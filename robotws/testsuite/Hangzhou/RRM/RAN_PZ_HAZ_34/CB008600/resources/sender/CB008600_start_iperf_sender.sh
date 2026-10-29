#!/bin/bash
# the input parameters are 1:5qi, 2:port, 3:size, 4:datarate, 5:time in sequence.
temp_5qi=$1
temp_port=$2
temp_size=$3
temp_datarate=$4
temp_time=$5
filename_1="case104_${temp_5qi}_sender_out.pcap"
IFACE="ens255f0"
time_s=$(($5 + 10))

IP_LIST=$(ip -4 addr show dev "$IFACE" | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
for IP in $IP_LIST; do
    if [[ $IP == 172.* ]]; then
        DHCP_IP=$IP
        break
    fi
done

# 检查是否找到了 DHCP 地址
if [[ -z "$DHCP_IP" ]]; then
    echo "[ERROR] The IP address obtained by DHCP was not found with the beginning of 172.."
    exit 1
fi

echo "timeout $time_s sudo tcpdump -i ens255f0 udp and port "$temp_port" -w "$filename_1""
timeout $time_s sudo tcpdump -i ens255f0 udp and port "$temp_port" -w "$filename_1" &
sleep 1
iperf -c 10.108.250.230 -u -e -t "$temp_time" -l "$temp_size" -b "$temp_datarate" --trip-times -p "$temp_port" -i 1 -B "$DHCP_IP" &
echo "sender ok"
