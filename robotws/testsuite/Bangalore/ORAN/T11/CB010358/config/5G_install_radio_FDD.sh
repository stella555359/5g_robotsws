#!/bin/bash

cd /home/ute/MN/UTE/robotws/testsuite/Bangalore/ORAN/T11/CB010358/config
scp Iphy_FDD.xml 192.168.200.1:/ffs/run/simmode
sleep 3
ssh toor4nsn@192.168.200.1 ln -fs /ffs/run/simmode/Iphy_FDD.xml /ffs/run/simmode/iphy.xml
ssh toor4nsn@192.168.200.1 reboot
