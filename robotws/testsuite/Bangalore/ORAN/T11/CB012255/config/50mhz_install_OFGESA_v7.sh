#!/bin/bash

cd /home/ute/MN/UTE/robotws/testsuite/Bangalore/ORAN/T11/CB012255/config
scp 50mhz_iphy.xml 192.168.200.1:/ffs/run/simmode
sleep 3
ssh toor4nsn@192.168.200.1 ln -fs /ffs/run/simmode/50mhz_iphy.xml /ffs/run/simmode/iphy.xml
sleep 2
ssh toor4nsn@192.168.200.1 reboot
