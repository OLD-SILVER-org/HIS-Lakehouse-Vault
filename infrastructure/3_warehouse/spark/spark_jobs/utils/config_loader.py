import os
from dotenv import load_dotenv

class Config:
    """
    A helper class to load and manage all configurations from environment variables.
    It centralizes environment-specific logic (e.g., switching endpoints for local dev).
    """
    def __init__(self):
        load_dotenv()
        self.env = os.getenv("SPARK_ENV", "local")

        # Lake Configuration
        self.HIVE_METASTORE_URIS = os.getenv("HIVE_METASTORE_URIS")
        self.LAKE_HIVE_WAREHOUSE_DIR = os.getenv("LAKE_HIVE_WAREHOUSE_DIR")
        self.LAKE_MINIO_ENDPOINT = os.getenv("LAKE_MINIO_ENDPOINT")
        self.LAKE_MINIO_ROOT_USER = os.getenv("LAKE_MINIO_ROOT_USER")
        self.LAKE_MINIO_ROOT_PASSWORD = os.getenv("LAKE_MINIO_ROOT_PASSWORD")
        self.AWS_JAVA_V1_DISABLE_DEPRECATION_ANNOUNCEMENT = os.getenv("AWS_JAVA_V1_DISABLE_DEPRECATION_ANNOUNCEMENT")

        # Warehouse Postgres Configuration with defaults
        self.WAREHOUSE_POSTGRES_USER = os.getenv("WAREHOUSE_POSTGRES_USER", "dwh_admin")
        self.WAREHOUSE_POSTGRES_PASSWORD = os.getenv("WAREHOUSE_POSTGRES_PASSWORD")
        self.WAREHOUSE_POSTGRES_PORT = os.getenv("WAREHOUSE_POSTGRES_PORT", "5435")
        self.WAREHOUSE_POSTGRES_DB = os.getenv("WAREHOUSE_POSTGRES_DB", "postgres")
        self.WAREHOUSE_POSTGRES_HOST = "localhost" if self.is_local() else "warehouse"

        # Adjust endpoints for the local environment
        if self.is_local():
            if self.HIVE_METASTORE_URIS:
                self.HIVE_METASTORE_URIS = self.HIVE_METASTORE_URIS.replace("hive-metastore", "localhost")
            if self.LAKE_MINIO_ENDPOINT:
                self.LAKE_MINIO_ENDPOINT = self.LAKE_MINIO_ENDPOINT.replace("minio", "localhost")

    def is_local(self) -> bool:
        """Checks if the environment is 'local'."""
        return self.env == "local"

    def is_docker(self) -> bool:
        """Checks if the environment is 'docker'."""
        return self.env == "docker"

if __name__ == "__main__":
    config = Config()
    print(f"[*] Environment: {config.env}")
    print(f"[*] Hive Metastore URIs: {config.HIVE_METASTORE_URIS}")
    print(f"[*] Lake Hive Warehouse Dir: {config.LAKE_HIVE_WAREHOUSE_DIR}")
    print(f"[*] Lake MinIO Endpoint: {config.LAKE_MINIO_ENDPOINT}")
    print(f"[*] Lake MinIO Root User: {config.LAKE_MINIO_ROOT_USER}")
    print(f"[*] Lake MinIO Root Password: {config.LAKE_MINIO_ROOT_PASSWORD}")
    print(f"[*] AWS Java V1 Disable Deprecation Announcement: {config.AWS_JAVA_V1_DISABLE_DEPRECATION_ANNOUNCEMENT}")
    print(f"[*] Warehouse Postgres User: {config.WAREHOUSE_POSTGRES_USER}")
    print(f"[*] Warehouse Postgres Password: {config.WAREHOUSE_POSTGRES_PASSWORD}")
    print(f"[*] Warehouse Postgres Port: {config.WAREHOUSE_POSTGRES_PORT}")
    print(f"[*] Warehouse Postgres DB: {config.WAREHOUSE_POSTGRES_DB}")
    print(f"[*] Warehouse Postgres Host: {config.WAREHOUSE_POSTGRES_HOST}")