#Script to enable BIP mirroring in loner
#Author: ANEZROUK
# info: https://confluence.int.net.nokia.com/pages/viewpage.action?pageId=904771598

# **** ethloner0 ***
# // recv from network
echo "write 0x0000F600 0x702" > /sys/kernel/debug/ixgbe/0000:04:00.1/reg_ops

# // send to network
echo "write 0x0000F604 0x704" > /sys/kernel/debug/ixgbe/0000:04:00.1/reg_ops


# **** ethbp1 ***
// recv from network

echo "write 0x0000F600 0x702" > /sys/kernel/debug/ixgbe/0000:04:00.0/reg_ops

// send to network

echo "write 0x0000F604 0x704" > /sys/kernel/debug/ixgbe/0000:04:00.0/reg_ops

# **** ethloner0 ***
tcpdump -nei ethloner0 -c 100000 -w /ffs/run/config/scripts/tcpdumpL2L1.pcap  'ether[0x18:2]!=0xe101 && ether[0x18:2]!=0x131 && ether[0x18:2]!=0x240 && ether[0x18:2]!=0x127 && ether[0x18:2]!=0x12a && ether[0x18:2]!=0x233 && ether[0x18:2]!=0x108'

# **** ethbp1 ***
# tcpdump -nei ethbp1 -c 100000 -w /ffs/run/config/scripts/tcpdumpL2L1.pcap  'ether[0x18:2]!=0xe101 && ether[0x18:2]!=0x131 && ether[0x18:2]!=0x240 && ether[0x18:2]!=0x127 && ether[0x18:2]!=0x12a && ether[0x18:2]!=0x233 && ether[0x18:2]!=0x108'