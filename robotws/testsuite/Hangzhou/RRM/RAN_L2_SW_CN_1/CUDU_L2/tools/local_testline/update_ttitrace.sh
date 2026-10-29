#! set -eEuo pipefail
if [ -n "$1" ];then
gnb_v=$1
else
gnb_v=$(sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.129 ls /ffs/run/TargetBD_*.xml|awk -F 'TargetBD_|.xml' '{print $2}' )
fi
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
#WFT server: https://lterel.es-si-s3-z2.eecloud.nsn-net.net/build/SBTS00/SBTS00_ENB_9999_211122_000003_TtiTracer.zip
#UTE Cloud server: http://files.ute.nsn-rdnet.net/builds/enb/base/SBTS00_ENB_9999_211122_000003/SBTS00_ENB_9999_211122_000003_TtiTracer.zip
#cd /home/ute/output/builds; wget http://files.ute.nsn-rdnet.net/builds/enb/base/${gnb_v}/${dec_file}
#cd /home/ute/output/builds; wget http://files.ute.nsn-rdnet.net/builds/enb/base/${gnb_v}/${dissectors_file}
# for UTE Cloud
server_link=https://artifactory-espoo2.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-local/build
cd /home/ute/output/builds; wget ${server_link}/${gnbp1}/${gnb_v}/${dec_file}
cd /home/ute/output/builds; wget ${server_link}/${gnbp1}/${gnb_v}/${dissectors_file}
# # for Local Testline
# server_link=http://files.ute.nsn-rdnet.net/builds/enb/base
# cd /home/ute/output/builds; wget ${server_link}/${gnb_v}/${dec_file}
# cd /home/ute/output/builds; wget ${server_link}/${gnb_v}/${dissectors_file}
sudo dpkg -i /home/ute/output/builds/${dec_file}
sudo rm -rf /opt/tti_dissectors && sudo mkdir -p /opt/tti_dissectors && sudo chown ute /opt/tti_dissectors
unzip -q -o -d /opt/tti_dissectors /home/ute/output/builds/${dissectors_file}
chmod +x /opt/tti-dec/tti-dec-bin/bin/eventDecoder
echo "Congratulations:Now you can parse ttitrace manually now!"
echo "Usage example:"
echo "source /opt/tti-dec/venv/bin/activate"
echo "python /opt/tti-dec/tti-dec-bin/TtiTraceDecoder.py ~/tcpdump_ttitrace.pcap excelCsv --optim"