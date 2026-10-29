#!/bin/bash

ips=(10.42.165.x 10.42.165.24 10.42.165.y)

for ip in "${ips[@]}"
do
    echo -e "\nVirtual machine IP address: $ip"   
    ssh $ip 'sudo bash -s' < ./mount_burak.sh
done
