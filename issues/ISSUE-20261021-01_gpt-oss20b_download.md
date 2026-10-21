# ISSUE-20261021-01 gpt-oss:20b download

- **Status**: mitigated (model already in ollama list)
- **Device**: agx (or whichever box deploys 20B)
- **Symptom**: previously downloading / needed resume
- **Verify**: `ollama list` shows `gpt-oss:20b` 13GB
- **Next**: P0 open LAN API; host curl acceptance (see `docs/DEV_PHASE_PLAN.md`)
