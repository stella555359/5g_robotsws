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
bsh 1:2 'sh /ffs/run/config/scripts/L1R51_GNB_loner_mirror_on.sh'
echo -e "${YELLOW}Enabling ASIK mirroring${NC}"
dbgrrc set port 2 mtu 9216
dbgrrc set port 23 mtu 9216
dbgrrc set port 25 mtu 9216
dbgrrc set port 15 speed 10000
dbgrrc mirror sport 23 dport 2 e b
dbgrrc mirror sport 25 dport 2 e b



