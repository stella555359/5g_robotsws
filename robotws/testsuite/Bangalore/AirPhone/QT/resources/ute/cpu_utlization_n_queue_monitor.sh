#!/bin/bash

if [ $# != 1 ]; then
    echo "Argument missing! Please provide filename to store the stats."
	echo ""
	echo "Usage: $0 absolute_file_path"
	echo "Example: $0 /tmp/cpu_udp_stats.log"
	exit 1
fi

fname=$1
>$fname
echo "Collecting UDP and CPU stats in ${fname}"
echo "Press Ctrl + C to stop."
count=0
echo "dd if=/dev/zero of=/opt/wts/latest/test1.img bs=300M count=1 oflag=dsync" >> ${fname}
dd if=/dev/zero of=/opt/wts/latest/test1.img bs=300M count=1 oflag=dsync >> ${fname} 2>&1
rm /opt/wts/latest/test1.img
while true
do
  ((count+=1))
  echo "[${count}] **************************************`date`**************************************" >> ${fname}
    if [[ $count == 10 || $count == 20 ]]; then
      echo "dd if=/dev/zero of=/opt/wts/latest/test1.img bs=300M count=1 oflag=dsync" >> ${fname}
      dd if=/dev/zero of=/opt/wts/latest/test1.img bs=300M count=1 oflag=dsync >> ${fname} 2>&1
      rm /opt/wts/latest/test1.img
  fi
  echo "[${count}] *********************************************************************************" >> ${fname}
  echo "cat /proc/net/udp" >> ${fname}
  cat /proc/net/udp >> $1
  #top -p `pidof sim_upf` -p `pidof sim_uec` -p `pidof sim_enb` -p `pidof sim_pgw` -p `pidof sim_sgw` -o +%CPU -b  -n1 >> ${fname}
  # Collect CPU stats of all running processes
  echo "" >> ${fname}
  echo "top -o +%CPU -b  -n1 | head -n 40" >> ${fname}
  COLUMNS=900 top -o +%CPU -b  -n1 | head -n 40 >> ${fname}
  echo "" >> ${fname}
  echo "cat /proc/loadavg" >> ${fname}
  cat /proc/loadavg >> ${fname}
  cat /proc/loadavg | awk '{print $1 * 100}' >> ${fname}
  echo "sudo netstat -anp" >> ${fname}
  sudo netstat -anp >> ${fname}
  echo "" >> ${fname}
  if (( count % 5 == 0 )); then
    pstree -p >> ${fname}
  fi
  sleep 5
done

