#!/bin/bash

if [ $# != 1 ]; then
    fname=trf_stats_AP.log
else
    fname=$1
fi
count=0
while true
do
  ((count+=1))
  echo "[${count}] **************************************`date`**************************************" >> ${fname}
  echo "show port stats 0,15 rates" | cli -k 1234 >> ${fname}
  echo "" >> ${fname}
  echo "*********************************************************************************" >> ${fname}
  echo "" >> ${fname}
  echo "show port stats all rates" | cli -k 1234 >> ${fname}
  echo "" >> ${fname}
  echo "*********************************************************************************" >> ${fname}
  echo "" >> ${fname}
  sleep 5
done

