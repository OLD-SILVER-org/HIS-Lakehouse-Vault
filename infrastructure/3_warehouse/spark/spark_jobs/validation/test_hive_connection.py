import sys
import os

# Add relevant paths to sys.path to import utils and config
script_dir = os.path.dirname(os.path.abspath(__file__))
# test_hive_connection.py is in validation/, utils is in ../utils/
utils_path = os.path.abspath(os.path.join(script_dir, "..", "utils"))

if utils_path not in sys.path:
    sys.path.append(utils_path)

try:
    from spark_utils import SparkUtils
except ImportError as e:
    print(f"[✘] Failed to import SparkUtils from {utils_path}")
    print(f"[!] Error: {e}")
    sys.exit(1)

def test_connection():
    print("[*] Initializing Spark Session...")
    utils = SparkUtils()
    spark = utils.get_spark_session("Test_Hive_Iceberg_Connection")
    
    print("[*] Attempting to list namespaces in hospital_catalog...")
    try:
        # List namespaces (databases) in the catalog
        namespaces = spark.sql("SHOW NAMESPACES IN hospital_catalog").collect()
        print(f"[✔] Successfully connected! Found {len(namespaces)} namespaces:")
        for ns in namespaces:
            print(f"  - {ns[0]}")
            
        # Try to show tables in bronze if it exists
        print("\n[*] Attempting to list tables in hospital_catalog.bronze...")
        try:
            tables = spark.sql("SHOW TABLES IN hospital_catalog.bronze").collect()
            print(f"[✔] Found {len(tables)} tables in bronze:")
            for t in tables:
                print(f"  - {t['tableName']}")
        except Exception as e:
            print(f"[!] Could not list tables in bronze: {e}")

    except Exception as e:
        if "NoSuchNamespaceException" in str(e):
            print(f"[✔] Connection successful! (But the warehouse is currently empty).")
            print("[!] Instruction: You need to create a namespace or table first. Example:")
            print("    spark.sql(\"CREATE NAMESPACE IF NOT EXISTS hospital_catalog.bronze\")")
        else:
            print(f"[✘] Connection failed: {e}")
    finally:
        print("\n[*] Stopping Spark Session...")
        spark.stop()

if __name__ == "__main__":
    test_connection()
