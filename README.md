# Hospital Data Warehouse Project

## Project Groups
The project is divided into 4 main infrastructure groups for distributed deployment on VPS.

### 1. Source (`infrastructure/1_source`)
- **Services**: PostgreSQL (Source DB), Kafka Cluster (KRaft/ZooKeeper), Flink, Debezium.
- **Port Mappings**:
  - Postgres: 5432
  - Kafka: 9092
  - ZooKeeper: 2181

### 2. Lake (`infrastructure/2_lake`)
- **Services**: MinIO (S3 compatible), Hive Metastore.
- **Port Mappings**:
  - MinIO API: 9000
  - MinIO Console: 9001
  - Hive Metastore: 9083

### 3. Warehouse (`infrastructure/3_warehouse`)
- **Services**: Spark Cluster (Master/Worker), DBT.
- **Port Mappings**:
  - Spark Master Web UI: 8080
  - Spark Master: 7077

### 4. BI (`infrastructure/4_bi`)
- **Services**: Apache Superset.
- **Port Mappings**:
  - Superset: 8088

## Directory Structure
- `src/`: Contains source code.
  - `dbt_project`: DBT models for Data Vault and Dimensional Modeling.
  - `spark_jobs`: PySpark/Scala jobs for batch processing.
  - `flink_jobs`: Flink jobs for stream processing.
- `configs/`: Centralized configuration files.
- `scripts/`: Deployment and maintenance scripts.
