#!/bin/bash

cd /home/ute/robotws/testsuite/Bangalore/ORAN/T08/CB012647/config/
scp LTENR.xml 192.168.200.1:/ffs/run/simmode
sleep 3
ssh toor4nsn@192.168.200.1 ln -fs LTENR.xml iphy.xml
ssh toor4nsn@192.168.200.1 reboot
