#!/bin/bash


sleep 3
sudo ip addr add 10.0.1.121/24 dev eth3
sudo ip addr add 10.0.1.131/24 dev eth3
sudo ip addr add 10.0.1.132/24 dev eth3
sudo ip addr add 10.0.1.133/24 dev eth3
sudo ip addr add 10.0.1.134/24 dev eth3
sudo ip addr add 10.0.1.135/24 dev eth3
sudo ip addr add 10.0.1.136/24 dev eth3
sudo ip addr add 10.0.1.137/24 dev eth3
sudo ip addr add 10.0.1.138/24 dev eth3
sudo ip addr add 10.0.1.150/24 dev eth3
sudo ip addr add 10.0.1.112/24 dev eth3
sleep 3
killall -9 egate
sudo killall -9 edaemon
cd /opt/wts/latest
sudo ./edaemon --port 22222
./egate --port 20000
{
sleep 3
echo cfg_sim file=/home/ute/MN/UTE/robotws/testsuite/Bangalore/ORAN/SG08/CB009037_CB006856_BOAM_ET/resources/configurations/basic_setup_G.cfg
sleep 3
echo start
sleep 1
} | telnet localhost 20000
sleep 10
