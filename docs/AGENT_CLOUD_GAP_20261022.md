# Agent + Cloud: design vs reality (2026-10-22 15:05 CST)

Hands-on acceptance on **host** after workers slim + M3 bridge work. Compare against `docs/DEV_PHASE_PLAN.md`, `docs/CLOUD_AGENT_M3.md`, `docs/CLOUD_EXAM_20261021.md`.

## Executive summary

| Layer | Verdict |
|-------|---------|
| **Host Agent (P1)** | **Meets design** for M1 chat, M3 ops, FS (host+AGX), launch dashboard, slash commands |
| **AGX (P0/M2)** | **Meets design** — `gpt-oss:20b`, smoke M2 SSH generate OK |
| **Cloud (M3)** | **Bridge meets design**; **cloud “growth” still below product intent** (same exam weak items as 10-21) |
| **Owl (P2/P3)** | **Blocked on hardware/LAN** — host-side secretary/forward ready, NX SSH unset |
| **Phase P3 integration** | **~40%** — host desk + cloud probe OK; owl path missing |

---

## Acceptance run (host, this session)

```bash
bash ~/owl-agent-line/scripts/endpoint_smoke.sh   # pass=4 fail=0
# :3000 /api/chat (token) → reply AGX_OK ~7s
# /cloud status, /todo list, /forward agx → pong + TCP receipt
# supervise loop: host_cloud_supervise.pid alive; log cycles ~66021
```

| Check | Design | Result | Δ |
|-------|--------|--------|---|
| P0 AGX tags | `gpt-oss:20b` on LAN | OK | 0 |
| P1 `:3000` healthz | Agent up | OK | 0 |
| P1-4 M2 | SSH `agx_m2_run.sh` | OK | 0 |
| P1-5 M3 SSH | `cloud_bridge` + key | OK | 0 |
| M1 chat | Local policy → AGX OpenAI API | `provider=local-openai-compatible`, `model=gpt-oss:20b` | 0 |
| `/api/status_snap?polish=false` | Fast ops modal | ~1 ms | 0 (P0 fix held) |
| `/api/capabilities` | FS + bridges | host+agx FS; cloud_m3 ok; **owl unavailable** | P2 |
| Launch dashboard | `:8765` | Listening | 0 |
| `cloud_bridge.py` on cloud | Same as host after deploy | **MD5 match** | 0 |

---

## Cloud probe vs 2026-10-21 exam

Remote `remote_probe()` (2026-10-22 ~15:04):

| Metric | 2026-10-21 exam | 2026-10-22 now | Notes |
|--------|-----------------|----------------|-------|
| Loops alive (4) | all true (synth fig **off**) | same | by design |
| Curriculum passed | 71/71, held_out=[] | same | **saturated** — no new curriculum growth |
| `research_unique` | 28464 | **28878** (+414) | slow corpus growth |
| `research_zeros` (streak) | ~33–34 | **7** | improved window |
| `research_new` (this cycle) | ~0 | **0** | still flat per cycle |
| `style_n` (real) | 2643 (~52.9/100) | **2699** (+56) | still below 60 band |
| Live loop exam | capability exam snapshot | **`project_refactor_safe` ok=1.0** | different exam id |
| `:8788` LLM | down | not probed; **still no cloud LLM** | M1/M2 on AGX only |

**Capability exam JSON on cloud** (`TC_ALPHA_CAPABILITY_EXAM.json`, scores unchanged vs 10-21):

| Score key | Value | Design gap |
|-----------|-------|------------|
| A_curriculum / anti-leak / V6 pack | 100 | OK |
| A_figure_real_style | **52.9** | Real figure band still low |
| A_live_exam | **0** | No live exam instance |
| TC_journal_structure | **0** | API `unhashable type: 'dict'` (unfixed) |
| TC_task_pipeline | **11.1** | Most tasks paused / awaiting_ceo_review |
| A_chat_local_no_official | 100 | Cloud chat = templates, not AGX-class LLM |

**Supervise log (host → cloud, ~14:57):** 自主训练 OK · 图风 OK · **企微 DOWN** · **CPU加压 DOWN** · disk OK.

**systemctl on cloud:** `workers-alpha-cpu-train.service` **active**; wecom-related unit **inactive** (matches 企微 DOWN).

---

## Phase checklist (design doc)

| Phase | Item | Status | Gap |
|-------|------|--------|-----|
| P0 | AGX 20B from host | **Done** | — |
| P1 | Agent + M3 bridge + smoke | **Done** | P1-3 host 7B light route still **open** |
| P2 | NX models + secretary on device | **Host stub only** | `COMPANION_OWL_SSH` empty; FS owl target false |
| P3-1 | user → owl → light local | **Not testable** | NX off LAN |
| P3-2 | user → owl → AGX | **Partial** | `/forward agx` works **from host** as owl stand-in |
| P3-3 | host desk → AGX / workers | **Done** | workers = agent-only tree |
| P3-4 | host checks cloud progress | **Done** | probe + `/cloud` + ops tab ~1.5s |
| P3-5 | DEVLOG + close ISSUEs | **Ongoing** | ISSUE-20261018-03 still open (growth) |
| P4 | GitHub | **Done** | local doc commits may lag remote |

---

## Host Agent: design features still open

| Feature | Intended | Current |
|---------|----------|---------|
| Owl primary HCI | NX `:11434` qwen3:4b | Host `:3000` is de facto entry |
| Multi-endpoint FS write on owl | SSH NX | owl target **unavailable** |
| Light/heavy split (P1-3) | Host 7B + AGX 20B | Single path to AGX 20B only |
| Docker Agent stack (ISSUE-02) | open-webui/n8n | Light **webapp** only — issue still **open** |
| Cloud “smarter over time” | M3 background | Processes healthy; **exam pipeline scores flat** |

---

## Recommended next actions (priority, NX delayed)

### A. This week (no Orin NX)

1. **Cloud ops recovery (M3)** — from host chat or API: `/cloud repair` (or one-shot `host_cloud_supervise_loop.sh --once` with repair) to target **企微** + **CPU加压** DOWN seen in supervise text.
2. **Fix `TC_journal_structure` on cloud** — debug `unhashable type: 'dict'` in cloud venv; re-run `tc_alpha_capability_exam.py`; record in DEVLOG.
3. **Human pipeline** — clear a batch of `awaiting_ceo_review` on cloud to move `TC_task_pipeline` off 11.1 (design assumes CEO gate, not automation).
4. **P3 host-only demo script** — document one path: `owl_agent_up.sh` → chat hard Q → AGX; ops modal 云 → probe; `/forward agx` receipt — satisfies P3-3/P3-4 until NX arrives.
5. **Optional P1-3** — if host disk/RAM allows, set `COMPANION_LOCAL_LLM_BASE` to host Ollama 7B for light Q&A; keep 20B on AGX for Plan/long chat.

### B. When NX carrier is on LAN

1. Set `COMPANION_OWL_SSH` + `COMPANION_FS_OWL_SSH` in secrets (not in git).
2. USB: `owl_nx_sync_models.sh` → `owl_nx_bootstrap.sh` per `docs/OWL_NX_DEPLOY.md`.
3. Re-run `endpoint_smoke.sh` + add **P2-accept** row (ollama list, `/owl health`, FS owl list).

### C. Do not expect (by design)

- Cloud `:8788` large-model inference — use **AGX M1/M2**.
- Curriculum count >71 without new shortfall design — loop will stay “alive but not growing”.
- Synth figure loop — intentionally **false**.

---

## TCP example (verified today)

```text
[TCP v1] from=owl to=agx mode=M1 pri=P1 kind=TASK id=fwd-20261022-e9aa761d
body: forward heavy inference
→ receipt ok=True, body includes pong from gpt-oss:20b
```

---

## References

- Prior cloud exam: `docs/CLOUD_EXAM_20261021.md`
- M3 bridge: `docs/CLOUD_AGENT_M3.md`
- Phases: `docs/DEV_PHASE_PLAN.md`
- Smoke: `scripts/endpoint_smoke.sh`
