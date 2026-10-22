# Host Offline Agent (P1)

> Updated: 2026-10-21 · mode=**M1**  
> Goal: no public-net LLM; host UI + LAN AGX `gpt-oss:20b` (if AGX unreachable, retarget host Ollama).

## Status

| Item | Value |
|------|-------|
| UI | companion webapp `http://<host>:3000/?token=…` |
| Policy | `COMPANION_LLM_POLICY=local` (**never go to cloud**) |
| Inference | `COMPANION_LOCAL_LLM_BASE=http://192.168.90.3:11434/v1` |
| Chat model | `COMPANION_MODEL=gpt-oss:20b` |
| Plan / Docs model | `ASSISTANT_MODEL=deepseek-r1:14b` (AGX; reasoning without using 20B for every plan) |
| Host fallback Ollama | `127.0.0.1:11434` · `qwen3:8b` / `qwen3:14b` |

Token lives in `~/workers/data/runtime/COMPANION.secrets.env` as `COMPANION_CHAT_TOKEN` (do not commit or share in chat).

## Launch dashboard (recommended)

```bash
# Probe + start connectable pieces + open http://127.0.0.1:8765/
bash ~/owl-agent-line/scripts/owl_agent_up.sh

# Dashboard only (no auto-start)
bash ~/owl-agent-line/scripts/owl_agent_up.sh --ui

# Terminal status only
bash ~/owl-agent-line/scripts/owl_agent_up.sh --cli
```

Cards: **AGX Ollama** · **Host Ollama fallback** · **Agent :3000** · **Cloud M3 SSH** · **cloud supervise loop**.  
Button **启动可用组件** runs `host_offline_agent.sh` (Agent + M3 loop when SSH key is present).

## One-shot start / stop

```bash
# Start / restart (same as dashboard button)
bash ~/owl-agent-line/scripts/host_offline_agent.sh

# AGX IP changed:
AGX_OLLAMA_BASE=http://<newIP>:11434/v1 bash ~/owl-agent-line/scripts/host_offline_agent.sh

# Use host model only (no AGX dependency):
AGX_OLLAMA_BASE=http://127.0.0.1:11434/v1 AGX_MODEL=qwen3:8b \
  bash ~/owl-agent-line/scripts/host_offline_agent.sh
```

## Acceptance

```bash
curl -sf http://127.0.0.1:3000/healthz | head -c 120; echo
# provider should be local-openai-compatible (needs token; see secrets)
# Chat: open browser on :3000; or ask “in one sentence, are you local or cloud?”
```

Verified in person: AGX `/v1/chat/completions` works; engine `/llm` and natural-language chat both use `local-openai-compatible` / `gpt-oss:20b`.

## Notes

- **Host public IP changes**: does not affect this Agent (auth is local token + LAN Ollama).
- **AGX LAN IP changes**: set `AGX_OLLAMA_BASE` or secrets `COMPANION_LOCAL_LLM_BASE`, then rerun the script.
- Docker Open WebUI (Claude-first) is **not** this offline path; use the light webapp offline.
- If `safe_mode` is left on by mistake it blocks chat; the start script clears it when sqlite is healthy.

## Ops panel (自洽机 · 云 · 记忆)

Header **自洽机** / **云** / **记忆** open a **modal panel** (tabs + refresh). They no longer inject long blocks into chat.

Status API uses fast deterministic text (`polish=0` by default). Optional: `/api/status_snap?polish=1`.

## File workspace (host · AGX · Owl)

Click **文件** in the UI — opens a **workspace panel** (no longer spamming duplicate export cards in chat).

| Tab | Purpose |
|-----|---------|
| **工作区** | Browse / preview / edit under allowed roots |
| **导出下载** | Sandbox exports from `/write` / chat code fences |

Endpoints: **host** (default roots: `~/workers`, home) · **agx** (`ssh agx`, `/home/ubuntu`) · **owl** (set `COMPANION_FS_OWL_SSH=ubuntu@<nx-ip>` in secrets).

Writes require **Allow write** in the panel (or chat: `确认写入 <grant_id>` after `/fs write …`).

Chat: `/fs help` · `/fs list host …` · `/fs read agx …` · `/fs write host /path \| content`

## File exports (download links)

Like ChatGPT file cards: artifacts are written under `~/workers/data/runtime/companion_exports/` and served as clickable downloads in the UI.

| Command | Effect |
|---------|--------|
| `/write path.py \| content` | Single text/code file |
| `/write app.py` + fenced code block | Same |
| `/project app.zip` + multiple fences (`# path: rel`) | Zip of a small project |
| `/image title \| line1; line2` | Offline SVG (+ PNG chart if matplotlib available) |
| `/files` | List exports |
| UI button **文件** | Same list + download buttons |
| Natural language: "generate file / save as / export" | Code fences in the model reply are auto-saved |

Download URL shape: `/api/download/<id>?token=...` (Content-Disposition attachment).

Restart after code updates: `bash ~/owl-agent-line/scripts/host_offline_agent.sh`

## Cloud M3 (supervise + pipeline)

Host Agent talks to **39.96.82.193** via SSH (`lib/companion/cloud_bridge.py`):

- Chat: `/cloud status` · `/cloud supervise` · `/cloud repair` · `/cloud pipeline`
- UI header button **云**
- Background: `scripts/host_cloud_supervise_loop.sh --once`

Full doc: [`CLOUD_AGENT_M3.md`](CLOUD_AGENT_M3.md)

## Plan mode (P1)

- Role **Plan · 开发计划** uses **`ASSISTANT_MODEL`** on AGX (e.g. `deepseek-r1:14b`); Chat uses **`COMPANION_MODEL`** (e.g. `gpt-oss:20b`). Higher `max_tokens`, 180s client timeout, **auto-retry** if headings-only.
- User-facing walkthrough: [`AGENT_USER_GUIDE.md`](AGENT_USER_GUIDE.md)
- Tune via env: `COMPANION_PLAN_MAX_TOKENS`, `COMPANION_PLAN_TIMEOUT_SEC`, `COMPANION_PLAN_TEMPERATURE`.

## File workspace UX (P1)

- **导出下载** tab hides endpoint/path chrome; browse tab has **过滤文件名** search.
- Overlays set `aria-hidden` when closed.

## UI: collapse + Plan mode

- Long messages collapse by default; click **展开全文** / use header **全部展开|全部折叠** (Cursor-like).
- Role select includes **Plan · 开发计划**: developer planning dialogue with Goal / Assumptions / Plan / Risks / Next.
- Plan mode always uses the local/LAN LLM when available; confirm before asking to execute/write files.
