#!/bin/bash
package_dir=/home/ute/package/
echo before delete: `ls ${package_dir}`
rm -rf ${package_dir}
mkdir ${package_dir}
echo after delete: `ls ${package_dir}`
cmd="aria2c -j 16 -x 16 -s 16 https://lterel.es-si-s3-z2.eecloud.nsn-net.net/build/$(echo "$1"|awk -F '_' '{print $1}')/${1}_release_BTSSM_downloadable_A54.zip -d ${package_dir}"
echo cmd=${cmd}
echo cmd=mybot /home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_L2_SW_CN_1/CUDU_L2/tools/update_gnb.robot

# aria2c -j 16 -x 16 -s 16 https://lterel.es-si-s3-z2.eecloud.nsn-net.net/build/SBTS00/SBTS00_ENB_9999_220908_000001_release_BTSSM_downloadable_A54.zip

# Note:
# first, make sure aria2c installed.
# sudo apt update
# sudo apt install aria2

# aria2 apt download resource
# sudo cat /etc/apt/sources.list.d/debian_repo.list
# deb [ arch=amd64 ] http://files.ute.nsn-rdnet.net/osrepo/debian10/public/buster buster ute

# if you can't connect to eecloud server, modify DNS server file.
# error hint:
#[AbstractCommand.cc:792] errorCode=19 CUID#7 - Name resolution for lterel.es-si-s3-z2.eecloud.nsn-net.net failed:Could not contact DNS servers

# nameserver 10.56.126.31
# nameserver 10.42.7.104
# nameserver 10.171.0.3
# search ute.nsn-rdnet.net
# sudo sed -i '$ a nameserver 10.56.126.31' /etc/resolv.conf