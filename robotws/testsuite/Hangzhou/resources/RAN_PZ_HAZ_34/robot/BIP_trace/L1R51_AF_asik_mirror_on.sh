#!/bin/sh
# Script to enable mirroring in Loner and forward it in ASIK RRCto EIF2
# Usage
#   - mkdir /ffs/run/config/scripts/
#   - Copy mirrorToEif2_L1R51.sh and loner_mirroring_L1R51.sh to ASIK /ffs/run/config/scripts/ folder
#   - give execution rights chmod +x /ffs/run/config/scripts/*.sh
#   - sh /ffs/run/config/scripts/mirrorToEif2_L1R51.sh
# Author: OTAVA
RED='\033[0;31m'
BLUE='\033[36m'
YELLOW='\033[33m'
NC='\033[0m' # No Color
echo -e "${YELLOW}Go to Loner and run the enable mirroring script${NC}"
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no toor4nsn@192.168.253.22 'sh /ffs/run/config/scripts/L1R51_AF_loner_mirror_on.sh'
echo -e "${YELLOW}Enabling ASIK mirroring${NC}"
dbgrrc enable port 15
dbgrrc set port 15 speed 10000
#dbgrrc mirror sport 23 dport 15 e b
dbgrrc mirror sport 25 dport 15 e b
dbgrrc set port 15 mtu 9216
