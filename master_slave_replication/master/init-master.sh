#!/bin/bash
set -e

PGDATA="/var/lib/postgresql/data"
CONF="$PGDATA/postgresql.conf"
CURRENT_PRIMARY_HOST="slave_db_one"
REPL_USER="replicator"
REPL_PASS="123456"
PG_HBA="/etc/postgresql/pg_hba.conf"
PG_CONF="/etc/postgresql/postgresql.conf"
DB_NAME="${POSTGRES_DB:-testdb}"

# Clean up stale PID
rm -f "$PGDATA/postmaster.pid" || true

# Ensure data directory ownership
chown -R postgres:postgres "$PGDATA"
chmod 700 "$PGDATA"

# If already initialized, just start PostgreSQL
if [ -f "$PGDATA/PG_VERSION" ]; then
  echo "✅ Detected existing PostgreSQL data. Starting PostgreSQL..."
  exec gosu postgres postgres -c config_file="$CONF"
fi

# If another node is up, rejoin as standby
echo "🔍 Checking if $CURRENT_PRIMARY_HOST is reachable as primary..."
if pg_isready -h "$CURRENT_PRIMARY_HOST" -p 5432 -U "$REPL_USER" > /dev/null 2>&1; then
  echo "📦 Primary detected at $CURRENT_PRIMARY_HOST — reinitializing as standby..."
  rm -rf "$PGDATA"/*
  PGPASSWORD="$REPL_PASS" gosu postgres pg_basebackup \
    -h "$CURRENT_PRIMARY_HOST" \
    -D "$PGDATA" \
    -U "$REPL_USER" \
    -v -P --wal-method=stream
  touch "$PGDATA/standby.signal"
  chown -R postgres:postgres "$PGDATA"
  chmod 700 "$PGDATA"
  echo "🌀 Standby initialized. Starting PostgreSQL..."
  exec gosu postgres postgres -c config_file="$CONF"
fi

echo "🚀 No primary reachable. Bootstrapping fresh PostgreSQL cluster..."
gosu postgres initdb -D "$PGDATA" --username=postgres

# Apply configs
cp "$PG_CONF" "$PGDATA/postgresql.conf"
cp "$PG_HBA" "$PGDATA/pg_hba.conf"
chown postgres:postgres "$PGDATA/postgresql.conf" "$PGDATA/pg_hba.conf"

# Start PostgreSQL temporarily to create roles & schema
gosu postgres pg_ctl -D "$PGDATA" -o "-c config_file=$CONF" -w start

# Create roles if needed
psql -U postgres <<-EOSQL
DO \$\$
BEGIN
  IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'replicator') THEN
    CREATE ROLE replicator WITH REPLICATION LOGIN ENCRYPTED PASSWORD '$REPL_PASS';
  END IF;
  IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'pgpool_healthcheck') THEN
    CREATE USER pgpool_healthcheck WITH PASSWORD '12345' REPLICATION LOGIN;
  END IF;
END
\$\$;
EOSQL

# Create the database if it doesn't exist
psql -U postgres -tc "SELECT 1 FROM pg_database WHERE datname = '$DB_NAME'" | grep -q 1 || \
  psql -U postgres -c "CREATE DATABASE $DB_NAME;"

# Grant privileges
psql -U postgres <<-EOSQL
GRANT CONNECT ON DATABASE $DB_NAME TO pgpool_healthcheck;
GRANT USAGE ON SCHEMA public TO pgpool_healthcheck;
GRANT SELECT ON pg_stat_replication TO pgpool_healthcheck;
EOSQL

# Load schema and queries
psql -U postgres -d "$DB_NAME" -f /docker-entrypoint-initdb.d/schema.sql
psql -U postgres -d "$DB_NAME" -f /docker-entrypoint-initdb.d/raw_queries.sql

# Shutdown temporary instance
gosu postgres pg_ctl -D "$PGDATA" -m fast -w stop

echo "✅ Master initialized. Launching production PostgreSQL..."
exec gosu postgres postgres -c config_file="$CONF"
