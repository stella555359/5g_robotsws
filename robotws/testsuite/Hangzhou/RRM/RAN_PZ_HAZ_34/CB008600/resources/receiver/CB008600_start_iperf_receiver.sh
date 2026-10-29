#!/bin/bash
# the input parameters are 1:5qi, 2:port, 3:size, 4:datarate, 5:time in sequence.
temp_5qi=$1
temp_port=$2
temp_size=$(($3 + 28))
temp_datarate=$4
temp_time=$5
filename_1="case104_${temp_5qi}_bts_out_A.pcap"
filename_2="case104_${temp_5qi}_receiver_in_B.pcap"
filename_3="case104_${temp_5qi}_UL_TTI_${temp_size}B_${temp_datarate}.txt"

# Start tcpdump and iperf processes with the specified parameters
timeout "$temp_time" sudo tcpdump -i ens4f1 udp and port 2152 -w "$filename_1" &
timeout "$temp_time" sudo tcpdump -i ens4f0 udp and port "$temp_port" -w "$filename_2" &
timeout "$temp_time" iperf -s -e -u --histograms=100u,100000,98,99.99 -p "$temp_port" -B 10.108.250.230 >"$filename_3" &
echo "receiver ok"