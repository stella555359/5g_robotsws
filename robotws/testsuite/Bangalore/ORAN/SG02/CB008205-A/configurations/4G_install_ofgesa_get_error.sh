#!/bin/bash

cd /home/ute/MN/UTE/robotws/testsuite/Bangalore/ORAN/SG02/CB008205-A/configurations
scp OFGESA_V5_get_error_4G.xml 192.168.200.1:/ffs/run/simmode
scp 4G_OFEGSA_snapshot_v5_get_error.xml 192.168.200.1:/rom/simmode #snapshot with n1, n3 band
sleep 3
ssh toor4nsn@192.168.200.1 ln -fs /ffs/run/simmode/OFGESA_V5_get_error_4G.xml /ffs/run/simmode/iphy.xml
ssh toor4nsn@192.168.200.1 reboot
