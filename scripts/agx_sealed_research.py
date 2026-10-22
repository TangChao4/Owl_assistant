#!/usr/bin/env python3
"""CLI: sealed research exam (independent of training)."""
from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent / "agx_research"))
from sealed_research_exam import (  # noqa: E402
    export_agx_bundle,
    host_selfcheck_all,
    list_tasks,
    verify_submission,
    verify_starter_should_fail,
)


def main() -> int:
    p = argparse.ArgumentParser(description="Sealed research exam — code/embodied/data reproduction")
    sub = p.add_subparsers(dest="cmd", required=True)

    sub.add_parser("list", help="List tasks")

    e = sub.add_parser("export-agx", help="Prompt + broken candidate only")
    e.add_argument("--out", required=True)
    e.add_argument("--tasks", default="", help="Comma-separated task ids; default all")

    v = sub.add_parser("verify", help="Grade a candidate directory")
    v.add_argument("--task", required=True)
    v.add_argument("--candidate", required=True)

    sub.add_parser("selfcheck", help="Assert starters fail host tests (CI)")

    s = sub.add_parser("starter-check", help="One task starter should fail")
    s.add_argument("--task", required=True)

    args = p.parse_args()
    if args.cmd == "list":
        out = list_tasks()
    elif args.cmd == "export-agx":
        ids = [x.strip() for x in args.tasks.split(",") if x.strip()] or None
        out = export_agx_bundle(args.out, task_ids=ids)
    elif args.cmd == "verify":
        out = verify_submission(args.task, args.candidate)
    elif args.cmd == "selfcheck":
        out = host_selfcheck_all()
    else:
        out = verify_starter_should_fail(args.task)

    print(json.dumps(out, ensure_ascii=False, indent=2))
    if args.cmd == "selfcheck" and not out.get("passed"):
        return 2
    if args.cmd == "verify" and not out.get("passed"):
        return 2
    if args.cmd == "starter-check" and not out.get("verified_non_vacuous"):
        return 2
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
