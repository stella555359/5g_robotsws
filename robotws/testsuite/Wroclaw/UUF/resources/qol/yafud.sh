#!/bin/bash

# Variables
SOFT=$1
IP=${2:-129}

#Set tags
RED='\e[31m'
BOLD='\e[1m'
NO_COLOR='\e[0m'
PRINT_INFO="${BOLD}[INFO]${NO_COLOR} "
PRINT_ERROR="${RED}${BOLD}[ERROR]${NO_COLOR} "

#Check SMOD
if sshpass -p oZPS0POrRieRtu ssh -q toor4nsn@192.168.255.$IP [ -d /var/dt/module-identity/ ]; then
	ID=$(sshpass -p oZPS0POrRieRtu ssh -q toor4nsn@192.168.255.$IP cat /var/dt/module-identity/unit-id | tr -d '\0')
	echo $ID
else
	ID=$(sshpass -p oZPS0POrRieRtu ssh -q toor4nsn@192.168.255.$IP cat /proc/device-tree/module-identity/unit-id | tr -d '\0')
	echo $ID
fi

#Check if the build is correct
if [ ! $1 ]; then echo -e "$PRINT_ERROR Please provide the SW Build";
 exit 1
fi

echo "IP: 192.168.255.${IP}"

if [ ${ID} ]; then
    if [[ ${ID} = FSMF || ${ID} = FSIH ]]; then
      echo -e "$PRINT_INFO Performing yafudfsmf on $BOLD${ID}$NO_COLOR using soft ${SOFT}"
      deactivate; source /home/ute/test_repo/bin/activate; /home/ute/MN/UTE/robotws/testsuite/Wroclaw/UUF/resources/qol/yaft3.sh ${SOFT} ${IP}
      exit
    else
      echo -e "$PRINT_INFO Performing yafud on $BOLD${ID}$NO_COLOR using soft ${SOFT}"
      deactivate; source /home/ute/test_repo/bin/activate; /home/ute/MN/UTE/robotws/testsuite/Wroclaw/UUF/resources/qol/yaft.sh  ${SOFT} ${IP}
      exit
    fi
else echo -e "$PRINT_ERROR Seems that HW is not online. Please try again when BTS is running. "
fi