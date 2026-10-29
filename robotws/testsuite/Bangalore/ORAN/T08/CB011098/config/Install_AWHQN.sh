#!/bin/bash

cd /home/ute/robotws/testsuite/Bangalore/ORAN/T08/CB011098/config
scp NC1.xml 192.168.200.1:/ffs/run/simmode
scp 6NC.xml 192.168.200.1:/ffs/run/simmode
sleep 3
ssh toor4nsn@192.168.200.1 ln -fs 6NC.xml iphy.xml
ssh toor4nsn@192.168.200.1 reboot
