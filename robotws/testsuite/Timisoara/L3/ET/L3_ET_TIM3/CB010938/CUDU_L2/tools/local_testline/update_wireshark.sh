#! set -eEuo pipefail
version=3.4.8.lte.2110.01
wget https://bts.inside.nsn.com/labstorage/Analyzer/Wireshark_LTE_NSN/deb10/libwireshark-data_${version}+buster_all.deb
wget https://bts.inside.nsn.com/labstorage/Analyzer/Wireshark_LTE_NSN/deb10/libwireshark14_${version}+buster_amd64.deb
wget https://bts.inside.nsn.com/labstorage/Analyzer/Wireshark_LTE_NSN/deb10/libwiretap11_${version}+buster_amd64.deb
wget https://bts.inside.nsn.com/labstorage/Analyzer/Wireshark_LTE_NSN/deb10/libwsutil12_${version}+buster_amd64.deb
wget https://bts.inside.nsn.com/labstorage/Analyzer/Wireshark_LTE_NSN/deb10/wireshark-common_${version}+buster_amd64.deb
wget https://bts.inside.nsn.com/labstorage/Analyzer/Wireshark_LTE_NSN/deb10/wireshark_${version}+buster_amd64.deb
wget https://bts.inside.nsn.com/labstorage/Analyzer/Wireshark_LTE_NSN/deb10/wireshark-qt_${version}+buster_amd64.deb
wget https://bts.inside.nsn.com/labstorage/Analyzer/Wireshark_LTE_NSN/deb10/tshark_${version}+buster_amd64.deb
echo "sudo dpkg -i libwireshark-data_${version}+buster_all.deb libwsutil12_.deb libwiretap11_${version}+buster_amd64.deb libwireshark14_${version}+buster_amd64.deb wireshark-common_${version}+buster_amd64.deb"
echo "sudo dpkg -i wireshark_${version}+buster_amd64.deb wireshark-qt_${version}+buster_amd64.deb tshark_${version}+buster_amd64.deb"

