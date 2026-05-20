from typing import List, Optional

from airflow.providers.standard.operators.python import PythonOperator


class TaskSparkElastic:
    def __init__(
        self,
        task_id: str,
        pipeline_script: str,
        spark_master_url: str = "spark://spark-master:7077",
        spark_container: str = "spark-master",
        extra_args: Optional[List[str]] = None,
    ):
        self.task_id = task_id
        self.pipeline_script = pipeline_script
        self.spark_master_url = spark_master_url
        self.spark_container = spark_container
        self.extra_args = extra_args or []

    def build_submit_command(self) -> str:
        args = " ".join(self.extra_args)
        command = (
            f"spark-submit --master {self.spark_master_url} {self.pipeline_script} {args}".strip()
        )
        return command

    def execute_command(self):
        import docker  # type: ignore

        client = docker.from_env()
        command = self.build_submit_command()

        container = client.containers.get(self.spark_container)
        exit_code, output = container.exec_run(command)

        if exit_code != 0:
            raise Exception(
                f"Spark job '{self.task_id}' failed in container '{self.spark_container}' "
                f"with exit code {exit_code}: {output.decode('utf-8', errors='ignore')}"
            )

        return output.decode('utf-8', errors='ignore')

    def build(self, dag):
        return PythonOperator(
            task_id=self.task_id,
            python_callable=self.execute_command,
            dag=dag,
        )
