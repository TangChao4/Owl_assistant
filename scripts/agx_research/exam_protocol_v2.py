"""Sealed-exam protocol v2 — reduce leak / rote-memorization risk for 320-style banks.

Design:
- Campaign-specific seeds (not the fixed demo seed 20261022 alone).
- Evaluator keys stay on host/USB vault; AGX receives prompt-only exports.
- Leakage audit before any offline SFT (prompt hash overlap, group_id overlap).
- Fresh parametric items reuse the same generators as agx_research.code_challenges.

Does NOT start training. Grading on AGX without evaluator file is intentionally blocked.
"""
from __future__ import annotations

import hashlib
import json
import random
import sys
from pathlib import Path
from typing import Any

# Import generator from staged research pack when present.
_STAGING = Path(__file__).resolve().parents[2] / ".staging" / "AGX_Research_Engineer_V1_20261022"
if _STAGING.is_dir() and str(_STAGING) not in sys.path:
    sys.path.insert(0, str(_STAGING))

try:
    from agx_research.code_challenges import FAMILIES, make_one, evaluate  # type: ignore
except ImportError as e:
    raise SystemExit(
        "agx_research not on PYTHONPATH. Stage USB zip under owl-agent-line/.staging/ "
        "or set PYTHONPATH to AGX_Research_Engineer_V1_20261022 root."
    ) from e


def campaign_seed(campaign_id: str, base_seed: int = 0) -> int:
    h = hashlib.sha256(f"{campaign_id}:{base_seed}".encode()).hexdigest()
    return int(h[:12], 16)


def generate_campaign(
    out_dir: str | Path,
    *,
    campaign_id: str,
    per_family: int = 40,
    base_seed: int = 0,
    overwrite: bool = False,
) -> dict[str, Any]:
    """New question bank; evaluator written locally (move off AGX before exam)."""
    p = Path(out_dir)
    if p.exists() and any(p.iterdir()) and not overwrite:
        raise FileExistsError(f"refusing to overwrite non-empty {p}")
    p.mkdir(parents=True, exist_ok=True)
    seed = campaign_seed(campaign_id, base_seed)
    public: list[dict] = []
    secret: list[dict] = []
    for family in FAMILIES:
        for i in range(per_family):
            item = make_one(family, i, seed)
            public.append({k: item[k] for k in ("task_id", "family", "group_id", "prompt")})
            secret.append({k: item[k] for k in ("task_id", "answer", "answer_kind")})
    rng = random.Random(seed)
    groups = sorted({q["group_id"] for q in public})
    rng.shuffle(groups)
    n = len(groups)
    test_g = set(groups[: max(1, n // 5)])
    val_g = set(groups[max(1, n // 5) : max(2, 2 * n // 5)])
    for q in public:
        q["split"] = (
            "test"
            if q["group_id"] in test_g
            else ("validation" if q["group_id"] in val_g else "train")
        )
        q["campaign_id"] = campaign_id
    q_path = p / "questions.jsonl"
    e_path = p / "evaluator_HOST_ONLY.jsonl"
    agx_path = p / "questions_AGX_PROMPT_ONLY.jsonl"
    manifest_path = p / "CAMPAIGN_MANIFEST.json"
    if q_path.exists() or e_path.exists():
        raise FileExistsError("campaign files already exist")
    with q_path.open("w", encoding="utf-8") as f:
        for row in public:
            f.write(json.dumps(row, ensure_ascii=False) + "\n")
    with e_path.open("w", encoding="utf-8") as f:
        for row in secret:
            f.write(json.dumps(row, ensure_ascii=False) + "\n")
    with agx_path.open("w", encoding="utf-8") as f:
        for row in public:
            f.write(
                json.dumps(
                    {k: row[k] for k in ("task_id", "family", "group_id", "prompt", "split", "campaign_id")},
                    ensure_ascii=False,
                )
                + "\n"
            )
    manifest = {
        "protocol": "exam_v2",
        "campaign_id": campaign_id,
        "seed_derived": seed,
        "total": len(public),
        "families": list(FAMILIES),
        "per_family": per_family,
        "agx_may_receive": str(agx_path.name),
        "agx_must_not_receive": [e_path.name, "evaluator_ONLY.jsonl"],
        "grading_host_only": True,
        "demo_seed_20261022_is_not_this_bank": True,
    }
    manifest_path.write_text(json.dumps(manifest, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    return {
        "campaign_id": campaign_id,
        "seed": seed,
        "count": len(public),
        "questions": str(q_path),
        "evaluator_host": str(e_path),
        "agx_prompts": str(agx_path),
        "manifest": str(manifest_path),
    }


def prompt_fingerprint(prompt: str) -> str:
    return hashlib.sha256(prompt.strip().encode("utf-8")).hexdigest()


def load_jsonl(path: Path) -> list[dict]:
    return [json.loads(line) for line in path.read_text(encoding="utf-8").splitlines() if line.strip()]


def leakage_audit(
    *,
    train_jsonl: str | Path,
    exam_questions: str | Path,
    evaluator_jsonl: str | Path | None = None,
) -> dict[str, Any]:
    """Block SFT if train prompts overlap sealed exam or evaluator paths leak into train."""
    train_rows = load_jsonl(Path(train_jsonl))
    exam_rows = load_jsonl(Path(exam_questions))
    train_prompts: set[str] = set()
    train_groups: set[str] = set()
    for row in train_rows:
        msgs = row.get("messages") or []
        for m in msgs:
            if m.get("role") == "user":
                train_prompts.add(prompt_fingerprint(str(m.get("content", ""))))
        gid = (row.get("metadata") or {}).get("group_id")
        if gid:
            train_groups.add(str(gid))
    exam_fps = {prompt_fingerprint(r["prompt"]) for r in exam_rows if "prompt" in r}
    exam_groups = {str(r.get("group_id", "")) for r in exam_rows}
    overlap = train_prompts & exam_fps
    group_overlap = train_groups & exam_groups if train_groups else set()
    eval_on_disk = False
    if evaluator_jsonl:
        ep = Path(evaluator_jsonl)
        eval_on_disk = ep.is_file()
    passed = not overlap and not group_overlap
    return {
        "passed": passed,
        "train_rows": len(train_rows),
        "exam_rows": len(exam_rows),
        "prompt_hash_overlap_count": len(overlap),
        "group_id_overlap_count": len(group_overlap),
        "evaluator_present_in_audit_path": eval_on_disk,
        "policy": "Do not SFT on prompts that appear in active exam bank; keep evaluator off AGX.",
    }


def grade_on_host(questions: str | Path, evaluator: str | Path, predictions: str | Path, output: str | Path) -> dict:
    return evaluate(str(questions), str(evaluator), str(predictions), str(output))


def agx_safe_tree_check(root: str | Path) -> dict[str, Any]:
    """Fail if evaluator key files exist on AGX workspace (leak / cheat surface)."""
    root = Path(root)
    forbidden = []
    for name in ("evaluator_ONLY.jsonl", "evaluator_HOST_ONLY.jsonl"):
        hits = list(root.rglob(name))
        if hits:
            forbidden.extend(str(h) for h in hits)
    return {"passed": not forbidden, "forbidden_paths": forbidden}
