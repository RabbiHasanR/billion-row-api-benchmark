#!/bin/sh

# Fail if any variable is unset
set -eu

# Generate MD5 hash: md5(password + username)
HASH=$(printf "%s%s" "$POSTGRES_PASSWORD" "$POSTGRES_USER" | md5sum | awk '{print $1}')

echo "${POSTGRES_USER}:md5${HASH}" > /etc/pgpool-II/pool_passwd

echo "Generated /etc/pgpool-II/pool_passwd for user ${POSTGRES_USER}"
