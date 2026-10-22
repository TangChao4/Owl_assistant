#!/usr/bin/env python3
"""Resumable offline QLoRA on AGX (Orin). No Hub access at runtime if LOCAL_FILES_ONLY=1.

Graceful interrupt: SIGINT/SIGTERM saves checkpoint + RUN_STATE.json.
"""
from __future__ import annotations

import argparse
import json
import os
import shutil
import signal
import sys
import time
from pathlib import Path

_SCRIPT_DIR = Path(__file__).resolve().parent
if str(_SCRIPT_DIR) not in sys.path:
    sys.path.insert(0, str(_SCRIPT_DIR))

# Offline-first before HF imports
os.environ.setdefault("HF_HUB_OFFLINE", "1")
os.environ.setdefault("TRANSFORMERS_OFFLINE", "1")
os.environ.setdefault("HF_DATASETS_OFFLINE", "1")


TRAIN_SCRIPT_REV = "20261022d"


def latest_valid_checkpoint(out: Path) -> Path | None:
    """Highest step dir that finished saving (trainer_state.json present)."""
    cks = sorted(out.glob("checkpoint-*"), key=lambda x: int(x.name.split("-")[-1]))
    for ck in reversed(cks):
        if (ck / "trainer_state.json").is_file():
            return ck
    return None


def broken_checkpoint_names(out: Path) -> list[str]:
    return [
        p.name
        for p in sorted(out.glob("checkpoint-*"), key=lambda x: int(x.name.split("-")[-1]))
        if p.is_dir() and not (p / "trainer_state.json").is_file()
    ]


def remove_broken_checkpoints(out: Path) -> list[str]:
    removed: list[str] = []
    for name in broken_checkpoint_names(out):
        shutil.rmtree(out / name, ignore_errors=True)
        removed.append(name)
    return removed


def early_stop_step(
    *,
    eval_loss: float,
    best_loss: float | None,
    bad_streak: int,
    patience: int,
    threshold: float,
) -> tuple[float, int, bool]:
    patience = max(1, int(patience))
    threshold = float(threshold)
    loss = float(eval_loss)
    if best_loss is None or loss < best_loss - threshold:
        return loss, 0, False
    streak = int(bad_streak) + 1
    best = float(best_loss) if best_loss is not None else loss
    return best, streak, streak >= patience


def early_stop_state_from_run(run_state: dict) -> tuple[float | None, int]:
    best = run_state.get("early_stop_best_loss")
    if best is None and run_state.get("best_eval_loss") is not None:
        best = run_state.get("best_eval_loss")
    streak = int(run_state.get("early_stop_streak") or 0)
    if best is not None:
        best = float(best)
    return best, streak


def read_text_jsonl(path: Path) -> list[dict]:
    rows = []
    for line in path.read_text(encoding="utf-8").splitlines():
        if not line.strip():
            continue
        obj = json.loads(line)
        text = obj.get("text") or obj.get("content")
        if not text:
            raise ValueError(f"missing text in {path}")
        rows.append({"text": text})
    if not rows:
        raise ValueError(f"empty {path}")
    return rows


def main() -> int:
    p = argparse.ArgumentParser()
    p.add_argument("--model", required=True, help="Local HF model directory")
    p.add_argument("--train-jsonl", required=True)
    p.add_argument("--eval-jsonl", required=True)
    p.add_argument("--output", required=True)
    p.add_argument("--run-id", default="default")
    p.add_argument(
        "--max-duration-sec",
        type=int,
        default=0,
        help="Safety time cap only (0=off). Primary stop: early stopping on eval_loss.",
    )
    p.add_argument("--max-steps", type=int, default=0, help="Optional hard step cap (0=off)")
    p.add_argument("--save-steps", type=int, default=25)
    p.add_argument("--eval-steps", type=int, default=0, help="0 = same as save-steps")
    p.add_argument("--logging-steps", type=int, default=5)
    p.add_argument("--early-stopping-patience", type=int, default=4)
    p.add_argument(
        "--early-stopping-threshold",
        type=float,
        default=0.002,
        help="Min eval_loss improvement to reset patience",
    )
    p.add_argument("--lora-r", type=int, default=16)
    p.add_argument("--resume", action="store_true")
    args = p.parse_args()

    out = Path(args.output)
    out.mkdir(parents=True, exist_ok=True)
    state_path = out / "RUN_STATE.json"
    run_state = {
        "run_id": args.run_id,
        "started_at": time.time(),
        "max_duration_sec": args.max_duration_sec,
        "early_stopping_patience": args.early_stopping_patience,
        "status": "running",
        "last_checkpoint": None,
        "termination": None,
    }
    if args.resume and state_path.is_file():
        run_state.update(json.loads(state_path.read_text(encoding="utf-8")))
        run_state["status"] = "running"
        run_state["resumed_at"] = time.time()
        run_state.pop("error", None)
        run_state.pop("save_error", None)
    run_state["max_duration_sec"] = args.max_duration_sec
    run_state["early_stopping_patience"] = args.early_stopping_patience
    run_state["early_stopping_threshold"] = float(args.early_stopping_threshold)
    run_state["train_script_rev"] = TRAIN_SCRIPT_REV

    resume_ckpt: str | None = None
    if args.resume:
        removed = remove_broken_checkpoints(out)
        if removed:
            run_state["removed_broken_checkpoints"] = removed
            print(f"[agx_train] removed incomplete: {', '.join(removed)}", file=sys.stderr)
        valid = latest_valid_checkpoint(out)
        if not valid:
            state_path.write_text(json.dumps(run_state, indent=2), encoding="utf-8")
            raise FileNotFoundError(
                f"No resumable checkpoint under {out} (need checkpoint-*/trainer_state.json)."
            )
        resume_ckpt = str(valid)
        run_state["last_checkpoint"] = resume_ckpt
        run_state["status"] = "running"
        run_state.pop("signal", None)
        run_state.pop("finished_at", None)
        run_state.pop("error", None)
        run_state.pop("note", None)
        state_path.write_text(json.dumps(run_state, indent=2), encoding="utf-8")
        print(f"[agx_train] resume from {resume_ckpt} (rev {TRAIN_SCRIPT_REV})", file=sys.stderr)

    import torch
    from torch.utils.data import Dataset as TorchDataset
    from peft import LoraConfig, get_peft_model, prepare_model_for_kbit_training
    from transformers import (
        AutoModelForCausalLM,
        AutoTokenizer,
        BitsAndBytesConfig,
        Trainer,
        TrainingArguments,
        TrainerCallback,
        DataCollatorForLanguageModeling,
    )

    if not torch.cuda.is_available():
        raise RuntimeError("CUDA required")

    train_rows = read_text_jsonl(Path(args.train_jsonl))
    eval_rows = read_text_jsonl(Path(args.eval_jsonl))

    bnb = BitsAndBytesConfig(
        load_in_4bit=True,
        bnb_4bit_quant_type="nf4",
        bnb_4bit_compute_dtype=torch.bfloat16 if torch.cuda.is_bf16_supported() else torch.float16,
        bnb_4bit_use_double_quant=True,
    )
    tok = AutoTokenizer.from_pretrained(args.model, local_files_only=True)
    if tok.pad_token is None:
        tok.pad_token = tok.eos_token
    model = AutoModelForCausalLM.from_pretrained(
        args.model,
        quantization_config=bnb,
        device_map="auto",
        local_files_only=True,
        torch_dtype=torch.bfloat16 if torch.cuda.is_bf16_supported() else torch.float16,
    )
    model = prepare_model_for_kbit_training(model)
    model = get_peft_model(
        model,
        LoraConfig(
            r=args.lora_r,
            lora_alpha=args.lora_r * 2,
            lora_dropout=0.05,
            bias="none",
            task_type="CAUSAL_LM",
            target_modules=["q_proj", "k_proj", "v_proj", "o_proj", "gate_proj", "up_proj", "down_proj"],
        ),
    )

    class TextJsonlDataset(TorchDataset):
        def __init__(self, rows: list[dict], max_length: int = 1024):
            self.items = []
            for row in rows:
                enc = tok(row["text"], truncation=True, max_length=max_length)
                self.items.append(
                    {
                        "input_ids": enc["input_ids"],
                        "attention_mask": enc["attention_mask"],
                    }
                )

        def __len__(self) -> int:
            return len(self.items)

        def __getitem__(self, idx: int) -> dict:
            row = self.items[idx]
            input_ids = torch.tensor(row["input_ids"], dtype=torch.long)
            labels = input_ids.clone()
            return {
                "input_ids": input_ids,
                "attention_mask": torch.tensor(row["attention_mask"], dtype=torch.long),
                "labels": labels,
            }

    train_ds = TextJsonlDataset(train_rows)
    eval_ds = TextJsonlDataset(eval_rows)

    t0 = time.time()
    trainer_ref: list = []

    max_dur = int(args.max_duration_sec or 0)
    step_cap = int(args.max_steps or 0)
    eval_steps = int(args.eval_steps or args.save_steps)

    def _persist_state(extra: dict | None = None) -> None:
        if extra:
            run_state.update(extra)
        state_path.write_text(json.dumps(run_state, indent=2), encoding="utf-8")

    class TimeLimitCallback(TrainerCallback):
        def on_step_end(self, _args, state, control, **kwargs):
            if max_dur > 0:
                elapsed = time.time() - t0 + float(run_state.get("elapsed_before_sec", 0))
                if elapsed >= max_dur:
                    run_state["termination"] = "time_limit"
                    control.should_training_stop = True
            if step_cap > 0 and state.global_step >= step_cap:
                run_state["termination"] = "max_steps"
                control.should_training_stop = True

    class RunStateCallback(TrainerCallback):
        def on_save(self, _args, state, control, **kwargs):
            ck = out / f"checkpoint-{state.global_step}"
            if ck.is_dir():
                run_state["last_checkpoint"] = str(ck)
            _persist_state({"global_step": state.global_step})

        def on_evaluate(self, _args, state, control, metrics=None, **kwargs):
            if metrics and "eval_loss" in metrics:
                loss = float(metrics["eval_loss"])
                extra = {
                    "global_step": state.global_step,
                    "last_eval_loss": loss,
                    "best_metric": float(state.best_metric) if state.best_metric is not None else None,
                }
                if state.best_metric is not None:
                    extra["best_eval_loss"] = float(state.best_metric)
                _persist_state(extra)

        def on_train_end(self, _args, state, control, **kwargs):
            if not run_state.get("termination"):
                run_state["termination"] = "completed"
            _persist_state({"global_step": state.global_step, "finished_at": time.time()})

    class EvalEarlyStopCallback(TrainerCallback):
        """Resume-safe early stop (avoids HF EarlyStoppingCallback checkpoint KeyError)."""

        def __init__(self, patience: int, threshold: float) -> None:
            self.patience = max(1, int(patience))
            self.threshold = float(threshold)
            self.best_loss, self.bad_streak = early_stop_state_from_run(run_state)

        def on_evaluate(self, _args, state, control, metrics=None, **kwargs):
            if not metrics or "eval_loss" not in metrics:
                return
            self.best_loss, self.bad_streak, stop = early_stop_step(
                eval_loss=float(metrics["eval_loss"]),
                best_loss=self.best_loss,
                bad_streak=self.bad_streak,
                patience=self.patience,
                threshold=self.threshold,
            )
            _persist_state(
                {
                    "early_stop_best_loss": self.best_loss,
                    "early_stop_streak": self.bad_streak,
                    "best_eval_loss": self.best_loss,
                }
            )
            if stop:
                run_state["termination"] = "early_stop"
                control.should_training_stop = True

    train_args = TrainingArguments(
        output_dir=str(out),
        per_device_train_batch_size=1,
        per_device_eval_batch_size=1,
        gradient_accumulation_steps=16,
        learning_rate=2e-4,
        num_train_epochs=1,
        max_steps=args.max_steps if args.max_steps > 0 else 100000,
        logging_steps=args.logging_steps,
        save_steps=args.save_steps,
        eval_strategy="steps",
        eval_steps=eval_steps,
        save_total_limit=4,
        load_best_model_at_end=True,
        metric_for_best_model="eval_loss",
        greater_is_better=False,
        bf16=torch.cuda.is_bf16_supported(),
        fp16=not torch.cuda.is_bf16_supported(),
        gradient_checkpointing=True,
        report_to="none",
        dataloader_num_workers=0,
        remove_unused_columns=False,
    )
    collator = DataCollatorForLanguageModeling(tok, mlm=False)

    def _graceful_stop(signum, frame):
        st = trainer_ref[0] if trainer_ref else None
        run_state["status"] = "interrupted"
        run_state["signal"] = signum
        run_state["elapsed_sec"] = time.time() - t0
        if st:
            try:
                st.save_model(str(out / "interrupt_save"))
                st.save_state()
            except Exception as e:
                run_state["save_error"] = str(e)
        state_path.write_text(json.dumps(run_state, indent=2), encoding="utf-8")
        sys.exit(128 + signum)

    signal.signal(signal.SIGINT, _graceful_stop)
    signal.signal(signal.SIGTERM, _graceful_stop)

    trainer = Trainer(
        model=model,
        args=train_args,
        train_dataset=train_ds,
        eval_dataset=eval_ds,
        data_collator=collator,
        callbacks=[
            TimeLimitCallback(),
            RunStateCallback(),
            EvalEarlyStopCallback(
                patience=args.early_stopping_patience,
                threshold=args.early_stopping_threshold,
            ),
        ],
    )
    trainer_ref.append(trainer)

    state_path.write_text(json.dumps(run_state, indent=2), encoding="utf-8")
    try:
        trainer.train(resume_from_checkpoint=resume_ckpt)
        run_state["status"] = "completed"
        if not run_state.get("termination"):
            run_state["termination"] = "completed"
    except KeyboardInterrupt:
        run_state["status"] = "interrupted"
        run_state["termination"] = "interrupted"
    except Exception as e:
        run_state["status"] = "failed"
        run_state["error"] = f"{type(e).__name__}: {e}"
        raise
    finally:
        run_state["elapsed_sec"] = time.time() - t0
        run_state["finished_at"] = time.time()
        try:
            trainer.save_model(str(out / "final_adapter"))
            if trainer.state.best_metric is not None:
                run_state["best_eval_loss"] = float(trainer.state.best_metric)
        except Exception as e:
            run_state.setdefault("save_error", str(e))
        _persist_state()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
