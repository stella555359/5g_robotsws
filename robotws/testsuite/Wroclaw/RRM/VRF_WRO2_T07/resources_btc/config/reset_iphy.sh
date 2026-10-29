DIR="$(cd "$(dirname "$0")" && pwd)" && . ${DIR}/config.sh

sshpass -p $PASSWORD ssh $USERNAME@$IPHY_IP "reboot"
