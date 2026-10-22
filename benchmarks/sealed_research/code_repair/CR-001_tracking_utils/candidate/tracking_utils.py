"""Batch helper — one bug in delegation."""

from .tracking_metrics import rmse_sequence


def batch_rmse(pairs):
    """pairs: list of (predicted_list, actual_list). Returns list of rmse floats."""
    out = []
    for pred, act in pairs:
        # BUG: swaps pred/act for even indices
        if len(out) % 2 == 0:
            out.append(rmse_sequence(act, pred))
        else:
            out.append(rmse_sequence(pred, act))
    return out
