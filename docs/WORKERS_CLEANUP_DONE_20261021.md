# workers Cleanup Execution Record 2026-10-21

Executed per user checklist. Paper-related items offloaded → `/home/ubuntu/essays`; rest deleted.

## Done
| Item | Action |
|------|--------|
| A1 | Deleted old `research_adapter_*`; kept **v12** + **v13** |
| A2 | Deleted all `sft_shortfall_*` |
| B1 | `data/backups/` kept only `20261021-194531`, `20261020-172011` |
| C1 | Deleted `data/runtime/alpha_figure_corpus/` (not paper drafts; deleted outright) |
| D1 | Deleted root old zips |
| D2 | Plan docx → `~/essays/docx_plans/` |
| E1 | `DELIVER_ISA_v12_*`, `DELIVER_CEP_*` → `~/essays/DELIVER_archives/` |
| E2 | Deleted duplicate Measurement zips; kept `*_deAI_LATEST.zip` |
| F1 | Cleared `__pycache__` / `.pyc` |
| F2 | Deleted `.pytest_cache` |

## Kept untouched
- G1 `dataset_BearingDataCenter`
- H1 `.venv`
- H2 `third_party/alpha_integrations` (originally “confirm then delete”; not touched this round)
- Current main tasks under `data/tasks/` (bearing-fault and edge-bearing dirs; Chinese dirnames on disk)

## Size
- workers before cleanup ≈ **79G**
- workers after cleanup ≈ **38G**
- Offloaded essays: see `~/essays/`
