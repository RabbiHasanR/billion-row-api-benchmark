# FROM postgres:15

# COPY ./postgresql.conf /etc/postgresql/postgresql.conf
# COPY ./pg_hba.conf /etc/postgresql/pg_hba.conf
# COPY ./schema.sql /docker-entrypoint-initdb.d/schema.sql
# COPY ./raw_queries.sql /docker-entrypoint-initdb.d/raw_queries.sql
# COPY ./init-master.sh /docker-entrypoint-initdb.d/init-master.sh

# EXPOSE 5432

# RUN chmod +x /docker-entrypoint-initdb.d/init-master.sh


FROM postgres:15-alpine

COPY ./postgresql.conf /etc/postgresql/postgresql.conf
COPY ./pg_hba.conf /etc/postgresql/pg_hba.conf
COPY ./schema.sql ./raw_queries.sql ./init-master.sh /docker-entrypoint-initdb.d/

RUN chmod +x /docker-entrypoint-initdb.d/init-master.sh

EXPOSE 5432