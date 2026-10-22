#!/usr/bin/env bash
# Move paper/submission bulk out of ~/workers → ~/essays (mv, not copy).
# Agent keeps: lib/companion, scripts/companion, deploy, data/runtime, .venv, config (trimmed).
set -euo pipefail

WORKERS="${WORKERS:-$HOME/workers}"
ESSAYS="${ESSAYS:-$HOME/essays/workers_relocated}"
mkdir -p "$ESSAYS"

mv_if() {
  local src="$1" dest="$2"
  if [[ -e "$src" ]]; then
    mkdir -p "$(dirname "$dest")"
    if [[ -e "$dest" ]]; then
      echo "merge into existing: $dest"
      shopt -s dotglob nullglob
      for x in "$src"/*; do
        [[ -e "$x" ]] || continue
        base=$(basename "$x")
        if [[ -e "$dest/$base" ]]; then
          rm -rf "$dest/$base"
        fi
        mv "$x" "$dest/"
      done
      rmdir "$src" 2>/dev/null || true
    else
      mv "$src" "$dest"
    fi
    echo "OK mv $src -> $dest"
  fi
}

cd "$WORKERS"

mv_if "$WORKERS/data/tasks" "$ESSAYS/data_tasks"
mv_if "$WORKERS/data/tc_alpha_research_prep_v2" "$ESSAYS/data_tc_alpha_research_prep_v2"
mv_if "$WORKERS/data/datasets" "$ESSAYS/data_datasets"
mv_if "$WORKERS/data/backups" "$ESSAYS/data_backups"
mv_if "$WORKERS/data/role_training" "$ESSAYS/data_role_training"
mv_if "$WORKERS/data/lit_corpus" "$ESSAYS/data_lit_corpus"
mv_if "$WORKERS/data_public_sets" "$ESSAYS/data_public_sets"

for d in DELIVER_投稿包 DELIVER_远程控制包 DELIVER_submission_pack; do
  mv_if "$WORKERS/$d" "$ESSAYS/paper_deliver/$d"
done
for d in CEP_Q1_retarget_free_fast_v14 ISA_Q1_mature_submission_v14_morning Mechatronics_Q1_retarget_from_ISA_v14 ABCDE check_for_sun need_modify creativity kits archives backups; do
  mv_if "$WORKERS/$d" "$ESSAYS/paper_roots/$d"
done
mv_if "$WORKERS/dataset_BearingDataCenter" "$ESSAYS/dataset_BearingDataCenter"
mv_if "$WORKERS/third_party" "$ESSAYS/third_party"
mv_if "$WORKERS/stm32f407" "$ESSAYS/stm32f407"
mv_if "$WORKERS/groups" "$ESSAYS/groups"

mkdir -p "$ESSAYS/paper_code"
for f in main.py ceo_qt.py; do
  [[ -f "$WORKERS/$f" ]] && mv "$WORKERS/$f" "$ESSAYS/paper_code/$f" && echo "OK mv $f"
done

mkdir -p "$WORKERS/data/tasks"
mkdir -p "$WORKERS/data/backups"

echo "--- done ---"
du -sh "$WORKERS" "$ESSAYS" 2>/dev/null || true
