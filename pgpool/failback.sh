#!/bin/bash
old_master=$1
new_master=$2

echo "Failback triggered. Old master: $old_master, New master: $new_master"

# Remove failover.trigger from the old master
ssh $old_master "rm -f /var/lib/postgresql/data/failover.trigger"

# Reconfigure old master as standby
ssh $old_master "pg_basebackup -h $new_master -D /var/lib/postgresql/data -R"

# Restart PostgreSQL
ssh $old_master "systemctl restart postgresql"

echo "✅ Failback completed. Old master is now a standby."
