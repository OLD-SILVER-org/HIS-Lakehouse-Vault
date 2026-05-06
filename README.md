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

The system is fully containerized and easy to deploy. Please refer to the step-by-step detailed guide for installation, operation, and access links:

👉 **[Detailed Setup Guide](docs/setup_guide.md)**

---

## 🛠️ Additional Technical Documents
- [**Data Vault 2.0 Documents**](docs/modeling/data_vault_documents.md): Detailed Hub/Link/Sat design for hospital data.

---

## 📊 Data Modeling

The system implements the **Data Vault 2.0** methodology in the Warehouse layer to ensure scalability and historical data tracking:
- **Raw Vault**: Hubs, Links, Satellites (Raw storage from source).
- **Business Vault**: Applied hospital business logic.
- **Data Mart**: Star Schema (Fact & Dimension) for BI reporting.

---

## 🖼️ System Showcases

### 1. Data Lineage & Modeling (dbt)
The system architecture follows the **Data Vault 2.0** methodology, ensuring high scalability and historical auditability. Below is a focused lineage of the **Financial Fact** flow:

![Data Vault Lineage](images/system/lineage_graph_fact_thanh_toan.png)

👉 **[Explore Interactive Lineage & Documentation](http://localhost:8183/)**

*   **Detailed Modeling Docs**: See [Data Vault 2.0 Documents](docs/modeling/data_vault_documents.md) for entity definitions.

### 2. Business Intelligence Dashboards (Superset)
End-to-end analytics providing insights into hospital operations, finance, and corporate health checkups.

| Operational Dashboard | Financial Dashboard | Corporate Dashboard |
| :---: | :---: | :---: |
| ![Operational](images/dashboard/dashboard_operational.png) | ![Financial](images/dashboard/dashboard_financial.png) | ![Corporate](images/dashboard/dashboard_corporate.png) |

### 3. Pipeline Orchestration & Monitoring (Airflow & Slack)
The entire workflow is orchestrated by Airflow, with real-time failure alerts and success notifications integrated into Slack.

| Airflow DAGs | Slack Notifications |
| :---: | :---: |
| ![Airflow](images/system/service_airflow.png) | ![Slack](images/system/slack_mess.png) |

### 4. Processing Engines (Spark & Flink)
*   **Stream Processing (Flink)**: High-performance CDC ingestion from Kafka into Apache Iceberg tables.
    ![Flink](images/system/service_flink.png)

---

## 📝 Contact
- **Project Lead**: Nguyễn Thanh Tính
- **Email**: thanhtinh.de@gmail.com
- **Version**: 1.0.0
