#!/usr/bin/sh
if [ $# -eq 1 ] ; then
gnb_v=$1
else
gnb_v=$(sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.129 ls /ffs/run/TargetBD_*.xml|awk -F 'TargetBD_|.xml' '{print $2}' )
echo "gnb version: ${gnb_v}"
gnbp1=$(echo "${gnb_v}"|awk -F '_' '{print $1}')
gnbp3=$(echo "${gnb_v}"|awk -F '_' '{print $3}')
gnbp4=$(echo "${gnb_v}"|awk -F '_' '{print $4}')
gnbp5=$(echo "${gnb_v}"|awk -F '_' '{print $5}')
if [ $gnbp3 = 9999 ];then
gnb_v="SBTS00_ENB_${gnbp3}_${gnbp4}_${gnbp5}"
gnbp1=SBTS00
fi
fi
echo "4:gnb_v=${gnb_v}"
cd /tmp
addr=`wget --user=lv1 --ask-password https://artifactory-hz1.int.net.nokia.com/artifactory/wslte5g_plugins-local/MCShark/ -O - | grep ${gnb_v} |sed -n '$p' | cut -d\" -f2`
addr1=`wget --user=lv1 --ask-password https://artifactory-hz1.int.net.nokia.com/artifactory/wslte5g_plugins-local/MCShark/${addr} -O - | grep bullseye.so\" | sed -n '1p' | cut -d\" -f2`
sudo wget --user=lv1 --ask-password https://artifactory-hz1.int.net.nokia.com/artifactory/wslte5g_plugins-local/MCShark/${addr}/${addr1}
sudo rm /usr/lib/x86_64-linux-gnu/wireshark/plugins/4.0/epan/mcshark*.so
sudo cp ${addr1} /usr/lib/x86_64-linux-gnu/wireshark/plugins/4.0/epan
