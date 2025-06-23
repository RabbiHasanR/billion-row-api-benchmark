#!/bin/sh

# Test 1: Verify write goes to primary
echo "=== WRITE TEST ==="
psql -h pgpool -p 9999 -U test_user -c "INSERT INTO route_test(node, query_type) VALUES ('via pgpool', 'write')" testdb

# Test 2: Verify read goes to replica (if load balancing enabled)
echo "=== READ TEST ==="
psql -h pgpool -p 9999 -U test_user -c "SELECT * FROM route_test ORDER BY created_at DESC LIMIT 5" testdb

# Test 3: Verify connection pooling
echo "=== POOL TEST ==="
for i in {1..10}; do
  psql -h pgpool -p 9999 -U test_user -c "SELECT 'Connection $i', pg_backend_pid()" testdb &
done
wait

# Test 4: Check pool status
echo "=== POOL STATUS ==="
psql -h pgpool -p 9999 -U test_user -c "SHOW pool_pools" testdb
psql -h pgpool -p 9999 -U test_user -c "SHOW pool_backend_stats" testdb

# Test 5: Verify routing with transaction
echo "=== TRANSACTION TEST ==="
psql -h pgpool -p 9999 -U test_user <<EOF
BEGIN;
INSERT INTO route_test(node, query_type) VALUES ('transaction', 'write');
SELECT * FROM route_test ORDER BY created_at DESC LIMIT 1;
COMMIT;
EOF

# Test 6: Load testing with pgbench
echo "=== LOAD TEST ==="
pgbench -h pgpool -p 9999 -U test_user -i -s 10 testdb
pgbench -h pgpool -p 9999 -U test_user -c 10 -j 2 -T 30 testdb