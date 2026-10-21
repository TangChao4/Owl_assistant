# 本机离线 Agent（P1）

> 更新日期：2026-10-21 · mode=**M1**  
> 目标：不依赖公网 LLM；本机 UI + 局域网 AGX `gpt-oss:20b`（AGX 不可达时可改指本机 Ollama）。

## 现状

| 项 | 值 |
|----|-----|
| UI | companion webapp `http://<本机>:3000/?token=…` |
| 策略 | `COMPANION_LLM_POLICY=local`（**永不走云**） |
| 推理 | `COMPANION_LOCAL_LLM_BASE=http://192.168.90.3:11434/v1` |
| 模型 | `gpt-oss:20b` |
| 本机兜底 Ollama | `127.0.0.1:11434` · `qwen3:8b` / `qwen3:14b` |

Token 在 `~/workers/data/runtime/COMPANION.secrets.env` 的 `COMPANION_CHAT_TOKEN`（勿提交、勿发群）。

## 一键启停

```bash
# 启动 / 重启
bash ~/owl-agent-line/scripts/host_offline_agent.sh

# AGX IP 变了：
AGX_OLLAMA_BASE=http://<新IP>:11434/v1 bash ~/owl-agent-line/scripts/host_offline_agent.sh

# 改用本机模型（完全不依赖 AGX）：
AGX_OLLAMA_BASE=http://127.0.0.1:11434/v1 AGX_MODEL=qwen3:8b \
  bash ~/owl-agent-line/scripts/host_offline_agent.sh
```

## 验收

```bash
curl -sf http://127.0.0.1:3000/healthz | head -c 120; echo
# provider 应为 local-openai-compatible（需带 token，见 secrets）
# 对话：浏览器打开 :3000；或发「用一句话说明是本地还是云端」
```

已亲自测：AGX `/v1/chat/completions` 通；engine `/llm` 与自然语言聊天均走 `local-openai-compatible` / `gpt-oss:20b`。

## 说明

- **本机公网 IP 变化**：不影响本 Agent（鉴权是本地 token + 局域网 Ollama）。
- **AGX 局域网 IP 变化**：改 `AGX_OLLAMA_BASE` 或 secrets 里 `COMPANION_LOCAL_LLM_BASE` 后重跑脚本。
- Docker Open WebUI（Claude-first）**不是**本离线路径；离线用轻量 webapp 即可。
- `safe_mode` 若误开会挡聊天；启动脚本会在 sqlite 正常时清除。
