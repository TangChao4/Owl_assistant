# ISSUE-20261021-01 gpt-oss:20b 下载

- **状态**：mitigated（模型已在 ollama list）
- **设备**：agx（或部署 20B 的那台）
- **现象**：此前下载中/需续传
- **验证**：`ollama list` 显示 `gpt-oss:20b` 13GB
- **下一步**：P0 开放局域网 API；本机 curl 验收（见 DEV_PHASE_PLAN_CN.md）
