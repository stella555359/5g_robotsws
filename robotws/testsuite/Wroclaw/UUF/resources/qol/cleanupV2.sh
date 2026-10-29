#!/bin/bash

# Variables
IP=${1:-1}
ID=$(sshpass -p oZPS0POrRieRtu ssh -q toor4nsn@192.168.255.$IP cat /var/dt/module-identity/unit-id | tr -d '\0')

#Set tags
GREEN='\e[32m'
RED='\e[31m'
BOLD='\e[1m'
NO_COLOR='\e[0m'
PRINT_INFO="${BOLD}[INFO]${NO_COLOR} "
PRINT_OK="${GREEN}${BOLD}[OK]${NO_COLOR} "
PRINT_ERROR="${RED}${BOLD}[ERROR]${NO_COLOR} "

echo "IP: 192.168.255.${IP}"
if [ ${ID} ]; then
    if [ ${ID} = FSMF -o ${ID} = FSIH ]; then echo -e "$PRINT_INFO Performing cleanup on $BOLD${ID}$NO_COLOR"
    echo -e "$PRINT_INFO cleanup swconfig"
    sshpass -p 'oZPS0POrRieRtu' scp /home/ute/MN/UTE/robotws/testsuite/Wroclaw/UUF/resources/qol/swconfig.txt  toor4nsn@192.168.255.$IP:/ffs/run/swconfig.txt
    echo -e "$PRINT_OK cleanup swconfig is done"
    echo -e "$PRINT_INFO cleanup mess in uboot_env and with fallbackCause"
    sshpass -p 'oZPS0POrRieRtu' ssh -tt toor4nsn@192.168.255.$IP << EOF
    uboot_env del netboot
    uboot_env del disable_watchdog
    uboot_env set uboot_recovery=1
    ddal -s ddal_boot_set_reset_loop_count 0
    rm -rfv /ffs/run/config/fallbackCause.txt
    exit
EOF
echo -e "$PRINT_OK cleanup on $BOLD${ID}$NO_COLOR is done, DZIENKI HEJ"
    else echo -e "$PRINT_INFO Performing cleanup on $BOLD${ID}$NO_COLOR"
    echo -e "$PRINT_INFO cleanup swconfig"
    sshpass -p 'oZPS0POrRieRtu' scp /home/ute/MN/UTE/robotws/testsuite/Wroclaw/UUF/resources/qol/swconfig.txt  toor4nsn@192.168.255.$IP:/ffs/run/swconfig.txt
    echo -e "$PRINT_OK cleanup swconfig is done"
    echo -e "$PRINT_INFO cleanup mess in uboot_env and with fallbackCause"
    sshpass -p 'oZPS0POrRieRtu' ssh -qtt toor4nsn@192.168.255.$IP << EOF
    uboot_env del uboot_recovery
    uboot_env del disable_watchdog
    uboot_env set netboot=netboot_first
    ddal -s ddal_boot_set_reset_loop_count 0
    rm -rfv /ffs/run/config/fallbackCause.txt
    exit
EOF
echo -e "$PRINT_OK cleanup on $BOLD${ID}$NO_COLOR is done, DZIENKI HEJ"
    fi
else echo -e "$PRINT_ERROR something goes wrong,  please try again"
fi

