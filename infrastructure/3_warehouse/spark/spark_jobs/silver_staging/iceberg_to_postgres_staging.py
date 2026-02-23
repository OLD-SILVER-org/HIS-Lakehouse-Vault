import sys
import os

# Add parent directory to sys.path to import utils
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '../../')))
from utils.spark_utils import SparkUtils

class IcebergToPostgresStaging:
    def __init__(self):
        self.utils = SparkUtils()
        self.spark = self.utils.get_spark_session("Iceberg_to_Staging_Job")
        
        # Iceberg Source Table (catalog.database.table)
        self.source_catalog = "hospital_catalog"
        self.source_db = "bronze" # Thay đổi database tương ứng trong Lake của bạn
        
        # Postgres Target Details
        self.target_schema = "staging"

    def process_table(self, table_name):
        """
        Đọc dữ liệu từ Iceberg, biến đổi và ghi vào Postgres Staging
        """
        source_table = f"{self.source_catalog}.{self.source_db}.{table_name}"
        print(f"[*] Reading from {source_table}...")
        
        try:
            # 1. Đọc dữ liệu từ Iceberg
            df = self.spark.table(source_table)
            
            # 2. Biến đổi dữ liệu (Ví dụ: chuẩn hoá kiểu dữ liệu, thêm cột timestamp)
            print(f"[*] Transforming {table_name}...")
            # df = df.withColumn("processed_at", current_timestamp())
            
            # 3. Ghi vào Postgres Staging sử dụng JDBC
            target_table = f"{self.target_schema}.{table_name}"
            jdbc_url = self.utils.get_jdbc_url()
            properties = self.utils.get_postgres_properties()
            
            print(f"[*] Writing to Postgres target: {target_table}...")
            df.write \
                .jdbc(url=jdbc_url, table=target_table, mode="overwrite", properties=properties)
            
            print(f"[✔] Successfully processed {table_name}")
            
        except Exception as e:
            print(f"[✘] Error processing {table_name}: {str(e)}")

    def run(self):
        # Bạn có thể truyền danh sách table cần lấy ở đây
        tables = ["ct_phieu_thu"] # Thay bằng tên table thực tế của bạn
        for table in tables:
            self.process_table(table)

if __name__ == "__main__":
    job = IcebergToPostgresStaging()
    job.run()
