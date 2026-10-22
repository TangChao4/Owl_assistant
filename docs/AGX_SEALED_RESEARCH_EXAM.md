# Sealed research examination (code · embodied · data)

> **Independent of training.** SFT/LoRA data must not include `host_only/` tests, reference sims, or sealed prompts tied to active campaigns.  
> **Assessment goal:** reproduce **runnable code** and **data-handling** in embodied / robotics-adjacent domains — not numeric JSON trivia alone.

## Task catalog (v1 — host-verified starters)

| ID | Track | What it tests |
|----|--------|----------------|
| **CR-001** | code_repair | 2-file Python tracking RMSE + batch wrapper |
| **CR-002** | code_repair | 2-file scalar Kalman predict/update + gated innovation |
| **ER-001** | embodied_repro | CV + dropout sim; RMSE + update count vs reference |
| **ER-002** | embodied_repro | 2R planar FK (`q2` relative joint) |
| **DR-001** | data_repro | NX-style manifest rows (path/sha256/timebase) |

Manifest: `benchmarks/sealed_research/manifest_tasks.json`

Each bundled **starter** fails host pytest (non-vacuous). AGX receives **PROMPT.md + candidate/** only.

## Commands

```bash
# List
python3 ~/owl-agent-line/scripts/agx_sealed_research.py list

# CI: all starters must fail tests
python3 ~/owl-agent-line/scripts/agx_sealed_research.py selfcheck

# Export for AGX (no host_only)
python3 ~/owl-agent-line/scripts/agx_sealed_research.py export-agx \
  --out ~/agx_autotrain/inbox/sealed_research_v1

# After AGX returns patched candidate/
python3 ~/owl-agent-line/scripts/agx_sealed_research.py verify \
  --task CR-001 --candidate /path/to/candidate
```

## Workflow with numeric exam v2

| Layer | Tool | Purpose |
|-------|------|---------|
| Math JSON bank | `agx_exam_v2.py campaign-new` | Broad reasoning / JSON discipline |
| **Reproduction** | `agx_sealed_research.py` | Multi-file code, sim metrics, data contracts |
| Training gate | `leakage-audit` | No prompt/group overlap before offline train |

## AGX execution policy

- One Ollama model loaded; code tasks use **editor + local Python**, not LLM stdout as submission.
- Run engineering sandbox with `--confirm-sandbox` only in isolated VM when executing untrusted patches.
- Do **not** copy `host_only/` to AGX; do **not** train on sealed prompts.

## Expansion roadmap (priority)

1. More **CR-***: C++ rotation + Python fusion (3-file), build graph fix  
2. More **ER-***: gated Kalman on `science_grid` conditions (import reference metrics)  
3. More **DR-***: time-sync CSV, calibration JSON from NX contract pack  
4. External grader host: optional second machine holds extra hidden seeds for ER sims  

When you order **开始训练**, run `leakage-audit` against both math campaigns and sealed prompt hashes.

See: `docs/AGX_EXAM_V2_ANTI_LEAK.md`, `docs/AGX_DUAL_MODEL_AND_USB_RESEARCH.md`.
