#################################################################
# Dockerfile to build Zimbra 9 (built by Zextras) container images
# Based on Rocky Linux 8
#################################################################
FROM rockylinux/rockylinux
MAINTAINER Truong Anh Tuan <tatuan@gmail.com>

RUN yum -y update && yum -y install \
  perl \
  glibc-langpack-en \
  net-tools \
  openssh-clients \
  bind-utils \
  rsyslog \
  wget

RUN ln -s -f /usr/share/zoneinfo/Asia/Ho_Chi_Minh /etc/localtime

ENV LANGUAGE=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

VOLUME ["/opt/zimbra"]

EXPOSE 25 80 465 587 110 143 993 995 443 3443 9071

COPY opt /opt/

CMD ["/bin/bash", "/opt/build.sh", "-d"]
