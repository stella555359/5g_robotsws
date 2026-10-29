#!/bin/bash
#! set -eEuo pipefail
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
echo "4:gnb_v=${gnb_v}"
dec_file="${gnb_v}_tti-dec.deb"
echo "dec_file=${dec_file}"
dissectors_file="${gnb_v}_tti-dissectors.zip"
echo "dissectors_file=${dissectors_file}"
mkdir -p /home/ute/output/builds
server_link=https://lterel.es-si-s3-z2.eecloud.nsn-net.net/build
cd /home/ute/output/builds; wget ${server_link}/${gnbp1}/${dec_file}
cd /home/ute/output/builds; wget ${server_link}/${gnbp1}/${dissectors_file}
sudo dpkg -i /home/ute/output/builds/${dec_file}
sudo rm -rf /opt/tti_dissectors && sudo mkdir -p /opt/tti_dissectors && sudo chown ute /opt/tti_dissectors
unzip -q -o -d /opt/tti_dissectors /home/ute/output/builds/${dissectors_file}
chmod +x /opt/tti-dec/tti-dec-bin/bin/eventDecoder
