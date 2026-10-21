# Cloud Capability Hands-on Exam Report (2026-10-21 21:13 CST)

Host: `39.96.82.193` · dir: `/opt/workers` · uptime ~10d 11h · RAM 7.1Gi (avail ~4.3Gi) · **no GPU / :8788 down**

## 1. Progress snapshot (probe)

| Item | Value |
|------|-------|
| Four loops alive | curriculum / research_net / real_style / tc_autonomous = **true** (running ~3 days continuous; PIDs unchanged) |
| Synth-figure loop | **false** (stopped refresh by design) |
| Curriculum passed | **71/71**, `held_out_fails=[]`, `inject_path_live=false`, anti_leak=v3 |
| Curriculum loop | cycle **435**, sustained `skipped=no_open_shortfall` (**alive but not growing**) |
| Research net | unique_new **28464**, `consecutive_zero_new≈33–34` (near-window almost no new lit) |
| Real figure style | checkpoint **n=2643** (≈52.9/100), this cycle `new_this_cycle=0` |
| mobile | listening `:8765` on box; **public curl fails** (likely security group not open) |
| Edge paper STATUS | still on 2026-09-23 snapshot: `awaiting_ceo_review`, ≈62% |

## 2. Capability exam (`tc_alpha_capability_exam.py`, ran in person)

Artifact: `/opt/workers/data/runtime/companion_services/TC_ALPHA_CAPABILITY_EXAM.json`

| Score item | Score | Read |
|------------|-------|------|
| A_chat_local_no_official | 100 | local template chat works; no official LLM |
| A_emotion_retrieval | 80 | emotion retrieval mostly OK; occasional neighborhood noise |
| A_curriculum | 100 | curriculum all-pass + anti-leak gate pass |
| A_live_exam | **0** | **no live exam instance on site** |
| A_hard_deliverables | 100 | hard deliverable presence gate pass |
| A_figure_synth | 100 | synth figure corpus meets bar (refresh stopped) |
| A_figure_real_style | **52.9** | real figures 2643/5000; below 60 band |
| A_drill_local | 100 | |
| TC_v6_18pack | 100 | V6 self-test **18/18 PASS** |
| TC_figure_style_api | 100 | |
| TC_journal_structure | **0** | API error `unhashable type: 'dict'` |
| TC_artifacts_presence | 100 | metrics/figure_data/locks present |
| TC_task_pipeline | **11.1** | many tasks stuck paused / awaiting_ceo_review |
| TC_jetson | 100 | secrets/lock present |

Task state sample: paused×6 · awaiting_ceo_review×6 · completed×2 · failed×1 · …

## 3. One-line verdict

**Processes healthy, anti-leak passed, V6 self-test all green; but capability growth is largely stalled (no curriculum shortfall to train, near-zero new lit, real figures growing slowly), submission pipeline mostly waiting on human review, and cloud has no local large-model inference.**  
Cloud fits continued **M3 background**; strong inference should go **AGX (M1/M2)** — do not expect cloud to “get smarter by running longer”.

## 4. Suggested actions (not required tonight)

1. P0 AGX already up → use M1 to fill cloud’s missing inference.  
2. Open/fix `journal_structure` error (TC 0-score item).  
3. CEO clear a batch of `awaiting_ceo_review` to lift `TC_task_pipeline`.  
4. If public mobile is needed: open cloud security group **8765** (or SSH tunnel only).  
5. Real figure corpus: change sources or accept ~53; do not refill with synth figures.
