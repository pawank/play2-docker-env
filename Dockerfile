# Use phusion/baseimage as base image. To make your builds reproducible, make
# sure you lock down to a specific version, not to `latest`!
# See https://github.com/phusion/baseimage-docker/blob/master/Changelog.md for
# a list of version numbers.
FROM phusion/baseimage:0.9.15

MAINTAINER Pawan Kumar <pawan.kumar@gmail.com>

# Set correct environment variables.
ENV HOME /root

# Fix for $HOME:
RUN echo /root > /etc/container_environment/HOME

# Set the locale
RUN locale-gen en_US.UTF-8 && echo 'LANG="en_US.UTF-8"' > /etc/default/locale
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Regenerate SSH host keys. baseimage-docker does not contain any, so you
# have to do that yourself. You may also comment out this instruction; the
# init system will auto-generate one during boot.
RUN /etc/my_init.d/00_regen_ssh_host_keys.sh

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

## Install an SSH of your choice.
ADD id_rsa.pub /tmp/your_key.pub
RUN cat /tmp/your_key.pub >> /root/.ssh/authorized_keys && rm -f /tmp/your_key.pub

RUN apt-get update
RUN apt-get -y upgrade

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y wget unzip htop vim

echo ""
echo "---> Installing Oracle JDK 8 <---"
# Install JDK 8 from Oracle
RUN sudo add-apt-repository ppa:webupd8team/java
RUN sudo apt-get update
RUN sudo echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections
RUN sudo apt-get install -y oracle-java8-installer
RUN sudo apt-get install -y oracle-java8-set-default

#ENV PLAY_VERSION 2.3.7
#ENV PATH $PATH:/opt/play-$PLAY_VERSION

ENV ACTIVATOR_VERSION 1.2.12
ENV PATH $PATH:/opt/activator-$ACTIVATOR_VERSION:.
#ENV PATH $PATH:/opt/play-$PLAY_VERSION:/opt/activator-$ACTIVATOR_VERSION:.

echo ""
echo "---> Installing Typesafe Activator <---"
RUN mkdir -p /opt && cd /opt/ && wget http://downloads.typesafe.com/typesafe-activator/$ACTIVATOR_VERSION/typesafe-activator-$ACTIVATOR_VERSION.zip && unzip typesafe-activator-$ACTIVATOR_VERSION.zip
echo "export PATH=/opt/activator-$ACTIVATOR_VERSION:\$PATH" >> ~/.bashrc
#RUN mkdir -p /opt && cd /opt/ && wget http://downloads.typesafe.com/typesafe-activator/$ACTIVATOR_VERSION/typesafe-activator-$ACTIVATOR_VERSION-minimal.zip && unzip typesafe-activator-$ACTIVATOR_VERSION-minimal.zip

#echo "export PATH=/opt/activator-$ACTIVATOR_VERSION-minimal:\$PATH" >> ~/.bashrc

source ~/.bashrc

echo "jdk version:"
javac -version
echo ""

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

VOLUME ["/opt/workspace"]
WORKDIR /opt/workspace
EXPOSE 9000 

echo "=========================================="
echo "DONE"
echo "=========================================="

CMD ["/bin/bash"]
