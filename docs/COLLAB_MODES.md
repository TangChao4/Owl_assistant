# Collaboration Modes: Host · AGX · Cloud

AGX endpoint: `192.168.90.3:11434` · model: `gpt-oss:20b`  
SSH: `ssh agx` (user `ubuntu`)

---

## M1 — Host and AGX together

```
you → host Agent / workers
        ├─ light tasks → host 7B (optional)
        └─ heavy reasoning → AGX gpt-oss:20b
```

- Host owns: publish, split, tool calls, write logs, call cloud.  
- AGX owns: 20B inference API (callable by multiple clients).  
- Acceptance: host `curl http://192.168.90.3:11434/api/tags` works; Agent chat uses 20B.

---

## M2 — AGX works alone

```
you → SSH / onboard terminal → AGX (ollama / scripts)
(host may be off; cloud need not participate)
```

- Fits: batch inference, long thinking, onboard experiments, offline laptop scenarios.  
- Ops: `ssh agx` → `ollama run gpt-oss:20b`  
- Note: bring results back yourself via `scp` / USB to host or cloud; for unattended runs use `nohup` / `tmux`.

---

## M3 — Cloud participates

```
you → host (optional) → cloud TC/Alpha loops
                ↘ hard spots ↔ AGX (via host or scripts)
```

- Cloud: WeCom, curriculum, retrieval, figure style, submission status, backups.  
- Do not run 20B on cloud; strong models stay on AGX.  
- Host: `cloud_status_probe` / SSH to the cloud box to inspect loops; when extra inference is needed, use M1.

---

## How to choose

| Scenario | Mode |
|----------|------|
| Day-to-day dev, Agent chat, write-and-ask | **M1** |
| At the board / just need heavy compute | **M2** |
| Long-running submissions, WeCom, curriculum backend | **M3** (± M1) |
| Secretary chat, reminders | owl (may forward to M1/M2) |

In DEVLOGs, label the day mode: `mode=M1|M2|M3|M1+M3`.
