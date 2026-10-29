#!/bin/bash
IPEK=${2:-1}

echo "    **** Oneshot yaft script - v.0.01b ****"
echo "YAFT:loading yaft files from repository"
svn checkout https://svne1.access.nsn.com/isource/svnroot/BTS_T_YAFT/trunk /home/ute/YAFT --username ca_uuf --password ca_uuf_pass || { echo >&2 "YAFT SCRIPT ERROR: failed to clone yaft repository"; exit 1; } 
#. /home/ute/MN/UTE/robotws/testsuite/Wroclaw/UUF/resources/qol/settings.ini
#WA sometimes contents of cache is not visible - trying to refresh contents with ls
echo "YAFT:refreshing burak contents"
cd /home/ute/burak/$1/
ls -l /home/ute/burak/$1/
echo "YAFT:switching to Yaft dir"
cd /home/ute/YAFT || { echo echo >&2 "YAFT SCRIPT ERROR: unable to find path /home/ute/YAFT" ; exit 1; }
echo "YAFT:Downloading SW package...(might take a while)"
rsync -vu --progress /home/ute/burak/$1/*.zip /home/ute/YAFT || { echo echo >&2 "YAFT SCRIPT ERROR: unable to find SW package on burak - does not exist or burak not mounted" ; exit 1; }
sudo systemctl stop dnsmasq && sudo systemctl status dnsmasq | grep Active:
echo "oZPS0POrRieRtu" | python yaft.py -i 192.168.255.$IPEK -z /home/ute/YAFT/*$1*.zip --ask_for_password --clean_to_default --ignore_FSPs -L -K

