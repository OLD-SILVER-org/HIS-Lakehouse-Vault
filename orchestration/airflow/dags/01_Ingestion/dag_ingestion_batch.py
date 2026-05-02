from airflow import DAG
from tasks.task_flink_ingestion import TaskFlinkIngestion
from common.dag_config import get_dag_config

with DAG(
    dag_id="dag_ingestion_batch",
    default_args=get_dag_config(),
    schedule=None,
    catchup=False,
    tags=['ingestion', 'batch']
) as dag:
    
    job_main = TaskFlinkIngestion("flink_batch_job.HospitalBatchJob").build(dag)

globals()["dag_ingestion_batch"] = dag
