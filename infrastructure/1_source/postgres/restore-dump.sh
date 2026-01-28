#!/bin/bash
set -e

# Wait until Postgres is ready (init scripts run when DB is up, but extra caution is good)
echo "Starting restore from /tmp/hospital-source-dump to database $POSTGRES_DB..."

# Use pg_restore for custom format
pg_restore -U "$POSTGRES_USER" -d "$POSTGRES_DB" /tmp/hospital-source-dump

echo "Database restore finished."
