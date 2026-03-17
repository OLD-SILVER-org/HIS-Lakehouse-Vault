import sys
import os
import traceback
from pyspark.sql.functions import current_timestamp, lit, col, to_timestamp
from pyspark.sql.types import TimestampType, DateType, IntegerType, LongType, FloatType, DoubleType, BooleanType, StringType

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
        self.target_db="dwh"
        self.target_schema = "staging"

    def preprocess_time_columns(self, df):
        """
        Preprocesses created_at and updated_at columns before casting.
        If they are LongType (epoch microseconds), converts them to Timestamp.
        If they are StringType (ISO 8601), converts them to Timestamp.
        """
        time_columns = ["created_at", "updated_at"]
        for c in df.columns:
            if c.lower() in time_columns:
                col_type = type(df.schema[c].dataType)
                if col_type == LongType:
                    df = df.withColumn(c, to_timestamp(col(c) / 1000000.0))
                elif col_type == StringType:
                    df = df.withColumn(c, to_timestamp(col(c)))
        return df

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

    def get_target_columns(self, table_name):
        """
        Fetches the column list from Postgres to ensure Spark only sends existing columns.
        """
        query = f"""
            (SELECT column_name, data_type 
             FROM information_schema.columns 
             WHERE table_schema = '{self.target_schema}' 
               AND table_name = '{table_name.lower()}') as col_query
        """
        url = self.utils.get_jdbc_url(self.target_db)
        print(f"[*] Fetching schema for {table_name} from Postgres...")
        try:
            col_df = self.spark.read.jdbc(
                url=url,
                table=query,
                properties=self.utils.get_postgres_properties()
            )
            # Returns a dict {column_name: data_type}
            return {row['column_name']: row['data_type'] for row in col_df.collect()}
        except Exception as e:
            msg = str(e)
            if "SQLState: 42P01" in msg or "relation" in msg.lower() and "does not exist" in msg.lower():
                 print(f"[!] Table {table_name} not found in Postgres schema '{self.target_schema}'")
                 return {} 
            
            print(f"[✘] Connection or query error for {table_name}: {msg}")
            return None

    def transform(self, df, target_cols_info):
        """
        Filters and casts data types to match Postgres exactly.
        target_cols_info: dict {column_name: data_type}
        """
        if not target_cols_info:
            return df
            
        target_col_names = list(target_cols_info.keys())
        spark_cols = df.columns
        
        # 1. Find common columns (case-insensitive)
        final_cols = []
        for c in spark_cols:
            actual_name = next((tc for tc in target_col_names if tc.lower() == c.lower()), None)
            if actual_name:
                # 2. Cast types based on Postgres data type
                col_type = target_cols_info[actual_name].lower()
                
                # Timestamp & Date
                if "timestamp" in col_type:
                    df = df.withColumn(c, col(c).cast(TimestampType()))
                elif "date" in col_type:
                    df = df.withColumn(c, col(c).cast(DateType()))
                
                # Integer & BigInt
                elif "bigint" in col_type or "int8" in col_type:
                    df = df.withColumn(c, col(c).cast(LongType()))
                elif "integer" in col_type or "int4" in col_type or "int" in col_type:
                    df = df.withColumn(c, col(c).cast(IntegerType()))
                
                # Boolean
                elif "boolean" in col_type or "bool" in col_type:
                    df = df.withColumn(c, col(c).cast(BooleanType()))
                
                # Floating point / Numeric
                elif any(t in col_type for t in ["numeric", "decimal", "real", "double", "float"]):
                    df = df.withColumn(c, col(c).cast(DoubleType()))
                
                # Rename to match Postgres exactly (case-sensitive)
                if c != actual_name:
                    df = df.withColumnRenamed(c, actual_name)
                
                final_cols.append(actual_name)
        
        return df.select(*final_cols)

    def write_to_staging(self, table_name, df):
        """
        Writes data to the Postgres staging table.
        """
        # Using 2-part name for Postgres (schema.table) since we're already connected to the database.
        target_table = f"{self.target_schema}.{table_name.lower()}"
        print(f"[*] Loading data to {target_table}...")
        
        try:
            jdbc_url = self.utils.get_jdbc_url(self.target_db)
            print(f"[*] Connecting to: {jdbc_url}")
            properties = self.utils.get_postgres_properties()
            
            # Using overwrite + truncate to clear data without dropping the table
            df.write.jdbc(
                url=jdbc_url,
                table=target_table,
                mode="overwrite",
                properties={**properties, "truncate": "true"}
            )
            print(f"[✔] Successfully loaded {target_table} ({df.count()} records)")
        except Exception as e:
            print(f"[✘] Error writing {table_name} to staging: {str(e)}")
            traceback.print_exc()

    def process_table(self, table_name):
        """
        Full pipeline for a single table with column matching.
        """
        print(f"\n--- Processing Table: {table_name} ---")
        try:
            # 1. Fetch existing columns in Postgres
            target_cols = self.get_target_columns(table_name)
            
            if target_cols is None:
                print(f"[!] Skipping {table_name}: Unable to connect to Postgres or query information_schema.")
                return
                
            if len(target_cols) == 0:
                print(f"[!] Skipping {table_name}: Table not found in Postgres schema '{self.target_schema}'")
                return

            # 2. Read from Iceberg (MinIO)
            df = self.spark.read.table(f"{self.catalog}.{self.source_db}.{table_name}")
            
            # 2.5 Preprocess time columns
            df = self.preprocess_time_columns(df)
            
            # 3. Transform (Filter to match Postgres columns)
            df_matched = self.transform(df, target_cols)
            
            # 4. Write to Postgres
            self.write_to_staging(table_name, df_matched)
            
        except Exception as e:
            print(f"[✘] Failed to process {table_name}: {str(e)}")

    def load(self):
        """
        Main entry point to load all tables from Lake to Staging.
        """
        table_list = self.get_list_table_from_lake()
        
        if not table_list:
            print("[!] No tables found in the lake to load.")
            return

        for table in table_list:
            self.process_table(table)
        
        print("\n[*] Initial Load process finished.")

if __name__ == "__main__":
    loader = InitialLoader()
    loader.spark.sparkContext.setLogLevel("ERROR") 
    loader.load()
    try:
        loader.spark.stop()
    except Exception:
        pass
