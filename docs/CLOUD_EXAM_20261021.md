# 云端能力亲自考验报告（2026-10-21 21:13 CST）

主机：`39.96.82.193` · 目录：`/opt/workers` · 开机约 10 天 11 小时 · 内存 7.1Gi（可用 ~4.3Gi）· **无 GPU / :8788 宕**

## 1. 进度快照（probe）

| 项 | 值 |
|----|-----|
| 四环存活 | curriculum / research_net / real_style / tc_autonomous = **true**（已连续跑 ~3 天，PID 未换） |
| 合成图环 | **false**（按设计停刷） |
| 课程 passed | **71/71**，`held_out_fails=[]`，`inject_path_live=false`，anti_leak=v3 |
| 课程环 | cycle **435**，持续 `skipped=no_open_shortfall`（**活着但不涨**） |
| 研究网 | unique_new **28464**，`consecutive_zero_new≈33–34`（近窗几乎无新文献） |
| 真图风格 | checkpoint **n=2643**（≈52.9/100），本周期 `new_this_cycle=0` |
| mobile | 机内监听 `:8765`；**公网 curl 失败**（多半安全组未放行） |
| 边端稿 STATUS | 仍停在 2026-09-23 快照：`awaiting_ceo_review`，≈62% |

## 2. 能力考（`tc_alpha_capability_exam.py`，亲自跑通）

产物：`/opt/workers/data/runtime/companion_services/TC_ALPHA_CAPABILITY_EXAM.json`

| 分数项 | 分 | 解读 |
|--------|-----|------|
| A_chat_local_no_official | 100 | 本地模板聊天可用，未打官方 LLM |
| A_emotion_retrieval | 80 | 情绪检索基本可用，偶有邻域噪声 |
| A_curriculum | 100 | 课表全过 + 防泄门禁过 |
| A_live_exam | **0** | **无现场 live exam 实例** |
| A_hard_deliverables | 100 | 交付物硬门存在性过 |
| A_figure_synth | 100 | 合成图语料达标（已停刷） |
| A_figure_real_style | **52.9** | 真图 2643/5000，未到 60 档 |
| A_drill_local | 100 | |
| TC_v6_18pack | 100 | V6 自测 **18/18 PASS** |
| TC_figure_style_api | 100 | |
| TC_journal_structure | **0** | API 报错 `unhashable type: 'dict'` |
| TC_artifacts_presence | 100 | metrics/figure_data/locks 在 |
| TC_task_pipeline | **11.1** | 任务多停在 paused / awaiting_ceo_review |
| TC_jetson | 100 | secrets/lock 在 |

任务状态抽样：paused×6 · awaiting_ceo_review×6 · completed×2 · failed×1 · …

## 3. 一句话判定

**进程健康，防泄过关，V6 自测全绿；但能力增长面基本停住（课无短板可练、文献近零新增、真图缓增），投稿管线大半等人审，云上无本地大模型推理。**  
云端适合继续当 **M3 后台**；强推理应走 **AGX（M1/M2）**，不要指望云端「越跑越聪明」。

## 4. 建议动作（非今晚必须）

1. P0 已通 AGX → 用 M1 补云端缺的推理。  
2. 打开/修 `journal_structure` 报错（TC 0 分项）。  
3. CEO 清一批 `awaiting_ceo_review`，抬 `TC_task_pipeline`。  
4. 若要公网看 mobile：云安全组放行 **8765**（或只走 SSH 隧道）。  
5. 真图语料：换源或接受 ~53 分，勿再刷合成图充数。
