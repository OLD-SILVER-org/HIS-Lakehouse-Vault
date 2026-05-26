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
docker compose --env-file .env -f infrastructure/1_source/postgres/docker-compose.yml up -d
docker compose --env-file .env -f infrastructure/1_source/kafka/docker-compose.yml up -d
docker compose --env-file .env -f infrastructure/1_source/debezium/docker-compose.yml up -d

# Configure Debezium Connector
# Windows:
.\infrastructure\1_source\debezium\send_connector.cmd
# Linux/Bash:
bash infrastructure/1_source/debezium/send_connector.cmd

```

### Step 2: LAKE Layer
Set up Iceberg storage infrastructure and processing/query engines.
```bash
# Download required JAR dependencies
bash infrastructure/2_lake/jars/download_jars.sh

# Create lake network
docker network create lake-net

# Deploy storage and metadata services
docker compose --env-file .env -f infrastructure/2_lake/postgres/docker-compose.yml up -d
docker compose --env-file .env -f infrastructure/2_lake/minio/docker-compose.yml up -d
docker compose --env-file .env -f infrastructure/2_lake/hive_metastore/docker-compose.yml up -d
docker compose --env-file .env -f infrastructure/2_lake/flink/docker-compose.yml up -d
docker compose --env-file .env -f infrastructure/2_lake/trino/docker-compose.yml up -d

```



### Step 3: WAREHOUSE Layer
Process data from Lake to Warehouse using Spark.
```bash
# Download required JAR dependencies
bash infrastructure/3_warehouse/jars/download_jars.sh

# Create warehouse network
docker network create warehouse-net

# Launch Spark Cluster and Warehouse Postgres
docker compose --env-file .env -f infrastructure/3_warehouse/spark/docker-compose.yml build
docker compose --env-file .env -f infrastructure/3_warehouse/spark/docker-compose.yml up -d

# If you want to increase Spark capacity for concurrent pipelines, scale the Spark worker service:
docker compose --env-file .env -f infrastructure/3_warehouse/spark/docker-compose.yml up --scale spark-worker=2 -d

docker compose --env-file .env -f infrastructure/3_warehouse/postgres/docker-compose.yml up -d

# Initialize Staging and Metadata Schemas (Only if containers are already running without schemas; default Docker entrypoint runs these on first launch)
docker exec -it postgres-warehouse psql -U dwh_admin -d dwh -f /docker-entrypoint-initdb.d/create_staging_metadata.sql
docker exec -it postgres-warehouse psql -U dwh_admin -d dwh -f /docker-entrypoint-initdb.d/create_staging.sql
```

### Step 4: DBT Transformation
Build the Data Vault 2.0 model.
docker compose --env-file .env -f infrastructure/3_warehouse/dbt/docker-compose.yml up -d
```bash
# Run dbt container
docker compose --env-file .env -f infrastructure/3_warehouse/dbt/docker-compose.yml up -d
```

### Step 5: BI Layer
Launch Apache Superset to build intelligent analytical dashboards.
> **Note:** Remember to import the zip files from the `exports` directory into Superset to be able to create the dashboards.

docker compose --env-file .env -f infrastructure/4_bi/superset/docker-compose.yml up -d
```bash
docker compose --env-file .env -f infrastructure/4_bi/superset/docker-compose.yml up -d
```

### Step 6: Orchestration Layer
Set up Apache Airflow to schedule and automate the entire pipeline workflow.
docker compose --env-file .env -f orchestration/airflow/docker-compose.yml up -d
```bash
docker compose --env-file .env -f orchestration/airflow/docker-compose.yml up -d
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
| **VPN/Auth** | WGDashboard | [https://vmi3040316.contaboserver.net](https://vmi3040316.contaboserver.net) | `admin` / `admin` |
| **Orchestration** | Airflow UI | [http://vmi3040316.contaboserver.net:18888](http://vmi3040316.contaboserver.net:18888) | `guest` / `thanhtinh@Pass1` |
| **Visualization** | Superset UI | [http://vmi3040316.contaboserver.net:18088](http://vmi3040316.contaboserver.net:18088) | `guest` / `thanhtinh@Pass1` |
| **Storage** | MinIO Console | [http://vmi3040316.contaboserver.net:19001](http://vmi3040316.contaboserver.net:19001) | `guest` / `thanhtinh@Pass1` |
| **Processing** | Spark Master | [http://vmi3040316.contaboserver.net:18085](http://vmi3040316.contaboserver.net:18085) | `guest` / `thanhtinh@Pass1` |
| **Processing** | Flink UI | [http://vmi3040316.contaboserver.net:8081](http://vmi3040316.contaboserver.net:8081) | `guest` / `thanhtinh@Pass1` |
| **Streaming** | Kafka UI | [http://vmi3040316.contaboserver.net:18090](http://vmi3040316.contaboserver.net:18090) | `guest` / `thanhtinh@Pass1` |
| **Query Engine** | Trino UI | [http://vmi3040316.contaboserver.net:18080](http://vmi3040316.contaboserver.net:18080) | `guest` / `thanhtinh@Pass1` |
| **CDC Metadata** | Kafka UI | [http://localhost:8090](http://localhost:8090) | - |

---

## 6. Troubleshooting

### 6.1. Source PostgreSQL Initialization Fails
If you encounter `FATAL: password authentication failed for user "your_user"`, it means the initialization script did not run (common if the `./data` folder already exists). 
Manually initialize the user and permissions with:
```bash
docker exec -it postgres_source bash /docker-entrypoint-initdb.d/init-db.sh
```

### 6.2. PostgreSQL Authentication (MD5 vs SCRAM-SHA-256)
Older drivers (like Hive 3.1.3's JDBC) do not support the Postgres 14+ default `scram-sha-256`. 
If you see `authentication type 10 is not supported` or `User ... does not have a valid SCRAM secret` in any Postgres container logs, you must switch authentication to `md5`:
1. In `docker-compose.yml`, add `POSTGRES_HOST_AUTH_METHOD: md5` to environment variables and `command: ["postgres", "-c", "password_encryption=md5"]`.
2. **CRITICAL:** If the database `data` folder was already initialized, changing the compose file won't update `pg_hba.conf`. You must manually replace `scram-sha-256` with `md5` in the physical file:
   ```bash
   sed -i 's/scram-sha-256/md5/g' <path-to-postgres-data>/pg_hba.conf
   ```
3. Restart the Postgres container, then reset the user password to generate the md5 hash:
   ```bash
   docker exec -it <postgres-container-name> psql -U <username> -d <database> -c "ALTER USER <username> WITH PASSWORD '<password>';"
   ```

### 6.3. Trino Permission Denied
If Trino fails to start with "Permission denied" on `/var/trino/data`, run:
```bash
sudo chmod -R 777 infrastructure/2_lake/trino/data
```

### 6.4. Airflow Docker Socket Permissions
If Airflow tasks fail with `Permission denied` when calling the Docker API, run:
```bash
sudo chmod 666 /var/run/docker.sock
```

