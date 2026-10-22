#!/usr/bin/env bash
# Prepare AGX for offline autonomous training — NO training until AGX_TRAIN_CONFIRM=1.
#
# Resource policy: keep CPU/GPU at performance (do not lower base frequency).
# Serialize Ollama loads (one heavy model). This script does not change cpufreq.
#
#   bash ~/owl-agent-line/scripts/agx_prepare_autotrain.sh
#   bash ~/owl-agent-line/scripts/agx_prepare_autotrain.sh --remote agx
#
set -euo pipefail

OWL="${OWL_AGENT_LINE:-$HOME/owl-agent-line}"
REMOTE=""
if [[ "${1:-}" == "--remote" ]]; then
  REMOTE="${2:-agx}"
fi

_prep_body() {
  local ws="${AGX_TRAIN_WORKSPACE:-$HOME/agx_autotrain}"
  mkdir -p "$ws"/{campaigns,inbox,logs,ollama_answers}
  local gov=""
  if [[ -r /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor ]]; then
    gov="$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)"
  fi
  cat > "$ws/PREP_STATE.json" <<EOF
{
  "protocol": "agx_autotrain_prep_v1",
  "train_allowed": false,
  "unlock": "Set AGX_TRAIN_CONFIRM=1 only after explicit 开始训练 order",
  "workspace": "$ws",
  "cpu_governor_cpu0": "$gov",
  "resource_rules": [
    "OLLAMA_MAX_LOADED_MODELS=1",
    "Never load gpt-oss:20b and deepseek-r1:14b together",
    "No powersave during eval/train bursts",
    "Use batch=1 + gradient accumulation instead of over-parallelism"
  ],
  "exam_v2_doc": "$OWL/docs/AGX_EXAM_V2_ANTI_LEAK.md"
}
EOF
  echo "Prepared: $ws/PREP_STATE.json"
  if [[ "$gov" == "powersave" ]]; then
    echo "WARN: cpu0 governor=powersave — consider performance on AGX (本脚本不降基频)." >&2
  fi
  if command -v ollama >/dev/null 2>&1; then
    echo "--- ollama ps ---"
    ollama ps 2>/dev/null || true
  fi
}

if [[ -n "$REMOTE" ]]; then
  ssh -o BatchMode=yes "$REMOTE" "OWL='$OWL' AGX_TRAIN_WORKSPACE=\${AGX_TRAIN_WORKSPACE:-\$HOME/agx_autotrain} bash -s" <<'EOS'
set -euo pipefail
ws="${AGX_TRAIN_WORKSPACE:-$HOME/agx_autotrain}"
mkdir -p "$ws"/{campaigns,inbox,logs,ollama_answers}
gov=""
if [[ -r /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor ]]; then
  gov="$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)"
fi
cat > "$ws/PREP_STATE.json" <<EOF
{
  "protocol": "agx_autotrain_prep_v1",
  "train_allowed": false,
  "unlock": "Set AGX_TRAIN_CONFIRM=1 only after explicit order",
  "workspace": "$ws",
  "cpu_governor_cpu0": "$gov",
  "resource_rules": ["OLLAMA_MAX_LOADED_MODELS=1", "one heavy Ollama model at a time", "no powersave during train/eval"]
}
EOF
echo "Prepared: $ws/PREP_STATE.json"
if [[ "$gov" == "powersave" ]]; then
  echo "WARN: cpu0 governor=powersave" >&2
fi
command -v ollama >/dev/null 2>&1 && ollama ps 2>/dev/null || true
EOS
else
  _prep_body
fi

echo "Training NOT started (by design)."
