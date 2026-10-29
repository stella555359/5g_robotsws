#!/bin/bash

sleep 3
cd /home/ute/MN/UTE/robotws/testsuite/Bangalore/ORAN/T08/CB012450/NR-TDD/resources/configurations
scp Iphy7.xml 192.168.200.1:/ffs/run/simmode     #iphy for 2 O-RU's
scp 25R2_NCSnapshot-AWHQN.xml 192.168.200.1:/ffs/run/simmode #snapshot with n78 band
#scp samji_ncs_2.xml 192.168.200.1:/ffs/run/simmode #snapshot with n78 band
ssh toor4nsn@192.168.200.1 ln -fs /ffs/run/simmode/Iphy7.xml /ffs/run/simmode/iphy.xml
ssh toor4nsn@192.168.200.1 reboot
sleep 5
cd /home/ute/MN/UTE/robotws/testsuite/Bangalore/ORAN/T08/CB012450/NR-TDD/resources/configurations
sudo cp Basic_4Cell.cfg /opt/iphy/latest
sleep 5
cd /opt/iphy/latest
sudo chmod 777 /opt/iphy/*
sleep 5


