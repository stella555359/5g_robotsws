#!/bin/sh
# Script to enable Mirroring in Loner and tcpdumps to ABIL Slave Xeon.
# ASIK can be on left or right side of AMIA and ABIL must be in the first slot above ASIK
# Usage
#   - mkdir /ffs/run/config/scripts/
#   - Copy automaticL2L1Tcpdump_L1R51.sh and loner_mirroring_L1R51.sh to ASIK /ffs/run/config/scripts/ folder
#   - give execution rights chmod +x /ffs/run/config/scripts/*.sh
#   - sh /ffs/run/config/scripts/automaticL2L1Tcpdump_L1R51.sh
#   - capture is written to /ffs/run/config/scripts/tcpdumpL2L1.pcap
#   - Remember to delete capture from ASIK after copying 
#
# Note! There's capture filter in tcpdump which filters out the following messages
#   - SyncInd 0x206
#   - PatternConfigReq 0x116
#   - SlotTypeReq 0x122
#   - CsiRsSendReq 0x120
#   - SsBlocSendReq 0x123
#   - PrachReceiveReq 0x233
#
# Author: OTAVA
YELLOW='\033[33m'
NC='\033[0m' # No Color
echo -e "${YELLOW}Enabling mirroring in Loner${NC}"
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no toor4nsn@192.168.253.22 'sh /ffs/run/config/scripts/loner_mirroring_L1R51.sh'
echo -e "${YELLOW}Enabling RRC mirroring from loner interface to ASIK Slave Xeon${NC}"
dbgrrc mirror sport 25 dport 21 e b
echo -e "${YELLOW}tcpdump 100000 packets and filter TTI based messages. Output is saved to /ffs/run/config/scripts/tcpdumpL2L1.pcap${NC}"
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no toor4nsn@192.168.253.21 "tcpdump -i ethbp1 -c 100000 -w /ffs/run/config/scripts/tcpdumpL2L1.pcap 'ether[0x18:2]!=0x206 && ether[0x18:2]!=0x116 && ether[0x18:2]!=0x122 && ether[0x18:2]!=0x123 && ether[0x18:2]!=0x233'"
echo -e "${YELLOW}Disable RRC mirroring from loner interface to ASIK Slave Xeon${NC}"
dbgrrc mirror sport 25 dport 21 d b
