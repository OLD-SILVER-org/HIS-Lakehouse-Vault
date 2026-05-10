#!/bin/bash

# Script to restart all HIS Lakehouse services in order
BASE_DIR="/opt/his-lakehouse"
ENV_FILE="$BASE_DIR/.env"

echo "Force stopping and removing all containers..."
docker rm -f $(docker ps -a -q) 2>/dev/null || true

echo "Pruning system to clear defunct networks/volumes (be careful)..."
docker network prune -f

echo "Creating external networks..."
docker network create source-net || true
docker network create lake-net || true
docker network create warehouse-net || true
docker network create serving-net || true
docker network create monitoring-net || true

# Function to run docker compose with env file
run_compose() {
    local dir=$1
    echo "Starting services in $dir..."
    cd "$BASE_DIR/$dir" && docker compose --env-file "$ENV_FILE" up -d
}

# 1. Source
run_compose "infrastructure/1_source/postgres"
run_compose "infrastructure/1_source/kafka"
run_compose "infrastructure/1_source/debezium"
sleep 10

# 2. Lake
run_compose "infrastructure/2_lake/postgres"
run_compose "infrastructure/2_lake/minio"
sleep 10
run_compose "infrastructure/2_lake/hive_metastore"
run_compose "infrastructure/2_lake/trino"
run_compose "infrastructure/2_lake/flink"
sleep 10

# 3. Warehouse
run_compose "infrastructure/3_warehouse/postgres"
run_compose "infrastructure/3_warehouse/spark"
sleep 10

# 4. BI
run_compose "infrastructure/4_bi"
sleep 5

# 5. Orchestration
run_compose "orchestration/airflow"
sleep 10

# 6. Network
run_compose "services/network"

echo "System status:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Image}}"
