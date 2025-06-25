FROM alpine:3.20

ARG PGPOOL_VERSION=4.6.2

ENV PGPOOL_HOME=/usr/local/pgpool-II
ENV PATH=$PATH:$PGPOOL_HOME/bin:$PGPOOL_HOME/sbin


RUN addgroup -g 1000 pgpool && \
    adduser -D -u 1000 -G pgpool pgpool

RUN apk add --no-cache --virtual .build-deps \
    build-base postgresql-dev openssl-dev readline-dev zlib-dev \
    wget tar linux-headers libxml2-dev libxslt-dev \
    --repository=http://dl-cdn.alpinelinux.org/alpine/v3.20/community/ && \
    apk add --no-cache \
    postgresql14-client libpq libxml2 libxslt openssl \
    --repository=http://dl-cdn.alpinelinux.org/alpine/v3.20/community/

RUN wget -q "https://www.pgpool.net/mediawiki/download.php?f=pgpool-II-${PGPOOL_VERSION}.tar.gz" -O "/tmp/pgpool-II-${PGPOOL_VERSION}.tar.gz" && \
    tar -xzf "/tmp/pgpool-II-${PGPOOL_VERSION}.tar.gz" -C /tmp

RUN cd "/tmp/pgpool-II-${PGPOOL_VERSION}" && \
    ./configure \
        --prefix=$PGPOOL_HOME \
        --with-openssl \
        --with-libpq=/usr/lib/postgresql14 \
        --with-libxml=/usr/include/libxml2 \
        --with-libxslt=/usr/include/libxslt && \
    make -j$(nproc) && \
    make install && \
    rm -rf /tmp/* && \
    apk del .build-deps

RUN mkdir -p ${PGPOOL_HOME}/etc ${PGPOOL_HOME}/log /tmp/pgpool && \
    chown -R pgpool:pgpool ${PGPOOL_HOME}/etc /tmp/pgpool && \
    chmod 700 /tmp/pgpool

COPY ./config/pgpool.conf ${PGPOOL_HOME}/etc/
COPY ./config/pool_hba.conf ${PGPOOL_HOME}/etc/
COPY ./config/pcp.conf ${PGPOOL_HOME}/etc/
COPY ./config/pool_passwd ${PGPOOL_HOME}/etc/



COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

RUN chown -R pgpool:pgpool ${PGPOOL_HOME}/etc && \
    chmod 600 ${PGPOOL_HOME}/etc/pool_passwd && \
    chmod 600 ${PGPOOL_HOME}/etc/pcp.conf

RUN echo "chmod 600 ${PGPOOL_HOME}/etc/pcp.conf ${PGPOOL_HOME}/etc/pool_passwd" >> /entrypoint.sh


USER pgpool

EXPOSE 9999 9898

ENTRYPOINT ["/entrypoint.sh"]
CMD ["pgpool", "-n", "-f", "/usr/local/pgpool-II/etc/pgpool.conf"]








