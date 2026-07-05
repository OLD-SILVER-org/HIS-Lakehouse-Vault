# 🚀 Technical Highlights & Performance Metrics

### 📈 Scalability & Throughput
- **Sustained 40,000 rec/min (~57M records/day)** on a single 8-core VPS.
- **Bottleneck Isolation:** Identified and isolated the primary system bottleneck to the **PostgreSQL WAL reader** rather than the pipeline itself, providing a clear path for future scaling.

### ⚡ Data Freshness & Latency
- **~5 minute End-to-End Latency:** Optimized data flow from source ingestion to analytics-ready state.
- **Stream Processing:** Integrated **Debezium** for Change Data Capture (CDC) and **Apache Flink** for stateful stream processing to minimize data stale-ness.

### 🏗️ Infrastructure Density & Cost Efficiency
- **Full-Stack Orchestration:** Orchestrated **27 Docker containers** simultaneously on a single node, managing a complex ecosystem:
    - Messaging/Streaming: Kafka (KRaft), Flink.
    - Processing/Storage: Spark, Iceberg, MinIO.
    - Analytics/BI: Trino, dbt, Airflow, Elasticsearch, Kibana, Superset.
- **Resource Optimization:** Achieved infrastructure density equivalent to managed AWS services (MSK, EMR, Athena, etc.) valued at **$900+/month**.

### 🛠️ Debugging & Performance Tuning
- **Spark Optimization:** Diagnosed and resolved **Spark Netty OOM** (Out of Memory) errors by reconfiguring executor memory and off-heap direct memory settings.
- **Storage Health:** Eliminated **Iceberg small-file fragmentation** issues via scheduled compaction pipelines, ensuring consistent query performance.
- **Infrastructure Tracing:** Conducted root-cause analysis on PostgreSQL WAL disconnects to define the system's maximum throughput ceiling.