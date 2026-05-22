from airflow import DAG
from airflow.task.trigger_rule import TriggerRule
from airflow.models.baseoperator import cross_downstream
from tasks.task_spark_elastic import TaskSparkElastic
from tasks.task_slack_notification import TaskSlackNotification
from common.dag_config import get_dag_config

SPARK_ARGS = ["--executor-memory", "512m", "--executor-cores", "1", "--total-executor-cores", "1"]

with DAG(
    dag_id="dag_elastic_streaming",
    default_args=get_dag_config(),
    schedule=None,
    catchup=False,
    tags=['elastic', 'streaming', 'spark']
) as dag:

    notify_start = TaskSlackNotification(task_id="notify_start").build(
        dag=dag,
        message="🚀 Elastic Streaming: Initializing all streams (patient, service, staff, treatment)...",
        trigger_rule=TriggerRule.ALL_SUCCESS
    )

    patient_streaming = TaskSparkElastic(
        task_id="spark_elastic_streaming_patient",
        pipeline_script="/opt/spark/spark_jobs/elastic_search/streaming/patient_pipeline_streaming.py",
        extra_args=SPARK_ARGS
    ).build(dag)

    service_streaming = TaskSparkElastic(
        task_id="spark_elastic_streaming_service",
        pipeline_script="/opt/spark/spark_jobs/elastic_search/streaming/service_pipeline_streaming.py",
        extra_args=SPARK_ARGS
    ).build(dag)

    staff_streaming = TaskSparkElastic(
        task_id="spark_elastic_streaming_staff",
        pipeline_script="/opt/spark/spark_jobs/elastic_search/streaming/staff_pipeline_streaming.py",
        extra_args=SPARK_ARGS
    ).build(dag)

    treatment_streaming = TaskSparkElastic(
        task_id="spark_elastic_streaming_treatment",
        pipeline_script="/opt/spark/spark_jobs/elastic_search/streaming/treatment_pipeline_streaming.py",
        extra_args=SPARK_ARGS
    ).build(dag)

    notify_done = TaskSlackNotification(task_id="notify_done").build(
        dag=dag,
        message="🛑 Elastic Streaming: All streams stopped cleanly.",
        trigger_rule=TriggerRule.ALL_SUCCESS
    )

    notify_failure = TaskSlackNotification(task_id="notify_failure").build(
        dag=dag,
        message="🚨 Elastic Streaming: One or more streams FAILED or Crashed!",
        trigger_rule=TriggerRule.ONE_FAILED
    )

    streams = [patient_streaming, service_streaming, staff_streaming, treatment_streaming]

    # notify_start -> all 4 streams in parallel -> notify_done / notify_failure
    notify_start >> streams
    cross_downstream(streams, [notify_done, notify_failure])

globals()["dag_elastic_streaming"] = dag
