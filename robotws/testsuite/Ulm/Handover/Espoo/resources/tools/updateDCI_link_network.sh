#!/bin/bash
# note!
# CLOUD_5G_I_BL_AP_KL_SANSA_FS_CPRI_CMWV_FDD -> export DCI_SYSCOM_PORT="sei13"

Help () {
	echo "updateDCI_link_network.sh"
	echo "Usage:"
	echo "updateDCI_link_network.sh -d [download path] -f [filename] -u -s -v -1 -2"
        echo "Download/Upload SW to IPHY run:"
        echo "updateDCI_link_network.sh -d https://hzisoj70.china.nsn-net.net/artifactory/mnp5g-airphone-ci-gen-local/Airphone/4.0.20785/ -f DCI_link_network_config-4.0.20785.tar.gz "
        echo "Download/Upload SW to IPHY fs2:"
        echo "updateDCI_link_network.sh -2 -d https://hzisoj70.china.nsn-net.net/artifactory/mnp5g-airphone-ci-gen-local/Airphone/4.0.20785/ -f DCI_link_network_config-4.0.20785.tar.gz "
	echo "Update SW to IPHY fs2:"
        echo "updateDCI_link_network.sh -2 -u"
        echo "Get status of Service:"        
        echo "updateDCI_link_network.sh -s"
	echo "Get Installed Version:"
	echo "updateDCI_link_network.sh -v"
	exit
};

DOWNLOADPATH="null"
FILENAME="null"
GETVERSION=0
GETSTATUS=0
DOWNLOAD=1
UPDATESW=0
ACTIVEFS=run

while getopts d:f:hsvu12 flag
do
    case "${flag}" in
        d) DOWNLOADPATH=${OPTARG};;
        f) FILENAME=${OPTARG};;
        u) UPDATESW=1;;
        v) GETVERSION=1;;
	s) GETSTATUS=1;;
        1) ACTIVEFS=fs1;;
        2) ACTIVEFS=fs2;;
	h) Help
    esac
done

if [ $GETVERSION -eq 1 ]; then
  ssh toor4nsn@192.168.200.1 "ls DCI">loki.log 2>&1
  VERSION=$(/bin/grep DCI_link_network_config loki.log)
  echo "Version: $VERSION"
  DOWNLOAD=0
fi

if [ $GETSTATUS -eq 1 ]; then
  ssh toor4nsn@192.168.200.1 "systemctl status airphone-dci-link-network-config.service">loki.log 2>&1
  STATUS=$(/bin/grep -e"Active: active" loki.log)
  echo "Status: $STATUS"
  DOWNLOAD=0
fi

if [ $UPDATESW -eq 1 ]; then
  echo "Update SW and Reboot"
  ssh toor4nsn@192.168.200.1 "cd /ffs/$ACTIVEFS/config/toor4nsn/DCI/; ./deploy.sh --yes" > /dev/null 2>&1
  ssh toor4nsn@192.168.200.1 "cd /ffs/$ACTIVEFS/config/toor4nsn/DCI/; reboot" > /dev/null 2>&1
  DOWNLOAD=0
fi

if [ $DOWNLOAD -eq 1 ]; then
  if [ $DOWNLOADPATH == "null" ]; then
     echo "Missing download path"
     Help
  fi

  if [ $FILENAME == "null" ]; then
     echo "Missing file name"
     Help 
  fi

  echo "Downloading File $DOWNLOADPATH/$FILENAME" 
  wget $DOWNLOADPATH/$FILENAME > /dev/null 2>&1
  
  echo "Uploading $FILENAME to IPHY"
  ssh toor4nsn@192.168.200.1 "mkdir -p /ffs/$ACTIVEFS/config/toor4nsn/DCI/"
  scp $FILENAME toor4nsn@192.168.200.1:/ffs/$ACTIVEFS/config/toor4nsn/DCI/ > /dev/null 2>&1
  echo "Uncompressing File $FILENAME"
  ssh toor4nsn@192.168.200.1 "cd /ffs/$ACTIVEFS/config/toor4nsn/DCI/; tar xvzf $FILENAME" > /dev/null 2>&1
  ssh toor4nsn@192.168.200.1 "cd /ffs/$ACTIVEFS/config/toor4nsn/DCI/; chmod +x -R *" > /dev/null 2>&1
  echo ""
  echo "!!! Edit IPHY /ffs/$ACTIVEFS/config/toor4nsn/DCI/deploy.cfg Before Update !!!" 
fi

