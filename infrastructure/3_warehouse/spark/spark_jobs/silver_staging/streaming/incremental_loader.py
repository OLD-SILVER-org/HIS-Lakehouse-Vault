import sys
import os
import traceback
from datetime import datetime
import psycopg2
from pyspark.sql.functions import current_timestamp, lit, col, to_timestamp, desc, max as spark_max,  monotonically_increasing_id
from pyspark.sql.types import TimestampType, DateType, IntegerType, LongType, FloatType, DoubleType, BooleanType, StringType
from pyspark import StorageLevel  

# Add parent directory to sys.path to import utils
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '../../')))
from utils.spark_utils import SparkUtils
from utils.slack_utils import SlackNotifier

class IncrementalBatchLoader:
    def __init__(self):
        self.utils = SparkUtils()
        self.spark = self.utils.get_spark_session("IncrementalBatchLoader")
        
        # Iceberg Catalog and Database
        self.catalog = "hospital_catalog"
        self.source_db = "hospital_db_sink"
        
        # Postgres Target Details
        self.target_db="dwh"
        self.target_schema = "staging"
        self.notifier = SlackNotifier()

        self.batch_size = int(os.getenv("SPARK_BATCH_SIZE", "200"))


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
            print(f"[*] Columns in Postgres for {table_name}: collected {col_df.count()} columns")
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
        target_table = f"{self.target_schema}.{table_name.lower()}"
        source_table= f"{self.catalog}.{self.source_db}.{table_name}"

        try:
            jdbc_url = self.utils.get_jdbc_url(self.target_db)
            base_props = self.utils.get_postgres_properties()
            load_props = {
                **base_props,
                "batchsize": str(self.batch_size),
                "reWriteBatchedInserts": "true"
            }
            table_cols = df.columns
            print(f"[*] Writing to {target_table} (Wide table: {len(table_cols)} cols). Forcing coalesce(1) to avoid OOM 134.")
            
            # Coalesce(1) 
            df.coalesce(1).write.jdbc(                       
                url=jdbc_url, table=target_table,
                mode="append", properties=load_props)
              
            new_snapshot_id = self.spark.read \
                .format("iceberg") \
                .load(f"{source_table}.snapshots") \
                .orderBy(desc("committed_at")) \
                .limit(1) \
                .collect()[0]["snapshot_id"]

        except Exception as e:
            df.unpersist()
            self.notifier.send_message(f"[!] Error writing to {target_table}: {str(e)}")
            raise e
        return new_snapshot_id
            
            
    def update_snapshot_tracker(self, table_name, df, new_snapshot_id=None):
        """Update the watermark. If updated_at is missing, use current time."""
        updated_at_col = next((c for c in df.columns if c.lower() == "updated_at"), None)

        try:
            max_time = df.select(spark_max(col(updated_at_col))).collect()[0][0] \
                if updated_at_col else datetime.now()

            if not max_time:
                return

            with psycopg2.connect(
                host=self.utils.config.WAREHOUSE_POSTGRES_HOST,
                port=self.utils.config.WAREHOUSE_POSTGRES_PORT,
                user=self.utils.config.WAREHOUSE_POSTGRES_USER,
                password=self.utils.config.WAREHOUSE_POSTGRES_PASSWORD,
                dbname=self.target_db,
                options="-c timezone=UTC"
            ) as conn:
                with conn.cursor() as cur:
                    cur.execute("""
                        INSERT INTO staging_metadata.snapshot_tracker
                            (lake_table_name, last_snapshot_id, last_load_time)
                        VALUES (%s, %s, %s)
                        ON CONFLICT (lake_table_name) DO UPDATE SET
                            last_snapshot_id = EXCLUDED.last_snapshot_id,
                            last_load_time   = EXCLUDED.last_load_time
                    """, (table_name.lower(), new_snapshot_id, max_time))
                conn.commit()
            print(f"[*] Successfully updated snapshot_tracker for {table_name.lower()}")

        except Exception as e:
            self.notifier.send_message(f"[!] Could not update snapshot_tracker for {table_name}: {e}")
            
    def update_load_tracker(self, table_name, status, batch_size, error_message=None):
        try:
            load_type = "INCREMENTAL"
            load_time = datetime.now()
           
            schema = "lake_table_name STRING, load_type STRING, load_time TIMESTAMP, status STRING, batch_size INT, error_message STRING"
            meta_df = self.spark.createDataFrame(
                [(table_name.lower(), load_type, load_time, status, batch_size, error_message)],
                schema=schema
            )
            meta_df.write.jdbc(
                url=self.utils.get_jdbc_url(self.target_db),
                table="staging_metadata.load_tracker",
                mode="append",
                properties=self.utils.get_postgres_properties()
            )
        except Exception as e:
            print(f"[!] Could not update load_tracker: {e}")


    def get_last_snapshot_id(self, table_name):
        try:
            query = f"""
                (SELECT last_snapshot_id 
                 FROM staging_metadata.snapshot_tracker 
                 WHERE lake_table_name = '{table_name.lower()}'
                 ORDER BY last_load_time DESC
                 LIMIT 1) as snapshot_query
            """
            url = self.utils.get_jdbc_url(self.target_db)
            snapshot_df = self.spark.read.jdbc(
                url=url,
                table=query,
                properties=self.utils.get_postgres_properties()
            )
            if snapshot_df.count() > 0:
                return snapshot_df.collect()[0]["last_snapshot_id"]
            else:
                return None
        except Exception as e:
            print(f"[!] Error fetching last snapshot id for {table_name}: {str(e)}")
            return None
        
    def read_newest_data(self, table_name, last_snapshot_id):
        source_table = f"{self.catalog}.{self.source_db}.{table_name}"
        try:
            if last_snapshot_id:
                
                latest_snapshot = self.spark.read \
                    .format("iceberg") \
                    .load(f"{source_table}.snapshots") \
                    .orderBy(desc("committed_at")) \
                    .limit(1) \
                    .collect()[0]["snapshot_id"]

                if latest_snapshot == last_snapshot_id:
                    print(f"[*] No new snapshots for {table_name}, skipping.")
                    return None

                df = self.spark.read \
                    .format("iceberg") \
                    .option("start-snapshot-id", last_snapshot_id) \
                    .load(source_table)
            else:
                df = self.spark.read \
                    .format("iceberg") \
                    .load(source_table)
            return df
        except Exception as e:
            print(f"[!] Error reading {table_name}: {str(e)}")
            return None

    def process_table(self, table_name):
        print(f"\n--- Processing Table: {table_name} ---")
        try:

            target_cols = self.get_target_columns(table_name)
            
            if target_cols is None:
                return
            if len(target_cols) == 0:
                return
            last_snapshot_id = self.get_last_snapshot_id(table_name)
            df = self.read_newest_data(table_name, last_snapshot_id)
            if df is None:
                print(f"[*] Skipping {table_name} — no new data.")
                return

            df = self.preprocess_time_columns(df)
            df_matched = self.transform(df, target_cols)
            
            new_snapshot_id = self.write_to_staging(table_name, df_matched)
            self.update_snapshot_tracker(table_name, df_matched, new_snapshot_id=new_snapshot_id)
            self.update_load_tracker(table_name, status="SUCCESS", batch_size=self.batch_size)
            self.notifier.send_message(f"✅ *Success Processing Table*: `{table_name}`\n> Batch Size: {self.batch_size}")

        except Exception as e:
            error_msg = f"[✘] Failed to process {table_name}: {str(e)}"
            self.update_load_tracker(table_name, status="FAILED", error_message=error_msg, batch_size=self.batch_size)
            self.notifier.send_message(f"❌ *Error Processing Table*: `{table_name}`\n> {str(e)}")
        finally:
            self.spark.catalog.clearCache()


    def load(self):
        """
        Main entry point to load all tables from Lake to Staging.
        """
        table_list = self.get_list_table_from_lake()
        
        if not table_list:
            print("[!] No tables found in the lake to load.")
            self.notifier.send_message("⚠️ *Incremental Load Warning*: No tables found in the lake to load.")
            return

        self.notifier.send_message(f"🚀 *Incremental Load Started*: Starting to load {len(table_list)} tables from Lake to Staging.")

        for table in table_list:
            self.process_table(table)
        
        print("\n[*] Incremental Load process finished.")
        self.notifier.send_message("✅ *Incremental Load Finished*: Data loading process completed successfully!")

if __name__ == "__main__":
    loader = IncrementalBatchLoader()
    loader.spark.sparkContext.setLogLevel("ERROR")
    loader.load()
    try:
        loader.spark.stop()
    except Exception:
        pass