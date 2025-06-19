#!/bin/sh
set -eu

FAILED_NODE_ID=$1
FAILED_HOST=$2
FAILED_PORT=$3
NEW_PRIMARY_NODE_ID=$5

echo "[Failover] Node $FAILED_NODE_ID at $FAILED_HOST:$FAILED_PORT failed" >> /tmp/failover.log

# Optional: Promote standby if primary fails
if [ "$FAILED_NODE_ID" = "0" ]; then
  echo "[Failover] Promoting standby node ${NEW_PRIMARY_NODE_ID}" >> /tmp/failover.log
  su - postgres -c "pg_ctl promote -D /var/lib/postgresql/data" >> /tmp/failover.log 2>&1 || true
fi
