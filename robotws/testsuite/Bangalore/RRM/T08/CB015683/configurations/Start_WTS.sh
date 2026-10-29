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
sh cfg_sim file=/home/ute/MN/UTE/robotws/testsuite/Bangalore/RRM/T08/CB015683/configurations/basic_setup.cfg
sleep 10
sh cfg_sim file=/home/ute/MN/UTE/robotws/testsuite/Bangalore/RRM/T08/CB015683/configurations/x2.sh
sleep 3
echo start
sleep 1
} | telnet localhost 20000
sleep 10

