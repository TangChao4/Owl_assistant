import importlib.util
import math
import random
from pathlib import Path

CAND = Path(__file__).resolve().parents[2] / "candidate" / "fk_2r.py"


def _load():
    spec = importlib.util.spec_from_file_location("fk_2r", CAND)
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


def _ref(configs):
    out = []
    for c in configs:
        l1, l2 = float(c["l1"]), float(c["l2"])
        t1 = math.radians(float(c["q1_deg"]))
        t2 = math.radians(t1 + math.radians(float(c["q2_deg"])))
        out.append((l1 * math.cos(t1) + l2 * math.cos(t2), l1 * math.sin(t1) + l2 * math.sin(t2)))
    return out


def test_fk_batch():
    mod = _load()
    rng = random.Random(3)
    configs = [
        {"l1": rng.randint(2, 9), "l2": rng.randint(2, 9), "q1_deg": a, "q2_deg": b}
        for a, b in [(0, 0), (30, 45), (90, -30), (-45, 60)]
    ]
    configs += [
        {
            "l1": rng.uniform(2, 8),
            "l2": rng.uniform(2, 8),
            "q1_deg": rng.uniform(-120, 120),
            "q2_deg": rng.uniform(-90, 90),
        }
        for _ in range(12)
    ]
    got = mod.fk_batch(configs)
    exp = _ref(configs)
    assert len(got) == len(exp)
    for (x, y), (xe, ye) in zip(got, exp):
        assert math.isclose(x, xe, abs_tol=1e-6) and math.isclose(y, ye, abs_tol=1e-6)
