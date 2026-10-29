#!/bin/bash
#A revolver to shoot the locks on ssh via swconfig.txt flags
echo not yet Snake
sshpass -p 'oZPS0POrRieRtu' ssh -tt toor4nsn@192.168.255.1 << EOF
echo -e "0x1A0020=1 # enable ssh even with TRS \n0x30000F=1 # enable ssh even with TRS \n0x19012=1 ### Enable SSH connection automatically in every startup ### \n0x480008=1 #SSH \n0x45005a=1 # enable developer user login" >>  /ffs/run/swconfig.txt
ddal -s ddal_reboot_sm_site_graceful DDAL_REBOOT_SM_SHELF_SIDE_OWN
exit
EOF
echo ur pretty good