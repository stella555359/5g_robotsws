#!/bin/bash

# Directory to store outputs
OUTPUT_DIR="/tmp/env_monitor/"
mkdir -p "$OUTPUT_DIR"

while true; do
    TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

    CPU_FILE="$OUTPUT_DIR/cpu_stats_$TIMESTAMP.json"
    MEM_FILE="$OUTPUT_DIR/mem_stats_$TIMESTAMP.json"

    # Capture CPU stats, average value from last 3 seconds
    CPU_JSON=$(mpstat -P ALL -o JSON 3 1)

    # Parse memory into JSON
    MEM_JSON=$(free -h | awk -v ts="$(date '+%Y-%m-%d %H:%M:%S')" '
    BEGIN {
        printf("{\"timestamp\":\"%s\",", ts)
    }
    NR==2 {
        printf "\"Mem\":{\"total\":\"%s\",\"used\":\"%s\",\"free\":\"%s\",\"shared\":\"%s\",\"buff/cache\":\"%s\",\"available\":\"%s\"},", $2,$3,$4,$5,$6,$7
    }
    NR==3 {
        printf "\"Swap\":{\"total\":\"%s\",\"used\":\"%s\",\"free\":\"%s\"}", $2,$3,$4
        printf "}"
    }
    ')
    # Save to files
    echo "$CPU_JSON" > "$CPU_FILE"
    echo "$MEM_JSON" > "$MEM_FILE"

    sleep 60
done
