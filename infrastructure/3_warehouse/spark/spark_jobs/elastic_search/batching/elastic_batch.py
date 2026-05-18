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
    
    def write_to_es(self, df):
        """
        Helper method to write Spark DataFrame to Elasticsearch.
        """
        es_conf = {
            "es.nodes": "elasticsearch",
            "es.port": "9200",
            "es.resource": self.target_index,
            "es.net.http.auth.user": self.user,
            "es.net.http.auth.pass": self.password,
            "es.nodes.wan.only": "true",
            "es.index.auto.create": "true",
            "es.write.operation": "upsert" if self.id_col else "index"
        }

        if self.id_col:
            es_conf["es.mapping.id"] = self.id_col
        
        try:
            df.write.format("org.elasticsearch.spark.sql") \
                .options(**es_conf) \
                .mode("append") \
                .save()
        except Exception as e:
            if self.notifier:
                error_msg = f"❌ Failed to write to ES index: {self.target_index}\nError: {str(e)}\n{traceback.format_exc()}"
                self.notifier.send_message(error_msg)
            raise e

    def run(self):
        df = self.extract()
        transformed_df = self.transform(df)
        self.write_to_es(transformed_df)
