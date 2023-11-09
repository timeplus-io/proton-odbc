import pyodbc
import pytest


class TestGrant:
    def test_invalid(self, get_invalid_connection: pyodbc.Connection):
        with pytest.raises(pyodbc.Error) as auth_err:
            with get_invalid_connection as conn:
                with conn.cursor() as cursor:
                    cursor.execute("select 1")
        assert 'Authentication failed' in str(auth_err.value)
