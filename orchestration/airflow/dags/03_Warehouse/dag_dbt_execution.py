from airflow import DAG
from airflow.task.trigger_rule import TriggerRule
from airflow.sensors.time_delta import TimeDeltaSensor
from airflow.operators.trigger_dagrun import TriggerDagRunOperator
from datetime import timedelta
from tasks.task_dbt_execution import TaskDbtExecution
from tasks.task_slack_notification import TaskSlackNotification
from common.dag_config import get_dag_config

with DAG(
    dag_id="dag_dbt_execution",
    default_args=get_dag_config(),
    schedule=None,
    max_active_runs=1,
    catchup=False,
    tags=['dbt','execution']
) as dag:
    job_main = TaskDbtExecution(dbt_command="dbt run", task_id="dbt_run").build(dag)
    job_test = TaskDbtExecution(dbt_command="dbt test", task_id="dbt_test").build(dag)

    notify_success = TaskSlackNotification(task_id="notify_success").build(
        dag=dag,
        message="🚀 DBT Run completed successfully!",
        trigger_rule=TriggerRule.ALL_SUCCESS
    )

    notify_failure = TaskSlackNotification(task_id="notify_failure").build(
        dag=dag,
        message="⚠️ DBT Execution encountered an issue.",
        trigger_rule=TriggerRule.ONE_FAILED
    )

    wait_1p = TimeDeltaSensor(
        task_id="wait_1_minutes",
        delta=timedelta(minutes=1)
    )

    trigger_lake = TriggerDagRunOperator(
        task_id="trigger_lake_streaming",
        trigger_dag_id="dag_lake_streaming",
        wait_for_completion=False
    )

    job_main  >> notify_success >> wait_1p >> trigger_lake
    [job_main] >> notify_failure

globals()["dag_dbt_execution"] = dag
