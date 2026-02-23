import os
from pyspark.sql import SparkSession
from typing import Optional
from .config_loader import Config

class SparkUtils:
    def __init__(self):
        self.config = Config()

    def _find_local_jars(self) -> tuple[Optional[str], Optional[str]]:
        """
        Automatically discovers JAR files in predefined local directories.
        Returns a tuple of (comma_separated_jars, classpath_string).
        Handles Windows-specific URI formatting and platform-specific path separators.
        """
        current_dir = os.getcwd()
        possible_jar_dirs = [
            os.path.join(current_dir, "jars"),
            os.path.join(current_dir, "..", "jars"),
            os.path.join(os.path.dirname(__file__), "..", "..", "..", "..", "2_lake", "jars")
        ]

        found_jars = []
        for jar_dir in possible_jar_dirs:
            real_jar_dir = os.path.realpath(jar_dir)
            if os.path.exists(real_jar_dir) and os.path.isdir(real_jar_dir):
                all_files = os.listdir(real_jar_dir)
                jars = [os.path.join(real_jar_dir, f) for f in all_files 
                        if f.endswith(".jar") and not any(x in f.lower() for x in ["flink", "sql-connector"])]
                
                if jars:
                    found_jars.extend(jars)
                    print(f"[*] Found {len(jars)} compatible JARs in: {real_jar_dir}")

        if not found_jars:
            print("[!] No compatible local JARs found.")
            return None, None

        unique_jars = list(set(found_jars))
        
        # Format for spark.jars (requires file:/// on Windows local)
        if os.name == 'nt' and self.config.is_local():
            jar_list = ",".join([f"file:///{j.replace(os.sep, '/')}" for j in unique_jars])
        else:
            jar_list = ",".join(unique_jars)

        # Format for extraClassPath (uses ; on Windows, : on Linux)
        classpath = os.pathsep.join(unique_jars)

        return jar_list, classpath

    def get_spark_session(self, app_name="Hospital_DWH_Job") -> SparkSession:
        """
        Creates and configures a SparkSession based on the environment settings.
        """
        builder = SparkSession.builder.appName(app_name)

        if self.config.is_docker():
            builder = builder.master("spark://spark-master:7077")
        else:  # local environment
            builder = builder.master("local[*]")

        # Automatically discover and load JARs if available in the project structure
        jar_list, classpath = self._find_local_jars()
        if jar_list:
            builder = builder.config("spark.jars", jar_list) \
                             .config("spark.driver.extraClassPath", classpath) \
                             .config("spark.executor.extraClassPath", classpath)

        # --- Common Configurations ---
        # Suppress AWS SDK V1 deprecation warnings
        if self.config.AWS_JAVA_V1_DISABLE_DEPRECATION_ANNOUNCEMENT:
            os.environ["AWS_JAVA_V1_DISABLE_DEPRECATION_ANNOUNCEMENT"] = self.config.AWS_JAVA_V1_DISABLE_DEPRECATION_ANNOUNCEMENT
            builder = builder.config("spark.executorEnv.AWS_JAVA_V1_DISABLE_DEPRECATION_ANNOUNCEMENT", self.config.AWS_JAVA_V1_DISABLE_DEPRECATION_ANNOUNCEMENT) \
                             .config("spark.driverEnv.AWS_JAVA_V1_DISABLE_DEPRECATION_ANNOUNCEMENT", self.config.AWS_JAVA_V1_DISABLE_DEPRECATION_ANNOUNCEMENT)

        # Configure Hive Metastore, S3 (MinIO), and Iceberg
        builder = builder \
            .config("hive.metastore.uris", self.config.HIVE_METASTORE_URIS) \
            .config("spark.sql.warehouse.dir", self.config.LAKE_HIVE_WAREHOUSE_DIR) \
            .config("spark.hadoop.fs.s3a.endpoint", self.config.LAKE_MINIO_ENDPOINT) \
            .config("spark.hadoop.fs.s3a.access.key", self.config.LAKE_MINIO_ROOT_USER) \
            .config("spark.hadoop.fs.s3a.secret.key", self.config.LAKE_MINIO_ROOT_PASSWORD) \
            .config("spark.hadoop.fs.s3a.path.style.access", "true") \
            .config("spark.hadoop.fs.s3a.impl", "org.apache.hadoop.fs.s3a.S3AFileSystem") \
            .config("spark.hadoop.fs.s3a.connection.ssl.enabled", "false") \
            .config("spark.sql.extensions", "org.apache.iceberg.spark.extensions.IcebergSparkSessionExtensions") \
            .config("spark.sql.catalog.hospital_catalog", "org.apache.iceberg.spark.SparkHiveCatalog") \
            .config("spark.sql.catalog.hospital_catalog.uri", self.config.HIVE_METASTORE_URIS) \
            .config("spark.sql.catalog.hospital_catalog.warehouse", self.config.LAKE_HIVE_WAREHOUSE_DIR) \
            .config("spark.sql.catalog.hospital_catalog.io-impl", "org.apache.iceberg.aws.s3.S3FileIO") \
            .config("spark.sql.catalog.hospital_catalog.s3.endpoint", self.config.LAKE_MINIO_ENDPOINT) \
            .config("spark.sql.catalog.hospital_catalog.s3.access-key-id", self.config.LAKE_MINIO_ROOT_USER) \
            .config("spark.sql.catalog.hospital_catalog.s3.secret-access-key", self.config.LAKE_MINIO_ROOT_PASSWORD) \
            .config("spark.sql.catalog.hospital_catalog.s3.path-style-access", "true") \
            .enableHiveSupport()
            
        return builder.getOrCreate()

    def get_postgres_properties(self):
        """
        Returns a dictionary of standard JDBC properties for the Postgres Warehouse.
        """
        return {
            "user": self.config.WAREHOUSE_POSTGRES_USER,
            "password": self.config.WAREHOUSE_POSTGRES_PASSWORD,
            "driver": "org.postgresql.Driver"
        }

    def get_jdbc_url(self):
        """
        Constructs the JDBC URL for the Warehouse Postgres database.
        """
        return f"jdbc:postgresql://{self.config.WAREHOUSE_POSTGRES_HOST}:{self.config.WAREHOUSE_POSTGRES_PORT}/{self.config.WAREHOUSE_POSTGRES_DB}"
