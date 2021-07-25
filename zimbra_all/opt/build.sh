#<one line to give the program's name and a brief idea of what it does.>
#    Copyright (C) 2021 iWayVietnam
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
# 
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <https://www.gnu.org/licenses/>.

#!/bin/sh

## BEGIN. Check if Zimbra already installed?
if [ -e /opt/zimbra-install/install-autoKeys ]
then ## Zimbra NOT installed yet.

if [ -z "$LOGSTASH_IP" ]
then
      echo "Push log to logstash not define, so not config"
      rm -rf /opt/push-logs-to-logstash
else
      echo "Push log to logstash server $LOGSTASH_IP, configuring...."
      cp /opt/push-logs-to-logstash/* /etc/rsyslog.d/
      sed -i "s|LOGSTASH_IP|$LOGSTASH_IP|g" /etc/rsyslog.d/02-output.conf
      rm -rf /opt/push-logs-to-logstash
fi

cp /etc/rsyslog.conf /etc/rsyslog.conf.bak
sed -i 's|SysSock.Use="off")|SysSock.Use="on")|g' /etc/rsyslog.conf
sed -i 's|module(load="imjournal"|#module(load="imjournal"|g' /etc/rsyslog.conf
sed -i 's|StateFile="imjournal.state"|#StateFile="imjournal.state"|g' /etc/rsyslog.conf
sed -i 's|*.info;mail.none;authpriv.none;cron.none|*.info;local0.none;local1.none;mail.none;auth.none;authpriv.none;cron.none|g' /etc/rsyslog.conf
echo -e "\nlocal0.*                -/var/log/zimbra.log\nlocal1.*                -/var/log/zimbra-stats.log\nauth.*                  -/var/log/zimbra.log\nmail.*                -/var/log/zimbra.log" >> /etc/rsyslog.conf
rsyslogd

## Preparing all the variables like IP, Hostname, etc, all of them from the container
HOSTNAME=$(hostname -a)
DOMAIN=$(hostname -d)
CONTAINERIP=$(ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1  -d'/')
RANDOMHAM=$(date +%s|sha256sum|base64|head -c 10)
RANDOMSPAM=$(date +%s|sha256sum|base64|head -c 10)
RANDOMVIRUS=$(date +%s|sha256sum|base64|head -c 10)

# Add Zimbra 9 RPM repo
cat > /etc/yum.repos.d/zimbra.repo <<EOF
[zimbra-90-oss]
name=Zimbra New RPM Repository
baseurl=https://repo.zimbra.com/rpm/90/rhel8
gpgcheck=1
enabled=1
EOF
rpm --import https://files.zimbra.com/downloads/security/public.key 2>&1

##Install the Zimbra Collaboration ##
#echo "Downloading Zimbra 9 built by Zextras"
#wget -O zcs-9.0.0_OSE_RHEL8_latest-zextras.tgz https://download.zextras.com/zcs-9.0.0_OSE_RHEL8_latest-zextras.tgz

echo "Extracting files from the archive"
tar xzvf /opt/zimbra-install/zcs-9.0.0_OSE_RHEL8_latest-zextras.tgz -C /opt/zimbra-install/

echo "Installing Zimbra Collaboration just the Software"
cd /opt/zimbra-install/zimbra-installer && ./install.sh -s --platform-override < /opt/zimbra-install/install-autoKeys

##Creating the Zimbra Collaboration Config File ##
cat <<EOF >/opt/zimbra-install/installParameters
AVDOMAIN="$DOMAIN"
AVUSER="admin@$DOMAIN"
CREATEADMIN="admin@$DOMAIN"
CREATEADMINPASS="$PASSWORD"
CREATEDOMAIN="$DOMAIN"
DOCREATEADMIN="yes"
DOCREATEDOMAIN="yes"
DOTRAINSA="yes"
EXPANDMENU="no"
HOSTNAME="$HOSTNAME.$DOMAIN"
HTTPPORT="8080"
HTTPPROXY="TRUE"
HTTPPROXYPORT="80"
HTTPSPORT="8443"
HTTPSPROXYPORT="443"
IMAPPORT="7143"
IMAPPROXYPORT="143"
IMAPSSLPORT="7993"
IMAPSSLPROXYPORT="993"
INSTALL_WEBAPPS="service zimlet zimbra zimbraAdmin"
JAVAHOME="/opt/zimbra/common/lib/jvm/java"
LDAPAMAVISPASS="$PASSWORD"
LDAPPOSTPASS="$PASSWORD"
LDAPROOTPASS="$PASSWORD"
LDAPADMINPASS="$PASSWORD"
LDAPREPPASS="$PASSWORD"
LDAPBESSEARCHSET="set"
LDAPDEFAULTSLOADED="1"
LDAPHOST="$HOSTNAME.$DOMAIN"
LDAPPORT="389"
LDAPREPLICATIONTYPE="master"
LDAPSERVERID="2"
MAILBOXDMEMORY="1024"
MAILPROXY="TRUE"
MODE="https"
MYSQLMEMORYPERCENT="30"
POPPORT="7110"
POPPROXYPORT="110"
POPSSLPORT="7995"
POPSSLPROXYPORT="995"
PROXYMODE="https"
REMOVE="no"
RUNARCHIVING="no"
RUNAV="yes"
RUNCBPOLICYD="no"
RUNDKIM="yes"
RUNSA="yes"
RUNVMHA="no"
SERVICEWEBAPP="yes"
SMTPDEST="admin@$DOMAIN"
SMTPHOST="$HOSTNAME.$DOMAIN"
SMTPNOTIFY="yes"
SMTPSOURCE="admin@$DOMAIN"
SNMPNOTIFY="yes"
SNMPTRAPHOST="$HOSTNAME.$DOMAIN"
SPELLURL="http://$HOSTNAME.$DOMAIN:7780/aspell.php"
STARTSERVERS="yes"
SYSTEMMEMORY="3.8"
TRAINSAHAM="ham.$RANDOMHAM@$DOMAIN"
TRAINSASPAM="spam.$RANDOMSPAM@$DOMAIN"
UIWEBAPPS="yes"
UPGRADE="yes"
USEKBSHORTCUTS="TRUE"
USESPELL="yes"
VERSIONUPDATECHECKS="TRUE"
VIRUSQUARANTINE="virus-quarantine.$RANDOMVIRUS@$DOMAIN"
ZIMBRA_REQ_SECURITY="yes"
ldap_bes_searcher_password="$PASSWORD"
ldap_dit_base_dn_config="cn=zimbra"
ldap_nginx_password="$PASSWORD"
ldap_url="ldap://$HOSTNAME.$DOMAIN:389"
mailboxd_directory="/opt/zimbra/mailboxd"
mailboxd_keystore="/opt/zimbra/mailboxd/etc/keystore"
mailboxd_keystore_password="$PASSWORD"
mailboxd_server="jetty"
mailboxd_truststore="/opt/zimbra/common/lib/jvm/java/lib/security/cacerts"
mailboxd_truststore_password="changeit"
postfix_mail_owner="postfix"
postfix_setgid_group="postdrop"
ssl_default_digest="sha256"
zimbraDNSMasterIP=""
zimbraDNSTCPUpstream="no"
zimbraDNSUseTCP="yes"
zimbraDNSUseUDP="yes"
zimbraDefaultDomainName="$DOMAIN"
zimbraFeatureBriefcasesEnabled="Enabled"
zimbraFeatureTasksEnabled="Enabled"
zimbraIPMode="ipv4"
zimbraMailProxy="TRUE"
zimbraMtaMyNetworks="127.0.0.0/8 $CONTAINERIP/32 [::1]/128 [fe80::]/64"
zimbraPrefTimeZoneId="Asia/Ho_Chi_Minh"
zimbraReverseProxyLookupTarget="TRUE"
zimbraVersionCheckNotificationEmail="admin@$DOMAIN"
zimbraVersionCheckNotificationEmailFrom="admin@$DOMAIN"
zimbraVersionCheckSendNotifications="FALSE"
zimbraWebProxy="TRUE"
zimbra_ldap_userdn="uid=zimbra,cn=admins,cn=zimbra"
zimbra_require_interprocess_security="1"
zimbra_server_hostname="$HOSTNAME.$DOMAIN"
INSTALL_PACKAGES="zimbra-core zimbra-ldap zimbra-logger zimbra-mta zimbra-dnscache zimbra-snmp zimbra-store zimbra-apache zimbra-spell zimbra-memcached zimbra-proxy zimbra-drive zimbra-chat"
EOF

echo "Installing Zimbra Collaboration injecting the configuration"
/opt/zimbra/libexec/zmsetup.pl -c /opt/zimbra-install/installParameters

su - zimbra -c 'zmcontrol restart'
echo "You can access now to your Zimbra Collaboration Server https://$HOSTNAME.$DOMAIN"

rm -Rf /opt/zimbra-install

else ## Zimbra already installed. Just need to start Zimbra services.
  rsyslogd
  su - zimbra -c 'zmcontrol restart'
fi ## END. Check if Zimbra already installed?

if [[ $1 == "-d" ]]; then
  while true; do sleep 1000; done
fi

if [[ $1 == "-bash" ]]; then
  /bin/bash
fi
