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

filename="L2TtiTrace_EventsSnapshot.bin"
decdir="/tmp/tti_traces"

if [ "$1" == "start" ];
then
	bsh 1:1 << eof
		cd /opt/tools/ttiTrace;
		rm -f /var/eventsTrace/*
		./eventsCollect.sh > /dev/null 2>&1 &
eof
	echo -e "\nTTI traces started in host 1:1 !!!\n"

elif [ "$1" == "stop" ];
then
	bsh 1:1 << eof
		$(typeset -f); kill_process eventsCollect.sh
eof
		echo -e "\nTTI traces stopped in host 1:1 !!!\n"

else
	rm -f ${decdir}/* ${decdir}*.tar
	bsh 1:1 << eof
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
		tti_trace_file=`bsh 1:1 "ls ${decdir}*.tar" 2>/dev/null`
		bget 1:1 $tti_trace_file /tmp/. 2>/dev/null
		bsh 1:1 "rm -f $tti_trace_file" 2>/dev/null
		echo -e "\nTTI traces collected in host 1:1 !!!\n"

	wait
fi
