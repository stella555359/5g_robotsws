#!/bin/bash

cd /home/ute/MN/UTE/robotws/testsuite/Bangalore/ORAN/T11/CB011172/config/AD_TC3
scp iphy-new.xml 192.168.200.1:/ffs/run/simmode
scp NC_SNAP_500_FJT.xml 192.168.200.1:/ffs/run/simmode
sleep 3
ssh toor4nsn@192.168.200.1 ln -fs /ffs/run/simmode/iphy-new.xml /ffs/run/simmode/iphy.xml
ssh toor4nsn@192.168.200.1 reboot

sleep 2

sudo ip addr add 10.0.1.131/24 dev eth3
sudo ip addr add 10.0.1.122/24 dev eth3
sudo ip addr add 10.0.1.124/24 dev eth3
sudo ip addr add 10.0.1.125/24 dev eth3
sudo ip addr add 10.0.1.123/24 dev eth3
sudo ip addr add 10.0.1.126/24 dev eth3
sudo ip addr add 10.0.1.128/24 dev eth3
sudo ip addr add 10.0.1.131/24 dev eth3
sudo ip addr add 10.0.1.12/24 dev eth3
sudo ip addr add 10.0.1.133/24 dev eth3
sudo ip addr add 10.0.1.134/24 dev eth3
sudo ip addr add 10.0.1.135/24 dev eth3
sudo ip addr add 10.0.1.136/24 dev eth3
sudo ip addr add 10.0.2.91/24 dev eth3
sudo ip addr add 10.0.1.121/24 dev eth3
sudo ip addr add 10.0.1.137/24 dev eth3
sudo ip addr add 10.0.1.111/24 dev eth3
sudo ip addr add 10.0.1.112/24 dev eth3
sudo ip addr add 10.0.1.10/24 dev eth3
sudo ip addr add 10.0.1.210/24 dev eth3