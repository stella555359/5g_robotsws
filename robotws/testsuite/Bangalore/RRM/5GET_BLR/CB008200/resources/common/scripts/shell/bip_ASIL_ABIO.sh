#!/bin/bash

dbgnac set port 2 speed 25000
dbgnac enable port 2
dbgnac set port 2 loop e t
dbgnac mirror sport 0 dport 2 e b
dbgnac mirror sport 2 dport 20 e b
/usr/bin/netd_uspace_lnk 2 1 25000 1
ifconfig nac_eth2 up

tcpdump -i nac_eth2 -w /tmp/5GBipL2L1_filtering_off.pcap0
