import sys
import os

# Add parent directory to sys.path to import utils
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from utils.spark_utils import SparkUtils

def test_connection():
    print("[*] Initializing Spark Session...")
    utils = SparkUtils()
    spark = utils.get_spark_session("Test_Hive_Iceberg_Connection")
    
    catalog = "hospital_catalog"
    name_space = "hospital_db_sink"
    table_name = "ct_phieu_thu"

    # Show tables
    tables = spark.sql(f"SHOW TABLES IN {catalog}.{name_space}").collect()
    for table in tables:
        print(table)

    # Query data
    table_dataframe = spark.sql(
        f"SELECT * FROM {catalog}.{name_space}.{table_name} LIMIT 10"
    )
    table_dataframe.show(50)

    print("\n[*] Stopping Spark Session...")
    spark.stop()

if __name__ == "__main__":
    test_connection()