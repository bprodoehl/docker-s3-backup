#!/bin/sh

# Jenkins-Driven S3 Backup Slave
#
#    This container is capable of acting as a Jenkins slave over SSH,
#    backing up folders and MySQL databases to Amazon S3.
#
# VERSION               0.1.0

FROM      phusion/baseimage:0.9.15
MAINTAINER Connectify <bprodoehl@connectify.me>

RUN apt-get update && apt-get -y dist-upgrade
RUN apt-get -y install software-properties-common s3cmd zip bzip2

# install default JRE
RUN apt-get -y install --no-install-recommends default-jre

# install Oracle Java 8
#RUN echo debconf shared/accepted-oracle-license-v1-1 select true | sudo debconf-set-selections
#RUN echo debconf shared/accepted-oracle-license-v1-1 seen true | sudo debconf-set-selections
#RUN add-apt-repository -y ppa:webupd8team/java
#RUN apt-get update
#RUN apt-get -y install oracle-java8-installer

# install MariaDB client
RUN apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xcbcb082a1bb943db
RUN add-apt-repository -y 'deb http://mirror.jmu.edu/pub/mariadb/repo/5.5/ubuntu trusty main'
RUN apt-get update
RUN apt-get -y install mariadb-client

# install Node.js
RUN curl -sL https://deb.nodesource.com/setup | sudo bash -
RUN apt-get install -y python-software-properties python g++ make nodejs

# get the PHP tool to replace the domain in a WordPress or Drupal DB
RUN apt-get install -y php5-cli php5-mysql git
RUN cd /tmp && git clone https://github.com/interconnectit/Search-Replace-DB

# expose the necessary ports
EXPOSE 22

ADD files/ /tmp/
RUN cd /tmp/restore && npm install

ADD runit/create-admin-user.sh /etc/my_init.d/10-create-admin-user.sh

CMD ["/sbin/my_init"]
