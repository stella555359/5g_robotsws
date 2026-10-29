#!/bin/bash
# Script to enable mirroring for gNB with ASIL+ABIO L1Bypass configuration
# Tcpdump on ASIL.
# Example : tcpdump -i nac_eth2 -w /user/toor4nsn/gnbL1L2.pcap

# 2021/10/19 : BHO: FIVEG_FTPS-32788: [LO_L1BP] missing messages in L1/L2 pcap traces
# bcicmd -n 3msd -c '/dbg3ms/mirror set 28 13 ingress'
bcicmd -n 3msd -c '/dbg3ms/mirror set 28 13 both'
dbgnac set port 2 speed 25000
dbgnac enable port 2
dbgnac set port 2 loop e t
dbgnac mirror sport 0 dport 2 e b
dbgnac mirror sport 2 dport 20 e b
/usr/bin/netd_uspace_lnk 2 1 25000 1
ifconfig nac_eth2 up
