# 开发日志与问题索引

职责全文：`三机职责分工_猫头鹰_AGX_云端.md`

| 日期 | 类型 | 文件 | 设备 | 摘要 |
|------|------|------|------|------|
| 2026-10-21 | 职责 | 三机职责分工_猫头鹰_AGX_云端.md | 全部 | v2026-10-21b：四端定责；**本机=第二任务发布台** |
| 2026-10-21 | DEVLOG | DEVLOG_20261021.md | host/agx/owl/cloud | 见当日日志 |

## 未关闭 ISSUE
| 编号 | 严重度 | 设备 | 标题 | 状态 |
|------|--------|------|------|------|
| ISSUE-20261018-01 | P2 | owl/usb | Owl optional 模型 partial ~4.4G 未完成 | open |
| ISSUE-20261018-02 | P1 | host | Docker 镜像拉取失败（open-webui/n8n），Agent 完整栈未起 | open |
| ISSUE-20261020-01 | P1 | agx/net | AGX IP 变更，旧 SSH 地址失效 | open（待记新 IP） |
| ISSUE-20261018-03 | P1 | cloud | 云端 CPU 环存活但课程/图风增长停滞；8788 LLM 未装备 | open |
| ISSUE-20261021-01 | P2 | agx | gpt-oss:20b 下载进行中，需保证可续传 | open |

## 写法约定
- 每次收工：新建 `DEVLOG_YYYYMMDD.md`，并在本表加一行。
- 新问题：`issues/ISSUE_YYYYMMDD_短标题.md`，并挂到「未关闭 ISSUE」。
- 关闭问题时改状态为 closed，并在对应 DEVLOG 写验证命令。
