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






# set -e

# PGPOOL_HOME="/usr/local/pgpool-II"
# RUNTIME_CONFIG_DIR="/tmp/pgpool_config"

# # Create working directories
# mkdir -p "$RUNTIME_CONFIG_DIR" /var/run/pgpool /tmp/pgpool
# chmod 750 "$RUNTIME_CONFIG_DIR"

# # Copy all config files to writable location
# for config_file in pgpool.conf pool_hba.conf pcp.conf pool_passwd; do
#     if [ -f "/etc/${config_file}" ]; then
#         echo "Using ${config_file} from volume"
#         cp -f "/etc/${config_file}" "$RUNTIME_CONFIG_DIR/${config_file}"
#         chmod 600 "$RUNTIME_CONFIG_DIR/${config_file}"
#     elif [ -f "${PGPOOL_HOME}/etc/${config_file}" ]; then
#         cp -f "${PGPOOL_HOME}/etc/${config_file}" "$RUNTIME_CONFIG_DIR/${config_file}"
#         chmod 600 "$RUNTIME_CONFIG_DIR/${config_file}"
#     fi
# done

# # Verify essential configs exist
# for essential_file in pgpool.conf pcp.conf; do
#     if [ ! -f "$RUNTIME_CONFIG_DIR/${essential_file}" ]; then
#         echo "Error: Missing required config file ${essential_file}" >&2
#         exit 1
#     fi
# done

# # Prepare PID directory
# export PGPOOL_PID_FILE="/tmp/pgpool/pgpool.pid"
# mkdir -p "$(dirname "$PGPOOL_PID_FILE")"

# # Run pgpool with the copied configs
# exec "$@" -f "$RUNTIME_CONFIG_DIR/pgpool.conf"