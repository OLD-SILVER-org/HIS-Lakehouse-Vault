from airflow import DAG
from tasks.task_flink_ingestion import TaskFlinkIngestion
from common.dag_config import get_dag_config

with DAG(
    dag_id="dag_ingestion_streaming",
    default_args=get_dag_config(),
    schedule=None,
    catchup=False,
    tags=['ingestion', 'streaming']
) as dag:
    
    streaming_job = TaskFlinkIngestion("flink_streaming_job.HospitalStreamingJob").build(dag)

globals()["dag_ingestion_streaming"] = dag
