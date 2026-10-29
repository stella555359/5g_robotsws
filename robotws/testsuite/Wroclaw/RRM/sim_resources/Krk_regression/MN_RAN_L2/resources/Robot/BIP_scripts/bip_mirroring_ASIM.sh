#!/bin/bash

dbgnac set port 5 speed 25000
dbgnac enable port 5
dbgnac set port 5 loop e t
dbgnac mirror sport 16 dport 5 e b
dbgnac mirror sport 12 dport 5 e b
dbgnac mirror sport 1 dport 5 e b
dbgnac mirror sport 5 dport 20 e i
/usr/bin/netd_uspace_lnk 5 1 25000 1
ifconfig nac_eth5 up

nohup tcpdump -v -i nac_eth5 -w /ffs/run/logs/bip_log_asim.pcap >/dev/null 2>&1 &
