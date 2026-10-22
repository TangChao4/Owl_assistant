#!/usr/bin/env python3
"""CLI for exam protocol v2 (host-side). No training."""
from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent
sys.path.insert(0, str(ROOT / "agx_research"))

from exam_protocol_v2 import (  # noqa: E402
    agx_safe_tree_check,
    generate_campaign,
    grade_on_host,
    leakage_audit,
)


def main() -> int:
    p = argparse.ArgumentParser(description="AGX exam v2 — campaigns, leakage audit, host-only grade")
    sub = p.add_subparsers(dest="cmd", required=True)

    g = sub.add_parser("campaign-new", help="Generate fresh bank (evaluator stays on host)")
    g.add_argument("--out", required=True)
    g.add_argument("--campaign-id", required=True)
    g.add_argument("--per-family", type=int, default=40)
    g.add_argument("--base-seed", type=int, default=0)
    g.add_argument("--overwrite", action="store_true")

    a = sub.add_parser("leakage-audit", help="Before offline SFT")
    a.add_argument("--train-jsonl", required=True)
    a.add_argument("--exam-questions", required=True)
    a.add_argument("--evaluator", default="")

    s = sub.add_parser("agx-tree-check", help="Ensure no evaluator files under AGX tree")
    s.add_argument("--root", required=True)

    gr = sub.add_parser("grade", help="Host-only grading")
    gr.add_argument("--questions", required=True)
    gr.add_argument("--evaluator", required=True)
    gr.add_argument("--predictions", required=True)
    gr.add_argument("--output", required=True)

    args = p.parse_args()
    try:
        if args.cmd == "campaign-new":
            out = generate_campaign(
                args.out,
                campaign_id=args.campaign_id,
                per_family=args.per_family,
                base_seed=args.base_seed,
                overwrite=args.overwrite,
            )
        elif args.cmd == "leakage-audit":
            out = leakage_audit(
                train_jsonl=args.train_jsonl,
                exam_questions=args.exam_questions,
                evaluator_jsonl=args.evaluator or None,
            )
        elif args.cmd == "agx-tree-check":
            out = agx_safe_tree_check(args.root)
        else:
            out = grade_on_host(args.questions, args.evaluator, args.predictions, args.output)
        print(json.dumps(out, ensure_ascii=False, indent=2))
        if args.cmd in ("leakage-audit", "agx-tree-check") and not out.get("passed", True):
            return 2
        return 0
    except Exception as e:
        print(f"ERROR {type(e).__name__}: {e}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
