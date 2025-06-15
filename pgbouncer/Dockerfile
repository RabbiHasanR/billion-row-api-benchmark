FROM edoburu/pgbouncer:latest

WORKDIR /etc/pgbouncer

COPY ./pgbouncer.ini /etc/pgbouncer/pgbouncer.ini
COPY ./generate_userlist.sh /usr/local/bin/generate_userlist.sh

EXPOSE 6432

CMD ["pgbouncer", "/etc/pgbouncer/pgbouncer.ini"]
