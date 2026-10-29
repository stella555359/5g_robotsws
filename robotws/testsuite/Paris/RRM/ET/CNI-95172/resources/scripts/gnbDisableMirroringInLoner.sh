#!/bin/bash

abil1_master_xeon_node='1:0'
abil1_slave_xeon_node='1:1'
abil1_loner_node='1:2'
abil2_loner_node='2:2'
abil3_loner_node='3:2'

disableMirroringInLoner() {
    echo -e "${YELLOW}Disable mirroring in Loner $1${NC}"
    bsh $1 "echo 0x0 > /sys/class/xlgx/xlgx0/device/monitored_ports_mask && echo 0x0 > /sys/class/xlgx/xlgx0/device/monitoring_port_flag"
}

disableMirroringInLoners() {
    bsh $abil1_loner_node "echo 0 2 > /sys/class/bip/bip0/device/multicast_ctrl"
    if [ $MIRROR_ABIL_1 = 'true' ]; then disableMirroringInLoner "$abil1_loner_node"; fi
    if [ $MIRROR_ABIL_2 = 'true' ]; then disableMirroringInLoner "$abil2_loner_node"; fi
    if [ $MIRROR_ABIL_3 = 'true' ]; then disableMirroringInLoner "$abil3_loner_node"; fi
}

readOptionsFromConfigFile() {
    directory="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
    source $directory/gnbMirroringConfig.sh
    if [ $? -eq 0 ]; then 
        echo -e "\n${YELLOW}Read options from gnbMirroringConfig.sh${NC}"
    else 
        echo -e "\n${RED}Config file (gnbMirroringConfig.sh) not found${NC}"
        exit
    fi
}

readOptionsFromConfigFile

disableMirroringInLoners

# disableMirroringInAsikRrc $asik_rrc_abil1_slave_xeon_port
# disableX2MirroringInAsikRrc $asik_rrc_abil1_slave_xeon_port
            
            
            