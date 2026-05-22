from typing import List, Optional
from airflow.operators.bash import BashOperator

class TaskSparkIngestion:
    def __init__(
        self,
        task_id: str,
        pipeline_script: str,
        spark_master_url: str = "spark://spark-master:7077",
        extra_args: Optional[List[str]] = None,
    ):
        self.task_id = task_id
        self.pipeline_script = pipeline_script
        self.spark_master_url = spark_master_url
        self.extra_args = extra_args or []

    def build(self, dag):
        # We use docker exec to run spark-submit inside the spark-master container
        args_str = " ".join(self.extra_args) if self.extra_args else ""
        submit_cmd = f"spark-submit --master {self.spark_master_url} {args_str} {self.pipeline_script}"
        bash_command = f"docker exec spark-master {submit_cmd.strip()}"
        
        return BashOperator(
            task_id=self.task_id,
            bash_command=bash_command,
            dag=dag,
        )
