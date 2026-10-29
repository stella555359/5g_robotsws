#!/bin/bash
# switch partition script to be run on target
# does the actual switching

echo "***** Switchpart TARGET script v.0.1 *****"
OUTPUT=$(uboot_env get active_partition)
WHICH=${OUTPUT##*=}
if [[ $WHICH = "1" ]]; then
    echo "Current detected partition 1"
    OUTPUT=$(uboot_env set active_partition=2)
    if [[ $OUTPUT = "Added 1 variables" ]]; then
        echo "Switched to partition 2"
    else
        echo "WARNING: Switching finished with errors:"
        echo $OUTPUT
    fi
elif [[ $WHICH = "2" ]]; then
    echo "Current detected partition 2"
    OUTPUT=$(uboot_env set active_partition=1)
    if [[ $OUTPUT = "Added 1 variables" ]]; then
        echo "Switched to partition 1"
    else
        echo "WARNING: Switching finished with errors:"
        echo $OUTPUT
    fi
else
    echo "ERROR: Switching finished with errors:"
    echo $OUTPUT
    exit 1
fi

sync
reboot
