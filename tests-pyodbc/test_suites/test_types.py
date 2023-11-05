import time

import pyodbc
import pytest

import type_testsuites as type_t
import utils


class TestType:
    @pytest.mark.parametrize(type_t.arg_name, type_t.args, ids=type_t.ids)
    def test_type(self,
                  get_connection: pyodbc.Connection,
                  stream_suffix: str,
                  type_name: str,
                  input_list: list,
                  expect_output: list):
        with get_connection as conn:
            with conn.cursor() as cursor:
                cursor.execute(f"drop stream if exists `test_{stream_suffix}`")
                cursor.execute(f"create stream `test_{stream_suffix}` (`x` {type_name})")
                cursor.executemany(f"insert into `test_{stream_suffix}` (`x`) values (?)", input_list)
                result = cursor.execute(f"select x from `test_{stream_suffix}` where _tp_time > earliest_ts() limit {len(input_list)}").fetchall()
                #cursor.execute(f"drop stream if exists `test_{stream_suffix}`")
                utils.assert_eq2d(expect_output, result)
