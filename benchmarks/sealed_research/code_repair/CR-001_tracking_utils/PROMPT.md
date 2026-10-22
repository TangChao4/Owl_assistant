# CR-001 · 多文件代码修复（Python）

## 目标

修复 `candidate/` 下 **两个文件**，使 `host` 侧独立测试通过。考核的是**可运行代码**，不是文字解释。

## 文件

- `candidate/tracking_metrics.py` — 轨迹误差指标
- `candidate/tracking_utils.py` — 调用 metrics 的批量接口

## 约束

- 仅修改 `candidate/` 内 Python；不得引入网络或读 `/dev/*`。
- 空序列、长度不一致必须 `ValueError`。
- RMSE 定义：\(\sqrt{\frac1n\sum (p_i-a_i)^2}\)，不是 MSE 忘开根号。

## 交付

将修复后的 **整个 `candidate/` 目录** 打包为 tar 或 rsync 到 host 阅卷路径（见封闭考核流程）。不要在同目录放置测试用例或标准答案。
