# 🔍 Elasticsearch & Kibana Stack

This directory contains the Docker Compose setup for **Elasticsearch** and **Kibana**, used for log analysis, search, and data visualization within the HIS-Lakehouse platform.

## 🚀 How to Run

To start the **Elasticsearch & Kibana** stack, run:

```bash
docker compose --env-file .env up -d
```

To start the **Spark for Elasticsearch** stack (dedicated cluster), run:

```bash
cd src/spark
docker compose --env-file ../../.env up -d
```

### 📊 Spark Web UIs (ES Cluster)
- **Spark Master UI (Internal)**: [http://localhost:8089](http://localhost:8089)
- **Spark Master UI (External)**: [http://vmi3040316.contaboserver.net:18089/](http://vmi3040316.contaboserver.net:18089/)
- **Spark Worker UI**: [http://localhost:8084](http://localhost:8084)
- **Spark Master Internal**: `spark://spark-es-master:7077`

### ⚙️ Configuration
The stack uses environment variables defined in the `.env` file:
- `ELASTIC_IMAGE`: Version of Elasticsearch (e.g., `8.17.2`).
- `KIBANA_IMAGE`: Version of Kibana.
- `ES_PASSWORD`: The password for the `elastic` user.

## 🌐 Accessing the Web UI

The stack is integrated with the **Caddy Reverse Proxy**, providing an additional layer of security and a standard URL.

### 🔗 Access Link
👉 **Kibana Dashboard**: [http://vmi3040316.contaboserver.net:5601/](http://vmi3040316.contaboserver.net:5601/)

### 🔐 Security & Authentication
Access is protected by the **Kibana Login Layer**:
- **User**: `elastic` (Password: `thanhtinh@Pass123`)
- **Alternative User**: `kibanadmin` (Password: `kibanapass`)

*(Lớp bảo mật Caddy Basic Auth đã được gỡ bỏ cho dịch vụ này theo yêu cầu).*

## 🛠️ Maintenance

- **View Logs**: `docker compose logs -f`
- **Check Health**: 
  ```bash
  docker exec elasticsearch curl -s -u elastic:${ES_PASSWORD} -f http://localhost:9200/_cat/health
  ```
- **Stop Stack**: `docker compose down`
