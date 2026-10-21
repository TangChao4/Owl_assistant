# Host task checklist (second task desk) quick ref

When to use host: **When you are not giving commands to Owl, publish tasks here by default.**  
Collab modes: `docs/COLLAB_MODES.md` → **M1** host↔AGX · **M2** AGX alone · **M3** cloud participates.

| ID | Task | How | Mode | Downstream |
|----|------|-----|------|------------|
| A | Secretary (no Owl) | `bash ~/owl-agent-line/scripts/host_offline_agent.sh` → `:3000` | **M1 offline** | see `docs/HOST_OFFLINE_AGENT.md` |
| B | Heavy reasoning (collab) | Agent → `http://192.168.90.3:11434` | **M1** | `gpt-oss:20b` |
| B2 | Heavy reasoning (alone) | `ssh agx` → `ollama run` | **M2** | fetch results yourself |
| C | Research / submit | `workers` / `main.py` / CEO | **M3**±M1 | cloud + optional AGX |
| D | Check progress | STATUS / cloud probe | **M3** | cloud, host |
| E | Deploy / download | copy models, webapp/Docker | — | NX / AGX / USB |
| F | Devlog | `DEVLOG_*.md` with `mode=M1|M2|M3` | — | INDEX |

Models: host resident 7B GGUF(+LoRA); 20B on AGX; Owl small models for NX.  
Log device field: host = `host`.
