# # Use a slim Debian image as the base
# FROM debian:bullseye-slim

# # Set build argument for the PgPool-II version
# ARG PGPOOL_VERSION="4.4.12"
# ARG PGPOOL_TAR="pgpool-II-${PGPOOL_VERSION}.tar.gz"

# # Step 1: Install build dependencies
# RUN apt-get update && \
#     apt-get install -y --no-install-recommends \
#         build-essential \
#         libpq-dev \
#         postgresql-client \
#     && rm -rf /var/lib/apt/lists/* \
#     && apt-get clean

# # Set the working directory for the build process
# WORKDIR /tmp

# # Step 2: Copy the pre-downloaded source code into the image
# COPY "${PGPOOL_TAR}" "/tmp/${PGPOOL_TAR}"

# # Step 3: Extract, configure, compile, and install PgPool-II
# RUN tar -xzf "${PGPOOL_TAR}" && \
#     cd "pgpool-II-${PGPOOL_VERSION}" && \
#     ./configure && make && make install && \
#     rm -rf /tmp/*

# # Step 4: Create a dedicated system user and group for PgPool-II
# RUN groupadd -r pgpool && useradd -r -g pgpool pgpool

# # Step 5: Create necessary directories and set ownership
# RUN mkdir -p /usr/local/etc /etc/pgpool-II /var/log/pgpool-II /var/run/pgpool && \
#     chown -R pgpool:pgpool /usr/local/etc /etc/pgpool-II /var/log/pgpool-II /var/run/pgpool && \
#     chmod -R 755 /var/log/pgpool-II && \
#     chmod -R 700 /var/run/pgpool

# # Step 6: Copy pre-configured files into the image
# COPY --chown=pgpool:pgpool pgpool.conf /usr/local/etc/pgpool.conf
# COPY --chown=pgpool:pgpool pool_hba.conf /usr/local/etc/pool_hba.conf
# COPY --chown=pgpool:pgpool pcp.conf /usr/local/etc/pcp.conf

# # Step 7: Copy the password generation script
# COPY generate_pool_passwd.sh /usr/local/bin/generate_pool_passwd.sh
# RUN chmod +x /usr/local/bin/generate_pool_passwd.sh

# # Step 8: Ensure `pool_passwd` exists with correct permissions
# RUN touch /usr/local/etc/pool_passwd && \
#     chown pgpool:pgpool /usr/local/etc/pool_passwd && \
#     chmod 600 /usr/local/etc/pool_passwd

# # Step 9: Ensure query cache lock file can be created
# RUN touch /var/log/pgpool-II/memq_lock_file && \
#     chown pgpool:pgpool /var/log/pgpool-II/memq_lock_file && \
#     chmod 600 /var/log/pgpool-II/memq_lock_file

# # Expose the default PgPool-II port
# EXPOSE 9999

# # Switch to the non-root pgpool user to run the application
# USER pgpool

# # Step 10: Run the password generation script before starting PgPool-II
# CMD ["bash", "-c", "/usr/local/bin/generate_pool_passwd.sh && pgpool -n -f /usr/local/etc/pgpool.conf -a /usr/local/etc/pool_hba.conf"]






# FROM debian:bookworm-slim

# RUN apt-get update && \
#     apt-get install -y --no-install-recommends \
#     pgpool2 \
#     postgresql-client \
#     net-tools \
#     iputils-ping \
#     && rm -rf /var/lib/apt/lists/*


# RUN mkdir -p /etc/pgpool2 /var/log/pgpool2 \
#     && chown -R postgres:postgres /etc/pgpool2 /var/log/pgpool2


# COPY pgpool.conf /etc/pgpool2/pgpool.conf
# COPY pool_hba.conf /etc/pgpool2/pool_hba.conf
# COPY pool_passwd /etc/pgpool2/pool_passwd
# COPY pcp.conf /etc/pgpool2/pcp.conf


# RUN chmod 600 /etc/pgpool2/pool_passwd /etc/pgpool2/pcp.conf \
#     && chown postgres:postgres /etc/pgpool2/pool_passwd /etc/pgpool2/pcp.conf

# EXPOSE 9999
# EXPOSE 9898

# USER postgres

# CMD ["pgpool", "-n", "-f", "/etc/pgpool2/pgpool.conf", "-a", "/etc/pgpool2/pool_hba.conf", "-F", "/etc/pgpool2/pool_passwd"]


FROM debian:bookworm-slim

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        pgpool2 \
        postgresql-client \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /etc/pgpool2 /var/log/pgpool2 \
    && chown -R postgres:postgres /etc/pgpool2 /var/log/pgpool2

COPY pgpool.conf pool_hba.conf pool_passwd pcp.conf /etc/pgpool2/

RUN chmod 600 /etc/pgpool2/pool_passwd /etc/pgpool2/pcp.conf \
    && chown postgres:postgres /etc/pgpool2/pool_passwd /etc/pgpool2/pcp.conf

EXPOSE 9999 9898

USER postgres

CMD ["pgpool", "-n", "-f", "/etc/pgpool2/pgpool.conf", "-a", "/etc/pgpool2/pool_hba.conf", "-F", "/etc/pgpool2/pool_passwd"]

