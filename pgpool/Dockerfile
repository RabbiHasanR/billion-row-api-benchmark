FROM debian:bullseye-slim

# Install pgpool2 and postgresql-client (for pg_isready healthcheck)
RUN apt-get update && \
    apt-get install -y pgpool2 postgresql-client gettext && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Copy configuration files and helper script
COPY ./pgpool.conf /etc/pgpool-II/pgpool.conf
COPY ./pool_hba.conf /etc/pgpool-II/pool_hba.conf
COPY ./entrypoint.sh /usr/local/bin/entrypoint.sh

# Make the helper script executable
RUN chmod +x /usr/local/bin/entrypoint.sh

# Expose the Pgpool port
EXPOSE 9999

# Healthcheck to ensure pgpool is running and accepting connections
HEALTHCHECK CMD pg_isready -h 127.0.0.1 -p 9999 || exit 1

# Use ENTRYPOINT and CMD to run your script and then pgpool with proper signal handling
ENTRYPOINT ["/bin/sh", "-c"]
CMD ["/usr/local/bin/entrypoint.sh && exec pgpool -n -f /etc/pgpool-II/pgpool.conf"]
