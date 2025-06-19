# FROM postgres:15

FROM postgres:15-alpine

# COPY ./postgresql.conf /etc/postgresql/postgresql.conf
# COPY ./pg_hba.conf /etc/postgresql/pg_hba.conf
# COPY ./schema.sql /docker-entrypoint-initdb.d/schema.sql
# COPY ./raw_queries.sql /docker-entrypoint-initdb.d/raw_queries.sql
# COPY ./init-master.sh /docker-entrypoint-initdb.d/init-master.sh

# EXPOSE 5432

# RUN chmod +x /docker-entrypoint-initdb.d/init-master.sh

COPY ./postgresql.conf /etc/postgresql/postgresql.conf
COPY ./pg_hba.conf /etc/postgresql/pg_hba.conf
COPY ./schema.sql /docker-entrypoint-initdb.d/schema.sql
COPY ./raw_queries.sql /docker-entrypoint-initdb.d/raw_queries.sql


COPY ./init-master.sh /usr/local/bin/init-master.sh
RUN chmod +x /usr/local/bin/init-master.sh

EXPOSE 5432

ENTRYPOINT ["/usr/local/bin/init-master.sh"]


