#!/usr/bin/env bash
# Host → cloud SSH reverse tunnels for Companion UI + AGX Ollama (LAN-side AGX).
#
# On cloud localhost:
#   13000 → host 127.0.0.1:3000 (Companion webapp)
#   13001 → AGX  192.168.90.3:11434 (Ollama native)
#
# Usage:
#   bash ~/owl-agent-line/scripts/host_cloud_companion_tunnel.sh start
#   bash ~/owl-agent-line/scripts/host_cloud_companion_tunnel.sh stop
#   bash ~/owl-agent-line/scripts/host_cloud_companion_tunnel.sh status
set -euo pipefail

OWL="${OWL_AGENT_LINE:-$HOME/owl-agent-line}"
PIDFILE="${COMPANION_TUNNEL_PIDFILE:-$HOME/workers/data/runtime/companion_services/cloud_tunnel.pid}"
LOG="${COMPANION_TUNNEL_LOG:-$HOME/workers/data/runtime/companion_services/cloud_tunnel.log}"

# shellcheck source=/dev/null
source "$HOME/workers/data/runtime/COMPANION.secrets.env" 2>/dev/null || true

CLOUD_HOST="${COMPANION_CLOUD_HOST:-39.96.82.193}"
CLOUD_USER="${COMPANION_CLOUD_USER:-root}"
CLOUD_KEY="${COMPANION_CLOUD_SSH_KEY:-$HOME/.ssh/workers_cloud_ed25519}"
HOST_UI_PORT="${COMPANION_WEBUI_PORT:-3000}"
AGX_HOST="${AGX_OLLAMA_HOST:-192.168.90.3}"
AGX_PORT="${AGX_OLLAMA_PORT:-11434}"
REMOTE_UI="${COMPANION_TUNNEL_REMOTE_UI:-13000}"
REMOTE_LLM="${COMPANION_TUNNEL_REMOTE_LLM:-13001}"

cmd="${1:-status}"
case "$cmd" in
  start)
    mkdir -p "$(dirname "$PIDFILE")"
    if [[ -f "$PIDFILE" ]] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then
      echo "Tunnel already running pid=$(cat "$PIDFILE")"
      exit 0
    fi
    [[ -f "$CLOUD_KEY" ]] || { echo "Missing SSH key: $CLOUD_KEY"; exit 1; }
    nohup ssh -N \
      -o BatchMode=yes -o ExitOnForwardFailure=yes -o ServerAliveInterval=30 -o ServerAliveCountMax=3 \
      -i "$CLOUD_KEY" \
      -R "127.0.0.1:${REMOTE_UI}:127.0.0.1:${HOST_UI_PORT}" \
      -R "127.0.0.1:${REMOTE_LLM}:${AGX_HOST}:${AGX_PORT}" \
      "${CLOUD_USER}@${CLOUD_HOST}" >>"$LOG" 2>&1 &
    echo $! >"$PIDFILE"
    echo "Tunnel started pid=$(cat "$PIDFILE") cloud=${CLOUD_HOST} remotes ${REMOTE_UI}(UI) ${REMOTE_LLM}(Ollama)"
    ;;
  stop)
    if [[ -f "$PIDFILE" ]]; then
      kill "$(cat "$PIDFILE")" 2>/dev/null || true
      rm -f "$PIDFILE"
    fi
    pkill -f "127.0.0.1:${REMOTE_UI}:127.0.0.1:${HOST_UI_PORT}" 2>/dev/null || true
    echo "Tunnel stopped"
    ;;
  status)
    if [[ -f "$PIDFILE" ]] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then
      echo "RUNNING pid=$(cat "$PIDFILE") → ${CLOUD_HOST}:${REMOTE_UI}/${REMOTE_LLM}"
    else
      echo "NOT running"
    fi
    ;;
  *)
    echo "Usage: $0 start|stop|status"
    exit 1
    ;;
esac
