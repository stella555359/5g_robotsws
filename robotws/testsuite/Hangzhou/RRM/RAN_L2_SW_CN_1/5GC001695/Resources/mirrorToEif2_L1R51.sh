#!/bin/sh
# Script to enable mirroring in Loner and forward it in ASIK RRCto EIF2
# Usage
#   - mkdir /ffs/run/config/scripts/
#   - Copy mirrorToEif2_L1R51.sh and loner_mirroring_L1R51.sh to ASIK /ffs/run/config/scripts/ folder
#   - give execution rights chmod +x /ffs/run/config/scripts/*.sh
#   - sh /ffs/run/config/scripts/mirrorToEif2_L1R51.sh
# Author: OTAVA
dbgrrc mirror sport 25 dport 21 enable both
dbgrrc mirror sport 23 dport 21 enable both
