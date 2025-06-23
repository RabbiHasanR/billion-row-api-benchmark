#!/bin/bash
set -e


psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    DO \$\$
    BEGIN
      IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'replicator') THEN
        CREATE ROLE replicator WITH REPLICATION LOGIN ENCRYPTED PASSWORD '123456';
      END IF;
    END
    \$\$;

    DO \$\$
    BEGIN
      IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'pgpool_healthcheck') THEN
        CREATE USER pgpool_healthcheck WITH PASSWORD '12345' REPLICATION LOGIN;
      END IF;
    END
    \$\$;

    GRANT CONNECT ON DATABASE ${POSTGRES_DB:-testdb} TO pgpool_healthcheck;
    GRANT USAGE ON SCHEMA public TO pgpool_healthcheck;
    GRANT SELECT ON pg_stat_replication TO pgpool_healthcheck;

    -- Create the new PGPOOL_USER for read/write operations
    DO \$\$
    BEGIN
      IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'test_user') THEN
        CREATE USER test_user WITH PASSWORD '12345';
      END IF;
    END
    \$\$;

    -- Grant all privileges on the database to the new user
    -- GRANT ALL PRIVILEGES ON DATABASE ${POSTGRES_DB:-testdb} TO test_user;

     -- Grant CONNECT privilege on the database
    GRANT CONNECT ON DATABASE ${POSTGRES_DB:-testdb} TO test_user;

    -- Grant USAGE and CREATE privilege on the public schema
    GRANT USAGE, CREATE ON SCHEMA public TO test_user;

    -- Grant all privileges on future tables and sequences in the public schema
    ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL PRIVILEGES ON TABLES TO test_user;
    ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL PRIVILEGES ON SEQUENCES TO test_user;
    ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL PRIVILEGES ON FUNCTIONS TO test_user;
EOSQL

