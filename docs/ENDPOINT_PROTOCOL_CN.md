# 四端统一沟通协议（TCP：Task · Capability · Progress）

> 版本：2026-10-21 · 版权：唐朝 (Tangchao)  
> 目的：本机 / AGX / 云端 / 猫头鹰之间**加速、重点、无歧义**沟通。  
> 协作模式：M1 本机↔AGX · M2 AGX 单干 · M3 云端参与（见 `COLLAB_MODES_CN.md`）

---

## 1. 端点注册表

| 端点 ID | 角色 | 地址 | 主端口 / API |
|---------|------|------|----------------|
| `owl` | 秘书交互 | Orin NX（待定 IP） | Ollama 小模型；秘书 Agent |
| `host` | 第二任务台 / 编排 | 本机 Ubuntu | Agent :3000（规划）；workers |
| `agx` | 强推理 | `192.168.90.3` | **Ollama `http://192.168.90.3:11434`** · 模型 `gpt-oss:20b` |
| `cloud` | TC/Alpha CPU 后台 | `39.96.82.193` | SSH；mobile 规划 `:8765`（公网未通）；**无** `:8788` LLM |

SSH 别名（本机）：`agx` → 192.168.90.3 · 云：`root@39.96.82.193`（密钥）

---

## 2. 消息信封（所有重点沟通必须带）

口头或工单/日志里用同一骨架：

```text
[TCP v1]
from: host|agx|cloud|owl|user
to:   host|agx|cloud|owl|broadcast
mode: M1|M2|M3|M1+M3|owl
pri:  P0|P1|P2
kind: TASK|STATUS|CAPA|RESULT|BLOCKER|ASK
id:   YYYYMMDD-短横线编号
body: ...
```

| 字段 | 含义 |
|------|------|
| `pri P0` | 阻塞今晚目标，必须回 |
| `pri P1` | 影响能力/进度，当日回 |
| `pri P2` | 可延后 |
| `kind TASK` | 下达任务 |
| `kind STATUS` | 进度心跳 |
| `kind CAPA` | 能力考/分数 |
| `kind RESULT` | 产出路径或摘要 |
| `kind BLOCKER` | 卡点（含退让） |
| `kind ASK` | 只需是/否或单值 |

**示例（本机请 AGX 推理）：**
```text
[TCP v1] from=host to=agx mode=M1 pri=P0 kind=TASK id=20261021-gen1
body: model=gpt-oss:20b; prompt=...; num_predict=256; return=content
```

**示例（查云端）：**
```text
[TCP v1] from=host to=cloud mode=M3 pri=P1 kind=STATUS id=20261021-cloud1
body: want=probe+exam_scores
```

---

## 3. 标准能力/进度字典（重点只谈这些键）

### 3.1 云端 `STATUS` 必答键
```json
{
  "endpoint": "cloud",
  "alive": {"curriculum": true, "research": true, "real_style": true, "tc_auto": true},
  "passed": 71,
  "held_out_fails": [],
  "inject_path_live": false,
  "research_unique": 28464,
  "research_zeros": 34,
  "style_n": 2643,
  "llm8788": false,
  "mobile8765": "listen_local",
  "paper_top": "边端轴承… awaiting_ceo_review"
}
```
采集命令：`python scripts/companion/cloud_status_probe.py`

### 3.2 云端 `CAPA` 必答键（能力考）
只汇报短板与满分项，避免贴全文：
```json
{
  "endpoint": "cloud",
  "scores_weak": {"A_live_exam": 0, "A_figure_real_style": 52.9, "TC_journal_structure": 0, "TC_task_pipeline": 11.1},
  "scores_strong": ["A_curriculum", "TC_v6_18pack", "anti_leak"],
  "verdict": "healthy_process_stalled_growth"
}
```
采集：`PYTHONPATH=/opt/workers python scripts/companion/tc_alpha_capability_exam.py`

### 3.3 AGX `STATUS` / `RESULT`
```json
{
  "endpoint": "agx",
  "ollama": "http://192.168.90.3:11434",
  "models": ["gpt-oss:20b"],
  "listen": "0.0.0.0:11434",
  "last_result": {"content": "…", "eval_count": 56}
}
```

### 3.4 本机 `TASK` 路由词（加速决策）
| 用户意图含 | 路由 |
|------------|------|
| 秘书/提醒/催办 | → `owl`（无则 `host`） |
| 难推理/长文/深代码 | → `agx`（M1 或 M2） |
| 投稿/课程/企微/文献网 | → `cloud`（M3） |
| 查进度 | → 对应端 `STATUS` |

---

## 4. 一键体检命令（本机执行）

```bash
# AGX
curl -s http://192.168.90.3:11434/api/tags | head -c 200; echo

# 云端 probe（SSH）
ssh -i ~/.ssh/workers_cloud_ed25519 root@39.96.82.193 \
  'cd /opt/workers && .venv/bin/python scripts/companion/cloud_status_probe.py'

# 云端能力考（较慢，~2min）
ssh -i ~/.ssh/workers_cloud_ed25519 root@39.96.82.193 \
  'cd /opt/workers && PYTHONPATH=/opt/workers .venv/bin/python scripts/companion/tc_alpha_capability_exam.py' \
  | tail -20
```

---

## 5. 沟通加速约定

1. **先报信封**（from/to/mode/pri/kind/id），再讲细节。  
2. **云端不谈「又跑了多少 cycle」当成绩**；只谈 `held_out`、短板分、任务状态迁移。  
3. **AGX 不谈安装故事**；只谈 model / latency / OOM / content。  
4. **BLOCKER 必须带退让**（例：20B OOM → 14B；云端无 LLM → 转 agx）。  
5. 日志：`devlogs/DEVLOG_*.md` 写同一 `id` 与 `mode`。  

## 6. 当前基线（2026-10-21 考验后）

| 端 | 状态一句 |
|----|----------|
| `agx` | 20B 局域网可用 |
| `cloud` | 环活、防泄过、V6 绿；增长停滞；无本地 LLM |
| `host` | 编排位；Agent 接线为下一优先级 |
| `owl` | 模型在 U 盘；NX 部署未完 |
