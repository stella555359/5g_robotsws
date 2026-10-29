#!/bin/bash

cd /home/ute/MN/UTE/robotws/testsuite/Bangalore/ORAN/T11/CB012648/config
scp ASOH_Iphy.xml 25R2_NCSnapshot-AWHQN* 192.168.200.1:/ffs/run/simmode/
sleep 3
ssh toor4nsn@192.168.200.1 ln -fs /ffs/run/simmode/ASOH_Iphy.xml /ffs/run/simmode/iphy.xml
ssh toor4nsn@192.168.200.1 reboot
