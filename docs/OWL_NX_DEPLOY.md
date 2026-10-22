# Owl (Orin NX) deploy — Phase P2

> Goal: first **secretary entry** on NX with small Ollama models; heavy tasks **forward** to AGX (`192.168.90.3`).

## Network (host)

Add to `~/.ssh/config` when NX IP is known (example LAN slot — replace with your NX address):

```sshconfig
Host owl
  HostName 192.168.90.2
  User ubuntu
  IdentityFile ~/.ssh/id_ed25519
```

Add to `~/workers/data/runtime/COMPANION.secrets.env`:

```bash
COMPANION_OWL_SSH=owl
COMPANION_FS_OWL_SSH=owl
COMPANION_OWL_MODEL=qwen3:4b
COMPANION_OWL_OLLAMA=http://127.0.0.1:11434
```

Restart Agent: `bash ~/owl-agent-line/scripts/host_offline_agent.sh`

Host UI: ops panel tab **Owl** · chat `/owl` · `/todo` · `/forward agx …`

---

## P2-1 Models on ext4 (not exFAT)

USB store (host): `/media/ubuntu/THIS/Owl_Secretary/01_LLM_Models/ollama_store`

On NX, use **ext4** home or `/opt/ollama/models`:

```bash
# On NX (after SSH)
sudo mkdir -p /opt/ollama/models
# From host (when NX online):
bash ~/owl-agent-line/scripts/owl_nx_sync_models.sh owl /opt/ollama/models
```

Acceptance: `OLLAMA_MODELS=/opt/ollama/models ollama list` shows 5 core models (see `scripts/owl_pack/README.md`).

---

## P2-2 Ollama on NX

Reference: [Ollama API](https://github.com/ollama/ollama/blob/main/docs/api.md) (GitHub — same protocol as host/AGX).

```bash
# systemd or manual on NX
sudo tee /etc/systemd/system/ollama-owl.service <<'EOF'
[Unit]
Description=Ollama Owl NX
After=network.target

[Service]
Environment=OLLAMA_HOST=0.0.0.0:11434
Environment=OLLAMA_MODELS=/opt/ollama/models
ExecStart=/usr/local/bin/ollama serve
Restart=always

[Install]
WantedBy=multi-user.target
EOF
sudo systemctl enable --now ollama-owl
```

Primary chat model: **`qwen3:4b`**.

Optional UI later (not default on host — Docker pull was blocked): [Open WebUI](https://github.com/open-webui/open-webui) on NX only, pointing at local Ollama.

---

## P2-3 Secretary (host until NX sync)

Minimal todos/reminders on host (JSON store):

```text
/todo 买元件
/todo list
/remind 周五交进度
/todo done <id>
```

When NX is online, mirror policy can be added in a later sync script.

---

## P2-4 Forward heavy → AGX

From host Agent (simulates owl handoff):

```text
/forward agx 请用三句话解释 TCP v1 envelope 字段
```

Writes receipt to `~/workers/data/runtime/owl_forward_receipts.jsonl` with `[TCP v1] from=owl to=agx …`.

---

## Bootstrap from host

```bash
bash ~/owl-agent-line/scripts/owl_nx_bootstrap.sh owl
```

Checks SSH, Ollama, suggests clone of **[Owl_assistant](https://github.com/TangChao4/Owl_assistant)** on NX for docs/scripts (no weights in git).

---

## Phase checklist

| ID | Item | Status |
|----|------|--------|
| P2-1 | Models on NX ext4 | run when NX on LAN |
| P2-2 | Ollama serve + qwen3:4b | bootstrap script |
| P2-3 | `/todo` `/remind` | **done on host** |
| P2-4 | `/forward agx` + receipt | **done on host** |
| P2-5 | Speech/expression | deferred |
