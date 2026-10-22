#!/usr/bin/env bash
# AGX GPU smoke: checkpoint save + resume without EarlyStoppingCallback KeyError.
# Repro case: 35 steps, eval/save every 10 → resume from ckpt → finish to 35.
set -euo pipefail

WS="${AGX_SMOKE_WS:-/tmp/agx_train_smoke}"
RUN_ID="${AGX_SMOKE_RUN_ID:-smoke_earlystop}"
OUT="$WS/runs/$RUN_ID"
PY="${AGX_TRAIN_PYTHON:-python3}"
SCRIPT="${AGX_TRAIN_SCRIPT:-$HOME/owl-agent-line/scripts/agx_offline_qlora_train.py}"
MODEL="${AGX_TRAIN_MODEL:-$HOME/agx_autotrain/models/Qwen2.5-7B-Instruct}"
TRAIN="${AGX_TRAIN_JSONL:-$HOME/agx_autotrain/data/qlora_sft_train.jsonl}"
EVAL="${AGX_TRAIN_EVAL:-$HOME/agx_autotrain/data/qlora_sft_holdout.jsonl}"

[[ -f "$MODEL/config.json" ]] || { echo "FAIL: model missing $MODEL"; exit 1; }
[[ -f "$TRAIN" ]] || { echo "FAIL: train jsonl missing"; exit 1; }

export HF_HUB_OFFLINE=1 TRANSFORMERS_OFFLINE=1 HF_DATASETS_OFFLINE=1
export PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True

rm -rf "$OUT"
mkdir -p "$OUT"

run_train() {
  "$PY" "$SCRIPT" \
    --model "$MODEL" \
    --train-jsonl "$TRAIN" \
    --eval-jsonl "$EVAL" \
    --output "$OUT" \
    --run-id "$RUN_ID" \
    --max-steps 35 \
    --save-steps 10 \
    --eval-steps 10 \
    --early-stopping-patience 99 \
    --early-stopping-threshold 0.002 \
    "$@"
}

echo "== phase 1: steps 0→20 (stop at 20 via max-steps in subprocess) =="
# Run until first checkpoint past 10, then SIGTERM to mimic interrupt — or use max-steps 20
"$PY" "$SCRIPT" \
  --model "$MODEL" \
  --train-jsonl "$TRAIN" \
  --eval-jsonl "$EVAL" \
  --output "$OUT" \
  --run-id "$RUN_ID" \
  --max-steps 20 \
  --save-steps 10 \
  --eval-steps 10 \
  --early-stopping-patience 99 \
  --early-stopping-threshold 0.002

grep -q checkpoint-10 "$OUT/RUN_STATE.json" || { echo "FAIL: no checkpoint-10"; exit 1; }
st1=$(python3 -c "import json; print(json.load(open('$OUT/RUN_STATE.json'))['status'])")
[[ "$st1" == "completed" ]] || { echo "FAIL: phase1 status=$st1"; exit 1; }

echo "== phase 2: resume 20→35 (exercises resume + save at 30) =="
run_train --resume 2>&1 | tee -a "$OUT/smoke.log"

if grep -qi "KeyError: 'EarlyStoppingCallback'" "$OUT/smoke.log" 2>/dev/null; then
  echo "FAIL: EarlyStoppingCallback KeyError (old trainer)"
  exit 1
fi

st2=$(python3 -c "import json; print(json.load(open('$OUT/RUN_STATE.json'))['status'])")
step=$(python3 -c "import json; print(json.load(open('$OUT/RUN_STATE.json')).get('global_step',0))")
[[ "$st2" == "completed" ]] && [[ "$step" -ge 35 ]] || {
  echo "FAIL: phase2 status=$st2 step=$step"
  exit 1
}
echo "PASS: smoke resume/save OK → $OUT"
