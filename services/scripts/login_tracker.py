import os
import json
import time
import urllib.request
import urllib.parse
from datetime import datetime, timedelta

LOG_FILE = "/data/logs/caddy_access.log"
WEBHOOK_URL = os.environ.get("LOGIN_WEBHOOK")
CACHE_EXPIRY_HOURS = 2

# To store (ip, username) -> last_seen_datetime
alert_cache = {}

def send_slack_alert(ip, username, path):
    if not WEBHOOK_URL:
        print("No LOGIN_WEBHOOK configured.")
        return

    message = f"🚨 *Login Alert* 🚨\nUser `{username}` just logged in from IP `{ip}`.\nRequested path: `{path}`"
    payload = {"text": message}
    data = json.dumps(payload).encode("utf-8")
    
    req = urllib.request.Request(WEBHOOK_URL, data=data, headers={"Content-Type": "application/json"})
    try:
        urllib.request.urlopen(req)
        print(f"[{datetime.now()}] Sent Slack alert for user {username} from {ip}")
    except Exception as e:
        print(f"[{datetime.now()}] Error sending Slack alert: {e}")

def process_log_line(line):
    try:
        log = json.loads(line)
        # Check if basicauth succeeded (Caddy populates user_id)
        if "user_id" in log:
            username = log["user_id"]
            ip = log.get("request", {}).get("remote_ip", "Unknown IP")
            path = log.get("request", {}).get("uri", "/")
            
            # Remove port from IP if present
            if ":" in ip and not ip.startswith("["):
                ip = ip.split(":")[0]

            now = datetime.now()
            cache_key = (ip, username)
            
            if cache_key in alert_cache:
                last_seen = alert_cache[cache_key]
                if now - last_seen < timedelta(hours=CACHE_EXPIRY_HOURS):
                    return # Skip, already alerted recently
            
            # Send alert and update cache
            send_slack_alert(ip, username, path)
            alert_cache[cache_key] = now
            
    except json.JSONDecodeError:
        pass
    except Exception as e:
        print(f"Error processing log line: {e}")

def tail_file(filepath):
    # Wait for file to exist
    while not os.path.exists(filepath):
        time.sleep(1)
        
    with open(filepath, "r") as f:
        # Go to the end of the file
        f.seek(0, 2)
        print(f"[{datetime.now()}] Started tailing {filepath}")
        
        while True:
            line = f.readline()
            if not line:
                time.sleep(0.5)
                continue
            process_log_line(line)

if __name__ == "__main__":
    if not WEBHOOK_URL:
        print("Warning: LOGIN_WEBHOOK environment variable is not set!")
    tail_file(LOG_FILE)
