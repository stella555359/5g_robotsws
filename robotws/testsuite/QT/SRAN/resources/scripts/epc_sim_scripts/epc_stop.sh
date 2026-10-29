#!/bin/sh

#Variables
host='localhost'
egate_port='20000'
reset='reset'
shutdown='shutdown'

#Reset and shutdown ePC SIM
( echo open ${host} ${egate_port}
sleep 2
echo ${reset}
sleep 2
echo ${shutdown}
sleep 2
) | telnet

#Kill egate and edaemon processes
sudo killall egate
sudo killall edaemon
