# AGX Endpoint (Local Integration)

| Item | Value |
|------|-------|
| Ethernet IP | `192.168.90.3` |
| SSH | `ssh agx` or `ssh ubuntu@192.168.90.3` (local Host aliases `agx` / `agx-eth` already configured) |
| Ollama | `http://192.168.90.3:11434` |
| Model | `gpt-oss:20b` |
| Listen | `OLLAMA_HOST=0.0.0.0:11434` (systemd override) |

## Local self-check
```bash
curl -s http://192.168.90.3:11434/api/tags
curl -s http://192.168.90.3:11434/api/generate \
  -d '{"model":"gpt-oss:20b","prompt":"ping","stream":false}'
```

> Do not commit passwords to the repo; prefer SSH public-key login.
