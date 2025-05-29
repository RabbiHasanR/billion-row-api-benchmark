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
