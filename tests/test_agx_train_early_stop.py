"""Reproducible early-stop policy (matches AGX QLoRA trainer)."""

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "scripts"))
from agx_train_early_stop import early_stop_step, state_from_run


def test_improvement_resets_streak():
    best, streak, stop = early_stop_step(
        eval_loss=0.5, best_loss=0.6, bad_streak=3, patience=4, threshold=0.002
    )
    assert stop is False
    assert streak == 0
    assert best == 0.5


def test_small_improvement_within_threshold_counts_as_bad():
    best, streak, stop = early_stop_step(
        eval_loss=0.599, best_loss=0.6, bad_streak=0, patience=4, threshold=0.002
    )
    assert stop is False
    assert streak == 1
    assert best == 0.6


def test_patience_triggers_stop():
    best, streak, stop = early_stop_step(
        eval_loss=0.61, best_loss=0.6, bad_streak=3, patience=4, threshold=0.002
    )
    assert stop is True
    assert streak == 4
    assert best == 0.6


def test_replay_user_run_eval_loss_plateau():
    """Simulate AGX run: best ~0.10019 then flat evals → stop on 4th bad."""
    best: float | None = None
    streak = 0
    losses = [0.12, 0.105, 0.10019386559724808, 0.1005, 0.1004, 0.1006, 0.10055]
    stopped_at = None
    for i, loss in enumerate(losses):
        best, streak, stop = early_stop_step(
            eval_loss=loss,
            best_loss=best,
            bad_streak=streak,
            patience=4,
            threshold=0.002,
        )
        if stop:
            stopped_at = i
            break
    assert stopped_at == 6
    assert abs(best - 0.10019386559724808) < 1e-9


def test_state_from_run_resume():
    rs = {
        "best_eval_loss": 0.10019386559724808,
        "early_stop_streak": 2,
    }
    best, streak = state_from_run(rs)
    assert abs(best - 0.10019386559724808) < 1e-9
    assert streak == 2
