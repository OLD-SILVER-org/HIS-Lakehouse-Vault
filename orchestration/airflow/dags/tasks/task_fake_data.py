from airflow.providers.standard.operators.python import PythonOperator


class TaskFakeData:
    def __init__(self):
        self.task_id = "generate_fake_data"
        self.container_name = "fake_data_script"
        self.command = "python3 /app/src/fake_generator.py"

    def execute_fake_data(self):
        import docker  # type: ignore
        client = docker.from_env()

        container = client.containers.get(self.container_name)

        # Exec command 
        exit_code, output = container.exec_run(self.command)

        print(output.decode('utf-8'))
        if exit_code != 0:
            raise Exception(f'Fake data generation failed with exit code {exit_code}')

    def build(self, dag):
        return PythonOperator(
            task_id=self.task_id,
            python_callable=self.execute_fake_data,
            dag=dag,
        )
