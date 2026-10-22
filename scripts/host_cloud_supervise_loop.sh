#!/usr/bin/env bash
# Host-side M3 cloud supervise loop (SSH → alpha_supervise on cloud).
# Optional: run from cron/systemd every 5–15 min when host Agent is up.
set -euo pipefail

WORKERS="${WORKERS:-$HOME/workers}"
INTERVAL="${CLOUD_SUPERVISE_SEC:-300}"
LOG="${CLOUD_SUPERVISE_LOG:-$WORKERS/data/runtime/companion_services/host_cloud_supervise.log}"
PUSH="${COMPANION_PROACTIVE_PUSH:-0}"

mkdir -p "$(dirname "$LOG")"
cd "$WORKERS"

run_once() {
  "$WORKERS/.venv/bin/python" - <<'PY'
from lib.companion import cloud_bridge as c
if not c.bridge_ready():
    print("bridge_not_ready"); raise SystemExit(2)
r = c.remote_supervise(push_pending=False)
if r.get("ok") is False:
    print(r.get("error") or "fail"); raise SystemExit(1)
print((r.get("text") or "")[:800])
PY
}

echo "$(date -Is) host_cloud_supervise start interval=${INTERVAL}s push=${PUSH}" >>"$LOG"

if [[ "${1:-}" == "--once" ]]; then
  run_once | tee -a "$LOG"
  exit 0
fi

while true; do
  if run_once >>"$LOG" 2>&1; then
    echo "$(date -Is) ok" >>"$LOG"
  else
    echo "$(date -Is) cycle_failed" >>"$LOG"
  fi
  sleep "$INTERVAL"
done
