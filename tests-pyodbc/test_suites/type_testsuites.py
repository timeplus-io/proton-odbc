import datetime
import decimal
import uuid


def type_test_paramize(stream_suffix: str, type_name: str, input_list: list, expect_output: list = None) -> list:
    input_list = [(item,) for item in input_list]
    if expect_output is None:
        expect_output = input_list
    else:
        expect_output = [(item,) for item in expect_output]
    return [stream_suffix, type_name, input_list, expect_output]


arg_name = ["stream_suffix", "type_name", "input_list", "expect_output"]
args = [
    type_test_paramize("uint8", "uint8", [0, 1, (1 << 7) - 1, (1 << 8) - 1]),
    type_test_paramize("uint16", "uint16", [0, 2, (1 << 15) - 1, (1 << 16) - 1]),
    type_test_paramize("uint32", "uint32", [0, 3, (1 << 31) - 1, (1 << 32) - 1]),
    type_test_paramize("uint64", "uint64", [0, 4, (1 << 63) - 1]),
    type_test_paramize("int8", "int8", [0, 1, (1 << 7) - 1, -(1 << 7)]),
    type_test_paramize("int16", "int16", [0, 2, (1 << 15) - 1, -(1 << 15)]),
    type_test_paramize("int32", "int32", [0, 3, (1 << 31) - 1, -(1 << 31)]),
    type_test_paramize("int64", "int64", [0, 4, (1 << 63) - 1, -(1 << 63)]),
    type_test_paramize("float32", "float32", [0, 1, 3.141592, 1e5 + .1, - (1e5 + .1)]),  # only support 6 decimal digits
    type_test_paramize("float64", "float64", [0, 1, 3.141592, 1e10 + .1, - (1e10 + .1)]),
    # only support 6 decimal digits
    type_test_paramize("date", "date", [
        datetime.date(2023, 1, 1),
        datetime.date(2149, 6, 6)
    ]),
    type_test_paramize("date32", "date32", [
        datetime.date(2023, 1, 1),
        datetime.date(2149, 6, 6)
    ]),
    type_test_paramize("datetime", "datetime", [
        datetime.datetime(2023, 1, 1, 2, 30, 11),
        datetime.datetime(2106, 2, 7, 6, 28, 15)
    ]),
    type_test_paramize("datetime64", "datetime64", [
        datetime.datetime(2023, 1, 1, 2, 30, 11),
        datetime.datetime(2106, 2, 7, 6, 28, 15),
    ]),
    type_test_paramize("decimal", "decimal(10,1)", [
        decimal.Decimal("100000000.1"),
        decimal.Decimal("199999999.9")
    ]),
    type_test_paramize("decimal32", "decimal32(9)", [
        decimal.Decimal("0." + "0" * 8 + "1"),
        decimal.Decimal("0." + "9" * 9)
    ]),
    type_test_paramize("decimal64", "decimal64(18)", [
        decimal.Decimal("0." + "0" * 17 + "1"),
        decimal.Decimal("0." + "9" * 18)
    ]),
    type_test_paramize("decimal128", "decimal128(37)", [
        decimal.Decimal("0." + "0" * 36 + "1"),
        decimal.Decimal("0." + "9" * 37)
    ]),
    type_test_paramize("fixed_string", "fixed_string(9)", ["123456789"]),
    type_test_paramize("string", "string", ["1234567890abcdefghijklmnopqrstuvwxyz", "你好，世界！"]),
    type_test_paramize("uuid", "uuid", [uuid.uuid5(uuid.NAMESPACE_URL, "www.baidu.com")],
                       [uuid.uuid5(uuid.NAMESPACE_URL, "www.baidu.com").__str__()]),
    type_test_paramize("array", "array(string)", ["['1','2','3']"]),
    type_test_paramize("array", "array(int32)", ["[1,2,3]"]),

]
ids = [f"type_test_{param[1]}" for param in args]
