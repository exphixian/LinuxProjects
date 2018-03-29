### This script was created for use in CentOS ###
#!/bin/bash

#ASSIGNING VARIABLES
interface=`ifconfig | awk '{print substr($1,1, length ($1)-1)}' | head -1
echo "Please enter the HOSTNAME of this device:"
read HOST
echo "Please enter the IP address for this device:"
read IP
echo "Please enter the SUBNET mask for this device:"
read NETMASK
echo "Please enter the GATEWAY that you will be using:"
read GATEWAY
echo "Please define the nameserver that you wish to use:"
read NS

#NETWORK CONFIG
echo "NETWORKING=yes" >> /etc/sysconfig/network && echo "GATEWAY=${GATEWAY}" >> /etc/sysconfig/network
cd /etc/sysconfig/network-scripts/
mv ifcfg-${interface} ifcfg-${interface}.bak
echo "DEVICE=${interface}"> ifcfg-${interface} && echo "BOOTPROTO=static" >> ifcfg-${interface} && echo "DHCPCLASS=" >> ifcfg-${interface}
echo "IPADDR=${IP}" >> ifcfg-${interface} && echo "NETMASK=${NETMASK}" >> ifcfg-${interface} && echo "GATEWAY=${GATEWAY}" >> ifcfg-${interface}
echo 'ONBOOT="yes"' >> ifcfg-${interface}
### These DNS addresses will need to be changed ###
echo "DNS1=000.000.000.000" >> ifcfg-${interface}
echo "DNS2=000.000.000.000" >> ifcfg-${interface}
echo "nameserver ${NS}" > /etc/resolv.conf
ifup $interface
hostname $HOST
echo "${IP} ${HOST}.${DOMAIN} ${HOST}" >> /etc/hosts
service network restart

done
