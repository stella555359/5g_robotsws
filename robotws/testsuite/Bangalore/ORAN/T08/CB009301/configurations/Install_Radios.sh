#!/bin/bash

sleep 3
cd /home/ute/robotws/testsuite/Bangalore/ORAN/T07/CB009301/configurations
scp 9301_iphy.xml 192.168.200.1:/ffs/fs2/simmode     #iphy for 2 O-RU's
scp 9301_iphy.xml 192.168.200.1:/ffs/fs1/simmode     #iphy for 2 O-RU's
scp 25R2_NCSnapshot-AWHQN_V12.xml 192.168.200.1:/ffs/fs2/simmode #snapshot for NR ORAN TDD n77 band
scp 25R2_NCSnapshot-AWHQN_V12.xml 192.168.200.1:/ffs/fs1/simmode #snapshot for NR ORAN TDD n77 band
ssh toor4nsn@192.168.200.1 ln -fs /ffs/run/simmode/9301_iphy.xml /ffs/run/simmode/iphy.xml
ssh toor4nsn@192.168.200.1 reboot
sleep 5
cd /home/ute/robotws/testsuite/Bangalore/ORAN/T07/CB009301/configurations
cp basic_setup_9301.cfg /opt/iphy/latest
sleep 5