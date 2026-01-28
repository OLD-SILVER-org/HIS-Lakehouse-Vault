-- ==========================================
-- CDC USER INITIALIZATION FOR DEBEZIUM
-- ==========================================

-- 1. Create CDC user (REPLICATION is a required privilege)
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_user WHERE usename = 'thanhtinh') THEN
        CREATE USER thanhtinh WITH REPLICATION PASSWORD 'thanhtinh@123';
    END IF;
END
$$;

-- 2. Grant connection privileges to the target database
GRANT CONNECT ON DATABASE hospital_source TO thanhtinh;

-- 3. Grant privileges on the target schema
-- Debezium needs USAGE to access the schema and SELECT for the initial snapshot
GRANT USAGE ON SCHEMA pgsql_source TO thanhtinh;
GRANT SELECT ON ALL TABLES IN SCHEMA pgsql_source TO thanhtinh;

-- Automatically grant SELECT on future tables
ALTER DEFAULT PRIVILEGES IN SCHEMA pgsql_source GRANT SELECT ON TABLES TO thanhtinh;

-- 4. Create Publication (Required for pgoutput plugin)
-- Note: This command must be run by a SUPERUSER or the OWNER of the tables.
-- If Debezium is left to create it, the 'thanhtinh' user needs OWNER or SUPERUSER rights.
-- The safest approach is to create it manually here using the 'postgres' user.
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_publication WHERE pubname = 'hospital_pub') THEN
        CREATE PUBLICATION hospital_pub FOR ALL TABLES;
    END IF;
END
$$;

-- 5. Check replication slots (Optional, Debezium usually creates slots if it has sufficient rights)
-- SELECT * FROM pg_replication_slots;
