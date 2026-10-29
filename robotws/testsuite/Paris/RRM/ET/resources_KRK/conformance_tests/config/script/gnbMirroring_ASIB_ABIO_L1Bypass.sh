#!/bin/bash
# Script to enable mirroring for gNB with ASIB+ABIO L1Bypass configuration
# https://confluence.ext.net.nokia.com/pages/viewpage.action?pageId=1041113502
# Tcpdump on ASIB.
#root@fct-4a:~ >tcpdump -i eths2 -w /tmp/bip.pcap -vvv
# enable Marvell  ports2
echo 1 >  /var/run/cpss/ports/2/enable
#set eths2 up
ifconfig eths2 up
#Enable interface and monitor ports 5&6 to port 2.
ncp_portmirror -d netdriver -p xgmac97
echo 2 both > /var/run/cpss/ports/4/mirroring_port
echo 2 both > /var/run/cpss/ports/5/mirroring_port
echo 2 both > /var/run/cpss/ports/6/mirroring_port
ncp_l2 -p XGMAC97 -I -senableSwitching.false
ncp_l2 -p XGMAC97 -i -sdiscardInvalidVlanidPackets.false
ncp_l2 -p XGMAC97 -i -sdiscardBadLengthPackets.false