#!/bin/bash
#sort-of-automated script to unlock BTS with  users.json forbidding access
IPEK=${1:-1}

tput setaf 1
printf "%s\n" "***** Waiting for 192.168.255.$IPEK to start the duel *****"
echo "HINT: toggle the power supply on SMOD"
tput sgr0
while ! timeout 0.2 ping -c 1 -n 192.168.255.$IPEK &> /dev/null
do
    printf "%c" "."
done
tput setaf 1
printf "\n%s\n"  "***** WILD USERS.JSON APPEARED *****"
echo "***** SHERIFF USED TRUSTY OLD REVOLVER *****"
tput sgr0
sshpass -p 'oZPS0POrRieRtu' ssh -tt toor4nsn@192.168.255.$IPEK << EOF
rm -rfv /ffs/run/config/users.json
system-module-reboot
exit
EOF
tput setaf 1
echo "***** IT'S SUPER EFFECTIVE! *****"
tput sgr0