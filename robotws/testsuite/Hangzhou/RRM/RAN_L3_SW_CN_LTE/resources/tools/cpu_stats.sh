#!/bin/bash
clear
filename=0
echo ============================================
if [ $# -eq 0 ]; then
	filename=cpu_stats_$(date +%Y%m%d_%H%M).log
	echo "Specify filename through:"
	echo "./cpu_stats.sh <filename>"
	echo --------------------------------------------
else
	filename=$1	
fi
echo Logging to $filename
echo ============================================
sleep 1

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

#=====================
#        MAIN
#=====================
pids_buffer=()
process_pid=()
process_name=()
current_cpu_utilization=()
minimum_cpu_utilization=()
maximum_cpu_utilization=()
average_cpu_utilization=()
total_for_average=()
count_for_average=0
SECONDS=0
start_time=$(date +%Y-%m-%d__%H:%M:%S)

while [ 1 ]; do
	pids_buffer=($(GetProperPid egate) $(GetProperPid edaemon) $(GetProperPid sim_))
	pids_in_comma=$(printf ",%s" "${pids_buffer[@]}")	
	IFS=$'\n'
	top_output=()
	top_output=($(top -p${pids_in_comma:1} -b -n1 | egrep "sim_|egate|edaemon"))
	unset IFS
	
	date +%Y-%m-%d__%H:%M:%S | tee -a $filename
	echo $SECONDS | awk '{ printf "%02d:%02d:%02d", $1/3600, $1/60%60, $1%60}' | tee -a $filename
	echo " since $start_time" | tee -a $filename

	itr=0
	if [ -z "$process_pid" ]; then
		while [ $itr -lt ${#top_output[@]} ]; do
			process_pid=(${process_pid[@]} $( echo ${top_output[itr]} | awk '{print $1}' ))
			process_name=(${process_name[@]} $( echo ${top_output[itr]} | awk '{print $12}' ))
			current_cpu_utilization=(${current_cpu_utilization[@]} $( echo ${top_output[itr]} | awk '{print $9}' ))
			minimum_cpu_utilization=(${minimum_cpu_utilization[@]} $( echo ${top_output[itr]} | awk '{print $9}' ))
			maximum_cpu_utilization=(${maximum_cpu_utilization[@]} $( echo ${top_output[itr]} | awk '{print $9}' ))
			average_cpu_utilization=(${average_cpu_utilization[@]} $( echo ${top_output[itr]} | awk '{print $9}' ))
			total_for_average=(${total_for_average[@]} $( echo ${top_output[itr]} | awk '{print $9}' ))
			count_for_average=1
			itr=$(( itr+1 ))
		done
	else
		count_for_average=$(( count_for_average+1 ))
		while [ $itr -lt ${#top_output[@]} ]; do
			itr2=0
			while [ $itr2 -lt ${#process_pid[@]} ]; do
				if [ $( echo ${top_output[itr]} | awk '{print $1}' ) == ${process_pid[itr2]} ]; then
					if [ $( echo ${top_output[itr]} | awk '{print $12}' ) == ${process_name[itr2]} ]; then
						current_cpu_utilization[itr2]=$( echo ${top_output[itr]} | awk '{print $9}' )
						if (( $(bc <<< "${minimum_cpu_utilization[itr2]} > $( echo ${top_output[itr]} | awk '{print $9}' )") )); then
							minimum_cpu_utilization[itr2]=$( echo ${top_output[itr]} | awk '{print $9}' )
						fi
						if (( $(bc <<< "${maximum_cpu_utilization[itr2]} < $( echo ${top_output[itr]} | awk '{print $9}' )") )); then
							maximum_cpu_utilization[itr2]=$( echo ${top_output[itr]} | awk '{print $9}' )
						fi
						total_for_average[itr2]=$( echo ${total_for_average[itr2]} + $( echo ${top_output[itr]} | awk '{print $9}' ) | bc )
						average_cpu_utilization[itr2]=$(echo ${total_for_average[itr2]} $count_for_average | awk '{printf "%.2f", $1/$2}')
					else
						echo "ERROR: PID-Process mismatch"
						exit
					fi
				fi
				itr2=$(( itr2+1 ))
			done
			itr=$(( itr+1 ))
		done
	fi
	
	echo "=========================================" | tee -a $filename
	echo " PROCESS  PID      CUR   MIN   MAX    AVE" | tee -a $filename
	echo "-----------------------------------------" | tee -a $filename
	itr=0
	while [ $itr -lt ${#top_output[@]} ]; do
		echo 	${process_name[itr]} ${process_pid[itr]} ${current_cpu_utilization[itr]} ${minimum_cpu_utilization[itr]} ${maximum_cpu_utilization[itr]} ${average_cpu_utilization[itr]} | awk '{ printf "%8s %-5s   %5s%6s%6s%7s\n", $1, $2, $3, $4, $5, $6}' | tee -a $filename
		itr=$(( itr+1 ))
	done
	echo "=========================================" | tee -a $filename
	echo | tee -a $filename
	echo | tee -a $filename
done