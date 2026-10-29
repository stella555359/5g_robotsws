#!/bin/bash

cd /home/ute/robotws/testsuite/Bangalore/ORAN/T11/CB014151/config
scp iphy-SDL.xml 192.168.200.1:/ffs/run/simmode
scp NC_SNAP_500_FJT.xml 192.168.200.1:/ffs/run/simmode
sleep 3
ssh toor4nsn@192.168.200.1 ln -fs /ffs/run/simmode/iphy-SDL.xml /ffs/run/simmode/iphy.xml
ssh toor4nsn@192.168.200.1 reboot
