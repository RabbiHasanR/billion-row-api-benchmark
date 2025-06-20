#!/bin/bash
set -e

# # Copy your custom configs into the data directory
# cp /etc/postgresql/postgresql.conf /var/lib/postgresql/data/postgresql.conf
# cp /etc/postgresql/pg_hba.conf /var/lib/postgresql/data/pg_hba.conf

# # Make sure permissions are correct
# chown postgres:postgres /var/lib/postgresql/data/postgresql.conf /var/lib/postgresql/data/pg_hba.conf

# # Wait for PostgreSQL to start
# until pg_isready -U postgres; do
#   sleep 1
# done

# echo "✅ Master initialized. Ready to start."

# # Create replication user if not exists
# psql -U postgres <<-EOSQL
#     DO \$\$
#     BEGIN
#         IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'replicator') THEN
#             CREATE ROLE replicator WITH REPLICATION LOGIN ENCRYPTED PASSWORD '123456';
#         END IF;
#     END
#     \$\$;
# EOSQL



echo "🚀 Custom entrypoint started"

# Copy custom configs before DB starts
echo "📁 Copying config files..."
cp /etc/postgresql/postgresql.conf /var/lib/postgresql/data/
cp /etc/postgresql/pg_hba.conf /var/lib/postgresql/data/
chown postgres:postgres /var/lib/postgresql/data/postgresql.conf /var/lib/postgresql/data/pg_hba.conf

# Hand over to the official entrypoint to initialize/start the DB
echo "📦 Running official docker-entrypoint.sh"
exec docker-entrypoint.sh postgres &
POSTGRES_PID=$!

# Wait for DB to be ready
echo "⏳ Waiting for PostgreSQL to be ready..."
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


echo "👤 Creating replicator user..."
psql -U postgres -d postgres <<-'EOSQL'
DO $$
BEGIN
  IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'replicator') THEN
    CREATE ROLE replicator WITH REPLICATION LOGIN ENCRYPTED PASSWORD '123456';
  END IF;
END
$$;
EOSQL

# Create pgpool_healthcheck user
echo "🩺 Creating pgpool_healthcheck user..."
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

# Run schema.sql
psql -U postgres -d ${POSTGRES_DB:-testdb} -f /docker-entrypoint-initdb.d/schema.sql

# Run raw_queries.sql
psql -U postgres -d ${POSTGRES_DB:-testdb} -f /docker-entrypoint-initdb.d/raw_queries.sql


wait $POSTGRES_PID

# Create replication user with explicit error checking
# echo "Creating replicator user..."
# psql -v ON_ERROR_STOP=1 -U postgres <<-EOSQL
#   DO \$\$
#   BEGIN
#     RAISE NOTICE 'Checking for replicator user...';
#     IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'replicator') THEN
#       RAISE NOTICE 'Creating replicator user...';
#       CREATE ROLE replicator WITH REPLICATION LOGIN ENCRYPTED PASSWORD '123456';
#       RAISE NOTICE 'Replicator user created successfully';
#     ELSE
#       RAISE NOTICE 'Replicator user already exists';
#     END IF;
#   EXCEPTION WHEN OTHERS THEN
#     RAISE EXCEPTION 'Error creating replicator: %', SQLERRM;
#   END
#   \$\$;
  
#   -- Verify creation
#   SELECT rolname, rolreplication FROM pg_roles WHERE rolname = 'replicator';
# EOSQL

# # Create pgpool_healthcheck user if not exists and grant connect to testdb
# psql -U postgres <<-EOSQL
#     DO \$\$
#     BEGIN
#         IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'pgpool_healthcheck') THEN
#             CREATE USER pgpool_healthcheck WITH PASSWORD '12345' REPLICATION LOGIN;
#         END IF;
#     END
#     \$\$;

#     -- Grant required privileges on 'testdb' to pgpool_healthcheck
#     GRANT CONNECT ON DATABASE testdb TO pgpool_healthcheck;
#     GRANT USAGE ON SCHEMA public TO pgpool_healthcheck;

#     -- Grant SELECT privilege on replication-related system catalogs
#     GRANT SELECT ON pg_stat_replication TO pgpool_healthcheck;
# EOSQL







