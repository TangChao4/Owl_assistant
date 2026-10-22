# AGX offline QLoRA (early-stop, resumable)

Uses **AGX system `python3`** + **`~/.local` PyTorch**; no full duplicate venv required.

## Termination (default)

| Priority | Condition |
|----------|-----------|
| **Primary** | **Early stopping** on **`eval_loss`**: no improvement ≥ `AGX_TRAIN_EARLY_THRESHOLD` (default `0.002`) for **`AGX_TRAIN_EARLY_PATIENCE`** eval rounds (default **4**; eval every **25** steps). |
| **Output** | **`load_best_model_at_end`** → best checkpoint reload before `final_adapter/`. |
| **Safety** | Optional **`AGX_TRAIN_MAX_SEC`** (default **0** = off). Set e.g. `86400` for a 24h hard cap. |
| **Manual** | `agx_train_ctl.sh stop` → SIGTERM + `interrupt_save/`. |

`RUN_STATE.json` fields: `termination` (`early_stop` | `time_limit` | `completed` | `failed` | …), `best_eval_loss`, `last_eval_loss`, `early_stop_streak`, `early_stop_best_loss`.

**Resume-safe early stop:** uses `EvalEarlyStopCallback` in `agx_offline_qlora_train.py` (not HF `EarlyStoppingCallback`). Resuming after an old crash at `KeyError: 'EarlyStoppingCallback'` is fixed by updating scripts and `agx_train_ctl.sh resume` (checkpoints kept).

**Broken `checkpoint-150`:** a failed save leaves `optimizer.pt` but **no** `trainer_state.json`. Resume must use **125**, not 150. On AGX:

```bash
grep EvalEarlyStop ~/owl-agent-line/scripts/agx_offline_qlora_train.py   # must match (not EarlyStoppingCallback)
bash ~/owl-agent-line/scripts/agx_train_ctl.sh repair   # drops incomplete checkpoint-* dirs
bash ~/owl-agent-line/scripts/agx_train_ctl.sh resume
```

**Verify on AGX:**

```bash
python3 -m pytest ~/owl-agent-line/tests/test_agx_train_early_stop.py -q   # logic replay (any machine)
bash ~/owl-agent-line/scripts/agx_train_smoke.sh   # GPU: save + resume, no KeyError
```

## One-time on AGX

```bash
bash ~/owl-agent-line/scripts/agx_ensure_train_deps.sh
```

## Control (on AGX)

```bash
bash ~/owl-agent-line/scripts/agx_train_ctl.sh start   # early-stop; frees Ollama VRAM first
bash ~/owl-agent-line/scripts/agx_train_ctl.sh stop    # SIGTERM → checkpoint
bash ~/owl-agent-line/scripts/agx_train_ctl.sh resume  # continues + same stop policy
bash ~/owl-agent-line/scripts/agx_train_ctl.sh status
```

Tune without editing code:

```bash
AGX_TRAIN_EARLY_PATIENCE=3 AGX_TRAIN_EARLY_THRESHOLD=0.001 \
  bash ~/owl-agent-line/scripts/agx_train_ctl.sh resume
```

## Host deploy (Ethernet)

```bash
bash ~/owl-agent-line/scripts/agx_deploy_offline_train.sh
bash ~/owl-agent-line/scripts/agx_deploy_offline_train.sh --start
```

Artifacts: `~/agx_autotrain/runs/<RUN_ID>/` (`checkpoint-*`, `final_adapter/`, `RUN_STATE.json`, `train.log`).

## Notes

- **No gpt-oss:20b weight training** on Orin (Ollama inference only).
- Base model: **Qwen2.5-7B-Instruct** QLoRA on curriculum JSONL.
- Runtime: `HF_HUB_OFFLINE=1`.
- After changing stop policy on a **running** job: `stop` → rsync scripts → `resume` (checkpoints kept).
