#! set -eEuo pipefail
version=4.0.8.lte.2310.02
url=https://artifactory-espoo2.int.net.nokia.com/artifactory/wireshark-lte-5g-deb-local/wireshark/wireshark-stable/buster/
wget ${url}/libwireshark-data_${version}+buster_all.deb
wget ${url}/libwireshark16_${version}+buster_amd64.deb
wget ${url}/libwiretap13_${version}+buster_amd64.deb
wget ${url}/libwsutil14_${version}+buster_amd64.deb
wget ${url}/wireshark-common_${version}+buster_amd64.deb
wget ${url}/wireshark-doc_${version}+buster_all.deb
wget ${url}/wireshark-qt_${version}+buster_amd64.deb
wget ${url}/tshark_${version}+buster_amd64.deb
wget ${url}/wireshark_${version}+buster_amd64.deb
echo "======sudo dpkg -i libwiretap13_${version}+buster_amd64.deb"
sudo dpkg -i libwiretap13_${version}+buster_amd64.deb
echo "======sudo dpkg -i libwsutil14_${version}+buster_amd64.deb"
sudo dpkg -i libwsutil14_${version}+buster_amd64.deb
echo "======sudo dpkg -i libwireshark16_${version}+buster_amd64.deb"
sudo dpkg -i libwireshark16_${version}+buster_amd64.deb
echo "======sudo dpkg -i libwireshark-data_${version}+buster_all.deb"
sudo dpkg -i libwireshark-data_${version}+buster_all.deb
echo "======sudo dpkg -i wireshark-common_${version}+buster_amd64.deb"
sudo dpkg -i wireshark-common_${version}+buster_amd64.deb
echo "======sudo dpkg -i wireshark-doc_${version}+buster_all.deb"
sudo dpkg -i wireshark-doc_${version}+buster_all.deb
echo "======sudo dpkg -i wireshark-qt_${version}+buster_amd64.deb"
sudo dpkg -i wireshark-qt_${version}+buster_amd64.deb
echo "======sudo dpkg -i wireshark_${version}+buster_amd64.deb"
sudo dpkg -i wireshark_${version}+buster_amd64.deb
echo "======sudo dpkg -i tshark_${version}+buster_amd64.deb"
sudo dpkg -i tshark_${version}+buster_amd64.deb
