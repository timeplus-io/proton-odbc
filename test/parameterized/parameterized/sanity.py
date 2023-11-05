#!/usr/bin/env python3
import datetime
import decimal

from testflows.core import TestScenario, Given, When, Then
from testflows.core import TE
from utils import PyODBCConnection

@TestScenario
def sanity(self):
    """clickhouse-odbc driver sanity suite to check support of parameterized
    queries using pyodbc connector.
    """
    with PyODBCConnection() as conn:
        with Given("PyODBC connection"):
            def query(query, *args, **kwargs):
                """Execute a query and check that it does not
                raise an exception.
                """
                with When(f"I execute '{query}'", flags=TE):
                    with Then("it works"):
                        conn.query(query, *args, **kwargs)

            with When("I want to do sanity check"):
                query("SELECT 1")

            table_schema = (
                "CREATE STREAM ps (i uint8, ni nullable(uint8), s string, d date, dt datetime, "
                "f float32, dc decimal32(3), fs fixed_string(8))"
            )

            with Given("table", description=f"Table schema {table_schema}", format_description=False):
                query("DROP STREAM IF EXISTS ps", fetch=False)
                query(table_schema, fetch=False)
                try:
                    with When("I want to insert a couple of rows"):
                        query("INSERT INTO ps (* except _tp_time) VALUES (1, NULL, 'Hello, world', '2005-05-05', '2005-05-05 05:05:05', "
                            "1.333, 10.123, 'fstring0')", fetch=False)
                        query("INSERT INTO ps (* except _tp_time) VALUES (2, NULL, 'test', '2019-05-25', '2019-05-25 15:00:00', "
                            "1.433, 11.124, 'fstring1')", fetch=False)
                        query("SELECT (* except _tp_time) FROM ps where _tp_time > earliest_ts() limit 2")

                    with When("I want to select using parameter of type UInt8", flags=TE):
                        query("SELECT (* except _tp_time) FROM ps WHERE i = ? AND _tp_time > earliest_ts() ORDER BY i, s, d LIMIT 1", [1])

                    with When("I want to select using parameter of type Nullable(UInt8)", flags=TE):
                        query("SELECT (* except _tp_time) FROM ps WHERE ni = ? AND _tp_time > earliest_ts() ORDER BY i, s, d LIMIT 1", [None])

                    with When("I want to select using parameter of type String", flags=TE):
                        query("SELECT (* except _tp_time) FROM ps WHERE s = ? AND _tp_time > earliest_ts() ORDER BY i, s, d LIMIT 1", ["Hello, world"])

                    with When("I want to select using parameter of type Date", flags=TE):
                        query("SELECT (* except _tp_time) FROM ps WHERE d = ? AND _tp_time > earliest_ts() ORDER BY i, s, d LIMIT 1", [datetime.date(2019,5,25)])

                    with When("I want to select using parameter of type DateTime", flags=TE):
                        query("SELECT (* except _tp_time) FROM ps WHERE dt = ? AND _tp_time > earliest_ts() ORDER BY i, s, d LIMIT 1", [datetime.datetime(2005, 5, 5, 5, 5, 5)])

                    with When("I want to select using parameter of type Float32", flags=TE):
                        query("SELECT (* except _tp_time) FROM ps WHERE f = ? AND _tp_time > earliest_ts() ORDER BY i, s, d LIMIT 1", [1.333])

                    with When("I want to select using parameter of type Decimal32(3)", flags=TE):
                        query("SELECT (* except _tp_time) FROM ps WHERE dc = ? AND _tp_time > earliest_ts() ORDER BY i, s, d LIMIT 1", [decimal.Decimal('10.123')])

                    with When("I want to select using parameter of type FixedString(8)", flags=TE):
                        query("SELECT (* except _tp_time) FROM ps WHERE fs = ? AND _tp_time > earliest_ts() ORDER BY i, s, d LIMIT 1", [u"fstring0"])

                    with When("I want to select using parameters of type UInt8 and String", flags=TE):
                        query("SELECT (* except _tp_time) FROM ps WHERE i = ? and s = ? and _tp_time > earliest_ts() ORDER BY i, s, d LIMIT 1", [2, "test"])

                    with When("I want to select using parameters of type UInt8, String, and Date", flags=TE):
                        query("SELECT (* except _tp_time) FROM ps WHERE i = ? and s = ? and d = ? and _tp_time > earliest_ts() ORDER BY i, s, d LIMIT 1",
                            [2, "test", datetime.date(2019,5,25)])
                finally:
                    query("DROP STREAM ps", fetch=False)
