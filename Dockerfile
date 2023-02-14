ARG POSTGRES_VERSION
FROM postgres:$POSTGRES_VERSION

ARG PATRONI_VERSION
ARG WALE_VERSION=1.1.1

RUN export DEBIAN_FRONTEND=noninteractive \
    && apt-get update \
    && apt-get install -y \
            curl \
            jq \
            less \
            python3-pip \
            python3-psycopg2 \
            # Required for wal-e
            daemontools lzop pv \
    && apt-get clean \
    && rm /var/lib/apt/lists/* -fR
RUN mkdir -p /home/postgres \
    && chown postgres:postgres /home/postgres
RUN pip3 install --upgrade patroni[etcd3]==$PATRONI_VERSION wal-e[aws]==$WALE_VERSION

RUN mkdir /data && chown postgres:postgres /data

USER postgres

RUN pip3 install awscli --upgrade --user

COPY config/docker-entrypoint.sh /usr/local/bin/
COPY config/patroni.yml /etc/patroni/config.yml

EXPOSE 5432 8008
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["/etc/patroni/config.yml"]
