# 这条线如何接上 GitHub

## 为什么单独建仓

- `workers` 当前**不是** git 仓库，体积大、含运行数据，不适合整仓直接推 GitHub。
- 模型权重（14G+ Ollama / GGUF）**禁止**进 Git。
- `owl-agent-line` 只跟踪：职责文档、开发日志、ISSUE、小脚本 → 适合私有 GitHub。

## 一次接驳清单

1. [ ] `sudo apt install -y gh git`
2. [ ] `gh auth login`（浏览器或 Token）
3. [ ] `cd ~/owl-agent-line && git status`
4. [ ] 若还无 commit：见下方「首次提交」
5. [ ] `gh repo create owl-agent-line --public --source=. --remote=origin --push`（开源；先私有则改 `--private`）
5b. [ ] 确认根目录有 `LICENSE`（默认 MIT）
6. [ ] 浏览器打开仓库，确认 `devlogs/` 在
7. [ ] 把仓库 URL 记进当日 `DEVLOG_*.md`

## 首次提交（若尚无 commit）

```bash
cd ~/owl-agent-line
git add -A
git status   # 确认没有 .gguf / secrets / blobs
git -c user.name="你的名字" -c user.email="你的邮箱@example.com" commit -m "chore: bootstrap owl-agent-line ops docs"
```

（使用 `-c` 仅本次生效，不改全局 git config。）

## 开源与许可证

- 本仓默认 **MIT**（见根目录 `LICENSE`）：允许他人使用、修改、再分发，需保留版权与许可声明。
- **换许可证**（在首次大量 fork 前尽早定）：
  - 仍要宽松 + 专利条款 → 改用 **Apache-2.0**
  - 要求衍生作品也开源 → **GPL-3.0**
  - 网络服务也必须开源 → **AGPL-3.0**
- **不要**把 API Key、云主机私钥、内网 IP 密码写进公开仓。
- 模型文件不进 Git；使用者自行按模型方许可下载。

## 和四端的关系

| 端 | 与 GitHub 关系 |
|----|----------------|
| 本机 | **主推送端**：写日志、commit、push |
| 猫头鹰 NX | 一般不直接 push；需要时从本机 pull 文档 |
| AGX | 不存 git 主副本；只跑模型 |
| 云端 | TC 代码另议；本仓不替代 `/opt/workers` |

## Token 权限（若用 PAT）

创建 Classic Token 或 Fine-grained：至少 `repo`（私有库读写）。  
不要把 Token 写进仓库文件。

## 常见问题

- **auth 失败**：代理/网络；或改用 `gh auth login` → SSH。  
- **误加模型**：立刻 `git rm -r --cached <路径>`，确认 `.gitignore` 后重 commit。  
- **U 盘 exFAT**：不要在 U 盘上 `git init`；以 `~/owl-agent-line` 为准。
