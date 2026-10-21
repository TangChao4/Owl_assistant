# How This Line Connects to GitHub

## Target repository

| Item | Value |
|------|-------|
| Remote | **https://github.com/TangChao4/Owl_assistant** |
| Branch | remote `main` (local may still be `master`) |
| Visibility | Public · MIT · Copyright Tangchao |
| Local path | `~/owl-agent-line` |

> **Host public/LAN IP can change**: pushing to GitHub **does not depend on host IP**. Auth is account Token / SSH key.  
> When IP changes, only update AGX/owl LAN address docs and `~/.ssh/config`; **no need** to redo `gh auth`.

## Why a separate repo

- `workers` is currently **not** a git repo; it is large and holds runtime data — not suitable to push whole as one GitHub repo.
- Model weights (14G+ Ollama / GGUF) are **forbidden** in Git.
- `owl-agent-line` only tracks: role docs, DEVLOGs, ISSUEs, small scripts → push to `Owl_assistant`.

## One-time connect checklist

1. [x] Install `gh` (no sudo on host: extract to `~/.local/bin/gh`)
2. [x] `gh auth login` logged in as **TangChao4** (HTTPS; **IP-independent**)
3. [x] remote = `https://github.com/TangChao4/Owl_assistant.git`
4. [x] First push succeeded: `scripts/push_to_github.sh` → `main` (overwrote Initial commit)
5. [x] Remote shows `.cursor` / `devlogs` / `docs` / `scripts` …
6. [x] Recorded in `DEVLOG_20261021.md`

## Daily push (recommended script)

```bash
export PATH="$HOME/.local/bin:$PATH"
cd ~/owl-agent-line

# With uncommitted changes: script add + commit + push to main (force-with-lease overwrite)
./scripts/push_to_github.sh "docs: update DEVLOG"

# Push existing commits only, custom message:
./scripts/push_to_github.sh "chore: sync after cloud exam"
```

Script behavior:

- remote fixed to `https://github.com/TangChao4/Owl_assistant.git`
- any local branch → push to remote **`main`**
- first align with Initial commit: uses `--force-with-lease` (confirmed OK to overwrite)
- refuses staging secrets / `.local/`
- **does not read or bind host IP**

## Manual equivalent

```bash
export PATH="$HOME/.local/bin:$PATH"
cd ~/owl-agent-line
gh auth status
gh auth setup-git
git remote add origin https://github.com/TangChao4/Owl_assistant.git 2>/dev/null \
  || git remote set-url origin https://github.com/TangChao4/Owl_assistant.git
git push -u origin HEAD:main --force-with-lease
```

## Relation to the four endpoints

| Endpoint | Relation to GitHub |
|----------|--------------------|
| host | **Primary push seat**: write logs, commit, `push_to_github.sh` |
| owl NX | usually does not push; pull docs from host when needed |
| agx | does not hold the main git copy; only runs models |
| cloud | TC code is separate; this repo does not replace `/opt/workers` |

## Token / login notes

- Use `gh auth login`; **do not** put Tokens in the repo or chat.
- Token/session lives in `~/.config/gh/`; changing IP **still works**; if expired, run `gh auth login` again.
- Classic PAT needs at least `repo`; Fine-grained needs Contents write on `Owl_assistant`.

## FAQ

- **auth fails**: proxy/network; rerun `gh auth login -h github.com -p https -w`.  
- **accidentally added models**: immediately `git rm -r --cached <path>`, confirm `.gitignore`, then re-commit.  
- **USB exFAT**: do not `git init` on the USB; use `~/owl-agent-line`.  
- **host IP changed**: GitHub push unchanged; only update AGX/Owl LAN docs and SSH.
