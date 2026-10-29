#!/bin/bash

cd /home/ute/robotws/testsuite/Bangalore/ORAN/T11/CB011172/config/AC3_TC1
scp iphy-new.xml 192.168.200.1:/ffs/run/simmode
scp NC_SNAP_500_FJT1.xml 192.168.200.1:/ffs/run/simmode
scp NC_SNAP_500_FJT2.xml 192.168.200.1:/ffs/run/simmode
scp TDD_NCSNAP_10APR_RU1.xml 192.168.200.1:/ffs/run/simmode
scp TDD_NCSNAP_10APR_RU2.xml 192.168.200.1:/ffs/run/simmode
scp TDD_NCSNAP_10APR_RU3.xml 192.168.200.1:/ffs/run/simmode
sleep 3
ssh toor4nsn@192.168.200.1 ln -fs /ffs/run/simmode/iphy-new.xml /ffs/run/simmode/iphy.xml
ssh toor4nsn@192.168.200.1 reboot
