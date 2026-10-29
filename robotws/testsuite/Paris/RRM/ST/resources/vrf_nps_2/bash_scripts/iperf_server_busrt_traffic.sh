#!/bin/bash

while true; do
  # iperf -c $1 -u -t 1 -b 400M -p $3 -l $2
  iperf -c $1 -u -t 1 -p $2 -i 1 -l $3 -w 20m -b 400000k 2>&1 # Run iperf for 1 second at 10 Mbps
  sleep 3 # Pause for 1 second
done
