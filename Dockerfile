#
# MemSQL Quickstart Dockerfile
#
# https://github.com/memsql/memsql-docker-quickstart
#

# Based on Phusion's baseimage
FROM phusion/baseimage:0.9.16
CMD ["/sbin/my_init"]

RUN apt-get update && apt-get install -y \
    libmysqlclient-dev mysql-client \
    python-dev python-pip \
    wget jq build-essential \
    libcurl4-openssl-dev

# install useful python packages
RUN pip install memsql ipython psutil

# configure locale
RUN locale-gen en_US.UTF-8
RUN update-locale LANG=en_US.UTF-8

# configure environment
RUN echo en_US.UTF-8 > /etc/container_environment/LANG
RUN echo en_US.UTF-8 > /etc/container_environment/LC_ALL
RUN echo en_US:en > /etc/container_environment/LANGUAGE
RUN chmod 755 /etc/container_environment
RUN chmod 644 /etc/container_environment.sh

# set UTC
RUN ln -sf /usr/share/zoneinfo/UTC /etc/localtime

# setup directories
RUN mkdir /memsql /memsql-ops /vol-template

# download and install MemSQL Ops
# then reduce size by symlinking objdir and lib from one install to the other
ADD setup_ops.sh /tmp/setup_ops.sh
RUN /tmp/setup_ops.sh

VOLUME ["/memsql"]

# setup MemSQL Ops service
RUN mkdir /etc/service/memsql-ops
ADD memsql_ops.service /etc/service/memsql-ops/run

# add helper scripts
ADD memsql-shell /usr/local/bin/memsql-shell
ADD check-system /usr/local/bin/check-system

# expose ports
EXPOSE 3306
EXPOSE 9000

# Clean up APT
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
