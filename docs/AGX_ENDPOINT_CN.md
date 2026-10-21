# AGX 端点（本机联调）

| 项 | 值 |
|----|-----|
| 以太网 IP | `192.168.90.3` |
| SSH | `ssh agx` 或 `ssh ubuntu@192.168.90.3`（本机已配 Host `agx` / `agx-eth`） |
| Ollama | `http://192.168.90.3:11434` |
| 模型 | `gpt-oss:20b` |
| 监听 | `OLLAMA_HOST=0.0.0.0:11434`（systemd override） |

## 本机自检
```bash
curl -s http://192.168.90.3:11434/api/tags
curl -s http://192.168.90.3:11434/api/generate \
  -d '{"model":"gpt-oss:20b","prompt":"ping","stream":false}'
```

> 密码勿写入仓库；优先 SSH 公钥登录。
