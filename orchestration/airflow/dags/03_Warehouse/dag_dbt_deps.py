from airflow import DAG
from airflow.utils.trigger_rule import TriggerRule
from tasks.task_dbt_execution import TaskDbtExecution
from tasks.task_slack_notification import TaskSlackNotification
from common.dag_config import get_dag_config

with DAG(
    dag_id="dag_dbt_deps",
    default_args=get_dag_config(),
    schedule=None,
    catchup=False,
    tags=['dbt','deps']
) as dag:
    job_main = TaskDbtExecution(dbt_command="dbt deps", task_id="dbt_deps").build(dag)
    
    notify_success = TaskSlackNotification(task_id="notify_success").build(
        dag=dag,
        message="📦 DBT Dependencies installed successfully!",
        trigger_rule=TriggerRule.ALL_SUCCESS
    )

    notify_failure = TaskSlackNotification(task_id="notify_failure").build(
        dag=dag,
        message="❌ Failed to install DBT Dependencies.",
        trigger_rule=TriggerRule.ONE_FAILED
    )

    job_main >> [notify_success, notify_failure]

globals()["dag_dbt_deps"] = dag
