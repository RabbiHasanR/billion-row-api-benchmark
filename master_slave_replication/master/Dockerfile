# Use the official Postgres 15 Alpine image
FROM postgres:15-alpine

# It's good practice to set these explicitly
# ENV POSTGRES_DB=testdb
# ENV POSTGRES_USER=postgres
# ENV POSTGRES_PASSWORD=postgres

# Copy your custom configuration files
# The CMD below will tell postgres to use them
COPY ./postgresql.conf /etc/postgresql/postgresql.conf
COPY ./pg_hba.conf /etc/postgresql/pg_hba.conf

# === INITIALIZATION SCRIPTS ===
# The entrypoint will execute these scripts in alphabetical order
# during the initial database creation.

# 1. Copy the script to create roles and permissions
COPY ./01-init-permissions.sh /docker-entrypoint-initdb.d/
RUN chmod +x /docker-entrypoint-initdb.d/01-init-permissions.sh

# 2. Copy the script to create the database schema
COPY ./schema.sql /docker-entrypoint-initdb.d/

# 3. Copy the script to insert raw query data
COPY ./raw_queries.sql /docker-entrypoint-initdb.d/


# Expose the PostgreSQL port
EXPOSE 5432

# Tell the postgres server to use our custom config files.
# The base image's CMD is ["postgres"]. We override it to add flags.
CMD ["postgres", "-c", "config_file=/etc/postgresql/postgresql.conf", "-c", "hba_file=/etc/postgresql/pg_hba.conf"]




# FROM postgres:15-alpine
# COPY ./postgresql.conf /etc/postgresql/postgresql.conf
# COPY ./pg_hba.conf /etc/postgresql/pg_hba.conf
# COPY ./schema.sql /docker-entrypoint-initdb.d/schema.sql
# COPY ./raw_queries.sql /docker-entrypoint-initdb.d/raw_queries.sql
# COPY ./init-master.sh /usr/local/bin/init-master.sh

# RUN chmod +x /usr/local/bin/init-master.sh

# EXPOSE 5432

# ENTRYPOINT ["/usr/local/bin/init-master.sh"]








# # Copy custom PostgreSQL configs
# COPY ./postgresql.conf /etc/postgresql/postgresql.conf
# COPY ./pg_hba.conf /etc/postgresql/pg_hba.conf

# # Optional: SQL scripts still needed by old_init_master.sh (or may be loaded manually)
# COPY ./schema.sql /docker-entrypoint-initdb.d/schema.sql
# COPY ./raw_queries.sql /docker-entrypoint-initdb.d/raw_queries.sql

# # Copy custom entrypoint script
# COPY ./new_init_master.sh /usr/local/bin/entrypoint.sh
# RUN chmod +x /usr/local/bin/entrypoint.sh

# # Use the custom entrypoint
# ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# # Default PostgreSQL port
# EXPOSE 5432


# COPY ./postgresql.conf /etc/postgresql/postgresql.conf
# COPY ./pg_hba.conf /etc/postgresql/pg_hba.conf
# COPY ./schema.sql /docker-entrypoint-initdb.d/
# COPY ./raw_queries.sql /docker-entrypoint-initdb.d/
# COPY ./old_init_master.sh /docker-entrypoint-initdb.d/

# # Ensure proper permissions
# RUN chmod +x /docker-entrypoint-initdb.d/old_init_master.sh

# EXPOSE 5432