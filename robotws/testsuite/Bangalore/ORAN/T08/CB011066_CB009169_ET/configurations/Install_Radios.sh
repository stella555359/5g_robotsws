#!/bin/bash

sleep 3
cd /home/ute/MN/UTE/robotws/testsuite/Bangalore/ORAN/T08/CB011066_CB009169_ET/configurations
scp IPHY.xml 192.168.200.1:/ffs/run/simmode     #iphy for 2 O-RU's
#scp new_iphy.xml 192.168.200.1:/ffs/fs1/simmode     #iphy for 2 O-RU's
scp fjt_4T4R_FDD_n1_n3_n75_v7.xml 192.168.200.1:/ffs/run/simmode #snapshot for NR FDD n1, n3 & n75 band
scp fjt_4T4R_FDD_n1_n3_n75_v7_1.xml 192.168.200.1:/ffs/run/simmode #snapshot for NR FDD n1, n3 & n75 band
#scp fjt_4T4R_FDD_n1_n3_n75_v7.xml 192.168.200.1:/ffs/fs1/simmode #snapshot for NR FDD n1, n3 & n75 band
#scp fjt_4T4R_FDD_n1_n3_n75_v7_1.xml 192.168.200.1:/ffs/fs1/simmode #snapshot for NR FDD n1, n3 & n75 band
ssh toor4nsn@192.168.200.1 ln -fs /ffs/run/simmode/IPHY.xml /ffs/run/simmode/iphy.xml
ssh toor4nsn@192.168.200.1 reboot
sleep 5
cd /home/ute/MN/UTE/robotws/testsuite/Bangalore/ORAN/T08/CB011066_CB009169_ET/configurations
cp basic_setup_11066.cfg /opt/iphy/latest
sleep 5