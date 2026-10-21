# owl-agent-line

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

猫头鹰助手 · 本机第二任务台 · AGX 强推理 · 云端 TC/Alpha 的**运维与开发日志线**。

> **不包含**模型权重（GGUF / Ollama blobs）。权重仍在本机盘、U 盘、AGX 上。  
> **许可证**：本仓库以 [MIT License](LICENSE) 开源。第三方模型权重各自遵循其原许可证（Qwen / Ollama 模型卡等），不因本仓 MIT 而改变。

## 四端入口

| 端 | 职责 |
|----|------|
| 猫头鹰 (Orin NX) | 第一交互：人机 + 秘书 |
| 本机 (`host`) | 不令猫头鹰时的**第二任务发布台** + Agent/TC |
| AGX 32G | 强推理（如 `gpt-oss:20b`） |
| 云端 | TC/Alpha CPU 后台（企微/课程/检索） |

详情：`devlogs/三机职责分工_猫头鹰_AGX_云端.md` · 本机速查：`devlogs/本机任务清单_速查.md`

## 接上 GitHub（本机执行）

### 1. 安装并登录

```bash
sudo apt update && sudo apt install -y gh git
gh auth login
# 选 GitHub.com → HTTPS → Login with browser（或 token）
```

### 2. 确认本仓库

```bash
cd ~/owl-agent-line
git status
```

### 3. 创建远程并推送（开源用公开库）

```bash
# 在已 login 的前提下（公开开源）：
gh repo create owl-agent-line --public --source=. --remote=origin --push

# 若暂时不想公开，可先：
# gh repo create owl-agent-line --private --source=. --remote=origin --push
# 以后再在 GitHub 仓库 Settings → Change visibility → Public
```

若仓库已在网页上建好：

```bash
git remote add origin git@github.com:<你的用户名>/owl-agent-line.git
# 或 HTTPS：
# git remote add origin https://github.com/<你的用户名>/owl-agent-line.git
git push -u origin HEAD
```

### 4. 日常同步

```bash
cd ~/owl-agent-line
# 改完 devlogs / docs 后：
git add -A
git status
git commit -m "docs: 更新开发日志"
git push
```

### 5. 与 U 盘日志同步（可选）

U 盘：`/media/ubuntu/THIS/Owl_Secretary/09_DevLogs/`  
本仓库：`devlogs/`

```bash
# U盘 → 仓库（写完日志后）
cp -a /media/ubuntu/THIS/Owl_Secretary/09_DevLogs/*.md ~/owl-agent-line/devlogs/
# 仓库 → U盘（从 Git 拉下来后）
cp -a ~/owl-agent-line/devlogs/*.md /media/ubuntu/THIS/Owl_Secretary/09_DevLogs/
```

## 目录

```
docs/       定责镜像
devlogs/    开发日志与 ISSUE 模板
issues/     问题单（可从模板复制）
scripts/    下载/部署辅助脚本（不含权重）
```

## 安全

- 勿提交 `*.secrets.env`、API Key、云主机私钥。
- `.gitignore` 已排除模型与密钥；推送前务必 `git status` 检查。
