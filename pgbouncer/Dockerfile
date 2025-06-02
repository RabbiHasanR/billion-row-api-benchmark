FROM edoburu/pgbouncer:latest

# Set working directory
WORKDIR /etc/pgbouncer

# Copy configuration files
COPY pgbouncer.ini /etc/pgbouncer/pgbouncer.ini
COPY generate_userlist.sh /etc/pgbouncer/generate_userlist.sh

# Run PgBouncer with custom config
CMD ["pgbouncer", "/etc/pgbouncer/pgbouncer.ini"]
