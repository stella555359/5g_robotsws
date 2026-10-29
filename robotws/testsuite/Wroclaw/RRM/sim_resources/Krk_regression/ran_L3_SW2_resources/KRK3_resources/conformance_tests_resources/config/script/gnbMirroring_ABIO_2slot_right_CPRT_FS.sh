#!/bin/bash
echo "**********dumping BIP traffic for ABIO to ASIB CPU"
echo "**********mandatory parameter: ABIO slot id for mirroring"
echo "**********optional parameter: PCAP file name"

echo "**********right ABIO1**********"
#CPRT_L2RT 
sleep 1
/usr/bin/lfs-nw_switch-mirror-tool.sh -p 0 -d ethsei02 -f backplane_link -b "C2B4(5)" -s 5 -l eths3 -v 306

echo "**********right ABIO2**********"
#CPRT_L2RT 
sleep 1
/usr/bin/lfs-nw_switch-mirror-tool.sh -p 0 -d ethsei02 -f backplane_link -b "C2B5(5)" -s 6 -l eths3 -v 306


echo 3 both > /var/run/cpss/ports/5/mirroring_port 
echo 3 both > /var/run/cpss/ports/6/mirroring_port
echo 3 both > /var/run/cpss/ports/9/mirroring_port 
echo 3 both > /var/run/cpss/ports/10/mirroring_port


echo "**********Mirroring to ASIB netdriver"
ncp_portmirror -p xgmac96 -r
ncp_portmirror -d netdriver -p xgmac96
ncp_l2 -p XGMAC96 -I -senableSwitching.false
ncp_l2 -p XGMAC96 -i -sdiscardInvalidVlanidPackets.false
ncp_l2 -p XGMAC96 -i -sdiscardBadLengthPackets.false

echo "**********Dump file will be stored in /tmp/"

sleep 1
/opt/trs/bin/vtc vtc_traffic_capturing_start_test 1 1 1 0 0xffffffffffff file_name
