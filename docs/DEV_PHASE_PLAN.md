# Development Phases and Task Plan (gpt-oss:20b ready)

> Updated: 2026-10-21  
> Prerequisite: on AGX, `ollama list` already shows `gpt-oss:20b` (~13GB)  
> Four-endpoint role split: `devlogs/ROLE_SPLIT_OWL_AGX_CLOUD.md`

---

## Overall goals

| Endpoint | Target state |
|----------|--------------|
| **owl (NX)** | Secretary interaction usable (small models) |
| **host** | Second task desk + Agent; can collaborate with AGX **(M1)** |
| **agx** | `gpt-oss:20b` LAN API; can also **work alone (M2)** |
| **cloud** | **Can participate (M3)**: CPU background; host can schedule / check progress |

Collaboration modes: `docs/COLLAB_MODES.md` (M1 collaborate / M2 AGX alone / M3 cloud participates).

---

## Phase 0 — Connectivity acceptance (tonight / 0.5 day)

**Goal**: Confirm AGX 20B is callable from host; record IP.

| ID | Task | Who | Acceptance |
|----|------|-----|------------|
| P0-1 | On AGX, confirm service listens on `0.0.0.0:11434` | agx | `ss -lntp \| grep 11434` or `OLLAMA_HOST=0.0.0.0:11434` |
| P0-2 | Local trial run on AGX | agx | `ollama run gpt-oss:20b "ping"` returns a reply |
| P0-3 | Record AGX IP; write into host SSH / docs | host | note in `devlogs`; `ssh` works |
| P0-4 | Host `curl http://AGX_IP:11434/api/tags` | host | JSON includes `gpt-oss:20b` |
| P0-5 | Host sends one generate request | host | `/api/generate` or OpenAI-compatible API works |

**Host quick test:**
```bash
export AGX=http://<AGX_IP>:11434
curl -s "$AGX/api/tags" | head
curl -s "$AGX/api/generate" -d '{"model":"gpt-oss:20b","prompt":"Introduce yourself in one sentence","stream":false}'
```

---

## Phase 1 — Land the three modes (1–2 days)

**Goal**: M1 collaboration usable; M2 solo has a playbook; M3 cloud is queryable and can participate.

| ID | Task | Mode | Acceptance |
|----|------|------|------------|
| P1-1 | Start light Agent (host) | M1 | `:3000` or WebUI opens |
| P1-2 | Agent strong model → `http://192.168.90.3:11434` / `gpt-oss:20b` | M1 | chat goes to AGX |
| P1-3 | Optional host 7B for light Q&A | M1 | light/heavy split |
| P1-4 | Docs/scripts: AGX solo (tmux / `ollama run` / return results) | M2 | one independent run via SSH on board |
| P1-5 | Host cloud probe; when needed “cloud task + AGX fill-in inference” | M3±M1 | progress readable; hard spots can go to AGX |
| P1-6 | DEVLOG labels `mode=M1/M2/M3` | all | INDEX searchable |

**Routing rules:**
- Secretary / short answers → owl or host 7B  
- Long reasoning / hard code → **agx (M1 or M2)**  
- Research long-runs / WeCom / curriculum → **cloud (M3)**; pull AGX again for hard spots

---

## Phase 2 — Owl secretary on NX (1–2 days, can parallel Phase 1)

**Goal**: First interaction entry is live.

| ID | Task | Notes | Acceptance |
|----|------|-------|------------|
| P2-1 | Copy USB `ollama_store` wholesale onto NX **ext4** | Do not run the service on exFAT | `ollama list` shows 5 models |
| P2-2 | Start Ollama on NX; primary `qwen3:4b` | | host dialogue works |
| P2-3 | Minimal secretary: reminders, todos, brief templates | start filling `05_Agent_System` | demo 3 scenarios |
| P2-4 | Heavy-task forward: owl → host Agent or direct AGX | | forward has receipt |
| P2-5 | (Optional) speech / expression later | see SPEECH guide | do not block main path |

---

## Phase 3 — Three-endpoint integration (1 day)

| ID | Task | Acceptance |
|----|------|------------|
| P3-1 | user → owl → (light) finish locally | secretary scenarios OK |
| P3-2 | user → owl → AGX 20B | hard questions OK |
| P3-3 | user → host task desk → AGX / workers | can issue tasks without owl |
| P3-4 | host checks cloud progress | `cloud_status_probe` returns results |
| P3-5 | Write `DEVLOG` + close related ISSUEs (IP, 20B) | INDEX updated |

---

## Phase 4 — Open source and engineering (0.5–1 day)

| ID | Task | Acceptance |
|----|------|------------|
| P4-1 | `gh auth login` + public push `owl-agent-line` (MIT / Tangchao) | visible on GitHub |
| P4-2 | README: architecture, how to attach AGX, how to start Agent | outsiders can follow |
| P4-3 | (Optional) `workers` `git init` then separate repo or submodule strategy | large weights still stay out of Git |

---

## Phase 5 — Enhancements (schedule later)

- owl: ASR/TTS, expression hardware  
- agx: 14B backup, R1 distill comparison; **do not keep three large models resident at once**  
- cloud: break curriculum idle spin / figure-style increments (per defect list; no fake metrics)  
- host: continue disk cleanup (Trash T3 etc., per your checklist)  

---

## Recommended order this week (20B ready)

```
P0 connect AGX API
 → P1-1/P1-3 host Agent + point at 20B   (usable immediately)
 → P2 owl NX (can parallel)
 → P3 integration
 → P4 push GitHub
```

## Open these files first each development session

| Scenario | File |
|----------|------|
| Role split | `devlogs/ROLE_SPLIT_OWL_AGX_CLOUD.md` |
| Host tasks | `devlogs/HOST_TASK_CHECKLIST.md` |
| Find workers code | `docs/WORKERS_TASK_TREE.md` |
| This plan | `docs/DEV_PHASE_PLAN.md` |
| Logs | `devlogs/DEVLOG_TEMPLATE.md` → today’s DEVLOG |

## Risks

- AGX and host firewall / different subnet → P0 fails  
- 20B + long context OOM → lower ctx or fall back to 14B  
- Docker not up → use light webapp first (P1-1)  
- owl and AGX sharing one `OLLAMA_MODELS` → forbidden; keep directories separate  
