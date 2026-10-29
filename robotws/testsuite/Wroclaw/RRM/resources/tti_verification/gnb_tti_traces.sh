#!/bin/sh

if [[ $1 != "start" && $1 != "stop" && $1 != "--help" && $1 != "-h" ]]; then
    echo "+++ Error: Unknown value $1" >&2
    exit 1
fi

if [[ $1 == "-h" || $1 == "--help" ]]; then
    echo
    echo "Usage: $0 {start/stop...}" >&2
    echo "Example: $0 start"
    exit 1
fi

kill_process() {
    PID=`ps -eaf | grep ${1} | grep -v grep | awk '{print $2}'`
    if [[ "" !=  "$PID" ]]; then
        echo "killing $PID"
        kill -9 $PID
    fi
}

filename="L2TtiTrace_EventsSnapshot.bin"

if [ "$1" == "start" ];
then
    cd /opt/tools/ttiTrace
    ./eventsCollect.sh > /dev/null 2>&1 &
    echo -e '\nTTI traces started !!!\n'
else
    $(typeset -f); kill_process eventsCollect.sh
    mkdir -p /tmp/tti_traces/
    rm /tmp/tti_traces/*
    cd /var/eventsTrace
    for file in *; do
        fileIdx=$(echo ${file} | sed -r 's/L2TtiTrace_EventsSnapshot.bin.([0-9]*).(.)?tar.gz/\1/')
        echo ${fileIdx};
        tar -zxvf ${file}
        mv ${filename}.${fileIdx}. ${filename}.${fileIdx}
        /opt/tools/ttiTrace/eventDecoder /var/eventsTrace/${filename}.${fileIdx} /tmp/tti_traces/${filename}.${fileIdx}
    done
    rm /var/eventsTrace/*
    echo -e '\nTTI traces stopped !!!\n'
fi


