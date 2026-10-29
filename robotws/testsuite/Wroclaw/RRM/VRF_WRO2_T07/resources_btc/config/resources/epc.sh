#!/bin/bash
### BEGIN INIT INFO
# Provides:          hostname
# Required-Start:
# Required-Stop:
# Should-Start:      glibc
# Default-Start:     S
# Default-Stop:
# Short-Description: Set hostname based on /etc/hostname
# Description:       Read the machines hostname from /etc/hostname, and
#                    update the kernel value with this value.  If
#                    /etc/hostname is empty, the current kernel value
#                    for hostname is used.  If the kernel value is
#                    empty, the value 'localhost' is used.
### END INIT INFO

#PATH=/sbin:/bin
latestPath=/opt/iphy/WTS_CURRENT/
logPath=/opt/iphy/logs
logFilename=bts.log
portEgate=20000
portEpcEdaemon=22222
portUecEdaemon=10000
fsyslog_status () {
#fsyslogPidExists=$(ps aux | grep -E "fsyslog" | grep -v grep | awk '{print $2}' | wc -l)
echo $(ps aux | grep -E "fsyslog" | grep -v grep | awk '{print $2}' | wc -l)
}
egate_status () {
echo $(ps aux | grep -E "egate" | grep -v grep | awk '{print $2}' | wc -l)
}
edaemon_status () {
echo $(ps aux | grep -E "edaemon" | grep -v grep | awk '{print $2}' | wc -l)
}

do_status () {

if [[ $(fsyslog_status) -eq 0 ]] && [[ $(egate_status) -eq 0 ]] && [[ $(edaemon_status) -eq 0 ]]
then
	echo '------------------------------'
	echo '--------System is down--------'
	echo '------------------------------'
fi

if [[ $(fsyslog_status) -eq 1 ]] && [[ $(egate_status) -eq 1 ]] && [[ $(edaemon_status) -eq 2 ]]
then
	echo '------------------------------'
	echo '---System is up and running---'
	echo '------------------------------'
fi

if [[ $(fsyslog_status) -eq 0 ]] && [[ $(egate_status) -eq 1 ]] && [[ $(edaemon_status) -eq 2 ]]
then
	echo '------------------------------'
	echo '-------fsyslog is down--------'
	echo '------------------------------'
fi

if [[ $(fsyslog_status) -eq 1 ]] && [[ $(egate_status) -eq 0 ]] && [[ $(edaemon_status) -eq 2 ]]
then
	echo '------------------------------'
	echo '--------egate is down---------'
	echo '------------------------------'
fi

if [[ $(fsyslog_status) -eq 1 ]] && [[ $(egate_status) -eq 1 ]] && [[ $(edaemon_status) -eq 1 ]]
then
	echo '------------------------------'
	echo '--edaemon is partially down---'
	echo '------------------------------'
fi

if [[ $(fsyslog_status) -eq 1 ]] && [[ $(egate_status) -eq 1 ]] && [[ $(edaemon_status) -eq 0 ]]
then
	echo '------------------------------'
	echo '----edaemon is fully down-----'
	echo '------------------------------'
fi

if [[ $(fsyslog_status) -eq 0 ]] && [[ $(egate_status) -eq 0 ]] && [[ $(edaemon_status) -eq 2 ]]
then
	echo '------------------------------'
	echo '---fsyslog & egate are down---'
	echo '------------------------------'
fi

if [[ $(fsyslog_status) -eq 0 ]] && [[ $(egate_status) -eq 0 ]] && [[ $(edaemon_status) -eq 1 ]]
then
	echo '------------------------------'
	echo '---fsyslog & egate are down---'
	echo '--edaemon is partially down---'
	echo '------------------------------'
fi

if [[ $(fsyslog_status) -eq 1 ]] && [[ $(egate_status) -eq 0 ]] && [[ $(edaemon_status) -eq 1 ]]
then
	echo '------------------------------'
	echo '-------egate is down----------'
	echo '--edaemon is partially down---'
	echo '------------------------------'
fi

if [[ $(fsyslog_status) -eq 0 ]] && [[ $(egate_status) -eq 1 ]] && [[ $(edaemon_status) -eq 1 ]]
then
	echo '------------------------------'
	echo '-------fsyslog is down--------'
	echo '--edaemon is partially down---'
	echo '------------------------------'
fi

}

do_start () {
do_status
tablica=( "$@" )
export LUA_PATH=$latestPath"?.lua;"
for i in ${tablica[@]}
do
	echo 'aaaa'$i
done

if [[ $(fsyslog_status) -eq 0 ]]
then
	chmod u+x "$latestPath"'fsyslog'
	echo '----------------------------------------'
	echo '------------Starting fsyslog------------'
	echo '----------------------------------------'
	echo '----------Logs will be stored in--------'
	echo $logPath
#	"$latestPath"'fsyslog' --log-dir=$logPath --log-file-name=$logFilename
#	ps aux | grep -E "fsyslog" | grep -v grep 
fi
if [[ $(egate_status) -eq 0 ]]
then
	chmod u+x "$latestPath"'egate'
	echo '----------------------------------------'
	echo '-------------Starting egate-------------'
	echo '----------------------------------------'
	"$latestPath"'egate' --port $portEgate
#	ps aux | grep -E "egate" | grep -v grep 
fi

if [[ $(edaemon_status) -eq 0 ]]
then
	#echo '----------------------------------------'
	#echo '----------edaemon is down---------------'
	echo '----------------------------------------'
	echo '------- Starting edaemon for UEC -------'
	echo '----------------------------------------'
	sudo "$latestPath"'edaemon' --port $portUecEdaemon
	echo '----------------------------------------'
	echo '------- Starting edaemon for EPC -------'
	echo '----------------------------------------'
	sudo "$latestPath"'edaemon' --port $portEpcEdaemon
	#echo '----------------------------------------'

fi
if [[ $(edaemon_status) -eq 1 ]]
then
	if [[ $(ps aux | grep -E "edaemon --port "$portUecEdaemon | grep -v grep | wc -l) -lt 1 ]]
	then
		echo 'Starting, previosly down, edaemon for UEC'
		sudo "$latestPath"'edaemon' --port $portUecEdaemon
	fi
	if [[ $(ps aux | grep -E "edaemon --port "$portEpcEdaemon | grep -v grep | wc -l) -lt 1 ]]
	then
		echo 'Starting, previosly down, edaemon for EPC'
		sudo "$latestPath"'edaemon' --port $portEpcEdaemon

	fi
	echo ' '
	echo '------------------------------'
	echo '-----Checking status----------'
	echo '------------------------------'
	echo ' '
	do_status

fi
}

do_stop () {
if [[ $(fsyslog_status) -eq 1 ]]
then
	echo '------------------------------'
	echo '---fsyslog is shutting down---'
	echo '------------------------------'
	fsyslogPid=$(ps aux | grep -E "fsyslog" | grep -v grep | awk '{print $2}')
#	echo $fsyslogPid
	if [[ $fsyslogPid == "" ]] || [[ $fsyslogPid -lt 0 ]]
	then
		echo 'some issue happend with fsyslog process, please check it'
	else
		kill -9 $fsyslogPid
	fi
fi

if [[ $(egate_status) -eq 1 ]]
then
	echo '------------------------------'
	echo '----egate is shutting down----'
	echo '------------------------------'
#	$(ps aux | grep -E "edaemon --port "$portEpcEdaemon | grep -v grep | wc -l)
	egatePid=$(ps aux | grep -E "egate --port "$portEgate | grep -v grep | awk '{print $2}')
	if [[ $egatePid == "" ]] || [[ $egatePid -lt 0 ]]
	then
		echo 'some issue happend with egate process, please check it'
	else
		kill -9 $egatePid
	fi

fi

if [[ $(edaemon_status) -eq 1 ]] || [[ $(edaemon_status) -eq 2 ]]
then
	echo '------------------------------'
	echo '---edaemon is shutting down---'
	echo '------------------------------'
#	$(ps aux | grep -E "edaemon --port "$portEpcEdaemon | grep -v grep | wc -l)
	edaemonUecPid=$(ps aux | grep -E "edaemon --port "$portUecEdaemon | grep -v grep | awk '{print $2}')
	if [[ $edaemonUecPid == "" ]] || [[ $edaemonUecPid -lt 0 ]]
	then
		echo 'some issue happend with edaemon for UEC process, probably been killed before you start script, please check it'
	else
		sudo kill -9 $edaemonUecPid
	fi
	edaemonEpcPid=$(ps aux | grep -E "edaemon --port "$portEpcEdaemon | grep -v grep | awk '{print $2}')
	if [[ $edaemonEpcPid == "" ]] || [[ $edaemonEpcPid -lt 0 ]]
	then
		echo 'some issue happend with edaemon for EPC process, probably been killed before you start script, please check it'
	else
		sudo kill -9 $edaemonEpcPid
	fi
fi

do_status
}



case "$1" in
  start)
	if [[ $3 != '' ]]
	then
		logPath=$2
		if [ ! -d $2 ]
		then
			mkdir -p $2
		fi
	fi

	if [[ $3 != '' ]]
	then
		logFilename=$3	
		echo 'logFilename'$logFilename
	fi

	do_start
	;;
  restart|reload|force-reload)
	echo "Error: argument '$1' not supported" >&2
	exit 3
	;;
  stop)
	do_stop
	exit $?
	;;
  status)
	do_status
	exit $?
	;;
  *)	
	echo "Usage: epc.sh [start|stop|status] -/path/to/directory filename" >&2
	echo "By default: "
	echo "all binaries should be placed in "$latestPath
	echo "log directory is "$logPath" and log filename is "$logFilename
	echo ""
	exit 3
	;;
esac

:
