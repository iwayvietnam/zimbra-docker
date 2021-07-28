# zimbra-docker
The project to build a Zimbra 9 (built by Zextras) Docker image based on Rocky Linux 8.

Check out the prebuilt image on Docker Hub: https://hub.docker.com/r/iwayvietnam/zimbra_all

### How to start a new Zimbra container from prebuilt Docker image
##### Create a new Docker network dedicated for Zimbra
```bash
$ docker network create --driver=bridge --subnet=172.28.0.0/16 zimbranet
```
##### Run a new dnsmasq container:
```bash
$ docker run --name dnsmasq-iwaytest2 -d -it \
-p 172.28.0.1:53:53/tcp -p 172.28.0.1:53:53/udp \
--net=zimbranet --cap-add=NET_ADMIN 4km3/dnsmasq \
--address=/iwaytest2.com/172.28.0.3 \
--domain=iwaytest2.com \
--mx-host=iwaytest2.com,mail.iwaytest2.com,0
```
(assumption: the new Zimbra domain is iwaytest2.com)
##### Create a new Docker volume for Zimbra container:
```bash
$ docker volume create zimbra-iwaytest2
```
##### Run All Zimbra Services (Zimbra AiO) in a container:
```bash
$ docker run --name zimbra-iwaytest2 -it \
-p 25:25 -p 80:80 -p 465:465 \
-p 587:587 -p 110:110 -p 143:143 \
-p 993:993 -p 995:995 -p 443:443 \
-p 3443:3443 -p 9071:9071 \
-h mail.iwaytest2.com --net=zimbranet --dns 172.28.0.1 \
-v zimbra-iwaytest2:/opt/zimbra \
-e PASSWORD=Zimbra2021 iwayvietnam/zimbra_all
```
(and WAIT...)

### NEW: Run multi-servers Zimbra in separated containers
##### Run the first Zimbra LDAP in a container:
```bash
$ docker volume create zimbra-ldap1
$ docker run --name zimbra-ldap1 -it \
-p 389:389 \
-h ldap1.iwaytest2.com --net=zimbranet --dns 172.28.0.1 \
-v zimbra-ldap1:/opt/zimbra \
-e INSTALLED-SERVICES=LDAP \
-e PASSWORD=Zimbra2021 iwayvietnam/zimbra_all
```
##### Run an additional Zimbra LDAP in a container:
```bash
$ docker volume create zimbra-ldap2
$ docker run --name zimbra-ldap2 -it \
-p 389:389 \
-h ldap2.iwaytest2.com --net=zimbranet --dns 172.28.0.1 \
-v zimbra-ldap2:/opt/zimbra \
-e INSTALLED-SERVICES=LDAP -e LDAPHOST=ldap1.iwaytest2.com \
-e PASSWORD=Zimbra2021 iwayvietnam/zimbra_all
```
##### Run a new Zimbra Mailstore in a container:
```bash
$ docker volume create zimbra-mailstore
$ docker run --name zimbra-mailstore -it \
-p 7080:7080 -p 7443:7443 -p 7071:7071 \
-p 7110:7110 -p 7143:7143 -p 7993:7993 -p 7995:7995 \
-h mailstore.iwaytest2.com --net=zimbranet --dns 172.28.0.1 \
-v zimbra-mailstore:/opt/zimbra \
-e INSTALLED-SERVICES=MAILSTORE -e LDAPHOST=ldap1.iwaytest2.com \
-e PASSWORD=Zimbra2021 iwayvietnam/zimbra_all
```
##### Run a new Zimbra MTA in a container:
```bash
$ docker volume create zimbra-mta
$ docker run --name zimbra-mta -it \
-p 25:25 -p 80:80 -p 465:465 \
-p 587:587 \
-h mta.iwaytest2.com --net=zimbranet --dns 172.28.0.1 \
-v zimbra-mta:/opt/zimbra \
-e INSTALLED-SERVICES=MTA -e LDAPHOST=ldap1.iwaytest2.com \
-e PASSWORD=Zimbra2021 iwayvietnam/zimbra_all
```
##### Run a new Zimbra Proxy in a container:
```bash
$ docker volume create zimbra-proxy
$ docker run --name zimbra-proxy -it \
-p 80:80 -p 443:443 -p 9071:9071 \
-p 110:110 -p 143:143 -p 993:993 -p 995:995 \
-h proxy.iwaytest2.com --net=zimbranet --dns 172.28.0.1 \
-v zimbra-proxy:/opt/zimbra \
-e INSTALLED-SERVICES=PROXY -e LDAPHOST=ldap1.iwaytest2.com \
-e PASSWORD=Zimbra2021 iwayvietnam/zimbra_all
```

### LICENSE
This work is released under GNU General Public License v3 or above.
