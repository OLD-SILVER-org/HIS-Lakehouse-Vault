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
    print(f"[X] Failed to import SparkUtils from {utils_path}")
    print(f"[!] Error: {e}")
    sys.exit(1)

def test_connection():
    print("[*] Initializing Spark Session...")
    utils = SparkUtils()
    spark = utils.get_spark_session("Test_Hive_Iceberg_Connection")
    
    catalogs = ["hospital_catalog"]
    total_found = 0

    for catalog in catalogs:
        print(f"\n[*] Checking catalog: {catalog}")
        try:
            # List namespaces (databases) in the catalog
            namespaces = spark.sql(f"SHOW NAMESPACES IN {catalog}").collect()
            print(f"[OK] Found {len(namespaces)} namespaces in {catalog}.")
            
            for ns in namespaces:
                ns_name = ns[0]
                print(f"    - Namespace: {ns_name}")
                try:
                    tables = spark.sql(f"SHOW TABLES IN {catalog}.{ns_name}").collect()
                    if not tables:
                        print(f"      (No tables found in {ns_name})")
                    else:
                        for t in tables:
                            print(f"      - Table: {t['tableName']}")
                            total_found += 1
                except Exception as e:
                    print(f"      [!] Error listing tables in {ns_name}: {e}")

        except Exception as e:
            if "NoSuchNamespaceException" in str(e) or "CatalogNotFoundException" in str(e):
                print(f"[!] Catalog '{catalog}' not found or empty.")
            else:
                print(f"[X] Error checking {catalog}: {e}")

    print("\n" + "="*40)
    print(f"[OK] TOTAL TABLES FOUND: {total_found}")
    print("="*40)

    if total_found == 0:
        print("\n[TIP] Your warehouse seems empty. You can create a test table with:")
        print("    spark.sql(\"CREATE NAMESPACE IF NOT EXISTS hospital-datalake.test_db\")")
        print("    spark.sql(\"CREATE TABLE IF NOT EXISTS hospital-datalake.test_db.test_table (id INT, name STRING) USING iceberg\")")
        print("    spark.sql(\"INSERT INTO hospital-datalake.test_db.test_table VALUES (1, 'test')\")")

    print("\n[*] Stopping Spark Session...")
    spark.stop()

if __name__ == "__main__":
    test_connection()
