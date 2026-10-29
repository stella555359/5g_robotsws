#!/bin/bash
# Script to enable BIP traces for gNB with ASOE Full Stack configuration
# Commands to be launched on gNB:
#   root@asc-0a:~ >/usr/bin/lfs-nw_switch-mirror-tool.sh -S 1010 -f L1_L2_LOKIA_SNF -d 13
#   root@asc-0a:~ >bsh 0:1
#   asc-0b:~# tcpdump -i etha01 -w ASOE_BIP.pcap
#
echo "********** BIP Traces for ASOE and FS AP **********"
/usr/bin/lfs-nw_switch-mirror-tool.sh -S 1010 -f L1_L2_LOKIA_SNF -d 13
