#
# MemSQL Quickstart Minimal Dockerfile
#
# https://github.com/memsql/memsql-docker-quickstart
#

FROM debian:jessie-slim
MAINTAINER Carl Sverre <carl@memsql.com>

RUN apt-get update \
 && apt-get install -y \
    curl \
    mysql-client \
    rsync \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# install dumb-init
ENV DUMB_INIT_VERSION 1.2.0
ENV DUMB_INIT_URL https://github.com/Yelp/dumb-init/releases/download/v${DUMB_INIT_VERSION}/dumb-init_${DUMB_INIT_VERSION}_amd64.deb
RUN curl -sL $DUMB_INIT_URL > /tmp/dumb_init.deb \
 && dpkg -i /tmp/dumb_init.deb \
 && rm /tmp/dumb_init.deb

# set UTC
RUN ln -sf /usr/share/zoneinfo/UTC /etc/localtime

# setup user
RUN useradd -M memsql

# setup MemSQL
ENV MEMSQL_VERSION 841eb693c06a33f870ca46c9e2b47fdd65b7f9bd
ENV MEMSQL_DL_URL http://download.memsql.com/releases/commit/$MEMSQL_VERSION/memsqlbin_amd64.tar.gz
RUN curl -sL $MEMSQL_DL_URL > /tmp/memsqlbin_amd64.tar.gz \
 && tar -xzf /tmp/memsqlbin_amd64.tar.gz \
 && mv memsqlbin master \
 && cp -r master leaf \
 && rm /tmp/memsqlbin_amd64.tar.gz

# compile internal tables
RUN mkdir -p /cache/master /cache/leaf /cache/tmp \
 && chown -R memsql:memsql /cache \
 && /master/memsqld --user=memsql --port=3523 --plancachedir=/cache/master --tracelogsdir=/cache/tmp --datadir=/cache/tmp --init-memsql-db-only \
 && /leaf/memsqld --user=memsql --port=3523 --plancachedir=/cache/leaf --tracelogsdir=/cache/tmp --datadir=/cache/tmp --init-memsql-db-only \
 && rm -r /cache/tmp

ADD config/master.cnf /master/memsql.cnf
ADD config/leaf.cnf /leaf/memsql.cnf

# setup volumes
RUN mkdir /state
VOLUME /state

ENTRYPOINT ["/memsql-entrypoint.sh"]
CMD ["memsqld"]

# expose port
EXPOSE 3306

COPY memsql-entrypoint.sh /
