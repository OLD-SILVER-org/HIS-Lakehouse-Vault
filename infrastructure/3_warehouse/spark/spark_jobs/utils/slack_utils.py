import requests
import json,os

class SlackNotifier:
    """
    Utility class to send notifications to Slack via Webhook.
    Used for Spark jobs monitoring.
    """
    def __init__(self):
        # Use the same Webhook URL as Flink
        self.webhook_url = os.getenv("WEBHOOK_URL")
    def send_message(self, message: str):
        """Sends a text message to the Slack channel."""
        payload = {"text": message}
        try:
            response = requests.post(
                self.webhook_url, 
                data=json.dumps(payload),
                headers={'Content-Type': 'application/json'}
            )
            if response.status_code != 200:
                print(f"[!] Slack returned an error: {response.status_code}, {response.text}")
            return response.status_code
        except Exception as e:
            print(f"[!] Failed to send Slack message: {e}")
            return None

if __name__ == "__main__":
    # Test notification
    notifier = SlackNotifier()
    notifier.send_message("🚀 Test message from Spark SlackNotifier!")
