#!/usr/bin/env bash
# Rsync USB ollama_store → NX ext4 path (run from host when NX SSH works).
#
#   bash ~/owl-agent-line/scripts/owl_nx_sync_models.sh owl /opt/ollama/models
#
set -euo pipefail

OWL_SSH="${1:-owl}"
DEST="${2:-/opt/ollama/models}"
SRC="${OWL_MODEL_SRC:-/media/ubuntu/THIS/Owl_Secretary/01_LLM_Models/ollama_store}"

if [[ ! -d "$SRC" ]]; then
  echo "Source missing: $SRC (mount USB Owl_Secretary?)" >&2
  exit 1
fi

echo "Sync $SRC → ${OWL_SSH}:${DEST}"
ssh -o BatchMode=yes "$OWL_SSH" "sudo mkdir -p '$DEST' && sudo chown -R \$(whoami):\$(whoami) '$DEST' 2>/dev/null || true"
rsync -av --progress --info=progress2 "$SRC/" "${OWL_SSH}:${DEST}/"
echo "Done. On NX: OLLAMA_MODELS=$DEST ollama list"
