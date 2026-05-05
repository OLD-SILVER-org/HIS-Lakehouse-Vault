# 🏥 Hospital Data Warehouse System

This project builds a modern Data Warehouse system for a hospital, applying the **Medallion Architecture** combined with **Data Vault 2.0**. The system supports real-time data processing (Real-time CDC) and batch processing to provide intelligent business intelligence (BI) reports.

---

## 🏗️ System Architecture

![System Architecture](images/system/system_architecture.png)

The system is designed with a distributed model, divided into 4 main layers:

### 🚀 Data Processing Strategy

The system operates on a hybrid processing model to ensure both speed and consistency:
*   **Real-time Streaming (CDC)**: Changes from the Source DB are captured by Debezium, streamed through Kafka, and processed by **Apache Flink** into the Iceberg Lake in near real-time.
*   **Batch & Incremental Processing**: **Apache Spark** periodically transforms and moves data from the Lake into the Warehouse using **dbt**, building a robust Data Vault 2.0 structure.
*   **Unified Querying**: **Trino** provides a high-performance SQL engine to query data directly across the Lake and Warehouse without data movement.

---

## 🛠️ Tech Stack

| Component | Technology | Purpose |
| :--- | :--- | :--- |
| **Ingestion** | Debezium, Kafka | CDC data from source systems (HIS) |
| **Stream Processing** | Apache Flink | Ingest data from Kafka into Iceberg Tables |
| **Storage (Data Lake)** | Apache Iceberg, MinIO | High-performance table storage with ACID support |
| **Data Processing** | Apache Spark | Data processing (Batch & Incremental) from Lake to Warehouse |
| **Transformation** | dbt (data build tool) | Build Data Vault 2.0 & Dimensional Models |
| **Query Engine** | Trino | Direct querying on Data Lake |
| **Orchestration** | Apache Airflow | Pipeline scheduling and workflow management |
| **Visualization** | Apache Superset | Operational & Financial BI Dashboards |

---

## 📂 Project Structure

```text
HOSPITAL_DWH/
├── infrastructure/           # Docker Compose setup for each cluster
│   ├── 1_source/             # Source DB, Kafka, Debezium
│   ├── 2_lake/               # Flink, MinIO, Hive Metastore, Trino
│   ├── 3_warehouse/          # Spark, dbt, Warehouse Postgres
│   └── 4_bi/                 # Apache Superset
├── orchestration/            # Airflow DAGs and Tasks
│   └── airflow/
│       └── dags/
│           ├── 01_Ingestion/ # CDC & Flink Pipelines
│           ├── 02_Lake/      # Data Lake Processing Pipelines
│           └── 03_Warehouse/ # Spark & dbt Pipelines
├── docs/                     # Detailed documentation
├── .env                      # Environment configuration
└── README.md                 # This file
```

---

## 🚀 Deployment

To deploy the system, please refer to the step-by-step detailed guide here:

👉 **[Detailed Setup Guide](docs/setup_guide.md)**

---

## 🔗 Quick Access Links

Once the system is running, you can access the management interfaces via the following links:

| Service | Tool | URL | Credentials |
| :--- | :--- | :--- | :--- |
| **Orchestration** | Airflow UI | [http://localhost:18082](http://localhost:18082) | *Refer to `.env`* |
| **Visualization** | Superset UI | [http://localhost:8088](http://localhost:8088) | *Refer to `.env`* |
| **Storage** | MinIO Console | [http://localhost:9001](http://localhost:9001) | *Refer to `.env`* |
| **Processing** | Spark Master | [http://localhost:8085](http://localhost:8085) | - |
| **Query Engine** | Trino UI | [http://localhost:8080](http://localhost:8080) | - |
| **CDC Metadata** | Kafka UI | [http://localhost:8090](http://localhost:8090) | - |

---

## 🛠️ Additional Technical Documents
*(Updating...)*

---

## 📊 Data Modeling

The system implements the **Data Vault 2.0** methodology in the Warehouse layer to ensure scalability and historical data tracking:
- **Raw Vault**: Hubs, Links, Satellites (Raw storage from source).
- **Business Vault**: Applied hospital business logic.
- **Data Mart**: Star Schema (Fact & Dimension) for BI reporting.

---

## 📝 Contact
- **Project Lead**: Nguyễn Thanh Tính
- **Email**: thanhtinh.de@gmail.com
- **Version**: 1.0.0
