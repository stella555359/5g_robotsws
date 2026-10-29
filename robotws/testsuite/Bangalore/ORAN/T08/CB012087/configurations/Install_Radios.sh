#!/bin/bash

sleep 3
cd /home/ute/MN/UTE/robotws/testsuite/Bangalore/ORAN/T08/CB012087/configurations
scp CB012087_iphy.xml 192.168.200.1:/ffs/fs2/simmode     #iphy for 2 O-RU's
scp CB012087_iphy.xml 192.168.200.1:/ffs/fs1/simmode     #iphy for 2 O-RU's
scp FJT_NCS_v500_FJT1.xml 192.168.200.1:/ffs/fs1/simmode #snapshot for NR ORAN TDD n77 band
scp FJT_NCS_v500_FJT2.xml 192.168.200.1:/ffs/fs1/simmode #snapshot for NR ORAN TDD n77 band
scp FJT_NCS_v500_FJT1.xml 192.168.200.1:/ffs/fs2/simmode #snapshot for NR ORAN TDD n77 band
scp FJT_NCS_v500_FJT2.xml 192.168.200.1:/ffs/fs2/simmode #snapshot for NR ORAN TDD n77 band
ssh toor4nsn@192.168.200.1 ln -fs /ffs/run/simmode/CB012087_iphy.xml /ffs/run/simmode/iphy.xml
ssh toor4nsn@192.168.200.1 reboot
sleep 5
cd /home/ute/MN/UTE/robotws/testsuite/Bangalore/ORAN/T08/CB012087/configurations
cp Basic_setup_2LTE_1NRcell.cfg /opt/iphy/latest
sleep 5