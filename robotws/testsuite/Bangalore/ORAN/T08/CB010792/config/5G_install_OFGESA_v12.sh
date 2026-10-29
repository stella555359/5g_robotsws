#!/bin/bash

cd /home/ute/MN/UTE/robotws/testsuite/Bangalore/ORAN/T08/CB010792/config/
scp Iphy_v12_125.xml 192.168.200.1:/ffs/run/simmode
sleep 3
ssh toor4nsn@192.168.200.1 ln -fs /ffs/run/simmode/Iphy_v12_125.xml /ffs/run/simmode/iphy.xml
ssh toor4nsn@192.168.200.1 reboot
