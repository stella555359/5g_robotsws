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
mkdir -p /home/ute/tti_trace
tti_tools=/home/ute/tti_trace
#WFT server: https://lterel.es-si-s3-z2.eecloud.nsn-net.net/build/SBTS00/SBTS00_ENB_9999_211122_000003_TtiTracer.zip
#UTE Cloud server: http://files.ute.nsn-rdnet.net/builds/enb/base/SBTS00_ENB_9999_211122_000003/SBTS00_ENB_9999_211122_000003_TtiTracer.zip
#cd /home/ute/output/builds; wget http://files.ute.nsn-rdnet.net/builds/enb/base/${gnb_v}/${dec_file}
#cd /home/ute/output/builds; wget http://files.ute.nsn-rdnet.net/builds/enb/base/${gnb_v}/${dissectors_file}
#server_link=https://lterel.es-si-s3-z2.eecloud.nsn-net.net/build
server_link=https://artifactory-espoo2.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-local/build
cd ${tti_tools}; wget ${server_link}/${gnbp1}/${gnb_v}/${dec_file}
cd ${tti_tools}; wget ${server_link}/${gnbp1}/${gnb_v}/${dissectors_file}
sudo dpkg -i ${tti_tools}/${dec_file}
sudo rm -rf /opt/tti_dissectors && sudo mkdir -p /opt/tti_dissectors && sudo chown ute /opt/tti_dissectors
sudo unzip -q -o -d /opt/tti_dissectors ${tti_tools}/${dissectors_file}
sudo chmod +x /opt/tti-dec/tti-dec-bin/bin/eventDecoder
echo "Congratulations:Now you can parse ttitrace manually now!"
echo "Usage example:"
echo "source /opt/tti-dec/venv/bin/activate"
echo "python /opt/tti-dec/tti-dec-bin/TtiTraceDecoder.py ~/10.57.152.242_20210918T011915.965048.pcap excelCsv --optim"