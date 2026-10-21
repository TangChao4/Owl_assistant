# `/home/ubuntu` 全盘清理候选项（只列举，未删除）

盘点：2026-10-21 · home 约 **630G** · 系统盘可用约 **108G** · U盘 `/media/ubuntu/THIS` 可用约 **702G**（可外移）

回复示例：`删 T1 T2 A1；外移到U盘 J1 J2；论文到essays X1`

---

## 一、强烈建议先清（回收站 / 明显冗余）

| ID | 路径 | 约大小 | 说明 | 建议 |
|----|------|--------|------|------|
| **T1** | `~/.local/share/Trash/files/ANSYS261_LINX64_DISK*.iso`（12 张） | **~99G** | 回收站里的 ANSYS 安装镜像 | **清空回收站该项**（已装则不需要） |
| **T2** | `~/.local/share/Trash/` 其余（视觉、robotic.zip 等） | **~11G** | 回收站其它 | 清空回收站 |
| **T3** | 整份回收站 `~/.local/share/Trash` | **~110G** | =T1+T2 | 一次清空最省事 |

---

## 二、超大安装 / 解压包（有用也可能想挪走）

| ID | 路径 | 约大小 | 说明 | 建议 |
|----|------|--------|------|------|
| **A1** | `~/ansys/ansys_extracted/` | **99G** | ANSYS 解压产物 | 已安装可删解压；或整目录外移 U 盘 |
| **A2** | `~/ansys/_SolidSQUAD_/` | 98M | 安装相关 | 随 A1 |
| **X1** | `~/xyz_soft/dist/OFFLINE_INSTALLERS/` | **24G** | GPW 离线安装包 | 外移 U盘或只留 latest |
| **X2** | `~/xyz_soft/dist/_offline_cache/` | **15G** | 离线缓存 | 可删/外移 |
| **X3** | `~/xyz_soft/dist/PATCHES/` + 大量旧 Patch 目录 | **~6G+** | 重复 patch 版本 | 只留最新，旧的删 |
| **X4** | `~/xyz_soft/dataset_raw/` | 5.9G | 基因数据原始 | 外移或留 |
| **X5** | `~/xyz_soft/results/` | 2.4G | 结果 | 论文相关→essays；否则外移 |
| **J1** | `~/sdk_install/JetPack_7.2_...ORIN_NX...` | **27G** | JetPack 刷机包 | 不刷机可外移 U盘 |
| **J2** | `~/sdk_install/JetPack_6.2.1_...NANO...` | **24G** | Nano 刷机包 | 外移或删其一 |
| **J3** | `~/7.2/`（含 deb/tbz2/SDKM） | **16G** | 又一份 Jetson 7.2 材料 | 与 J1 重复风险，可外移 |
| **J4** | `~/nano-6.2.1/` | **9.1G** | Nano 材料 | 与 J2 重复风险 |
| **J5** | `~/orin_nx_sysroot/` | **13G** | 交叉编译 sysroot | 不用交叉编译可外移 |
| **J6** | `~/JL/`（含 wheels/venv/dist 多份 deploy） | **11G** | Jetson 部署工程 | 旧 `JL/dist/*.tar.gz` 可删重复 |

---

## 三、模型重复（有用，但可精简）

| ID | 路径 | 约大小 | 说明 | 建议 |
|----|------|--------|------|------|
| **M1** | `~/models/hf/Qwen2.5-7B-Instruct` | **15G** | HF 全量 | 与 M2 重复；日常用 GGUF 可删/外移其一 |
| **M2** | `~/AlphaCmd/models/Qwen2.5-7B-Instruct` | **15G** | 又一份 HF | 同上，**只留一份** |
| **M3** | `~/models/gguf/qwen25-7b` Q4+Q5 | 9.5G | 两份量化 | 可只留 **Q5**（或只留 Q4） |
| **M4** | `~/models/gguf/qwen25-14b` | 8.4G | 14B GGUF | AGX 用可外移到 U盘/AGX；本机可删 |
| **M5** | 系统 Ollama `qwen3:8b/14b`（`/usr/share/ollama/...`） | ~14G | 不在 home 但占盘 | 与 GGUF 功能重叠，可择一 |

---

## 四、Cursor / 缓存（会再长出来）

| ID | 路径 | 约大小 | 说明 | 建议 |
|----|------|--------|------|------|
| **C1** | `~/.config/Cursor/User/globalStorage/` | **46G** | Cursor 全局存储 | 可清部分；先备份再清 |
| **C2** | `~/.config/Cursor/snapshots/` | **9.9G** | 快照 | 可清旧快照 |
| **C3** | `~/.config/Cursor/User/workspaceStorage` + History/logs/Cache | ~1.5G | | 可清 |
| **C4** | `~/.cache/` | 2.4G | 通用缓存 | 可清 |
| **C5** | `~/.cursor-server/` | 787M | 远程/服务端 | 慎删 |
| **C6** | `~/snap/` | 1.3G | snap | 可清理旧 revision |

---

## 五、比赛 / 工程压缩包与备份（home 根目录散落）

| ID | 路径 | 约大小 | 说明 | 建议 |
|----|------|--------|------|------|
| **R1** | `~/actual_contest_real_for_simple.zip` | 2.3G | 比赛包 | 已有 `actual_contest/` 则可删 zip |
| **R2** | `~/actual_contest_1006.zip` | 2.1G | | 同上 |
| **R3** | `~/actual_contest.zip` + `actual_contest_20261001.tar.gz` | ~1G | | 同上 |
| **R4** | `~/actual_contest/` 工程目录 | 3.7G | 有用 | 赛后外移 U盘 |
| **R5** | `~/MrZhou.zip` `ri.zip` `ricon_explain.zip` `电机.zip` `机械臂.zip` `9.25.zip` 等 | ~0.8G+ | 根目录散落 zip | 有对应目录则删 zip |
| **R6** | `~/robotic/backups/pre_A00_clutter/` | 大文件在内 | 旧备份 | 可外移/删 |
| **R7** | `~/Jetson_Backup/` | 2.1G | | 外移 U盘 |
| **R8** | `~/桌面/全部备份版本.zip` | 大 | | 外移或删 |
| **R9** | `~/下载/`（WeCom、cubeide、qt.run 等） | **6.0G** | 安装包 | 已安装可删 |

---

## 六、开发环境重复

| ID | 路径 | 约大小 | 说明 | 建议 |
|----|------|--------|------|------|
| **E1** | `~/miniconda3/` | **29G** | conda | 不用的 env 可删 |
| **E2** | `~/Qt5.12.12/` + `下载/qt-....run` | 5.2G+1.4G | Qt | 不用可外移；run 可删 |
| **E3** | `~/STM32/` downloads（cubeide deb/sh、CubeF4/H7 zip） | 大块在 13G 内 | 安装包 | 已装可删 downloads |
| **E4** | `~/UP/`（含 torch wheel、STM32Cube.zip） | 8.2G | | 外移或精简 |
| **E5** | `~/Android/Sdk` | 在 2.3G 内 | | 不用安卓可删 |
| **E6** | `~/atc-stereo/data/public/downloads/*.zip` | >1G×2 | 数据集 zip | 已解压可删 zip |
| **E7** | `~/文档/xwechat_files/` | 3.8G | 微信文件缓存 | 可清旧文件 |
| **E8** | `~/.local/libreoffice/` | 1.2G | 本地 LO | 系统已有则可删 |

---

## 七、建议默认保留（除非你明确要挪）

| 路径 | 大小 | 原因 |
|------|------|------|
| `~/workers/` | 38G | TC 主工程（已清过一轮） |
| `~/owl-agent-line/` | 小 | 开源运维仓 |
| `~/essays/` | 55M | 刚外移的论文包 |
| `~/models/gguf` 至少留一份 7B | | Agent 常驻 |
| `~/AlphaCmd/lora/` | ~1.5G | LoRA 有用 |
| `~/.ssh/` | | 密钥 |

---

## 体积优先级（想先腾空间）

1. **T3 清空回收站** → ~110G  
2. **A1 ANSYS 解压** → ~99G（或外移）  
3. **J1+J2 或 J3+J4** JetPack 重复 → ~30–50G  
4. **X1+X2** xyz 离线包/缓存 → ~39G  
5. **C1+C2** Cursor 存储/快照 → ~56G（慎）  
6. **M1 或 M2** 删一份 HF 7B → 15G  
7. **R1–R3** 比赛 zip → ~5G  

合计理论可回收远超当前 108G 可用空间（部分互斥，按你是否还要用 ANSYS/JetPack 决定）。
