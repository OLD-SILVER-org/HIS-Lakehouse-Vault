from airflow import DAG
from tasks.task_flink_ingestion import TaskIngestion
from common.dag_config import get_dag_config

with DAG(
    dag_id="Flink_Initial_Load_Batch",
    default_args=get_dag_config(),
    schedule=None,
    catchup=False,
    tags=['batch', 'initial_load']
) as dag:
    
    #job_ct = TaskIngestion("flink_batch_job.HospitalBatchCtJob").build(dag)
    #job_dm = TaskIngestion("flink_batch_job.HospitalBatchDmJob").build(dag)
    job_main = TaskIngestion("flink_batch_job.HospitalBatchJob").build(dag)

    job_main

globals()["Flink_Initial_Load_Batch"] = dag
