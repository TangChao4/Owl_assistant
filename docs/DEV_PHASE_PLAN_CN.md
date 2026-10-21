# 开发阶段与任务计划（gpt-oss:20b 已就绪）

> 更新日期：2026-10-21  
> 前提：AGX 上 `ollama list` 已见 `gpt-oss:20b`（约 13GB）  
> 四端定责见：`devlogs/三机职责分工_猫头鹰_AGX_云端.md`

---

## 总目标

| 端 | 目标状态 |
|----|----------|
| **猫头鹰 (NX)** | 秘书交互可用（小模型） |
| **本机** | 第二任务台 + Agent 入口；能把重活打到 AGX |
| **AGX** | `gpt-oss:20b` 对局域网提供 API |
| **云端** | 继续 CPU 后台；本机可查进度 |

---

## 阶段 0 — 联通验收（今晚 / 0.5 天）

**目的**：确认 AGX 20B 能被本机调用，记下 IP。

| ID | 任务 | 谁做 | 验收 |
|----|------|------|------|
| P0-1 | AGX 上确认服务监听 `0.0.0.0:11434` | AGX | `ss -lntp \| grep 11434` 或 `OLLAMA_HOST=0.0.0.0:11434` |
| P0-2 | AGX 本机试跑 | AGX | `ollama run gpt-oss:20b "ping"` 有回复 |
| P0-3 | 记下 AGX 新 IP，写入本机 SSH / 文档 | 本机 | `devlogs` 记一笔；`ssh` 可通 |
| P0-4 | 本机 `curl http://AGX_IP:11434/api/tags` | 本机 | JSON 含 `gpt-oss:20b` |
| P0-5 | 本机发一条生成请求 | 本机 | `/api/generate` 或 OpenAI 兼容接口通 |

**本机快速测：**
```bash
export AGX=http://<AGX_IP>:11434
curl -s "$AGX/api/tags" | head
curl -s "$AGX/api/generate" -d '{"model":"gpt-oss:20b","prompt":"用一句话介绍你自己","stream":false}'
```

---

## 阶段 1 — 本机 Agent 最小闭环（1–2 天）

**目的**：不靠猫头鹰也能在本机发布任务，重推理走 AGX。

| ID | 任务 | 路径/入口 | 验收 |
|----|------|-----------|------|
| P1-1 | 起轻量 Agent（优先无 Docker） | `workers` → `python -m lib.companion.webapp` | 浏览器打开 :3000 |
| P1-2 | 或修 Docker 后起 Open WebUI | `deploy/companion/up.sh` | WebUI 可登录 |
| P1-3 | 配置默认「强模型」指向 AGX `gpt-oss:20b` | companion / WebUI 连接设置 | 聊天走 20B |
| P1-4 | 本机常驻 7B（可选，省 AGX） | `~/models/gguf/qwen25-7b` | 轻问本地，重问 AGX |
| P1-5 | 任务清单 A–F 各做一条样例 | 见 `本机任务清单_速查.md` | 有回执 |

**路由规则（写进 Agent 系统提示）：**
- 秘书/短答/催办 → 本地 7B 或以后猫头鹰  
- 长推理/难代码/深分析 → **AGX `gpt-oss:20b`**  
- 科研投稿长跑 → `workers` / 云端  

---

## 阶段 2 — 猫头鹰秘书上 NX（1–2 天，可与阶段 1 并行）

**目的**：第一交互入口落地。

| ID | 任务 | 说明 | 验收 |
|----|------|------|------|
| P2-1 | U盘 `ollama_store` 整包拷到 NX **ext4** | 勿在 exFAT 上跑服务 | `ollama list` 见 5 模型 |
| P2-2 | NX 起 Ollama，主用 `qwen3:4b` | | 本机对话通 |
| P2-3 | 秘书最小能力：提醒、待办、简报模板 | `05_Agent_System` 开始填 | 3 个场景演示 |
| P2-4 | 重任务转发：猫头鹰 → 本机 Agent 或直调 AGX | | 转发有回执 |
| P2-5 | （可选）语音/表情后置 | 见 SPEECH 指南 | 不阻塞主路径 |

---

## 阶段 3 — 三端联调（1 天）

| ID | 任务 | 验收 |
|----|------|------|
| P3-1 | 用户→猫头鹰→（轻）本地完成 | 秘书场景 OK |
| P3-2 | 用户→猫头鹰→AGX 20B | 难问题 OK |
| P3-3 | 用户→本机任务台→AGX / workers | 不令猫头鹰也能下任务 |
| P3-4 | 本机查云端进度 | `cloud_status_probe` 有结果 |
| P3-5 | 写 `DEVLOG` + 关闭相关 ISSUE（IP、20B） | INDEX 更新 |

---

## 阶段 4 — 开源与工程化（0.5–1 天）

| ID | 任务 | 验收 |
|----|------|------|
| P4-1 | `gh auth login` + 公开推送 `owl-agent-line`（MIT / 唐朝） | GitHub 可见 |
| P4-2 | README 补充：架构图、如何接 AGX、如何起 Agent | 外人能跟做 |
| P4-3 | （可选）workers `git init` 后另仓或子模块策略 | 大权重仍不进 Git |

---

## 阶段 5 — 增强（排期后置）

- 猫头鹰：ASR/TTS、表情硬件  
- AGX：14B 备用、R1 蒸馏对照；**禁止三模型同时常驻**  
- 云端：打破课程空转 / 图风增量（按缺陷表，不堆假指标）  
- 本机：继续清盘（回收站 T3 等，按你勾选）  

---

## 本周推荐顺序（20B 已好）

```
P0 联通 AGX API
 → P1-1/P1-3 本机 Agent + 指向 20B   （你马上能用）
 → P2 猫头鹰 NX（可并行）
 → P3 联调
 → P4 推 GitHub
```

## 每次开发先打开这些文件

| 场景 | 文件 |
|------|------|
| 定责 | `devlogs/三机职责分工_猫头鹰_AGX_云端.md` |
| 本机任务 | `devlogs/本机任务清单_速查.md` |
| workers 找代码 | `docs/WORKERS_TASK_TREE_CN.md` |
| 本计划 | `docs/DEV_PHASE_PLAN_CN.md` |
| 日志 | `devlogs/DEVLOG_模板.md` → 当日 DEVLOG |

## 风险

- AGX 与本机防火墙 / 不在同一网段 → P0 失败  
- 20B + 长上下文 OOM → 降 ctx 或退 14B  
- Docker 未起 → 先走轻量 webapp（P1-1）  
- 猫头鹰与 AGX 共用一个 `OLLAMA_MODELS` → 禁止，目录分离  
