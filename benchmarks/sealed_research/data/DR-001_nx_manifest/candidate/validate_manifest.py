import re

_SHA = re.compile(r"^[a-f0-9]{64}$")


def validate_manifest(rows):
    errors = []
    seen = set()
    for i, row in enumerate(rows):
        p = row.get("path")
        h = row.get("sha256")
        ts = row.get("captured_at")
        if not p or not h:
            errors.append(f"row{i}: missing path/sha256")
            continue
        # BUG: does not reject .. or absolute paths
        if p in seen:
            errors.append(f"row{i}: duplicate path")
        seen.add(p)
        if not _SHA.match(str(h)):
            errors.append(f"row{i}: bad sha256")
        if not ts:
            errors.append(f"row{i}: missing captured_at")
    return {"ok": not errors, "errors": errors, "record_count": len(rows)}
