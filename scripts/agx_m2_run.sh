#!/usr/bin/env bash
# M2 — run one prompt on AGX via SSH (host orchestration optional; AGX does inference).
#
#   bash ~/owl-agent-line/scripts/agx_m2_run.sh "Summarize TCP v1 in one sentence."
#   bash ~/owl-agent-line/scripts/agx_m2_run.sh --json "ping"
#
set -euo pipefail

AGX_SSH="${AGX_SSH:-agx}"
AGX_HOST="${AGX_HOST:-192.168.90.3}"
AGX_MODEL="${AGX_MODEL:-gpt-oss:20b}"
JSON=0
PROMPT=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --json) JSON=1; shift ;;
    -h|--help)
      sed -n '2,7p' "$0"
      exit 0
      ;;
    *) PROMPT="$*"; break ;;
  esac
done

if [[ -z "$PROMPT" ]]; then
  echo "Usage: $0 [--json] \"your prompt\"" >&2
  exit 1
fi

SSH_TARGET="$AGX_SSH"
if ! ssh -o BatchMode=yes -o ConnectTimeout=6 "$SSH_TARGET" true 2>/dev/null; then
  SSH_TARGET="ubuntu@${AGX_HOST}"
fi

B64="$(printf '%s' "$PROMPT" | base64 -w0)"

if [[ "$JSON" == "1" ]]; then
  ssh -o BatchMode=yes "$SSH_TARGET" "AGX_PROMPT_B64='$B64' AGX_MODEL='$AGX_MODEL' python3 - <<'PY'
import base64, json, os, urllib.request
prompt = base64.b64decode(os.environ[\"AGX_PROMPT_B64\"]).decode()
model = os.environ[\"AGX_MODEL\"]
body = json.dumps({\"model\": model, \"prompt\": prompt, \"stream\": False}).encode()
req = urllib.request.Request(
    \"http://127.0.0.1:11434/api/generate\",
    data=body,
    headers={\"Content-Type\": \"application/json\"},
    method=\"POST\",
)
with urllib.request.urlopen(req, timeout=120) as r:
    print(r.read().decode())
PY"
else
  echo "[TCP v1] from=host to=agx mode=M2 pri=P1 kind=TASK id=$(date +%Y%m%d-%H%M%S)"
  echo "body: model=${AGX_MODEL}; prompt_len=${#PROMPT}"
  ssh -o BatchMode=yes "$SSH_TARGET" "ollama run $(printf '%q' "$AGX_MODEL") $(printf '%q' "$PROMPT")"
fi
