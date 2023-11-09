def assert_eq2d(a: list, b: list):
    assert len(a) == len(b), f"list length neq: {len(a)} != {len(b)}"
    for i in range(len(a)):
        assert len(a[i]) == len(b[i]), f" At index {i} diff: {a[i]} != {b[i]}"
        for j, x, y in zip(range(len(a[i])), a[i], b[i]):
            assert x == y, f" At index {i}, {j} diff: {x} != {y}"
