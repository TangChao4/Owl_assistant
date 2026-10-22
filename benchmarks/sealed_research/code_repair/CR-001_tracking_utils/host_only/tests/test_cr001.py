import importlib.util
import math
import random
import sys
from pathlib import Path

TASK_ROOT = Path(__file__).resolve().parents[2]
CAND = TASK_ROOT / "candidate"


def test_rmse_and_batch():
    sys.path.insert(0, str(TASK_ROOT))
    import importlib

    metrics = importlib.import_module("candidate.tracking_metrics")
    utils = importlib.import_module("candidate.tracking_utils")
    rng = random.Random(42)
    pairs = []
    for _ in range(8):
        n = rng.randint(1, 40)
        p = [rng.uniform(-50, 50) for _ in range(n)]
        a = [x + rng.gauss(0, 0.5) for x in p]
        pairs.append((p, a))
    rmses = utils.batch_rmse(pairs)
    assert len(rmses) == 8
    for (p, a), r in zip(pairs, rmses):
        exp = math.sqrt(sum((x - y) ** 2 for x, y in zip(p, a)) / len(p))
        assert math.isclose(r, exp, rel_tol=1e-9, abs_tol=1e-8)
    for fn in (
        lambda: metrics.rmse_sequence([], []),
        lambda: metrics.rmse_sequence([1.0], [1.0, 2.0]),
    ):
        try:
            fn()
            raise AssertionError("expected ValueError")
        except ValueError:
            pass
