# Four-Endpoint Unified Communication Protocol (TCP: Task · Capability · Progress)

> Version: 2026-10-21 · Copyright: Tangchao  
> Purpose: **fast, focused, unambiguous** communication among host / agx / cloud / owl.  
> Collaboration modes: M1 host↔agx · M2 agx alone · M3 cloud participates (see `COLLAB_MODES.md`)

---

## 1. Endpoint registry

| Endpoint ID | Role | Address | Main port / API |
|-------------|------|---------|-----------------|
| `owl` | Secretary interaction | Orin NX (IP TBD) | Ollama small models; secretary Agent |
| `host` | Second task desk / orchestration | local Ubuntu | Agent :3000 (planned); workers |
| `agx` | Strong inference | `192.168.90.3` | **Ollama `http://192.168.90.3:11434`** · model `gpt-oss:20b` |
| `cloud` | TC/Alpha CPU background | `39.96.82.193` | SSH; mobile planned `:8765` (not open on public net); **no** `:8788` LLM |

SSH aliases (host): `agx` → 192.168.90.3 · cloud: `root@39.96.82.193` (key)

---

## 2. Message envelope (required for all important communication)

Use the same skeleton in speech, tickets, or logs:

```text
[TCP v1]
from: host|agx|cloud|owl|user
to:   host|agx|cloud|owl|broadcast
mode: M1|M2|M3|M1+M3|owl
pri:  P0|P1|P2
kind: TASK|STATUS|CAPA|RESULT|BLOCKER|ASK
id:   YYYYMMDD-short-id
body: ...
```

| Field | Meaning |
|-------|---------|
| `pri P0` | Blocks tonight’s goal; must reply |
| `pri P1` | Affects capability/progress; reply same day |
| `pri P2` | Can defer |
| `kind TASK` | Issue a task |
| `kind STATUS` | Progress heartbeat |
| `kind CAPA` | Capability exam / scores |
| `kind RESULT` | Output path or summary |
| `kind BLOCKER` | Stuck point (include fallback) |
| `kind ASK` | Yes/no or single value only |

**Example (host asks AGX to infer):**
```text
[TCP v1] from=host to=agx mode=M1 pri=P0 kind=TASK id=20261021-gen1
body: model=gpt-oss:20b; prompt=...; num_predict=256; return=content
```

**Example (query cloud):**
```text
[TCP v1] from=host to=cloud mode=M3 pri=P1 kind=STATUS id=20261021-cloud1
body: want=probe+exam_scores
```

---

## 3. Standard capability / progress dictionary (focus only on these keys)

### 3.1 Cloud `STATUS` required keys
```json
{
  "endpoint": "cloud",
  "alive": {"curriculum": true, "research": true, "real_style": true, "tc_auto": true},
  "passed": 71,
  "held_out_fails": [],
  "inject_path_live": false,
  "research_unique": 28464,
  "research_zeros": 34,
  "style_n": 2643,
  "llm8788": false,
  "mobile8765": "listen_local",
  "paper_top": "edge-bearing… awaiting_ceo_review"
}
```
Collect: `python scripts/companion/cloud_status_probe.py`

### 3.2 Cloud `CAPA` required keys (capability exam)
Report only weak and full-score items; avoid pasting the full dump:
```json
{
  "endpoint": "cloud",
  "scores_weak": {"A_live_exam": 0, "A_figure_real_style": 52.9, "TC_journal_structure": 0, "TC_task_pipeline": 11.1},
  "scores_strong": ["A_curriculum", "TC_v6_18pack", "anti_leak"],
  "verdict": "healthy_process_stalled_growth"
}
```
Collect: `PYTHONPATH=/opt/workers python scripts/companion/tc_alpha_capability_exam.py`

### 3.3 AGX `STATUS` / `RESULT`
```json
{
  "endpoint": "agx",
  "ollama": "http://192.168.90.3:11434",
  "models": ["gpt-oss:20b"],
  "listen": "0.0.0.0:11434",
  "last_result": {"content": "…", "eval_count": 56}
}
```

### 3.4 Host `TASK` routing words (speed decisions)
| User intent contains | Route |
|----------------------|-------|
| secretary / remind / follow-up | → `owl` (else `host`) |
| hard reasoning / long text / deep code | → `agx` (M1 or M2) |
| submission / curriculum / WeCom / lit net | → `cloud` (M3) |
| check progress | → matching endpoint `STATUS` |

---

## 4. One-shot health commands (run on host)

```bash
# AGX
curl -s http://192.168.90.3:11434/api/tags | head -c 200; echo

# Cloud probe (SSH)
ssh -i ~/.ssh/workers_cloud_ed25519 root@39.96.82.193 \
  'cd /opt/workers && .venv/bin/python scripts/companion/cloud_status_probe.py'

# Cloud capability exam (slower, ~2min)
ssh -i ~/.ssh/workers_cloud_ed25519 root@39.96.82.193 \
  'cd /opt/workers && PYTHONPATH=/opt/workers .venv/bin/python scripts/companion/tc_alpha_capability_exam.py' \
  | tail -20
```

---

## 5. Communication speed rules

1. **Lead with the envelope** (from/to/mode/pri/kind/id), then details.  
2. **Cloud: do not treat “how many cycles ran” as a score**; talk `held_out`, weak scores, task state transitions.  
3. **AGX: do not retell install stories**; talk model / latency / OOM / content.  
4. **BLOCKER must include a fallback** (e.g. 20B OOM → 14B; cloud has no LLM → hand off to agx).  
5. Logs: `devlogs/DEVLOG_*.md` use the same `id` and `mode`.  

## 6. Current baseline (after 2026-10-21 exam)

| Endpoint | One-line status |
|----------|-----------------|
| `agx` | 20B available on LAN |
| `cloud` | loops alive, anti-leak passed, V6 green; growth stalled; no local LLM |
| `host` | orchestration seat; Agent wiring is next priority |
| `owl` | host bridge P2-3/4 done; NX deploy scripts ready; set `COMPANION_OWL_SSH` |
