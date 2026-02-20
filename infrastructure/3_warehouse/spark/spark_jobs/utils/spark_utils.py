import os
from dotenv import load_dotenv
from pyspark.sql import SparkSession

class SparkUtils:
    def __init__(self):
        load_dotenv()
        self.env = os.getenv("SPARK_ENV", "local")
        self.HIVE_METASTORE_URIS = os.getenv("HIVE_METASTORE_URIS")
        self.LAKE_HIVE_WAREHOUSE_DIR = os.getenv("LAKE_HIVE_WAREHOUSE_DIR")
        self.LAKE_MINIO_ENDPOINT = os.getenv("LAKE_MINIO_ENDPOINT")
        self.LAKE_MINIO_ROOT_USER = os.getenv("LAKE_MINIO_ROOT_USER")
        self.LAKE_MINIO_ROOT_PASSWORD = os.getenv("LAKE_MINIO_ROOT_PASSWORD")

    def get_spark_session(self, app_name="Hospital_DWH_Job"):
        """
        Create sparkSession to detect environment (Local or Docker)
        """    
        builder = SparkSession.builder.appName(app_name)
        
        # Common configuration for Hive Metastore
        builder = builder \
            .config("hive.metastore.uris", self.HIVE_METASTORE_URIS) \
            .config("spark.sql.warehouse.dir", self.LAKE_HIVE_WAREHOUSE_DIR) \
            .enableHiveSupport()
        
        # MinIO (S3A) configuration
        builder = builder \
            .config("spark.hadoop.fs.s3a.endpoint", self.LAKE_MINIO_ENDPOINT) \
            .config("spark.hadoop.fs.s3a.access.key", self.LAKE_MINIO_ROOT_USER) \
            .config("spark.hadoop.fs.s3a.secret.key", self.LAKE_MINIO_ROOT_PASSWORD) \
            .config("spark.hadoop.fs.s3a.path.style.access", "true") \
            .config("spark.hadoop.fs.s3a.impl", "org.apache.hadoop.fs.s3a.S3AFileSystem") \
            .config("spark.hadoop.fs.s3a.connection.ssl.enabled", "false")

        if self.env == "docker"
            # Run on Docker
            builder = builder.master("spark://spark-master:7077")
        else:
            # Run on Local
            builder = builder.master("local[*]")
            
        return builder.get_spark_session()
