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
        self.AWS_JAVA_V1_DISABLE_DEPRECATION_ANNOUNCEMENT = os.getenv("AWS_JAVA_V1_DISABLE_DEPRECATION_ANNOUNCEMENT")

    def get_spark_session(self, app_name="Hospital_DWH_Job"):
        """
        Create sparkSession to detect environment (Local or Docker)
        """    
        builder = SparkSession.builder.appName(app_name)
        
        # Suppress AWS SDK V1 deprecation warnings if configured in env
        if self.AWS_JAVA_V1_DISABLE_DEPRECATION_ANNOUNCEMENT:
            os.environ["AWS_JAVA_V1_DISABLE_DEPRECATION_ANNOUNCEMENT"] = self.AWS_JAVA_V1_DISABLE_DEPRECATION_ANNOUNCEMENT
            builder = builder.config("spark.executorEnv.AWS_JAVA_V1_DISABLE_DEPRECATION_ANNOUNCEMENT", self.AWS_JAVA_V1_DISABLE_DEPRECATION_ANNOUNCEMENT) \
                             .config("spark.driverEnv.AWS_JAVA_V1_DISABLE_DEPRECATION_ANNOUNCEMENT", self.AWS_JAVA_V1_DISABLE_DEPRECATION_ANNOUNCEMENT)

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

        if self.env == "docker":
            # Run on Docker
            builder = builder.master("spark://spark-master:7077")
        else:
            # Run on Local
            # Replace container hostnames with localhost for local development
            if self.HIVE_METASTORE_URIS:
                self.HIVE_METASTORE_URIS = self.HIVE_METASTORE_URIS.replace("hive-metastore", "localhost")
            if self.LAKE_MINIO_ENDPOINT:
                self.LAKE_MINIO_ENDPOINT = self.LAKE_MINIO_ENDPOINT.replace("minio", "localhost")
                
            builder = builder.master("local[*]")
            
            # --- Smart JAR Discovery ---
            # Order of preference:
            # 1. Local module jars: current_dir/jars/ or current_dir/../jars/
            # 2. Shared infrastructure: infrastructure/2_lake/jars/
            
            current_dir = os.getcwd()
            possible_jar_dirs = [
                os.path.join(current_dir, "jars"),                   # Case: inside module folder
                os.path.join(current_dir, "..", "jars"),            # Case: inside utils/ folder of module
                os.path.join(current_dir, "infrastructure", "2_lake", "jars") # Global fallback
            ]
            
            found_jars = []
            for jar_dir in possible_jar_dirs:
                if os.path.exists(jar_dir):
                    jars = [os.path.join(jar_dir, f) for f in os.listdir(jar_dir) if f.endswith(".jar")]
                    if jars:
                        found_jars.extend(jars)
                        print(f"[*] Found {len(jars)} JARs in: {jar_dir}")
            
            if found_jars:
                # Use set to avoid duplicates if directories overlap
                unique_jars = list(set(found_jars))
                builder = builder.config("spark.jars", ",".join(unique_jars))
            else:
                print("[!] No local JARs found. Make sure required JARs are in 'jars/' or 'infrastructure/2_lake/jars/'.")
            
        # Update builder with potentially modified endpoints
        builder = builder \
            .config("hive.metastore.uris", self.HIVE_METASTORE_URIS) \
            .config("spark.hadoop.fs.s3a.endpoint", self.LAKE_MINIO_ENDPOINT)
            
        return builder.getOrCreate()
