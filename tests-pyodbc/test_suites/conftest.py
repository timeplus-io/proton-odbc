import pyodbc
import pytest
import yaml


@pytest.fixture(autouse=True)
def get_connection():
    with open('../config.yaml', 'r', encoding='utf-8') as f:
        cfg = yaml.full_load(f)['data_source']
        return pyodbc.connect(';'.join([f'{k}={v}' for k, v in cfg.items()]), autocommit=True)
