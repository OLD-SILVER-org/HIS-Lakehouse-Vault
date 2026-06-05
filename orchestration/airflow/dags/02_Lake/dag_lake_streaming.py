from airflow import DAG
from airflow.task.trigger_rule import TriggerRule
from airflow.operators.trigger_dagrun import TriggerDagRunOperator
from tasks.task_spark_ingestion import TaskSparkIngestion
from tasks.task_slack_notification import TaskSlackNotification
from common.dag_config import get_dag_config

with DAG(
    dag_id="dag_lake_streaming",
    default_args=get_dag_config(),
    schedule=None,
    max_active_runs=1,
    catchup=False,
    tags=['lake', 'streaming', 'spark']
) as dag:
    
    notify_start = TaskSlackNotification(task_id="notify_start").build(
        dag=dag,
        message="🚀 Spark Streaming (Incremental): Initializing and starting...",
        trigger_rule=TriggerRule.ALL_SUCCESS
    )

    spark_load = TaskSparkIngestion(
        task_id="spark_lake_to_staging",
        pipeline_script="/opt/spark/spark_jobs/silver_staging/streaming/incremental_loader.py",
        extra_args=[
            "--executor-memory", "2g", 
            "--executor-cores", "2", 
            "--total-executor-cores", "2"
        ]
    ).build(dag)

    notify_stopped = TaskSlackNotification(task_id="notify_stopped").build(
        dag=dag,
        message="🛑 Spark Streaming (Incremental): Stopped cleanly.",
        trigger_rule=TriggerRule.ALL_SUCCESS
    )

    notify_failure = TaskSlackNotification(task_id="notify_failure").build(
        dag=dag,
        message="🚨 Spark Streaming (Incremental): FAILED or Crashed!",
        trigger_rule=TriggerRule.ONE_FAILED
    )

    trigger_dbt = TriggerDagRunOperator(
        task_id="trigger_dbt_execution",
        trigger_dag_id="dag_dbt_execution",
        wait_for_completion=False
    )

    notify_start >> spark_load >> [notify_stopped, notify_failure]
    notify_stopped >> trigger_dbt

globals()["dag_lake_streaming"] = dag
