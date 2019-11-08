FROM alpine:3.10
LABEL maintainer "DI GREGORIO Nicolas <nicolas.digregorio@gmail.com>"

ARG JOAL_VERSION=2.1.19

### Environment variables
ENV LANG='en_US.UTF-8' \
    LANGUAGE='en_US.UTF-8' \
    APPUSER='joal' \
    APPUID='10030' \
    APPGID='10030' \
    JOAL_VERSION="${JOAL_VERSION}"

# Copy config files
COPY root/ /

RUN set -x && \
    chmod 1777 /tmp && \
    . /usr/local/bin/docker-entrypoint-functions.sh && \
    MYUSER=${APPUSER} && \
    MYUID=${APPUID} && \
    MYGID=${APPGID} && \
    ConfigureUser && \
    apk --no-cache upgrade && \
    apk add --no-cache --virtual=run-deps \
      bash \
      ca-certificates \
      openjdk8 \
      su-exec \
    && \
    mkdir /joal /config && \
    wget https://github.com/anthonyraymond/joal/releases/download/${JOAL_VERSION}/joal.tar.gz -O /tmp/joal.tar.gz && \
    tar xzf /tmp/joal.tar.gz -C /joal && \
    mv /joal/jack-of-all-trades-${JOAL_VERSION}.jar /joal/joal.jar && \
    chown -R ${MYUSER} /joal /config && \
    mkdir /docker-entrypoint.d && \
    chmod +x /usr/local/bin/docker-entrypoint.sh && \
    ln -snf /usr/local/bin/docker-entrypoint.sh /docker-entrypoint.sh && \
    rm -rf /tmp/* \
           /var/cache/apk/*  \
           /var/tmp/*
