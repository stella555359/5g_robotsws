#!/bin/bash
echo "**********dumping BIP traffic for ABIO to ASIB CPU"
echo "**********mandatory parameter: ABIO slot id for mirroring"
echo "**********optional parameter: PCAP file name"
slot_id=$1
echo "**********right ABIO1**********"
#L1-L2 traffic
/usr/bin/lfs-nw_switch-mirror-tool.sh -p 0 -d ethsei02 -f L1_L2_UL -b "C2B4(2)" -s 5 -l eths3 -v 303
sleep 1
/usr/bin/lfs-nw_switch-mirror-tool.sh -p 0 -d ethsei02 -f L1_L2_DL -b "C2B4(2)" -s 5 -l eths3 -v 304
#L2HI_L2RT traffic
sleep 1
/usr/bin/lfs-nw_switch-mirror-tool.sh -p 0 -d ethsei02 -f L2HI_L2RT -b "C2B4(2)" -s 5 -l eths3 -v 305

echo "**********right ABIO2**********"
#L1-L2 traffic
sleep 1
/usr/bin/lfs-nw_switch-mirror-tool.sh -p 0 -d ethsei02 -f L1_L2_UL -b "C2B5(2)" -s 6 -l eths3 -v 306
sleep 1
/usr/bin/lfs-nw_switch-mirror-tool.sh -p 0 -d ethsei02 -f L1_L2_DL -b "C2B5(2)" -s 6 -l eths3 -v 307
#L2HI_L2RT traffic
sleep 1
/usr/bin/lfs-nw_switch-mirror-tool.sh -p 0 -d ethsei02 -f L2HI_L2RT -b "C2B5(2)" -s 6 -l eths3 -v 308

#L2HI_TRSW traffic
#right ABIO1
echo 3 both > /var/run/cpss/ports/5/mirroring_port 
echo 3 both > /var/run/cpss/ports/6/mirroring_port
#right ABIO2
echo 3 both > /var/run/cpss/ports/9/mirroring_port 
echo 3 both > /var/run/cpss/ports/10/mirroring_port

echo "**********Mirroring to ASIB netdriver"
ncp_portmirror -p xgmac96 -r
ncp_portmirror -d netdriver -p xgmac96
ncp_l2 -p XGMAC96 -I -senableSwitching.false
ncp_l2 -p XGMAC96 -i -sdiscardInvalidVlanidPackets.false
ncp_l2 -p XGMAC96 -i -sdiscardBadLengthPackets.false

echo "**********Dump file will be stored in /tmp/"

#sleep 1
#/opt/trs/bin/vtc vtc_traffic_capturing_start_test 1 1 1 0 0xffffffffffff file_name
sleep 1
if [ $# -eq 1 ]; then
	tcpdump -i eths3 -C 100 -W 20 -vvv -w /tmp/tcpdumpL2L1_filtering_off.pcap
else
	tcpdump -i eths3 -C 100 -W 20 -vvv -w /tmp/$2.pcap
fi
