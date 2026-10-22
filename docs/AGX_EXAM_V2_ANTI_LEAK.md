# AGX exam v2 — anti leak / anti rote (320-bank upgrade)

> **Training**: still **gated** until you explicitly order 开始训练.  
> **Frequency**: do **not** lower CPU/GPU base clock to “save power” during eval/train bursts; cap **parallelism** instead.

## Problem with bundled `exam_320`

The USB pack ships **questions + evaluator on the same tree**. That is useful for **demo**, but it enables:

| Risk | Mechanism |
|------|-----------|
| **泄题** | `evaluator_ONLY.jsonl` on the same machine as Ollama / future SFT |
| **背题** | Fixed seed `20261022` + static 320 prompts in git/USB |
| **假高分** | `pilot_320/verified_train.jsonl` shares generators with exam; test prompts can overlap families/groups if seeds reused |
| **Split illusion** | `split=test` in-repo is not a **sealed** test if answers are local |

Package README already warns: move evaluator off-model workspace.

---

## v2 protocol (implemented on host)

Tools: `scripts/agx_exam_v2.py` + `scripts/agx_research/exam_protocol_v2.py`

### 1. Campaign bank (fresh params, new seed)

```bash
python3 ~/owl-agent-line/scripts/agx_exam_v2.py campaign-new \
  --out ~/agx_autotrain/campaigns/20261022_runA \
  --campaign-id 20261022_runA \
  --per-family 40
```

Outputs:

| File | Goes to AGX? |
|------|----------------|
| `questions_AGX_PROMPT_ONLY.jsonl` | **Yes** (for `exam-ask-ollama`) |
| `evaluator_HOST_ONLY.jsonl` | **No** — host/USB vault only |
| `CAMPAIGN_MANIFEST.json` | Host + AGX (metadata only) |

Each campaign derives `seed = SHA256(campaign_id)[:12]` — **not** the demo `20261022` seed alone.

### 2. Model answers on AGX (inference only)

On AGX (one model loaded; performance governor):

```bash
cd ~/AGX_Research_Engineer_V1_20261022
python3 -m agx_research.cli exam-ask-ollama \
  --questions ~/agx_autotrain/inbox/questions_AGX_PROMPT_ONLY.jsonl \
  --output ~/agx_autotrain/ollama_answers/runA_gptoss.jsonl \
  --model gpt-oss:20b --split test --limit 999
```

Copy **answers jsonl only** back to host — never copy evaluator to AGX.

### 3. Grade on host only

```bash
python3 ~/owl-agent-line/scripts/agx_exam_v2.py grade \
  --questions ~/agx_autotrain/campaigns/20261022_runA/questions.jsonl \
  --evaluator ~/agx_autotrain/campaigns/20261022_runA/evaluator_HOST_ONLY.jsonl \
  --predictions ~/agx_autotrain/ollama_answers/runA_gptoss.jsonl \
  --output ~/agx_autotrain/logs/runA_grade.json
```

### 4. Leakage audit before offline SFT

```bash
python3 ~/owl-agent-line/scripts/agx_exam_v2.py leakage-audit \
  --train-jsonl /path/to/verified_train.jsonl \
  --exam-questions ~/agx_autotrain/campaigns/20261022_runA/questions.jsonl
```

Exit code **2** if prompt-hash or `group_id` overlap — **do not train** until fixed.

### 5. AGX tree hygiene

```bash
python3 ~/owl-agent-line/scripts/agx_exam_v2.py agx-tree-check --root ~/agx_autotrain
```

Fails if any `evaluator*.jsonl` exists under the AGX workspace.

---

## Offline training prep (not start)

```bash
bash ~/owl-agent-line/scripts/agx_prepare_autotrain.sh --remote agx
```

Creates `~/agx_autotrain/{campaigns,inbox,logs,ollama_answers}` and `PREP_STATE.json` with `train_allowed: false`.

Unlock only when you export on AGX:

```bash
export AGX_TRAIN_CONFIRM=1   # you say 开始训练 first
```

Then (separate step, not run by prep script):

- LoRA entry: research pack `train/sft_lora.py --dry-run` first  
- **Never** train on `test` split or on prompts that fail `leakage-audit`  
- gpt-oss 20B LoRA: pack notes **Hopper-class** training GPU; Orin AGX inference ≠ train node

---

## Resource rules (基频)

| Do | Don't |
|----|--------|
| `OLLAMA_MAX_LOADED_MODELS=1` | Two 20B-class models resident |
| One exam job at a time | Parallel `exam-ask-ollama` + heavy chat |
| `performance` governor if you already use it | This repo **does not** write powersave or underclock |
| Batch=1, grad accum for future GPU train | Crank threads until thermal throttle drops clocks |

---

## Relation to fixed 320 demo

Keep `outputs/exam_320/` as **regression demo** only. **Score claims** use **campaign-new** banks + host grading.

**Reproduction layer (priority):** `docs/AGX_SEALED_RESEARCH_EXAM.md` — multi-file code, embodied sim, data manifest (host pytest, separate from training).

See also: `docs/AGX_DUAL_MODEL_AND_USB_RESEARCH.md`.
