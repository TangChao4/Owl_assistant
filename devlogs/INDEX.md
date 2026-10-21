# 开发日志与问题索引

职责全文：`三机职责分工_猫头鹰_AGX_云端.md`

| 日期 | 类型 | 文件 | 设备 | 摘要 |
|------|------|------|------|------|
| 2026-10-21 | 职责 | 三机职责分工_猫头鹰_AGX_云端.md | 全部 | v2026-10-21b：四端定责；**本机=第二任务发布台** |
| 2026-10-21 | 计划 | ../docs/DEV_PHASE_PLAN_CN.md | host/agx | **20B 就绪**；P0 联通→P1 Agent→P2 猫头鹰→P3 联调→P4 GitHub |
| 2026-10-21 | 考验 | ../docs/CLOUD_EXAM_20261021.md | cloud | 亲自考：环活/防泄过/V6绿；增长停滞；无8788 |
| 2026-10-21 | 协议 | ../docs/ENDPOINT_PROTOCOL_CN.md | 全部 | TCP 信封 + 端点字典（host/agx/cloud/owl） |
| 2026-10-21 | README/树 | ../README.md · ../docs/WORKERS_TASK_TREE_CN.md | 全部 | 当前状态入库；工作树扩为双树；DEVLOG强制同步 |
| 2026-10-21 | GitHub | ../docs/GITHUB_CONNECT_CN.md · ../scripts/push_to_github.sh | host | → TangChao4/Owl_assistant；gh登录；IP无关推送 |
| 2026-10-21 | DEVLOG | DEVLOG_20261021.md | host/agx/owl/cloud | P0过；云端CAPA；TCP协议；日志强制更新约定 |

## 未关闭 ISSUE
| 编号 | 严重度 | 设备 | 标题 | 状态 |
|------|--------|------|------|------|
| ISSUE-20261018-01 | P2 | owl/usb | Owl optional 模型 partial ~4.4G 未完成 | open |
| ISSUE-20261018-02 | P1 | host | Docker 镜像拉取失败（open-webui/n8n），Agent 完整栈未起 | open |
| ISSUE-20261020-01 | P1 | agx/net | AGX IP=192.168.90.3（以太网）已录入 | closed |
| ISSUE-20261018-03 | P1 | cloud | 云端 CPU 环存活但课程/图风增长停滞；8788 LLM 未装备 | open |
| ISSUE-20261021-01 | P2 | agx | gpt-oss:20b + 局域网 :11434 已通 | closed |

## 写法约定（强制自动更新）
- **实质性改动或重点决策完成后立刻写日志**，不要等用户再催：
  1. 追加/新建当日 `DEVLOG_YYYYMMDD.md`
  2. 本表加/改一行（类型可写：DEVLOG / 协议 / 考验 / 计划 / 职责）
  3. 阶段或端点状态变了 → 同步 `README.md`「当前状态」与 `docs/WORKERS_TASK_TREE_CN.md`
- 新问题：`issues/ISSUE_YYYYMMDD_短标题.md`，并挂到「未关闭 ISSUE」。
- 关闭问题时改状态为 closed，并在对应 DEVLOG 写验证命令。
- 重点沟通尽量带 `mode=M1|M2|M3` 与 TCP `kind`（见 `docs/ENDPOINT_PROTOCOL_CN.md`）。
