#!/bin/bash
set -e

echo "🔄 Pgpool Entrypoint starting..."

KEY_PATH="/pgpool_ssh_keys/id_rsa"
KEY_DIR="$(dirname "$KEY_PATH")"

# Ensure dir exists and is writable
mkdir -p "$KEY_DIR"
chmod 700 "$KEY_DIR"
chown postgres:postgres "$KEY_DIR"

# Generate key as postgres
if [ ! -f "$KEY_PATH" ]; then
  echo "🔐 Generating SSH keypair..."
  su - postgres -c "ssh-keygen -t rsa -b 4096 -f $KEY_PATH -N ''"
fi

# Link private key for failover
[ -L /etc/pgpool2/id_rsa ] || ln -sf "$KEY_PATH" /etc/pgpool2/id_rsa

# Switch to postgres and run pgpool
exec su postgres -c "pgpool -n -f /etc/pgpool2/pgpool.conf \
  -a /etc/pgpool2/pool_hba.conf \
  -F /etc/pgpool2/pool_passwd"
