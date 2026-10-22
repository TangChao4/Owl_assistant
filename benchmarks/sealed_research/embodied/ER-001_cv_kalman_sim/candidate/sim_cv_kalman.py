import math
import random


def run_sim(seed=9001, steps=120):
    rng = random.Random(seed)
    x_true = 0.0
    v = 0.35
    x_est, p = 0.0, 4.0
    q, r, gate = 0.08, 0.9, 3.0
    sq = []
    used = 0
    for _ in range(steps):
        x_true += v + rng.gauss(0, 0.05)
        z = x_true + rng.gauss(0, 0.7) if rng.random() > 0.18 else None
        p = p + q
        if z is not None:
            # BUG: always updates, no gating
            k = p / (p + r)
            x_est = x_est + k * (z - x_est)
            p = (1 - k) * p
            used += 1
        sq.append((x_est - x_true) ** 2)
    rmse = math.sqrt(sum(sq) / len(sq))
    return {"rmse": rmse, "updates_used": used}
