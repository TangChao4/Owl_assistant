import math


def fk_batch(configs):
    out = []
    for c in configs:
        l1, l2 = float(c["l1"]), float(c["l2"])
        t1 = math.radians(float(c["q1_deg"]))
        # BUG: treats q2 as absolute world angle
        t2 = math.radians(float(c["q2_deg"]))
        x = l1 * math.cos(t1) + l2 * math.cos(t2)
        y = l1 * math.sin(t1) + l2 * math.sin(t2)
        out.append((x, y))
    return out
