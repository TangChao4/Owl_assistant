#!/usr/bin/env bash
# On AGX: install only missing training wheels into user site (reuse system torch).
set -euo pipefail

PY="${AGX_TRAIN_PYTHON:-python3}"
missing=()
for mod in peft transformers accelerate bitsandbytes; do
  if ! "$PY" -c "import $mod" 2>/dev/null; then
    missing+=("$mod")
  fi
done

if [[ ${#missing[@]} -eq 0 ]]; then
  echo "AGX train deps OK (system/user python: $PY)"
  "$PY" -c "import torch, peft; print('torch', torch.__version__, 'peft', peft.__version__)"
  exit 0
fi

echo "Installing missing on AGX: ${missing[*]}"
"$PY" -m pip install --user --break-system-packages "${missing[@]}"
echo "Done."
