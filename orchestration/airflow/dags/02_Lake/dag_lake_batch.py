from airflow import DAG
from airflow.utils.trigger_rule import TriggerRule
from airflow.operators.trigger_dagrun import TriggerDagRunOperator
from tasks.task_spark_ingestion import TaskSparkIngestion
from tasks.task_slack_notification import TaskSlackNotification
from common.dag_config import get_dag_config

with DAG(
    dag_id="dag_lake_batch",
    default_args=get_dag_config(),
    schedule=None,
    catchup=False,
    tags=['lake', 'batch', 'spark']
) as dag:
    
    spark_load = TaskSparkIngestion(
        python_command="python3 /opt/spark/spark_jobs/silver_staging/batching/initial_loader.py",
        task_id="spark_lake_to_staging"
    ).build(dag)

    notify_success = TaskSlackNotification(task_id="notify_success").build(
        dag=dag,
        message="🚀 Spark Batch (Lake to Staging) completed successfully!",
        trigger_rule=TriggerRule.ALL_SUCCESS
    )

    notify_failure = TaskSlackNotification(task_id="notify_failure").build(
        dag=dag,
        message="❌ Spark Batch (Lake to Staging) failed.",
        trigger_rule=TriggerRule.ONE_FAILED
    )

    # Trigger the downstream Warehouse (dbt) DAG after successful Spark processing
    trigger_dbt = TriggerDagRunOperator(
        task_id="trigger_dbt_execution",
        trigger_dag_id="dag_dbt_execution",
        wait_for_completion=False
    )

    spark_load >> [notify_success, notify_failure]
    notify_success >> trigger_dbt

globals()["dag_lake_batch"] = dag
