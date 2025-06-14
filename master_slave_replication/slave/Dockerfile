FROM postgres:15

COPY ./postgresql.conf /etc/postgresql/postgresql.conf
COPY ./pg_hba.conf /etc/postgresql/pg_hba.conf

# COPY ./init-slave.sh /docker-entrypoint-initdb.d/init-slave.sh

# RUN chmod +x /docker-entrypoint-initdb.d/init-slave.sh

COPY ./init-slave.sh /usr/local/bin/init-slave.sh
RUN chmod +x /usr/local/bin/init-slave.sh

EXPOSE 5432

ENTRYPOINT ["/usr/local/bin/init-slave.sh"]
