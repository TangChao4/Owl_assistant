# DR-001 · NX 证据清单解析（无硬件）

实现 `candidate/validate_manifest.py`：

```python
def validate_manifest(rows: list[dict]) -> dict:
    """Returns {"ok": bool, "errors": list[str], "record_count": int}"""
```

规则（与 NX 交换协议一致的最小子集）：

- 每条必须有 `path`, `sha256`, `captured_at`（ISO-8601 字符串）
- `sha256` 为 64 位小写 hex
- `path` 不得含 `..` 或以 `/` 开头
- 重复 `path` 报错
