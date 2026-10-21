# workers 清理候选项（待你勾选）

盘点时间：2026-10-21 · 总计约 **79G**  
**尚未删除任何文件。** 回复如：`删 A1 A2 B3` 或 `保留全部 adapters 只删 C组`。

| 组 | 路径 / 说明 | 约大小 | 风险 | 建议 |
|----|-------------|--------|------|------|
| **A1** | `data/tc_alpha_research_prep_v2/artifacts/` 中 **旧 adapter**（除 v12、v13） | ~35–40G | 中：旧实验权重 | **优先删**（保留 `…_v12_…` + `…_v13_…`） |
| **A2** | 同上目录里大量 `sft_shortfall_*` 小目录 | <10M | 低 | 可删 |
| **B1** | `data/backups/` 定时备份（约 12 份×228M） | ~2.7G | 低：可只留最近 1–2 份 | 建议只留最新 2 份 |
| **C1** | `data/runtime/alpha_figure_corpus/`（合成图已饱和停刷） | ~1.9G | 低–中 | 可删或外移 U 盘 |
| **D1** | 根目录旧 zip：`CEP_*.zip` `Mechatronics_*.zip` `ISA_Q1_*.zip` `DELIVER_ISA_v11*.zip` `DELIVER_ISA_v12_HIL*.zip` `TC_ALPHA_*.zip` | ~15M | 低（若 DELIVER 目录已有） | 可删 |
| **D2** | 根目录旧 docx 方案稿（Mechatronics_v7/v8、consultant、V10 等） | ~1M | 低 | 可归档到 `archives/` 或删 |
| **E1** | `DELIVER_ISA_v12_FULL_PACK_*` `DELIVER_CEP_Q1_v15_*` 目录 | ~48M | 低 | 旧交付包，可外移 |
| **E2** | `DELIVER_投稿包/` 里重复 Measurement/deAI 多版本 zip | ~40M+ | 低 | 只留 `*_LATEST.zip` |
| **F1** | `__pycache__` / `.pyc`（约 2860 目录 / 2万+ 文件） | 通常几百 MB 级 | 极低 | 可清（可再生） |
| **F2** | `.pytest_cache/` | 小 | 极低 | 可清 |
| **G1** | `dataset_BearingDataCenter/`（rar 数据集） | **2.4G** | 高：实验可能还要用 | **默认保留**，除非已另有备份 |
| **G2** | `data/tasks/` 下旧空壳/小任务（非当前轴承/边端） | 不定 | 中 | 逐个确认 |
| **H1** | `.venv/` | **6.9G** | 高：删了要重装依赖 | **不要删**（除非准备重建环境） |
| **H2** | `third_party/alpha_integrations/` | 1.1G | 中 | 确认不用再删 |
| **H3** | `check_for_sun/` `need_modify/` `ABCDE/` | ~130M | 低–中 | 像临时区，可外移 |

## 不建议动

- `main.py` `lib/` `scripts/` `docs/` `config/` `deploy/`  
- `data/tasks/轴承故障_SCI二区/` `边端轴承诊断_Electronics_SCI二区/`（当前主任务）  
- `.env`（密钥；也不要提交 Git）  
- 当前指针 adapter：`research_adapter_shortfall_v12_*`（云端曾用）+ 建议同留 **v13**
