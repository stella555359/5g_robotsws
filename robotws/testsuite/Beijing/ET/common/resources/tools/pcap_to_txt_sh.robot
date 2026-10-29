#!/usr/bin/sh
root=/home/ute/MN/UTE/robotws
current_dir=`pwd`
robot_file=`readlink -f $0`
if [ $# -lt 2 ] ; then
    echo "\nInvalid parameter number!"
    echo "\nUsage example(x2ap):"
    echo "$0  x2ap  /tmp/bip.pcap"
    echo "\nUsage example(bip):"
    echo "$0  dldata_csirssendreq  /tmp/bip.pcap"
    exit 1
fi
filter=$1
while [ $# != 1 ];do
echo "\nconverting for" $2
    cd $current_dir
    pcap_file=`readlink -f $2`
    cd ${root} && robot --pythonpath ${root} -v pcap_file:$pcap_file -v pcap_filter:$filter $robot_file;
shift
done
exit

*** Settings ***

Resource          ${EXECDIR}/testsuite/Beijing/ET/common/resources/pcap_to_txt.robot


*** Test Cases ***

PCAP PARSER TEST

    Connect To UTE
    Log To Console       Connected to UTE done

    Log To Console       Converting Pcap files

    ${pcap_txt_file}     Convert Pcap To Text UTE    source=${pcap_file}   filter=${pcap_filter}

