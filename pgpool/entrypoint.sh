#!/bin/sh
set -e

PGPOOL_HOME="/usr/local/pgpool-II"

# Ensure runtime directory exists (should already be owned by pgpool)
mkdir -p /var/run/pgpool

# Link volume-mounted configs if present
for config_file in pgpool.conf pool_hba.conf pcp.conf pool_passwd; do
    if [ -f "/etc/${config_file}" ]; then
        echo "Using ${config_file} from /etc (mounted volume)"
        cp -f "/etc/${config_file}" "${PGPOOL_HOME}/etc/${config_file}"
        chmod 600 "${PGPOOL_HOME}/etc/${config_file}"
    fi
done

# Validate presence of config
if [ ! -f "${PGPOOL_HOME}/etc/pgpool.conf" ]; then
    echo "Error: pgpool.conf not found in ${PGPOOL_HOME}/etc/" >&2
    exit 1
fi

export PGPOOL_PID_FILE="/tmp/pgpool/pgpool.pid"
mkdir -p "$(dirname "$PGPOOL_PID_FILE")"

mkdir -p /tmp/pgpool


exec "$@"
