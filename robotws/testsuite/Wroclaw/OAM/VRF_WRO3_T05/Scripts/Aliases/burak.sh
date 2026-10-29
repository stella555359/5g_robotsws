#!/bin/bash
mkdir -p /home/ute/Desktop/burak; sudo mount -t cifs //10.42.248.45/Global_veryfication/[6]_CSV1/SW/sw_zip /home/ute/Desktop/burak -o username=uufwro,password=uufpass18,rw,nounix,file_mode=0777,dir_mode=0777,uid=ute,gid=ute,domain=noklab
echo "burak with UUF SW packages mounted. You can find it under /home/ute/Desktop/burak"