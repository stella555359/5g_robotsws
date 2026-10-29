#!/bin/bash
# Script to enable mirroring for gNB with ASIB+ABIO L1Bypass configuration
# https://confluence.ext.net.nokia.com/pages/viewpage.action?pageId=1041113502
# Tcpdump on ASIB.
#root@fct-4a:~ >tcpdump -i eths2 -w /tmp/bip.pcap -vvv
# enable Marvell  ports2
echo 1 >  /var/run/cpss/ports/2/enable
#set eths2 up
ifconfig eths2 up
/usr/bin/lfs-nw_switch-mirror-tool.sh -p 0 -d ethsei02 -f L2HI_L2RT -b "C2B5(2)" -s 6 -l eths2 -v 305
/usr/bin/lfs-nw_switch-mirror-tool.sh -p 0 -d ethsei02 -f L2HI_L2RT -b "C2B4(2)" -s 5 -l eths2 -v 305

#Enable interface and monitor ports 5&6 to port 2.
echo 2 both > /var/run/cpss/ports/6/mirroring_port
ncp_portmirror -d netdriver -p xgmac97

ncp_l2 -p XGMAC97 -I -senableSwitching.false
ncp_l2 -p XGMAC97 -i -sdiscardInvalidVlanidPackets.false
ncp_l2 -p XGMAC97 -i -sdiscardBadLengthPackets.false