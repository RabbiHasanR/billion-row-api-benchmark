#!/bin/bash
set -e

failed_node=$1
new_master=$2

KEY_PATH="/etc/pgpool2/id_rsa"
SSH_USER="postgres"
SSH_OPTIONS="-i $KEY_PATH -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o BatchMode=yes -o ConnectTimeout=5"

echo "⚠️ Failover triggered. Failed node: $failed_node, Promoting: $new_master"

# Check SSH key exists
if [ ! -f "$KEY_PATH" ]; then
    echo "❌ Error: SSH key not found at $KEY_PATH"
    exit 1
fi

# Check SSH connectivity
if ! ssh $SSH_OPTIONS ${SSH_USER}@$new_master "echo SSH OK"; then
    echo "❌ Error: SSH connection to $new_master failed!"
    exit 1
fi

# Promote the new master
ssh $SSH_OPTIONS ${SSH_USER}@$new_master "pg_ctl promote -D /var/lib/postgresql/data"

# Wait a bit
sleep 5

# Optional: trigger file (if you use it in recovery.conf)
ssh $SSH_OPTIONS ${SSH_USER}@$new_master "touch /var/lib/postgresql/data/failover.trigger || true"

# Check recovery state
if ssh $SSH_OPTIONS ${SSH_USER}@$new_master "psql -U postgres -tAc 'SELECT pg_is_in_recovery();'" | grep -q "t"; then
    echo "❌ Error: $new_master is still in recovery!"
    exit 1
fi

# Reattach new master to Pgpool
pcp_attach_node -h localhost -U pgpool -p 9898 -n $new_master || {
    echo "⚠️ Warning: Failed to reattach node $new_master"
}

echo "✅ Failover completed. $new_master is now master."
