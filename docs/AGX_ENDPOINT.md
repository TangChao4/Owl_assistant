# AGX Endpoint (Local Integration)

| Item | Value |
|------|-------|
| Ethernet IP | `192.168.90.3` (confirmed 2026-10-22) |
| SSH | `ssh agx` or `ssh ubuntu@192.168.90.3` (local Host aliases `agx` / `agx-eth` already configured) |
| Ollama | `http://192.168.90.3:11434` |
| Models | **`gpt-oss:20b`** (chat / forward / research propose) · **`deepseek-r1:14b`** (Plan/Docs via `ASSISTANT_MODEL`) |
| Listen | `OLLAMA_HOST=0.0.0.0:11434` (systemd override) |
| Routing doc | `docs/AGX_DUAL_MODEL_AND_USB_RESEARCH.md` |
| USB research pack | `/media/ubuntu/THIS/workers/` · stage: `scripts/usb_agx_research_stage.sh` |

## Local self-check
```bash
curl -s http://192.168.90.3:11434/api/tags
curl -s http://192.168.90.3:11434/api/generate \
  -d '{"model":"gpt-oss:20b","prompt":"ping","stream":false}'
```

## M2 one-shot from host

```bash
bash ~/owl-agent-line/scripts/agx_m2_run.sh "Your prompt here"
bash ~/owl-agent-line/scripts/agx_m2_run.sh --json "ping"   # raw Ollama JSON via SSH
```

> Do not commit passwords to the repo; prefer SSH public-key login.
