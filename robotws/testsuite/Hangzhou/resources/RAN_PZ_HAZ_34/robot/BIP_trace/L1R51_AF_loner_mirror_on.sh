#Script to enable BIP mirroring in loner
#Author: OTAVA

# Read bip0 mac address and mask out two last digits
bip0=`ifconfig arb0p0 | grep HWaddr`
bip0_mac=${bip0:38:17}

# Get BIP0 arp index
bip0_arp=`cat /sys/class/xlgx/xlgx0/device/arb_rules| grep -a $bip0_mac`
bip0_arp_index=${bip0_arp:1:1}
#echo $bip0_arp_index

# Read MAC conf
mac_conf=`dump-ethss-xlgx-regs xlgx0 | grep "MAC_CONF\[$bip0_arp_index\]"`
#echo $mac_conf
# Extract value from string
mac_conf_value=${mac_conf:32:32}
#echo $mac_conf_value
# Set second LSB to one
mac_conf_value_mod="$((mac_conf_value|0x4))"
#echo $mac_conf_value_mod
# Convert to hex
mac_conf_value_mod_hex=`printf '%x\n' $mac_conf_value_mod`
#echo $mac_conf_value_mod_hex

echo "Write ${mac_conf_value_mod_hex} to MAC_CONF[$bip0_arp_index] address"
fpga_rw wn xlgx002_xlgx_blk.MAC_CONF[$bip0_arp_index] $mac_conf_value_mod_hex

