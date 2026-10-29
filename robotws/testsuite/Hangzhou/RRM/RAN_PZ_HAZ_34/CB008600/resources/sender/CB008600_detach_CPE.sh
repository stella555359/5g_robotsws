#!/bin/bash


# SSH 信息
SSH_USER="root"
SSH_HOST="192.168.1.1"
SSH_PORT="60981"
#SSH_PORT="22"
SSH_PASS="NjwDVU4gkio!jyqr"
#SSH_PASS="2d4ab6b2a864"

# Step 1: SSH 到CPE执行 Detach 和 Attach
echo "[INFO] 正在通过 SSH 执行远程 Detach + Attach 操作..."

sshpass -p "$SSH_PASS" ssh -p $SSH_PORT -o StrictHostKeyChecking=no $SSH_USER@$SSH_HOST << 'EOF'
/bin/Nokia.GenericService.RequestCellularService "AICAction" '{"paralist": [{"Action": 2}]}'
EOF


echo "UE detach operation run successfully"