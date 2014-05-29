#!/bin/sh

# Jenkins-Driven S3 Backup Slave
#
#    This container is capable of acting as a Jenkins slave over SSH,
#    backing up folders and MySQL databases to Amazon S3.
#
# VERSION               0.0.1

FROM      ubuntu:14.04
MAINTAINER Connectify <bprodoehl@connectify.me>

RUN echo "deb http://archive.ubuntu.com/ubuntu trusty main universe" > /etc/apt/sources.list

# Keep the image as small as possible by disabling apt cache and compressing the apt index
RUN echo 'Dir::Cache { srcpkgcache ""; pkgcache ""; }' > /etc/apt/apt.conf.d/02nocache
RUN echo 'Acquire::GzipIndexes "true"; Acquire::CompressionTypes::Order:: "gz";' > /etc/apt/apt.conf.d/02compress-indexes

RUN apt-get -y update
RUN apt-get -y upgrade
RUN apt-get -y install software-properties-common openssh-server s3cmd zip bzip2

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
RUN add-apt-repository -y ppa:chris-lea/node.js
RUN apt-get update
RUN apt-get install -y python-software-properties python g++ make nodejs

RUN mkdir /var/run/sshd

# expose the necessary ports
EXPOSE 22

ADD startup.sh /tmp/startup.sh

# Start ssh services.
CMD ["/bin/bash", "/tmp/startup.sh"]
