#!/bin/bash

for host in `cat /home/ute/MN/UTE/robotws/testsuite/Wroclaw/UUF/resources/qol/NAlabs.txt`
do
     if [[ $host == "2001" ]]
     then
         password="Gamazda!20"
     else
         password="Medsql!_1893"
     fi
     printf "$host : "
     ipnode=$(host srnclab${host}node01.srnblr.nsn-rdnet.net | awk '/has address/ {print $4}')
     result=$(sshpass -p $password ssh -tt -q omc@$ipnode timeout 10 wget http://$1:8080/NE3S/1.0/NE3SRegistrationService)

     if [[ $result == *"ERROR 405:"* ]]
     then
        tput setaf 2
        echo "PASSED"
        tput sgr0
     else
        tput setaf 1
        echo "FAILED"
        tput sgr0
     fi
done
