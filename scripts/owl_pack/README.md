# Owl research secretary: USB model download helper

Download Ollama models into `/media/ubuntu/THIS/Owl_Secretary/01_LLM_Models/ollama_store` using a dedicated Ollama service on `127.0.0.1:11435`.

## Usage

1. Keep the dedicated service running (terminal 1):

```bash
OLLAMA_HOST=127.0.0.1:11435 OLLAMA_MODELS=/media/ubuntu/THIS/Owl_Secretary/01_LLM_Models/ollama_store OLLAMA_KEEP_ALIVE=0 ollama serve
```

2. In another terminal:

```bash
bash owl_model_downloader.sh list
bash owl_model_downloader.sh core
bash owl_model_downloader.sh vision
bash owl_model_downloader.sh optional
```

`all` pulls every recommended Ollama model. Prefer `core` first; run `vision` / `optional` later.

> Do not run the script with `sudo`. It does not change existing Ollama systemd units and does not delete models.

## Model roles

- `qwen3:4b`: main chat, persona, expression-state output
- `qwen3:1.7b`: low-resource fallback
- `qwen2.5-coder:3b`: code, deploy scripts, log analysis
- `qwen3-embedding:0.6b`: semantic retrieval / long-term memory vectors
- `qwen3-vl:4b`: images / screenshots (confirm Ollama version supports it first)
- `deepseek-r1:7b`: optional reasoning contrast
- `qwen2.5-coder:7b`: optional stronger coding

**Important**: reminders, task checks, nudges, expression, and speech need scheduler services, agent tool permissions, mic, TTS/ASR, ESP32 expression control, etc. Downloading weights alone does not grant those capabilities.

## Notes

- exFAT can store model blobs but is a poor home for Linux-permission Python venvs.
- Point the dedicated service `OLLAMA_MODELS` at the external disk; client `OLLAMA_HOST` only selects the service.
- The script checks the mount point so an unplugged disk does not silently download onto the system disk.
- Download logs live under `08_Download_Logs`.
- Speech models: see `SPEECH_DOWNLOAD_GUIDE.md`.
