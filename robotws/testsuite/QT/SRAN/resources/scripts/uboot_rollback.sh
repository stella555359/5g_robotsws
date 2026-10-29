#!/bin/bash

# Usage: ./uboot_rollback.sh <IP_ADDRESS>
if [ -z "$1" ]; then
    echo "Usage: $0 <IP_ADDRESS>"
    exit 1
fi

IP_ADDRESS="$1"

# Remove offending key from known_hosts to avoid host identification errors
ssh-keygen -f "/home/ute/.ssh/known_hosts" -R "$IP_ADDRESS" 2>/dev/null

# Ping the IP address until successful
while ! ping -c 1 $IP_ADDRESS &> /dev/null; do
    echo "Pinging $IP_ADDRESS..."
    sleep 1
done

echo "Ping to $IP_ADDRESS successful."

# SSH into the device and get the active partition
ACTIVE_PARTITION=$(sshpass -p "oZPS0POrRieRtu" ssh toor4nsn@$IP_ADDRESS "uboot_env get | grep active_partition" | awk -F= '{print $2}')

echo "Current active partition: $ACTIVE_PARTITION"

# Check the active partition and set it accordingly
if [ "$ACTIVE_PARTITION" -eq 2 ]; then
    RESPONSE=$(sshpass -p "oZPS0POrRieRtu" ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no toor4nsn@$IP_ADDRESS "uboot_env set active_partition=1" 2>&1)
    if [[ $? -ne 0 || "$RESPONSE" == *"Connection refused"* || "$RESPONSE" == *"No route to host"* || "$RESPONSE" == *"Connection timed out"* ]]; then
        echo "Failed to set active_partition to 1: $RESPONSE"
        exit 1
    fi
    echo "Set active_partition to 1"
elif [ "$ACTIVE_PARTITION" -eq 1 ]; then
    RESPONSE=$(sshpass -p "oZPS0POrRieRtu" ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no toor4nsn@$IP_ADDRESS "uboot_env set active_partition=2" 2>&1)
    if [[ $? -ne 0 || "$RESPONSE" == *"Connection refused"* || "$RESPONSE" == *"No route to host"* || "$RESPONSE" == *"Connection timed out"* ]]; then
        echo "Failed to set active_partition to 2: $RESPONSE"
        exit 1
    fi
    echo "Set active_partition to 2"
else
    echo "Unknown active partition: $ACTIVE_PARTITION"
    exit 1
fi

# Reboot the device
sshpass -p "oZPS0POrRieRtu" ssh toor4nsn@$IP_ADDRESS "reboot"
echo "Reboot command executed."