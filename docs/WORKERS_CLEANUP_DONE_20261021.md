# workers 清理执行记录 2026-10-21

按用户勾选执行。论文相关外移 → `/home/ubuntu/essays`；其余删除。

## 已执行
| 项 | 动作 |
|----|------|
| A1 | 删除旧 `research_adapter_*`，保留 **v12** + **v13** |
| A2 | 删除全部 `sft_shortfall_*` |
| B1 | `data/backups/` 仅留 `20261021-194531`、`20261020-172011` |
| C1 | 删除 `data/runtime/alpha_figure_corpus/`（非论文稿，直接删） |
| D1 | 删除根目录旧 zip |
| D2 | 方案 docx → `~/essays/docx_plans/` |
| E1 | `DELIVER_ISA_v12_*`、`DELIVER_CEP_*` → `~/essays/DELIVER_archives/` |
| E2 | Measurement 重复 zip 删除，保留 `*_deAI_LATEST.zip` |
| F1 | 清空 `__pycache__` / `.pyc` |
| F2 | 删除 `.pytest_cache` |

## 保留未动
- G1 `dataset_BearingDataCenter`
- H1 `.venv`
- H2 `third_party/alpha_integrations`（原建议确认后再删，本次未动）
- 当前主任务 `data/tasks/轴承故障_*`、`边端轴承诊断_*`

## 体积
- 清理前 workers ≈ **79G**
- 清理后 workers ≈ **38G**
- 外移 essays：见 `~/essays/`
