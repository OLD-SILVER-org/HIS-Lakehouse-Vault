#!/bin/sh
# Database initialization script: Restore first -> Create User & Grant permissions later

echo "🚀 [init-db.sh] Starting database initialization..."

# Define CDC User credentials (defaults)
CDC_SCHEMA=${CDC_SCHEMA:-pgsql_source}
CDC_DB=${POSTGRES_DB:-hospital_source}
CDC_USER=${CDC_USER:-thanhtinh}
CDC_PASSWORD=${CDC_PASSWORD:-thanhtinh@123}
CDC_PUBLICATION=${CDC_PUBLICATION:-hospital_pub}

# ==================================================================
# STEP 1: RESTORE DATA (Accept warnings)
# ==================================================================
echo "📦 [Step 1] Restoring data from dump file..."
pg_restore -U "$POSTGRES_USER" -d "$POSTGRES_DB" -v /tmp/hospital-source-dump || echo "⚠️ pg_restore finished with warnings (OK)"

# ==================================================================
# STEP 2: CREATE USER AND GRANT PERMISSIONS (Run SQL directly)
# ==================================================================
echo "👤 [Step 2] Creating User '$CDC_USER' and granting permissions..."

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    -- 1. Create User if not exists
    DO \$\$
    BEGIN
        IF NOT EXISTS (SELECT FROM pg_catalog.pg_user WHERE usename = '$CDC_USER') THEN
            CREATE USER $CDC_USER WITH REPLICATION PASSWORD '$CDC_PASSWORD';
        END IF;
    END
    \$\$;

    -- 2. Grant connection and schema access permissions
    GRANT CONNECT ON DATABASE $CDC_DB TO $CDC_USER;
    GRANT USAGE ON SCHEMA $CDC_SCHEMA TO $CDC_USER;
    GRANT SELECT ON ALL TABLES IN SCHEMA $CDC_SCHEMA TO $CDC_USER;

    -- 3. Automatically grant permissions for future tables
    ALTER DEFAULT PRIVILEGES IN SCHEMA $CDC_SCHEMA GRANT SELECT ON TABLES TO $CDC_USER;

    -- 4. Create Publication for Debezium
    CREATE PUBLICATION $CDC_PUBLICATION FOR ALL TABLES;
    ALTER PUBLICATION $CDC_PUBLICATION OWNER TO $CDC_USER;
EOSQL

echo "✅ [init-db.sh] Initialization complete !"