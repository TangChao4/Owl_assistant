# 这条线如何接上 GitHub

## 目标仓库

| 项 | 值 |
|----|-----|
| 远端 | **https://github.com/TangChao4/Owl_assistant** |
| 分支 | 远端 `main`（本机本地可仍为 `master`） |
| 可见性 | Public · MIT · 版权 唐朝 |
| 本机路径 | `~/owl-agent-line` |

> **本机公网/局域网 IP 会变**：推 GitHub **不依赖本机 IP**。鉴权是账号 Token / SSH 密钥。  
> IP 变了只需改：AGX/猫头鹰的局域网地址文档与 `~/.ssh/config`，**不必**重做 `gh auth`。

## 为什么单独建仓

- `workers` 当前**不是** git 仓库，体积大、含运行数据，不适合整仓直接推 GitHub。
- 模型权重（14G+ Ollama / GGUF）**禁止**进 Git。
- `owl-agent-line` 只跟踪：职责文档、开发日志、ISSUE、小脚本 → 推到 `Owl_assistant`。

## 一次接驳清单

1. [x] 安装 `gh`（本机无 sudo 时：解压到 `~/.local/bin/gh`）
2. [ ] `gh auth login -h github.com -p https -w`（浏览器或 device code；**与 IP 无关**）
3. [x] 仓库已有 commits；remote 脚本会自动加
4. [ ] 一键推送：`~/owl-agent-line/scripts/push_to_github.sh`
5. [ ] 浏览器打开 `Owl_assistant`，确认 `devlogs/` / `docs/` 在
6. [ ] 把结果记进当日 `DEVLOG_*.md`

## 日常推送（推荐脚本）

```bash
export PATH="$HOME/.local/bin:$PATH"
cd ~/owl-agent-line

# 有未提交改动时：脚本会 add + commit + 推到 main（force-with-lease 覆盖）
./scripts/push_to_github.sh "docs: 更新开发日志"

# 仅推已有 commit、自定义说明：
./scripts/push_to_github.sh "chore: sync after cloud exam"
```

脚本行为：

- remote 固定为 `https://github.com/TangChao4/Owl_assistant.git`
- 本地任意分支 → 推到远端 **`main`**
- 首次对齐 Initial commit：使用 `--force-with-lease`（已确认可覆盖）
- 拒绝暂存密钥 / `.local/` 
- **不读取、不绑定本机 IP**

## 手动等价命令

```bash
export PATH="$HOME/.local/bin:$PATH"
cd ~/owl-agent-line
gh auth status
gh auth setup-git
git remote add origin https://github.com/TangChao4/Owl_assistant.git 2>/dev/null \
  || git remote set-url origin https://github.com/TangChao4/Owl_assistant.git
git push -u origin HEAD:main --force-with-lease
```

## 和四端的关系

| 端 | 与 GitHub 关系 |
|----|----------------|
| 本机 | **主推送端**：写日志、commit、`push_to_github.sh` |
| 猫头鹰 NX | 一般不直接 push；需要时从本机 pull 文档 |
| AGX | 不存 git 主副本；只跑模型 |
| 云端 | TC 代码另议；本仓不替代 `/opt/workers` |

## Token / 登录注意

- 用 `gh auth login`；**不要**把 Token 写进仓库或聊天。
- Token/登录态在 `~/.config/gh/`，换 IP **仍然有效**；失效再跑一次 `gh auth login`。
- Classic PAT 至少 `repo`；Fine-grained 需对 `Owl_assistant` 有 Contents 写权限。

## 常见问题

- **auth 失败**：代理/网络；重跑 `gh auth login -h github.com -p https -w`。  
- **误加模型**：立刻 `git rm -r --cached <路径>`，确认 `.gitignore` 后重 commit。  
- **U 盘 exFAT**：不要在 U 盘上 `git init`；以 `~/owl-agent-line` 为准。  
- **本机 IP 变了**：GitHub 推送照旧；只更新 AGX/Owl 局域网文档与 SSH。
