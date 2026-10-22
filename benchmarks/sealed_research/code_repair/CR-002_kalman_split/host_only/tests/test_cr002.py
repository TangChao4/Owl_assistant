import importlib.util
import math
import random
import sys
from pathlib import Path

TASK_ROOT = Path(__file__).resolve().parents[2]


def _load_pkg():
    sys.path.insert(0, str(TASK_ROOT))
    import importlib

    return importlib.import_module("candidate.kalman_runner")


def reference(observations, q, r, gate):
    x, p = 0.0, 1.0
    out = []
    for z, dt in observations:
        p = p + q * max(dt, 1e-6)
        if z is not None:
            s = p + r
            innov = z - x
            if abs(innov) <= gate * math.sqrt(s):
                k = p / s
                x = x + k * innov
                p = (1 - k) * p
        out.append(x)
    return out


def test_kalman_runner_matches_reference():
    mod = _load_pkg()
    rng = random.Random(7)
    for _ in range(20):
        n = rng.randint(8, 60)
        obs = []
        val = 0.0
        for _ in range(n):
            dt = rng.uniform(0.05, 0.2)
            val += rng.gauss(0, 0.3)
            z = val + rng.gauss(0, 0.8) if rng.random() > 0.15 else None
            obs.append((z, dt))
        q, r, gate = 0.05, 0.5, 2.5
        got = mod.run_filter(obs, q, r, gate)
        exp = reference(obs, q, r, gate)
        assert len(got) == len(exp)
        assert all(math.isclose(a, b, abs_tol=1e-5) for a, b in zip(got, exp))
