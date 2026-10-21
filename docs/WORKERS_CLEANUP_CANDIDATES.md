# workers Cleanup Candidates (awaiting your checklist)

Inventory time: 2026-10-21 · total ~ **79G**  
**No files deleted yet.** Reply e.g.: `delete A1 A2 B3` or `keep all adapters; delete group C only`.

| Group | Path / notes | Approx size | Risk | Suggestion |
|-------|--------------|-------------|------|------------|
| **A1** | `data/tc_alpha_research_prep_v2/checkpoints/` **old adapters** (except v12, v13) | ~35–40G | med: old experiment weights | **delete first** (keep `…_v12_…` + `…_v13_…`) |
| **A2** | many `sft_shortfall_*` small dirs in same tree | <10M | low | deletable |
| **B1** | `data/backups/` timed backups (~12 × 228M) | ~2.7G | low: keep newest 1–2 | keep latest 2 |
| **C1** | `data/runtime/alpha_figure_corpus/` (synth figures saturated, stopped refresh) | ~1.9G | low–med | delete or offload USB |
| **D1** | root old zips: `CEP_*.zip` `Mechatronics_*.zip` `ISA_Q1_*.zip` `DELIVER_ISA_v11*.zip` `DELIVER_ISA_v12_HIL*.zip` `TC_ALPHA_*.zip` | ~15M | low (if DELIVER dirs exist) | deletable |
| **D2** | root old docx plans (Mechatronics_v7/v8, consultant, V10, etc.) | ~1M | low | archive to `archives/` or delete |
| **E1** | `DELIVER_ISA_v12_FULL_PACK_*` `DELIVER_CEP_Q1_v15_*` dirs | ~48M | low | old deliver packs; offload OK |
| **E2** | `DELIVER_submission_pack/` duplicate Measurement/deAI multi-version zips (Chinese dirname on disk) | ~40M+ | low | keep `*_LATEST.zip` only |
| **F1** | `__pycache__` / `.pyc` (~2860 dirs / 20k+ files) | usually hundreds of MB | very low | clearable (regenerable) |
| **F2** | `.pytest_cache/` | small | very low | clearable |
| **G1** | `dataset_BearingDataCenter/` (rar dataset) | **2.4G** | high: experiments may need it | **keep by default** unless backed up elsewhere |
| **G2** | `data/tasks/` old shells/small tasks (not current bearing/edge) | varies | med | confirm one by one |
| **H1** | `.venv/` | **6.9G** | high: must reinstall deps if deleted | **do not delete** (unless rebuilding env) |
| **H2** | `third_party/alpha_integrations/` | 1.1G | med | delete only after confirming unused |
| **H3** | `check_for_sun/` `need_modify/` `ABCDE/` | ~130M | low–med | look like temp; offload OK |

## Prefer leave alone

- `main.py` `lib/` `scripts/` `docs/` `config/` `deploy/`  
- `data/tasks/` current bearing-fault SCI Q2 and edge-bearing Electronics SCI Q2 task dirs (Chinese dirnames on disk)  
- `.env` (secrets; also never commit to Git)  
- current pointer adapters: `research_adapter_shortfall_v12_*` (used on cloud) + prefer also keep **v13**
