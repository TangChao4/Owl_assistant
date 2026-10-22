# ER-002 · 2R 平面正运动学复现

实现 `candidate/fk_2r.py` 中 `fk_batch(configs) -> list[tuple[float,float]]`。

输入：`[{"l1":..., "l2":..., "q1_deg":..., "q2_deg":...}, ...]`  
`q2_deg` 为 **相对关节 2** 角；末端角 = q1 + q2。

输出：末端 `(x, y)`，单位与链长一致。
