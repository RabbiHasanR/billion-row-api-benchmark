#!/bin/sh

# Fail if any variable is unset
set -eu

# Define username and password
PG_USER="postgres"
PG_PASSWORD="postgres"

# Generate MD5 hash: md5(password + username)
HASH=$(printf "%s%s" "$PG_PASSWORD" "$PG_USER" | md5sum | awk '{print $1}')

# Output to pool_passwd
echo "$PG_USER:md5$HASH" > /usr/local/etc/pool_passwd

# Set correct permissions
chmod 600 /usr/local/etc/pool_passwd
chown pgpool:pgpool /usr/local/etc/pool_passwd

echo "✅ Generated pool_passwd for PgPool-II"
