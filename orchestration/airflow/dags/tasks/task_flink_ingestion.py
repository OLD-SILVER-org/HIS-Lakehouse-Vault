from airflow.operators.python import PythonOperator

class TaskIngestion:
    def __init__(self, job_class):
        self.task_id = f"Run_{job_class.split('.')[-1]}"
        self.job_class = job_class
        self.jar_path = "/opt/flink/jobs/flink-sql-job-1.0.jar"

    def execute_flink_command(self):
        import docker # type: ignore
        client = docker.from_env()
        
        # Lệnh Flink bạn muốn chạy
        command = f"flink run -c {self.job_class} {self.jar_path}"
        print(f"Executing: {command}")
        
        # Gọi lệnh vào thẳng container flink_jobmanager
        container = client.containers.get('flink_jobmanager')
        exit_code, output = container.exec_run(command)
        
        print(output.decode('utf-8'))
        if exit_code != 0:
            raise Exception(f"Flink job failed with exit code {exit_code}")

    def build(self, dag):
        return PythonOperator(
            task_id=self.task_id,
            python_callable=self.execute_flink_command,
            dag=dag,
        )
