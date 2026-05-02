from datetime import datetime


def get_dag_config() -> dict:
    default_args = {
        "owner": "airflow",

    }
    return default_args
