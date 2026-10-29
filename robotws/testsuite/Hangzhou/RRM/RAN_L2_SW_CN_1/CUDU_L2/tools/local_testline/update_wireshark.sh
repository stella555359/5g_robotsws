#! set -eEuo pipefail
version=4.2.6.lte.2409.01
wget https://artifactory-espoo2.int.net.nokia.com/artifactory/ute-debian-virtual/libwireshark-data_${version}+bookworm_all.deb
wget https://artifactory-espoo2.int.net.nokia.com/artifactory/ute-debian-virtual/libwireshark17_${version}+bookworm_amd64.deb
wget https://artifactory-espoo2.int.net.nokia.com/artifactory/ute-debian-virtual/libwiretap14_${version}+bookworm_amd64.deb
wget https://artifactory-espoo2.int.net.nokia.com/artifactory/ute-debian-virtual/libwsutil15_${version}+bookworm_amd64.deb
wget https://artifactory-espoo2.int.net.nokia.com/artifactory/ute-debian-virtual/wireshark-common_${version}+bookworm_amd64.deb
wget https://artifactory-espoo2.int.net.nokia.com/artifactory/ute-debian-virtual/wireshark_${version}+bookworm_amd64.deb
wget https://artifactory-espoo2.int.net.nokia.com/artifactory/ute-debian-virtual/wireshark-qt_${version}+bookworm_amd64.deb
wget https://artifactory-espoo2.int.net.nokia.com/artifactory/ute-debian-virtual/tshark_${version}+bookworm_amd64.deb
echo "sudo dpkg -i libwireshark-data_${version}+bookworm_all.deb libwsutil15_${version}+bookworm_amd64.deb libwiretap11_${version}+bookworm_amd64.deb libwireshark17_${version}+bookworm_amd64.deb wireshark-common_${version}+bookworm_amd64.deb"
sudo dpkg -i libwireshark-data_${version}+bookworm_all.deb libwsutil15_${version}+bookworm_amd64.deb libwiretap14_${version}+bookworm_amd64.deb libwireshark17_${version}+bookworm_amd64.deb wireshark-common_${version}+bookworm_amd64.deb
echo "sudo dpkg -i wireshark_${version}+bookworm_amd64.deb wireshark-qt_${version}+bookworm_amd64.deb tshark_${version}+bookworm_amd64.deb"
sudo dpkg -i tshark_${version}+bookworm_amd64.deb  wireshark_${version}+bookworm_amd64.deb wireshark-qt_${version}+bookworm_amd64.deb 

