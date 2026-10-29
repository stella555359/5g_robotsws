#!/bin/bash

cd /home/ute/MN/UTE/robotws/testsuite/Bangalore/ORAN/T08/CB008957_ET/config/
scp Iphy_CB008957.xml 192.168.200.1:/ffs/run/simmode
sleep 3
ssh toor4nsn@192.168.200.1 ln -fs /ffs/run/simmode/Iphy_CB008957.xml /ffs/run/simmode/iphy.xml
ssh toor4nsn@192.168.200.1 reboot
