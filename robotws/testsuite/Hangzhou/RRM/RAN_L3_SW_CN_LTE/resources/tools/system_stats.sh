#!/bin/bash

function GetProperPid(){
	pids_arr=($(ps -eLf | grep $1 | grep -v grep | awk '{print $4}'))
	pid_sleep_thread=()
	pid_main_thread=()
	itr=0
	while [ $itr -lt ${#pids_arr[@]} ]; do
		if [ $((itr%2)) -eq 0 ]; then
			pid_sleep_thread=(${pid_sleep_thread[@]} $(( pids_arr[itr] )))
		else
			pid_main_thread=(${pid_main_thread[@]} $((pids_arr[itr])))
		fi
		itr=$(( itr+1 ))
	done
	echo ${pid_main_thread[@]}
}

function GetTotalPhysMemKB(){
	while read -r line; do
		if [[ $line == *"MemTotal"* ]]; then
			echo $line | awk '{print "Total available physical memory:      ", $2, "KB"}' | tee -a system_stats.log
		fi
	done <<< "$mem_info"		
}

function GetTotalFreeMemKB(){
	while read -r line; do
		if [[ $line == *"MemFree"* ]]; then
			echo $line | awk '{print "Total free physical memory:           ", $2, "KB"}' | tee -a system_stats.log
		fi
	done <<< "$mem_info"
}

function GetTotalCpuLoad(){
	if [ -z "$prev_stat" ]; then
		prev_user_mode=0; prev_user_mode_low=0; prev_sys_mode=0; prev_idle_task=0;
	else		
		read ignore1 prev_user_mode prev_user_mode_low prev_sys_mode prev_idle_task ignore2 <<< $prev_stat 
	fi
	read ignore1 curr_user_mode curr_user_mode_low curr_sys_mode curr_idle_task ignore2 <<< $curr_stat 
	if [ $prev_user_mode != 0 ] || [ $prev_user_mode_low != 0 ] || [ $prev_sys_mode != 0 ] || [ $prev_idle_task != 0 ]; then
		percent=$(( curr_user_mode-prev_user_mode + curr_user_mode_low-prev_user_mode_low + curr_sys_mode-prev_sys_mode ))
		total=$((percent + curr_idle_task-prev_idle_task))
		percent=$(echo $percent $total | awk '{printf "%.2f", 100*$1/$2}')
		echo -e "Total CPU load in system:             " $percent "%" $'\t' "\c" | tee -a system_stats.log
	else	
		echo    "Total CPU load in system:             " N/A | tee -a system_stats.log
	fi
	
	#get cpu usage per core
	if [ -z "$prev_stat" ]; then
		prev_user_mode=0; prev_user_mode_low=0; prev_sys_mode=0; prev_idle_task=0;
	else
		prev_cores_user_mode=()
		prev_cores_user_mode_low=()
		prev_cores_sys_mode=()
		prev_cores_idle_task=()
		while read -r line; do
			if [[ $line == *"cpu"* ]]; then
				if [[ $line != *"cpu "* ]]; then
					prev_cores_user_mode=(${prev_cores_user_mode[@]} $( echo $line | awk '{print $2}' ))
					prev_cores_user_mode_low=(${prev_cores_user_mode_low[@]} $( echo $line | awk '{print $3}' ))
					prev_cores_sys_mode=(${prev_cores_sys_mode[@]} $( echo $line | awk '{print $4}' ))
					prev_cores_idle_task=(${prev_cores_idle_task[@]} $( echo $line | awk '{print $5}' ))
				fi
			fi
		done <<< "$prev_stat"		
		curr_cores_user_mode=()
		curr_cores_user_mode_low=()
		curr_cores_sys_mode=()
		curr_cores_idle_task=()
		while read -r line; do
			if [[ $line == *"cpu"* ]]; then
				if [[ $line != *"cpu "* ]]; then
					curr_cores_user_mode=(${curr_cores_user_mode[@]} $( echo $line | awk '{print $2}' ))
					curr_cores_user_mode_low=(${curr_cores_user_mode_low[@]} $( echo $line | awk '{print $3}' ))
					curr_cores_sys_mode=(${curr_cores_sys_mode[@]} $( echo $line | awk '{print $4}' ))
					curr_cores_idle_task=(${curr_cores_idle_task[@]} $( echo $line | awk '{print $5}' ))
				fi
			fi
		done <<< "$curr_stat"

		
		core_stats=(" (")
		min=999
		max=0
		itr=0
		while [ $itr -lt ${#curr_cores_user_mode[@]} ]; do
			percent=$(( curr_cores_user_mode[itr]-prev_cores_user_mode[itr] + curr_cores_user_mode_low[itr]-prev_cores_user_mode_low[itr] + curr_cores_sys_mode[itr]-prev_cores_sys_mode[itr] ))
			total=$((percent + curr_cores_idle_task[itr]-prev_cores_idle_task[itr]))
			percent=$(echo $percent $total | awk '{printf "%.2f", 100*$1/$2}')
			if [ 1 -eq "$(echo "${percent} > ${max}" | bc)" ]; then
				max=${percent}
			fi
			if [ 1 -eq "$(echo "${percent} < ${min}" | bc)" ]; then
				min=${percent}
			fi
			core_stats=(${core_stats[@]} $percent)
			itr=$(( itr+1 ))					
			if [ $itr -lt ${#curr_cores_user_mode[@]} ]; then
				core_stats=(${core_stats[@]} "|")
			fi					
		done
		core_stats=(${core_stats[@]} ") ( MIN: " $min " | MAX:" $max ")")
		echo ${core_stats[@]} | tee -a system_stats.log
	fi
}

function GetNumberOfCpus(){
	cpu=0;
	while read -r line; do
		if [[ $line == *"processor"* ]]; then
				cpu=$(( cpu+1 ));
		fi
	done <<< "$cpu_info"
	echo "Total number of CPUs:                 " $cpu | tee -a system_stats.log
}

function GetUdpInErrs(){
	while read -r line; do
		if [[ $line == *"Udp"* ]]; then
			if [[ $line != *"NoPorts"* ]]; then
				if [[ $line != *"UdpLite"* ]]; then
					udp_in_errs=$( echo $line | awk '{print $4}' )
				fi	
			fi
		fi
	done <<< "$net_snmp"	
	echo "Total OS UDP Queue Overflow:          " "$(( udp_in_errs-prev_udp_in_errs ))" packets | tee -a system_stats.log
}

function GetUdpRcvErrs(){
	while read -r line; do
		if [[ $line == *"Udp"* ]]; then
			if [[ $line != *"NoPorts"* ]]; then
				if [[ $line != *"UdpLite"* ]]; then
					udp_rcv_buf_errs=$( echo $line | awk '{print $6}' )
				fi	
			fi
		fi
	done <<< "$net_snmp"		
	echo "Total App UDP Socket Buffer Overflow: " "$(( udp_rcv_buf_errs-prev_udp_rcv_buf_errs ))" packets | tee -a system_stats.log
}

function GetPidProcName(){
	while read -r line; do
		if [[ $line == *"Name"* ]]; then
			echo $line | awk '{print $2}'
		fi
	done <<< "$status_pid"
}

function GetPidPhysMem(){
	while read -r line; do
		if [[ $line == *"VmRSS"* ]]; then
			echo $line | awk '{print $2}'
		fi
	done <<< "$status_pid"
}

function GetPidVirtMem(){
	while read -r line; do
		if [[ $line == *"VmSize"* ]]; then
			echo $line | awk '{print $2}'
		fi
	done <<< "$status_pid"
}

function GetPidCpuLoad(){
	if [ -z "$prev_stat_pids" ]; then
		echo N/A
	else
		itr=0
		while [ $itr -lt ${#prev_stat_pids[@]} ]; do
			if [ $(echo ${prev_stat_pids[itr]} | awk '{print $1}') == $(echo $1 | awk '{print $1}') ]; then
				read ignore1 ignore2 ignore3 ignore4 ignore5 ignore6 ignore7 ignore8 ignore9 ignore10 ignore11 ignore12 ignore13 curr_utime curr_stime ignore14 <<< $1
				read ignore15 curr_user_mode curr_user_mode_low curr_sys_mode curr_idle_task ignore16 <<< $curr_stat
				read ignore1 ignore2 ignore3 ignore4 ignore5 ignore6 ignore7 ignore8 ignore9 ignore10 ignore11 ignore12 ignore13 prev_utime prev_stime ignore14 <<< "${prev_stat_pids[itr]}"
				read ignore15 prev_user_mode prev_user_mode_low prev_sys_mode prev_idle_task ignore16 <<< $prev_stat
				percent=$(( curr_utime-prev_utime + curr_stime-prev_stime))
				total=$(( curr_user_mode-prev_user_mode + curr_user_mode_low-prev_user_mode_low + curr_sys_mode-prev_sys_mode + curr_idle_task-prev_idle_task ))
				percent=$(echo $percent $total | awk '{printf "%.2f", 100*$1/$2}')
				echo $percent				
			fi
			itr=$(( itr+1 ))
		done		
	fi
}

#=====================
#        MAIN
#=====================
net_snmp=$(cat /proc/net/snmp)
#get initial InErrors Value
prev_udp_in_errs=0
while read -r line; do
    if [[ $line == *"Udp"* ]]; then
		if [[ $line != *"NoPorts"* ]]; then
			if [[ $line != *"UdpLite"* ]]; then
				prev_udp_in_errs=$( echo $line | awk '{print $4}' )
			fi	
		fi
	fi
done <<< "$net_snmp"

#get initial RcvBufErrors Value
prev_udp_rcv_buf_errs=0
while read -r line; do
	if [[ $line == *"Udp"* ]]; then
		if [[ $line != *"NoPorts"* ]]; then
			if [[ $line != *"UdpLite"* ]]; then
				prev_udp_rcv_buf_errs=$( echo $line | awk '{print $6}' )
			fi	
		fi
	fi
done <<< "$net_snmp"

prev_stat=""
prev_stat_pids=()
while [ 1 ]; do
	sleep 1
	
	date +%Y-%m-%d__%H:%M:%S | tee -a system_stats.log	
	mem_info=$(cat /proc/meminfo)
	net_snmp=$(cat /proc/net/snmp)
	cpu_info=$(cat /proc/cpuinfo)
	curr_stat=$(cat /proc/stat)
	GetTotalPhysMemKB
	GetTotalFreeMemKB
	GetTotalCpuLoad
	GetNumberOfCpus
	GetUdpInErrs
	GetUdpRcvErrs	

	pids=()
	status_pid=0
	curr_stat_pids=()	
	proc_name_pids=()
	phys_mem_pids=()
	virt_mem_pids=()
	cpu_load_pids=()
	
	pids=(${pids[@]} $(GetProperPid egate) $(GetProperPid edaemon) $(GetProperPid sim_))
	itr=0
	while [ $itr -lt ${#pids[@]} ]; do
		status_pid=$(cat /proc/$(( pids[itr] ))/status)
		curr_stat_pids=("${curr_stat_pids[@]}" "$(cat /proc/$(( pids[itr] ))/stat)")
		proc_name_pids=(${proc_name_pids[@]} $(GetPidProcName))
		phys_mem_pids=(${phys_mem_pids[@]} $(GetPidPhysMem))
		virt_mem_pids=(${virt_mem_pids[@]} $(GetPidVirtMem))		
		itr=$(( itr+1 ))
	done	
	itr=0
	while [ $itr -lt ${#curr_stat_pids[@]} ]; do
		cpu_load_pids=("${cpu_load_pids[@]}" "$(GetPidCpuLoad "${curr_stat_pids[itr]}")")
		itr=$(( itr+1 ))
	done
	
	echo ${pids[@]} 		  | awk '{print "PID:                  ", $0}' | tee -a system_stats.log
	echo ${proc_name_pids[@]} | awk '{print "Process:              ", $0}' | tee -a system_stats.log
	echo ${phys_mem_pids[@]}  | awk '{print "Physical Memory Used: ", $0}' | tee -a system_stats.log
	echo ${virt_mem_pids[@]}  | awk '{print "Virtual Memory Used:  ", $0}' | tee -a system_stats.log
	echo ${cpu_load_pids[@]}  | awk '{print "Current CPU Load:     ", $0}' | tee -a system_stats.log
	
	prev_stat=$curr_stat
	unset prev_stat_pids
	prev_stat_pids=("${curr_stat_pids[@]}")
	echo | tee -a system_stats.log
done
