import sys
import os
import traceback
from pyspark.sql.functions import current_timestamp, lit, col
from pyspark.sql.types import TimestampType, DateType, IntegerType, LongType, FloatType, DoubleType, BooleanType, StringType

# Add parent directory to sys.path to import utils
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '../../')))
from utils.spark_utils import SparkUtils
from utils.slack_utils import SlackNotifier
from abc import ABC, abstractmethod


class ElasticStreaming(ABC):
    def __init__(self, source, target_index, id_col):
        self.source = source
        self.target_index = target_index
        self.id_col = id_col
        self.utils = SparkUtils()
        self.spark = self.utils.get_spark_session("Elastic_Streaming_Job")

        # Iceberg Catalog and Minio
        self.source_sink = "hospital_catalog.hospital_db_sink"

        # Slack Notifier
        self.notifier = SlackNotifier()

        # Auth
        self.user = "elastic"
        self.password = os.getenv("ES_PASSWORD", "")

        # Checkpoint
        checkpoint_bucket = os.getenv("MINIO_CHECKPOINT_BUCKET", "spark-checkpoint")
        self.checkpoint_base_path = f"s3a://{checkpoint_bucket}/elastic_streaming/"

    @abstractmethod
    def extract_stream(self):
        """Return a streaming DataFrame from Iceberg source."""
        pass

    @abstractmethod
    def transform(self, df):
        pass

    def send_slack_message(self, message: str):
        if self.notifier:
            self.notifier.send_message(message)

    def _get_es_conf(self):
        """Build Elasticsearch write configuration."""
        es_conf = {
            "es.nodes": "elasticsearch",
            "es.port": "9200",
            "es.resource": self.target_index,
            "es.net.http.auth.user": self.user,
            "es.net.http.auth.pass": self.password,
            "es.nodes.wan.only": "true",
            "es.index.auto.create": "true",
            "es.write.operation": "upsert" if self.id_col else "index",
            "es.batch.size.entries": "5000",
            "es.batch.size.bytes": "10mb",
            "es.batch.write.retry.count": "3",
            "es.batch.write.retry.wait": "10s",
            "es.batch.write.refresh": "false",
            "es.batch.flush.timeout": "120s",
            "es.mapping.id": self.id_col if self.id_col else None
        }
        # Remove None values from config
        return {k: v for k, v in es_conf.items() if v is not None}

    def _write_micro_batch(self, micro_batch_df, batch_id):
        """
        Function applied to each micro-batch in the stream.
        Writes the micro-batch to Elasticsearch.
        """
        if micro_batch_df.isEmpty():
            return

        table_name = self.source
        print(f"[{table_name}] Processing micro-batch {batch_id} for ES index: {self.target_index}")

        try:
            # 1. Transform
            df_transformed = self.transform(micro_batch_df)

            # 2. Count records
            row_count = df_transformed.count()

            # 3. Write to Elasticsearch
            es_conf = self._get_es_conf()
            df_transformed.write.format("org.elasticsearch.spark.sql") \
                .options(**es_conf) \
                .mode("append") \
                .save()

            print(f"[{table_name}] ↳ Successfully wrote {row_count} rows to ES index: {self.target_index}")

        except Exception as e:
            error_msg = (
                f"❌ Elastic Streaming FAILED for {table_name} -> {self.target_index}\n"
                f"Batch ID: {batch_id}\n"
                f"Error: {str(e)}\n{traceback.format_exc()}"
            )
            print(error_msg)
            self.send_slack_message(error_msg)
            raise e

    def run(self):
        """
        Main entry point: start the streaming query and await termination.
        """
        table_name = self.source
        self.send_slack_message(
            f"🚀 Elastic Streaming: Starting stream for {table_name} -> {self.target_index}"
        )

        try:
            # 1. Read Stream from Iceberg
            stream_df = self.extract_stream()

            # 2. Checkpoint location
            checkpoint_dir = f"{self.checkpoint_base_path}{table_name}/"

            # 3. Write Stream via foreachBatch
            query = stream_df.writeStream \
                .outputMode("append") \
                .option("checkpointLocation", checkpoint_dir) \
                .foreachBatch(lambda df, batch_id: self._write_micro_batch(df, batch_id)) \
                .trigger(availableNow=True) \
                .start()

            # 4. Await termination
            query.awaitTermination()
            query.stop()

            self.send_slack_message(
                f"✅ Elastic Streaming: Finished processing for {table_name} -> {self.target_index}"
            )

        except Exception as e:
            error_msg = (
                f"🚨 Elastic Streaming CRASHED for {table_name} -> {self.target_index}\n"
                f"Error: {str(e)}"
            )
            print(error_msg)
            self.send_slack_message(error_msg)
            raise e
