from airflow import DAG
from tasks.task_flink_ingestion import TaskIngestion
from common.dag_config import get_dag_config

with DAG(
    dag_id="Flink_CDC_Streaming",
    default_args=get_dag_config(),
    schedule=None, 
    catchup=False,
    tags=['streaming', 'cdc']
) as dag:
    
    streaming_job = TaskIngestion("flink_streaming_job.HospitalStreamingJob").build(dag)

globals()["Flink_CDC_Streaming"] = dag
