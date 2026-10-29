#!/bin/bash
set -x

echo "**********dumping BIP traffic for ABIO to ASIL CPU"
echo "**********mandatory parameter: ABIO slot id for mirroring default 5"
echo  "**********${YELLOW}Enabling mirroring for gNB$1${NC}*********"
echo  "${YELLOW}Enabling mirroring in ASIL $1${NC}"

dbgnet port 4 set speed 10g
dbgnet port 4 set mode kr
dbgnet port 4 set state forwarding

echo  "${YELLOW}Enabling mirroring in ABIO SNOWFISH $1${NC}"

bsh 1:0 "echo set port 4 pwrdown | cli -k 1234"
bsh 1:0 "echo set port attribute 4 phy-type 10gbase-kr | cli -k 1234"
bsh 1:0 "echo set port 4 up | cli -k 1234"
bsh 1:0 "echo show port 4 | cli -k 1234"
bsh 1:0 "dbgnac set port 4 loop e t"
bsh 1:0 "dbgnac mirror sport 12 dport 4 e b"
bsh 1:0 "dbgnac mirror sport 4 dport 20 e b"
bsh 1:0 "dbgnac mirror dump"
bsh 1:0 "ip link set nac_eth4 up"

