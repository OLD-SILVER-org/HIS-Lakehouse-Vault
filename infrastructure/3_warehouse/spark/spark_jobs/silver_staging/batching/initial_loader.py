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
        self.source_db = "bronze"
        
        # Postgres Target Details
        self.target_schema = "staging"

    def get_list_table_from_lake(self):
        """
        Lấy danh sách các bảng từ hospital_catalog.bronze
        """
        print(f"[*] Fetching tables from {self.catalog}.{self.source_db}...")
        try:
            # Sử dụng spark.sql để liệt kê các bảng trong catalog và database cụ thể
            tables_df = self.spark.sql(f"SHOW TABLES IN {self.catalog}.{self.source_db}")
            table_list = [row['tableName'] for row in tables_df.collect()]
            print(f"[*] Found {len(table_list)} tables: {table_list}")
            return table_list
        except Exception as e:
            print(f"[✘] Error fetching tables: {str(e)}")
            return []

    def transform(self, df):
        """
        Thực hiện các biến đổi cơ bản:
        - Chuyển tên cột sang chữ thường
        - Thêm cột metadata (_ingested_at, _batch_id)
        """
        # 1. Chuyển tên cột sang chữ thường
        for col_name in df.columns:
            df = df.withColumnRenamed(col_name, col_name.lower())
        
        # 2. Thêm metadata
        df = df.withColumn("_ingested_at", current_timestamp()) \
               .withColumn("_batch_id", lit("INITIAL_LOAD"))
        
        return df

    def write_to_staging(self, table_name, df):
        """
        Ghi dữ liệu vào Postgres Staging sử dụng JDBC
        """
        target_table = f"{self.target_schema}.{table_name}"
        jdbc_url = self.utils.get_jdbc_url()
        properties = self.utils.get_postgres_properties()
        
        print(f"[*] Writing to Postgres staging: {target_table} (mode=overwrite)...")
        try:
            df.write \
                .jdbc(url=jdbc_url, table=target_table, mode="overwrite", properties=properties)
            print(f"[✔] Successfully loaded {table_name} into staging.")
        except Exception as e:
            print(f"[✘] Error writing {table_name} to staging: {str(e)}")

    def process_table(self, table_name):
        """
        Quy trình xử lý một bảng: Read -> Transform -> Load
        """
        source_table = f"{self.catalog}.{self.source_db}.{table_name}"
        print(f"\n>>> Processing table: {table_name}...")
        try:
            # 1. Read
            df = self.spark.table(source_table)
            
            # 2. Transform
            df_transformed = self.transform(df)
            
            # 3. Load
            self.write_to_staging(table_name, df_transformed)
            
        except Exception as e:
            print(f"[✘] Error processing {table_name}: {str(e)}")

    def load(self):
        """
        Chương trình chính: Lấy danh sách bảng và duyệt qua từng bảng để xử lý
        """
        tables = self.get_list_table_from_lake()
        if not tables:
            print("[!] No tables found to process.")
            return

        for table in tables:
            self.process_table(table)
        
        print("\n[*] Initial load process completed.")

if __name__ == "__main__":
    loader = InitialLoader()
    loader.load()
