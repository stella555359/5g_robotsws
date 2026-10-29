#!/bin/bash
#
# Author: Abderrahmane NEZROUK
# email: abderrahmane.nezrouk@nokia.com

##################################################################################
# Helpfull script to avoid pcap tcpdump files to be overwrited, once the generated
# number files is reached the tcpdump is stoped.
# Arguments:
#        $1: card interface
#        $2: timeout to wait before to kill the process
##################################################################################

IsFileExist(){
    # 0 = true
    # 1 = false
    [ -e $1 ] && echo 0 || echo 1
}

readOptionsFromConfigFile() {
    source $directory/gnbMirroringConfig.sh
    if [ $? -eq 0 ]; then
        echo -e "\n${YELLOW}Read options from gnbMirroringConfig.sh${NC}"
    else
        echo -e "\n${RED}Config file (gnbMirroringConfig.sh) not found${NC}"
        exit
    fi
}

interface=$1
timeout=$(($2))
let "second=0"
directory="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
readOptionsFromConfigFile
let "NUMBER_OF_FILES-=1"
if [[ "$NUMBER_OF_FILES" -eq 0 ]]; then
    exit
fi
file="/tmp/tcpdumpL2L1_filtering_$FILTERING.pcap$NUMBER_OF_FILES"
echo NUMBER_OF_FILES=$NUMBER_OF_FILES
echo $file
echo interface=$interface

while [ $timeout -gt $second ]; do
    result=$(IsFileExist $file)
    if [[ "$result" -eq 0 ]]; then
        break
    fi
    sleep 1
    let "second+=1"
done
tcpdump_process=$(ps -ef | grep -E '^[tcpdump|root]' | grep 'tcpdump -i '$interface | awk '{print $2}')
kill -9 ${tcpdump_process[@]}
