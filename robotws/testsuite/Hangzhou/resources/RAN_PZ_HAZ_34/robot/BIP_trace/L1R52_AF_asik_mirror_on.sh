#!/bin/sh
#Script to enable Mirroring in Loner and ASIK
#Copy mirroringON.sh and loner_mirroring_v2.sh scripts to ASIK /ffs/run/config/scripts/ folder and chmod +x
#You may need to create the scripts folder
#To run it type in ASIK: sh /rom/config/scripts/mirroringON.sh
#Author: OTAVA
YELLOW='\033[33m'
NC='\033[0m' # No Color
echo -e "${YELLOW}Enabling mirroring in ABIL${NC}"
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no toor4nsn@fsp-1-1c 'sh /ffs/run/config/scripts/L1R52_AF_loner_mirror_on.sh'
echo -e "${YELLOW}Enabling mirroring in ASIK${NC}"
dbgrrc enable port 15
dbgrrc set port 15 speed 10000
#dbgrrc mirror sport 23 dport 15 e b
dbgrrc mirror sport 25 dport 15 e b
dbgrrc set port 15 mtu 9216
