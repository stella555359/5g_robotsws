#!/bin/bash

function getEgateProperPid(){
	egate_num=`ps -ef | grep egate | grep port| grep -v grep |  wc -l`
	if [ "$egate_num" -ge "2" ]; then
		echo "Too many egates are running on the host. Please. Keep the single instance"
		exit 1
	fi
	pids_arr=($(ps -eLf | grep egate | grep -v grep | grep port | awk '{print $4}'))
	pid_sleep_thread=${pids_arr[0]}
	pid_main_thread=${pids_arr[1]}
	echo "$pid_main_thread"
}

function getEgatePort(){
	egate_port=`ps -ef | grep egate | grep port | awk 'BEGIN { FS = "=| " } ; {print $NF}'`
	echo "$egate_port"
}

function prepareEdaemonPortGrepCondition(){
	tel_port=$1
	pids_arr=($(ps -ef | grep edaemon | grep -v grep | grep port | awk 'BEGIN { FS = "=| " } ; {print $NF}'))
	grepCondition=`printf %X $tel_port`

	for t in "${pids_arr[@]}"
	do
		app_port_hex=`printf %X $t`
		grepCondition="$grepCondition|$app_port_hex"
	done
	echo "$grepCondition"
}



period=1.5
egate_pid=$(getEgateProperPid)
egate_port=$(getEgatePort)
ports_to_grep=$(prepareEdaemonPortGrepCondition "$egate_port")
echo "Working with thread $egate_pid, egate port:$egate_port, grep condition:$ports_to_grep"

while [ 1 ]; do
	date +%Y-%m-%d_%H:%M:%S
	echo ==TOP stats==
	top -b -n1 | egrep "egate|sim_enb|%CPU"

	echo ==/proc/pid/status stats==
	sudo egrep "State|Vm" /proc/"$egate_pid"/status
	
	echo ==/proc/pid/stack stats==
	sudo cat /proc/"$egate_pid"/stack
	
	echo ==/proc/pid/net/tcp stats==
	sudo egrep -i "$ports_to_grep" /proc/"$egate_pid"/net/tcp

	sleep $period
done
