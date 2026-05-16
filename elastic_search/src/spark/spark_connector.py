from pyspark.sql import SparkSession
import sys
import os

spark = SparkSession.builder \
    .appName("IcebergToElasticsearch") \
    .config("spark.sql.catalog.minio", "org.apache.iceberg.spark.SparkCatalog") \
    .config("spark.sql.catalog.minio.type", "hadoop") \
    .config("spark.sql.catalog.minio.warehouse", "s3a://warehouse/") \
    .config("spark.hadoop.fs.s3a.endpoint", "http://localhost:9000") \
    .config("spark.hadoop.fs.s3a.access.key", "minioadmin") \
    .config("spark.hadoop.fs.s3a.secret.key", "minioadmin") \
    .config("spark.hadoop.fs.s3a.path.style.access", "true") \
    .getOrCreate()
# Thêm đường dẫn để import SparkUtils
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), "../../../infrastructure/3_warehouse/spark/spark_jobs")))
from utils.spark_utils import SparkUtils

utils = SparkUtils()
spark = utils.get_spark_session("IcebergToElasticsearch")

es_nodes = "localhost" if utils.config.is_local() else "elasticsearch"

# Đọc Iceberg table từ MinIO
df = spark.read.format("iceberg").load("minio.db.my_table")
# Sử dụng catalog 'hospital_catalog' đã được định nghĩa trong SparkUtils
df = spark.read.format("iceberg").load("hospital_catalog.db.my_table")

# Chuyển dữ liệu sang Elasticsearch
df.write \
    .format("org.elasticsearch.spark.sql") \
    .option("es.nodes", "http://localhost:9200") \
    .option("es.nodes", es_nodes) \
    .option("es.port", "9200") \
    .option("es.nodes.wan.only", "true") \
    .option("es.resource", "my_index/_doc") \
    .mode("overwrite") \
    .save()