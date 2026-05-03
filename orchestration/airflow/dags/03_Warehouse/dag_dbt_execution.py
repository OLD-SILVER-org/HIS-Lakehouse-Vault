from airflow import DAG
from airflow.utils.trigger_rule import TriggerRule
from tasks.task_dbt_execution import TaskDbtExecution
from tasks.task_slack_notification import TaskSlackNotification
from common.dag_config import get_dag_config

with DAG(
    dag_id="dag_dbt_execution",
    default_args=get_dag_config(),
    schedule="*/10 * * * *",
    catchup=False,
    tags=['dbt','execution']
) as dag:
    job_main = TaskDbtExecution(dbt_command="dbt run", task_id="dbt_run").build(dag)
    job_test = TaskDbtExecution(dbt_command="dbt test", task_id="dbt_test").build(dag)

    notify_success = TaskSlackNotification(task_id="notify_success").build(
        dag=dag,
        message="🚀 DBT Run & Test completed successfully!",
        trigger_rule=TriggerRule.ALL_SUCCESS
    )

    notify_failure = TaskSlackNotification(task_id="notify_failure").build(
        dag=dag,
        message="⚠️ DBT Execution encountered an issue.",
        trigger_rule=TriggerRule.ONE_FAILED
    )

    job_main >> job_test >> [notify_success, notify_failure]

globals()["dag_dbt_execution"] = dag
