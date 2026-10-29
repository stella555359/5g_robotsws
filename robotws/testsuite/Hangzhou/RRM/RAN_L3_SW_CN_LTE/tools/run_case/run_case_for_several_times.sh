#!/bin/sh
if [ $# != 2 ]
then
	echo "usage: $0 <path to robot file> <times>"
    exit
fi
	
log_dir=/home/ute/log_`date +%Y%m%d%H%M`
mkdir -p $log_dir
log=$log_dir/pybot.log
for i in $(seq 1 $2)
do
   rm -rf $log
   echo "======= this is time $i to run case ===="
   robot -L trace -l ${i}_log.html -o ${i}_output.xml  -d $log_dir/${i} -v REMOVE_LOGS:on "$1" | tee -a ${log}
   grep "| FAIL |" ${log} > /dev/null
   found_fail=`echo $?`
   if [ $found_fail != 0 ]
   then
      cp $log_dir/${i}/${i}_log.html $log_dir/${i}_log_pass.html
   else
      cp $log_dir/${i}/${i}_log.html $log_dir/${i}_log_fail.html
   fi
done

