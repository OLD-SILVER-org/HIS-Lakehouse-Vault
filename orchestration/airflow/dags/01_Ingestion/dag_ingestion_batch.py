from airflow import DAG
from airflow.task.trigger_rule import TriggerRule
from tasks.task_flink_ingestion import TaskFlinkIngestion
from tasks.task_slack_notification import TaskSlackNotification
from common.dag_config import get_dag_config

with DAG(
    dag_id="dag_ingestion_batch",
    default_args=get_dag_config(),
    schedule=None,
    catchup=False,
    tags=['ingestion', 'batch']
) as dag:
    
    job_main = TaskFlinkIngestion("flink_batch_job.HospitalBatchJob").build(dag)

    notify_success = TaskSlackNotification(task_id="notify_success").build(
        dag=dag,
        message="✅ Flink Batch Ingestion completed successfully!",
        trigger_rule=TriggerRule.ALL_SUCCESS
    )

    notify_failure = TaskSlackNotification(task_id="notify_failure").build(
        dag=dag,
        message="❌ Flink Batch Ingestion failed.",
        trigger_rule=TriggerRule.ONE_FAILED
    )

    job_main >> [notify_success, notify_failure]

globals()["dag_ingestion_batch"] = dag
