import pyodbc
import pytest
import yaml


@pytest.fixture(autouse=True)
def get_default_connection():
    with open('../config.yaml', 'r', encoding='utf-8') as f:
        cfg = yaml.full_load(f)['default_data_source']
        return pyodbc.connect(';'.join([f'{k}={v}' for k, v in cfg.items()]), autocommit=True)

@pytest.fixture(autouse=True)
def get_invalid_connection():
    with open('../config.yaml', 'r', encoding='utf-8') as f:
        cfg = yaml.full_load(f)['invalid_data_source']
        return pyodbc.connect(';'.join([f'{k}={v}' for k, v in cfg.items()]), autocommit=True)

@pytest.fixture(autouse=True)
def get_valid_connection():
    with open('../config.yaml', 'r', encoding='utf-8') as f:
        cfg = yaml.full_load(f)['valid_data_source']
        return pyodbc.connect(';'.join([f'{k}={v}' for k, v in cfg.items()]), autocommit=True)
