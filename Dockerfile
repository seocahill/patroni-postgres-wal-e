ARG POSTGRES_VERSION
FROM postgres:$POSTGRES_VERSION-alpine

ARG PATRONI_VERSION

RUN apk add --no-cache py3-pip py3-psycopg2

#RUN export DEBIAN_FRONTEND=noninteractive \
    #&& apt-get update \
    #&& apt-get install -y \
            #curl \
            #jq \
            #less \
            #python3-pip \
            #python3-psycopg2 \
    #&& apt-get clean \
    #&& rm /var/lib/apt/lists/* -fR
RUN mkdir -p /home/postgres \
    && chown postgres:postgres /home/postgres
RUN apk add --no-cache gcc libc-dev linux-headers python3-dev \
 && pip3 install --upgrade patroni[etcd3]==$PATRONI_VERSION \
 && apk del gcc libc-dev linux-headers python3-dev

RUN mkdir /data && chown postgres:postgres /data

USER postgres

COPY config/docker-entrypoint.sh /usr/local/bin/
COPY config/patroni.yml /etc/patroni/config.yml

EXPOSE 5432 8008
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["/etc/patroni/config.yml"]
