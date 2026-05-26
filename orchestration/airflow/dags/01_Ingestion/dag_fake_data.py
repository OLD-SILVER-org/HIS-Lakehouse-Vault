from airflow import DAG
from airflow.task.trigger_rule import TriggerRule
from tasks.task_fake_data import TaskFakeData
from tasks.task_slack_notification import TaskSlackNotification
from common.dag_config import get_dag_config

with DAG(
    dag_id='dag_fake_data_streaming',
    default_args=get_dag_config(),
    schedule='*/1 * * * *',
    catchup=False,
    max_active_runs=1,
    tags=['ingestion', 'fake_data', 'streaming']
) as dag:

    fake_data_job = TaskFakeData().build(dag)

    notify_success = TaskSlackNotification(task_id='notify_success').build(
        dag=dag,
        message='🎭 Fake Data: Generated successfully!',
        trigger_rule=TriggerRule.ALL_SUCCESS
    )

    notify_failure = TaskSlackNotification(task_id='notify_failure').build(
        dag=dag,
        message='🚨 Fake Data: Generation failed!',
        trigger_rule=TriggerRule.ONE_FAILED
    )

    fake_data_job >> [notify_success, notify_failure]

globals()['dag_fake_data_streaming'] = dag
