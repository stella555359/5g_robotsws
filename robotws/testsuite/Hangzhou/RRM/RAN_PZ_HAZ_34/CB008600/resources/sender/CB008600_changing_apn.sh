#!/bin/bash

SSH_USER="root"
SSH_HOST="192.168.1.1"
SSH_PORT="60981"
SSH_PASS="NjwDVU4gkio!jyqr"
temp_apn=$1

if [ $# -eq 0 ]; then
    echo "Mandatory parameter APN not provided"
    exit 1
fi

echo "Input APN is $1"

sshpass -p "$SSH_PASS" ssh -p "$SSH_PORT" -o StrictHostKeyChecking=no "$SSH_USER"@"$SSH_HOST" << EOF
cfgcli -fs InternetGatewayDevice.WANDevice.2.X_ALU-COM_Cellular.AccessPoint.1.APN "$temp_apn"
sleep 3s
EOF

echo "APN has been changed"
