#!/bin/bash

sleep 3
cd /home/ute/MN/UTE/robotws/testsuite/Bangalore/ORAN/T08/CB013328-NR/configurations
scp KDDI_iphy.xml 192.168.200.1:/ffs/fs2/simmode     #iphy for 2 O-RU's
scp KDDI_iphy.xml 192.168.200.1:/ffs/fs1/simmode     #iphy for 2 O-RU's
scp NCS_KDDI_updated.xml 192.168.200.1:/ffs/fs2/simmode #snapshot for NR ORAN TDD n77 band
scp NCS_KDDI_updated.xml 192.168.200.1:/ffs/fs1/simmode #snapshot for NR ORAN TDD n77 band
ssh toor4nsn@192.168.200.1 ln -fs /ffs/run/simmode/KDDI_iphy.xml /ffs/run/simmode/iphy.xml
ssh toor4nsn@192.168.200.1 cp /opt/UE_APP_OAM/eaxc_conf_profiles/latest/ORAN_LfFdd3rdParty_c_eAxC_IdMapping.json /rom/simmode/
ssh toor4nsn@192.168.200.1 reboot
sleep 5
cd /home/ute/MN/UTE/robotws/testsuite/Bangalore/ORAN/T08/CB013328-NR/configurations
cp basic_setup_KDDI.cfg /opt/iphy/latest
sleep 5