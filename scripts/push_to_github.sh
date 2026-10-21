#!/usr/bin/env bash
# 本机 → GitHub: TangChao4/Owl_assistant (覆盖推送到 main)
# 鉴权走 gh / HTTPS token，不依赖本机公网 IP（IP 变化无需改本脚本）
set -euo pipefail

REPO_DIR="${REPO_DIR:-$HOME/owl-agent-line}"
REMOTE_NAME="${REMOTE_NAME:-origin}"
REMOTE_URL="${REMOTE_URL:-https://github.com/TangChao4/Owl_assistant.git}"
REMOTE_BRANCH="${REMOTE_BRANCH:-main}"
# 仅本次 commit 生效，不改全局 git config（本机 IP 无关）
GIT_AUTHOR_NAME="${GIT_AUTHOR_NAME:-唐朝}"
GIT_AUTHOR_EMAIL="${GIT_AUTHOR_EMAIL:-TangChao4@users.noreply.github.com}"
LOCAL_BRANCH="$(git -C "$REPO_DIR" rev-parse --abbrev-ref HEAD 2>/dev/null || echo master)"
MSG="${1:-docs: sync owl-agent-line}"
# 首次覆盖远端 Initial commit：FORCE=1；日常可用 FORCE=0（默认仍 force-with-lease，失败则提示）
FORCE="${FORCE:-1}"

cd "$REPO_DIR"
export PATH="${HOME}/.local/bin:${PATH}"

if ! command -v gh >/dev/null 2>&1; then
  echo "缺少 gh。安装：sudo apt install -y gh" >&2
  exit 1
fi

if ! gh auth status -h github.com >/dev/null 2>&1; then
  echo "未登录 GitHub。本机执行一次（与 IP 无关）：" >&2
  echo "  gh auth login -h github.com -p https -w" >&2
  exit 1
fi

# 确保 remote 指向 Owl_assistant
if git remote get-url "$REMOTE_NAME" >/dev/null 2>&1; then
  cur="$(git remote get-url "$REMOTE_NAME")"
  if [[ "$cur" != "$REMOTE_URL" && "$cur" != "${REMOTE_URL%.git}" && "$cur" != "git@github.com:TangChao4/Owl_assistant.git" ]]; then
    echo "更新 remote $REMOTE_NAME: $cur → $REMOTE_URL"
    git remote set-url "$REMOTE_NAME" "$REMOTE_URL"
  fi
else
  git remote add "$REMOTE_NAME" "$REMOTE_URL"
fi

# 用 gh 凭证推 HTTPS（换 IP 后仍有效，直到 token 失效再 gh auth login）
gh auth setup-git >/dev/null

# 可选：有改动则提交
if [[ -n "$(git status --porcelain)" ]]; then
  git add -A
  # 再挡一层：密钥/本地 env 不应进仓
  if git diff --cached --name-only | grep -E '(^|/)\.local/|\.secrets\.env$|agx\.secrets|COMPANION\.secrets\.env$' >/dev/null; then
    echo "拒绝：暂存区含密钥/本地 env，请检查 .gitignore" >&2
    git status --short
    exit 1
  fi
  git -c user.name="$GIT_AUTHOR_NAME" -c user.email="$GIT_AUTHOR_EMAIL" commit -m "$MSG" || true
fi

echo "推送 $LOCAL_BRANCH → $REMOTE_NAME/$REMOTE_BRANCH （覆盖远端 main）…"
git fetch "$REMOTE_NAME" "$REMOTE_BRANCH" 2>/dev/null || true
# HTTP/1.1 在部分网络下比 HTTP/2 更稳（与本机 IP 无关）
push_opts=(-c http.version=HTTP/1.1)
if [[ "$FORCE" == "1" ]]; then
  # 用户已确认可覆盖 Owl_assistant 的 Initial commit / main
  git "${push_opts[@]}" push -u "$REMOTE_NAME" "HEAD:$REMOTE_BRANCH" --force
else
  git "${push_opts[@]}" push -u "$REMOTE_NAME" "HEAD:$REMOTE_BRANCH" --force-with-lease
fi

echo "完成：https://github.com/TangChao4/Owl_assistant"
echo "提示：本机 IP 变化不影响本脚本；若 LAN 上 AGX IP 变了，另改 docs/AGX_ENDPOINT_CN.md / SSH Host。"
