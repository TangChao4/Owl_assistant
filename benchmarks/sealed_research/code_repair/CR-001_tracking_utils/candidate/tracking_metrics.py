"""Intentionally broken — sealed exam starter."""


def rmse_sequence(predicted, actual):
    if len(predicted) != len(actual):
        raise ValueError("length mismatch")
    if len(predicted) == 0:
        raise ValueError("empty sequence")
    # BUG: returns mean squared error, not RMSE
    return sum((a - b) ** 2 for a, b in zip(predicted, actual)) / len(predicted)
