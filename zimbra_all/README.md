### How to build a new Docker image
##### Firstly, of course, install Docker and setup to manage Docker as a non-root user
See: https://docs.docker.com/engine/install/

##### Pull the latest Rocky Linux based docker image
```bash
$ docker pull rockylinux/rockylinux
```
##### Checkout this git repo
```bash
* $ git clone https://github.com/iwayvietnam/zimbra-docker.git && cd zimbra-docker/zimbra_all
```
##### Download the latest Zimbra 9 (built by Zextras)
```bash
$ wget -O opt/zimbra-install/zcs-9.0.0_OSE_RHEL8_latest-zextras.tgz \
https://download.zextras.com/zcs-9.0.0_OSE_RHEL8_latest-zextras.tgz
```
##### Build Zimbra a new docker image
```bash
$ docker build --rm -t iwayvietnam/zimbra_all .
```
