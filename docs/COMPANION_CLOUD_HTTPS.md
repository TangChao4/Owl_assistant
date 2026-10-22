# Companion 云端 HTTPS 访问（客户 / 联网调用你的模型）

把 **公网 HTTPS** 接到 **本机 Agent + AGX Ollama**，不把你的 Chat Token 暴露给公网裸奔 `:3000`。

## 架构

```text
客户浏览器 / OpenAI SDK
    → https://39.96.82.193:8443  (cloud gateway + TLS)
        → 127.0.0.1:13000  SSH -R  (host Companion :3000)
        → 127.0.0.1:13001  SSH -R  (AGX Ollama :11434)
```

- **外层**：`COMPANION_GATEWAY_KEY`（Header `X-Companion-Gateway-Key` 或 `Authorization: Bearer`）
- **内层**：Companion 仍用 `COMPANION_CHAT_TOKEN`（`?token=` 或 POST body）

## 一次性部署

### 1. 云安全组

阿里云 ECS：**入站 TCP 8443**（HTTPS 网关）。22 仅你的 IP 更佳。

### 2. 云上网关 + 自签证书

在 **host** 执行：

```bash
bash ~/owl-agent-line/scripts/cloud_companion_https_setup.sh
```

把输出的 `COMPANION_GATEWAY_KEY` 写入 `~/workers/data/runtime/COMPANION.secrets.env`：

```bash
COMPANION_GATEWAY_KEY=...
COMPANION_PUBLIC_BASE=https://39.96.82.193:8443
COMPANION_CLOUD_GATEWAY_BASE=https://39.96.82.193:8443
# 可选：AGX 不可达时走云端回环
COMPANION_LLM_POLICY=hybrid
```

### 3. 本机反向隧道（host 必须在线且能访问 AGX）

```bash
bash ~/owl-agent-line/scripts/host_cloud_companion_tunnel.sh start
bash ~/owl-agent-line/scripts/host_cloud_companion_tunnel.sh status
```

Agent 启动时自动开隧道：`COMPANION_CLOUD_TUNNEL=1 bash ~/owl-agent-line/scripts/host_offline_agent.sh`

### 4. 客户访问

- **Web UI**：`https://39.96.82.193:8443/?token=COMPANION_CHAT_TOKEN`  
  请求需带 Header：`X-Companion-Gateway-Key: <COMPANION_GATEWAY_KEY>`
- **OpenAI 兼容**（调用 AGX 模型）：

```bash
curl -sk https://39.96.82.193:8443/v1/chat/completions \
  -H "X-Companion-Gateway-Key: $COMPANION_GATEWAY_KEY" \
  -H "Authorization: Bearer ollama" \
  -H "Content-Type: application/json" \
  -d '{"model":"gpt-oss:20b","messages":[{"role":"user","content":"hi"}]}'
```

自签证书：客户端需 `-k` 或导入 `companion_gateway.crt`。

## 运维

| 命令 | 位置 |
|------|------|
| `host_cloud_companion_tunnel.sh status` | host |
| `curl -sk https://39.96.82.193:8443/healthz` | 任意 |
| 网关日志 | cloud `/opt/workers/data/runtime/companion_gateway.log` |

## 安全说明

- 务必使用 **强 Gateway Key + Chat Token**；不要提交 git。
- 网关只绑定 cloud `127.0.0.1:13000/13001`，不直接暴露 host 内网。
- `COMPANION_LLM_POLICY=local` 时 host Agent 仍只连 AGX；`hybrid` 在 AGX 失败时可经云端隧道回退。
