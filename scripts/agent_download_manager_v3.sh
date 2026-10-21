#!/usr/bin/env bash
# Engineering Research Agent: unattended downloader and link preflight.
# No installation, deletion, service restarts, or changes to existing Alpha/Workers/Ollama directories.
set -Eeuo pipefail
IFS=$'\n\t'

MODE="${1:---check}"
TARGET="${AGENT_DOWNLOAD_DIR:-/media/ubuntu/THIS/AI_Research_Agent_Downloads}"
MIN_FREE_GB="${MIN_FREE_GB:-25}"
LOG_DIR=""
LOG=""
MANIFEST=""
FAILS=0

usage() {
cat <<'HELP'
Usage:
  bash agent_download_manager.sh --check       # Connectivity / free-space preflight; no downloads
  bash agent_download_manager.sh --download    # Download integration components (no LLM weights)
  bash agent_download_manager.sh --models      # Download Qwen3:8b and qwen3:14b using existing Ollama
  bash agent_download_manager.sh --all         # Integration components followed by models
  bash agent_download_manager.sh --status      # Show status of downloaded files/images and Ollama

Environment:
  AGENT_DOWNLOAD_DIR=/media/ubuntu/THIS/AI_Research_Agent_Downloads
  MIN_FREE_GB=25       # Minimum available space to start a stage
  INCLUDE_OPTIONAL=1  # Also fetch optional LangGraph/Dify/VTuber source repositories
  INCLUDE_SEARCH_IMAGE=1 # Also pull SearXNG container image

Notes:
  --download pulls official Open WebUI and n8n Docker images and downloads GitHub
  branch source archives for the integration projects. Sources are reference copies;
  this does not install or enable the services.
  --models uses the existing Ollama server storage configured on this machine, not necessarily
  AGENT_DOWNLOAD_DIR. Check 'systemctl show ollama -p Environment' beforehand.
  Re-running the script skips completed archives and Docker layers where possible.
HELP
}

case "$MODE" in --check|--download|--models|--all|--status|--help) ;; *) usage; exit 2;; esac
if [[ "$MODE" == "--help" ]]; then usage; exit 0; fi

# Resolve target and check the parent mount; never silently create a substitute on the system disk.
if [[ "$TARGET" == /media/ubuntu/THIS/* ]]; then
  if ! mountpoint -q /media/ubuntu/THIS; then
    echo 'ERROR: /media/ubuntu/THIS is not mounted. Refusing to write to the system disk.' >&2
    exit 3
  fi
fi
mkdir -p "$TARGET"/{archives,models,logs,manifests}
LOG_DIR="$TARGET/logs"
LOG="$LOG_DIR/run_$(date +%Y%m%d_%H%M%S).log"
MANIFEST="$TARGET/manifests/downloads.tsv"
touch "$MANIFEST"
exec > >(tee -a "$LOG") 2>&1

say() { printf '\n[%s] %s\n' "$(date '+%F %T')" "$*"; }
warn() { say "WARNING: $*"; }
failed() { FAILS=$((FAILS+1)); warn "$*"; }

space_ok() {
  local avail
  avail=$(df -Pk "$TARGET" | awk 'NR==2 {print $4}')
  say "Destination: $TARGET; available space: $((avail/1024/1024)) GiB (approximately)"
  if (( avail < MIN_FREE_GB * 1024 * 1024 )); then
    warn "Less than $MIN_FREE_GB GiB available. Stage blocked."
    return 1
  fi
}

check_url() {
  local label="$1" url="$2" status
  say "Testing $label: $url"
  # GET range is used instead of relying on HEAD, which some download mirrors reject.
  if curl -fLIsS --connect-timeout 12 --max-time 30 --retry 2 "$url" >/dev/null; then
    say "PASS $label"
    return 0
  fi
  warn "HEAD probe failed for $label; trying byte-range GET"
  if curl -fLsS --range 0-0 --output /dev/null --connect-timeout 12 --max-time 35 --retry 2 "$url"; then
    say "PASS $label (GET)"
    return 0
  fi
  failed "Network access failed: $label ($url)"
  return 1
}

# Use GitHub archive URLs instead of git clone to allow robust curl resume and avoid .git history.
# Branch zip archives are not immutable: write SHA256 once downloaded to facilitate later auditing.
fetch_archive() {
  local key="$1" url="$2" dest tmp rc
  dest="$TARGET/archives/${key}.tar.gz"
  tmp="${dest}.partial"
  if [[ -s "$dest" ]] && gzip -t "$dest" 2>/dev/null && tar -tzf "$dest" >/dev/null 2>&1; then
    say "SKIP already downloaded: $dest"
    return 0
  fi
  say "Downloading $key"
  # GitHub-generated archives may not support HTTP Range (curl exit 33).
  # Try continuing once. If resume is unsupported, keep the old partial as a backup
  # and retry from byte zero to a new partial file (no deletions).
  rc=0
  curl -fL --retry 3 --retry-all-errors --retry-delay 5 --connect-timeout 20 \
       --continue-at - --output "$tmp" "$url" || rc=$?
  if [[ "$rc" == 33 ]]; then
    warn "Server does not support resuming $key. Restarting full archive download."
    if [[ -e "$tmp" ]]; then
      mv -- "$tmp" "${tmp}.no-range.$(date +%Y%m%d_%H%M%S)"
    fi
    rc=0
    curl -fL --retry 5 --retry-all-errors --retry-delay 10 --connect-timeout 20 \
         --output "$tmp" "$url" || rc=$?
  fi
  if (( rc == 0 )); then
    if [[ -s "$tmp" ]] && gzip -t "$tmp" 2>/dev/null && tar -tzf "$tmp" >/dev/null 2>&1; then
      mv -f -- "$tmp" "$dest"
      (cd "$TARGET" && sha256sum "archives/$key.tar.gz" >> manifests/archive_sha256.txt)
      printf '%s\t%s\t%s\n' "$key" "$url" "$(date -Is)" >> "$MANIFEST"
      say "OK $dest"
      return 0
    fi
    failed "$key failed archive verification; partial retained: $tmp"
    return 1
  fi
  failed "$key failed (curl exit $rc); partial retained: $tmp"
  return 1
}

docker_pull() {
  local img="$1"
  if ! command -v docker >/dev/null; then
    failed "Docker not installed, unable to pull $img"
    return 1
  fi
  if ! docker info >/dev/null 2>&1; then
    failed "Docker daemon unavailable or user lacks access. Check: docker info. Image $img skipped."
    return 1
  fi
  say "Pulling Docker image: $img"
  if docker pull "$img"; then
    docker image inspect "$img" --format '{{index .RepoDigests 0}}' 2>/dev/null || true
    say "OK $img (stored in Docker data-root, not necessarily target directory)"
  else
    failed "Docker image download failed: $img"
  fi
}

preflight() {
  say '===== PREFLIGHT: disk, tools, network ====='
  space_ok || return 1
  for c in curl tar gzip sha256sum df; do
    if command -v "$c" >/dev/null; then say "PASS tool: $c"; else failed "Missing tool: $c"; fi
  done
  if command -v docker >/dev/null; then
    docker --version || true
    docker info --format 'Docker root: {{.DockerRootDir}}' 2>/dev/null || warn 'Docker daemon unavailable'
  else warn 'Docker is not installed (archives can still download).'; fi
  if command -v ollama >/dev/null; then
    ollama --version || true
    ollama list || warn 'Ollama server not reachable'
  else warn 'Ollama not installed (model download unavailable).'; fi
  check_url 'GitHub' 'https://github.com/' || true
  check_url 'Open WebUI archive' 'https://github.com/open-webui/open-webui/archive/refs/heads/main.tar.gz' || true
  check_url 'n8n archive' 'https://github.com/n8n-io/n8n/archive/refs/heads/master.tar.gz' || true
  check_url 'SearXNG archive' 'https://github.com/searxng/searxng/archive/refs/heads/master.tar.gz' || true
  check_url 'Qwen3 Ollama library' 'https://ollama.com/library/qwen3' || true
  check_url 'VTuber official repository' 'https://github.com/Open-LLM-VTuber/Open-LLM-VTuber' || true
  say "Preflight reported $FAILS failure(s)."
}

download_integrations() {
  space_ok || { failed 'Insufficient target space; downloads skipped'; return 1; }
  # Avoid downloading enormous n8n monorepo; Docker image is enough for operation.
  fetch_archive 'open-webui-source' 'https://github.com/open-webui/open-webui/archive/refs/heads/main.tar.gz' || true
  fetch_archive 'searxng-source' 'https://github.com/searxng/searxng/archive/refs/heads/master.tar.gz' || true
  fetch_archive 'n8n-docs' 'https://github.com/n8n-io/n8n-docs/archive/refs/heads/main.tar.gz' || true
  if [[ "${INCLUDE_OPTIONAL:-0}" == "1" ]]; then
    fetch_archive 'langgraph-source' 'https://github.com/langchain-ai/langgraph/archive/refs/heads/main.tar.gz' || true
    fetch_archive 'dify-source' 'https://github.com/langgenius/dify/archive/refs/heads/main.tar.gz' || true
    fetch_archive 'vtuber-source' 'https://github.com/Open-LLM-VTuber/Open-LLM-VTuber/archive/refs/heads/main.tar.gz' || true
  fi
  docker_pull 'ghcr.io/open-webui/open-webui:main'
  docker_pull 'docker.n8n.io/n8nio/n8n:latest'
  if [[ "${INCLUDE_SEARCH_IMAGE:-0}" == "1" ]]; then
    docker_pull 'ghcr.io/searxng/searxng:latest'
  fi
  say 'Downloaded integration images are NOT started. No existing service was changed.'
}

models() {
  space_ok || { failed 'Insufficient target space'; return 1; }
  if ! command -v ollama >/dev/null || ! ollama list >/dev/null 2>&1; then
    failed 'Ollama command/server unavailable: cannot download models.'
    return 1
  fi
  say 'WARNING: Ollama model files will go to OLLAMA_MODELS configured for Ollama daemon, NOT necessarily the chosen target disk.'
  say 'Check service configuration: systemctl show ollama -p Environment'
  for m in qwen3:8b qwen3:14b; do
    say "Pulling model $m (may take many GiB)"
    if ollama pull "$m"; then
      say "OK model $m"
    else
      failed "Ollama pull failed: $m"
    fi
  done
}

status() {
  say '==== DISK ===='
  df -h "$TARGET"
  say '==== ARCHIVES ===='
  find "$TARGET/archives" -maxdepth 1 -type f -printf '%s bytes %p\n' | sort -k2
  say '==== OLLAMA ===='
  if command -v ollama >/dev/null; then ollama list || true; fi
  say '==== DOCKER ===='
  if command -v docker >/dev/null; then docker images --format '{{.Repository}}:{{.Tag}} {{.Size}}' 2>/dev/null | grep -E 'open-webui|n8n|searxng' || true; fi
  say '==== LOGS ===='
  ls -lh "$LOG_DIR" | tail -10
}

say "Starting mode $MODE"
case "$MODE" in
  --check) preflight ;;
  --download) preflight; download_integrations ;;
  --models) models ;;
  --all) preflight; download_integrations; models ;;
  --status) status ;;
esac
say "Finished. Failures: $FAILS. Log: $LOG"
if (( FAILS > 0 )); then exit 1; fi
