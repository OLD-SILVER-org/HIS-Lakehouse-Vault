import sys
import os
from pyspark.sql.functions import current_timestamp, lit

# Add parent directory to sys.path to import utils
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '../../')))
from utils.spark_utils import SparkUtils

class InitialLoader:
    def __init__(self):
        self.utils = SparkUtils()
        self.spark = self.utils.get_spark_session("Initial_Loader_Job")
        
        # Iceberg Catalog and Database
        self.catalog = "hospital_catalog"
        self.source_db = "hospital_db_sink"
        
        # Postgres Target Details
        self.target_schema = "staging"

    def get_list_table_from_lake(self):
        print(f"[*] Fetching tables from {self.catalog}.{self.source_db}...")
        try:
            tables_df = self.spark.sql(f"SHOW TABLES IN {self.catalog}.{self.source_db}")
            table_list = [row['tableName'] for row in tables_df.collect()]
            print(f"[*] Found {len(table_list)} tables: {table_list}")
            return table_list
        except Exception as e:
            print(f"[✘] Error fetching tables: {str(e)}")
            return []

    def transform(self, df):
        pass

    def write_to_staging(self, table_name, df):
        pass

    def process_table(self, table_name):
        pass

    def load(self):
        table_list = self.get_list_table_from_lake()

        pass

if __name__ == "__main__":
    loader = InitialLoader()
    loader.load()
