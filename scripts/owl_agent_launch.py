#!/usr/bin/env python3
"""Owl Agent launch dashboard — probe M1/M3 components and start what is reachable.

  bash ~/owl-agent-line/scripts/owl_agent_up.sh          # start + open UI
  bash ~/owl-agent-line/scripts/owl_agent_up.sh --ui     # dashboard only
  bash ~/owl-agent-line/scripts/owl_agent_up.sh --cli    # terminal summary, no HTTP
"""

from __future__ import annotations

import argparse
import json
import os
import re
import subprocess
import sys
import threading
import time
import urllib.error
import urllib.request
import webbrowser
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from typing import Any

WORKERS = Path(os.environ.get("WORKERS", Path.home() / "workers")).expanduser()
OWL = Path(os.environ.get("OWL_AGENT_LINE", Path.home() / "owl-agent-line")).expanduser()
SECRETS = WORKERS / "data/runtime/COMPANION.secrets.env"
WEBAPP_PID = WORKERS / "data/runtime/companion_services/webapp.pid"
SUP_PID = WORKERS / "data/runtime/companion_services/host_cloud_supervise.pid"
LAUNCH_PID = WORKERS / "data/runtime/companion_services/owl_launch.pid"
URL_HINT = Path("/tmp/owl_agent_launch_url.txt")
AGENT_URL_HINT = Path("/tmp/owl_agent_ui_url.txt")

PORT = int(os.environ.get("OWL_LAUNCH_PORT", "8765"))
AGENT_PORT = int(os.environ.get("COMPANION_WEBUI_PORT", "3000"))
AGX_BASE = os.environ.get("AGX_OLLAMA_BASE", "http://192.168.90.3:11434/v1").rstrip("/")
HOST_OLLAMA = os.environ.get("HOST_OLLAMA_BASE", "http://127.0.0.1:11434").rstrip("/")

_start_lock = threading.Lock()
_start_running = False


def _read_secrets() -> dict[str, str]:
    out: dict[str, str] = {}
    if not SECRETS.is_file():
        return out
    for line in SECRETS.read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        k, _, v = line.partition("=")
        out[k.strip()] = v.strip().strip('"').strip("'")
    return out


def _ollama_root(base: str) -> str:
    b = base.rstrip("/")
    if b.endswith("/v1"):
        return b[: -len("/v1")]
    return b


def _port_open(port: int) -> bool:
    import socket

    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        s.settimeout(0.3)
        return s.connect_ex(("127.0.0.1", port)) == 0


def _ollama_ok(base: str, timeout: float = 4.0) -> tuple[bool, str, list[str]]:
    url = f"{base.rstrip('/')}/api/tags"
    try:
        with urllib.request.urlopen(url, timeout=timeout) as r:
            data = json.loads(r.read().decode("utf-8", errors="replace"))
        names = [m.get("name", "") for m in data.get("models") or [] if isinstance(m, dict)]
        names = [n for n in names if n][:8]
        return True, "online", names
    except Exception as e:
        return False, str(e)[:120], []


def _pid_alive(pidfile: Path) -> tuple[bool, int | None]:
    if not pidfile.is_file():
        return False, None
    try:
        pid = int(pidfile.read_text().strip())
    except ValueError:
        return False, None
    try:
        os.kill(pid, 0)
        return True, pid
    except OSError:
        return False, pid


def _webapp_health() -> dict[str, Any]:
    alive, pid = _pid_alive(WEBAPP_PID)
    ok_http = False
    detail: dict[str, Any] = {}
    try:
        with urllib.request.urlopen(f"http://127.0.0.1:{AGENT_PORT}/api/healthz", timeout=3) as r:
            detail = json.loads(r.read().decode("utf-8", errors="replace"))
            ok_http = r.status == 200
    except Exception as e:
        detail = {"error": str(e)[:120]}
    return {
        "id": "agent",
        "label": "Agent · Chat UI",
        "mode": "M1",
        "ok": ok_http,
        "pid": pid,
        "port": AGENT_PORT,
        "detail": detail.get("provider") or detail.get("error") or "",
        "href": agent_chat_url(),
    }


def _owl_status() -> dict[str, Any]:
    ok = False
    detail = "not configured"
    if str(WORKERS) not in sys.path:
        sys.path.insert(0, str(WORKERS))
    try:
        from lib.companion import owl_bridge as ob  # type: ignore

        h = ob.health()
        ok = bool(h.get("ok") or h.get("ssh_ok"))
        detail = "online" if h.get("ok") else (h.get("hint") or h.get("error") or "offline")[:80]
    except Exception as e:
        detail = str(e)[:80]
    return {
        "id": "owl",
        "label": "Owl · Orin NX",
        "mode": "owl",
        "ok": ok,
        "detail": detail,
    }


def _cloud_status() -> dict[str, Any]:
    ok = False
    detail: Any = ""
    passed: int | None = None
    if str(WORKERS) not in sys.path:
        sys.path.insert(0, str(WORKERS))
    try:
        from lib.companion import cloud_bridge as c  # type: ignore

        h = c.health()
        ok = bool(h.get("ok") or h.get("ssh_ok"))
        detail = h.get("hostname") or h.get("error") or h.get("host") or ""
        if c.bridge_ready() and not c.is_cloud_runtime():
            try:
                p = c.remote_probe()
                if p.get("ok"):
                    passed = p.get("passed")
            except Exception:
                pass
    except Exception as e:
        detail = str(e)[:120]
    sub = f"passed={passed}" if passed is not None else str(detail)[:80]
    return {
        "id": "cloud",
        "label": "Cloud · M3 SSH",
        "mode": "M3",
        "ok": ok,
        "detail": sub,
    }


def _supervise_status() -> dict[str, Any]:
    alive, pid = _pid_alive(SUP_PID)
    return {
        "id": "supervise",
        "label": "Cloud · 督促循环",
        "mode": "M3",
        "ok": alive,
        "pid": pid,
        "detail": f"every {os.environ.get('CLOUD_SUPERVISE_SEC', '300')}s" if alive else "stopped",
    }


def collect_status() -> dict[str, Any]:
    agx_ok, agx_err, agx_models = _ollama_ok(_ollama_root(AGX_BASE))
    host_ok, host_err, host_models = _ollama_ok(HOST_OLLAMA)

    secrets = _read_secrets()
    model = secrets.get("COMPANION_LOCAL_LLM_MODEL") or os.environ.get("AGX_MODEL", "gpt-oss:20b")

    components = [
        {
            "id": "agx",
            "label": "AGX · Ollama LLM",
            "mode": "M1",
            "ok": agx_ok,
            "detail": ", ".join(agx_models[:3]) if agx_models else agx_err,
            "endpoint": AGX_BASE,
        },
        {
            "id": "host_ollama",
            "label": "Host · Ollama 备用",
            "mode": "M1",
            "ok": host_ok,
            "detail": ", ".join(host_models[:3]) if host_models else host_err,
            "endpoint": HOST_OLLAMA,
        },
        _webapp_health(),
        _owl_status(),
        _cloud_status(),
        _supervise_status(),
    ]
    connectable = sum(1 for c in components if c["ok"])
    return {
        "ts": time.strftime("%Y-%m-%dT%H:%M:%S%z"),
        "model": model,
        "connectable": connectable,
        "total": len(components),
        "components": components,
        "agent_url": agent_chat_url(),
        "launch_url": f"http://127.0.0.1:{PORT}/",
    }


def agent_chat_url() -> str:
    tok = _read_secrets().get("COMPANION_CHAT_TOKEN", "")
    if not tok:
        return f"http://127.0.0.1:{AGENT_PORT}/"
    return f"http://127.0.0.1:{AGENT_PORT}/?token={urllib.request.quote(tok, safe='')}"


def run_start_script() -> tuple[bool, str]:
    global _start_running
    script = OWL / "scripts/host_offline_agent.sh"
    if not script.is_file():
        return False, f"missing {script}"
    with _start_lock:
        if _start_running:
            return True, "start already in progress"
        _start_running = True
    try:
        env = os.environ.copy()
        env.setdefault("OWL_AGENT_LINE", str(OWL))
        env.setdefault("WORKERS", str(WORKERS))
        proc = subprocess.run(
            ["bash", str(script)],
            cwd=str(WORKERS),
            env=env,
            capture_output=True,
            text=True,
            timeout=120,
        )
        out = (proc.stdout or "") + (proc.stderr or "")
        tail = "\n".join(out.strip().splitlines()[-8:])
        ok = proc.returncode == 0
        if ok:
            AGENT_URL_HINT.write_text(agent_chat_url() + "\n", encoding="utf-8")
        return ok, tail or f"exit {proc.returncode}"
    except subprocess.TimeoutExpired:
        return False, "start timed out (120s)"
    except Exception as e:
        return False, str(e)
    finally:
        with _start_lock:
            _start_running = False


HTML_PAGE = r"""<!DOCTYPE html>
<html lang="zh">
<head>
<meta charset="utf-8"/>
<meta name="viewport" content="width=device-width, initial-scale=1"/>
<title>Owl Agent · Launch</title>
<style>
:root {
  color-scheme: dark;
  --bg: #0b0d12;
  --fg: #e8eaed;
  --mut: #9aa0a6;
  --acc: #7cacf8;
  --ok: #5bd286;
  --bad: #f07178;
  --card: #151922;
  --edge: #2a3140;
  --glow: rgba(124, 172, 248, 0.15);
}
* { box-sizing: border-box; }
body {
  margin: 0; min-height: 100vh; font-family: "Segoe UI", system-ui, sans-serif;
  background: radial-gradient(1200px 600px at 10% -10%, var(--glow), transparent),
              radial-gradient(900px 500px at 90% 0%, rgba(91,210,134,.08), transparent),
              var(--bg);
  color: var(--fg);
}
.wrap { max-width: 720px; margin: 0 auto; padding: 28px 18px 48px; }
header { margin-bottom: 28px; }
h1 { font-size: 1.55rem; font-weight: 650; letter-spacing: -0.02em; margin: 0 0 6px; }
.sub { color: var(--mut); font-size: 0.92rem; line-height: 1.5; }
.stats { display: flex; gap: 10px; flex-wrap: wrap; margin-top: 14px; }
.pill {
  font-size: 12px; padding: 5px 10px; border-radius: 999px;
  border: 1px solid var(--edge); background: rgba(255,255,255,.03);
}
.grid { display: grid; gap: 12px; }
.card {
  background: var(--card); border: 1px solid var(--edge); border-radius: 14px;
  padding: 14px 16px; display: grid; grid-template-columns: auto 1fr auto; gap: 12px; align-items: center;
  transition: border-color .2s, box-shadow .2s;
}
.card.ok { border-color: rgba(91,210,134,.35); box-shadow: 0 0 0 1px rgba(91,210,134,.06) inset; }
.dot { width: 11px; height: 11px; border-radius: 50%; background: var(--bad); box-shadow: 0 0 12px rgba(240,113,120,.35); }
.card.ok .dot { background: var(--ok); box-shadow: 0 0 12px rgba(91,210,134,.4); }
.card h2 { margin: 0; font-size: 0.98rem; font-weight: 600; }
.card p { margin: 4px 0 0; font-size: 0.82rem; color: var(--mut); word-break: break-word; }
.tag { font-size: 11px; color: var(--acc); border: 1px solid var(--edge); padding: 3px 8px; border-radius: 6px; }
.actions { margin-top: 22px; display: flex; flex-wrap: wrap; gap: 10px; }
button, a.btn {
  appearance: none; border: 0; border-radius: 12px; padding: 12px 18px; font-size: 0.95rem; font-weight: 600;
  cursor: pointer; text-decoration: none; display: inline-flex; align-items: center; justify-content: center;
}
.primary { background: linear-gradient(135deg, #6ea8fe, #5bd286); color: #0b0d12; flex: 1; min-width: 180px; }
.primary:disabled { opacity: .55; cursor: wait; }
.ghost { background: transparent; color: var(--fg); border: 1px solid var(--edge); }
.log {
  margin-top: 16px; font-size: 12px; color: var(--mut); white-space: pre-wrap;
  background: #0f1218; border: 1px solid var(--edge); border-radius: 10px; padding: 10px 12px; max-height: 140px; overflow: auto;
  display: none;
}
.log.show { display: block; }
footer { margin-top: 32px; font-size: 11px; color: var(--mut); text-align: center; }
</style>
</head>
<body>
<div class="wrap">
  <header>
    <h1>Owl Agent Launch</h1>
    <p class="sub">一键探测并接上当前可用的组分：M1 本地推理 · Agent 界面 · M3 云端督促与流水线。</p>
    <div class="stats">
      <span class="pill" id="statLine">探测中…</span>
      <span class="pill" id="modelLine"></span>
    </div>
  </header>
  <div class="grid" id="cards"></div>
  <div class="actions">
    <button type="button" class="primary" id="startBtn">启动可用组件</button>
    <button type="button" class="ghost" id="refreshBtn">刷新</button>
    <a class="btn ghost" id="chatLink" href="#" target="_blank" rel="noopener">打开 Agent 聊天</a>
  </div>
  <pre class="log" id="logBox"></pre>
  <footer>仅监听 127.0.0.1 · 令牌不会显示在页面上</footer>
</div>
<script>
const cards = document.getElementById('cards');
const statLine = document.getElementById('statLine');
const modelLine = document.getElementById('modelLine');
const startBtn = document.getElementById('startBtn');
const refreshBtn = document.getElementById('refreshBtn');
const chatLink = document.getElementById('chatLink');
const logBox = document.getElementById('logBox');

function esc(s) { const d = document.createElement('div'); d.textContent = s ?? ''; return d.innerHTML; }

function render(data) {
  statLine.textContent = `已连接 ${data.connectable} / ${data.total} · ${data.ts || ''}`;
  modelLine.textContent = data.model ? `模型 · ${data.model}` : '';
  chatLink.href = data.agent_url || '#';
  cards.innerHTML = (data.components || []).map(c => `
    <article class="card ${c.ok ? 'ok' : ''}">
      <div class="dot" title="${c.ok ? 'online' : 'offline'}"></div>
      <div>
        <h2>${esc(c.label)}</h2>
        <p>${esc(String(c.detail || ''))}</p>
      </div>
      <span class="tag">${esc(c.mode || '')}</span>
    </article>`).join('');
}

async function refresh() {
  const r = await fetch('/api/status');
  render(await r.json());
}

startBtn.onclick = async () => {
  startBtn.disabled = true;
  logBox.classList.add('show');
  logBox.textContent = '正在启动…';
  try {
    const r = await fetch('/api/start', { method: 'POST' });
    const j = await r.json();
    logBox.textContent = j.log || j.error || JSON.stringify(j);
    await refresh();
    if (j.agent_url) window.open(j.agent_url, '_blank', 'noopener');
  } catch (e) {
    logBox.textContent = String(e);
  } finally {
    startBtn.disabled = false;
  }
};
refreshBtn.onclick = refresh;
refresh();
setInterval(refresh, 8000);
</script>
</body>
</html>
"""


class Handler(BaseHTTPRequestHandler):
    server_version = "OwlLaunch/1.0"

    def log_message(self, fmt: str, *args: Any) -> None:
        return

    def _json(self, code: int, obj: Any) -> None:
        body = json.dumps(obj, ensure_ascii=False).encode("utf-8")
        self.send_response(code)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def do_GET(self) -> None:
        path = self.path.split("?", 1)[0]
        if path in ("/", "/index.html"):
            body = HTML_PAGE.encode("utf-8")
            self.send_response(200)
            self.send_header("Content-Type", "text/html; charset=utf-8")
            self.send_header("Content-Length", str(len(body)))
            self.end_headers()
            self.wfile.write(body)
            return
        if path == "/api/status":
            self._json(200, collect_status())
            return
        self.send_error(404)

    def do_POST(self) -> None:
        if self.path.split("?", 1)[0] != "/api/start":
            self.send_error(404)
            return
        ok, log = run_start_script()
        st = collect_status()
        self._json(200 if ok else 500, {"ok": ok, "log": log, "agent_url": st.get("agent_url"), "status": st})


def _mask_agent_url(url: str) -> str:
    return re.sub(r"(token=)[^&]+", r"\1***", url)


def print_cli(st: dict[str, Any]) -> None:
    print()
    print("  ╭─────────────────────────────────────────╮")
    print("  │  Owl Agent Launch · CLI                 │")
    print("  ╰─────────────────────────────────────────╯")
    print(f"  Model: {st.get('model', '?')}  ·  online {st.get('connectable')}/{st.get('total')}")
    print()
    for c in st.get("components") or []:
        mark = "●" if c.get("ok") else "○"
        print(f"  {mark} [{c.get('mode','?'):>2}] {c.get('label','')}")
        if c.get("detail"):
            print(f"      {c['detail']}")
    print()
    print(f"  Chat: {_mask_agent_url(st.get('agent_url', ''))}")
    print(f"  Dashboard: http://127.0.0.1:{PORT}/")
    print("  (full chat URL also in /tmp/owl_agent_ui_url.txt)")
    print()


def serve(auto_start: bool, open_browser: bool) -> None:
    if auto_start:
        ok, log = run_start_script()
        if not ok:
            print(log, file=sys.stderr)
    st = collect_status()
    URL_HINT.write_text(st["launch_url"] + "\n", encoding="utf-8")
    AGENT_URL_HINT.write_text(st.get("agent_url", "") + "\n", encoding="utf-8")

    alive, pid = _pid_alive(LAUNCH_PID)
    if _port_open(PORT) and (alive or pid is None):
        print(f"Launch UI already on port {PORT}: {st['launch_url']}")
        if open_browser:
            webbrowser.open(st["launch_url"])
        return
    if alive and pid and not _port_open(PORT):
        LAUNCH_PID.unlink(missing_ok=True)

    httpd = ThreadingHTTPServer(("127.0.0.1", PORT), Handler)
    LAUNCH_PID.write_text(str(os.getpid()) + "\n", encoding="utf-8")
    print(f"Launch UI → {st['launch_url']}")
    if open_browser:
        threading.Timer(0.4, lambda: webbrowser.open(st["launch_url"])).start()
    try:
        httpd.serve_forever()
    finally:
        if LAUNCH_PID.is_file():
            try:
                if int(LAUNCH_PID.read_text().strip()) == os.getpid():
                    LAUNCH_PID.unlink(missing_ok=True)
            except ValueError:
                pass


def main() -> int:
    parser = argparse.ArgumentParser(description="Owl Agent launch dashboard")
    parser.add_argument("--cli", action="store_true", help="Print status and exit")
    parser.add_argument("--ui", action="store_true", help="Dashboard only, do not auto-start services")
    parser.add_argument("--start", action="store_true", help="Run host_offline_agent.sh then exit")
    parser.add_argument("--no-browser", action="store_true", help="Do not open a browser tab")
    args = parser.parse_args()

    if str(WORKERS) not in sys.path:
        sys.path.insert(0, str(WORKERS))

    if args.start:
        ok, log = run_start_script()
        print(log)
        print_cli(collect_status())
        return 0 if ok else 1

    if args.cli:
        print_cli(collect_status())
        return 0

    auto = not args.ui
    serve(auto_start=auto, open_browser=not args.no_browser)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
