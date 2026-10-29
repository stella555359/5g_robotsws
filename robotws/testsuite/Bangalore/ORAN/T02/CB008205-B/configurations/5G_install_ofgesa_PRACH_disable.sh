#!/bin/bash

cd /home/ute/MN/UTE/robotws/testsuite/Bangalore/ORAN/T02/CB008205-B/configurations
scp OFGESA_v7_PRACH_disabled.xml 192.168.200.1:/ffs/run/simmode
scp OFGESA_snapshot_v7_PRACH_disabled.xml 192.168.200.1:/rom/simmode #snapshot with n1, n3 band
sleep 3
ssh toor4nsn@192.168.200.1 ln -fs /ffs/run/simmode/OFGESA_v7_PRACH_disabled.xml /ffs/run/simmode/iphy.xml
ssh toor4nsn@192.168.200.1 reboot
