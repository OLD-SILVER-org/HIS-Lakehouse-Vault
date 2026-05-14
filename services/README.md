# HIS Lakehouse - Network Services

This directory contains the core network and security layer for the HIS Lakehouse platform. 

It manages reverse proxying (Caddy), VPN (WireGuard/WGDashboard), and centralized authentication & login tracking.

## 📦 Components

1. **Caddy**: Acts as the main entry point (Reverse Proxy). It handles automatic HTTPS, routing, and Basic Authentication for all backend services (Airflow, Superset, Flink, Kafka, MinIO, Spark, WGDashboard).
2. **WGDashboard**: A Web UI for managing WireGuard VPN.
3. **Login Tracker**: A Python script that monitors Caddy's access logs to track user logins and sends alerts to Slack when an IP changes or after a long period of inactivity.

---

## 🚀 How to Install and Run

### 1. Prerequisites
- Docker and Docker Compose installed.
- Ensure ports `80`, `443`, `51820` (UDP), and mapped service ports (`8081`, `18085`, `18088`, `18090`, `18888`, `19001`) are open on your server firewall.

### 2. Configure Environment Variables
Make sure the `service_env.env` file exists in the `services/` directory and contains the required configurations:
- `NETWORK_DOMAIN`: Your server domain (e.g., `vmi3040316.contaboserver.net`)
- `NETWORK_EMAIL`: Email for Let's Encrypt SSL.
- `LOGIN_WEBHOOK`: Your Slack Webhook URL.
- `LOGIN_USER`, `LOGIN_PASS_HASH`: Credentials for Caddy Basic Auth.

*(See the `service_env.env` file for all variables).*

### 3. Start the Stack
Navigate to the `network` directory and run docker-compose, pointing to the parent environment file:

```bash
cd /opt/his-lakehouse/services/network
docker compose --env-file ../service_env.env up -d
```

### 4. Verify Services
Check if all containers are running successfully:
```bash
docker compose ps
```
You can view the logs of Caddy or the Login Tracker using:
```bash
docker compose logs -f caddy
docker compose logs -f login-tracker
```

---

## 🔐 Accessing Services & Authentication

All services are accessible via your domain name and specific ports. 

**Authentication Layers:**
1. **Layer 1 (Caddy Basic Auth)**: Whenever you access *any* service (including WGDashboard), a browser pop-up will ask for credentials.
   - **User**: Get from the `LOGIN_USER` variable in the `.env` file.
   - **Pass**: Password corresponding to `LOGIN_PASS_HASH` (Current password is: `thanhtinh@Pass1`).
2. **Layer 2 (Application Auth)**: Some apps will have their own login forms (e.g., WGDashboard, Superset, Airflow).
   - *For WGDashboard*: On first access, the default account is usually `admin` / `admin`. Please log in and change the password in the Settings section!

**Service Endpoints:**
- **Main Domain / WGDashboard**: `https://<NETWORK_DOMAIN>`
- **Airflow UI**: `http://<NETWORK_DOMAIN>:18888`
- **Superset BI**: `http://<NETWORK_DOMAIN>:18088`
- **Flink UI**: `http://<NETWORK_DOMAIN>:8081`
- **Spark Master**: `http://<NETWORK_DOMAIN>:18085`
- **Trino UI**: `http://<NETWORK_DOMAIN>:18080`
- **Kafka UI**: `http://<NETWORK_DOMAIN>:18090`
- **MinIO Console**: `http://<NETWORK_DOMAIN>:19001` hoặc `https://<NETWORK_DOMAIN>/minio`

---

## 🔔 Login Tracker & Slack Alerts

The `login-tracker` container continuously reads `/data/logs/caddy_access.log`.
It sends a message to Slack if:
- A user logs in from a **NEW IP address** (with a 10-minute cooldown to prevent spam).
- A user logs in from the **SAME IP address** but hasn't logged in for over 12 hours.

**Cache details:**
- Persistent user stats (Total Logins, Last IP, Last Login Time) are stored in `/opt/his-lakehouse/services/data/login_cache.json`.
- Tham khảo file `/opt/his-lakehouse/notes/login_tracker_instructions.md` để xem cấu trúc file json và cách reset số lần đăng nhập.
