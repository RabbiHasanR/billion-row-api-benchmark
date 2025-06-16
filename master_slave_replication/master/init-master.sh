#!/bin/bash
set -e

# Copy your custom configs into the data directory
cp /etc/postgresql/postgresql.conf /var/lib/postgresql/data/postgresql.conf
cp /etc/postgresql/pg_hba.conf /var/lib/postgresql/data/pg_hba.conf

# Make sure permissions are correct
chown postgres:postgres /var/lib/postgresql/data/postgresql.conf /var/lib/postgresql/data/pg_hba.conf


# Create replication user if not exists
psql -U postgres <<-EOSQL
    DO \$\$
    BEGIN
        IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'replicator') THEN
            CREATE ROLE replicator WITH REPLICATION LOGIN ENCRYPTED PASSWORD '123456';
        END IF;
    END
    \$\$;
EOSQL

# Create pgpool_healthcheck user if not exists and grant connect to testdb
psql -U postgres <<-EOSQL
    DO \$\$
    BEGIN
        IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'pgpool_healthcheck') THEN
            CREATE USER pgpool_healthcheck WITH PASSWORD '12345' REPLICATION LOGIN;
        END IF;
    END
    \$\$;

    -- Grant required privileges on 'testdb' to pgpool_healthcheck
    GRANT CONNECT ON DATABASE testdb TO pgpool_healthcheck;
    GRANT USAGE ON SCHEMA public TO pgpool_healthcheck;

    -- Grant SELECT privilege on replication-related system catalogs
    GRANT SELECT ON pg_stat_replication TO pgpool_healthcheck;
EOSQL


# Run schema.sql
psql -U postgres -d ${POSTGRES_DB:-testdb} -f /docker-entrypoint-initdb.d/schema.sql

# Run raw_queries.sql
psql -U postgres -d ${POSTGRES_DB:-testdb} -f /docker-entrypoint-initdb.d/raw_queries.sql