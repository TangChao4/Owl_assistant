# AGX dual models + USB research pack (no training until you say so)

> Updated: 2026-10-22  
> AGX Ollama (LAN `192.168.90.3:11434`): **`gpt-oss:20b`** + **`deepseek-r1:14b`** (~22GB weights on disk; **run one heavy model at a time** on 32GB).

## USB `workers/` folder (THIS drive)

| File | Role |
|------|------|
| `AGX_训练部署与科研闭环说明.pdf` | One-page loop: deploy boundary, research vs LLM train, NX split |
| `AGX_大型抗假阳性考核手册.pdf` | Anti–false-positive exam rules (320 tasks, canaries, sealed test) |
| `AGX_Research_Engineer_Training_and_Evaluation_V1_20261022.zip` | Full **AGX Research Engineer V1** package (CLI, benchmarks, docs, pilot data; **20B SFT not run**) |

Zip README states: **offline core tested**; **no LoRA/GRPO on your AGX yet**; do not claim real-world paper results from bundled `outputs/*` simulators.

---

## Model routing strategy (after R1 14B on AGX)

| Workload | Model | Where invoked |
|----------|--------|----------------|
| **Chat · 科研同伴** (default) | `gpt-oss:20b` | `COMPANION_MODEL` → host Agent M1 |
| **Plan · 开发计划** / **Docs · 文书** | `deepseek-r1:14b` | `ASSISTANT_MODEL` (reasoning / structure; lower VRAM spike than 20B for long plans) |
| **`/forward agx` heavy infer** | `gpt-oss:20b` | `owl_bridge.forward_to_agx` (default; agentic + long context) |
| **M2 one-shot SSH** | `gpt-oss:20b` (override) | `AGX_MODEL=… bash scripts/agx_m2_run.sh` |
| **Host light Q&A** (AGX down) | `qwen3:8b` / `qwen3:14b` | `COMPANION_LOCAL_LLM_BASE=http://127.0.0.1:11434/v1` |
| **Cloud M3** | *(no LLM)* | SSH supervise only |

Host secrets (not in git):

```bash
COMPANION_LOCAL_LLM_BASE=http://192.168.90.3:11434/v1
COMPANION_MODEL=gpt-oss:20b
ASSISTANT_MODEL=deepseek-r1:14b
```

Restart Agent after changing secrets: `bash ~/owl-agent-line/scripts/host_offline_agent.sh`

### Research pack Ollama calls (on AGX, when you stage the zip)

| CLI use | Suggested model | Why |
|---------|-----------------|-----|
| `propose` (unverified algorithm memo) | `gpt-oss:20b` | Long structured research write-up |
| `model_eval.run` (320 JSON math answers, `temperature=0`) | Try **both**; keep **separate output files** | R1 may emit reasoning before JSON — grading counts invalid JSON as fail; compare fairly on same split |
| Future **LoRA/SFT** (`train/sft_lora.py`) | `gpt-oss:20b` base | Pack design target — **blocked until you explicitly order training** |

**Hard rule:** same as pack `00_部署与交付边界.md` — **R0–R2** (doctor, canary, sealed exam) allowed; **R3+ training** only after your go-ahead.

---

## Exam v2 (anti leak / rote)

Fixed USB `exam_320` is **demo-only**. Production scoring: `docs/AGX_EXAM_V2_ANTI_LEAK.md` + `scripts/agx_exam_v2.py`.

## Staging the zip (read-only; no train)

```bash
bash ~/owl-agent-line/scripts/usb_agx_research_stage.sh
# On AGX after rsync/scp of staged tree:
cd ~/AGX_Research_Engineer_V1_20261022
python3 -m agx_research.cli doctor
python -m agx_research.cli canary-audit --output outputs/my_canaries.json
# Do NOT run train/sft_lora or science-test-once twice on same project without new protocol.
```

---

## Memory discipline on AGX 32G

- Prefer **one** of `{gpt-oss:20b, deepseek-r1:14b}` loaded for a long session (`ollama ps`).
- Plan on R1 while a 20B generate is running → risk OOM; serialize heavy jobs.
- Do **not** add a third 20B-class model on AGX without unloading the others.

---

## Release gates (from USB pack; unchanged)

| Gate | Meaning |
|------|---------|
| R0 | Files + hash + CLI |
| R1 | Ollama reachable (**you are here** for both models) |
| R2 | Verified dataset + external sealed grading |
| R3 | GPU LoRA on gpt-oss |
| R4–R6 | AGX eval uplift, NX real data, paper audit |

**Training type B (LLM fine-tune)** stays **off** until you say “开始训练”.
