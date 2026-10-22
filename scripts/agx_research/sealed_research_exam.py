"""Sealed research examination — code + embodied + data tracks, separate from training."""
from __future__ import annotations

import json
import os
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path
from typing import Any

REPO_ROOT = Path(__file__).resolve().parents[2]
BENCH = REPO_ROOT / "benchmarks" / "sealed_research"
MANIFEST = BENCH / "manifest_tasks.json"

TASK_DIRS = {
    "CR-001": BENCH / "code_repair" / "CR-001_tracking_utils",
    "CR-002": BENCH / "code_repair" / "CR-002_kalman_split",
    "ER-001": BENCH / "embodied" / "ER-001_cv_kalman_sim",
    "ER-002": BENCH / "embodied" / "ER-002_two_link_fk",
    "DR-001": BENCH / "data" / "DR-001_nx_manifest",
}


def load_manifest() -> dict:
    return json.loads(MANIFEST.read_text(encoding="utf-8"))


def list_tasks() -> list[dict]:
    return load_manifest()["tasks"]


def _test_file(task_id: str) -> Path:
    base = TASK_DIRS[task_id]
    tests = list((base / "host_only" / "tests").glob("test_*.py"))
    if len(tests) != 1:
        raise FileNotFoundError(f"expected one test module for {task_id}")
    return tests[0]


def run_pytest_on_candidate(task_id: str, candidate_root: Path, *, timeout: int = 60) -> dict[str, Any]:
    test_path = _test_file(task_id)
    env = {**os.environ, "PYTHONPATH": ""}
    cmd = [
        sys.executable,
        "-m",
        "pytest",
        str(test_path),
        "-q",
        "--tb=no",
    ]
    # Tests locate candidate relative to task dir; symlink submission into task if external.
    task_dir = TASK_DIRS[task_id]
    tmp = tempfile.mkdtemp(prefix="sealed_task_")
    work = Path(tmp)
    shutil.copytree(task_dir / "host_only", work / "host_only")
    shutil.copytree(candidate_root, work / "candidate")
    if (task_dir / "PROMPT.md").is_file():
        shutil.copy(task_dir / "PROMPT.md", work / "PROMPT.md")
    test_path = work / "host_only" / "tests" / _test_file(task_id).name

    try:
        p = subprocess.run(
            cmd,
            cwd=str(work),
            capture_output=True,
            text=True,
            timeout=timeout,
            env=env,
        )
        return {
            "task_id": task_id,
            "passed": p.returncode == 0,
            "returncode": p.returncode,
            "stdout": (p.stdout or "")[-2000:],
            "stderr": (p.stderr or "")[-2000:],
            "candidate": str(candidate_root),
        }
    finally:
        if tmp:
            shutil.rmtree(tmp, ignore_errors=True)


def verify_starter_should_fail(task_id: str) -> dict[str, Any]:
    """CI: bundled starter must fail (proves tests are non-vacuous)."""
    task_dir = TASK_DIRS[task_id]
    r = run_pytest_on_candidate(task_id, task_dir / "candidate")
    r["expect_pass"] = False
    r["verified_non_vacuous"] = not r["passed"]
    return r


def verify_submission(task_id: str, candidate_dir: str | Path) -> dict[str, Any]:
    r = run_pytest_on_candidate(task_id, Path(candidate_dir))
    r["expect_pass"] = True
    return r


def export_agx_bundle(out_dir: str | Path, *, task_ids: list[str] | None = None) -> dict[str, Any]:
    out = Path(out_dir)
    if out.exists() and any(out.iterdir()):
        raise FileExistsError(f"refusing non-empty {out}")
    out.mkdir(parents=True)
    ids = task_ids or [t["task_id"] for t in list_tasks()]
    exported = []
    for tid in ids:
        task_dir = TASK_DIRS[tid]
        dest = out / tid
        dest.mkdir()
        shutil.copy(task_dir / "PROMPT.md", dest / "PROMPT.md")
        shutil.copytree(task_dir / "candidate", dest / "candidate")
        meta = {
            "task_id": tid,
            "track": next(t["track"] for t in list_tasks() if t["task_id"] == tid),
            "host_only_tests": False,
            "training_data_allowed": False,
        }
        (dest / "AGX_MANIFEST.json").write_text(json.dumps(meta, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
        exported.append(tid)
    seal = {
        "protocol": "sealed_research_exam_v1",
        "tasks": exported,
        "forbidden_on_agx": ["host_only", "evaluator", "reference_sim.py", "golden"],
        "grading": "host_only_pytest",
    }
    (out / "SEALED_CAMPAIGN.json").write_text(json.dumps(seal, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    return {"out": str(out), "tasks": exported, "count": len(exported)}


def host_selfcheck_all() -> dict[str, Any]:
    results = []
    for t in list_tasks():
        tid = t["task_id"]
        results.append(verify_starter_should_fail(tid))
    ok = all(r["verified_non_vacuous"] for r in results)
    return {"all_starters_fail_tests": ok, "results": results, "passed": ok}
