#!/bin/bash
#Step 1 setting mirror
echo 1 > /var/run/cpss/ports/2/enable
ifconfig eths2 up
ncp_portmirror -d netdriver -p xgmac97
echo 2 both > /var/run/cpss/ports/4/mirroring_port
echo 2 both > /var/run/cpss/ports/5/mirroring_port
echo 2 both > /var/run/cpss/ports/6/mirroring_port
echo 2 both > /var/run/cpss/ports/8/mirroring_port
echo 2 both > /var/run/cpss/ports/9/mirroring_port
echo 2 both > /var/run/cpss/ports/10/mirroring_port
ncp_l2 -p XGMAC97 -I -senableSwitching.false
ncp_l2 -p XGMAC97 -i -sdiscardInvalidVlanidPackets.false
ncp_l2 -p XGMAC97 -i -sdiscardBadLengthPackets.false
#Step 2 dump traffic
tcpdump -i eths2 -C 100 -W 20 -vvv -w /tmp/5GBipL2L1_filtering_off.pcap



