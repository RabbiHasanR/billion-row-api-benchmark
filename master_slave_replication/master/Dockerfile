FROM postgres:15-alpine

COPY ./postgresql.conf /etc/postgresql/postgresql.conf
COPY ./pg_hba.conf /etc/postgresql/pg_hba.conf

COPY ./01-init-permissions.sh /docker-entrypoint-initdb.d/
RUN chmod +x /docker-entrypoint-initdb.d/01-init-permissions.sh

COPY ./schema.sql /docker-entrypoint-initdb.d/

COPY ./raw_queries.sql /docker-entrypoint-initdb.d/

EXPOSE 5432 22

CMD ["postgres", "-c", "config_file=/etc/postgresql/postgresql.conf", "-c", "hba_file=/etc/postgresql/pg_hba.conf"]
