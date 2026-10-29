#!/bin/bash
#Step 1 setting mirror
bcicmd -n 3msd -c '/dbg3ms/mirror set 28 13 both'
dbgnac set port 2 speed 25000
dbgnac enable port 2
dbgnac set port 2 loop e t
dbgnac mirror sport 0 dport 2 e b
dbgnac mirror sport 2 dport 20 e b
/usr/bin/netd_uspace_lnk 2 1 25000 1
ifconfig nac_eth2 up
#Step 2 dump traffic
tcpdump -i nac_eth2 -C 500 -W 5 -vvv -w /tmp/tcpdump_L2L1_bip_filtering_off.pcap


