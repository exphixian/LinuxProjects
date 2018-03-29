#!/bin/bash

#ASSIGNING VARIABLES
interface=`ifconfig | awk '{print substr($1,1, length ($1)-1)}' | head -1
echo "For the Deployment:"
echo "Please enter the HOSTNAME of this device:"
read HOST
echo "Please enter the IP address for this device:"
read IP
echo "Please enter the SUBNET mask for this device:"
read NETMASK
echo "Please senter the GATEWAY that you will be using:"
read GATEWAY
echo "For the Domain Controller (AD):"
echo "Please enter the IP address of the Domain Controller:"
read DC
echo "Please enter the NAME of the Domain Controller:"
read NAME
echo "Please enter the REALM for the Domain Controller:"
read REALM
echo "Please enter the DOMAIN for the Domain Controller:"
read DOMAIN
echo "Please enter the ADMIN that you will be using to connect to the domain controller:"
read ADMIN
#NETWORK CONFIG
echo "NETWORKING=yes" >> /etc/sysconfig/network && echo "GATEWAY=${GATEWAY}" >> /etc/sysconfig/network
cd /etc/sysconfig/network-scripts/
mv ifcfg-${interface} ifcfg-${interface}.bak
echo "DEVICE=${interface}"> ifcfg-${interface} && echo "BOOTPROTO=static" >> ifcfg-${interface} && echo "DHCPCLASS=" >> ifcfg-${interface}
### These IP addresses will need to be changed ###
echo "DNS1=000.000.000.000" >> ifcfg-${interface}
echo "DNS2=000.000.000.000" >> ifcfg-${interface}
echo "nameserver ${DC}" > /etc/resolv.conf
ifup $interface
hostname $HOST
echo "${IP} ${HOST}.${DOMAIN} ${HOST}" >> /etc/hosts
service network restart
#Installations
yum -y update && yum -y install epel-release
yum -y install openvpn easy-rsa iptables-services sssd krb5-workstation samba samba-common oddjob oddjob-mkhomedir ntpdate ntp adcli
### for NTP, the following line can be set to use time from a specific NTP server.  Insert the link you wish to use instead and remove the comment. ###
#sed -i "s/0.centos.pool.ntp.org/ /g" /etc/ntp.conf
#sed -i "s/[1-9].centos.pool.ntp.org//g" etc/ntp.conf
systemctl restart ntpd.service
systemctl enable ntpd.service


###... Need to reconstruct missing section###


service network restart

#AD using SSSD, Samba, & Kerberos
service realmd start
systemctl enable realmd
echo "[sssd]" >> /etc/sssd/sssd.conf
echo "services = nss, pam" >> /etc/sssd/sssd.conf
echo "domains = ${DOMAIN}" >> /etc/sssd/sssd.conf
echo "" >> /etc/sssd.sssd.conf
echo "[domain/${REALM}]" >> etc/sssd/sssd.conf
echo "id_provider = ad" >> etc/sssd/sssd.conf
echo "auth_provider = ad" >> etc/sssd/sssd.conf
echo "access_provider = ad" >> etc/sssd/sssd.conf
echo "chpass_provider = ad" >> etc/sssd/sssd.conf
echo "override_homedir = /home/%d/%u" >> etc/sssd/sssd.conf
echo "" >> etc/sssd/sssd.conf
echo "ad_server = ${DC}" >> etc/sssd/sssd.conf 
echo "" >> etc/sssd/sssd.conf
chmod 600 etc/sssd/sssd.conf
chown root etc/sssd/sssd.conf
sed -i "s/EXAMPLE.COM/${REALM}/g" /var/kerberos/krb5kdc/kadm5.acl
sed -i "s/EXAMPLE.COM/${REALM}/g" /var/kerberos/krb5kdc/kdc.conf
sed -i "s/EXAMPLE.COM/${REALM}/g" /etc/krb5.conf
sed -i "s/example.com/${DOMAIN}/g" /var/krb5.conf
sed -i "s/kerberos/${HOST}/g" /etc/krb5.conf
sed -i 's/#/ /g' /etc/krb5.conf
kdb5_util create -s -r ${REALM}


