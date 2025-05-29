FROM postgres:15

COPY ./postgresql.conf /etc/postgresql/postgresql.conf

COPY ./init-slave.sh /docker-entrypoint-initdb.d/init-slave.sh

RUN chmod +x /docker-entrypoint-initdb.d/init-slave.sh
