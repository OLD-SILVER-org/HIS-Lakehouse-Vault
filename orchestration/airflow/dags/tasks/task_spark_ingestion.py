from airflow.providers.standard.operators.python import PythonOperator

class TaskSparkIngestion:
    def __init__(self, python_command, task_id):
        self.task_id = task_id
        self.python_command = python_command

    def execute_command(self):
        import docker # type: ignore
        client = docker.from_env()
        
        command = f"{self.python_command}"
        print(f"Executing: {command}")
        
        # Call command in Spark container
        container = client.containers.get('spark-master')
        exit_code, output = container.exec_run(command)
        
        print(output.decode('utf-8'))
        if exit_code != 0:
            raise Exception(f"Spark job failed with exit code {exit_code}")

    def build(self, dag):
        return PythonOperator(
            task_id=self.task_id,
            python_callable=self.execute_command,
            dag=dag,
        )
