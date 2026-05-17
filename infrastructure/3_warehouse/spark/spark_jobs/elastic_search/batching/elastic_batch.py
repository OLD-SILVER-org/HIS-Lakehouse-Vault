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
    def __init__(self, source, target_index):
        self.source = source
        self.target_index = target_index
        self.utils = SparkUtils()
        self.spark = self.utils.get_spark_session("Elastic_Batch_Job")
        
        # Iceberg Catalog and Minio
        self.source_sink = "hospital_catalog.hospital_db_sink"
        
        # Elasticsearch Target Details
        self.target_index = target_index
        self.notifier = SlackNotifier()
    
    @abstractmethod
    def extract(self):
        pass
    
    @abstractmethod
    def transform(self, df):
        pass
    
    @abstractmethod
    def load(self, df):
        pass

    def run(self):
        df = self.extract()
        transformed_df = self.transform(df)
        self.load(transformed_df)
