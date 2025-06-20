#!/bin/sh
set -e

PGDATA="/var/lib/postgresql/data"
CONF_FILE="/etc/postgresql/postgresql.conf"
HBA_FILE="/etc/postgresql/pg_hba.conf"

if [ -s "$PGDATA/PG_VERSION" ]; then
  echo "✅ PostgreSQL already initialized"
else
  echo "🆕 Initializing database..."
  gosu postgres /usr/local/bin/initdb -D "$PGDATA"
  gosu postgres cp "$CONF_FILE" "$PGDATA/"
  gosu postgres cp "$HBA_FILE" "$PGDATA/"
  gosu postgres chown postgres:postgres "$PGDATA/postgresql.conf" "$PGDATA/pg_hba.conf"
fi

gosu postgres postgres -c config_file="$CONF_FILE" &
POSTGRES_PID=$!

for i in $(seq 1 30); do
  if pg_isready -U postgres > /dev/null 2>&1; then
    echo "✅ PostgreSQL is ready"
    break
  fi
  sleep 1
done

if ! pg_isready -U postgres > /dev/null 2>&1; then
  echo "❌ PostgreSQL did not become ready in time"
  kill $POSTGRES_PID
  exit 1
fi

psql -U postgres -d postgres -c "ALTER SYSTEM SET password_encryption = 'md5';"
psql -U postgres -d postgres -c "SELECT pg_reload_conf();"

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

wait $POSTGRES_PID

exec gosu postgres postgres -c config_file="$CONF_FILE"
