import os
import time
import threading
from datetime import datetime
import requests
from flask import Flask, jsonify
from flask_httpauth import HTTPBasicAuth
from werkzeug.security import generate_password_hash, check_password_hash
from dotenv import load_dotenv

# Load environment variables from the service_env.env file
env_path = os.path.join(os.path.dirname(__file__), 'service_env.env')
load_dotenv(dotenv_path=env_path)

WEBHOOK_URL = os.getenv('LOGIN_WEBHOOK')
USER = os.getenv('LOGIN_USER', 'guest')
PASS = os.getenv('LOGIN_PASS')
PASS_HASH = os.getenv('LOGIN_PASS_HASH')

# If a password hash is not supplied, generate one from the plain password (only on first start)
if not PASS_HASH and PASS:
    PASS_HASH = generate_password_hash(PASS)

app = Flask(__name__)
auth = HTTPBasicAuth()

# Basic Auth verification
@auth.verify_password
def verify_password(username, password):
    if username != USER:
        return False
    # If a hash is available, use it; otherwise compare plain password (fallback)
    if PASS_HASH:
        return check_password_hash(PASS_HASH, password)
    return password == PASS

# Simple protected endpoint
@app.route('/protected')
@auth.login_required
def protected():
    return jsonify({
        'message': f'Hello, {auth.current_user()}! You have accessed a protected resource.',
        'timestamp': datetime.utcnow().isoformat() + 'Z'
    })

# ---------------------------------------------------------------------------
# IP monitoring logic
IP_FILE = os.path.join(os.path.dirname(__file__), 'last_ip.txt')

def load_last_ip():
    if os.path.exists(IP_FILE):
        with open(IP_FILE, 'r') as f:
            return f.read().strip()
    return None

def save_last_ip(ip):
    with open(IP_FILE, 'w') as f:
        f.write(ip)

def get_public_ip():
    try:
        # ipify is a simple service returning plain text IP
        resp = requests.get('https://api.ipify.org', timeout=5)
        if resp.status_code == 200:
            return resp.text.strip()
    except Exception as e:
        print(f'[{datetime.now()}] Error fetching public IP: {e}')
    return None

def send_slack_message(message):
    if not WEBHOOK_URL:
        print('Slack webhook URL not configured.')
        return
    payload = {'text': message}
    try:
        r = requests.post(WEBHOOK_URL, json=payload, timeout=5)
        if r.status_code != 200:
            print(f'[{datetime.now()}] Slack webhook returned {r.status_code}: {r.text}')
    except Exception as e:
        print(f'[{datetime.now()}] Error sending Slack message: {e}')

def ip_watcher():
    last_ip = load_last_ip()
    while True:
        current_ip = get_public_ip()
        if current_ip and current_ip != last_ip:
            msg = f'🚨 Public IP changed from {last_ip or "(none)"} to {current_ip} at {datetime.now().isoformat()}'
            send_slack_message(msg)
            save_last_ip(current_ip)
            last_ip = current_ip
        time.sleep(60)  # check every minute

# Start the IP watcher in a background daemon thread
threading.Thread(target=ip_watcher, daemon=True).start()

if __name__ == '__main__':
    print(f'[{datetime.now()}] Starting auth service on 0.0.0.0:5000')
    app.run(host='0.0.0.0', port=5000)
