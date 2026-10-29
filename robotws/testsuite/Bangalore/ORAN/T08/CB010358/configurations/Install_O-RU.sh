#!/bin/bash

sleep 3
cd /home/ute/MN/UTE/robotws/testsuite/Bangalore/ORAN/T08/CB010358/configurations
scp iphy_1awhqn_1AZQI.xml 192.168.200.1:/ffs/fs2/simmode     #iphy file for one O-RU OSQA
scp iphy_1awhqn_1AZQI.xml 192.168.200.1:/ffs/fs1/simmode     #iphy file for one O-RU OSQA
scp NC1.xml 192.168.200.1:/ffs/fs2/simmode #snapshot for NR TDD
scp NC1.xml 192.168.200.1:/ffs/fs1/simmode #snapshot for NR TDD
ssh toor4nsn@192.168.200.1 ln -fs /ffs/run/simmode/iphy_1awhqn_1AZQI.xml /ffs/run/simmode/iphy.xml
sleep 2
ssh toor4nsn@192.168.200.1 reboot
sleep 5
cd /home/ute/MN/UTE/robotws/testsuite/Bangalore/ORAN/T08/CB010358/configurations
cp basic_setup_AWHQN_1cellconfig.cfg /opt/iphy/latest
sleep 5