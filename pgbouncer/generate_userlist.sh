#!/bin/sh
set -eu

# Generate MD5 hash in PostgreSQL format: md5(md5(password + username) + username)
HASH=$(printf "md5%s" $(printf "%s%s" "$POSTGRES_PASSWORD" "$POSTGRES_USER" | md5sum | awk '{print $1}'))

# Output to userlist.txt
echo "\"$POSTGRES_USER\" \"$HASH\"" > /etc/pgbouncer/userlist.txt
echo "✅ Generated userlist.txt for PgBouncer"