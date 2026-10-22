#!/usr/bin/env bash
# Pack current Owl/Agent deploy tree onto USB (overwrite zip, no duplicate trees).
#
#   bash ~/owl-agent-line/scripts/pack_owl_deploy_to_usb.sh
#   USB=/media/ubuntu/THIS bash ~/owl-agent-line/scripts/pack_owl_deploy_to_usb.sh
#
set -euo pipefail

USB="${USB:-/media/ubuntu/THIS}"
OWL="${OWL_AGENT_LINE:-$HOME/owl-agent-line}"
WORKERS="${WORKERS:-$HOME/workers}"
STAGE="${STAGE:-/tmp/Alpha_Owl_Implementation_V1}"
ZIP="${USB}/Alpha_Owl_Implementation_V1.zip"

if [[ ! -d "$USB" ]]; then
  echo "USB not mounted: $USB" >&2
  exit 1
fi

rm -rf "$STAGE"
mkdir -p "$STAGE"/{owl-agent-line,workers-agent,docs}

# owl-agent-line (no .git / .cursor)
rsync -a --delete \
  --exclude '.git' --exclude '.cursor' --exclude '__pycache__' --exclude '*.pyc' \
  "$OWL/" "$STAGE/owl-agent-line/"

# workers agent slice only
mkdir -p "$STAGE/workers-agent/lib" "$STAGE/workers-agent/scripts" "$STAGE/workers-agent/data/runtime"
rsync -a --delete \
  --exclude '__pycache__' --exclude '*.pyc' \
  "$WORKERS/lib/companion/" "$STAGE/workers-agent/lib/companion/"
rsync -a --delete \
  "$WORKERS/scripts/companion/" "$STAGE/workers-agent/scripts/companion/" 2>/dev/null || true
rsync -a --delete \
  "$WORKERS/deploy/" "$STAGE/workers-agent/deploy/" 2>/dev/null || true
mkdir -p "$STAGE/workers-agent/data/runtime"
rsync -a \
  "$WORKERS/data/runtime/COMPANION.secrets.env.example" "$STAGE/workers-agent/data/runtime/" 2>/dev/null || true
if [[ -f "$OWL/docs/OWL_NX_DEPLOY.md" ]]; then
  cp "$OWL/docs/OWL_NX_DEPLOY.md" "$STAGE/docs/"
fi

cat > "$STAGE/README.md" <<'EOF'
# Alpha Owl Implementation V1 (host deploy pack)

NX carrier not required for host+AGX+cloud path.

## On host (Ubuntu)

1. Unzip to e.g. `~/owl-deploy/`
2. Merge `workers-agent/` into existing `~/workers/` (lib/companion, scripts/companion, deploy)
3. Run: `bash owl-agent-line/scripts/owl_agent_up.sh`
4. Secrets: copy `COMPANION.secrets.env.example` → `~/workers/data/runtime/COMPANION.secrets.env`

## Endpoints (this week)

- AGX: 192.168.90.3 · gpt-oss:20b + deepseek-r1:14b (see docs/AGX_DUAL_MODEL_AND_USB_RESEARCH.md)
- USB workers/: AGX research zip + PDFs · stage only, no auto-train
- Cloud: M3 SSH bridge
- Owl NX: see docs/OWL_NX_DEPLOY.md when board arrives

EOF

rm -f "$ZIP"
(cd "$(dirname "$STAGE")" && zip -r -q "$ZIP" "$(basename "$STAGE")")
echo "Wrote $ZIP ($(du -h "$ZIP" | cut -f1))"
rm -rf "$STAGE"
