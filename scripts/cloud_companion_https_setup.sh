#!/usr/bin/env bash
# One-shot on cloud: TLS cert (self-signed) + deploy gateway + optional systemd.
# Run from host: bash scripts/cloud_companion_https_setup.sh
set -euo pipefail

OWL="${OWL_AGENT_LINE:-$HOME/owl-agent-line}"
# shellcheck source=/dev/null
source "$HOME/workers/data/runtime/COMPANION.secrets.env" 2>/dev/null || true

CLOUD_HOST="${COMPANION_CLOUD_HOST:-39.96.82.193}"
CLOUD_USER="${COMPANION_CLOUD_USER:-root}"
CLOUD_KEY="${COMPANION_CLOUD_SSH_KEY:-$HOME/.ssh/workers_cloud_ed25519}"
CLOUD_ROOT="${COMPANION_CLOUD_ROOT:-/opt/workers}"
GATE_KEY="${COMPANION_GATEWAY_KEY:-}"

if [[ -z "$GATE_KEY" ]]; then
  GATE_KEY="$(python3 -c 'import secrets; print(secrets.token_urlsafe(32))')"
  echo "Generated COMPANION_GATEWAY_KEY=$GATE_KEY"
  echo "Add to host secrets: COMPANION_GATEWAY_KEY=$GATE_KEY"
  echo "Add COMPANION_PUBLIC_BASE=https://${CLOUD_HOST}:8443"
fi

scp -i "$CLOUD_KEY" "$OWL/scripts/cloud_companion_gateway.py" "${CLOUD_USER}@${CLOUD_HOST}:${CLOUD_ROOT}/scripts/"

ssh -i "$CLOUD_KEY" "${CLOUD_USER}@${CLOUD_HOST}" bash -s <<EOF
set -euo pipefail
CRT="${CLOUD_ROOT}/data/runtime/companion_gateway.crt"
KEYF="${CLOUD_ROOT}/data/runtime/companion_gateway.key"
mkdir -p "${CLOUD_ROOT}/data/runtime"
if [[ ! -f "\$CRT" ]]; then
  openssl req -x509 -newkey rsa:2048 -nodes -days 825 \\
    -keyout "\$KEYF" -out "\$CRT" \\
    -subj "/CN=${CLOUD_HOST}/O=AlphaCompanion"
fi
pkill -f cloud_companion_gateway.py 2>/dev/null || true
export COMPANION_GATEWAY_KEY='${GATE_KEY}'
export COMPANION_GATEWAY_CERT="\$CRT"
export COMPANION_GATEWAY_KEY_FILE="\$KEYF"
export COMPANION_GATEWAY_PORT=8443
nohup python3 ${CLOUD_ROOT}/scripts/cloud_companion_gateway.py \\
  >> ${CLOUD_ROOT}/data/runtime/companion_gateway.log 2>&1 &
echo \$! > ${CLOUD_ROOT}/data/runtime/companion_gateway.pid
echo "Gateway pid=\$(cat ${CLOUD_ROOT}/data/runtime/companion_gateway.pid)"
EOF

echo ""
echo "Next:"
echo "  1) Aliyun security group: allow inbound TCP 8443 (and keep 22 SSH)."
echo "  2) On host: bash $OWL/scripts/host_cloud_companion_tunnel.sh start"
echo "  3) Clients: https://${CLOUD_HOST}:8443/?token=COMPANION_CHAT_TOKEN"
echo "     Header: X-Companion-Gateway-Key: ${GATE_KEY}  (for /v1 and UI API)"
echo "  4) OpenAI-compatible: https://${CLOUD_HOST}:8443/v1/chat/completions + gateway key + model name"
