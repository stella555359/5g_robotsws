#!/bin/bash
echo "**********dumping BIP traffic for ABIO to ASIB CPU"
echo "**********mandatory parameter: ABIO slot id for mirroring"
echo "**********optional parameter: PCAP file name"
slot_id=$1

if [ $slot_id -lt 4 ]; then
    fcp_id=1
	fsp_id=$slot_id
else
    fcp_id=2
	fsp_id=$(($slot_id-1))
fi

echo "C${fcp_id}B${fsp_id}(2)"

#L1-L2 traffic
/usr/bin/lfs-nw_switch-mirror-tool.sh -p 0 -d ethsei02 -f L1_L2_UL -b "C${fcp_id}B${fsp_id}(2)" -s $slot_id -l eths3 -v 303
sleep 1
/usr/bin/lfs-nw_switch-mirror-tool.sh -p 0 -d ethsei02 -f L1_L2_DL -b "C${fcp_id}B${fsp_id}(2)" -s $slot_id -l eths3 -v 304
#L2HI_L2RT traffic
sleep 1
/usr/bin/lfs-nw_switch-mirror-tool.sh -p 0 -d ethsei02 -f L2HI_L2RT -b "C${fcp_id}B${fsp_id}(2)" -s $slot_id -l eths3 -v 305

#L2HI_TRSW traffic
sleep 1
if [ $slot_id -eq 1 ] || [ $slot_id -eq 5 ]; then
	port1=5
	port2=6
elif [ $slot_id -eq 2 ] || [ $slot_id -eq 6 ]; then
	port1=9
	port2=10
elif [ $slot_id -eq 3 ] || [ $slot_id -eq 7 ]; then
	port1=13
	port2=14
fi

echo 3 both > /var/run/cpss/ports/$port1/mirroring_port
echo 3 both > /var/run/cpss/ports/$port2/mirroring_port

echo "**********Mirroring to ASIB netdriver"
ncp_portmirror -p xgmac96 -r
ncp_portmirror -d netdriver -p xgmac96
ncp_l2 -p XGMAC96 -I -senableSwitching.false
ncp_l2 -p XGMAC96 -i -sdiscardInvalidVlanidPackets.false
ncp_l2 -p XGMAC96 -i -sdiscardBadLengthPackets.false

echo "**********Dump file will be stored in /tmp/"
echo "collecting L1L2 logs"

if [ $# -eq 1 ]; then
	tcpdump -vvv -i eths3 -C 500 -W 10 -w /tmp/trace_ABIO.pcap
else
	tcpdump -vvv -i eths3 -C 500 -W 10 -w /tmp/$2.pcap
fi
