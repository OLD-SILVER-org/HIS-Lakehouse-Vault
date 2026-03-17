import sys
import os
import traceback
import gc
import time
from pyspark.sql.functions import current_timestamp, lit, col, to_timestamp, expr
from pyspark.sql.types import TimestampType, DateType, IntegerType, LongType, FloatType, DoubleType, BooleanType, StringType

# Add parent directory to sys.path to import utils
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '../../')))
from utils.spark_utils import SparkUtils

class IncrementalStreamingLoader:
    def __init__(self):
        self.utils = SparkUtils()
        self.spark = self.utils.get_spark_session("Incremental_Streaming_Loader_Job")
        
        # Optimize for local: fewer partitions reduce overhead per table
        if self.utils.config.is_local():
            self.spark.conf.set("spark.sql.shuffle.partitions", "4")
            self.spark.conf.set("spark.default.parallelism", "4")
        
        # Iceberg Catalog and Database
        self.catalog = "hospital_catalog"
        self.source_db = "hospital_db_sink"
        
        # Postgres Target Details
        self.target_db = "dwh"
        self.target_schema = "staging"
        
        checkpoint_bucket = os.getenv("MINIO_CHECKPOINT_BUCKET", "spark-checkpoint")
        self.checkpoint_base_path = f"s3a://{checkpoint_bucket}/streaming_loader/"

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
            print(f"[*] Found {len(table_list)} tables")
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
        try:
            col_df = self.spark.read.jdbc(
                url=url,
                table=query,
                properties=self.utils.get_postgres_properties()
            )
            return {row['column_name']: row['data_type'] for row in col_df.collect()}
        except Exception as e:
            msg = str(e)
            if "SQLState: 42P01" in msg or "relation" in msg.lower() and "does not exist" in msg.lower():
                 print(f"[!] Table {table_name} not found in Postgres schema '{self.target_schema}'")
                 return {} 
            return None

    def transform(self, df, target_cols_info):
        """
        Filters and casts data types to match Postgres exactly.
        """
        if not target_cols_info:
            return df
            
        target_col_names = list(target_cols_info.keys())
        spark_cols = df.columns
        final_cols = []
        
        for c in spark_cols:
            actual_name = next((tc for tc in target_col_names if tc.lower() == c.lower()), None)
            if actual_name:
                col_type = target_cols_info[actual_name].lower()
                
                if "timestamp" in col_type:
                    df = df.withColumn(c, col(c).cast(TimestampType()))
                elif "date" in col_type:
                    df = df.withColumn(c, col(c).cast(DateType()))
                elif "bigint" in col_type or "int8" in col_type:
                    df = df.withColumn(c, col(c).cast(LongType()))
                elif "integer" in col_type or "int4" in col_type or "int" in col_type:
                    df = df.withColumn(c, col(c).cast(IntegerType()))
                elif "boolean" in col_type or "bool" in col_type:
                    df = df.withColumn(c, col(c).cast(BooleanType()))
                elif any(t in col_type for t in ["numeric", "decimal", "real", "double", "float"]):
                    df = df.withColumn(c, col(c).cast(DoubleType()))
                
                if c != actual_name:
                    df = df.withColumnRenamed(c, actual_name)
                
                final_cols.append(actual_name)
        
        return df.select(*final_cols)

    def is_first_batch(self, batch_id, table_name, is_first_run_flag, micro_batch_df):
        """
        Helper function to handle Table Truncation and logging to load_tracker in Postgres BEFORE
        the micro-batch appends data.
        """
        if batch_id == 0 and is_first_run_flag[0]:
            print(f"[*] Executing PRE-LOAD tasks for {table_name}: Truncating Staging...")
            target_table = f"{self.target_schema}.{table_name.lower()}"
            
            # 1. Truncate staging table manually via spark jdbc execute
            # Try to get schema from an existing source table efficiently
            try:
                 schema_df = self.spark.createDataFrame([], micro_batch_df.schema)
                 schema_df.write.jdbc(
                     url=self.utils.get_jdbc_url(self.target_db),
                     table=target_table,
                     mode="overwrite",
                     properties={**self.utils.get_postgres_properties(), "truncate": "true"}
                 )
                 print(f"    ↳ Successfully truncated {target_table}.")
            except Exception as e:
                 print(f"    ↳ Warn: Failed to truncate {target_table}: {e}")
                 
            # Note: We don't log the Start time here because we want to log the FINAL count after
            # the batch is fully written.
            
            # Unset flag so it doesn't truncate again in subsequent microbatches
            is_first_run_flag[0] = False
            return True
        return False
        
    def log_load_tracker(self, table_name, batch_id, status, rows_loaded, error_msg=""):
        """
        Logs the status of a load to staging_metadata.load_tracker table.
        """
        try:
             # Create a small DataFrame to log to Postgres
             log_data = [(table_name, int(batch_id), status, int(rows_loaded), str(error_msg))]
             log_df = self.spark.createDataFrame(log_data, ["lake_table_name", "load_id", "status", "records_loaded", "error_message"])
             # Use current_timestamp() to set load_time
             log_df = log_df.withColumn("load_time", current_timestamp())
             
             # Reorder columns to match Postgres table
             log_df = log_df.select("lake_table_name", "load_id", "load_time", "status", "records_loaded", "error_message")
             
             print(f"[*] Logging status to staging_metadata.load_tracker for {table_name} (Status: {status})...")
             
             log_df.write.jdbc(
                 url=self.utils.get_jdbc_url(self.target_db),
                 table="staging_metadata.load_tracker",
                 mode="append",
                 properties=self.utils.get_postgres_properties()
             )
        except Exception as e:
            print(f"[✘] Failed to log to load_tracker for {table_name}: {e}")

    def _write_micro_batch(self, micro_batch_df, batch_id, table_name, target_cols, is_first_run_flag):
        """
        Function applied to each micro-batch in the stream.
        """
        if micro_batch_df.isEmpty():
            return
            
        print(f"[{table_name}] Processing micro-batch {batch_id}")
        
        try:
            # Check and Truncate staging table if it's the very first batch
            self.is_first_batch(batch_id, table_name, is_first_run_flag, micro_batch_df)
            
            # 1. Preprocess Time Columns
            df_processed = self.preprocess_time_columns(micro_batch_df)
            
            # 2. Transform types
            df_matched = self.transform(df_processed, target_cols)
            
            # 3. Write via JDBC (Append mode because we only pull new changes since last run)
            target_table = f"{self.target_schema}.{table_name.lower()}"
            jdbc_url = self.utils.get_jdbc_url(self.target_db)
            properties = self.utils.get_postgres_properties()
            
            # Count records for logging (Using a trick to get count from write or just defaulting to -1 if we skip it to save memory)
            # Actually, to be safe and informative, let's keep a simplified count or just skip it if it's too much.
            # If the user really needs it:
            records_count = df_matched.count() 
            
            df_matched.write.jdbc(
                url=jdbc_url,
                table=target_table,
                mode="append",
                properties=properties
            )
            print(f"[{table_name}] ↳ Successfully appended {records_count} rows to {target_table}")
            
            # 4. Log Success Status to Postgres
            self.log_load_tracker(table_name, batch_id, "SUCCESS", records_count)
            
        except Exception as e:
            print(f"[✘] Error in micro-batch for {table_name}: {str(e)}")
            traceback.print_exc()
            # 4. Log Failed Status
            self.log_load_tracker(table_name, batch_id, "FAILED", 0, str(e))

    def process_table_streaming(self, table_name):
        """
        Starts the structured stream for a single table.
        """
        target_cols = self.get_target_columns(table_name)
        if target_cols is None or len(target_cols) == 0:
            print(f"[!] Skipping {table_name}: Not found in target schema.")
            return None
            
        print(f"[*] Starting stream setup for {table_name}...")
        
        checkpoint_dir = f"{self.checkpoint_base_path}{table_name}/"
        
        # State to track if it's the first batch in this specific run (used to truncate)
        # We pass this array [True] into the foreachBatch so it can modify the reference value
        is_first_run_flag = [True] 

        # 1. Read Stream from Iceberg
        # We start from the latest snapshot if there's no checkpoint. 
        # But wait, since it's scheduled hourly, checkpoint will track the state.
        stream_df = self.spark.readStream \
            .format("iceberg") \
            .load(f"{self.catalog}.{self.source_db}.{table_name}")
            
        # 2. Write Stream via foreachBatch
        query = stream_df.writeStream \
            .outputMode("append") \
            .option("checkpointLocation", checkpoint_dir) \
            .foreachBatch(lambda df, batch_id: self._write_micro_batch(df, batch_id, table_name, target_cols, is_first_run_flag)) \
            .trigger(availableNow=True) \
            .start()
            
        return query

    def load(self):
        """
        Main entry point to run all streams.
        Processing tables sequentially to avoid 'Python worker failed to connect back' 
        errors on local Windows machine caused by concurrent streams.
        """
        table_list = self.get_list_table_from_lake()
        if not table_list:
            print("[!] No tables found.")
            return

        print(f"[*] Starting sequential processing for {len(table_list)} tables...")
        
        for table in table_list:
            try:
                query = self.process_table_streaming(table)
                if query is not None:
                    print(f"[*] Waiting for {table} to finish...")
                    query.awaitTermination()
                    query.stop() # Explicitly stop query
                    print(f"[✔] Finished {table}.")
                
                # Crucial for local Windows to avoid memory/thread bloat
                gc.collect()
                time.sleep(1) # Short pause to let threads stabilize
            except Exception as e:
                print(f"[✘] Stream failed for {table}: {e}")
                traceback.print_exc()

        print("\n[*] All tables processed.")

if __name__ == "__main__":
    loader = IncrementalStreamingLoader()
    loader.spark.sparkContext.setLogLevel("ERROR") 
    loader.load()
    try:
        loader.spark.stop()
    except Exception:
        # Ignore session stop errors on Windows which often occur after successful execution
        pass
