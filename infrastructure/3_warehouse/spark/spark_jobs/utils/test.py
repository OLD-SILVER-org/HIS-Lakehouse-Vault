import sys
import os

# Add the parent directory to sys.path to allow importing from 'utils'
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from spark_utils import SparkUtils

def test_spark_connection():
    print("Initializing Spark Session...")
    spark_utils = SparkUtils()
    spark = spark_utils.get_spark_session("Spark_Connection_Test")

    try:
        print("\n--- Listing Databases ---")
        databases = spark.sql("SHOW DATABASES")
        databases.show()

        # Check for the expected database
        db_list = [row[0] for row in databases.collect()]
        target_db = "hospital_db_sink"

        if target_db in db_list:
            print(f"\n--- Listing Tables in {target_db} ---")
            spark.sql(f"USE {target_db}")
            tables = spark.sql("SHOW TABLES")
            tables.show()
        else:
            print(f"\n[!] Database '{target_db}' not found. Listing tables in 'default' instead.")
            spark.sql("USE default")
            tables = spark.sql("SHOW TABLES")
            tables.show()

        print("\n✅ Spark connection and Hive Metastore query successful!")
    
    except Exception as e:
        print(f"\n❌ Error during Spark execution: {str(e)}")
    finally:
        spark.stop()

if __name__ == "__main__":
    test_spark_connection()
