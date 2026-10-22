#!/usr/bin/env bash
# AGX-side train control: start | stop | status | resume (offline, interrupt-safe).
#
#   ~/owl-agent-line/scripts/agx_train_ctl.sh start
#   ~/owl-agent-line/scripts/agx_train_ctl.sh stop
#   ~/owl-agent-line/scripts/agx_train_ctl.sh status
#   ~/owl-agent-line/scripts/agx_train_ctl.sh resume
#
set -euo pipefail

WS="${AGX_TRAIN_WORKSPACE:-$HOME/agx_autotrain}"
RUN_ID="${AGX_TRAIN_RUN_ID:-20261022_5h}"
OUT="$WS/runs/$RUN_ID"
PIDFILE="$OUT/train.pid"
LOG="$OUT/train.log"
MODEL="${AGX_TRAIN_MODEL:-$WS/models/Qwen2.5-7B-Instruct}"
TRAIN="${AGX_TRAIN_JSONL:-$WS/data/qlora_sft_train.jsonl}"
EVAL="${AGX_TRAIN_EVAL:-$WS/data/qlora_sft_holdout.jsonl}"
# Prefer AGX system Python + ~/.local torch (Orin); override with AGX_TRAIN_PYTHON if needed.
PY="${AGX_TRAIN_PYTHON:-python3}"
SCRIPT="${AGX_TRAIN_SCRIPT:-$HOME/owl-agent-line/scripts/agx_offline_qlora_train.py}"
# 0 = no time cap (stop on eval early-stopping). Optional safety: AGX_TRAIN_MAX_SEC=86400
MAX_SEC="${AGX_TRAIN_MAX_SEC:-0}"
EARLY_PATIENCE="${AGX_TRAIN_EARLY_PATIENCE:-4}"
EARLY_THRESHOLD="${AGX_TRAIN_EARLY_THRESHOLD:-0.002}"

mkdir -p "$OUT"

_stop_ollama() {
  if command -v ollama >/dev/null 2>&1; then
    ollama ps 2>/dev/null | awk 'NR>1 {print $1}' | while read -r m; do
      [[ -n "$m" ]] && ollama stop "$m" 2>/dev/null || true
    done
  fi
}

_train_pid_cmdline() {
  local pid="$1"
  ps -p "$pid" -o args= 2>/dev/null | head -1 || true
}

_is_train_pid() {
  local pid="$1"
  local cmd
  cmd="$(_train_pid_cmdline "$pid")"
  [[ "$cmd" == *agx_offline_qlora_train.py* ]]
}

cmd="${1:-status}"
case "$cmd" in
  repair)
    echo "Removing checkpoint dirs missing trainer_state.json under $OUT"
    fixed=0
    for d in "$OUT"/checkpoint-*; do
      [[ -d "$d" ]] || continue
      if [[ ! -f "$d/trainer_state.json" ]]; then
        echo "  rm -rf $d"
        rm -rf "$d"
        fixed=$((fixed + 1))
      fi
    done
    if [[ -f "$PIDFILE" ]]; then
      pid="$(cat "$PIDFILE")"
      if ! _is_train_pid "$pid"; then
        rm -f "$PIDFILE"
        echo "Cleared stale pidfile (pid=$pid not training)"
      fi
    fi
    if [[ -f "$OUT/RUN_STATE.json" ]]; then
      python3 - <<PY
import json
from pathlib import Path
out = Path("$OUT")
p = out / "RUN_STATE.json"
st = json.loads(p.read_text())
valid = None
for ck in sorted(out.glob("checkpoint-*"), key=lambda x: int(x.name.split("-")[-1]), reverse=True):
    if (ck / "trainer_state.json").is_file():
        valid = str(ck)
        break
if valid:
    st["last_checkpoint"] = valid
    print("RUN_STATE last_checkpoint ->", valid)
if st.get("status") == "running":
    st["status"] = "interrupted"
    st.setdefault("note", "marked interrupted by agx_train_ctl repair")
    print("RUN_STATE status -> interrupted (was running)")
p.write_text(json.dumps(st, indent=2))
PY
    fi
    echo "repair done (removed $fixed incomplete checkpoint dirs)"
    ;;
  start)
    if [[ -f "$PIDFILE" ]] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then
      echo "Already running pid=$(cat "$PIDFILE")"
      exit 0
    fi
    [[ -f "$MODEL/config.json" ]] || { echo "Missing model: $MODEL"; exit 1; }
    [[ -f "$TRAIN" ]] || { echo "Missing train jsonl: $TRAIN"; exit 1; }
    [[ -x "$PY" ]] || PY=python3
    _stop_ollama
    export HF_HUB_OFFLINE=1 TRANSFORMERS_OFFLINE=1 HF_DATASETS_OFFLINE=1
    export PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True
    extra=()
    [[ "$MAX_SEC" =~ ^[0-9]+$ ]] && [[ "$MAX_SEC" -gt 0 ]] && extra+=(--max-duration-sec "$MAX_SEC")
    nohup "$PY" "$SCRIPT" \
      --model "$MODEL" \
      --train-jsonl "$TRAIN" \
      --eval-jsonl "$EVAL" \
      --output "$OUT" \
      --run-id "$RUN_ID" \
      "${extra[@]}" \
      --save-steps 25 \
      --early-stopping-patience "$EARLY_PATIENCE" \
      --early-stopping-threshold "$EARLY_THRESHOLD" \
      >>"$LOG" 2>&1 &
    echo $! >"$PIDFILE"
    echo "Started pid=$(cat "$PIDFILE") log=$LOG (early_stop patience=$EARLY_PATIENCE; max_sec=${MAX_SEC:-0})"
    ;;
  stop)
    if [[ ! -f "$PIDFILE" ]]; then
      echo "No pidfile"
      exit 0
    fi
    pid="$(cat "$PIDFILE")"
    if kill -0 "$pid" 2>/dev/null; then
      echo "SIGTERM $pid (checkpoint on exit)..."
      kill -TERM "$pid" || true
      for _ in $(seq 1 120); do
        kill -0 "$pid" 2>/dev/null || break
        sleep 2
      done
      kill -KILL "$pid" 2>/dev/null || true
    fi
    rm -f "$PIDFILE"
    echo "Stopped. Resume with: $0 resume"
    ;;
  resume)
    [[ -f "$MODEL/config.json" ]] || { echo "Missing model: $MODEL"; exit 1; }
    [[ -x "$PY" ]] || PY=python3
    # Preflight: drop broken checkpoint-* and fix RUN_STATE before launch
    bash "$0" repair
    if [[ -f "$PIDFILE" ]] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null && _is_train_pid "$(cat "$PIDFILE")"; then
      echo "Already running pid=$(cat "$PIDFILE")"
      exit 0
    fi
    rm -f "$PIDFILE"
    _stop_ollama
    export HF_HUB_OFFLINE=1 TRANSFORMERS_OFFLINE=1 HF_DATASETS_OFFLINE=1
    export PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True
    extra=()
    [[ "$MAX_SEC" =~ ^[0-9]+$ ]] && [[ "$MAX_SEC" -gt 0 ]] && extra+=(--max-duration-sec "$MAX_SEC")
    nohup "$PY" "$SCRIPT" \
      --model "$MODEL" \
      --train-jsonl "$TRAIN" \
      --eval-jsonl "$EVAL" \
      --output "$OUT" \
      --run-id "$RUN_ID" \
      "${extra[@]}" \
      --save-steps 25 \
      --early-stopping-patience "$EARLY_PATIENCE" \
      --early-stopping-threshold "$EARLY_THRESHOLD" \
      --resume \
      >>"$LOG" 2>&1 &
    echo $! >"$PIDFILE"
    echo "Resumed pid=$(cat "$PIDFILE")"
    ;;
  status)
    if [[ -f "$PIDFILE" ]] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then
      pid="$(cat "$PIDFILE")"
      if _is_train_pid "$pid"; then
        echo "RUNNING pid=$pid"
        _train_pid_cmdline "$pid"
      else
        echo "STALE pidfile pid=$pid (not agx_offline_qlora_train.py) — run: $0 repair"
      fi
    else
      echo "NOT running"
      [[ -f "$PIDFILE" ]] && echo "NOTE: orphan pidfile $(cat "$PIDFILE") — run: $0 repair"
      if [[ -f "$OUT/RUN_STATE.json" ]]; then
        st=$(python3 -c "import json; print(json.load(open('$OUT/RUN_STATE.json')).get('status',''))" 2>/dev/null || true)
        if [[ "$st" == "running" ]]; then
          echo "NOTE: RUN_STATE still says running (likely crash after SIGTERM or trainer error). Try: rsync scripts → resume"
        fi
        if [[ -f "$LOG" ]] && grep -q "KeyError: 'EarlyStoppingCallback'" "$LOG" 2>/dev/null; then
          echo "HINT: EarlyStoppingCallback checkpoint bug — pull latest owl-agent-line (EvalEarlyStopCallback fix), then: $0 resume"
        fi
      fi
    fi
    [[ -f "$OUT/RUN_STATE.json" ]] && tail -c 4000 "$OUT/RUN_STATE.json" || true
    tail -n 12 "$LOG" 2>/dev/null || true
    ;;
  *)
    echo "Usage: $0 start|stop|status|resume|repair"
    exit 1
    ;;
esac
