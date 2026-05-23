import requests
import json,os
from datetime import datetime
from airflow.providers.standard.operators.python import PythonOperator

class TaskSlackNotification:
    """
    Template task for sending results to Slack.
    Can be used as a standalone task or as a callback.
    """
    WEBHOOK_URL = os.getenv("WEBHOOK_URL")

    def __init__(self, task_id="slack_notification"):
        self.task_id = task_id

    def send_slack_message(self, message, status="success", **context):
        dag_id = context.get('dag').dag_id
        now = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        
        icon = "✅" if status == "success" else "🔴"
        title = "Succeeded" if status == "success" else "Failed"

        full_message = f"{message}\n\n" + (
            f"{icon} *DAG {title}*\n"
            f"> *DAG*: `{dag_id}`\n"
            f"> *Finished At*: `{now}`\n"
            f"> *Status*: `{status.capitalize()}`"
        )
        payload = {"text": full_message}
        try:
            response = requests.post(
                self.WEBHOOK_URL,
                data=json.dumps(payload),
                headers={'Content-Type': 'application/json'}
            )
            print(f"Slack response: {response.status_code}")
        except Exception as e:
            print(f"Failed to send Slack message: {e}")

    def build(self, dag, message, status="success", trigger_rule="all_success"):
        """
        Builds the PythonOperator for Airflow.
        """
        return PythonOperator(
            task_id=self.task_id,
            python_callable=self.send_slack_message,
            op_kwargs={'message': message, 'status': status},
            trigger_rule=trigger_rule,
            dag=dag
        )

    @staticmethod
    def notify_failure(context):
        """
        Static method to be used as on_failure_callback in DAG/Task.
        """
        task_instance = context.get('task_instance')
        dag_id = context.get('dag').dag_id
        now = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        
        message = (
            f"🔴 *Task Failed*\n"
            f"> *DAG*: `{dag_id}`\n"
            f"> *Task*: `{task_instance.task_id}`\n"
            f"> *Failed At*: `{now}`\n"
            f"> *Log URL*: <{task_instance.log_url}|View Logs>"
        )
        
        requests.post(TaskSlackNotification.WEBHOOK_URL, json={"text": message})

    @staticmethod
    def notify_success(context):
        """
        Static method to be used as on_success_callback in DAG/Task.
        """
        dag_id = context.get('dag').dag_id
        now = datetime.now().strftime('%Y-%m-%d %H:%M:%S')

        message = (
            f"✅ *DAG Succeeded*\n"
            f"> *DAG*: `{dag_id}`\n"
            f"> *Finished At*: `{now}`\n"
            f"> *Status*: `Success` - All tasks completed successfully!"
        )

        requests.post(TaskSlackNotification.WEBHOOK_URL, json={"text": message})
