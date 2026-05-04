from airflow import DAG
from airflow.task.trigger_rule import TriggerRule
from tasks.task_spark_ingestion import TaskSparkIngestion
from tasks.task_slack_notification import TaskSlackNotification
from common.dag_config import get_dag_config

with DAG(
    dag_id="dag_lake_streaming",
    default_args=get_dag_config(),
    schedule="*/5 * * * *",
    max_active_runs=1,
    catchup=False,
    tags=['lake', 'streaming', 'spark']
) as dag:
    
    spark_load = TaskSparkIngestion(
        python_command="python3 /opt/spark/spark_jobs/silver_staging/streaming/incremental_loader.py",
        task_id="spark_lake_to_staging"
    ).build(dag)

    notify_success = TaskSlackNotification(task_id="notify_success").build(
        dag=dag,
        message="🔄 Spark Streaming (Incremental) completed successfully!",
        trigger_rule=TriggerRule.ALL_SUCCESS
    )

    notify_failure = TaskSlackNotification(task_id="notify_failure").build(
        dag=dag,
        message="🚨 Spark Streaming (Incremental) failed.",
        trigger_rule=TriggerRule.ONE_FAILED
    )

    spark_load >> [notify_success, notify_failure]

globals()["dag_lake_streaming"] = dag
