#!/usr/bin/env bash
# Four-endpoint smoke (host-run). mode=M1+M2+M3 acceptance helper.
set -euo pipefail

AGX="${AGX:-http://192.168.90.3:11434}"
OWL="${OWL_AGENT_LINE:-$HOME/owl-agent-line}"
WORKERS="${WORKERS:-$HOME/workers}"
PORT="${COMPANION_WEBUI_PORT:-3000}"
PASS=0
FAIL=0

ok() { echo "  OK  $*"; PASS=$((PASS + 1)); }
bad() { echo "  FAIL $*"; FAIL=$((FAIL + 1)); }

echo "=== endpoint_smoke $(date -Is) ==="
echo "AGX=${AGX}"

if curl -sf --max-time 6 "${AGX}/api/tags" | grep -q gpt-oss; then
  ok "P0 agx tags include gpt-oss"
else
  bad "P0 agx /api/tags"
fi

if curl -sf --max-time 3 "http://127.0.0.1:${PORT}/api/healthz" >/dev/null; then
  ok "P1 agent :${PORT} healthz"
else
  bad "P1 agent :${PORT} healthz"
fi

if [[ -x "${OWL}/scripts/agx_m2_run.sh" ]]; then
  if bash "${OWL}/scripts/agx_m2_run.sh" --json "reply with exactly: pong" | grep -qi pong; then
    ok "P1-4 M2 ssh generate"
  else
    bad "P1-4 M2 ssh generate (no pong in response)"
  fi
else
  bad "P1-4 script missing"
fi

if [[ -x "${WORKERS}/.venv/bin/python" ]]; then
  if ( cd "${WORKERS}" && "${WORKERS}/.venv/bin/python" -c "from lib.companion import cloud_bridge as c; import sys; h=c.health(); sys.exit(0 if c.bridge_ready() and (h.get('ssh_ok') or h.get('ok')) else 1)" ) 2>/dev/null; then
    ok "P1-5 M3 cloud SSH bridge"
  else
    bad "P1-5 M3 cloud SSH bridge"
  fi
else
  bad "workers venv missing"
fi

echo "--- summary: pass=${PASS} fail=${FAIL} ---"
[[ "$FAIL" -eq 0 ]]
