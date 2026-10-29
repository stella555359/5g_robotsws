#Script to enable BIP mirroring in loner
#Author: OTAVA

#Script to enable BIP mirroring in loner
#Author: OTAVA

# Read bip0 mac address and mask out two last digits
echo 0x3 > /sys/class/xlgx/xlgx0/device/monitored_ports_mask && echo 0x4 > /sys/class/xlgx/xlgx0/device/monitoring_port_flag

