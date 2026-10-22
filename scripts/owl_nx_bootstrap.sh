#!/usr/bin/env bash
# P2 bootstrap check for Orin NX (from host).
#
#   bash ~/owl-agent-line/scripts/owl_nx_bootstrap.sh [ssh-alias]
#
set -euo pipefail

OWL="${1:-${COMPANION_OWL_SSH:-owl}}"
REPO="${OWL_ASSISTANT_REPO:-https://github.com/TangChao4/Owl_assistant.git}"
NX_APP="${COMPANION_OWL_ROOT:-/home/ubuntu/owl-agent}"

echo "=== Owl NX bootstrap → ${OWL} ==="
if ! ssh -o BatchMode=yes -o ConnectTimeout=8 "$OWL" true 2>/dev/null; then
  echo "FAIL: SSH to ${OWL}. Add Host to ~/.ssh/config and COMPANION_OWL_SSH in secrets."
  echo "See docs/OWL_NX_DEPLOY.md"
  exit 1
fi
echo "OK SSH"

ssh -o BatchMode=yes "$OWL" bash -s <<EOF
set -e
if command -v ollama >/dev/null; then
  echo "OK ollama binary"
  ollama list 2>/dev/null | head -8 || echo "WARN: ollama list failed — set OLLAMA_MODELS on ext4"
else
  echo "WARN: install ollama on NX — curl -fsSL https://ollama.com/install.sh | sh"
fi
if [[ ! -d "$NX_APP/.git" ]]; then
  echo "Cloning Owl_assistant docs (no weights)..."
  git clone --depth 1 "$REPO" "$NX_APP" 2>/dev/null || echo "git clone skipped/failed"
else
  echo "OK repo $NX_APP"
fi
curl -sf --max-time 3 http://127.0.0.1:11434/api/tags >/dev/null && echo "OK ollama :11434" || echo "WARN: ollama not listening on :11434"
EOF

echo "Host: bash ~/owl-agent-line/scripts/owl_agent_up.sh --cli  (Owl row when secrets set)"
echo "Doc: docs/OWL_NX_DEPLOY.md"
