FROM centos:7

# set up our working directory
ENV TESTHOME=/home/testing
RUN mkdir -p $TESTHOME
WORKDIR $TESTHOME

# install misc utils we'll need
RUN yum install -y sudo curl

# install puppet 6
RUN rpm -Uvh https://yum.puppet.com/puppet6-release-el-7.noarch.rpm
RUN yum install -y puppet

# install goss
RUN curl -L https://github.com/aelsabbahy/goss/releases/latest/download/goss-linux-amd64 > /usr/local/bin/goss && chmod +x /usr/local/bin/goss

