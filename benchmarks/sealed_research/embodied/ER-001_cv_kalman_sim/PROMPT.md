# ER-001 · 具身算法复现（仿真）

在 `candidate/sim_cv_kalman.py` 实现 `run_sim(seed, steps) -> dict`：

- 生成带 dropout 的 1D 观测（常速度真值 + 噪声）
- 使用 **带创新门控** 的标量 Kalman（与 CR-002 语义一致）
- 返回 `{"rmse": float, "updates_used": int}`

Host 将在固定 seed 上与参考实现比对 RMSE（相对误差 ≤ 1%）且 `updates_used` 完全一致。
