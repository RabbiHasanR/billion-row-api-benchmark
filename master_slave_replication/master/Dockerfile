FROM postgres:15

COPY ./postgresql.conf /etc/postgresql/postgresql.conf
COPY ./pg_hba.conf /etc/postgresql/pg_hba.conf
COPY ./init-master.sh /docker-entrypoint-initdb.d/init-master.sh

EXPOSE 5432

RUN chmod +x /docker-entrypoint-initdb.d/init-master.sh