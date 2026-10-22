from .kalman_core import predict, update


def run_filter(observations, q, r, gate=3.0):
    x, p = 0.0, 1.0
    out = []
    for z, dt in observations:
        # BUG: ignores dt in predict (should scale q)
        x, p = predict(x, p, q)
        x, p, _ = update(x, p, z, r, gate)
        out.append(x)
    return out
