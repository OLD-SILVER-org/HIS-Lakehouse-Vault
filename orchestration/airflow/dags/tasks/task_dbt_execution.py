from airflow.providers.standard.operators.python import PythonOperator
class TaskDbtExecution:
    def __init__(self, dbt_command, task_id):
        self.task_id = task_id
        self.dbt_command = dbt_command

    def execute_dbt_command(self):
        import docker # type: ignore
        client = docker.from_env()
        
        # dbt command
        command = f"{self.dbt_command}"
        print(f"Executing: {command}")
        
        # Execute command in dbt container
        container = client.containers.get('dbt-warehouse')
        exit_code, output = container.exec_run(command)
        
        print(output.decode('utf-8'))
        if exit_code != 0:
            raise Exception(f"dbt execution failed with exit code {exit_code}")

    def build(self, dag):
        return PythonOperator(
            task_id=self.task_id,
            python_callable=self.execute_dbt_command,
            dag=dag,
        )
