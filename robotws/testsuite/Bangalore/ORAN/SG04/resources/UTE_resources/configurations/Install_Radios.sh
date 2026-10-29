#!/bin/bash

sleep 3
cd /home/ute/MN/UTE/robotws/testsuite/Bangalore/ORAN/SG04/resources/UTE_resources/configurations
scp new_iphy.xml 192.168.200.1:/ffs/fs2/simmode     #iphy for 2 O-RU's
scp new_iphy.xml 192.168.200.1:/ffs/fs1/simmode     #iphy for 2 O-RU's
scp fjt_4T4R_FDD_n1_n3_n75_v7.xml 192.168.200.1:/ffs/fs2/simmode #snapshot for NR FDD n1, n3 & n75 band
#scp fjt_4T4R_FDD_n1_n3_n75_v7_1.xml 192.168.200.1:/ffs/fs2/simmode #snapshot for NR FDD n1, n3 & n75 band
scp fjt_4T4R_FDD_n1_n3_n75_v7.xml 192.168.200.1:/ffs/fs1/simmode #snapshot for NR FDD n1, n3 & n75 band
#scp fjt_4T4R_FDD_n1_n3_n75_v7_1.xml 192.168.200.1:/ffs/fs1/simmode #snapshot for NR FDD n1, n3 & n75 band
ssh toor4nsn@192.168.200.1 ln -fs /ffs/run/simmode/new_iphy.xml /ffs/run/simmode/iphy.xml
sleep 5
ssh toor4nsn@192.168.200.1 reboot
sleep 5
cd /home/ute/MN/UTE/robotws/testsuite/Bangalore/ORAN/SG04/resources/UTE_resources/configurations
cp basic_setup_FJT.cfg /opt/iphy/latest
sleep 5
