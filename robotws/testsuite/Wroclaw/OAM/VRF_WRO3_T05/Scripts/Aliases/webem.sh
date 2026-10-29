#!/bin/bash

# Sprawdzenie czy bazówka posiada 2 noody

yaml_file="/home/ute/MN/UTE/robotws/testsuite/Wroclaw/OAM/RAN_PZ_WRO3_SG05/CBRS/Resources/Configuration/testlines.yaml"
hostname=$(hostname | awk -F'-' '{print $3}')
in_context=false
is_node2=false

while IFS= read -r line; do
  # Szukanie testlini
  if [[ $line =~ "$hostname" ]]; then
    in_context=true
  fi

  # Szukanie 2 nooda
  if $in_context && [[ $line =~ "node2" ]]; then
    is_node2=true
  fi

  #Szukanie m-plane & vm ip
  if $in_context && $is_node2 && [[ $line =~ "mplane_ip_addr" ]]; then
    mplane_ip=$(echo "$line" | awk -F ": " '{print $2}')
  fi

  if $in_context && $is_node2 && [[ $line =~ "vm_ip" ]]; then
    vm_ip=$(echo "$line" | awk -F ": " '{print $2}')
  fi

  if [[ -z "$(echo "$line" | grep -o '[^[:space:]]')" ]]; then
    in_context=false
  fi
done < "$yaml_file"

if $is_node2; then
  (google-chrome https://artifactory-espoo2.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-local/build/ --ignore-certificate-errors &> /dev/null &)
  sleep 0.2
  (google-chrome http://files.ute.nsn-rdnet.net/builds/enb/base/ --ignore-certificate-errors &> /dev/null &)
  sleep 0.2
  (google-chrome https://${mplane_ip//\'/} --ignore-certificate-errors &> /dev/null &)
  sleep 0.2
  (google-chrome https://192.168.255.1 --ignore-certificate-errors &> /dev/null &)
else
  (google-chrome https://artifactory-espoo2.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-local/build/ --ignore-certificate-errors &> /dev/null &)
  sleep 0.2
  (google-chrome http://files.ute.nsn-rdnet.net/builds/enb/base/ --ignore-certificate-errors &> /dev/null &)
  sleep 0.2
  (google-chrome https://192.168.255.1 --ignore-certificate-errors &> /dev/null &)
fi

