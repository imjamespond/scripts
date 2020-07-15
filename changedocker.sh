#!/bin/bash
ii=0
for i in $(cat ${1}); do
  ii=`expr $ii + 1`
  echo "${i} ${ii}"
  ssh -n root@$i "
  sed -i ':a;N;\$!ba;s/\"insecure-registries\":.*\\n*.*,/\"insecure-registries\":[\"127.0.0.1\",\"192.168.0.254:5000\", \"192.168.0.193:59999\"],/g' /etc/docker/daemon.json  
  systemctl restart docker 
  "
done