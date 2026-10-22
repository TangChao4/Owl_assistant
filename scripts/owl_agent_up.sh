#!/usr/bin/env bash
# One command to probe + start connectable Owl Agent pieces and open the launch dashboard.
#
#   bash ~/owl-agent-line/scripts/owl_agent_up.sh
#   bash ~/owl-agent-line/scripts/owl_agent_up.sh --ui      # dashboard only (no auto-start)
#   bash ~/owl-agent-line/scripts/owl_agent_up.sh --cli     # terminal status
#   bash ~/owl-agent-line/scripts/owl_agent_up.sh --start   # start services, no HTTP UI
#
set -euo pipefail

WORKERS="${WORKERS:-$HOME/workers}"
OWL_AGENT_LINE="${OWL_AGENT_LINE:-$HOME/owl-agent-line}"
export WORKERS OWL_AGENT_LINE

PY="${WORKERS}/.venv/bin/python"
LAUNCH="${OWL_AGENT_LINE}/scripts/owl_agent_launch.py"

if [[ ! -x "$PY" ]]; then
  echo "Missing workers venv: $PY" >&2
  exit 1
fi
if [[ ! -f "$LAUNCH" ]]; then
  echo "Missing $LAUNCH" >&2
  exit 1
fi

exec "$PY" "$LAUNCH" "$@"
