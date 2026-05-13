#!/bin/bash
set -e

# Automatically find the Python path
PYTHON_EXE=$(which python3 || which python)

ADMIN_USER=${BI_SUPERSET_USER:-superset}
ADMIN_PASS=${BI_SUPERSET_PASS:-superset@123}

echo "===================================================="
echo "STAGING: INITIALIZING SUPERSET"
echo "Python: $PYTHON_EXE"
echo "Admin User: $ADMIN_USER"
echo "===================================================="

# 0. Install Postgres driver and CORS libraries (using system Pip to install into VirtualEnv)
echo "Step 0: Installing Postgres driver and CORS libraries into VirtualEnv..."
pip install --target /app/.venv/lib/python3.10/site-packages psycopg2-binary flask-cors

# 1. Wait for Postgres to be ready
echo "Step 1: Waiting for Postgres (postgres-warehouse:5432)..."
for i in {1..30}; do
  $PYTHON_EXE -c "import socket; s = socket.socket(socket.AF_INET, socket.SOCK_STREAM); s.settimeout(1); s.connect(('postgres-warehouse', 5432))" && break
  echo "Postgres is unavailable - sleeping"
  sleep 1
done

# 2. Automatically create 'superset_metadata' database
echo "Step 2: Checking/Creating database 'superset_metadata'..."
$PYTHON_EXE -c "
import psycopg2
from psycopg2.extensions import ISOLATION_LEVEL_AUTOCOMMIT
try:
    conn = psycopg2.connect(dbname='postgres', user='dwh_admin', password='dwh_admin@123', host='postgres-warehouse', port=5432)
    conn.set_isolation_level(ISOLATION_LEVEL_AUTOCOMMIT)
    cur = conn.cursor()
    cur.execute(\"SELECT 1 FROM pg_catalog.pg_database WHERE datname = 'superset_metadata'\")
    if not cur.fetchone():
        cur.execute('CREATE DATABASE superset_metadata')
        print('SUCCESS: Created database superset_metadata')
    else:
        print('INFO: Database superset_metadata already exists')
    cur.close()
    conn.close()
except Exception as e:
    print(f'ERROR during DB creation: {e}')
"

# 3. Initialize Superset
echo "Step 3: Running DB Upgrade..."
superset db upgrade

echo "Step 4: Creating Admin User ($ADMIN_USER)..."
superset fab create-admin \
              --username "$ADMIN_USER" \
              --firstname "ThanhTinh" \
              --lastname "ThanhTinh" \
              --email "thanhtinh.de@gmail.com" \
              --password "$ADMIN_PASS" || echo "User already exists."

echo "Step 5: Initializing roles..."
superset init

# 4. Start Server
echo "Step 6: Starting Superset Web Server..."
/usr/bin/run-server.sh