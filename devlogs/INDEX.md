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
