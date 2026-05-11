import os
import json
import time
import urllib.request
import urllib.parse
from datetime import datetime, timedelta

LOG_FILE = "/data/logs/caddy_access.log"
WEBHOOK_URL = os.environ.get("LOGIN_WEBHOOK")
CACHE_FILE = "/opt/his-lakehouse/services/data/login_cache.json"

SESSION_TIMEOUT_HOURS = 12
IP_COOLDOWN_MINUTES = 10

# To store user data: username -> { "total_logins": int, "last_ip": str, "last_login_time": str, "last_alert_time": str }
user_cache = {}

def load_cache():
    """Load alert cache from file to persist across restarts."""
    global user_cache
    if os.path.exists(CACHE_FILE):
        try:
            with open(CACHE_FILE, 'r') as f:
                user_cache = json.load(f)
        except Exception as e:
            print(f"Error loading cache: {e}")
            user_cache = {}
    else:
        user_cache = {}

def save_cache():
    """Save current cache to a file in services/data."""
    try:
        os.makedirs(os.path.dirname(CACHE_FILE), exist_ok=True)
        with open(CACHE_FILE, 'w') as f:
            json.dump(user_cache, f, indent=4)
    except Exception as e:
        print(f"Error saving cache: {e}")

def send_slack_alert(ip, username, path, total_logins, login_time):
    if not WEBHOOK_URL:
        return

    # Format time for Slack message
    formatted_time = login_time.strftime("%Y-%m-%d %H:%M:%S")
    
    message = (
        f"🚨 *Login Alert* 🚨\n"
        f"👤 User: `{username}`\n"
        f"🌍 IP Address: `{ip}`\n"
        f"🕒 Time: `{formatted_time}`\n"
        f"🔢 Total Logins: `{total_logins}`\n"
        f"📂 Requested path: `{path}`"
    )
    payload = {"text": message}
    data = json.dumps(payload).encode("utf-8")
    
    req = urllib.request.Request(WEBHOOK_URL, data=data, headers={"Content-Type": "application/json"})
    try:
        urllib.request.urlopen(req)
    except Exception as e:
        print(f"Error sending Slack alert: {e}")

def process_log_line(line):
    try:
        log = json.loads(line)
        # Check if basicauth succeeded (Caddy populates user_id, but it's empty "" on failed auth/401)
        if "user_id" in log and log["user_id"].strip():
            username = log["user_id"]
            ip = log.get("request", {}).get("remote_ip", "Unknown IP")
            path = log.get("request", {}).get("uri", "/")
            
            # Remove port from IP if present
            if ":" in ip and not ip.startswith("["):
                ip = ip.split(":")[0]

            now = datetime.now()
            
            # Initialize user in cache if not exists
            if username not in user_cache:
                user_cache[username] = {
                    "total_logins": 0,
                    "last_ip": "",
                    "last_login_time": "1970-01-01T00:00:00",
                    "last_alert_time": "1970-01-01T00:00:00"
                }
                
            user_data = user_cache[username]
            user_data["total_logins"] += 1
            user_data["last_login_time"] = now.isoformat()
            
            last_ip = user_data["last_ip"]
            last_alert_time = datetime.fromisoformat(user_data["last_alert_time"])
            
            should_alert = False
            
            if ip != last_ip:
                # IP changed
                if now - last_alert_time >= timedelta(minutes=IP_COOLDOWN_MINUTES):
                    should_alert = True
            else:
                # IP is the same, but check if it's been a long time
                if now - last_alert_time >= timedelta(hours=SESSION_TIMEOUT_HOURS):
                    should_alert = True
                    
            if should_alert:
                send_slack_alert(ip, username, path, user_data["total_logins"], now)
                user_data["last_alert_time"] = now.isoformat()
            
            # Update last known IP
            user_data["last_ip"] = ip
            
            # Save cache after every successful login
            save_cache()
            
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
    load_cache() # Ensure cache is loaded on startup
    if not WEBHOOK_URL:
        print("Warning: LOGIN_WEBHOOK environment variable is not set!")
    tail_file(LOG_FILE)
