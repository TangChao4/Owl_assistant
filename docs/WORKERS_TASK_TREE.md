# Task Work Tree (find files)

> Updated: 2026-10-21  
> Two trees: this repo `~/owl-agent-line` (protocol/log line) + `~/workers` (research/Agent source).  
> Rule: **edit code in lib/scripts/main; run tasks under data/tasks; logs and protocol in owl-agent-line.**

---

## A. owl-agent-line (this repo)

```
owl-agent-line/
├── README.md                 ← four-endpoint status + key doc entry
├── LICENSE                   ← MIT · Copyright Tangchao
├── docs/
│   ├── ENDPOINT_PROTOCOL.md  ← TCP v1 unified protocol ★
│   ├── COLLAB_MODES.md       ← M1 / M2 / M3
│   ├── DEV_PHASE_PLAN.md     ← P0–P4 phases
│   ├── CLOUD_EXAM_20261021.md← cloud hands-on exam
│   ├── AGX_ENDPOINT.md       ← AGX :11434 / 20B
│   ├── OWL_AGX_CLOUD_ROLE_SPLIT.md
│   ├── HOST_OFFLINE_AGENT.md ← host offline Agent
│   ├── WORKERS_TASK_TREE.md  ← this file
│   ├── WORKERS_CLEANUP_*.md  ← workers cleanup candidates/done
│   ├── HOME_CLEANUP_CANDIDATES.md
│   └── GITHUB_CONNECT.md
├── devlogs/
│   ├── INDEX.md              ← log + ISSUE master table (keep in sync)
│   ├── DEVLOG_YYYYMMDD.md    ← daily DEVLOG (required for material changes)
│   ├── DEVLOG_TEMPLATE.md
│   ├── ROLE_SPLIT_OWL_AGX_CLOUD.md
│   └── HOST_TASK_CHECKLIST.md← host A–F + modes
├── issues/                   ← ISSUE tickets
├── scripts/
│   ├── push_to_github.sh     ← one-shot push Owl_assistant (no host IP bind) ★
│   ├── host_offline_agent.sh ← host offline Agent → AGX 20B ★
│   ├── owl_pack / …          ← see scripts/owl_pack/README.md
└── .cursor/rules/            ← project rules (incl. DEVLOG auto-update)
```

| What you want | Look first |
|---------------|------------|
| How four endpoints talk | `docs/ENDPOINT_PROTOCOL.md` |
| Pick M1/M2/M3 | `docs/COLLAB_MODES.md` · `devlogs/HOST_TASK_CHECKLIST.md` |
| Tonight’s phase | `docs/DEV_PHASE_PLAN.md` |
| **Host offline Agent** | `docs/HOST_OFFLINE_AGENT.md` · `scripts/host_offline_agent.sh` |
| Cloud capability | `docs/CLOUD_EXAM_20261021.md` |
| Call AGX | `docs/AGX_ENDPOINT.md` · `http://192.168.90.3:11434` |
| Push GitHub | `scripts/push_to_github.sh` · `docs/GITHUB_CONNECT.md` |
| Write/find logs | `devlogs/INDEX.md` · today’s `DEVLOG_*.md` |

---

## B. workers (research / Agent source)

> Root: `/home/ubuntu/workers` (post-cleanup ~38G class; trust local machine)

```
workers/
├── main.py, ceo_qt.py          ← entry: submission pipeline / CEO desk
├── lib/                        ← core libs (companion / sci_* / anti_freeze…)
├── scripts/companion/          ← cloud loops, host Agent helper scripts
├── scripts/gpu/                ← host GPU / adapter training
├── tools/                      ← ops helpers
├── deploy/                     ← deploy (companion Docker, cloud env)
├── config/                     ← plan/policy JSON
├── docs/                       ← notes and role docs
├── tests/                      ← tests
├── data/
│   ├── tasks/<task_name>/      ← current paper task workspace
│   ├── runtime/                ← runtime state
│   ├── logs/                   ← logs
│   ├── tc_alpha_research_prep_v2/  ← Alpha prep / corpus
│   ├── datasets/               ← dataset cache
│   └── backups/                ← auto backups
├── DELIVER_* / DELIVER_submission_pack/ ← deliver packs (read-only archive; Chinese dirname on disk)
├── .venv/                      ← Python env (do not search as source)
└── third_party/, dataset_*     ← third-party and large datasets
```

| What you want | Look at these paths |
|---------------|---------------------|
| A secretary/Agent chat | `lib/companion/` · `deploy/companion/` · `docs/COMPANION_*.md` |
| B call AGX / local LLM | `docs/LOCAL_FIRST_5060_POLICY.json` · companion secrets (do not commit) |
| C research submission continue | `main.py` · `data/tasks/<current_task>/` · `docs/JOURNAL_LOCK.json` |
| D check cloud/progress | `scripts/companion/cloud_status_probe.py` · `data/runtime/STATUS_NOW.md` |
| E figure style / journal frame | `lib/sci_figure_style/` · `lib/sci_journal_structure/` |
| F anti-freeze | `lib/anti_freeze_cursor/` · `python main.py anti-freeze` |
| G Jetson edge | `lib/jetson_remote/` · `kits/jetson_kit_bearing/` |
| H write DEVLOG | **`~/owl-agent-line/devlogs/`** (do not dump under workers root) |

### Do not search these as “source”

`.venv/` · `__pycache__/` · `data/backups/` · `DELIVER_*` old zips · `third_party/` large libs · `dataset_*`

---

## C. Endpoint quick reference (matches protocol)

| ID | Address | Main API |
|----|---------|----------|
| `owl` | Orin NX (TBD) | small-model Ollama |
| `host` | local Ubuntu | Agent (planned :3000) · workers |
| `agx` | `192.168.90.3` | `http://192.168.90.3:11434` · `gpt-oss:20b` |
| `cloud` | `39.96.82.193` | SSH; no public LLM |
