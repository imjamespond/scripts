#!/bin/bash
i=0
while read -r name ip; do
  i=`expr $i + 1`
  echo "${i}: ${name}, ${ip}"
  ssh -n root@$ip " 
  hostnamectl set-hostname ${name}
  " 
done < $1