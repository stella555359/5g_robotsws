#Script to disable all mirroring in loner
#Author: ANEZROUK
# info: https://confluence.int.net.nokia.com/pages/viewpage.action?pageId=904771598

echo "write 0x0000F600 0x0" > /sys/kernel/debug/ixgbe/0000:04:00.0/reg_ops

echo "write 0x0000F604 0x0" > /sys/kernel/debug/ixgbe/0000:04:00.0/reg_ops

echo "write 0x0000F600 0x0" > /sys/kernel/debug/ixgbe/0000:04:00.1/reg_ops

echo "write 0x0000F604 0x0" > /sys/kernel/debug/ixgbe/0000:04:00.1/reg_ops

pid=$(ps -ef | grep -E '^[tcpdump|root]' | grep ethloner0 | awk '{print $2}')

pkill -9 $pid