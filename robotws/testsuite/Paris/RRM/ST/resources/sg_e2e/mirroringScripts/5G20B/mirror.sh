#!/bin/bash
if [ ! -n "$1" ]; then
    cat /var/run/cpss/ports/mirror_info
    echo " 6(loner) -> 11(master bip)"
    exit
fi

if [ ! -n "$1" ]; then
    echo "you need to input a src port number!"
    exit
fi
if [ ! -n "$2" ]; then
    echo "you need to input a dst port number!"
    exit
fi

src_port=$1
dst_port=$2

if [[ $2 =~ "0" ]]
then
    echo both > /var/run/cpss/ports/${src_port}/disable_mirroring
    cat /var/run/cpss/ports/mirror_info
    exit
fi

luaCLI -c "cpss-api call cpssDxChMirrRxAnalyzerDpTcSet devNum 0 analyzerDp CPSS_DP_GREEN_E analyzerTc 7"
luaCLI -c "cpss-api call cpssDxChMirrTxAnalyzerDpTcSet devNum 0 analyzerDp CPSS_DP_GREEN_E analyzerTc 7"
luaCLI -c "cpss-api call cpssDxChMirrorToAnalyzerForwardingModeSet devNum 0 mode CPSS_DXCH_MIRROR_TO_ANALYZER_FORWARDING_SOURCE_BASED_OVERRIDE_E"

echo both > /var/run/cpss/ports/${src_port}/disable_mirroring
echo ${dst_port} both > /var/run/cpss/ports/${src_port}/mirroring_port
cat /var/run/cpss/ports/mirror_info

#capture
#tcpdump -i pepbp1 -w /bip.pcap -s0
#tcpdump -i pepbp1 udp -nn
