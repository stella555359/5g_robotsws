#!/bin/bash
 
# enable Marvell  ports2
echo 1 >  /var/run/cpss/ports/2/enable
 
#set eths2 up
ifconfig eths2 up
 
#Enable interface and monitor ports 5&6 to port 2 ( right side amia ) or 1&2 port2
ncp_portmirror -d netdriver -p xgmac97

shell_print=$(hostname | grep -o '[0-9]*')
board_side=1
if [[ $shell_print -eq 0 ]]; then
    echo "gNB on left side of AMIA"
    echo " not tested , may not work "
    echo 2 both > /var/run/cpss/ports/0/mirroring_port          
    echo 2 both > /var/run/cpss/ports/1/mirroring_port          
    echo 2 both > /var/run/cpss/ports/2/mirroring_port    
 
else
    echo "gNB on right side of AMIA"
    echo 2 both > /var/run/cpss/ports/4/mirroring_port
    echo 2 both > /var/run/cpss/ports/5/mirroring_port
    echo 2 both > /var/run/cpss/ports/6/mirroring_port   
    echo 2 both > /var/run/cpss/ports/7/mirroring_port
    echo 2 both > /var/run/cpss/ports/8/mirroring_port
    echo 2 both > /var/run/cpss/ports/9/mirroring_port   
    echo 2 both > /var/run/cpss/ports/10/mirroring_port
    echo 2 both > /var/run/cpss/ports/11/mirroring_port
fi
 
ncp_l2 -p XGMAC97 -I -senableSwitching.false           
ncp_l2 -p XGMAC97 -i -sdiscardInvalidVlanidPackets.false
ncp_l2 -p XGMAC97 -i -sdiscardBadLengthPackets.false
 
# Tcpdump on ASIB.
echo "Collecting BIP logs to /tmp/bip.pcap"
 
tcpdump -i eths2 -w /tmp/bip.pcap -vvv
