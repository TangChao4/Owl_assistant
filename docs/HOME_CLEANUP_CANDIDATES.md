# `/home/ubuntu` Full-Disk Cleanup Candidates (list only; nothing deleted)

Inventory: 2026-10-21 · home ~ **630G** · system disk free ~ **108G** · USB `/media/ubuntu/THIS` free ~ **702G** (can offload)

Reply example: `delete T1 T2 A1; offload to USB J1 J2; papers to essays X1`

---

## 1. Strongly clear first (Trash / obvious redundancy)

| ID | Path | Approx size | Notes | Suggestion |
|----|------|-------------|-------|------------|
| **T1** | `~/.local/share/Trash/files/ANSYS261_LINX64_DISK*.iso` (12 discs) | **~99G** | ANSYS install ISOs in Trash | **Empty that Trash item** (not needed if already installed) |
| **T2** | `~/.local/share/Trash/` rest (vision, robotic.zip, etc.) | **~11G** | other Trash | empty Trash |
| **T3** | whole Trash `~/.local/share/Trash` | **~110G** | =T1+T2 | one empty is simplest |

---

## 2. Huge install / extract trees (useful, but may want to move)

| ID | Path | Approx size | Notes | Suggestion |
|----|------|-------------|-------|------------|
| **A1** | `~/ansys/ansys_extracted/` | **99G** | ANSYS extract output | if installed, delete extract; or offload whole dir to USB |
| **A2** | `~/ansys/_SolidSQUAD_/` | 98M | install-related | follow A1 |
| **X1** | `~/xyz_soft/dist/OFFLINE_INSTALLERS/` | **24G** | GPW offline installers | offload USB or keep latest only |
| **X2** | `~/xyz_soft/dist/_offline_cache/` | **15G** | offline cache | delete / offload OK |
| **X3** | `~/xyz_soft/dist/PATCHES/` + many old Patch dirs | **~6G+** | duplicate patch versions | keep newest; delete old |
| **X4** | `~/xyz_soft/dataset_raw/` | 5.9G | gene data raw | offload or keep |
| **X5** | `~/xyz_soft/results/` | 2.4G | results | paper-related → essays; else offload |
| **J1** | `~/sdk_install/JetPack_7.2_...ORIN_NX...` | **27G** | JetPack flash pack | if not flashing, offload USB |
| **J2** | `~/sdk_install/JetPack_6.2.1_...NANO...` | **24G** | Nano flash pack | offload or delete one |
| **J3** | `~/7.2/` (deb/tbz2/SDKM) | **16G** | another Jetson 7.2 tree | likely duplicates J1; offload OK |
| **J4** | `~/nano-6.2.1/` | **9.1G** | Nano materials | likely duplicates J2 |
| **J5** | `~/orin_nx_sysroot/` | **13G** | cross-compile sysroot | offload if unused |
| **J6** | `~/JL/` (wheels/venv/dist multi deploy) | **11G** | Jetson deploy project | old `JL/dist/*.tar.gz` duplicates deletable |

---

## 3. Duplicate models (useful, but can trim)

| ID | Path | Approx size | Notes | Suggestion |
|----|------|-------------|-------|------------|
| **MD1** | `~/models/hf/Qwen2.5-7B-Instruct` | **15G** | full HF | duplicates MD2; daily GGUF → delete/offload one |
| **MD2** | `~/AlphaCmd/models/Qwen2.5-7B-Instruct` | **15G** | another HF copy | same; **keep only one** |
| **MD3** | `~/models/gguf/qwen25-7b` Q4+Q5 | 9.5G | two quants | keep **Q5** only (or Q4 only) |
| **MD4** | `~/models/gguf/qwen25-14b` | 8.4G | 14B GGUF | if for AGX, offload to USB/AGX; host may delete |
| **MD5** | system Ollama `qwen3:8b/14b` (`/usr/share/ollama/...`) | ~14G | not under home but uses disk | overlaps GGUF; pick one |

---

## 4. Cursor / caches (will grow back)

| ID | Path | Approx size | Notes | Suggestion |
|----|------|-------------|-------|------------|
| **C1** | `~/.config/Cursor/User/globalStorage/` | **46G** | Cursor global storage | can prune; backup first |
| **C2** | `~/.config/Cursor/snapshots/` | **9.9G** | snapshots | clear old snapshots |
| **C3** | `~/.config/Cursor/User/workspaceStorage` + History/logs/Cache | ~1.5G | | clearable |
| **C4** | `~/.cache/` | 2.4G | general cache | clearable |
| **C5** | `~/.cursor-server/` | 787M | remote/server | delete with care |
| **C6** | `~/snap/` | 1.3G | snap | can prune old revisions |

---

## 5. Contest / project archives and backups (scattered under home root)

| ID | Path | Approx size | Notes | Suggestion |
|----|------|-------------|-------|------------|
| **R1** | `~/actual_contest_real_for_simple.zip` | 2.3G | contest pack | if `actual_contest/` exists, delete zip |
| **R2** | `~/actual_contest_1006.zip` | 2.1G | | same |
| **R3** | `~/actual_contest.zip` + `actual_contest_20261001.tar.gz` | ~1G | | same |
| **R4** | `~/actual_contest/` project dir | 3.7G | useful | after contest, offload USB |
| **R5** | `~/MrZhou.zip` `ri.zip` `ricon_explain.zip` motor.zip / robot-arm.zip (Chinese filenames on disk) `9.25.zip` etc. | ~0.8G+ | scattered root zips | delete zip if matching dir exists |
| **R6** | `~/robotic/backups/pre_A00_clutter/` | large files inside | old backup | offload/delete OK |
| **R7** | `~/Jetson_Backup/` | 2.1G | | offload USB |
| **R8** | `~/Desktop/all-backup-versions.zip` (Chinese Desktop path on disk) | large | | offload or delete |
| **R9** | `~/Downloads/` (WeCom, cubeide, qt.run, etc.; Chinese Downloads path on disk) | **6.0G** | installers | delete if already installed |

---

## 6. Duplicate / heavy dev environments

| ID | Path | Approx size | Notes | Suggestion |
|----|------|-------------|-------|------------|
| **E1** | `~/miniconda3/` | **29G** | conda | delete unused envs |
| **E2** | `~/Qt5.12.12/` + Downloads `qt-....run` | 5.2G+1.4G | Qt | offload if unused; delete .run |
| **E3** | `~/STM32/` downloads (cubeide deb/sh, CubeF4/H7 zip) | large within 13G | installers | delete downloads if installed |
| **E4** | `~/UP/` (torch wheel, STM32Cube.zip) | 8.2G | | offload or trim |
| **E5** | `~/Android/Sdk` | within 2.3G | | delete if no Android |
| **E6** | `~/atc-stereo/data/public/downloads/*.zip` | >1G×2 | dataset zips | delete zip after extract |
| **E7** | `~/Documents/xwechat_files/` (Chinese Documents path on disk) | 3.8G | WeChat file cache | clear old files |
| **E8** | `~/.local/libreoffice/` | 1.2G | local LO | delete if system LO exists |

---

## 7. Prefer keep by default (unless you explicitly move)

| Path | Size | Reason |
|------|------|--------|
| `~/workers/` | 38G | TC main project (already cleaned once) |
| `~/owl-agent-line/` | small | open-source ops repo |
| `~/essays/` | 55M | recently offloaded paper packs |
| `~/models/gguf` keep at least one 7B | | Agent resident |
| `~/AlphaCmd/lora/` | ~1.5G | useful LoRA |
| `~/.ssh/` | | keys |

---

## Size priority (free space first)

1. **T3 empty Trash** → ~110G  
2. **A1 ANSYS extract** → ~99G (or offload)  
3. **J1+J2 or J3+J4** JetPack duplicates → ~30–50G  
4. **X1+X2** xyz offline packs/cache → ~39G  
5. **C1+C2** Cursor storage/snapshots → ~56G (careful)  
6. **MD1 or MD2** delete one HF 7B → 15G  
7. **R1–R3** contest zips → ~5G  

Theoretical reclaim far exceeds current 108G free (some mutually exclusive; depends on whether you still need ANSYS/JetPack).
