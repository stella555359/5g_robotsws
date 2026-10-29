#!/bin/bash

#Variables
if [[ ${HOSTNAME} =~ "IPHY"|"CLOUD"|"TDD-AIRSCALE-WRO" ]]; then
    cfg_file='cfg file=/home/ute/robotlte/testsuite/legacy/UTE/wtssim/new_configuration.lua'
else
    cfg_file='cfg file=/home/ute/robotlte/resources/QT/epc_sim_files/'${HOSTNAME}'/epc.lua'
fi

host='localhost'
egate_port='20000'
edaemon_port='10000'
_start='start'
_exit='exit'

#Kill egate and edaemon processes
sudo killall egate
sudo killall edaemon

#ePC SIM start
cd /opt/iphy/latest
sudo -i sysctl -w net.ipv4.ip_forward=1
sudo modprobe sctp
./egate --port ${egate_port}
sudo ./edaemon --port ${edaemon_port}

#Manual login to the EGATE console
#telnet ${host} ${egate_port}

#Load cfg file and start ePC SIM
( echo open ${host} ${egate_port}
sleep 2
echo ${cfg_file}
sleep 2
echo ${_start}
sleep 2
echo ${_exit}
sleep 2
) | telnet
