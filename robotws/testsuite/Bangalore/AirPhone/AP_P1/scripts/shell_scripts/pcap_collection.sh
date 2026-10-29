#!/bin/bash
if [ -f "$HOME/.ssh/toor4nsn/id_rsa" ] ; then
    PRIVATE_KEY="$HOME/.ssh/toor4nsn/id_rsa"
elif [ -f "$HOME/.ssh/id_rsa" ] ; then
    PRIVATE_KEY="$HOME/.ssh/id_rsa"
else
    echo "ERROR: Could not find ssh keys in $HOME/.ssh/ will generate new ones"
    ssh-keygen -t rsa -N "" -f "$HOME/.ssh/id_rsa"
    PRIVATE_KEY="$HOME/.ssh/id_rsa"
fi

ssh="ssh -q -o StrictHostkeyChecking=no -i $PRIVATE_KEY "
PCAP_PREFIX="attach_traffic"

startTcpDumpOngNB()
  {
    # Max 50 chunks of 900 MB each
    CHUNK_SIZE=900
    CHUNK_MAX_COUNT=50
    TL_USER="toor4nsn"
    BTS_FCT_IP_1="192.168.255.129"
    PCAP_PREFIX=$1

    TCPDUMP_OPTS="-vvv -C ${CHUNK_SIZE} -W ${CHUNK_MAX_COUNT} -z gzip -w "
    DATE_FORMAT='%Y-%m-%d_%H:%M:%S.pcap'
    $ssh $TL_USER@$BTS_FCT_IP_1 "bsh 0:0 tcpdump -i eths3  ${TCPDUMP_OPTS} /tmp/$(date +BTS_${PCAP_PREFIX}_L1L2_${DATE_FORMAT}.pcap)" &
    sleep 5
  }

echo "------------ Starting tcpdump on gNB ---------"
startTcpDumpOngNB "$@"
