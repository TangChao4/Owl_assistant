# Host Offline Agent (P1)

> Updated: 2026-10-21 · mode=**M1**  
> Goal: no public-net LLM; host UI + LAN AGX `gpt-oss:20b` (if AGX unreachable, retarget host Ollama).

## Status

| Item | Value |
|------|-------|
| UI | companion webapp `http://<host>:3000/?token=…` |
| Policy | `COMPANION_LLM_POLICY=local` (**never go to cloud**) |
| Inference | `COMPANION_LOCAL_LLM_BASE=http://192.168.90.3:11434/v1` |
| Model | `gpt-oss:20b` |
| Host fallback Ollama | `127.0.0.1:11434` · `qwen3:8b` / `qwen3:14b` |

Token lives in `~/workers/data/runtime/COMPANION.secrets.env` as `COMPANION_CHAT_TOKEN` (do not commit or share in chat).

## One-shot start / stop

```bash
# Start / restart
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

## UI: collapse + Plan mode

- Long messages collapse by default; click **展开全文** / use header **全部展开|全部折叠** (Cursor-like).
- Role select includes **Plan · 开发计划**: developer planning dialogue with Goal / Assumptions / Plan / Risks / Next.
- Plan mode always uses the local/LAN LLM when available; confirm before asking to execute/write files.
