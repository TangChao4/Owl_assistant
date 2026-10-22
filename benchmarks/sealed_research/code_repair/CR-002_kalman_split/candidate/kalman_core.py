def predict(x, p, q):
    # BUG: forgets process noise on covariance
    return x, p


def update(x, p, z, r, gate):
    if z is None:
        return x, p, False
    s = p + r
    innov = z - x
    if abs(innov) > gate * (s**0.5):
        return x, p, False
    k = p / s
    x = x + k * innov
    p = (1 - k) * p
    return x, p, True
