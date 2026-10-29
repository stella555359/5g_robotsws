#!/bin/bash


sleep 3
killall -9 egate
sudo killall -9 edaemon
cd /opt/iphy/latest
sudo ./edaemon --port 10000
./egate --port 20000
{
sleep 3
echo cfg file=/home/ute/MN/UTE/robotws/testsuite/Bangalore/ORAN/resources/BOAM_ET_resources/configurations/lua_scripts/1_cells_configuration.lua
sleep 3
echo start
sleep 1
} | telnet localhost 20000
sleep 10
