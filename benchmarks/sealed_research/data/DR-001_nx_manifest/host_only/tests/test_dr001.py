import importlib.util
from pathlib import Path

CAND = Path(__file__).resolve().parents[2] / "candidate" / "validate_manifest.py"


def _load():
    spec = importlib.util.spec_from_file_location("validate_manifest", CAND)
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


def test_dr001_rules():
    mod = _load()
    good = [
        {
            "path": "nx/cam0/frame_0001.bin",
            "sha256": "a" * 64,
            "captured_at": "2026-10-22T08:00:00+08:00",
        }
    ]
    r = mod.validate_manifest(good)
    assert r["ok"] and r["record_count"] == 1

    bad = [
        {"path": "/etc/passwd", "sha256": "b" * 64, "captured_at": "2026-10-22T08:00:00+08:00"},
        {"path": "nx/../escape", "sha256": "c" * 64, "captured_at": "2026-10-22T08:00:00+08:00"},
        {"path": "nx/dup", "sha256": "d" * 64, "captured_at": "2026-10-22T08:00:00+08:00"},
        {"path": "nx/dup", "sha256": "e" * 64, "captured_at": "2026-10-22T08:00:00+08:00"},
    ]
    r2 = mod.validate_manifest(bad)
    assert not r2["ok"]
    assert len(r2["errors"]) >= 3
