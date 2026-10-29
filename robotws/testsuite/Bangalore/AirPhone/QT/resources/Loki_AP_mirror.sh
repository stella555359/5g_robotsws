#!/bin/bash
set -x

echo "**********dumping BIP traffic for ABIO to ASIL CPU"
echo "**********mandatory parameter: ABIO slot id for mirroring default 5"

slot_id=1
if [ $slot_id -lt 4 ]; then
    fcp_id=1
	fsp_id=$slot_id
else
    fcp_id=2
	fsp_id=$(($slot_id-1))
fi

#L1-L2 traffic
/usr/bin/lfs-nw_switch-mirror-tool.sh -p 0 -d sei11 -f L1_L2_UL -b "C${fcp_id}B${fsp_id}(6)" -s $slot_id -v 303
sleep 1
/usr/bin/lfs-nw_switch-mirror-tool.sh -p 0 -d sei11 -f L1_L2_DL -b "C${fcp_id}B${fsp_id}(6)" -s $slot_id -v 304
#L2HI_L2RT traffic
sleep 1
/usr/bin/lfs-nw_switch-mirror-tool.sh -p 0 -d sei11 -f L2HI_L2RT -b "C${fcp_id}B${fsp_id}(6)" -s $slot_id -v 305

#Close ASIL MAC learning
bcicmd -n 3msd -c "/dbg3ms/port 36 set learning 0 0 1"

#ASIL config vlan to port 13
bcicmd -n 3msd -c "/dbg3ms/vlan add 303 13 untagged"
bcicmd -n 3msd -c "/dbg3ms/vlan add 304 13 untagged"
bcicmd -n 3msd -c "/dbg3ms/vlan add 305 13 untagged"
bcicmd -n 3msd -c "/dbg3ms/vlan remove 303 21"
bcicmd -n 3msd -c "/dbg3ms/vlan remove 304 21"
bcicmd -n 3msd -c "/dbg3ms/vlan remove 305 21"

dbgnac set port 2 speed 25000
dbgnac enable port 2
dbgnac set port 2 loop e t
dbgnac mirror sport 0 dport 2 e b
dbgnac mirror sport 2 dport 20 e b
/usr/bin/netd_uspace_lnk 2 1 25000 1
ifconfig nac_eth2 up
ifconfig nac_eth2 promisc

#sleep 2
#dbgnac enable port 2
#ifconfig nac_eth2 up
#ifconfig nac_eth2 promisc
#echo "**********Dump file will be stored in /tmp/"
#tcpdump -vvv -i nac_eth2 -C 100 -W 20 -w /tmp/trace_ABIO.pcap


