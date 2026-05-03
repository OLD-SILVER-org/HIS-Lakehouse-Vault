from airflow import DAG
from airflow.utils.trigger_rule import TriggerRule
from tasks.task_flink_ingestion import TaskFlinkIngestion
from tasks.task_slack_notification import TaskSlackNotification
from common.dag_config import get_dag_config

with DAG(
    dag_id="dag_ingestion_streaming",
    default_args=get_dag_config(),
    schedule=None,
    catchup=False,
    tags=['ingestion', 'streaming']
) as dag:
    
    streaming_job = TaskFlinkIngestion("flink_streaming_job.HospitalStreamingJob").build(dag)

    notify_success = TaskSlackNotification(task_id="notify_success").build(
        dag=dag,
        message="🌊 Flink Streaming Ingestion started successfully!",
        trigger_rule=TriggerRule.ALL_SUCCESS
    )

    notify_failure = TaskSlackNotification(task_id="notify_failure").build(
        dag=dag,
        message="🚨 Flink Streaming Ingestion encountered an error.",
        trigger_rule=TriggerRule.ONE_FAILED
    )

    streaming_job >> [notify_success, notify_failure]

globals()["dag_ingestion_streaming"] = dag
