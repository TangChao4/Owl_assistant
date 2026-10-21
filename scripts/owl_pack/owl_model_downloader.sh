#!/usr/bin/env bash
set -Eeuo pipefail
BASE="${OWL_BASE:-/media/ubuntu/THIS/Owl_Secretary}"
HOST="${OWL_OLLAMA_HOST:-http://127.0.0.1:11435}"
PROFILE="${1:-core}"
LOG="$BASE/08_Download_Logs"
STORE="$BASE/01_LLM_Models/ollama_store"
mkdir -p "$LOG" "$STORE" "$BASE/03_Speech_Models" "$BASE/04_Embedding_Models" "$BASE/07_Jetson_Deployment"
[[ -d "$(dirname "$BASE")" ]] || { echo 'External drive not mounted'; exit 2; }
[[ "$(findmnt -n -o TARGET --target "$BASE" 2>/dev/null)" != '/' ]] || { echo 'ERROR: External drive not mounted; refusing to write system disk'; exit 2; }
command -v ollama >/dev/null || { echo 'ollama missing'; exit 2; }
export OLLAMA_HOST="$HOST"
if ! curl -fsS --noproxy '*' "$HOST/api/tags" >/dev/null; then
 echo "Ollama at $HOST unavailable. Start dedicated server with:" >&2
 echo "OLLAMA_HOST=127.0.0.1:11435 OLLAMA_MODELS='$STORE' OLLAMA_KEEP_ALIVE=0 ollama serve" >&2
 exit 3
fi
# Check server is configured to use this store when possible. API does not expose storage path.
if [[ "$HOST" != 'http://127.0.0.1:11435' ]]; then echo 'WARNING: nonstandard host; verify model storage directory before downloading.'; fi
CORE=(qwen3:4b qwen3:1.7b qwen2.5-coder:3b qwen3-embedding:0.6b)
VISION=(qwen3-vl:4b)
OPTIONAL=(deepseek-r1:7b qwen2.5-coder:7b)
case "$PROFILE" in
 core) MODELS=("${CORE[@]}");;
 vision) MODELS=("${VISION[@]}");;
 optional) MODELS=("${OPTIONAL[@]}");;
 all) MODELS=("${CORE[@]}" "${VISION[@]}" "${OPTIONAL[@]}");;
 list) printf '%s\n' "${CORE[@]}" "${VISION[@]}" "${OPTIONAL[@]}"; exit 0;;
 *) echo 'Usage: bash owl_model_downloader.sh [core|vision|optional|all|list]'; exit 2;;
esac
TS=$(date +%Y%m%d_%H%M%S)
RUNLOG="$LOG/ollama_download_$TS.log"
FAILED=()
for model in "${MODELS[@]}"; do
 echo "==== $(date -Is) Downloading $model ====" | tee -a "$RUNLOG"
 ok=0
 for attempt in 1 2 3; do
   if ollama pull "$model" 2>&1 | tee -a "$RUNLOG"; then ok=1; break; fi
   echo "Attempt $attempt failed for $model" | tee -a "$RUNLOG"
   sleep 8
 done
 if (( !ok )); then FAILED+=("$model"); fi
done
ollama list | tee "$LOG/model_inventory_$TS.txt"
cat > "$BASE/07_Jetson_Deployment/README_models.txt" <<DOC
Owl Secretary model library
Ollama endpoint on workstation: $HOST
External model store: $STORE
Do NOT run Linux executables/virtualenv from exFAT. Copy model data to a Linux filesystem on Jetson or configure Jetson's Ollama service accordingly.
Model blobs and manifests are both needed for offline migration.
For Jetson: install a compatible Ollama version, stop its service, back up its existing models, copy blobs+manifests, configure OLLAMA_MODELS and restart; verify ollama list.
This script does not download ASR/TTS weights automatically. See SPEECH_DOWNLOAD_GUIDE.md.
DOC
printf 'Finished. Failed models: %s\n' "${FAILED[*]:-none}" | tee -a "$RUNLOG"
(( ${#FAILED[@]} == 0 ))
