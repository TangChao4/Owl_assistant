# owl-agent-line

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

Ops and development log line for Owl assistant, host task desk, AGX strong inference, and cloud TC/Alpha.

> **Copyright**: Tangchao · **License**: [MIT License](LICENSE)  
> **Does not include** model weights (GGUF / Ollama blobs). Weights stay on host disk, USB, or AGX.  
> Third-party model weights keep their original licenses (Qwen / Ollama model cards, etc.).

## Current status (2026-10-22)

| Endpoint | Status | Notes |
|----------|--------|-------|
| **Owl** `owl` | **P2 host bridge ready** | `docs/OWL_NX_DEPLOY.md` · `/owl` · `/todo` · NX online → bootstrap |
| **Host** `host` | **Offline agent up** | `workers` ~7G agent-only · deploy zip on USB |
| **AGX** `agx` | **P0 passed** | `192.168.90.3:11434` · `gpt-oss:20b` + `deepseek-r1:14b` · USB research pack staged read-only |
| **Cloud** `cloud` | M3 bridge OK; growth partial | Probe 2026-10-22: loops OK; research +414 / style +56 vs 10-21; pipeline exam scores flat; no `:8788` LLM |

Collab modes: **M1** host↔AGX · **M2** AGX solo · **M3** cloud participate.  
Unified messaging: **TCP v1** envelope (see protocol doc).

## Four endpoints

| Endpoint | Role |
|----------|------|
| Owl (Orin NX) | Primary HCI: human interface + secretary |
| Host (`host`) | Second task desk when Owl is not commanded + Agent/TC |
| AGX 32G | Strong inference (`gpt-oss:20b`) |
| Cloud | TC/Alpha CPU background (WeCom / curriculum / retrieval) |

Details: `devlogs/ROLE_SPLIT_OWL_AGX_CLOUD.md` · Host checklist: `devlogs/HOST_TASK_CHECKLIST.md`

## Host quick start

```bash
bash ~/owl-agent-line/scripts/owl_agent_up.sh
```

Opens **http://127.0.0.1:8765/** (launch dashboard), starts Agent + cloud supervise when reachable, and links to **:3000** chat.

## Key docs

| Doc | Purpose |
|-----|---------|
| [`docs/ENDPOINT_PROTOCOL.md`](docs/ENDPOINT_PROTOCOL.md) | Unified TCP envelope + endpoint registry |
| [`docs/COLLAB_MODES.md`](docs/COLLAB_MODES.md) | M1 / M2 / M3 |
| [`docs/DEV_PHASE_PLAN.md`](docs/DEV_PHASE_PLAN.md) | Phases P0–P4 |
| [`docs/CLOUD_EXAM_20261021.md`](docs/CLOUD_EXAM_20261021.md) | Cloud live exam report |
| [`docs/AGX_ENDPOINT.md`](docs/AGX_ENDPOINT.md) | AGX endpoint and connectivity |
| [`docs/AGENT_USER_GUIDE.md`](docs/AGENT_USER_GUIDE.md) | **Agent 使用指南**（启动、UI、命令） |
| [`docs/HOST_OFFLINE_AGENT.md`](docs/HOST_OFFLINE_AGENT.md) | Host offline agent → AGX |
| [`docs/CLOUD_AGENT_M3.md`](docs/CLOUD_AGENT_M3.md) | Host Agent → cloud SSH (supervise / pipeline) |
| [`docs/WORKERS_TASK_TREE.md`](docs/WORKERS_TASK_TREE.md) | Task tree (find files) |
| [`docs/devlog-auto-update.mdc`](docs/devlog-auto-update.mdc) | DEVLOG auto-update policy |
| [`devlogs/INDEX.md`](devlogs/INDEX.md) | Devlog and ISSUE index |

## Development logs (required)

After substantive changes or key decisions, **auto-update the devlog** in the same turn:

1. Append today's `devlogs/DEVLOG_YYYYMMDD.md` (create from template if needed)
2. Sync one row in `devlogs/INDEX.md`
3. If phase/endpoint status changed, update README "Current status" or task-tree rows
4. Prefer `mode=M1|M2|M3` and TCP `kind` (STATUS / CAPA / RESULT / BLOCKER)

Template: `devlogs/DEVLOG_TEMPLATE.md` · Policy: `docs/devlog-auto-update.mdc`  
(`.cursor/` is local-only and **must not** be pushed to GitHub.)

## Phase progress

| Phase | Scope | Status |
|-------|-------|--------|
| P0 | AGX connect + 20B acceptance | **Done** |
| P1 | Host offline Agent → AGX + cloud M3 | **P1 mostly done** · `owl_agent_up.sh` · `endpoint_smoke.sh` |
| P2 | Owl NX deploy | Pending |
| P3 | Multi-endpoint integration | Pending |
| P4 | GitHub → `TangChao4/Owl_assistant` | **First push done** · `./scripts/push_to_github.sh` |

## GitHub (host → Owl_assistant)

Remote: **https://github.com/TangChao4/Owl_assistant** (`main` · Public · MIT)

Host public IP changes do **not** affect push (`gh` account auth). Update LAN AGX/Owl docs only when those IPs change.

```bash
export PATH="$HOME/.local/bin:$PATH"
gh auth login -h github.com -p https -w   # once
cd ~/owl-agent-line
./scripts/push_to_github.sh "docs: sync"
```

Details: `docs/GITHUB_CONNECT.md`

### Optional USB log sync

USB: `/media/ubuntu/THIS/Owl_Secretary/09_DevLogs/` · Repo: `devlogs/`

```bash
cp -a /media/ubuntu/THIS/Owl_Secretary/09_DevLogs/*.md ~/owl-agent-line/devlogs/
cp -a ~/owl-agent-line/devlogs/*.md /media/ubuntu/THIS/Owl_Secretary/09_DevLogs/
```

## Layout

```
docs/       Roles, protocol, phase plan, exam reports, task tree, DEVLOG policy
devlogs/    Development logs and ISSUE index (required after substantive work)
issues/     Issue tickets
scripts/    Download/deploy helpers (no weights)
```

## Security

- Do not commit `*.secrets.env`, API keys, cloud private keys, or `.local/agx.env`.
- `.gitignore` excludes models, secrets, and `.cursor/`. Always `git status` before push.
