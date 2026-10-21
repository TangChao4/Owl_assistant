#!/usr/bin/env bash
# Host → GitHub: TangChao4/Owl_assistant (push to main)
# Auth via gh / HTTPS token; independent of host public IP
set -euo pipefail

REPO_DIR="${REPO_DIR:-$HOME/owl-agent-line}"
REMOTE_NAME="${REMOTE_NAME:-origin}"
REMOTE_URL="${REMOTE_URL:-https://github.com/TangChao4/Owl_assistant.git}"
REMOTE_BRANCH="${REMOTE_BRANCH:-main}"
# Commit identity for this run only (does not change global git config)
GIT_AUTHOR_NAME="${GIT_AUTHOR_NAME:-Tangchao}"
GIT_AUTHOR_EMAIL="${GIT_AUTHOR_EMAIL:-TangChao4@users.noreply.github.com}"
LOCAL_BRANCH="$(git -C "$REPO_DIR" rev-parse --abbrev-ref HEAD 2>/dev/null || echo master)"
MSG="${1:-docs: sync owl-agent-line}"
# FORCE=1 overwrites remote main (confirmed); FORCE=0 uses --force-with-lease
FORCE="${FORCE:-1}"

cd "$REPO_DIR"
export PATH="${HOME}/.local/bin:${PATH}"

if ! command -v gh >/dev/null 2>&1; then
  echo "gh not found. Install: sudo apt install -y gh (or place binary in ~/.local/bin)" >&2
  exit 1
fi

if ! gh auth status -h github.com >/dev/null 2>&1; then
  echo "Not logged in to GitHub. Run once (IP-independent):" >&2
  echo "  gh auth login -h github.com -p https -w" >&2
  exit 1
fi

if git remote get-url "$REMOTE_NAME" >/dev/null 2>&1; then
  cur="$(git remote get-url "$REMOTE_NAME")"
  if [[ "$cur" != "$REMOTE_URL" && "$cur" != "${REMOTE_URL%.git}" && "$cur" != "git@github.com:TangChao4/Owl_assistant.git" ]]; then
    echo "Updating remote $REMOTE_NAME: $cur -> $REMOTE_URL"
    git remote set-url "$REMOTE_NAME" "$REMOTE_URL"
  fi
else
  git remote add "$REMOTE_NAME" "$REMOTE_URL"
fi

gh auth setup-git >/dev/null

if [[ -n "$(git status --porcelain)" ]]; then
  git add -A
  # Block adding secrets/.local/.cursor; allowing deletion of .cursor from the index is OK
  if git diff --cached --name-only --diff-filter=ACMR | grep -E '(^|/)\.local/|\.secrets\.env$|agx\.secrets|COMPANION\.secrets\.env$|(^|/)\.cursor/' >/dev/null; then
    echo "Refuse: staged secrets, .local, or .cursor add/modify — check .gitignore" >&2
    git status --short
    exit 1
  fi
  git -c user.name="$GIT_AUTHOR_NAME" -c user.email="$GIT_AUTHOR_EMAIL" commit -m "$MSG" || true
fi

echo "Pushing $LOCAL_BRANCH -> $REMOTE_NAME/$REMOTE_BRANCH ..."
git fetch "$REMOTE_NAME" "$REMOTE_BRANCH" 2>/dev/null || true
push_opts=(-c http.version=HTTP/1.1)
if [[ "$FORCE" == "1" ]]; then
  git "${push_opts[@]}" push -u "$REMOTE_NAME" "HEAD:$REMOTE_BRANCH" --force
else
  git "${push_opts[@]}" push -u "$REMOTE_NAME" "HEAD:$REMOTE_BRANCH" --force-with-lease
fi

echo "Done: https://github.com/TangChao4/Owl_assistant"
echo "Note: host IP changes do not affect this script; if AGX LAN IP changes, update docs/AGX_ENDPOINT.md / SSH Host."
