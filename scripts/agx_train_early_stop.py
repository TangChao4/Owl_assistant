"""Deterministic early-stop on eval_loss (resume-safe; no HF EarlyStoppingCallback)."""

from __future__ import annotations


def early_stop_step(
    *,
    eval_loss: float,
    best_loss: float | None,
    bad_streak: int,
    patience: int,
    threshold: float,
) -> tuple[float, int, bool]:
    """One eval round. Returns (new_best_loss, new_bad_streak, should_stop)."""
    patience = max(1, int(patience))
    threshold = float(threshold)
    loss = float(eval_loss)
    if best_loss is None or loss < best_loss - threshold:
        return loss, 0, False
    streak = int(bad_streak) + 1
    best = float(best_loss) if best_loss is not None else loss
    return best, streak, streak >= patience


def state_from_run(run_state: dict) -> tuple[float | None, int]:
    best = run_state.get("early_stop_best_loss")
    if best is None and run_state.get("best_eval_loss") is not None:
        best = run_state.get("best_eval_loss")
    streak = int(run_state.get("early_stop_streak") or 0)
    if best is not None:
        best = float(best)
    return best, streak
