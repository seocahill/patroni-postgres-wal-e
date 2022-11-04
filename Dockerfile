FROM postgres:15.0

ENV WALE_VERSION=1.1.1

RUN export DEBIAN_FRONTEND=noninteractive \
    && apt-get update \
    && apt-get install -y \
            curl \
            jq \
            python3-pip \
            patroni \
            # Required for wal-e
            daemontools lzop pv \
    && rm /var/lib/apt/lists/* -fR
RUN mkdir -p /home/postgres \
    && chown postgres:postgres /home/postgres
RUN pip3 install --upgrade wal-e[aws]==$WALE_VERSION

RUN mkdir /data && chown postgres:postgres /data

USER postgres

RUN pip3 install awscli --upgrade --user

COPY config/docker-entrypoint.sh /usr/local/bin/
COPY config/patroni.yml /etc/patroni/config.yml

EXPOSE 5432 8008
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["/etc/patroni/config.yml"]
