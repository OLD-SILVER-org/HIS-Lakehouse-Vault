import sys
import os
import traceback
from pyspark.sql.functions import current_timestamp, lit, col, to_timestamp
from pyspark.sql.types import TimestampType, DateType, IntegerType, LongType, FloatType, DoubleType, BooleanType, StringType

# Add parent directory to sys.path to import utils
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '../../')))
from utils.spark_utils import SparkUtils
from utils.slack_utils import SlackNotifier
from abc import ABC, abstractmethod

class ElasticBatch (ABC):
    def __init__(self, source, target_index, id_col):
        self.source = source
        self.target_index = target_index
        self.id_col = id_col
        self.utils = SparkUtils()
        self.spark = self.utils.get_spark_session("Elastic_Batch_Job")
        
        # Iceberg Catalog and Minio
        self.source_sink = "hospital_catalog.hospital_db_sink"
        
        # Slack Notifier
        self.notifier = SlackNotifier()

        # Auth
        self.user = "elastic"
        self.password = os.getenv("ES_PASSWORD", "")
    
    @abstractmethod
    def extract(self):
        pass
    
    @abstractmethod
    def transform(self, df):
        pass
    
    def prepare_df_for_write(self, df):
        """Prepare DataFrame before writing to Elasticsearch."""
        df = df.persist()
        row_count = df.count()
        num_partitions = df.rdd.getNumPartitions()
        target_partitions = min(max(self.spark.sparkContext.defaultParallelism, 4), 8)

        print(f"[INFO] Elasticsearch target index: {self.target_index}")
        print(f"[INFO] Rows to write: {row_count}")
        print(f"[INFO] Current partitions: {num_partitions}")
        print(f"[INFO] Default parallelism: {self.spark.sparkContext.defaultParallelism}")
        print(f"[INFO] Target partitions for ES write: {target_partitions}")

        if num_partitions > target_partitions:
            df = df.repartition(target_partitions)
            print(f"[INFO] Repartitioned DataFrame to {target_partitions} partitions for Elasticsearch write")
        return df, row_count

    def write_to_es(self, df):
        """
        Helper method to write Spark DataFrame to Elasticsearch.
        """
        df, row_count = self.prepare_df_for_write(df)

        es_conf = {
            "es.nodes": "elasticsearch",
            "es.port": "9200",
            "es.resource": self.target_index,
            "es.net.http.auth.user": self.user,
            "es.net.http.auth.pass": self.password,
            "es.nodes.wan.only": "true",
            "es.index.auto.create": "true",
            "es.write.operation": "upsert" if self.id_col else "index",
            "es.batch.size.entries": "5000",
            "es.batch.size.bytes": "10mb",
            "es.batch.write.retry.count": "3",
            "es.batch.write.retry.wait": "10s",
            "es.batch.write.refresh": "false",
            "es.batch.flush.timeout": "120s",
            "es.mapping.id": self.id_col if self.id_col else None
        }

        # Remove None values from config
        es_conf = {k: v for k, v in es_conf.items() if v is not None}

        try:
            df.write.format("org.elasticsearch.spark.sql") \
                .options(**es_conf) \
                .mode("append") \
                .save()
            print(f"[INFO] Successfully wrote {row_count} rows to Elasticsearch index: {self.target_index}")
        except Exception as e:
            if self.notifier:
                error_msg = f"❌ Failed to write to ES index: {self.target_index}\nError: {str(e)}\n{traceback.format_exc()}"
                self.notifier.send_message(error_msg)
            raise e
        finally:
            df.unpersist()

    def run(self):
        df = self.extract()
        transformed_df = self.transform(df)
        self.write_to_es(transformed_df)
