import importlib.util
import math
import sys
from pathlib import Path

CAND = Path(__file__).resolve().parents[2] / "candidate" / "sim_cv_kalman.py"
REF = Path(__file__).resolve().parents[1] / "reference_sim.py"


def _load(path, name):
    spec = importlib.util.spec_from_file_location(name, path)
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


def test_er001_metrics_match_reference():
    cand = _load(CAND, "cand_sim")
    ref = _load(REF, "ref_sim")
    for seed in (9001, 9002, 9011):
        a = cand.run_sim(seed=seed, steps=140)
        b = ref.run_sim(seed=seed, steps=140)
        assert a["updates_used"] == b["updates_used"]
        assert math.isclose(a["rmse"], b["rmse"], rel_tol=0.01, abs_tol=1e-4)
