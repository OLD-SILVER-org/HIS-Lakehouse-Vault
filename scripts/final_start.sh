#!/bin/bash
BASE_DIR="/opt/his-lakehouse"
ENV_FILE="$BASE_DIR/.env"

run_compose() {
    local dir=$1
    echo "Starting services in $dir..."
    cd "$BASE_DIR/$dir" && docker compose --env-file "$ENV_FILE" up -d
}

# Start missing/exited services
run_compose "infrastructure/2_lake/hive_metastore"
run_compose "infrastructure/2_lake/trino"
run_compose "infrastructure/2_lake/flink"
run_compose "infrastructure/4_bi"
run_compose "services/network"

# Also try to start Airflow worker if it's still created
docker start airflow-airflow-worker-1 2>/dev/null || true

echo "Final check:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Image}}"
