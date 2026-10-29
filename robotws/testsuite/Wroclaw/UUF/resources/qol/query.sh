#!/bin/bash
for host in `cat ip-list`
do
     printf "$host : "
     sshpass -p "uteUTE!" ssh  $host hostname || sshpass -p "uteUTE!!" ssh  $host hostname || sshpass -p "ute" ssh  $host hostname || echo "GUNWO"

done