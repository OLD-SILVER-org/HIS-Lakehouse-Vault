# 🚀 System Deployment Guide (Setup Guide)

This document provides detailed instructions on how to set up and operate the entire Hospital Data Warehouse system from scratch.

---

## 1. Prerequisites
- **Operating System:** Linux or WSL2 on Windows is highly recommended.
- **Minimum Hardware:** 16GB+ RAM, 4 Cores+ CPU, 50GB+ Disk space.
- **Tools:** Install Docker Desktop & Docker Compose.
- **Configuration:** Create a `.env` file from `.env.example` and adjust the connection parameters.
- **Docker Compose:** This project uses `docker compose` (V2). If your system only has `docker-compose` (V1), you may need to install the Compose V2 plugin or use an alias: `alias docker-compose='docker compose'`.

---

## 2. Layer-by-Layer Deployment

### Step 1: SOURCE Layer
Create networks and services to capture data changes (CDC) from the Postgres HIS source.
```bash
# Create source network
docker network create source-net

# Launch services (Postgres, Kafka, Debezium)
docker-compose --env-file .env -f infrastructure/1_source/postgres/docker-compose.yml up -d
docker-compose --env-file .env -f infrastructure/1_source/kafka/docker-compose.yml up -d
docker-compose --env-file .env -f infrastructure/1_source/debezium/docker-compose.yml up -d

# Configure Debezium Connector
# Windows:
.\infrastructure\1_source\debezium\send_connector.cmd
# Linux/Bash:
bash infrastructure/1_source/debezium/send_connector.cmd

> [!TIP]
> If you encounter `FATAL: password authentication failed for user "thanhtinh"`, it means the initialization script did not run (common if the `./data` folder already exists). 
> Manually initialize the user and permissions with:
> `docker exec -it postgres_source bash /docker-entrypoint-initdb.d/init-db.sh`
```

### Step 2: LAKE Layer
Set up Iceberg storage infrastructure and processing/query engines.
```bash
# Create lake network
docker network create lake-net

# Deploy storage and metadata services
docker-compose --env-file .env -f infrastructure/2_lake/postgres/docker-compose.yml up -d
docker-compose --env-file .env -f infrastructure/2_lake/minio/docker-compose.yml up -d
docker-compose --env-file .env -f infrastructure/2_lake/hive_metastore/docker-compose.yml up -d
docker-compose --env-file .env -f infrastructure/2_lake/flink/docker-compose.yml up -d
docker-compose --env-file .env -f infrastructure/2_lake/trino/docker-compose.yml up -d
```

> [!IMPORTANT]
> **Hive Metastore Authentication:** Hive 3.1.3 uses an older JDBC driver that does not support SCRAM-SHA-256 (default in Postgres 14+). 
> If you see `authentication type 10 is not supported`, you must manually set the password to `md5` encryption:
> `docker exec -it hive-metastore-db psql -U hive -d hive_metastore -c "SET password_encryption = 'md5'; ALTER USER hive WITH PASSWORD 'hive@123';"`

### Step 3: WAREHOUSE Layer
Process data from Lake to Warehouse using Spark.
```bash
# Create warehouse network
docker network create warehouse-net

# Launch Spark Cluster and Warehouse Postgres
docker-compose --env-file .env -f infrastructure/3_warehouse/spark/docker-compose.yml up -d
docker-compose --env-file .env -f infrastructure/3_warehouse/postgres/docker-compose.yml up -d

# Initialize Staging and Metadata Schemas (Only if containers are already running without schemas; default Docker entrypoint runs these on first launch)
docker exec -it postgres-warehouse psql -U dwh_admin -d dwh -f /docker-entrypoint-initdb.d/create_staging_metadata.sql
docker exec -it postgres-warehouse psql -U dwh_admin -d dwh -f /docker-entrypoint-initdb.d/create_staging.sql
```

### Step 4: DBT Transformation
Build the Data Vault 2.0 model.
```bash
# Run dbt container
docker-compose --env-file .env -f infrastructure/3_warehouse/dbt/docker-compose.yml up -d
```

### Step 5: BI Layer
Launch Apache Superset to build intelligent analytical dashboards.
```bash
docker compose --env-file .env -f infrastructure/4_bi/superset/docker-compose.yml up -d
```

### Step 6: Orchestration Layer
Set up Apache Airflow to schedule and automate the entire pipeline workflow.
```bash
docker-compose --env-file .env -f orchestration/airflow/docker-compose.yml up -d
```

---

## 3. Important Technical Considerations
- **Deployment Order:** Must follow SOURCE -> LAKE -> WAREHOUSE -> BI sequence.
- **Networks:** Ensure all networks are created before starting containers so services can communicate.
- **Resources:** Spark and Flink are memory-intensive; ensure Docker Desktop is allocated sufficient RAM.
- **Database Initialization:** The `init-db.sh` for `postgres_source` only runs automatically if the volume is empty. If reusing data, run it manually using `docker exec` as noted in Step 1.

---

## 4. System Status Check
After setup, you can verify the status of all containers:
```bash
docker ps
```
Ensure all critical services are in `Up (healthy)` status.

---

## 5. Quick Access Links

Once the system is running, you can access the management interfaces via the following links:

| Service | Tool | URL | Credentials |
| :--- | :--- | :--- | :--- |
| **Orchestration** | Airflow UI | [http://localhost:18082](http://localhost:18082) | *Refer to `.env`* |
| **Data Warehouse Docs** | dbt Docs | [http://localhost:8183](http://localhost:8183) | - |
| **Visualization** | Superset UI | [http://localhost:8088](http://localhost:8088) | *Refer to `.env`* |
| **Storage** | MinIO Console | [http://localhost:9001](http://localhost:9001) | *Refer to `.env`* |
| **Processing** | Spark Master | [http://localhost:8085](http://localhost:8085) | - |
| **Query Engine** | Trino UI | [http://localhost:8080](http://localhost:8080) | - |
| **CDC Metadata** | Kafka UI | [http://localhost:8090](http://localhost:8090) | - |
