FROM debian:bullseye-slim

# Install pgpool2
RUN apt-get update && \
    apt-get install -y pgpool2 && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Copy configuration files into the container
COPY pgpool.conf /etc/pgpool-II/pgpool.conf
COPY pool_hba.conf /etc/pgpool-II/pool_hba.conf

# Expose the port (must match the port in pgpool.conf)
EXPOSE 9999

# Run pgpool in the foreground with the specified configuration
CMD ["pgpool", "-n", "-f", "/etc/pgpool-II/pgpool.conf"]