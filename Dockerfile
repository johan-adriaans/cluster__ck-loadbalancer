FROM johanadriaans/docker-base-alpine:3.4
MAINTAINER Johan Adriaans <johan@izi-services.nl>

ENV CONFD_VERSION 0.11.0
ENV SOCKLOG_VERSION=2.1.0

RUN apk --update --virtual .build-dependencies add coreutils gcc make musl-dev \
  && cd ~ \
  && wget http://smarden.org/socklog/socklog-2.1.0.tar.gz \
  && tar -zxvf socklog-$SOCKLOG_VERSION.tar.gz \
  && cd admin/socklog-$SOCKLOG_VERSION \
  && ./package/install \
  && rm ~/socklog-$SOCKLOG_VERSION.tar.gz \
  && apk del .build-dependencies \
  && apk add haproxy ca-certificates openssl zip \
  && rm -rf /var/cache/apk/* \
  && wget https://github.com/kelseyhightower/confd/releases/download/v$CONFD_VERSION/confd-$CONFD_VERSION-linux-amd64 -O /bin/confd \
  && chmod +x /bin/confd

COPY confd /etc/confd
COPY files/access_control /etc/haproxy/access_control
COPY files/default.pem /etc/ssl/private/default.pem
COPY service /etc/service

EXPOSE 80 443
ENTRYPOINT ["/sbin/dumb-init", "/sbin/runsvdir", "-P", "/etc/service"]
