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








