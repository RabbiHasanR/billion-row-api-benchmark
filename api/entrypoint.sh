#!/bin/sh
set -e
until nc -z $MASTER_DB_HOST $MASTER_DB_PORT; do
  echo "Waiting for Postgres at $MASTER_DB_HOST:$MASTER_DB_PORT..."
  sleep 1
done

python manage.py migrate --noinput

exec "$@"
