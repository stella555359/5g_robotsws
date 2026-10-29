#!/bin/bash
sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.129 << EOF
mkdir -p /ffs/run/config/toor4nsn/sm6-snowfish_bk
cp /ffs/run/swpool/CPLANE-5G/sm6-snowfish/cp-ue_*.txz /ffs/run/config/toor4nsn/sm6-snowfish_bk

####################  InactivityTimer ############################################



function ReplData {

sed -i "s/rdSupervisionTimerDurationInSeconds=.*/rdSupervisionTimerDurationInSeconds=$1/" /tmp/tmp/opt/nokia/SS_CPLANE/etc/cp_ue.enb_conf.ini

echo -e "cp_ue.enb_conf.ini edited"
}

rm -rf /tmp/tmp
mkdir /tmp/tmp
echo -e "/tmp/tmp folder was created."
cp /ffs/run/swpool/CPLANE-5G/sm6-snowfish/cp-ue_*.txz /tmp/tmp
echo -e "\nUnpacking files in progress."
tar xvf /tmp/tmp/cp-ue_*.txz -C /tmp/tmp/
rm /tmp/tmp/cp-ue_*.txz
echo -e "Changing param rdSupervisionTimerDurationInSeconds"
ReplData
echo $1
echo -e "\nPacking files in progress.\n"
cd /tmp/tmp
tar cfJ cp-ue_*.txz opt/ usr/
cp /tmp/tmp/cp-ue_*.txz /ffs/run/swpool/CPLANE-5G/sm6-snowfish/cp-ue_*.txz
crasign /ffs/run/swpool/CPLANE-5G/sm6-snowfish/cp-ue_*.txz
echo -e "File signed."

rm -f /ffs/run/HashContainer*
echo "Hash Containers were removed if existed :) !"


EOF
