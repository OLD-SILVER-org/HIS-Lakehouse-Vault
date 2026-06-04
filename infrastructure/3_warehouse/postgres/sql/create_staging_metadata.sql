-- CREATE database dwh;
-- \c dwh

------ staging metadata ------------
CREATE SCHEMA IF NOT EXISTS staging_metadata;

CREATE TABLE IF NOT EXISTS staging_metadata.snapshot_tracker (
  lake_table_name  VARCHAR(255) PRIMARY KEY,
  last_load_time   TIMESTAMP
);

CREATE TABLE  IF NOT EXISTS staging_metadata.load_tracker (
  id               BIGSERIAL PRIMARY KEY,  -- tự sinh, không cần truyền vào
  lake_table_name  VARCHAR(255),
  load_type        VARCHAR(20),            -- INIT / INCREMENTAL
  load_time        TIMESTAMP,
  status           VARCHAR(20),            -- SUCCESS / FAILED
  batch_size   BIGINT,
  error_message    TEXT
);