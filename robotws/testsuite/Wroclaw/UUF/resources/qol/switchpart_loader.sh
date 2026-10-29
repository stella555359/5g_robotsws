#!/bin/bash
# script to load and execute partition switcher on smod
IPEK=${1:-1}
echo "***** Switchpart LOADER script v.0.1 *****"
sshpass -p 'oZPS0POrRieRtu' scp /home/ute/MN/UTE/robotws/testsuite/Wroclaw/UUF/resources/qol/switchpart.sh  toor4nsn@192.168.255.$IPEK:/tmp
sshpass -p 'oZPS0POrRieRtu' ssh -tt toor4nsn@192.168.255.$IPEK << EOF
chmod +x /tmp/switchpart.sh
/tmp/switchpart.sh
rm /tmp/switchpart.sh
exit
EOF
