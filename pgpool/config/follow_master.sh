#!/bin/sh
set -e

NEW_PRIMARY_NODE_ID=$1
OLD_PRIMARY_NODE_ID=$2
NEW_PRIMARY_HOST=$3

echo "[Follow Master] New primary is node $NEW_PRIMARY_NODE_ID. Old was $OLD_PRIMARY_NODE_ID." >> /tmp/failback.log

# If the old master is back and we want to restore it as primary
if [ "$NEW_PRIMARY_NODE_ID" = "0" ]; then
  echo "[Follow Master] Promoting master_db back to primary." >> /tmp/failback.log
  docker exec -u postgres master_db pg_ctl promote -D /var/lib/postgresql/data
  sleep 5
  echo "[Follow Master] Demoting slave_db_one..." >> /tmp/failback.log
  docker stop slave_db_one
  docker rm slave_db_one
  docker compose up -d slave_db_one
fi
