from airflow import DAG
from tasks.task_spark_ingestion import TaskSparkIngestion
from common.dag_config import get_dag_config

with DAG(
    dag_id="dag_lake_streaming",
    default_args=get_dag_config(),
    schedule=None,
    catchup=False,
    tags=['lake', 'streaming', 'spark']
) as dag:
    
    # Task dùng Spark nạp dữ liệu từ Lake sang Staging
    spark_load = TaskSparkIngestion(
        python_command="python3 /opt/spark/spark_jobs/silver_staging/streaming/incremental_loader.py",
        task_id="spark_lake_to_staging"
    ).build(dag)

    spark_load

globals()["dag_lake_streaming"] = dag
