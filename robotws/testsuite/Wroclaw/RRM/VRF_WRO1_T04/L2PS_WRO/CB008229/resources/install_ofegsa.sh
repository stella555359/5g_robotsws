#!/bin/bash

iphy_path=$1
iphy=$2

cd $iphy_path
scp $iphy 192.168.200.1:/ffs/run/simmode
scp fjt_4T4R_FDD_n1_n3_n75_v7.xml 192.168.200.1:/rom/simmode
sleep 3
ssh toor4nsn@192.168.200.1 ln -fs /ffs/run/simmode/$iphy /ffs/run/simmode/iphy.xml
#ssh toor4nsn@192.168.200.1 reboot
