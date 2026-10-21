# owl-agent-line

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

猫头鹰助手 · 本机第二任务台 · AGX 强推理 · 云端 TC/Alpha 的**运维与开发日志线**。

> **版权**：唐朝 (Tangchao) · **许可证**：[MIT License](LICENSE)  
> **不包含**模型权重（GGUF / Ollama blobs）。权重仍在本机盘、U 盘、AGX 上。  
> 第三方模型权重各自遵循其原许可证（Qwen / Ollama 模型卡等），不因本仓 MIT 而改变。

## 当前状态（2026-10-21）

| 端 | 状态 | 要点 |
|----|------|------|
| **猫头鹰** `owl` | 待部署 | U 盘 5 模型包完整；待拷 NX ext4 |
| **本机** `host` | **离线 Agent 已起** | `:3000` webapp · `policy=local` · → AGX `gpt-oss:20b` |
| **AGX** `agx` | **P0 已过** | `192.168.90.3:11434` · `gpt-oss:20b` 局域网可调 |
| **云端** `cloud` | 环活、增长停滞 | 亲自考验：防泄过 / V6 绿；无 `:8788` LLM |

协作模式：**M1** 本机↔AGX · **M2** AGX 单干 · **M3** 云端参与。  
统一沟通：**TCP v1** 信封（见协议文档）。

## 四端入口

| 端 | 职责 |
|----|------|
| 猫头鹰 (Orin NX) | 第一交互：人机 + 秘书 |
| 本机 (`host`) | 不令猫头鹰时的**第二任务发布台** + Agent/TC |
| AGX 32G | 强推理（`gpt-oss:20b`） |
| 云端 | TC/Alpha CPU 后台（企微/课程/检索） |

详情：`devlogs/三机职责分工_猫头鹰_AGX_云端.md` · 本机速查：`devlogs/本机任务清单_速查.md`

## 关键文档

| 文档 | 用途 |
|------|------|
| [`docs/ENDPOINT_PROTOCOL_CN.md`](docs/ENDPOINT_PROTOCOL_CN.md) | **四端统一沟通协议**（TCP 信封 + 端点字典） |
| [`docs/COLLAB_MODES_CN.md`](docs/COLLAB_MODES_CN.md) | M1 / M2 / M3 协作模式 |
| [`docs/DEV_PHASE_PLAN_CN.md`](docs/DEV_PHASE_PLAN_CN.md) | 阶段计划 P0–P4 |
| [`docs/CLOUD_EXAM_20261021.md`](docs/CLOUD_EXAM_20261021.md) | 云端亲自考验报告 |
| [`docs/AGX_ENDPOINT_CN.md`](docs/AGX_ENDPOINT_CN.md) | AGX 端点与联通 |
| [`docs/WORKERS_TASK_TREE_CN.md`](docs/WORKERS_TASK_TREE_CN.md) | **任务工作树**（找文件） |
| [`devlogs/INDEX.md`](devlogs/INDEX.md) | 开发日志与 ISSUE 索引 |

## 开发日志（强制）

**实质性改动或重点决策完成后，必须自动更新开发日志**，不要等用户再提醒：

1. 追加当日 `devlogs/DEVLOG_YYYYMMDD.md`（无则按模板新建）
2. 同步一行到 `devlogs/INDEX.md`
3. 涉及任务入口/阶段/模式时，顺带改 README「当前状态」或工作树对应行
4. 日志里尽量带 `mode=M1|M2|M3` 与 TCP `kind`（STATUS / CAPA / RESULT / BLOCKER）

模板：`devlogs/DEVLOG_模板.md`

## 阶段进度速览

| 阶段 | 内容 | 状态 |
|------|------|------|
| P0 | AGX 联通 + 20B 验收 | **完成** |
| P1 | 本机离线 Agent → AGX | **P1-1/2 完成**；见 `docs/HOST_OFFLINE_AGENT_CN.md` |
| P2 | 猫头鹰 NX 部署 | 待做 |
| P3 | 三端联调 | 待做 |
| P4 | GitHub → `TangChao4/Owl_assistant` | **已首推** `main`；日常用 `./scripts/push_to_github.sh` |

## 接上 GitHub（本机 → Owl_assistant）

远端已建好：**https://github.com/TangChao4/Owl_assistant**（`main` · Public · MIT）

**本机 IP 会变也不影响推送**——鉴权是 `gh` 账号登录态，不绑 IP。局域网 AGX/猫头鹰 IP 变了另改文档即可。

### 1. 登录一次（浏览器）

```bash
export PATH="$HOME/.local/bin:$PATH"   # 本机 gh 装在这里
gh auth login -h github.com -p https -w
```

### 2. 日常一键推送（覆盖远端 main）

```bash
cd ~/owl-agent-line
./scripts/push_to_github.sh "docs: 更新开发日志"
```

详情：`docs/GITHUB_CONNECT_CN.md`

### 3. 与 U 盘日志同步（可选）

U 盘：`/media/ubuntu/THIS/Owl_Secretary/09_DevLogs/` · 本仓库：`devlogs/`

```bash
cp -a /media/ubuntu/THIS/Owl_Secretary/09_DevLogs/*.md ~/owl-agent-line/devlogs/
cp -a ~/owl-agent-line/devlogs/*.md /media/ubuntu/THIS/Owl_Secretary/09_DevLogs/
```

## 目录

```
docs/       定责、协议、阶段计划、考验报告、工作树
devlogs/    开发日志与 ISSUE 索引（实质改动必更新）
issues/     问题单（可从模板复制）
scripts/    下载/部署辅助脚本（不含权重）
.cursor/    项目规则（含 DEVLOG 自动更新）
```

## 安全

- 勿提交 `*.secrets.env`、API Key、云主机私钥、`.local/agx.env`。
- `.gitignore` 已排除模型与密钥；推送前务必 `git status` 检查。
