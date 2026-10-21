#!/usr/bin/env bash
# Host offline Agent (companion webapp :3000) -> AGX Ollama gpt-oss:20b
# No public-cloud LLM; host IP changes do not matter (change SECRETS if AGX LAN IP changes)
set -euo pipefail

WORKERS="${WORKERS:-$HOME/workers}"
SECRETS="$WORKERS/data/runtime/COMPANION.secrets.env"
LOG="$WORKERS/data/runtime/companion_webapp.log"
PIDFILE="$WORKERS/data/runtime/companion_services/webapp.pid"
AGX_BASE="${AGX_OLLAMA_BASE:-http://192.168.90.3:11434/v1}"
MODEL="${AGX_MODEL:-gpt-oss:20b}"
PORT="${COMPANION_WEBUI_PORT:-3000}"

cd "$WORKERS"
mkdir -p "$WORKERS/data/runtime/companion_services"

# Ensure offline routing keys exist (overwrite unless FORCE_LOCAL=0 and value already set)
python3 - <<PY
from pathlib import Path
p = Path("$SECRETS")
repl = {
    "COMPANION_LLM_POLICY": "local",
    "COMPANION_ALLOW_OPENAI": "0",
    "COMPANION_ALLOW_DEEPSEEK": "0",
    "COMPANION_USE_LITELLM": "0",
    "COMPANION_LOCAL_LLM_BASE": "$AGX_BASE",
    "COMPANION_LOCAL_LLM_MODEL": "$MODEL",
    "COMPANION_LOCAL_LLM_API_KEY": "ollama",
    "COMPANION_MODEL": "$MODEL",
    "ASSISTANT_MODEL": "$MODEL",
}
force = "${FORCE_LOCAL:-1}" == "1"
text = p.read_text(encoding="utf-8") if p.is_file() else ""
lines, seen = [], set()
for line in text.splitlines():
    if not line.strip() or line.strip().startswith("#") or "=" not in line:
        lines.append(line); continue
    k, _, v = line.partition("=")
    k, v = k.strip(), v.strip()
    if k in repl and (force or not v):
        lines.append(f"{k}={repl[k]}"); seen.add(k)
    else:
        lines.append(line); seen.add(k)
for k, v in repl.items():
    if k not in seen:
        lines.append(f"{k}={v}")
p.write_text("\n".join(lines) + "\n", encoding="utf-8")
print("secrets offline keys ready ->", "$AGX_BASE", "$MODEL")
PY

if ! curl -sf --max-time 5 "${AGX_BASE%/v1}/api/tags" >/dev/null; then
  echo "WARN: AGX Ollama unreachable: ${AGX_BASE%/v1} — set AGX_OLLAMA_BASE=http://127.0.0.1:11434/v1 for host models" >&2
fi

"$WORKERS/.venv/bin/python" - <<'PY'
from lib.companion.reliability.safe_mode import SafeMode
from pathlib import Path
SafeMode(Path("data/runtime/safe_mode.json")).disable("host_offline_agent_start")
print("safe_mode cleared")
PY

if [[ -f "$PIDFILE" ]]; then
  old=$(cat "$PIDFILE" || true)
  if [[ -n "${old:-}" ]] && kill -0 "$old" 2>/dev/null; then
    kill "$old" || true
    sleep 1
  fi
fi
pkill -f 'python3 -m lib.companion.webapp' 2>/dev/null || true
sleep 1

nohup env -u COMPANION_LLM_POLICY -u COMPANION_LOCAL_LLM_BASE -u COMPANION_LOCAL_LLM_MODEL \
  -u COMPANION_ALLOW_OPENAI -u OPENAI_API_KEY \
  "$WORKERS/.venv/bin/python" -m lib.companion.webapp \
  >>"$LOG" 2>&1 &
echo $! >"$PIDFILE"
sleep 1

TOKEN=$(grep -E '^COMPANION_CHAT_TOKEN=' "$SECRETS" | head -1 | cut -d= -f2-)
echo "PID=$(cat "$PIDFILE")"
curl -sf --max-time 3 "http://127.0.0.1:${PORT}/api/healthz" | head -c 200; echo
echo "Open: http://127.0.0.1:${PORT}/?token=${TOKEN:0:4}... (full token in secrets)"
echo "Mode: M1 offline · provider should be local-openai-compatible · model=$MODEL"
