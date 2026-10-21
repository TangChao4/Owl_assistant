# workers 开发任务树（找文件用）

> 根目录：`/home/ubuntu/workers`（约 79G）  
> 原则：**改代码看 lib/scripts/main；跑任务看 data/tasks；别在 DELIVER 旧包里改源码。**

```
workers/
├── main.py, ceo_qt.py          ← 入口：投稿流水线 / CEO 台
├── lib/                        ← 核心库（companion / sci_* / anti_freeze…）
├── scripts/companion/          ← 云端环、本机 Agent 辅助脚本
├── scripts/gpu/                ← 本机 GPU / adapter 训练
├── tools/                      ← 运维小工具
├── deploy/                     ← 部署（companion Docker、cloud env）
├── config/                     ← 计划/策略 JSON
├── docs/                       ← 说明与定责文档
├── tests/                      ← 测试
├── data/
│   ├── tasks/<任务名>/         ← 当前论文任务工作区（改稿、实验产物）
│   ├── runtime/                ← 运行时状态（可部分清理）
│   ├── logs/                   ← 日志
│   ├── tc_alpha_research_prep_v2/  ← Alpha 备课/语料（最大头）
│   ├── datasets/               ← 数据集缓存
│   └── backups/                ← 自动备份
├── DELIVER_* / DELIVER_投稿包/ ← 已打好的交付包（只读归档）
├── .venv/                      ← Python 环境（勿当源码搜）
└── third_party/, dataset_*     ← 第三方与大数据集
```

## 按任务找哪里

| 你要做的事 | 先看这些路径 |
|------------|----------------|
| A 秘书/Agent 聊天 | `lib/companion/` · `deploy/companion/` · `docs/COMPANION_*.md` |
| B 调 AGX / 本地 LLM | `docs/LOCAL_FIRST_5060_POLICY.json` · companion secrets（勿提交） |
| C 科研投稿续跑 | `main.py` · `data/tasks/<当前任务>/` · `docs/JOURNAL_LOCK.json` |
| D 查云端/进度 | `scripts/companion/cloud_status_probe.py` · `data/runtime/STATUS_NOW.md` · `data/runtime/companion_services/` |
| E 图风 / 刊架 | `lib/sci_figure_style/` · `lib/sci_journal_structure/` |
| F 防卡死 | `lib/anti_freeze_cursor/` · `data/anti_freeze/` · `python main.py anti-freeze` |
| G Jetson 边端实验 | `lib/jetson_remote/` · `kits/jetson_kit_bearing/` |
| H 写开发日志（本线） | `~/owl-agent-line/devlogs/`（不要在 workers 根目录乱堆） |

## 不要当「源码」搜索的目录

`.venv/` · `__pycache__/` · `data/backups/` · `DELIVER_*` 旧 zip · `third_party/` 大库 · `dataset_*`
