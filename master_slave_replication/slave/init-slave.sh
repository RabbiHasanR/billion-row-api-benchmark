#!/bin/bash
set -e

# Check required env vars
if [ -z "$MASTER_HOST" ]; then
  echo "Error: MASTER_HOST is not set!"
  exit 1
fi

until pg_isready -h "$MASTER_HOST" -p 5432; do
  echo 'Waiting for master...'
  sleep 2
done

rm -rf /var/lib/postgresql/data/*

PGPASSWORD="$REPLICATOR_PASSWORD" pg_basebackup -h "$MASTER_HOST" -D /var/lib/postgresql/data -U "$REPLICATOR_USER" -v -P --wal-method=stream

# After pg_basebackup step
touch /var/lib/postgresql/data/standby.signal

# Fix permissions and ownership
chown -R postgres:postgres /var/lib/postgresql/data
chmod 700 /var/lib/postgresql/data

exec gosu postgres postgres -c config_file=/etc/postgresql/postgresql.conf

echo "✅ Slave initialized. Ready to start."