#!/bin/sh

if [[ $1 != "start" && $1 != "stop" && $1 != "collect" && $1 != "--help" && $1 != "-h" ]]; then
	echo
	echo "+++ Error: Unknown value $1" >&2
	echo
	echo "Usage: $0 {start/stop/collect...}" >&2
	echo "Example: $0 start"
	echo
	exit 1
fi

kill_process() {
	PID=`ps -eaf | grep ${1} | grep -v grep | awk '{print $2}'`
	if [[ "" !=  "$PID" ]]; then
		echo "killing $PID"
		kill -9 $PID
	fi
}

find_tti_trace_hosts ()
{
	tti_trace_hosts=
	if [ -f /ffs/run/TargetBD*ASOD*.xml ]
	then
		xeon_host_list="0:0 0:1"
	else
		xeon_host_list="0:0 0:1 1:0 1:1 2:0 2:1 3:0 3:1"
	fi
	for xeon_host in $xeon_host_list
	do
		result=`bsh -t 1 $xeon_host 'ps -ef | grep "L2CounterClient " | grep -v grep' 2>/dev/null`
		if [ "$result" ]
		then
			tti_trace_hosts="$tti_trace_hosts $xeon_host"
		fi
	done
	echo $tti_trace_hosts
}

filename="L2TtiTrace_EventsSnapshot.bin"
decdir="/tmp/tti_traces"

if [ "$1" == "start" ];
then
	echo "finding TTI Trace Hosts ..."
	tti_trace_hosts="$( find_tti_trace_hosts )"
	echo tti_trace_hosts are $tti_trace_hosts
	echo $tti_trace_hosts > tti_trace_hosts.txt
	for tti_trace_host in $tti_trace_hosts
	do
		bsh $tti_trace_host << eof
			cd /opt/tools/ttiTrace;
			rm -f /var/eventsTrace/*
			./eventsCollect.sh > /dev/null 2>&1 &
eof
		echo -e "\nTTI traces started in host $tti_trace_host !!!\n"
	done 2>/dev/null

elif [ "$1" == "stop" ];
then
	for tti_trace_host in `cat tti_trace_hosts.txt`
	do
		bsh $tti_trace_host << eof
			$(typeset -f); kill_process eventsCollect.sh
eof
		echo -e "\nTTI traces stopped in host $tti_trace_host !!!\n"
	done 2>/dev/null

else
	rm -f ${decdir}/* ${decdir}*.tar
	for tti_trace_host in `cat tti_trace_hosts.txt`
	do
	{
		bsh $tti_trace_host << eof
			mkdir -p $decdir
			rm -f ${decdir}/* ${decdir}*.tar
			cd /var/eventsTrace
			for file in \`ls\`
			do
				echo file is \$file
				fileIdx=\$(echo \${file} | sed -r 's/L2TtiTrace_EventsSnapshot.bin.([0-9]*).tar.gz/\1/')
				echo \${fileIdx};
				tar -zxvf ${filename}.\${fileIdx}.tar.gz
				/opt/tools/ttiTrace/eventDecoder /var/eventsTrace/${filename}.\${fileIdx} ${decdir}/${filename}.\${fileIdx}
				gzip ${decdir}/${filename}.\${fileIdx}*
				rm /var/eventsTrace/${filename}.\${fileIdx}
			done
			tar -C $decdir -cvf ${decdir}_\${HOSTNAME}.tar .
eof
		if [ "$tti_trace_host" != "0:0" ]
		then
			tti_trace_file=`bsh $tti_trace_host "ls ${decdir}*.tar" 2>/dev/null`
			bget $tti_trace_host $tti_trace_file /tmp/. 2>/dev/null
			bsh $tti_trace_host "rm -f $tti_trace_file" 2>/dev/null
		fi
		echo -e "\nTTI traces collected in host $tti_trace_host !!!\n"
	} &
	done 2>/dev/null
	wait
fi
