#!/bin/bash
output=$(pgrep -fa syslog)

while read -r line; do
    if [[ "$line" == *"-p 51000 51001 51003 50011"* ]]; then
        #Extract the main PID to pid varaible
        pid=$(echo "$line" | awk '{print $1}')
        echo "Killing process $pid"
        #Kill syslog process
        kill -9 "$pid"
    fi
done <<< "$output"
