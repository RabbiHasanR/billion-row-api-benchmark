#!/bin/bash
set -e

cp /etc/postgresql/postgresql.conf /var/lib/postgresql/data/postgresql.conf
cp /etc/postgresql/pg_hba.conf /var/lib/postgresql/data/pg_hba.conf
chown postgres:postgres /var/lib/postgresql/data/postgresql.conf /var/lib/postgresql/data/pg_hba.conf

psql -U postgres -d postgres <<-'EOSQL'
DO $$
BEGIN
  IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'replicator') THEN
    CREATE ROLE replicator WITH REPLICATION LOGIN ENCRYPTED PASSWORD '123456';
  END IF;
END
$$;
EOSQL

psql -U postgres -d postgres <<-'EOSQL'
DO $$
BEGIN
  IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'pgpool_healthcheck') THEN
    CREATE USER pgpool_healthcheck WITH PASSWORD '12345' REPLICATION LOGIN;
  END IF;
END
$$;

GRANT CONNECT ON DATABASE testdb TO pgpool_healthcheck;
GRANT USAGE ON SCHEMA public TO pgpool_healthcheck;
GRANT SELECT ON pg_stat_replication TO pgpool_healthcheck;
EOSQL

psql -U postgres -d ${POSTGRES_DB:-testdb} -f /docker-entrypoint-initdb.d/schema.sql
psql -U postgres -d ${POSTGRES_DB:-testdb} -f /docker-entrypoint-initdb.d/raw_queries.sql

exec gosu postgres postgres -c config_file=/etc/postgresql/postgresql.conf
