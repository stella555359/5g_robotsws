#!/bin/bash

shell_print=$(hostname | grep -o '[0-9]*')
board_side=1
if [[ $shell_print -eq 0 ]]; then
    board_side=1
else
    board_side=5
fi

/usr/bin/lfs-nw_switch-mirror-tool.sh -p 1 -d ethsei00 -f L1_L2_UL -b "C1B1(2)" -s $board_side -l eths2 -v 303
/usr/bin/lfs-nw_switch-mirror-tool.sh -p 1 -d ethsei00 -f L1_L2_DL -b "C1B1(2)" -s $board_side -l eths2 -v 303
ncp_portmirror -p xgmac97 -r
ncp_portmirror -d netdriver -p xgmac97
tcpdump -i eths2 -w /tmp/bip.pcap -vv
