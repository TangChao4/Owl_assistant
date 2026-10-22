#!/usr/bin/env bash
# Host → AGX (Ethernet): sync scripts/data/model if missing; use AGX system Python + torch.
#
#   bash ~/owl-agent-line/scripts/agx_deploy_offline_train.sh
#   bash ~/owl-agent-line/scripts/agx_deploy_offline_train.sh --start
#   SKIP_MODEL=1 bash ...   # scripts + deps only (model already on AGX)
#
set -euo pipefail

AGX="${AGX_SSH:-agx}"
OWL="${OWL_AGENT_LINE:-$HOME/owl-agent-line}"
START=0
[[ "${1:-}" == "--start" ]] && START=1

echo "=== Sync scripts to AGX ==="
ssh "$AGX" "mkdir -p ~/owl-agent-line/scripts"
rsync -az \
  "$OWL/scripts/agx_offline_qlora_train.py" \
  "$OWL/scripts/agx_train_ctl.sh" \
  "$OWL/scripts/agx_train_early_stop.py" \
  "$OWL/scripts/agx_train_smoke.sh" \
  "$OWL/scripts/agx_ensure_train_deps.sh" \
  "$AGX:~/owl-agent-line/scripts/"

echo "=== Sync QLoRA data if needed ==="
ssh "$AGX" "mkdir -p ~/agx_autotrain/data"
rsync -az /home/ubuntu/models/lora_data/qlora_sft_train.jsonl /home/ubuntu/models/lora_data/qlora_sft_holdout.jsonl \
  "$AGX:~/agx_autotrain/data/"

if [[ "${SKIP_MODEL:-0}" != "1" ]]; then
  if ssh "$AGX" "test -f ~/agx_autotrain/models/Qwen2.5-7B-Instruct/config.json"; then
    echo "=== Model already on AGX (SKIP rsync) ==="
  else
    echo "=== Sync HF model Qwen2.5-7B (~15G) ==="
    ssh "$AGX" "mkdir -p ~/agx_autotrain/models"
    rsync -az --info=progress2 /home/ubuntu/models/hf/Qwen2.5-7B-Instruct/ \
      "$AGX:~/agx_autotrain/models/Qwen2.5-7B-Instruct/"
  fi
fi

echo "=== AGX deps (system python3 + user site only) ==="
ssh "$AGX" "chmod +x ~/owl-agent-line/scripts/*.sh && bash ~/owl-agent-line/scripts/agx_ensure_train_deps.sh"

if [[ "$START" == "1" ]]; then
  echo "=== Start training (early-stop; max_sec from AGX_TRAIN_MAX_SEC) on AGX ==="
  ssh "$AGX" "AGX_TRAIN_MODEL=\$HOME/agx_autotrain/models/Qwen2.5-7B-Instruct AGX_TRAIN_PYTHON=python3 bash ~/owl-agent-line/scripts/agx_train_ctl.sh start"
  sleep 5
  ssh "$AGX" "bash ~/owl-agent-line/scripts/agx_train_ctl.sh status"
fi

echo "Done. On AGX: ~/owl-agent-line/scripts/agx_train_ctl.sh stop|status|resume"
