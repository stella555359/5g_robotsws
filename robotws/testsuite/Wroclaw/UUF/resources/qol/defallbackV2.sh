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
    if [ ${ID} = FSMF -o ${ID} = FSIH ]; then echo -e "$PRINT_INFO Performing defallback on $BOLD${ID}$NO_COLOR"
    sshpass -p 'oZPS0POrRieRtu' ssh -tt toor4nsn@192.168.255.$IP << EOF
    uboot_env set uboot_recovery=1
    ddal -s ddal_boot_set_reset_loop_count 0
    rm -rfv /ffs/run/config/fallbackCause.txt
    reboot
    exit
EOF
echo -e "$PRINT_OK defallback on $BOLD${ID}$NO_COLOR is done, DZIENKI HEJ"
    else echo -e "$PRINT_INFO Performing defallback on $BOLD${ID}$NO_COLOR"
    sshpass -p 'oZPS0POrRieRtu' ssh -qtt toor4nsn@192.168.255.$IP << EOF
    uboot_env set netboot=netboot_first
    ddal -s ddal_boot_set_reset_loop_count 0
    rm -rfv /ffs/run/config/fallbackCause.txt
    ddal -s ddal_reboot_sm_site_graceful DDAL_REBOOT_SM_SHELF_SIDE_OWN
    exit
EOF
echo -e "$PRINT_OK defallback on $BOLD${ID}$NO_COLOR is done, DZIENKI HEJ"
    fi
else echo -e "$PRINT_ERROR something goes wrong,  please try again"
fi

