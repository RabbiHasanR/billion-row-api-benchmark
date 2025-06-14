#!/bin/sh

# Generate pool_passwd entry
echo "Generating pool_passwd..."
pg_enc -m -u postgres -p postgres

# Optional: print pool_passwd file to check
cat /etc/pgpool-II/pool_passwd

# Start pgpool in foreground
exec pgpool -n -f /etc/pgpool-II/pgpool.conf
