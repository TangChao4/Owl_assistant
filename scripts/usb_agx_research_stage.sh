#!/usr/bin/env bash
# Stage AGX Research Engineer V1 from USB — unpack + manifest check only. NO training.
#
#   bash ~/owl-agent-line/scripts/usb_agx_research_stage.sh
#   USB=/media/ubuntu/THIS DEST=$HOME/AGX_Research_Engineer_V1_20261022 bash ...
#
set -euo pipefail

USB="${USB:-/media/ubuntu/THIS}"
SRC="${USB}/workers"
ZIP="${SRC}/AGX_Research_Engineer_Training_and_Evaluation_V1_20261022.zip"
DEST="${DEST:-$HOME/AGX_Research_Engineer_V1_20261022}"
FALLBACK="${OWL_AGENT_LINE:-$HOME/owl-agent-line}/.staging/AGX_Research_Engineer_V1_20261022"

if [[ ! -f "$ZIP" ]]; then
  echo "Missing zip: $ZIP" >&2
  exit 1
fi

echo "=== USB workers ==="
ls -lh "$SRC"/*.pdf "$ZIP" 2>/dev/null || true

if [[ -d "$DEST" ]] && [[ -w "$(dirname "$DEST")" ]]; then
  echo "DEST exists (overwrite extract): $DEST"
  rm -rf "$DEST"
fi

if [[ ! -w "$(dirname "$DEST")" ]] 2>/dev/null || ! mkdir -p "$(dirname "$DEST")" 2>/dev/null; then
  echo "Cannot write $DEST — using repo staging: $FALLBACK"
  DEST="$FALLBACK"
  rm -rf "$DEST"
  mkdir -p "$(dirname "$DEST")"
fi
unzip -q "$ZIP" -d "$(dirname "$DEST")"
# Zip root folder name is fixed in archive
if [[ ! -d "$DEST" ]]; then
  inner="$(unzip -Z1 "$ZIP" | head -1 | cut -d/ -f1)"
  mv "$(dirname "$DEST")/$inner" "$DEST"
fi

if [[ -f "$DEST/FILE_SHA256_MANIFEST.json" ]]; then
  echo "Manifest present: $DEST/FILE_SHA256_MANIFEST.json"
fi

cat <<EOF

Staged: $DEST
Training: NOT started (by design). Next (your choice):
  cd $DEST && python3 -m agx_research.cli doctor
  python3 -m agx_research.cli canary-audit --output outputs/host_staged_canaries.json

On AGX: scp/rsync this tree, then same doctor/canary. See docs/AGX_DUAL_MODEL_AND_USB_RESEARCH.md
EOF
