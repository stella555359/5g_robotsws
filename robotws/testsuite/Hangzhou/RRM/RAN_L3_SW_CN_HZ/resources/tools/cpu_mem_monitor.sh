#!/bin/bash

# 接收日志文件名作为第一个参数
LOG_FILE=${1:-"monitor_$(date +%F_%H-%M-%S).log"}
INTERVAL=2       # 采样间隔（秒）
TOP_N=10         # 展示占用最多的前 N 个进程

echo "Monitoring started... Press [CTRL+C] to stop."
echo "Logging to $LOG_FILE"
echo ""

while true; do
    TIMESTAMP=$(date "+%F %T")
    echo "========== $TIMESTAMP ==========" | tee -a "$LOG_FILE"

    # 总体 CPU 使用率（更稳妥提取方法）
    CPU_LINE=$(top -bn1 | grep "Cpu(s)")
    CPU_IDLE=$(echo "$CPU_LINE" | awk -F',' '{ for(i=1;i<=NF;i++) if ($i ~ /id/) print $i }' | awk '{print $1}')
    CPU_USAGE=$(awk "BEGIN {print 100 - $CPU_IDLE}")
    echo "CPU Usage: ${CPU_USAGE%%.*}%" | tee -a "$LOG_FILE"

    # 内存使用率
    MEM_INFO=$(free -m | grep Mem)
    MEM_USED=$(echo $MEM_INFO | awk '{print $3}')
    MEM_TOTAL=$(echo $MEM_INFO | awk '{print $2}')
    MEM_PERC=$(awk "BEGIN {printf \"%.2f\", ($MEM_USED/$MEM_TOTAL)*100}")
    echo "Memory Usage: $MEM_USED / $MEM_TOTAL MB (${MEM_PERC}%)" | tee -a "$LOG_FILE"

    # Top N 占用资源的进程（使用 top 替代 ps，避免高 CPU 消耗）
    echo "Top $TOP_N Processes by CPU:" | tee -a "$LOG_FILE"
    top -b -n1 | head -n $(($TOP_N + 7)) | tee -a "$LOG_FILE"

    echo "" | tee -a "$LOG_FILE"
    sleep $INTERVAL
done
