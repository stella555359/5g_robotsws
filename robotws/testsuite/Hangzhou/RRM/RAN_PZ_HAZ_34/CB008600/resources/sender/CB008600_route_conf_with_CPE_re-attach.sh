#!/bin/bash

# 网卡名和目标IP
IFACE="ens255f0"
TARGET_IP="10.108.250.230"

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
sleep 6
/bin/Nokia.GenericService.RequestCellularService "AICAction" '{"paralist": [{"Action": 1}]}'
EOF


echo "[INFO] SSH 操作完成。"

sleep 10

# Step 2: 重载连接并重启网卡
echo "[INFO] 重新加载网络配置并重启接口 $IFACE ..."
#sudo nmcli connection reload
#sudo nmcli connection down $IFACE
#sudo nmcli connection up $IFACE
sudo ifdown $IFACE
sudo ifup $IFACE

# 等待网络接口启动并分配IP（必要时延时几秒）
sleep 8

# 获取该网卡上的所有 IPv4 地址
IP_LIST=$(ip -4 addr show dev $IFACE | grep -oP '(?<=inet\s)\d+(\.\d+){3}')

# 查找以 172. 开头的 DHCP 地址
for IP in $IP_LIST; do
    if [[ $IP == 172.* ]]; then
        DHCP_IP=$IP
        break
    fi
done

# 检查是否找到了 DHCP 地址
if [[ -z "$DHCP_IP" ]]; then
    echo "[ERROR] 未能找到 DHCP 获取的 IP 地址（以 172. 开头）。"
    exit 1
fi

# 添加路由前先删除旧路由（如果存在）
echo "[INFO] 添加静态路由：$TARGET_IP → $DHCP_IP"
sudo ip route del $TARGET_IP 2>/dev/null
sudo ip route add $TARGET_IP via $DHCP_IP dev $IFACE

echo "[SUCCESS] 路由添加成功：$TARGET_IP → $DHCP_IP（dev $IFACE）"