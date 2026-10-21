# 任务工作树（找文件用）

> 更新日期：2026-10-21  
> 两棵树：本仓 `~/owl-agent-line`（协议/日志线）+ `~/workers`（科研/Agent 源码）。  
> 原则：**改代码看 lib/scripts/main；跑任务看 data/tasks；日志与协议看 owl-agent-line。**

---

## A. owl-agent-line（本仓）

```
owl-agent-line/
├── README.md                 ← 四端状态 + 关键文档入口
├── LICENSE                   ← MIT · 版权 唐朝
├── docs/
│   ├── ENDPOINT_PROTOCOL_CN.md   ← TCP v1 统一沟通协议 ★
│   ├── COLLAB_MODES_CN.md        ← M1 / M2 / M3
│   ├── DEV_PHASE_PLAN_CN.md      ← P0–P4 阶段
│   ├── CLOUD_EXAM_20261021.md    ← 云端亲自考验
│   ├── AGX_ENDPOINT_CN.md        ← AGX :11434 / 20B
│   ├── OWL_AGX_CLOUD_ROLE_SPLIT_CN.md
│   ├── WORKERS_TASK_TREE_CN.md   ← 本文件
│   ├── WORKERS_CLEANUP_*.md      ← workers 清理候选/已做
│   ├── HOME_CLEANUP_CANDIDATES_CN.md
│   └── GITHUB_CONNECT_CN.md
├── devlogs/
│   ├── INDEX.md              ← 日志与 ISSUE 总表（必同步）
│   ├── DEVLOG_YYYYMMDD.md    ← 当日开发日志（实质改动必写）
│   ├── DEVLOG_模板.md
│   ├── 三机职责分工_猫头鹰_AGX_云端.md
│   └── 本机任务清单_速查.md  ← host A–F + 模式
├── issues/                   ← ISSUE 单
├── scripts/
│   ├── push_to_github.sh     ← 一键推 Owl_assistant（不绑本机 IP）★
│   ├── host_offline_agent.sh ← 本机离线 Agent → AGX 20B ★
│   ├── owl_pack / …
└── .cursor/rules/            ← 项目规则（含 DEVLOG 自动更新）
```

| 你要做的事 | 先看 |
|------------|------|
| 四端怎么说话 | `docs/ENDPOINT_PROTOCOL_CN.md` |
| 选 M1/M2/M3 | `docs/COLLAB_MODES_CN.md` · `devlogs/本机任务清单_速查.md` |
| 今晚阶段 | `docs/DEV_PHASE_PLAN_CN.md` |
| **本机离线 Agent** | `docs/HOST_OFFLINE_AGENT_CN.md` · `scripts/host_offline_agent.sh` |
| 云端能力 | `docs/CLOUD_EXAM_20261021.md` |
| AGX 调用 | `docs/AGX_ENDPOINT_CN.md` · `http://192.168.90.3:11434` |
| 推 GitHub | `scripts/push_to_github.sh` · `docs/GITHUB_CONNECT_CN.md` |
| 写/查日志 | `devlogs/INDEX.md` · 当日 `DEVLOG_*.md` |

---

## B. workers（科研 / Agent 源码）

> 根目录：`/home/ubuntu/workers`（清理后约 38G 量级，以本机为准）

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
│   ├── tasks/<任务名>/         ← 当前论文任务工作区
│   ├── runtime/                ← 运行时状态
│   ├── logs/                   ← 日志
│   ├── tc_alpha_research_prep_v2/  ← Alpha 备课/语料
│   ├── datasets/               ← 数据集缓存
│   └── backups/                ← 自动备份
├── DELIVER_* / DELIVER_投稿包/ ← 交付包（只读归档）
├── .venv/                      ← Python 环境（勿当源码搜）
└── third_party/, dataset_*     ← 第三方与大数据集
```

| 你要做的事 | 先看这些路径 |
|------------|----------------|
| A 秘书/Agent 聊天 | `lib/companion/` · `deploy/companion/` · `docs/COMPANION_*.md` |
| B 调 AGX / 本地 LLM | `docs/LOCAL_FIRST_5060_POLICY.json` · companion secrets（勿提交） |
| C 科研投稿续跑 | `main.py` · `data/tasks/<当前任务>/` · `docs/JOURNAL_LOCK.json` |
| D 查云端/进度 | `scripts/companion/cloud_status_probe.py` · `data/runtime/STATUS_NOW.md` |
| E 图风 / 刊架 | `lib/sci_figure_style/` · `lib/sci_journal_structure/` |
| F 防卡死 | `lib/anti_freeze_cursor/` · `python main.py anti-freeze` |
| G Jetson 边端 | `lib/jetson_remote/` · `kits/jetson_kit_bearing/` |
| H 写开发日志 | **`~/owl-agent-line/devlogs/`**（不要在 workers 根目录乱堆） |

### 不要当「源码」搜索的目录

`.venv/` · `__pycache__/` · `data/backups/` · `DELIVER_*` 旧 zip · `third_party/` 大库 · `dataset_*`

---

## C. 端点速查（与协议一致）

| ID | 地址 | 主 API |
|----|------|--------|
| `owl` | Orin NX（待定） | 小模型 Ollama |
| `host` | 本机 Ubuntu | Agent（规划 :3000）· workers |
| `agx` | `192.168.90.3` | `http://192.168.90.3:11434` · `gpt-oss:20b` |
| `cloud` | `39.96.82.193` | SSH；无公网 LLM |
