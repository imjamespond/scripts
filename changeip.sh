#!/bin/bash
sshpass -p dataSharing ssh -o stricthostkeychecking=no -tt root@192.168.0.245  <<EOF
  sed -i 's/IPADDR="192.168.0.245"/IPADDR="192.168.0.${1}"/g' /etc/sysconfig/network-scripts/ifcfg-ens192 
  systemctl restart network 
EOF