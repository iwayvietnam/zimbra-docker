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
##### Run a new Zimbra container:
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

### LICENSE
This work is released under GNU General Public License v3 or above.
