# CR-002 · 多文件 Kalman 标量更新（Python）

修复 `candidate/kalman_core.py` 与 `candidate/kalman_runner.py`。

- 预测：\(x \leftarrow x\)，\(P \leftarrow P + Q\)
- 更新：标准标量 Kalman；创新门控 `gate` 为 σ 倍数，超门限则 **不更新** 状态但仍预测

`run_filter(observations, q, r, gate)` 输入 `(z_or_None, dt)` 列表，返回后验均值序列。
