#!/bin/bash

cd /home/ute/MN/UTE/robotws/testsuite/Bangalore/ORAN/T11/CB014100/config
scp iphy_v17_v12_v7.xml 192.168.200.1:/ffs/run/simmode
sleep 3
ssh toor4nsn@192.168.200.1 ln -fs /ffs/run/simmode/iphy_v17_v12_v7.xml /ffs/run/simmode/iphy.xml
ssh toor4nsn@192.168.200.1 reboot
