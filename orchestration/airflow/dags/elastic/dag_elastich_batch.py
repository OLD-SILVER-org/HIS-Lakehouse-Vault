from airflow import DAG
from airflow.task.trigger_rule import TriggerRule
from airflow.providers.standard.operators.trigger_dagrun import TriggerDagRunOperator
from tasks.task_spark_elastic import TaskSparkElastic
from tasks.task_slack_notification import TaskSlackNotification
from common.dag_config import get_dag_config

with DAG(
    dag_id="dag_elastich_batch",
    dag_id="dag_elastic_batch",
    default_args=get_dag_config(),
    schedule=None,
    catchup=False,
    tags=['elastic', 'batch', 'spark']
) as dag:
    
    patient_elastich_batch = TaskSparkElastic( task_id="spark_lake_to_elastic_patient",
        pipeline_script="/opt/spark/spark_jobs/elastic_search/batching/patient_pipeline_batch.py",
    ).build(dag)

    service_elastich_batch = TaskSparkElastic( task_id="spark_lake_to_elastic_service",
        pipeline_script="/opt/spark/spark_jobs/elastic_search/batching/service_pipeline_batch.py",
    ).build(dag)

    staff_elastich_batch = TaskSparkElastic( task_id="spark_lake_to_elastic_staff",
        pipeline_script="/opt/spark/spark_jobs/elastic_search/batching/staff_pipeline_batch.py",
    ).build(dag)

    treatment_elastich_batch = TaskSparkElastic( task_id="spark_lake_to_elastic_treatment",
        pipeline_script="/opt/spark/spark_jobs/elastic_search/batching/treatment_pipeline_batch.py",
    ).build(dag)

    notify_success = TaskSlackNotification(task_id="notify_success").build(
        dag=dag,
        message="🚀 Spark Batch (Lake to Elastich) completed successfully!",
        message="🚀 Spark Batch (Lake to Elastic) completed successfully!",
        trigger_rule=TriggerRule.ALL_SUCCESS
    )

    notify_failure = TaskSlackNotification(task_id="notify_failure").build(
        dag=dag,
        message="❌ Spark Batch (Lake to Elastich) failed.",
        message="❌ Spark Batch (Lake to Elastic) failed.",
        trigger_rule=TriggerRule.ONE_FAILED
    )

    patient_elastich_batch >> [notify_success, notify_failure]
    service_elastich_batch >> [notify_success, notify_failure]
    staff_elastich_batch >> [notify_success, notify_failure]
    treatment_elastich_batch >> [notify_success, notify_failure]

globals()["dag_elastich_batch"] = dag
globals()["dag_elastic_batch"] = dag
