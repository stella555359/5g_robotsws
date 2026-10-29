#!/bin/bash

cd /home/ute/MN/UTE/robotws/testsuite/Bangalore/ORAN/T11/CB011172/config/B_TC6
scp iphy-new.xml 192.168.200.1:/ffs/run/simmode
scp NC_SNAP_500_FJT1.xml 192.168.200.1:/ffs/run/simmode
sleep 3
ssh toor4nsn@192.168.200.1 ln -fs /ffs/run/simmode/iphy-new.xml /ffs/run/simmode/iphy.xml
ssh toor4nsn@192.168.200.1 reboot
