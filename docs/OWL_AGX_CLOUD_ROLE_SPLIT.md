# Four-Endpoint Role Split: owl · host · agx · cloud

> Version: 2026-10-21c  
> Use: role lock, troubleshooting, DEVLOG cross-check.  
> Hardware: Orin NX (owl) · host Ubuntu+RTX5060 (second task desk) · AGX Orin 32G (strong inference, `192.168.90.3`) · cloud `39.96.82.193` (TC/Alpha CPU)

---

## 1. One-line roles

| Role | One line |
|------|----------|
| **owl assistant** | **First interaction entry**: HMI + all secretary work; Orin NX + small models. |
| **host (second task desk)** | **When you are not commanding owl**, publish tasks, orchestrate Agent, develop and accept; 5060 runs 7B+LoRA. |
| **AGX Orin 32G** | **Strong inference node**: callable by host/owl; can also **work alone** (host SSH / `ollama` direct). |
| **cloud** | **Optional participant** 7×24 CPU background: WeCom, curriculum, retrieval, backups, submission status; no large-weight training. |

### Three compute collaboration modes (host · agx · cloud)

| Mode | Who works | Typical use |
|------|-----------|-------------|
| **M1 host↔agx collaborate** | host orchestrates + agx infers | host Agent/TC splits tasks; heavy inference to `http://192.168.90.3:11434` (`gpt-oss:20b`); host may run 7B light Q&A in parallel |
| **M2 agx alone** | agx only | SSH onto board or onboard terminal: `ollama run gpt-oss:20b`; edge scripts/batch; **does not need host online** |
| **M3 cloud participates** | cloud ± host/agx | curriculum/retrieval/WeCom/submission long-runs on cloud; host issues or checks progress; for strong inference host calls AGX again, or writes results back to cloud |

Composable: e.g. “host issues research task → cloud resident loops → hard spots host pulls AGX for fill-in inference”.

### Entry priority (when publishing tasks)
1. **owl nearby** → prefer speak to owl (secretary / follow-up / relay).  
2. **not commanding owl** → **host** publishes tasks (Agent / TC / call AGX / invite cloud).  
3. **compute only, no orchestration** → **M2**: go straight to AGX.  
4. Heavy inference prefers **agx**; research long-runs prefer **cloud/host TC**; do not force owl to grind heavy compute.

---

## 2. owl assistant (Orin NX) — HMI + full secretary duty

### 2.1 Must own
- **HMI**: dialogue, expression/status, voice entry (after ASR/TTS).
- **Secretary work**: calendar reminders, todos, meeting summaries, file-sort hints, progress nudges, briefs.
- **Light memory retrieval**: embedding; does not replace TC evidence store.
- **Routing**: deep reasoning → host Agent or direct AGX; do not carry 20B yourself.
- **Peripheral coordination**: mic, wake, expression hardware (service layer, not model-only).

### 2.2 Explicitly does not
- No resident 14B/20B; no TC `main.py`/DELIVER; no locked metrics edits.  
- No venv on exFAT; USB is model warehouse only.

### 2.3 Models (USB prepared)
`Owl_Secretary/01_LLM_Models/ollama_store`: `qwen3:4b` / `1.7b` / `coder:3b` / `embedding:0.6b` / `vl:4b`.

---

## 3. host (Ubuntu + RTX 5060) — second task publish platform

> Definition: **when you are not issuing commands to owl, default publish and manage tasks on host.**

### 3.1 Must own (task publish and orchestration)
- **Task publish desk**: create/issue/reassign research and engineering tasks (TC `main.py`, Agent chat, scripts, deploy commands).
- **Agent host**: Open WebUI / companion webapp / custom Agent; take user intent → split tasks → call tools.
- **Downstream scheduling**:
  - heavy inference → **agx** (`http://AGX_IP:11434`, e.g. `gpt-oss:20b`)
  - research long-run / WeCom / curriculum backup → **cloud** or host runs TC directly
  - secretary / human-side reminders → may sync back to **owl** (if online), else host keeps its own todos
- **Dev and packaging**: code changes, write `09_DevLogs`, build deploy packs, organize USB models.
- **Acceptance desk**: cloud probe, AGX `ollama list`, TC STATUS, anti-leak exam results.

### 3.2 Must own (local compute)
- **Resident light inference**: Qwen2.5-**7B** GGUF (prefer Q5, backup Q4) + Alpha **LoRA** (`AlphaCmd/lora/...`).
- **On demand**: host may briefly run 14B GGUF, but prefer parking 14B/20B on AGX so desktop does not fight for 8GB.
- **Full HF 7B**: only for QLoRA/training; daily chat uses GGUF.

### 3.3 Host task checklist (daily tick)

| Task type | Host action | Downstream |
|-----------|-------------|------------|
| A. Publish secretary (no owl) | issue reminders / summaries / nudges in Agent/todos | sync when owl online; else host executes |
| B. Publish strong-inference questions | Agent sends prompt to AGX API | AGX 20B/14B |
| C. Publish research/submission tasks | `cd workers` → `main.py` / CEO desk / auto-run | cloud resident loops + host intervention |
| D. Check progress | read STATUS / cloud probe / ask Alpha | cloud, host artifacts |
| E. Deploy and download mgmt | model copy, Docker/webapp, resume notes | NX / AGX / USB |
| F. Write DEVLOG | `09_DevLogs/DEVLOG_*.md` + ISSUE | USB index |

### 3.4 Explicitly does not
- Does not replace owl as persona / expression / voice hardware primary entry (that is NX).  
- Does not pin 20B long-term on the 5060.  
- Does not pretend cloud “curriculum pass count” = capability accepted.

### 3.5 Host assets already present (placement)
| Asset | Use |
|-------|-----|
| `~/models/gguf/qwen25-7b` | host Agent resident |
| `~/models/gguf/qwen25-14b` | backup; prefer copy/leave for AGX |
| system Ollama `qwen3:8b` / `14b` | host or migrate AGX |
| `AlphaCmd/lora/*` | host 7B persona/doc adapt |
| `workers` + companion | task publish and TC |
| USB Owl store | **not a host resident service**; for NX |

### 3.6 Acceptance bar (host task desk)
- Without owl: publish one task → see a receipt (finished locally or handed to AGX/cloud).  
- Agent entry opens (webapp or WebUI).  
- Log device field can mark `host`.

---

## 4. AGX Orin 32G — strong inference

### 4.1 Must own
- Heavy model service (`gpt-oss:20b` etc.), LAN API.  
- Take deep reasoning / long code thrown by owl or **host**.  
- One large model resident at a time; OOM fallback ladder: 20B → 14B → R1-14B distill → back to host 7B.

### 4.2 Does not
- Not first/second “publish task” entry (entry is owl or host).  
- No secretary hardware stack; no cloud curriculum grind loops.

---

## 5. cloud — TC/Alpha CPU background

### 5.1 Must own
- WeCom/mobile status, curriculum loops, research net, figure-style learning, submission state machine, backup sync.  

### 5.2 Does not
- No download/train of large weights; no HMI secretary; no 20B.  
- Volume metrics ≠ acceptance (anti-leak / held-out are the bar).

---

## 6. Collaboration map

```
        ┌─ prefer ─→ owl(NX) ──secretary──→ user
user ───┤
        └─ when not commanding owl ─→ host(second desk/Agent/TC)
                              ├─ heavy inference ─→ agx
                              └─ research long-run/WeCom ─→ cloud
```

| Scenario | Primary publish entry | Execute |
|----------|----------------------|---------|
| In-person secretary, reminders, relay | owl | NX small models; host/AGX if needed |
| Sitting at the computer issuing tasks | **host** | Agent/TC; heavy → agx; long-run → cloud |
| Compute only, no chat | host or script direct | agx |
| Submission/curriculum/retrieval resident | host issues or cloud self-runs | cloud |

---

## 7. DEVLOG conventions

- Directory: `Owl_Secretary/09_DevLogs/`  
- Device field pick one primary: `owl_nx` | `host` | `agx` | `cloud` (host task desk uses **`host`**).  
- Templates: `devlogs/DEVLOG_TEMPLATE.md`, `devlogs/ISSUE_TEMPLATE.md`; index: `INDEX.md`.
