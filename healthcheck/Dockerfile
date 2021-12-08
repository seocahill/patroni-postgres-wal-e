FROM alpine:3

RUN apk add --no-cache bash curl jq

COPY healthcheck.sh /usr/local/bin

CMD ["healthcheck.sh"]
