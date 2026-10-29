#!/bin/bash

# Usage: ./tcp_scripts.sh <traffic_duration_in_minutes>

# Check if argument provided
if [ -z "$1" ]; then
  echo "Usage: $0 <traffic_duration_in_minutes>"
  exit 1
fi

# Convert minutes to seconds and add 60s buffer
duration=$(( $1 * 60 + 60 ))

echo "Monitoring duration: $duration seconds"

# Record the start time
start_time=$(date +%s)

# Run the loop for the specified duration
while :
do
  current_time=$(date +%s)
  elapsed_time=$(( current_time - start_time ))

  if (( elapsed_time >= duration )); then
    echo "Specified duration of $duration seconds has elapsed. Exiting script."
    break
  fi

  top -d 1 -n1 -b >> /home/ute/logs/top.txt
  date >> /home/ute/logs/udp_proc.txt
  cat /proc/net/udp >> /home/ute/logs/udp_proc.txt
  date >> /home/ute/logs/tcp_proc.txt
  cat /proc/net/tcp >> /home/ute/logs/tcp_proc.txt
  date >> /home/ute/logs/netstats.txt
  netstat -s -t >> /home/ute/logs/netstats.txt
  date >> /home/ute/logs/ifconfig.txt
  sudo ifconfig -a >> /home/ute/logs/ifconfig.txt
  date >> /home/ute/logs/ss.txt
  ss -tim >> /home/ute/logs/ss.txt

  sleep 1
done
