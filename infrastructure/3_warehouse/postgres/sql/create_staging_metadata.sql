CREATE database dwh;
\c dwh
------ staging metadata ------------
CREATE SCHEMA IF NOT EXISTS staging_metadata;

CREATE TABLE IF NOT EXISTS staging_metadata.snapshot_tracker (
  lake_table_name VARCHAR(255) PRIMARY KEY,
  last_snapshot_id BIGINT,
  last_load_time TIMESTAMP
);

CREATE TABLE IF NOT EXISTS staging_metadata.load_tracker (
  lake_table_name VARCHAR(255),
  load_id BIGINT,
  load_time TIMESTAMP,
  status VARCHAR(50),
  records_loaded BIGINT,
  error_message TEXT
);