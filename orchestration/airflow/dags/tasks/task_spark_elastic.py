from typing import List, Optional
from airflow.operators.bash import BashOperator

class TaskSparkElastic:
    def __init__(
        self,
        task_id: str,
        pipeline_script: str,
        spark_master_url: str = "spark://spark-master:7077",
        conn_id: str = "spark_default",
        extra_args: Optional[List[str]] = None,
    ):
        self.task_id = task_id
        self.pipeline_script = pipeline_script
        self.spark_master_url = spark_master_url
        self.conn_id = conn_id
        self.extra_args = extra_args or []

    def build(self, dag):
        # Build the spark-submit command to be executed inside spark-master
        args_str = " ".join(self.extra_args) if self.extra_args else ""
        
        # Clean up any extra spaces
        submit_cmd = f"spark-submit --master {self.spark_master_url} {args_str} {self.pipeline_script}"
        bash_command = f"docker exec spark-master {submit_cmd.strip()}"

        return BashOperator(
            task_id=self.task_id,
            bash_command=bash_command,
            dag=dag,
        )
