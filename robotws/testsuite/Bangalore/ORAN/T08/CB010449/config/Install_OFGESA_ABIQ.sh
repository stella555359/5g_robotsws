#!/bin/bash

cd /home/ute/MN/UTE/robotws/testsuite/Bangalore/ORAN/T08/CB010449/config/
scp Mix_ABIQ_12cell_n1n3.xml 192.168.200.1:/ffs/run/simmode
sleep 3
ssh toor4nsn@192.168.200.1 ln -fs /ffs/run/simmode/Mix_ABIQ_12cell_n1n3.xml /ffs/run/simmode/iphy.xml
ssh toor4nsn@192.168.200.1 reboot
