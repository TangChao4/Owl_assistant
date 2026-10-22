# Agent 使用指南（Host + AGX + 云 M3）

> 适用：本机 Ubuntu **任务台** + 局域网 **AGX** 推理 + **云端**后台督促（M3）。  
> 代码与日志线：`~/owl-agent-line` · Agent 运行时：`~/workers/lib/companion`

---

## 1. 你会得到什么

| 能力 | 说明 |
|------|------|
| **对话** | 浏览器 `:3000`，默认走 **AGX** 大模型（不依赖公网 LLM） |
| **Plan / 文书** | 角色切换后走 **AGX `deepseek-r1:14b`**（结构化计划） |
| **重推理转发** | `/forward agx` → **gpt-oss:20b**，带 TCP 回执 |
| **云端督促** | `/cloud …`、顶部 **云** 按钮 → SSH 看 TC/Alpha 循环（M3） |
| **文件** | 工作区浏览 host/AGX（Owl 需 NX SSH）；导出下载 |
| **秘书** | `/todo` `/remind`（NX 上线后可同步） |

四端角色详见：`devlogs/ROLE_SPLIT_OWL_AGX_CLOUD.md`

---

## 2. 一分钟启动（推荐）

```bash
bash ~/owl-agent-line/scripts/owl_agent_up.sh
```

- 打开 **http://127.0.0.1:8765/** 启动台（探测 AGX / Agent / 云 SSH）
- 点 **启动可用组件** 等价于：

```bash
bash ~/owl-agent-line/scripts/host_offline_agent.sh
```

仅看状态、不弹浏览器：

```bash
bash ~/owl-agent-line/scripts/owl_agent_up.sh --cli
```

---

## 3. 打开聊天界面

1. 读取本机令牌（勿提交 git、勿贴到公开处）：

   ```bash
   grep '^COMPANION_CHAT_TOKEN=' ~/workers/data/runtime/COMPANION.secrets.env
   ```

2. 浏览器访问（将 `TOKEN` 换成实际值）：

   ```text
   http://127.0.0.1:3000/?token=TOKEN
   ```

3. 局域网其它设备（若防火墙允许）：

   ```text
   http://<本机局域网IP>:3000/?token=TOKEN
   ```

**策略**：`COMPANION_LLM_POLICY=local` 时，对话**不会**走公网 API；推理在 **AGX Ollama**（默认 `192.168.90.3:11434`）。  
**外网客户访问 / 联网调模型**：[`COMPANION_CLOUD_HTTPS.md`](COMPANION_CLOUD_HTTPS.md)（云 **8443** + SSH 隧道 + Gateway Key）。

---

## 4. 界面说明

### 顶栏

| 控件 | 作用 |
|------|------|
| **Role** | `Chat · 科研同伴` / `Plan · 开发计划` / `Docs · 文书助手` |
| **自洽机** | 运维面板 · 本机 Agent 状态（快览，不刷聊天） |
| **记忆** | 近期会话摘要 |
| **文件** | 工作区 + 导出下载（**不会**再在聊天里重复贴导出列表） |
| **云** | Cloud M3 状态 / 督促摘要 |
| **全部展开/折叠** | 长消息折叠（类似 Cursor） |
| **模型** | 下拉框只显示 **当前能连上** 的 Ollama 模型（AGX + 本机）；切换角色会推荐默认项；选中的项会随每条消息发送 |
| **刷新模型** | 重新探测 endpoint（约 45s 内会用缓存） |

### 模型分工（当前推荐配置）

| 角色 | 模型（AGX Ollama） | 用途 |
|------|-------------------|------|
| **Chat** | `gpt-oss:20b` | 日常问答、长推理、代码讨论 |
| **Plan / Docs** | `deepseek-r1:14b` | 分节计划、推导型文书 |
| **本机兜底** | `qwen3:8b` / `14b`（本机 Ollama） | AGX 不可达时在顶栏改选 **Host · …**，不必改 secrets |

配置项：`~/workers/data/runtime/COMPANION.secrets.env`（示例见 `COMPANION.secrets.env.example`）。顶栏选择与 secrets 里的 `COMPANION_MODEL` / `ASSISTANT_MODEL` 对齐时，会作为各角色的默认下拉项。

---

## 5. 聊天命令（斜杠）

### 云端 M3

| 命令 | 作用 |
|------|------|
| `/cloud` | 帮助 |
| `/cloud status` | 循环 / 分数 / 研究计数 probe |
| `/cloud supervise` | 单次督促（可选） |
| `/cloud repair` | 修复 playbook + 督促 |
| `/cloud pipeline` | `STATUS_NOW.md` 摘要 |

亦可用口语：**监控**、**督促**、**修复**（bridge 就绪时路由到 cloud）。

详见：[`CLOUD_AGENT_M3.md`](CLOUD_AGENT_M3.md)

### 秘书与 Owl

| 命令 | 作用 |
|------|------|
| `/todo …` / `/todo list` | 待办清单（host；NX 后同步） |
| `/remind …` | 提醒 |
| `/owl` / `/owl health` | Orin NX 桥（需 `COMPANION_OWL_SSH`） |
| `/forward agx <问题>` | 重任务 → AGX 20B + **回执 JSONL** |

### 文件与工作区

| 命令 | 作用 |
|------|------|
| `/fs help` | 多端文件帮助 |
| `/fs list host …` / `agx` / `owl` | 列目录 |
| `/fs read …` | 读文件 |
| `/fs write host /path \| 内容` | 写入（需面板 **允许写入** 或 `确认写入 <grant_id>`） |
| `/write path \| 内容` | 导出到 sandbox，UI 可下载 |
| `/project name.zip` + 多段代码围栏 | 小项目 zip |
| `/files` | 列出导出 |

工作区端点：**host**（默认）· **agx**（SSH）· **owl**（NX 配置后）。

### 其它

| 命令 | 作用 |
|------|------|
| `/llm <prompt>` | 强制走 LLM 一轮 |
| `/kb search` / `/kb add` | 本地知识库（若启用） |
| `/research …` | 研究模式（依配置） |

### 联网检索（与对话 LLM 分离）

Agent **可以上网查资料**，但默认 **不会** 把整段对话交给公网 LLM；推理仍在 AGX/本机 Ollama。

| 方式 | 作用 |
|------|------|
| **口语** | 「查一下 …」「搜一下 …」「上网查 …」→ 网页检索 + 本地 KB + OpenAlex/arXiv |
| **`/web 关键词`** | 仅网页（Brave/Tavily/SearXNG 或 DuckDuckGo lite 兜底）+ 可选抓取前 3 条 |
| **`/web`** 或 **`/web status`** | 查看当前联网后端是否就绪 |
| **`/research 主题`** | UI 若走 `/api/research`：纯检索摘要；加 `--llm` 再让模型归纳 |
| **`/llm …`** | 在已有检索结果上让本地模型写要点 |

**配置**（`~/workers/data/runtime/COMPANION.secrets.env`，任选其一即可增强质量）：

```bash
COMPANION_WEB_SEARCH=1
COMPANION_WEB_SEARCH_FALLBACK=1   # 无 API key 时用 DuckDuckGo lite（默认开）
# BRAVE_SEARCH_API_KEY=...
# TAVILY_API_KEY=...
# SEARXNG_URL=http://127.0.0.1:8080
```

验收：`curl -s 'http://127.0.0.1:3000/api/web/status?token=TOKEN'` 应 `enabled: true`。

### 本机执行（需你确认）

在 **`COMPANION_HOST_EXEC=1`**（默认开）且路径在 **`COMPANION_HOST_EXEC_ROOTS`**（默认 `/home/ubuntu`）内时，Agent 可**代跑只读命令**（`find` / `ls` / `wc` / `du` 等），**不会**不经同意直接动你的机器。

| 步骤 | 示例 |
|------|------|
| 1. 描述任务 | 「统计 `/home/ubuntu/essays` 里有多少文件、占多大空间」 |
| 2. Agent 给出 **grant_id** 和拟执行命令 | 回复中含 `exec_…` |
| 3. 你同意 | **`确认执行 exec_xxxx`**（或先说「亲自执行」会再次提示 grant） |
| 4. 看结果 | 终端输出贴在聊天里 |

| 命令 | 作用 |
|------|------|
| `/exec status` | 本机执行策略与待授权数量 |
| `/run ls -la /home/ubuntu/essays` | 提交单条命令（同样需确认） |

改路径范围：secrets 里 `COMPANION_HOST_EXEC_ROOTS=/home/ubuntu:/other`。  
**写/删/改**类命令默认拒绝；确有需要设 `COMPANION_HOST_EXEC_ALLOW_MUTATING=1`（仍要确认）。

---

## 6. 运维面板（自洽机 · 云 · 记忆）

点击 **自洽机 / 云 / 记忆** 打开**同一模态面板**（分 Tab），避免在聊天里刷大段 STATUS。

- 数据来自 `/api/status_snap`（默认 **不** LLM 润色，毫秒级）
- 需要润色时（慢）：`/api/status_snap?polish=1`

---

## 7. 常见场景

### A. 日常科研对话

1. `owl_agent_up.sh` → 打开 `:3000`
2. Role 选 **Chat**
3. 直接中文提问；复杂推理会自动走 AGX 20B

### B. 写开发计划（Plan）

1. Role 选 **Plan · 开发计划**
2. 描述目标与约束；应出现 **Goal / Assumptions / Plan / Risks / Next**
3. 若过短会自动重试一轮（约 180s 客户端超时）

### C. 看云端 Alpha 是否在跑

1. 顶栏 **云** → 或聊天 `/cloud status`
2. 后台循环：`host_cloud_supervise_loop.sh`（Agent 启动时可自动带起，见 `HOST_OFFLINE_AGENT.md`）

### D. AGX 挂了，临时用本机小模型

```bash
AGX_OLLAMA_BASE=http://127.0.0.1:11434/v1 \
  bash ~/owl-agent-line/scripts/host_offline_agent.sh
```

（secrets 里模型改为 `qwen3:8b` 等。）

### E. 改代码后重启 Agent

```bash
bash ~/owl-agent-line/scripts/host_offline_agent.sh
```

---

## 8. 验收（可选）

```bash
bash ~/owl-agent-line/scripts/endpoint_smoke.sh
```

通过即：AGX tags、`:3000` healthz、M2 SSH、M3 cloud SSH 均 OK。

---

## 9. 故障排查

| 现象 | 处理 |
|------|------|
| 聊天 503 / safe_mode | 跑 `host_offline_agent.sh`；看 `/api/recovery/status` |
| 一直无回复 | `curl http://192.168.90.3:11434/api/tags`；查 AGX 电源与网线 |
| Plan 很慢 | 正常（R1/20B）；看浏览器是否 180s 超时 |
| **文件** 按钮以前刷屏 | 已改为模态工作区；刷新页面 |
| 云按钮空 | 配置 `COMPANION_CLOUD_*` 与 SSH 密钥，见 `CLOUD_AGENT_M3.md` |
| Owl 不可用 | 载板未到：设 `COMPANION_OWL_SSH` 后见 `OWL_NX_DEPLOY.md` |

---

## 10. 相关文档

| 文档 | 内容 |
|------|------|
| [`HOST_OFFLINE_AGENT.md`](HOST_OFFLINE_AGENT.md) | 启动、导出、Plan、FS 细节（英文运维向） |
| [`AGX_ENDPOINT.md`](AGX_ENDPOINT.md) | AGX IP、Ollama、双模型 |
| [`CLOUD_AGENT_M3.md`](CLOUD_AGENT_M3.md) | 云 SSH 桥 |
| [`OWL_NX_DEPLOY.md`](OWL_NX_DEPLOY.md) | NX 秘书部署 |
| [`AGX_OFFLINE_TRAIN.md`](AGX_OFFLINE_TRAIN.md) | AGX 上 QLoRA 训练（与聊天 Agent **分开**） |
| [`DEV_PHASE_PLAN.md`](DEV_PHASE_PLAN.md) | 阶段规划 |

---

## 11. 安全提醒

- **不要**将 `COMPANION.secrets.env`、SSH 私钥、token 提交 GitHub 或发给他人。
- 云 M3 仅 **督促/读状态**，不在云上跑对话大模型；强推理在 **AGX（M1）**。
- 多机写入文件前确认 **grant**，避免误改生产路径。
