# 猫头鹰科研秘书：U盘模型下载工具

目标：将 Ollama 模型直接下载到 `/media/ubuntu/THIS/Owl_Secretary/01_LLM_Models/ollama_store`，使用已经运行的独立 Ollama 服务 `127.0.0.1:11435`。

## 使用

1. 保持独立服务运行（第一个终端）：

```bash
OLLAMA_HOST=127.0.0.1:11435 OLLAMA_MODELS=/media/ubuntu/THIS/Owl_Secretary/01_LLM_Models/ollama_store OLLAMA_KEEP_ALIVE=0 ollama serve
```

2. 在另一个终端运行：

```bash
bash owl_model_downloader.sh list
bash owl_model_downloader.sh core
bash owl_model_downloader.sh vision
bash owl_model_downloader.sh optional
```

`all` 下载所有推荐的 Ollama 模型。`core` 优先推荐；`vision` 和 `optional` 可以以后执行。

> 不要用 `sudo` 运行脚本。脚本不更改已有 Ollama systemd 服务，也不删除模型。

## 模型职责

- `qwen3:4b`：主对话、人格与表情状态输出
- `qwen3:1.7b`：低资源备用
- `qwen2.5-coder:3b`：代码、部署脚本、日志分析
- `qwen3-embedding:0.6b`：语义检索、长期记忆向量化
- `qwen3-vl:4b`：图像、截图与视觉理解（下载前确认当前 Ollama 版本支持）
- `deepseek-r1:7b`：可选推理对照
- `qwen2.5-coder:7b`：可选增强代码分析

**重要**：提醒、任务检查、主动督促、表情和语音不是只下载模型就能实现，还需要调度服务、Agent工具权限、麦克风、TTS/ASR、ESP32表情控制等。模型不会自行获得这些能力。

## 注意

- exFAT 可以存放模型数据，但不适合直接承载依赖 Linux 权限的 Python 虚拟环境。
- 确保独立服务的 `OLLAMA_MODELS` 指向外置盘；客户端 `OLLAMA_HOST` 只选择服务，不设置服务端存储路径。
- 脚本检查挂载点，避免外置盘意外拔出后把模型下载到系统盘。
- 下载记录在 `08_Download_Logs`。
- 语音模型请参阅 `SPEECH_DOWNLOAD_GUIDE.md`。
