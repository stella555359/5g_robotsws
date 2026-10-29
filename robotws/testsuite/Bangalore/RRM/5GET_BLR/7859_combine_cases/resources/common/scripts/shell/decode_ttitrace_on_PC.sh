#!/bin/bash
event_decoder=/opt/tools/ttiTrace/eventDecoder
ttitrace_log_path=/var/eventsTrace/
extract_ttitrace_log_path=/var/eventsTrace/tti_extracted/
csv_ttitrace_log_path=/var/eventsTrace/tti_extracted/csv/
ttitrace_log_path_on_ASIK=/tmp/ttitrace_log/
log_path_on_control_pc=/home/ute/ttitrace_log/

if [ -n "$1" ];then
    echo log_path_on_control_pc is changed.
    log_path_on_control_pc=$1
else
    echo There is no saved log directory input.
fi
echo log_path_on_control_pc=$log_path_on_control_pc

err_log=$log_path_on_control_pc/error.txt
rm -rf $log_path_on_control_pc/full_dl.csv $log_path_on_control_pc/full_ul.csv
rm -rf $log_path_on_control_pc/L2TtiTrace_EventsSnapshot.bin.*.csv
mkdir $log_path_on_control_pc

sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1 mkdir $ttitrace_log_path_on_ASIK 2>$err_log

ASP_board=`sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1 bsh 1:0 cat /proc/device-tree/module-identity/unit-id 2>$err_log`

if [ $ASP_board = "ABIO" ];then
    CPU_ID=0
else
    CPU_ID=1
fi
CONTAINER_ID=`sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1 bsh 1:$CPU_ID ls -l /tmp/ 2>/dev/null|grep -e ".*ram.*L2RT20"|awk -F "node_" '{print $2}'|awk -F " " '{print $1}'`
echo ASP_board=$ASP_board,CPU_ID=$CPU_ID,CONTAINER_ID=$CONTAINER_ID
result=`sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1 bsh 1:$CPU_ID ls -1rt /var/eventsTrace/*L2TtiTrace_EventsSnapshot.bin.*.tar.gz 2>$err_log`
for i in $result; do
    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1 bsh 1:$CPU_ID rm -rf $extract_ttitrace_log_path 2>/dev/null
    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1 bsh 1:$CPU_ID mkdir $extract_ttitrace_log_path 2>/dev/null
    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1 bsh 1:$CPU_ID mkdir $csv_ttitrace_log_path 2>/dev/null
    echo i=$i
    echo $(date +%T)
    file_extract=`sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1 bsh 1:$CPU_ID tar zxvf $i -C /var/eventsTrace/tti_extracted/ 2>$err_log`
    echo file_extract=$file_extract
    file_csv_output=`sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1 bsh 1:$CPU_ID lxc-attach -n $CONTAINER_ID /opt/tools/ttiTrace/eventDecoder /var/eventsTrace/tti_extracted/$file_extract /var/eventsTrace/tti_extracted/csv/$file_extract 2>$err_log`
    echo file_csv_output=$file_csv_output
    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1 rm -rf $ttitrace_log_path_on_ASIK/* 2>/dev/null
    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1 bget 1:$CPU_ID $csv_ttitrace_log_path/$file_extract.dl.csv $ttitrace_log_path_on_ASIK 2>$err_log
    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1 bget 1:$CPU_ID $csv_ttitrace_log_path/$file_extract.ul.csv $ttitrace_log_path_on_ASIK 2>$err_log
    sshpass -p oZPS0POrRieRtu scp toor4nsn@192.168.255.1:$ttitrace_log_path_on_ASIK/*.csv $log_path_on_control_pc 2>$err_log
done

timeout 5s cat $(ls -tr $log_path_on_control_pc/*dl.csv) > $log_path_on_control_pc/full_dl.csv
timeout 5s cat $(ls -tr $log_path_on_control_pc/*ul.csv) > $log_path_on_control_pc/full_ul.csv
