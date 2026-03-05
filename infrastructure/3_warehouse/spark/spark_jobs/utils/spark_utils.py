import os
import glob
from pyspark.sql import SparkSession
from utils.config_loader import Config

class SparkUtils:
    """
    Utility class for Spark operations, including session initialization,
    configuration management, and JAR loading.
    """
    def __init__(self):
        self.config = Config()
        self.project_root = self._get_project_root()
        self.jars_path = os.path.join(self.project_root, "infrastructure", "3_warehouse", "jars")

    def _get_project_root(self):
        """Finds the project root directory."""
        # Assuming spark_utils.py is in infrastructure/3_warehouse/spark/spark_jobs/utils/
        return os.path.abspath(os.path.join(os.path.dirname(__file__), "../../../../../"))

    def get_jars(self):
        """Returns a comma-separated string of JAR files in the jars directory."""
        jar_pattern = os.path.join(self.jars_path, "*.jar")
        jars = glob.glob(jar_pattern)
        if not jars:
            print(f"[!] Warning: No JAR files found in {self.jars_path}")
            return ""
        return ",".join(jars)

    def get_spark_session(self, app_name="Hospital_DWH_Job"):
        """Initializes and returns a Spark session with proper configurations."""
        jars = self.get_jars()
        # Clean up endpoint
        endpoint = self.config.LAKE_MINIO_ENDPOINT
        if endpoint:
            endpoint = endpoint.strip().replace("http://", "").replace("https://", "")
        
        warehouse = self.config.LAKE_HIVE_WAREHOUSE_DIR.strip() if self.config.LAKE_HIVE_WAREHOUSE_DIR else ""
        if warehouse and not warehouse.endswith("/"):
            warehouse += "/"
        
        print(f"[*] Spark Warehouse: '{warehouse}'")
        
        builder = SparkSession.builder \
            .appName(app_name) \
            .config("spark.jars", jars) \
            .config("spark.sql.extensions", "org.apache.iceberg.spark.extensions.IcebergSparkSessionExtensions") \
            .config("spark.sql.catalog.hospital_catalog", "org.apache.iceberg.spark.SparkCatalog") \
            .config("spark.sql.catalog.hospital_catalog.type", "hive") \
            .config("spark.sql.catalog.hospital_catalog.warehouse", warehouse) \
            .config("spark.hadoop.fs.s3a.endpoint", endpoint) \
            .config("spark.hadoop.fs.s3a.access.key", self.config.LAKE_MINIO_ROOT_USER.strip() if self.config.LAKE_MINIO_ROOT_USER else "") \
            .config("spark.hadoop.fs.s3a.secret.key", self.config.LAKE_MINIO_ROOT_PASSWORD.strip() if self.config.LAKE_MINIO_ROOT_PASSWORD else "") \
            .config("spark.hadoop.fs.s3a.path.style.access", "true") \
            .config("spark.hadoop.fs.s3a.impl", "org.apache.hadoop.fs.s3a.S3AFileSystem") \
            .config("spark.hadoop.fs.s3a.connection.ssl.enabled", "false") \
            .config("spark.hadoop.fs.s3a.aws.credentials.provider", "org.apache.hadoop.fs.s3a.SimpleAWSCredentialsProvider")
            
        # Add Hive Metastore URIs if available
        if self.config.HIVE_METASTORE_URIS:
            builder = builder.config("spark.hadoop.hive.metastore.uris", self.config.HIVE_METASTORE_URIS)

        return builder.getOrCreate()

    def get_jdbc_url(self):
        """Returns the JDBC URL for the Postgres warehouse."""
        return f"jdbc:postgresql://{self.config.WAREHOUSE_POSTGRES_HOST}:{self.config.WAREHOUSE_POSTGRES_PORT}/{self.config.WAREHOUSE_POSTGRES_DB}"

    def get_postgres_properties(self):
        """Returns the properties for Postgres JDBC connection."""
        return {
            "user": self.config.WAREHOUSE_POSTGRES_USER,
            "password": self.config.WAREHOUSE_POSTGRES_PASSWORD,
            "driver": "org.postgresql.Driver"
        }

if __name__ == "__main__":
    utils = SparkUtils()
    print(f"[*] Project Root: {utils.project_root}")
    print(f"[*] Jars Path: {utils.jars_path}")
    print(f"[*] JDBC URL: {utils.get_jdbc_url()}")
    # Test Jar loading
    jars_count = len(utils.get_jars().split(",")) if utils.get_jars() else 0
    print(f"[*] Found {jars_count} JARs.")
    utils.get_spark_session().stop()
