#!/bin/bash

ADDRESS=`hostname -i`
DOWNLOADPATH=https://artifactory-espoo2.int.net.nokia.com/artifactory/dcap-lite-binaries-local/dcap-basic/releases/FB2224.1/dcap_basic_installer.FB2224.1.sh

Help() {
	echo "install_dcap.sh"
	echo "Usage:"
	echo "./install_dcap.sh"
	echo "install dcap basic $DOWNLOADPATH"
	echo "./install_dcap.sh -d[url to dcap basic installer script]"
	exit
};

while getopts d:h flag
do
    case "${flag}" in
        d) DOWNLOADPATH=${OPTARG};;
	h) Help
    esac
done

COMMAND=`echo $DOWNLOADPATH | rev | cut -d \/ -f 1 | rev`

#echo $ADDRESS
#echo $DOWNLOADPATH 
#echo $COMMAND

sudo rm -rf /var/lib/docker
sudo ln -s /home/docker/ /var/lib/docker
ls -l /var/lib/docker

cd /home/ute/logs/
wget $DOWNLOADPATH
chmod +x /home/ute/logs/$COMMAND
sudo UTE_CLOUD=1 bash /home/ute/logs/$COMMAND $ADDRESS

