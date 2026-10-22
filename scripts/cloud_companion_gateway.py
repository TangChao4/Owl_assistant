#!/usr/bin/env python3
"""HTTPS gateway on cloud → SSH reverse tunnels to host Agent + AGX Ollama.

Run on cloud (after host tunnel is up):
  COMPANION_GATEWAY_KEY=... python3 cloud_companion_gateway.py

Upstream (on cloud localhost, from host -R):
  13000 → host Companion :3000
  13001 → AGX Ollama :11434
"""
from __future__ import annotations

import json
import os
import ssl
import sys
import urllib.error
import urllib.request
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from typing import Any

HOST = os.getenv("COMPANION_GATEWAY_HOST", "0.0.0.0")
PORT = int(os.getenv("COMPANION_GATEWAY_PORT", "8443"))
GATE_KEY = (os.getenv("COMPANION_GATEWAY_KEY") or os.getenv("COMPANION_GATEWAY_API_KEY") or "").strip()
UI_UP = (os.getenv("COMPANION_GATEWAY_UI_UPSTREAM") or "http://127.0.0.1:13000").rstrip("/")
LLM_UP = (os.getenv("COMPANION_GATEWAY_LLM_UPSTREAM") or "http://127.0.0.1:13001").rstrip("/")
CERT = os.getenv("COMPANION_GATEWAY_CERT", "/opt/workers/data/runtime/companion_gateway.crt")
KEY = os.getenv("COMPANION_GATEWAY_KEY_FILE", "/opt/workers/data/runtime/companion_gateway.key")


def _auth_ok(handler: BaseHTTPRequestHandler) -> bool:
    if not GATE_KEY:
        return False
    got = handler.headers.get("X-Companion-Gateway-Key") or ""
    auth = handler.headers.get("Authorization") or ""
    if auth.lower().startswith("bearer "):
        got = auth.split(" ", 1)[1].strip()
    return got == GATE_KEY


def _proxy(method: str, upstream_base: str, path: str, headers: dict[str, str], body: bytes | None) -> tuple[int, bytes, dict[str, str]]:
    url = upstream_base + path
    req = urllib.request.Request(url, data=body, method=method)
    skip = {"host", "connection", "content-length", "transfer-encoding"}
    for k, v in headers.items():
        if k.lower() in skip:
            continue
        req.add_header(k, v)
    try:
        with urllib.request.urlopen(req, timeout=120) as resp:
            data = resp.read()
            out_h = {k: v for k, v in resp.headers.items() if k.lower() not in {"transfer-encoding", "connection"}}
            return resp.status, data, out_h
    except urllib.error.HTTPError as e:
        data = e.read()
        return e.code, data, dict(e.headers.items()) if e.headers else {}


class Handler(BaseHTTPRequestHandler):
    def log_message(self, fmt: str, *args: Any) -> None:
        return

    def _json(self, code: int, obj: Any) -> None:
        raw = json.dumps(obj, ensure_ascii=False).encode("utf-8")
        self.send_response(code)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(raw)))
        self.end_headers()
        self.wfile.write(raw)

    def _unauthorized(self) -> None:
        self._json(401, {"error": "unauthorized", "hint": "X-Companion-Gateway-Key or Authorization: Bearer"})

    def do_GET(self) -> None:  # noqa: N802
        if self.path in {"/healthz", "/api/healthz"}:
            ui_ok = llm_ok = False
            try:
                urllib.request.urlopen(UI_UP + "/healthz", timeout=5)
                ui_ok = True
            except Exception:
                pass
            try:
                urllib.request.urlopen(LLM_UP + "/api/tags", timeout=5)
                llm_ok = True
            except Exception:
                pass
            self._json(200, {"ok": ui_ok or llm_ok, "ui_upstream": UI_UP, "llm_upstream": LLM_UP, "ui_ok": ui_ok, "llm_ok": llm_ok})
            return
        if not _auth_ok(self):
            self._unauthorized()
            return
        if self.path.startswith("/v1"):
            code, data, hdrs = _proxy("GET", LLM_UP, self.path, dict(self.headers), None)
        else:
            code, data, hdrs = _proxy("GET", UI_UP, self.path, dict(self.headers), None)
        self.send_response(code)
        for k, v in hdrs.items():
            if k.lower() not in {"content-encoding"}:
                self.send_header(k, v)
        self.end_headers()
        self.wfile.write(data)

    def do_POST(self) -> None:  # noqa: N802
        if not _auth_ok(self):
            self._unauthorized()
            return
        n = int(self.headers.get("Content-Length") or 0)
        body = self.rfile.read(n) if n else b""
        if self.path.startswith("/v1"):
            code, data, hdrs = _proxy("POST", LLM_UP, self.path, dict(self.headers), body)
        else:
            code, data, hdrs = _proxy("POST", UI_UP, self.path, dict(self.headers), body)
        self.send_response(code)
        for k, v in hdrs.items():
            if k.lower() not in {"content-encoding"}:
                self.send_header(k, v)
        self.end_headers()
        self.wfile.write(data)


def main() -> int:
    if not GATE_KEY:
        print("Set COMPANION_GATEWAY_KEY", file=sys.stderr)
        return 2
    httpd = ThreadingHTTPServer((HOST, PORT), Handler)
    if os.getenv("COMPANION_GATEWAY_TLS", "1") != "0":
        if not (os.path.isfile(CERT) and os.path.isfile(KEY)):
            print(f"Missing TLS cert/key: {CERT} {KEY} — run cloud_companion_https_setup.sh or set COMPANION_GATEWAY_TLS=0", file=sys.stderr)
            return 2
        ctx = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
        ctx.load_cert_chain(CERT, KEY)
        httpd.socket = ctx.wrap_socket(httpd.socket, server_side=True)
    print(f"Companion gateway https://{HOST}:{PORT}/ (UI→{UI_UP}, LLM→{LLM_UP}/v1)")
    httpd.serve_forever()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
