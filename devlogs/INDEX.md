# Devlog and issue index

Full role split: `ROLE_SPLIT_OWL_AGX_CLOUD.md`

| Date | Type | File | Device | Summary |
|------|------|------|--------|---------|
| 2026-10-21 | roles | ROLE_SPLIT_OWL_AGX_CLOUD.md | all | v2026-10-21b: four-endpoint roles; **host = second task desk** |
| 2026-10-21 | plan | ../docs/DEV_PHASE_PLAN.md | host/agx | **20B ready**; P0 link → P1 Agent → P2 Owl → P3 integration → P4 GitHub |
| 2026-10-21 | exam | ../docs/CLOUD_EXAM_20261021.md | cloud | Hands-on: loops alive / anti-leak pass / V6 green; growth stalled; no 8788 |
| 2026-10-21 | protocol | ../docs/ENDPOINT_PROTOCOL.md | all | TCP envelope + endpoint registry (host/agx/cloud/owl) |
| 2026-10-21 | README/tree | ../README.md · ../docs/WORKERS_TASK_TREE.md | all | Current status checked in; dual task trees; DEVLOG sync required |
| 2026-10-21 | GitHub | ../docs/GITHUB_CONNECT.md · ../scripts/push_to_github.sh | host | → TangChao4/Owl_assistant; gh login; IP-independent push |
| 2026-10-21 | deploy | ../docs/HOST_OFFLINE_AGENT.md · ../scripts/host_offline_agent.sh | host/agx | P1 offline Agent: :3000 → AGX 20B; policy=local |
| 2026-10-21 | i18n | ../docs/devlog-auto-update.mdc · README | all | English-only repo; .cursor not on GitHub |
| 2026-10-21 | feature | ../docs/HOST_OFFLINE_AGENT.md | host | File export + clickable download links in :3000 UI |
| 2026-10-22 | deploy | ../scripts/pack_owl_deploy_to_usb.sh | host/USB | Alpha_Owl_Implementation_V1.zip overwrite |
| 2026-10-22 | cleanup | ~/essays/workers_relocated | host | workers paper data → essays (~31G mv) |
| 2026-10-22 | plan | ../docs/OWL_NX_DEPLOY.md | owl/host | P2 bridge, secretary, forward, NX bootstrap scripts |
| 2026-10-22 | accept | DEVLOG_20261022.md | host | P1: Plan retry + FS filter/export UX |
| 2026-10-22 | accept | DEVLOG_20261022.md | host | P0: 自洽机/云/记忆 ops modal; status_snap fast |
| 2026-10-22 | feature | ../docs/HOST_OFFLINE_AGENT.md | host/agx | Multi-endpoint file workspace + UI panel |
| 2026-10-22 | plan | ../docs/DEV_PHASE_PLAN.md | host/agx | P1 status; `agx_m2_run.sh` + `endpoint_smoke.sh` |
| 2026-10-22 | feature | ../docs/HOST_OFFLINE_AGENT.md | host | `owl_agent_up.sh` launch dashboard :8765 |
| 2026-10-22 | accept | DEVLOG_20261022.md | host/cloud | M3 bridge verified; supervise loop auto-start on Agent boot |
| 2026-10-22 | feature | ../docs/CLOUD_AGENT_M3.md | host/cloud | Agent SSH M3: supervise + pipeline on cloud |
| 2026-10-22 | exam | ../docs/AGENT_CLOUD_GAP_20261022.md | host/cloud/agx | Agent 4/4 smoke; cloud probe delta vs 10-21; P3 partial; next M3 repair + CEO |
| 2026-10-22 | plan | ../docs/AGX_DUAL_MODEL_AND_USB_RESEARCH.md | host/AGX/USB | R1 14B + gpt-oss routing; USB research zip; no train until user |
| 2026-10-22 | protocol | ../docs/AGX_EXAM_V2_ANTI_LEAK.md | host/AGX | Exam campaign v2; leakage audit; autotrain prep gated |
| 2026-10-22 | exam | ../docs/AGX_SEALED_RESEARCH_EXAM.md | host/AGX | 5 sealed repro tasks; code/embodied/data; selfcheck pass |
| 2026-10-22 | doc | ../docs/AGENT_USER_GUIDE.md | host | Agent 使用指南：启动、UI、斜杠命令、运维面板 |
| 2026-10-22 | feature | DEVLOG_20261022.md | host/AGX | :3000 顶栏可用模型下拉 + `/api/models` + model_key 路由 |
| 2026-10-22 | feature | ../docs/AGENT_USER_GUIDE.md | host | 联网检索：`/web`、口语查资料、DDG/Brave/Tavily/SearX |
| 2026-10-22 | feature | ../docs/AGENT_USER_GUIDE.md | host | 本机执行：grant +「确认执行 exec_…」只读 shell |
| 2026-10-22 | plan | ../docs/AGX_OFFLINE_TRAIN.md | AGX | QLoRA 早停 eval_loss 为主；取消默认 5h 跑满 |
| 2026-10-22 | fix | ../scripts/agx_offline_qlora_train.py | AGX | Resume-safe early stop；修复 EarlyStoppingCallback KeyError |
| 2026-10-22 | deploy | ../docs/COMPANION_CLOUD_HTTPS.md | host/cloud | :8443 网关 + SSH 隧道暴露 Agent/AGX 模型 |
| 2026-10-22 | feature | DEVLOG_20261022.md | host | Companion UI 客户向：停止/确认条/斜杠提示/移动布局/复制 |
| 2026-10-21 | feature | ../docs/HOST_OFFLINE_AGENT.md | host | Plan mode + collapsible chat UI |
| 2026-10-21 | DEVLOG | DEVLOG_20261021.md | host/agx/owl/cloud | P0 pass; cloud CAPA; TCP protocol; mandatory log-update rule |

## Open ISSUES
| ID | Severity | Device | Title | Status |
|----|----------|--------|-------|--------|
| ISSUE-20261018-01 | P2 | owl/usb | Owl optional model partial ~4.4G incomplete | open |
| ISSUE-20261018-02 | P1 | host | Docker image pull failed (open-webui/n8n); full Agent stack not up | open |
| ISSUE-20261020-01 | P1 | agx/net | AGX IP=192.168.90.3 (Ethernet) recorded | closed |
| ISSUE-20261018-03 | P1 | cloud | Cloud CPU loops alive but course/style growth stalled; 8788 LLM not equipped | open |
| ISSUE-20261021-01 | P2 | agx | gpt-oss:20b + LAN :11434 working | closed |

## Writing rules (mandatory auto-update)
- **Write the log immediately after substantive changes or key decisions** — do not wait for the user to ask:
  1. Append/create today's `DEVLOG_YYYYMMDD.md`
  2. Add/update one row in this table (type may be: DEVLOG / protocol / exam / plan / roles)
  3. If phase or endpoint status changed → sync `README.md` "Current status" and `docs/WORKERS_TASK_TREE.md`
- New issues: `issues/ISSUE_YYYYMMDD_short_title.md`, and list under "Open ISSUES".
- When closing an issue, set status to closed and record verification commands in the matching DEVLOG.
- Prefer `mode=M1|M2|M3` and TCP `kind` on important communication (see `docs/ENDPOINT_PROTOCOL.md`).
