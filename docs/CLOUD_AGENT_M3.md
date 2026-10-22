# Cloud Agent bridge (M3)

Connect the host `:3000` Agent to the cloud workers stack for **supervision** and **pipeline visibility**, not for cloud LLM inference.

## Architecture

```text
you → host Agent (webapp :3000)
        ├─ M1 heavy LLM → AGX :11434 gpt-oss:20b
        └─ M3 ops → SSH → cloud 39.96.82.193 /opt/workers
              ├─ cloud_status_probe.py (loops / scores)
              ├─ alpha_supervise_loop.py (督促 + safe repair)
              ├─ common_process_fix playbook (/cloud repair)
              └─ STATUS_NOW.md snapshot (/cloud pipeline)
```

Cloud already runs **autonomous CPU loops** (`workers-alpha-cpu-train.service`, curriculum/research/style/tc_auto). The bridge lets the host Agent **see and nudge** that stack.

## Secrets (host)

Add to `~/workers/data/runtime/COMPANION.secrets.env` (not in git):

```bash
COMPANION_CLOUD_HOST=39.96.82.193
COMPANION_CLOUD_USER=root
COMPANION_CLOUD_SSH_KEY=/home/ubuntu/.ssh/workers_cloud_ed25519
COMPANION_CLOUD_ROOT=/opt/workers
```

Requires SSH key access (same as `deploy/push-to-cloud.sh`).

## Chat commands

| Command | Action |
|---------|--------|
| `/cloud` | Help |
| `/cloud status` | Probe loops + passed/held_out/style/research |
| `/cloud supervise` | One cloud supervise cycle (no WeCom push unless enabled on cloud) |
| `/cloud repair` | Playbook + supervise with repair actions |
| `/cloud pipeline` | Top of `STATUS_NOW.md` on cloud |
| `/cloud health` | SSH bridge JSON |
| `监控` / `督促` / `修复` | Routed to **cloud** when bridge ready (host is not `/opt/workers`) |

UI: header button **云** → cloud STATUS text.

## Background supervise (optional)

`scripts/host_offline_agent.sh` starts the loop automatically when the SSH key is present (`CLOUD_SUPERVISE_LOOP=1`, default). PID: `~/workers/data/runtime/companion_services/host_cloud_supervise.pid`.

```bash
# One shot
bash ~/owl-agent-line/scripts/host_cloud_supervise_loop.sh --once

# Loop every 300s (foreground)
CLOUD_SUPERVISE_SEC=300 bash ~/owl-agent-line/scripts/host_cloud_supervise_loop.sh

# Disable auto-start with Agent
CLOUD_SUPERVISE_LOOP=0 bash ~/owl-agent-line/scripts/host_offline_agent.sh
```

Log: `~/workers/data/runtime/companion_services/host_cloud_supervise.log`

## Deploy code to cloud

After changing `cloud_bridge.py` / `alpha_supervise_loop.py` on host:

```bash
cd ~/workers
bash deploy/push-to-cloud.sh   # or scp the changed files under scripts/companion and lib/companion
```

## TCP envelope example

```text
[TCP v1] from=host to=cloud mode=M3 pri=P1 kind=STATUS id=20261022-cloud1
body: want=probe+supervise; cmd=/cloud status
```
