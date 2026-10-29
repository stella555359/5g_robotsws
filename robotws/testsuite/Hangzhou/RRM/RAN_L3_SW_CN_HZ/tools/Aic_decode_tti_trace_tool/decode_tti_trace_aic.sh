#!/bin/bash

echo -e "\033[1;30;47m please input vDU version(format like as: vDUCNF22R4_0.300.7132): \033[0m"
read vDU_version
if [ -z "$vDU_version" ]
then
  echo -e "\033[1;31;47m please input valid vDU version \033[0m"
  exit
fi
echo -e "\033[1;30;47m please input tti_pcap file path(format like as: /home/ute/tti_pcap_file_path): \033[0m"
read tti_pcap_path
vDU_release=$(echo "${vDU_version}"|awk -F '_' '{print $1}')
echo $vDU_release
vDU_release_id=$(echo "${vDU_version}"|awk -F '_' '{print $2}')
echo $vDU_release_id

echo "download tti trace tool with matching vDU version $vDU_version..."
download_path="https://artifactory-espoo1.int.net.nokia.com/artifactory/mnp5g-central-public-local/System_Release/$vDU_release_id/vDUCNF_${vDU_release_id}_tti-dec.deb"
echo $download_path
sudo rm -rf /home/ute/$vDU_version
wget --no-check-certificate $download_path -P /home/ute/$vDU_version

chmod +x /home/ute/$vDU_version/vDUCNF_${vDU_release_id}_tti-dec.deb
echo -e "\033[1;30;47m Start to install numpy pandas lib resource... \033[0m"
pip install -U numpy pandas

echo -e "\033[1;30;47m Start to install tti decoding lib resource... \033[0m"
cd /home/ute/vDUCNF22R4_0.300.7132; sudo dpkg -i vDUCNF_${vDU_release_id}_tti-dec.deb
sudo rm /opt/tti-dec/tti-dec-bin/ttiTrace_*.csv

echo -e "\033[1;30;47m Start to decode tti trace to excelcsv...\033[0m"
cd /opt/tti-dec/tti-dec-bin; python TtiTraceDecoder.py $tti_pcap_path excelCsv
sleep 3
cp /opt/tti-dec/tti-dec-bin/ttiTrace_*.csv $tti_pcap_path

echo -e "\033[1;30;47m decode tti trace to excelcsv finish, please find in log path: $tti_pcap_path \033[0m"
