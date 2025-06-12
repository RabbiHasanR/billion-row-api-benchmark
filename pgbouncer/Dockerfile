FROM edoburu/pgbouncer:latest

WORKDIR /etc/pgbouncer

# Copy files
COPY pgbouncer.ini /etc/pgbouncer/pgbouncer.ini
COPY generate_userlist.sh /usr/local/bin/generate_userlist.sh

# Ensure script is executable
# RUN chmod +x /usr/local/bin/generate_userlist.sh

# Run userlist generation before starting PgBouncer
# ENTRYPOINT ["/usr/local/bin/generate_userlist.sh"]
CMD ["pgbouncer", "/etc/pgbouncer/pgbouncer.ini"]
