#!/bin/bash
set -o errexit
declare LOCATION=$(dirname $0)
LFSINSTALL="/ffs/run/swpool/TOOLS/lfs-install-helper_IB5G2PSLFSOS2018050023"

for slot in 1 2 3 5 6 7 ; do
    $LFSINSTALL sc_pool=$LOCATION src=L1PLTF/5GL1SW.itb dest=boot/5GL1SW.itb slot=${slot} device=C arch=mcu-aspa
    $LFSINSTALL sc_pool=$LOCATION src=L1NODE/5GL1FPGA0.bin dest=apps/5GL1FPGA0.bin slot=${slot} device=C arch=mcu-aspa
    $LFSINSTALL sc_pool=$LOCATION src=L1NODE/5GL1FPGA9.bin dest=apps/5GL1FPGA9.bin slot=${slot} device=C arch=mcu-aspa
done
