#!/usr/bin/env bash

set -o errexit
set -o pipefail

SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"
PCP_VALUE="0"
FLOW_TYPE=""
DEST_PORT=""
SLOT_ID=""
BACKPLANE_PORT=""
LINK_PORT=""
SVLAN=""
DTPATH="$(ddal ddal_devicetree_get_lfs_path | grep path | cut -d '=' -f 2)"

declare -ri EXIT_FAILURE=1
declare -r ASIB_BOARD_TYPE="FCTM"
declare -r ASIK_BOARD_TYPE="FCTL"
declare -r ASIL_BOARD_TYPE="FCTP"
declare -r ASIM_BOARD_TYPE="FCTQ"
declare -r ASOE_BOARD_TYPE="ASCE"
declare -r ASOF_BOARD_TYPE="ASCF"
declare -r ABIL_UNIT_ID="ASPA"
declare -r ABIN_UNIT_ID="ASPC"
declare -r ABIO_UNIT_ID="ASPD"
declare -r ABIP_UNIT_ID="ASPE"
declare -r ABIQ_UNIT_ID="ASPF"
declare -r DATA_FLOW_L2HI_L2RT="L2HI_L2RT"
declare -r DATA_FLOW_L1_L2_UL="L1_L2_UL"
declare -r DATA_FLOW_L1_L2_DL="L1_L2_DL"
declare -r DATA_FLOW_L1_TO_L2="L1_TO_L2"
declare -r DATA_FLOW_L2_TO_L1="L2_TO_L1"
declare -r DATA_FLOW_L1_L2_LOKIA_SNF="L1_L2_LOKIA_SNF"
declare -r DATA_FLOW_BACKPLANE_LINK="backplane_link"
declare -ri ENABLE=1
declare -ri DISABLE=0
declare -ri ABIL_PORT38=38
declare -ri ABIL_PORT42=42
declare -ri ABIL_PORT46=46
declare -ri ABIL_VLAN_L1_L2=218
declare -ri ABINO_PORT20=100000
declare -ri ABINO_PORT12=1000
declare -ri ABINO_PORT12_PORT16=11000
declare -ri ASOE_PORT4=10
declare -ri ASOE_PORT12=1000
declare -ri ASOE_PORT4_PORT12=1010
declare -ri ASOE_PORT17=20000
declare -ri ASOE_PORT18=40000
declare -ri ASOE_PORT20=100000
declare -ri ABINO_L2HI_L2RT_MIRROR_GROUP=10
declare -ri ABINO_L1_L2_UL_MIRROR_GROUP=11
declare -ri ABINO_L1_L2_DL_MIRROR_GROUP=12
declare -ri ASOE_BACKHAUL_MIRROR_GROUP=13
declare -ri ASOE_L1_L2_LOKIA_SNF_BOTH_MIRROR_GROUP=14
declare -ri ASOE_L2HI_L2RT_MIRROR_GROUP=15
declare -ri ASOE_L2HI_L2RT_ACL_TABLE=51
declare -ri ABINO_L2HI_L2RT_ACL_TABLE=51
declare -ri ABINO_L2HI_TRSP_L2_DOMAIN=22
declare -ri ABINO_L2HI_L2RT_L2_DOMAIN=23
declare -ri ASOE_L2HI_L2RT_L2_DOMAIN=23
declare -ri VLAN_HEADER_LENGTH=14
declare -ri ASIK_BACKPLAIN_MTU=9728
declare -ri ASIK_SEI_MTU=8192
declare -ri SPEED_25G=25000
declare -ri SPEED_10G=10000

declare -A CVLAN_DICT=(["L2HI_L2RT"]="201" ["L1_L2_UL"]="218" ["L1_L2_DL"]="218")
declare -A NCP_ETH_DEVICE_DICT=(["eths0"]="XGMAC113" ["eths1"]="XGMAC112" ["eths2"]="XGMAC97" ["eths3"]="XGMAC96")
declare -A NCP_ETHSEI_DEVICE_DICT=(["ethsei00"]="XGMAC64" ["ethsei01"]="XGMAC65" ["ethsei02"]="XGMAC80" ["ethsei03"]="XGMAC81" \
                                   ["ethsei10"]="XGMAC32" ["ethsei11"]="XGMAC33" ["ethsei12"]="XGMAC48" ["ethsei13"]="XGMAC49")
declare -A FCTM_ABINO_SLOT_BACKPLANE_PORT_DICT=(["C1B1(5)"]="4,0" ["C1B1(1)"]="6,2" ["C1B1(2)"]="7,3" \
                                                ["C1B2(5)"]="8,0" ["C1B2(1)"]="10,2" ["C1B2(2)"]="11,3" \
                                                ["C1B3(5)"]="12,0" ["C1B3(1)"]="16,2" ["C1B3(2)"]="15,3" \
                                                ["C2B4(5)"]="4,0" ["C2B4(1)"]="6,2" ["C2B4(2)"]="7,3" \
                                                ["C2B5(5)"]="8,0" ["C2B5(1)"]="10,2" ["C2B5(2)"]="11,3" \
                                                ["C2B6(5)"]="12,0" ["C2B6(1)"]="16,2" ["C2B6(2)"]="15,3")

declare -A FCTL_SEI_QSFP_DICT=(["sei1"]="10" ["sei2"]="11" ["sei3"]="12" ["sei4"]="13")

declare -A FCTL_ABINO_SLOT_BACKPLANE_PORT_DICT=(["C1B1(5)"]="20,0" ["C1B1(6)"]="21,1" ["C1B1(1)"]="23,2" ["C1B1(2)"]="22,3" ["C1B1(10)"]="25,7" \
                                                ["C1B2(5)"]="28,0" ["C1B2(6)"]="29,1" ["C1B2(1)"]="31,2" ["C1B2(2)"]="30,3" ["C1B2(10)"]="33,7" \
                                                ["C1B3(5)"]="36,0" ["C1B3(6)"]="37,1" ["C1B3(1)"]="39,2" ["C1B3(2)"]="38,3" ["C1B3(10)"]="41,7" \
                                                ["C2B4(5)"]="20,0" ["C2B4(6)"]="21,1" ["C2B4(1)"]="23,2" ["C2B4(2)"]="22,3" ["C1B4(10)"]="25,7" \
                                                ["C2B5(5)"]="28,0" ["C2B5(6)"]="29,1" ["C2B5(1)"]="31,2" ["C2B5(2)"]="30,3" ["C1B5(10)"]="33,7" \
                                                ["C2B6(5)"]="36,0" ["C2B6(6)"]="37,1" ["C2B6(1)"]="39,2" ["C2B6(2)"]="38,3" ["C1B6(10)"]="41,7" )


declare -A FCTP_SEI_QSFP_DICT=(["sei11"]="21" ["sei12"]="22" ["sei13"]="23" ["sei14"]="24"\
                               ["sei21"]="25" ["sei22"]="26" ["sei23"]="27" ["sei24"]="28")

declare -A FCTP_ABINO_SLOT_BACKPLANE_PORT_DICT=(["C1B1(5)"]="35,0" ["C1B1(6)"]="36,1" ["C1B1(1)"]="37,2" ["C1B1(2)"]="38,3" \
                                                ["C1B2(5)"]="39,0" ["C1B2(6)"]="40,1" ["C1B2(1)"]="41,2" ["C1B2(2)"]="42,3" \
                                                ["C1B3(5)"]="43,0" ["C1B3(6)"]="44,1" ["C1B3(1)"]="45,2" ["C1B3(2)"]="46,3" \
                                                ["C2B4(5)"]="35,0" ["C2B4(6)"]="36,1" ["C2B4(1)"]="37,2" ["C2B4(2)"]="38,3" \
                                                ["C2B5(5)"]="39,0" ["C2B5(6)"]="40,1" ["C2B5(1)"]="41,2" ["C2B5(2)"]="42,3" \
                                                ["C2B6(5)"]="43,0" ["C2B6(6)"]="44,1" ["C2B6(1)"]="45,2" ["C2B6(2)"]="46,3" )

declare -A FCTP_ABINO_SLOT_BACKPLANE_PORT_25G_DICT=(["C1B1(5)"]="35,0" ["C1B1(6)"]="36,1" ["C1B1(9)"]="2,6"  ["C1B1(10)"]="1,7" \
                                                    ["C1B2(5)"]="39,0" ["C1B2(6)"]="40,1" ["C1B2(9)"]="6,6"  ["C1B2(10)"]="5,7" \
                                                    ["C1B3(5)"]="43,0" ["C1B3(6)"]="44,1" ["C1B3(9)"]="10,6" ["C1B3(10)"]="9,7" \
                                                    ["C2B4(5)"]="35,0" ["C2B4(6)"]="36,1" ["C2B4(9)"]="2,6"  ["C2B4(10)"]="2,7" \
                                                    ["C2B5(5)"]="39,0" ["C2B5(6)"]="40,1" ["C2B5(9)"]="6,6"  ["C2B5(10)"]="5,7" \
                                                    ["C2B6(5)"]="43,0" ["C2B6(6)"]="44,1" ["C2B6(9)"]="10,6" ["C2B6(10)"]="9,7" )

# ASIM /ABIP info:
#SEI port mapping to QSFP port external
declare -A FCTQ_SEI_QSFP_DICT=(["ethsei11"]="8" ["ethsei12"]="9" ["ethsei13"]="10" ["ethsei14"]="11")

# link port internal from harrier to aldrin3m C1B1(H,A)
declare -A FCTQ_INTERNAL_LINK_PORT=(["C1B1(5)"]="0,16" ["C1B1(6)"]="0,16" ["C1B1(1)"]="0,16" ["C1B1(2)"]="0,16" \
                                    ["C1B2(5)"]="1,17" ["C1B2(6)"]="1,17" ["C1B2(1)"]="1,17" ["C1B2(2)"]="1,17" \
                                    ["C1B3(5)"]="2,18" ["C1B3(6)"]="2,18" ["C1B3(1)"]="2,18" ["C1B3(2)"]="2,18" )

# ASIM-FSP (ABINO/ABIP) BP link. over aldrin3m
# ASIM-ABINO
declare -A FCTQ_ABINO_SLOT_BACKPLANE_PORT_DICT=(["C1B1(5)"]="0,0" ["C1B1(6)"]="1,1" ["C1B1(1)"]="7,2"  ["C1B1(2)"]="6,3" \
                                                ["C1B2(5)"]="2,0" ["C1B2(6)"]="3,1" ["C1B2(1)"]="5,2"  ["C1B2(2)"]="4,3" \
                                                ["C1B3(5)"]="8,0" ["C1B3(6)"]="9,1" ["C1B3(1)"]="15,2" ["C1B3(2)"]="14,3" )

# ASIM-ABIP
declare -A FCTQ_ABIP_SLOT_BACKPLANE_PORT_DICT=(["C1B1(5)"]="0,8" ["C1B1(6)"]="1,8" ["C1B1(1)"]="7,8"  ["C1B1(2)"]="6,8" \
                                               ["C1B2(5)"]="2,8" ["C1B2(6)"]="3,8" ["C1B2(1)"]="5,8"  ["C1B2(2)"]="4,8" \
                                               ["C1B3(5)"]="8,8" ["C1B3(6)"]="9,8" ["C1B3(1)"]="15,8" ["C1B3(2)"]="14,8" )

# ASIL-ABIP
declare -A FCTP_ABIP_SLOT_BACKPLANE_PORT_DICT=(["C1B1(5)"]="35,8" ["C1B1(6)"]="35,8" ["C1B1(1)"]="35,8" ["C1B1(2)"]="35,8" \
                                               ["C1B2(5)"]="39,8" ["C1B2(6)"]="39,8" ["C1B2(1)"]="39,8" ["C1B2(2)"]="39,8" \
                                               ["C1B3(5)"]="43,8" ["C1B3(6)"]="43,8" ["C1B3(1)"]="43,8" ["C1B3(2)"]="43,8" )

#global mirror param for cfg
declare -A MIRROR_PARA=(["PCP_value"]="null" ["src_port"]="null" ["dest_port"]="null" ["flow_type"]="null" \
                        ["backplane_port"]="null" ["slot_id"]="null" ["link_port"]="null" ["service_vlan"]="null" \
                        ["sei_port_status"]="up" ["eth_port_status"]="up" ["aldrin_port_status"]="up" \
                        ["original_mtu"]="9216" ["backplane_speed"]="${SPEED_10G}" ["original_multicast_ctrl"]="null" \
                        ["original_monitored_ports_mask"]="null" ["original_monitoring_port_flag"]="null")

declare -r FILE_CONTENT_ORDER=("PCP_value" "src_port" "dest_port" "flow_type" "backplane_port" "slot_id" "link_port" \
                               "service_vlan" "sei_port_status" "eth_port_status" "aldrin_port_status" "original_mtu" "backplane_speed" \
                               "original_multicast_ctrl" "original_monitored_ports_mask" "original_monitoring_port_flag")
declare -r LIST_HEADER=("index" "slot_id" "flow_type" "service_vlan" "PCP_value" "mirror_path")
declare -r MIRROR_FILE_PATH="/tmp/mirror.txt"

# Failure handler
function die {
    logger --stderr --priority user.error --tag "$SCRIPT_NAME" \
           "$1, exiting with return value $2"
    exit "$2"
}

function get_asil_backplane_port {
    local -r speed=${1}
    local -r backplane=${2}

    if [ "${speed}" == "${SPEED_25G}" ]; then
        backplane_port_array=($(echo ${FCTP_ABINO_SLOT_BACKPLANE_PORT_25G_DICT[$backplane]} | tr ',' ' '))
    else
        backplane_port_array=($(echo ${FCTP_ABINO_SLOT_BACKPLANE_PORT_DICT[$backplane]} | tr ',' ' '))
    fi
    echo ${backplane_port_array[*]}
}

function up_device {
    local -r dev=${1}
    if [ ! "$(ip link show ${dev} | grep UP)" ]; then
        ip link set dev ${dev} up
        if [ ${2} == "sei_port" ]; then
            MIRROR_PARA["sei_port_status"]="down"
        else
            MIRROR_PARA["eth_port_status"]="down"
        fi
    fi
}

function configure_aldrin {
    local -r check_link_status="$(cat /var/run/cpss/ports/${LINK_PORT:4:1}/enable)"
    local -r backplane_port_array=(`echo ${FCTM_ABINO_SLOT_BACKPLANE_PORT_DICT[$BACKPLANE_PORT]} | tr ',' ' '`)
    local -r original_mtu=$(cat /var/run/cpss/ports/${backplane_port_array[0]}/mru)
    local -r new_mtu=$(expr ${original_mtu} + ${VLAN_HEADER_LENGTH})

    #enable port
    if [ $check_link_status -eq $DISABLE ]; then
        echo $ENABLE > /var/run/cpss/ports/${LINK_PORT:4:1}/enable
        MIRROR_PARA["aldrin_port_status"]="down"
    fi

    if [ "$FLOW_TYPE" == "$DATA_FLOW_BACKPLANE_LINK" ]; then
        #Mirror traffic from backplan port to analyzer port
        echo ${LINK_PORT:4:1} both enable > /var/run/cpss/ports/${backplane_port_array[0]}/mirroring_port
        #Add svlan to the packets which mirrored to the analyzer port
        echo $SVLAN $PCP_VALUE both > /var/run/cpss/ports/${LINK_PORT:4:1}/mirroring_svlan
    else
        #Configure svlan to aldrin
        echo $SVLAN $SVLAN do_not_modify > /var/run/cpss/ports/${backplane_port_array[0]}/add_vlan
        #Configure the ingress vlan mirrior to aldrin
        echo $SVLAN enable ingress > /var/run/cpss/ports/${LINK_PORT:4:1}/vlan_mirror
    fi

    #Update MTU in case of dropping the max length packets for PR574362
    MIRROR_PARA["original_mtu"]="$original_mtu"
    echo $new_mtu > /var/run/cpss/vlan_mru
    echo $new_mtu > /var/run/cpss/ports/${LINK_PORT:4:1}/mru
    echo $new_mtu > /var/run/cpss/ports/${backplane_port_array[0]}/mru
}

function configure_ncp {
    local -r eth_xgmac_port="${NCP_ETH_DEVICE_DICT[$LINK_PORT]}"
    local -r ethsei_xgmac_port="${NCP_ETHSEI_DEVICE_DICT[$DEST_PORT]}"
    local -r acl_id="$(ncp_pcx -L | awk '$4=="'${eth_xgmac_port}'" {print $6}')"

    #up device
    up_device $LINK_PORT "eth_port"
    up_device $DEST_PORT "sei_port"

    #Configure xgmac interfaces
    ncp_l2 -i -p $eth_xgmac_port -v $SVLAN -a

    #enable mirroring function for source port and destination port
    ncp_l2 -p $eth_xgmac_port -B -senableMirroring.true
    ncp_l2 -p $ethsei_xgmac_port -E -sisMirroringPort.true

    #set acl for mirroring
    ncp_pcx -a$acl_id -m $ethsei_xgmac_port

    #flooding re-enable when disable mirror function
    if [ "$eth_xgmac_port" != "XGMAC113" ]; then
        ncp_l2 -B -p $eth_xgmac_port -senableFlooding.false
    fi
    ncp_l2 -p $ethsei_xgmac_port -e -supdateHeader.false

    #MTU has set to PKTSIZE_10K, not need to update
}

function configure_fctm {
    #NCP configuration
    configure_ncp
    #Adrin configuration
    configure_aldrin
}

function check_acl_table {
    local -r acl_table_index=$1
    #Check whether the ACL table is created
    if [ ! "$(dbgnac show acl | grep "index ${acl_table_index}")"  ]; then
        echo -e "Warning: ACL table ${acl_table_index} not configured"
    fi
}

function configure_port2_asce {
    local -i sport=0
    sport=${MIRROR_PARA["src_port"]}
    [ ${sport} -eq 100000 ] && dbgnac mirror sport 20 dport 2 e b
    [ $(ip addr | grep nac_eth2 | grep -c UP) -eq 1 ] && return
    dbgnac set port 2 speed 25000
    dbgnac enable port 2
    /usr/bin/netd_uspace_lnk 2 1 25000 1
    ip link set dev nac_eth2 up
    ip link set dev nac_eth2 promisc on
    dbgnac set port 2 loop e t
    dbgnac mirror sport 2 dport 20 e b
}

function restore_port2_asce {
    local -i sport=0
    sport=${MIRROR_PARA["src_port"]}
    [ ${sport} -eq 100000 ] && dbgnac mirror sport 20 dport 2 d b
    [ $(ip addr | grep nac_eth2 | grep -c UP) -eq 0 ] && return
    ip link set dev nac_eth2 promisc off
    ip link set dev nac_eth2 down
    dbgnac set port 2 loop d t
    dbgnac mirror sport 2 dport 20 d b
}

function configure_asce {
    local -i mirror_group=0
    local -i sport=0
    local -i dport=0
    local -i vlan=0
    local -i svlan=0
    local -i acl_table=0
    local -i domainId=0

    sport=${MIRROR_PARA["src_port"]}
    dport=${MIRROR_PARA["dest_port"]}
    [ ${dport} -eq 2 ] && configure_port2_asce
    MIRROR_PARA["service_vlan"]="$svlan"
    domainId=${ASOE_L2HI_L2RT_L2_DOMAIN}


    if [ "${FLOW_TYPE}" == "${DATA_FLOW_BACKPLANE_LINK}" ]; then
        mirror_group=${ASOE_BACKHAUL_MIRROR_GROUP}
        dbgnac del_mirror_attr ${mirror_group}
        dbgnac add_mirror_attr ${mirror_group} ${sport} ${dport} ${vlan} b ${svlan} 0 d
        #dbgnac add_mirror_attr 13 0x40000 17 0 b 310 0 d
    elif [ "$FLOW_TYPE" == "$DATA_FLOW_L1_L2_LOKIA_SNF" ]; then
        mirror_group=${ASOE_L1_L2_LOKIA_SNF_BOTH_MIRROR_GROUP}
        dbgnac del_mirror_attr ${mirror_group}
        dbgnac add_mirror_attr ${mirror_group} ${sport} ${dport} ${vlan} b ${svlan} 0 d
        #dbgnac add_mirror_attr 14 0x1010 17 0 b 0 0 d
    elif [ "$FLOW_TYPE" == "$DATA_FLOW_L2HI_L2RT" ]; then
        check_acl_table ${ASOE_L2HI_L2RT_ACL_TABLE}
        mirror_group=${ASOE_L2HI_L2RT_MIRROR_GROUP}
        dbgnac set_mirror_acl d table ${ASOE_L2HI_L2RT_ACL_TABLE} domainId ${domainId} mirror ${mirror_group}
        dbgnac del_mirror_attr ${mirror_group}
        #dbgnac add_mirror_attr 15 100000 17 0 b 312 0 e
        dbgnac add_mirror_attr ${mirror_group} ${sport} ${dport} ${vlan} b ${svlan} 0 e
        #dbgnac set_mirror_acl e table 51 domainId 23 mirror 15
        dbgnac set_mirror_acl e table ${ASOE_L2HI_L2RT_ACL_TABLE} domainId ${domainId} mirror $mirror_group
    fi

    echo "mirror_group=${mirror_group} sport=${sport} dport=${MIRROR_PARA["dest_port"]}"
}

function configure_abino {
    local -r unit_id=$1
    local -r board_type=$2
    local -r board_id="$((${SLOT_ID}%4))"
    local -r acl_table="$ABINO_L2HI_L2RT_ACL_TABLE"
    local -r new_mtu=$(expr ${MIRROR_PARA["original_mtu"]} + ${VLAN_HEADER_LENGTH})
    local -i mirror_group=0
    local -i port=0
    local cvlan=0
    local flow_direction="b"
    local enable_acl="d"
    local backplane_port_array

    case "$board_type" in
        "$ASIB_BOARD_TYPE")
            backplane_port_array=(`echo ${FCTM_ABINO_SLOT_BACKPLANE_PORT_DICT[$BACKPLANE_PORT]} | tr ',' ' '`)
            ;;
        "$ASIK_BOARD_TYPE")
            backplane_port_array=(`echo ${FCTL_ABINO_SLOT_BACKPLANE_PORT_DICT[$BACKPLANE_PORT]} | tr ',' ' '`)
            ;;
        "$ASIL_BOARD_TYPE")
            backplane_port_array=($(get_asil_backplane_port ${MIRROR_PARA["backplane_speed"]} $BACKPLANE_PORT))
            ;;
        "$ASIM_BOARD_TYPE")
            backplane_port_array=($(get_asim_backplane_port $BACKPLANE_PORT))
            ;;
        *)
            die "Unknown board type $board_type" "$EXIT_FAILURE"
            ;;
    esac

    if [ "$FLOW_TYPE" == "$DATA_FLOW_L2HI_L2RT" ]; then
        mirror_group=$ABINO_L2HI_L2RT_MIRROR_GROUP
        port=$ABINO_PORT20
        cvlan="${CVLAN_DICT[$FLOW_TYPE]}"
        enable_acl="e"
    elif [ "$FLOW_TYPE" == "$DATA_FLOW_L1_L2_UL" ]; then
        mirror_group=$ABINO_L1_L2_UL_MIRROR_GROUP
        if [ "$unit_id" == "$ABIN_UNIT_ID" ]; then
            port=$ABINO_PORT12
        else
            port=$ABINO_PORT12_PORT16
        fi
        flow_direction="i"
    elif [ "$FLOW_TYPE" == "$DATA_FLOW_L1_L2_DL" ]; then
        mirror_group=$ABINO_L1_L2_DL_MIRROR_GROUP
        if [ "$unit_id" == "$ABIN_UNIT_ID" ]; then
            port=$ABINO_PORT12
        else
            port=$ABINO_PORT12_PORT16
        fi
        flow_direction="e"
    fi

    #config mirror attr
    bsh ${board_id}:0 dbgnac del_mirror_attr $mirror_group
    bsh ${board_id}:0 dbgnac add_mirror_attr $mirror_group $port ${backplane_port_array[1]} $cvlan $flow_direction $SVLAN $[$PCP_VALUE<<1] $enable_acl

    #config acl rules
    if [ $enable_acl == "e" ]; then
        bsh ${board_id}:0 dbgnac set_mirror_acl e table $acl_table domainId $ABINO_L2HI_TRSP_L2_DOMAIN mirror $mirror_group
        bsh ${board_id}:0 dbgnac set_mirror_acl e table $acl_table domainId $ABINO_L2HI_L2RT_L2_DOMAIN mirror $mirror_group
    fi

    #Update MTU in case of dropping the max length packets for PR574362
    bsh ${board_id}:0 dbgnac set port ${backplane_port_array[1]} mtu $new_mtu

}

function configure_abil {
    local -r board_id="$((${SLOT_ID}%4))"
    if [ "$FLOW_TYPE" == "$DATA_FLOW_L1_TO_L2" ]; then
        MIRROR_PARA["original_multicast_ctrl"]=$(bsh ${board_id}:2 "head -1 /sys/class/bip/bip0/device/multicast_ctrl")
        bsh ${board_id}:2 "echo fffffff 0 > /sys/class/bip/bip0/device/multicast_ctrl"
    elif [ "$FLOW_TYPE" == "$DATA_FLOW_L2_TO_L1" ]; then
        MIRROR_PARA["original_monitored_ports_mask"]=$(bsh ${board_id}:2 "head -1 /sys/class/xlgx/xlgx0/device/monitored_ports_mask")
        MIRROR_PARA["original_monitoring_port_flag"]=$(bsh ${board_id}:2 "head -1 /sys/class/xlgx/xlgx0/device/monitoring_port_flag")
        bsh ${board_id}:2 "echo 0x2 > /sys/class/xlgx/xlgx0/device/monitored_ports_mask"
        bsh ${board_id}:2 "echo 0x1 > /sys/class/xlgx/xlgx0/device/monitoring_port_flag"
    else
        die "flow not supported $FLOW_TYPE" "$EXIT_FAILURE"
    fi
}

function configure_fctl {
    #FCTL configuration
    local -r backplane_port_array=(`echo ${FCTL_ABINO_SLOT_BACKPLANE_PORT_DICT[$BACKPLANE_PORT]} | tr ',' ' '`)
    local -r sei_port="${FCTL_SEI_QSFP_DICT[$DEST_PORT]}"

    #enable/configure backplane sei port
    if [ "$(dbgrrc show port $sei_port | grep down)" ]; then
        dbgrrc enable port $sei_port
        MIRROR_PARA["sei_port_status"]="down"
    fi

    #add vlan
    dbgrrc add port ${backplane_port_array[0]} vlan $SVLAN tagged y
    dbgrrc add port $sei_port vlan $SVLAN tagged n

    #store the original status
    MIRROR_PARA["backplane_port"]=$BACKPLANE_PORT
    MIRROR_PARA["dest_port"]=$DEST_PORT
    MIRROR_PARA["service_vlan"]=$SVLAN

    #Update SEI port MTU in case of dropping the max length packets for QINQ packets
    #Backplane MTU is 9728, not need to update
    #Set SEI port mtu same with Backplane MTU
    dbgrrc set port $sei_port mtu $ASIK_BACKPLAIN_MTU
}

function asil_3ms_port_map {
    local port
    local -r board_id="$((${SLOT_ID}%4))"
    case "$board_id" in
        "1")
            port=$ABIL_PORT38
            ;;
        "2")
            port=$ABIL_PORT42
            ;;
        "3")
            port=$ABIL_PORT46
            ;;
        *)
            die "Unknown slot id $SLOT_ID" "$EXIT_FAILURE"
            ;;
    esac
    echo $port
}

function configure_fctp {
    local -r unit_id=$1
    local -r board_id="$((${SLOT_ID}%4))"
    local sei_port
    local backplane_port
    local backplane_port_array
    local speed
    local status
    local original_mtu
    local new_mtu

    #configure FCT board
    if [ "$unit_id" == "$ABIL_UNIT_ID" ]; then
        backplane_port="$(asil_3ms_port_map)"
        sei_port="${FCTP_SEI_QSFP_DICT[$DEST_PORT]}"

        #enable/configure backplane sei port
        bcicmd -n 3msd -c "/dbg3ms/port $sei_port set state up"
        bcicmd -n 3msd -c "/dbg3ms/vlan add $ABIL_VLAN_L1_L2 $backplane_port tagged"
        bcicmd -n 3msd -c "/dbg3ms/vlan add $ABIL_VLAN_L1_L2 $sei_port untagged"
    elif [[ "$unit_id" == "$ABIN_UNIT_ID" ]] || [[ "$unit_id" == "$ABIO_UNIT_ID" ]]; then
        #Get ABINO speed 25G or 10G
        speed=(`bsh ${board_id}:0 dbgnac get port 1 speed | awk '{print $4}'`)
        MIRROR_PARA["backplane_speed"]="${speed}"
        backplane_port_array=($(get_asil_backplane_port ${speed} $BACKPLANE_PORT))

        #Get SEI port status
        sei_port="${FCTP_SEI_QSFP_DICT[$DEST_PORT]}"

        #update for the script will exit with 1 when grep doesn't match content and script set -e
        status=(`bcicmd -n 3msd -c "/dbg3ms/port $sei_port show" | grep down`) || true

        #Get backplane port MTU
        original_mtu=$(bcicmd -n 3msd -c "/dbg3ms/port ${backplane_port_array[0]} get frame_size" | awk '$1=="'${backplane_port_array[0]}'" {print $2}')
        new_mtu=$(expr ${original_mtu} + ${VLAN_HEADER_LENGTH})

        #enable/configure backplane sei port
        if [ "$status" ]; then
            bcicmd -n 3msd -c "/dbg3ms/port $sei_port set state up"
            MIRROR_PARA["sei_port_status"]="down"
        fi
        #enable/configure backplane sei port
        bcicmd -n 3msd -c "/dbg3ms/port $sei_port set state up"
        bcicmd -n 3msd -c "/dbg3ms/vlan add $SVLAN ${backplane_port_array[0]} tagged"
        bcicmd -n 3msd -c "/dbg3ms/vlan add $SVLAN $sei_port untagged"
        #disable MAC learning in case of src and dest MAC all are learned on the backplane port
        bcicmd -n 3msd -c "/dbg3ms/port ${backplane_port_array[0]} set learning 0 0 1"

        #store the original status
        MIRROR_PARA["backplane_port"]=$BACKPLANE_PORT
        MIRROR_PARA["dest_port"]=$DEST_PORT
        MIRROR_PARA["service_vlan"]=$SVLAN

        #Update MTU in case of dropping the max length packets for QINQ packets
        MIRROR_PARA["original_mtu"]="$original_mtu"
        bcicmd -n 3msd -c "/dbg3ms/port ${backplane_port_array[0]} set frame_size $new_mtu"
        bcicmd -n 3msd -c "/dbg3ms/port $sei_port set frame_size $new_mtu"

    else
        die "Unknown unit id $unit_id" "$EXIT_FAILURE"
    fi
}

######################## Start ASIM/ABIP Section ######################

#change switch cfg in dbgnet
function current_switch_model_set {
    dbgnet switch set ${1}
}

#return configured switch in dbgnet
function current_switch_model_get
{
    local sw=$(dbgnet switch get | cut -d ":" -f 2)
    echo ${sw}
}

function dbgnet_switch_cfg_check_set
{
    #checking dbgnet switch cfg
    local sw_new=${1}
    local sw=$(current_switch_model_get)
    echo "dbgnet current switch cfg : ${sw}"
    if [ "${sw}" != "${sw_new}" ]; then
        echo "changing dbgnet switch cfg ${sw_new}"
        current_switch_model_set ${sw_new}
    fi
}

#return mapping port aldrin3m to FSPs board
function get_asim_backplane_port {
    local -r backplane_port=${1}
    local -r backplane_port_array=($(echo ${FCTQ_ABINO_SLOT_BACKPLANE_PORT_DICT[${backplane_port}]} | tr ',' ' '))
    echo ${backplane_port_array[*]}
}

#return mapping port for internal link harrier/aldrin3m
function get_asim_interlink_port {
    local -r interlink_port=${1}
    local -r interlink_port_array=($(echo ${FCTQ_INTERNAL_LINK_PORT[${interlink_port}]} | tr ',' ' '))
    echo ${interlink_port_array[*]}
}

#harrier configuration
function asim_configure_harrier {
    echo "harrier cfg"
    local -r unit_id=${1}
    local svlan=${MIRROR_PARA["service_vlan"]}
    #mirroring all vlan recoreded in the switch except management 0/1
    local vlan_id="all"
    #Get SEI port status
    local sei_port=${FCTQ_SEI_QSFP_DICT["${MIRROR_PARA["dest_port"]}"]}

    #checking dbgnet switch cfg
    local sw_new="harrier"
    dbgnet_switch_cfg_check_set ${sw_new}

    #cheching selected SEI port status
    echo "checking SEI port ${sei_port} status"
    if dbgnet port ${sei_port} get state | grep -e disabled -e blocking ; then
        echo "port sei in down state, it will be up"
        dbgnet port ${sei_port} set state forwarding
        sleep 1
        MIRROR_PARA["sei_port_status"]="up"
    else
        echo "sei port is not disabled (down) status"
        MIRROR_PARA["sei_port_status"]="down"
        exit ${EXIT_FAILURE}
    fi

    local interlink_port_array=( $(get_asim_interlink_port $BACKPLANE_PORT) )
    local src_port=${interlink_port_array[0]}
    local dst_port=${sei_port}
    local direction="both"
    local state="enable"

    if [ ${svlan} != "null" ]; then
        #add vlan svlan to interlink port harrier/aldrin3m
        #untagged svlan for SEI port traffic to be catched without tag in external PC
        dbgnet vlan ${svlan} set ports ${dst_port} as untagged
        #tagged traffic from interlink port
        dbgnet vlan ${svlan} set ports ${src_port} as tagged
        vlan_id=${svlan}
    fi

    #mirror backplan port to sei port
    dbgnet mirror set sport ${src_port} dport ${dst_port} vlan ${vlan_id} direction ${direction} ${state}
}

function restore_asim_configure_harrier {
    echo "ASIM: remove & clear all mirror cfg from harrier"

    #disabling mirror
    local sei_port=${FCTQ_SEI_QSFP_DICT["${MIRROR_PARA["dest_port"]}"]}
    local dst_port=${sei_port}
    local vlan_id="all"
    local direction="both"
    local state="disable"
    local svlan=${MIRROR_PARA["service_vlan"]}
    local interlink_port_array=( $(get_asim_interlink_port $BACKPLANE_PORT) )
    local src_port=${interlink_port_array[0]}

    if [ ${svlan} != "null" ]; then
        vlan_id=${svlan}
        dbgnet mirror set sport ${src_port} dport ${dst_port} vlan ${vlan_id} direction ${direction} ${state}
        #remove svlan added
        dbgnet vlan ${svlan} remove ports ${dst_port}, ${src_port}
    else
        # remove mirroring all vlan
        dbgnet mirror set sport ${src_port} dport ${dst_port} vlan ${vlan_id} direction ${direction} ${state}
    fi
    #setting sei port to down
    if [ ${MIRROR_PARA["sei_port_status"]} == "up" ]; then
        dbgnet port ${dst_port} set state disabled
        MIRROR_PARA["sei_port_status"]="down"
    fi
}

#Adrin3m configuration
function asim_configure_aldrin3m
{
    echo "configure_aldrin3m"
    #check dbgnet switch cfg
    local sw_new="aldrin3m"
    dbgnet_switch_cfg_check_set ${sw_new}

    #get backplane port in aldrin3m
    local backplane_port_array=($(get_asim_backplane_port ${MIRROR_PARA["backplane_port"]}))
    local src_port=${backplane_port_array[0]}

    #get interlink port harrier/aldrin3m
    local interlink_port_array=($(get_asim_interlink_port ${MIRROR_PARA["backplane_port"]}))
    local dst_port=${interlink_port_array[1]}
    local vlan_id="all"
    local svlan=${MIRROR_PARA["service_vlan"]}
    local direction="both"

    if [ "${FLOW_TYPE}" != ${DATA_FLOW_BACKPLANE_LINK} ]; then
        #add vlan svlan to src port
        dbgnet vlan ${svlan} set ports ${src_port} as tagged
        #add vlan svlan to dst port
        dbgnet vlan ${svlan} set ports ${dst_port} as tagged

        #mirror all vlan svlan to port dstport
        vlan_id=${svlan}
        direction="ingress"
        dbgnet mirror set sport ${src_port} dport ${dst_port} vlan ${vlan_id} direction ${direction} enable
    else
        echo "setting backplane mode mirroring"
        #mirror port to port traffic from backplane to internal link port
        #already done except if we need to added svlan to this backplane traffic
        #direction=both
    fi
}

function restore_asim_configure_aldrin3m {
    echo "remove & clear all mirror cfg from aldrin3m"
}

function restore_asim {
    #harrier configuration
    restore_asim_configure_harrier
    #Adrin3m configuration
    restore_asim_configure_aldrin3m
}

# ASIM configuration switch for mirroring
function configure_fctq {
    #harrier configuration
    asim_configure_harrier
    #Adrin3m configuration
    asim_configure_aldrin3m
}

## ABIP port mapping to flow type
declare -i ABIP_PORT_L2HI_L2RT=18
declare -i ABIP_PORT_L1_L2=16
declare -i ABIP_PORT_FCT=8

#ABIP harrier configuration
function restore_abip {
    echo "remove and clear all mirror cfg in harrier"
}

# ABIP configuration switch for mirroring
function configure_abip {
    echo "ABIP: harrier configuration"
    local fsp_type=${1}
    local fct_type=${2}
    local cvlan=0
    local direction="both"
    local state="enable"

    if [ ${FLOW_TYPE} == "$DATA_FLOW_L2HI_L2RT" ]; then
        src_port=${ABIP_PORT_L2HI_L2RT}
        dst_port=${ABIP_PORT_FCT}
        cvlan="${CVLAN_DICT[$FLOW_TYPE]}"
        direction="egress"
    elif [ ${FLOW_TYPE} == "$DATA_FLOW_L1_L2_UL" ]; then
        src_port=${ABIP_PORT_FCT}
        dst_port=${ABIP_PORT_L1_L2}
        cvlan="${CVLAN_DICT[$FLOW_TYPE]}"
        direction="ingress"
    elif [ ${FLOW_TYPE} == "$DATA_FLOW_L1_L2_DL" ]; then
        src_port=${ABIP_PORT_FCT}
        dst_port=${ABIP_PORT_L1_L2}
        cvlan="${CVLAN_DICT[$FLOW_TYPE]}"
        direction="egress"
    fi

   dbgnet mirror set sport ${src_port} dport ${dst_port} vlan ${cvlan} direction ${direction} ${state}
}


######################  END ASIM/ABIP Section ##############################

function configure_fct {
    local -r board_type=$1
    local -r unit_id=$2

    #configure FCT board
    case "$board_type" in
        "$ASIB_BOARD_TYPE")
            configure_fctm
            ;;
        "$ASIK_BOARD_TYPE")
            if [ "$FLOW_TYPE" != "$DATA_FLOW_BACKPLANE_LINK" ]; then
                configure_fctl
            else
                die "ASIK doesn't support flow type $FLOW_TYPE" "$EXIT_FAILURE"
            fi
            ;;
        "$ASIL_BOARD_TYPE")
            if [ "$FLOW_TYPE" != "$DATA_FLOW_BACKPLANE_LINK" ]; then
                configure_fctp $unit_id
            else
                die "ASIL doesn't support flow type $FLOW_TYPE" "$EXIT_FAILURE"
            fi
            ;;
        "$ASOE_BOARD_TYPE"|"$ASOF_BOARD_TYPE")
            configure_asce
            ;;
        "${ASIM_BOARD_TYPE}")
            configure_fctq
            ;;
        *)
            die "Unknown board type $board_type" "$EXIT_FAILURE"
            ;;
    esac
}

function retrieve_fsp_unit_id {
    local slot=${1}
    local -r fsp_unit_id="$(tr -d '\0' < ${DTPATH}/slots/${slot}/A/board-identity/unit-id)"
    if [ "$fsp_unit_id" == "" ]; then
        die "Can't retrieve FSP unit id $fsp_unit_id" "$EXIT_FAILURE"
    elif [ "$fsp_unit_id" != "$ABIN_UNIT_ID" ] && [ "$fsp_unit_id" != "$ABIO_UNIT_ID" ] && [ "$fsp_unit_id" != "$ABIL_UNIT_ID" ]; then
        die "Not support FSP unit id $fsp_unit_id" "$EXIT_FAILURE"
    fi
    echo $fsp_unit_id
}

function retrieve_fct_board_type {
    local -r board_type="$(tr -d '\0' < ${DTPATH}/board-identity/unit-id)"
    if [ "$board_type" == "" ]; then
        die "Can't retrieve board type $board_type" "$EXIT_FAILURE"
    fi
    echo $board_type
}

function save_mirror_entry {
    if [ ! -f $MIRROR_FILE_PATH ]; then
        touch $MIRROR_FILE_PATH
    fi
    #make up mirror entry data and save to /tmp/mirror.txt
    for key in ${FILE_CONTENT_ORDER[*]}
    do
        tmp+=$(printf "%s," "${MIRROR_PARA[$key]}")
    done
    echo "$tmp" >> $MIRROR_FILE_PATH
}

function get_mirror_entry {
    local tmp=$1
    local index=0

    arr=(${tmp//,/ })
    for key in ${FILE_CONTENT_ORDER[*]}
    do
        MIRROR_PARA[$key]=${arr[$index]}
        index=`expr $index + 1`
    done
}

function restore_ncp {
    local -r eth_xgmac_port="${NCP_ETH_DEVICE_DICT[${MIRROR_PARA["link_port"]}]}"
    local -r ethsei_xgmac_port="${NCP_ETHSEI_DEVICE_DICT[${MIRROR_PARA["dest_port"]}]}"
    local -r acl_id="$(ncp_pcx -L | awk '$4=="'${eth_xgmac_port}'" {print $6}')"

    #restore eth interfaces
    ncp_l2 -i -p $eth_xgmac_port -v ${MIRROR_PARA["service_vlan"]} -r

    #disable mirroring function for source port and destination port
    ncp_l2 -p $eth_xgmac_port -B -senableMirroring.false
    ncp_l2 -p $ethsei_xgmac_port -E -sisMirroringPort.false
    #disable acl mirroring
    ncp_pcx -a$acl_id -m0

    if [ "$eth_xgmac_port" != "XGMAC113" ]; then
       ncp_l2 -B -p $eth_xgmac_port -senableFlooding.true
    fi
    ncp_l2 -p $ethsei_xgmac_port -e -supdateHeader.true

    if [ ${MIRROR_PARA["eth_port_status"]} == "down" ]; then
        ip link set dev ${MIRROR_PARA["link_port"]} down
    fi
    #restore sei interfaces
    if [ ${MIRROR_PARA["sei_port_status"]} == "down" ]; then
        ip link set dev ${MIRROR_PARA["dest_port"]} down
    fi
}

function restore_aldrin {
    local -r aldrin_port=${MIRROR_PARA["link_port"]:4:1}
    local -r aldrin_port_status=${MIRROR_PARA["aldrin_port_status"]}
    local -r backplane_port=${MIRROR_PARA["backplane_port"]}
    local -r backplane_port_array=(`echo ${FCTM_ABINO_SLOT_BACKPLANE_PORT_DICT[$backplane_port]} | tr ',' ' '`)
    local -r flow_type=${MIRROR_PARA["flow_type"]}
    local -r original_mtu=${MIRROR_PARA["original_mtu"]}

    if [ $flow_type == $DATA_FLOW_BACKPLANE_LINK ]; then
        #disable port mirror
        echo both > /var/run/cpss/ports/${backplane_port_array[0]}/disable_mirroring
        #disable svlan
        echo 1 > /var/run/cpss/ports/$aldrin_port/disable_svlan
    else
        #disable vlan mirror
        echo ${MIRROR_PARA["service_vlan"]} disable ingress > /var/run/cpss/ports/$aldrin_port/vlan_mirror
        #remove service vlan
        echo ${MIRROR_PARA["service_vlan"]} > /var/run/cpss/ports/${backplane_port_array[0]}/remove_vlan
    fi

    #disable port
    if [ $aldrin_port_status == "down" ]; then
        echo $DISABLE > /var/run/cpss/ports/$aldrin_port/enable
    fi

    #restore MTU
    echo $original_mtu > /var/run/cpss/vlan_mru
    echo $original_mtu > /var/run/cpss/ports/$aldrin_port/mru
    echo $original_mtu > /var/run/cpss/ports/${backplane_port_array[0]}/mru
}

function restore_asib {
    restore_aldrin
    restore_ncp
}

function restore_asoe {
    local -r flow_type=${MIRROR_PARA["flow_type"]}
    local -r acl_table="${ASOE_L2HI_L2RT_ACL_TABLE}"
    local -i dport=0

    dport=${MIRROR_PARA["dest_port"]}
    [ ${dport} -eq 2 ] && restore_port2_asce
    if [ "$flow_type" == "$DATA_FLOW_L1_L2_LOKIA_SNF" ]; then
        mirror_group=${ASOE_L1_L2_LOKIA_SNF_BOTH_MIRROR_GROUP}
    elif [ "$flow_type" == "$DATA_FLOW_BACKPLANE_LINK" ]; then
        mirror_group=${ASOE_BACKHAUL_MIRROR_GROUP}
    elif [ "$flow_type" == "$DATA_FLOW_L2HI_L2RT" ]; then
        mirror_group=${ASOE_L2HI_L2RT_MIRROR_GROUP}
        #remove mirror action of ACL rule
        dbgnac set_mirror_acl d table ${acl_table} domainId ${ASOE_L2HI_L2RT_L2_DOMAIN} mirror ${mirror_group}
    fi
    #delete mirror group
    dbgnac del_mirror_attr $mirror_group
}

function restore_abino {
    local -r fct_board_type=${1}
    local -r flow_type=${MIRROR_PARA["flow_type"]}
    local -r board_id="$((${MIRROR_PARA["slot_id"]}%4))"
    local -r acl_table="$ABINO_L2HI_L2RT_ACL_TABLE"
    local -r backplane_port=${MIRROR_PARA["backplane_port"]}
    local -r original_mtu=${MIRROR_PARA["original_mtu"]}

    if [ "$flow_type" == "$DATA_FLOW_L2HI_L2RT" ]; then
        mirror_group=$ABINO_L2HI_L2RT_MIRROR_GROUP
        #delete acl table
        bsh ${board_id}:0 dbgnac set_mirror_acl d table $acl_table domainId $ABINO_L2HI_TRSP_L2_DOMAIN mirror $mirror_group
        bsh ${board_id}:0 dbgnac set_mirror_acl d table $acl_table domainId $ABINO_L2HI_L2RT_L2_DOMAIN mirror $mirror_group
    elif [ "$flow_type" == "$DATA_FLOW_L1_L2_UL" ]; then
        mirror_group=$ABINO_L1_L2_UL_MIRROR_GROUP
    elif [ "$flow_type" == "$DATA_FLOW_L1_L2_DL" ]; then
        mirror_group=$ABINO_L1_L2_DL_MIRROR_GROUP
    fi
    #delete mirror group
    bsh ${board_id}:0 dbgnac del_mirror_attr $mirror_group

    case "$fct_board_type" in
        "$ASIB_BOARD_TYPE")
            #get backplane port
            backplane_port_array=($(echo ${FCTM_ABINO_SLOT_BACKPLANE_PORT_DICT[$backplane_port]} | tr ',' ' '))
            ;;
        "$ASIK_BOARD_TYPE")
            #get backplane port
            backplane_port_array=($(echo ${FCTL_ABINO_SLOT_BACKPLANE_PORT_DICT[$backplane_port]} | tr ',' ' '))
            ;;
        "$ASIL_BOARD_TYPE")
            backplane_port_array=($(get_asil_backplane_port ${MIRROR_PARA["backplane_speed"]} $backplane_port))
            ;;
        "$ASIM_BOARD_TYPE")
            backplane_port_array=($(get_asim_backplane_port $backplane_port))
            ;;
        *)
            die "Unknown board type $fct_board_type" "$EXIT_FAILURE"
            ;;
    esac
    #restore MTU
    bsh ${board_id}:0 dbgnac set port ${backplane_port_array[1]} mtu $original_mtu
}

function restore_asik {
    local -r dest_port=${MIRROR_PARA["dest_port"]}
    local -r svlan=${MIRROR_PARA["service_vlan"]}
    local -r sei_port="${FCTL_SEI_QSFP_DICT[$dest_port]}"

    #remove svlan
    dbgrrc delete vlan $svlan
    #disable port
    if [ ${MIRROR_PARA["sei_port_status"]} == "down" ]; then
        dbgrrc disable port $sei_port
    fi

    #Restore SEI port MTU
    dbgrrc set port $sei_port mtu $ASIK_SEI_MTU
}

function restore_asil {
    local -r dest_port=${MIRROR_PARA["dest_port"]}
    local -r svlan=${MIRROR_PARA["service_vlan"]}
    local -r sei_port="${FCTP_SEI_QSFP_DICT[$dest_port]}"
    local -r original_mtu=${MIRROR_PARA["original_mtu"]}
    local -r fsp_unit="$(retrieve_fsp_unit_id ${MIRROR_PARA["slot_id"]})"

    #remove svlan
    bcicmd -n 3msd -c "/dbg3ms/vlan destroy $svlan"
    #disable port
    if [ ${MIRROR_PARA["sei_port_status"]} == "down" ]; then
        bcicmd -n 3msd -c "/dbg3ms/port $sei_port set state down"
    fi

    if [[ "$fsp_unit" == "$ABIN_UNIT_ID" ]] || [[ "$fsp_unit" == "$ABIO_UNIT_ID" ]]; then
        backplane_port_array=($(get_asil_backplane_port ${MIRROR_PARA["backplane_speed"]} ${MIRROR_PARA["backplane_port"]}))
        #restore MTU
        bcicmd -n 3msd -c "/dbg3ms/port ${backplane_port_array[0]} set frame_size $original_mtu"
        bcicmd -n 3msd -c "/dbg3ms/port $sei_port set frame_size $original_mtu"
        #restore MAC learning
        bcicmd -n 3msd -c "/dbg3ms/port ${backplane_port_array[0]} set learning 1 0 1"
    fi

}

function restore_abil {
    local -r flow_type=${MIRROR_PARA["flow_type"]}
    local -r board_id="$((${SLOT_ID}%4))"
    local -r original_multicast_ctrl=${MIRROR_PARA["original_multicast_ctrl"]}
    local -r original_monitored_ports_mask=${MIRROR_PARA["original_monitored_ports_mask"]}
    local -r original_monitoring_port_flag=${MIRROR_PARA["original_monitoring_port_flag"]}
    if [ "$flow_type" == "$DATA_FLOW_L1_TO_L2" ]; then
        bsh ${board_id}:2 "echo ${original_multicast_ctrl} > /sys/class/bip/bip0/device/multicast_ctrl"
    elif [ "$flow_type" == "$DATA_FLOW_L2_TO_L1" ]; then
        bsh ${board_id}:2 "echo ${original_monitored_ports_mask} > /sys/class/xlgx/xlgx0/device/monitored_ports_mask"
        bsh ${board_id}:2 "echo ${original_monitoring_port_flag} > /sys/class/xlgx/xlgx0/device/monitoring_port_flag"
    else
        die "flow not supported $flow_type" "$EXIT_FAILURE"
    fi
}

function asoe_nac_port_map {
    case "${MIRROR_PARA["src_port"]}" in
        "$ASOE_PORT4")
            MIRROR_PARA["src_port"]="P4"
            ;;
        "$ASOE_PORT12")
            MIRROR_PARA["src_port"]="P12"
            ;;
        "$ASOE_PORT4_PORT12")
            MIRROR_PARA["src_port"]="P4_P12"
            ;;
        "$ASOE_PORT17")
            MIRROR_PARA["src_port"]="P17"
            ;;
        "$ASOE_PORT18")
            MIRROR_PARA["src_port"]="P18"
            ;;
        "$ASOE_PORT20")
            MIRROR_PARA["src_port"]="P20"
            ;;
        *)
            echo "${MIRROR_PARA["src_port"]}"
            ;;
    esac
}

function list_mirror_entries {
    local -r board_type="$(retrieve_fct_board_type)"
    #show header
    #format as follow:
    #    index           slot_id         flow_type       service_vlan    PCP_value       mirror_path
    for tmp in ${LIST_HEADER[*]}
    do
        printf "%-15s " $tmp
    done
    printf "\n"

    if [ ! -f $MIRROR_FILE_PATH ]; then
        return
    fi

    #show file contents
    index=1
    for tmp in `cat $MIRROR_FILE_PATH`
    do
        get_mirror_entry $tmp
        if [ $board_type == ${ASOE_BOARD_TYPE} ] || [ $board_type == ${ASOF_BOARD_TYPE} ]; then
            asoe_nac_port_map
            MIRROR_PARA["mirror_path"]="${MIRROR_PARA["src_port"]}->${MIRROR_PARA["dest_port"]}"
            printf "%-15i %-15s %-15s %-15s %-15s %-15s\n" $index ${MIRROR_PARA["slot_id"]} ${MIRROR_PARA["flow_type"]} ${MIRROR_PARA["service_vlan"]} ${MIRROR_PARA["PCP_value"]} ${MIRROR_PARA["mirror_path"]}
        else
            #make up mirror path as SPEC show
            MIRROR_PARA["mirror_path"]="${MIRROR_PARA["backplane_port"]}->${MIRROR_PARA["link_port"]}->${MIRROR_PARA["dest_port"]}"
            #show index slot_id flow_type service_vlan PCP_value and mirror_path
            printf "%-15i %-15s %-15s %-15s %-15s %-15s\n" $index ${MIRROR_PARA["slot_id"]} ${MIRROR_PARA["flow_type"]} ${MIRROR_PARA["service_vlan"]} ${MIRROR_PARA["PCP_value"]} ${MIRROR_PARA["mirror_path"]}
        fi
        index=`expr $index + 1`
    done
}

function delete_mirror_entry {
    local -r delete_index=$1
    local -r board_type="$(retrieve_fct_board_type)"

    if [ ! -f $MIRROR_FILE_PATH ]; then
        return
    fi

    index=1
    for tmp in `cat $MIRROR_FILE_PATH`
    do
        if [ $index -eq $delete_index ] ; then
            get_mirror_entry $tmp
            #restore FCT board
            case "$board_type" in
                "$ASIB_BOARD_TYPE")
                    restore_asib
                    ;;
                "$ASIK_BOARD_TYPE")
                    restore_asik
                    ;;
                "$ASIL_BOARD_TYPE")
                    restore_asil
                    ;;
                "$ASOE_BOARD_TYPE"|"$ASOF_BOARD_TYPE")
                    restore_asoe
                    ;;
                "$ASIM_BOARD_TYPE")
                    restore_asim
                    ;;
                *)
                    die "Unknown board type $board_type" "$EXIT_FAILURE"
                    ;;
            esac
            if [[ "${MIRROR_PARA["flow_type"]}" != "$DATA_FLOW_BACKPLANE_LINK" ]] && [[ "$board_type" != "$ASOE_BOARD_TYPE" ]] && [[ "$board_type" != "$ASOF_BOARD_TYPE" ]]; then
                fsp_unit="$(retrieve_fsp_unit_id ${MIRROR_PARA["slot_id"]})"
                #Restore fsp board
                if [ "$fsp_unit" == "$ABIL_UNIT_ID" ]; then
                    restore_abil $board_type
                fi

                if [[ "$fsp_unit" == "$ABIN_UNIT_ID" ]] || [[ "$fsp_unit" == "$ABIO_UNIT_ID" ]]; then
                    #restore abino
                    restore_abino $board_type
                fi
            fi
            #delete entry from mirror file
            sed -i "${delete_index}d" "$MIRROR_FILE_PATH"
            exit 1
        fi
        index=`expr $index + 1`
    done
}

function main {
    local fsp_unit_id=""
    local -r board_type="$(retrieve_fct_board_type)"

    if [ "$board_type" != "$ASOE_BOARD_TYPE" ] && [ $board_type != ${ASOF_BOARD_TYPE} ]; then
        fsp_unit_id="$(retrieve_fsp_unit_id $SLOT_ID)"
    fi
    #Configure FCT board
    configure_fct $board_type $fsp_unit_id

    if [[ "$FLOW_TYPE" != "$DATA_FLOW_BACKPLANE_LINK" ]] && [[ "$board_type" != "$ASOE_BOARD_TYPE" ]] && [[ "$board_type" != "$ASOF_BOARD_TYPE" ]]; then
        #Configure ABIL board
        if [ "$fsp_unit_id" == "$ABIL_UNIT_ID" ]; then
            configure_abil
        fi
        #Configure ABINO board
        if [[ "$fsp_unit_id" == "$ABIN_UNIT_ID" ]] || [[ "$fsp_unit_id" == "$ABIO_UNIT_ID" ]]; then
            configure_abino $fsp_unit_id $board_type
        fi

        if [ ${fsp_unit_id} == ${ABIP_UNIT_ID} ]; then
            configure_abip ${fsp_unit_id} ${board_type}
        fi
    fi
    save_mirror_entry
}

function usage {
    echo "Usage: lfs-nw_switch-mirror-tool.sh [OPTIONS]..."
    echo "Configure path for mirroring data flow."
    echo
    echo "Options"
    echo "   -p pcp_value [0|1|...] default value 0"
    echo "   -d destination_port [ethsei10|ethsei11|...] for asib, [sei11|sei12|...] for asil, [sei1|sei2|...] for asik"
    echo "   -f data_flow_type [L1_L2_UL|L1_L2_DL|L2HI_L2RT|backplane_link|L1_L2_LOKIA_SNF]"
    echo "                     L1_L2_UL: traffic from Ll to L2  L1_L2_DL: traffic from L2 to L1"
    echo "                     L1_L2_LOKIA_SNF: traffic from L1(LOKIA) to L2(Snowfish), only for ASOE"
    echo "   -b backplane_port [\"C1B1(5)\"|\"C1B1(6)\"|... ]"
    echo "   -s fsp slot_id [1|2|...]"
    echo "   -S source port for ASOE,Set the corresponding binary to 1 according to the port number"
    echo "      and then calculate the hexadecimal,For example: "
    echo "      P12->0001 0000 0000 0000->0x1000"
    echo "   -l link_port [eths0|eths2|eths3] ASIB only"
    echo "   -v service_vlan_id [303|304|...|317]"
    echo "   -L list all mirror entries"
    echo "   -D delete one mirror entry"
    echo "                       Please list all mirror entries before delete mirror entry"
    echo "                       After deleting one entry, the next entry numbers move up"
    echo
    echo "Examples:"
    echo "   ASIB+ABIN/O"
    echo "     configure mirror"
    echo "       ./lfs-nw_switch-mirror-tool.sh -p 1 -d ethsei01 -f L2HI_L2RT -b \"C1B1(5)\" -s 1 -l eths2 -v 303"
    echo "       ./lfs-nw_switch-mirror-tool.sh -p 0 -d ethsei02 -f L1_L2_UL -b \"C1B2(1)\" -s 2 -l eths3 -v 304"
    echo "       ./lfs-nw_switch-mirror-tool.sh -p 0 -d ethsei01 -f L1_L2_DL -b \"C1B2(1)\" -s 2 -l eths2 -v 305"
    echo "       mirror them to the same SEI port, but not suggestion."
    echo "       ./lfs-nw_switch-mirror-tool.sh -p 0 -d ethsei02 -f L1_L2_UL -b \"C1B2(1)\" -s 1 -l eths3 -v 304"
    echo "       ./lfs-nw_switch-mirror-tool.sh -p 0 -d ethsei02 -f L1_L2_DL -b \"C1B2(1)\" -s 1 -l eths3 -v 305"
    echo "       backplane mirror"
    echo "       ./lfs-nw_switch-mirror-tool.sh -p 0 -d ethsei02 -f backplane_link -b \"C1B2(1)\" -s 1 -l eths3 -v 304"
    echo "     list all mirror informations"
    echo "       ./lfs-nw_switch-mirror-tool.sh -L"
    echo "     delete one mirror entry"
    echo "       ./lfs-nw_switch-mirror-tool.sh -D 3"
    echo
    echo "     Please follow the new port grouping(LTE5265-A-c) on ASIB as below when configure mirror"
    echo "        eths1(XGMAC112)----->ethsei00(XGMAC64)"
    echo "        eths2(XGMAC97)------>ethsei01(XGMAC65) ethsei03(XGMAC81)"
    echo "        eths3(XGMAC96)------>ethsei02(XGMAC80)"
    echo
    echo "     ASIB SEI ports mapping"
    echo "               |-----------| ---------|           |-----------| ---------|"
    echo "               |   SEI1    | AXM Port |           |   SEI2    | AXM Port |"
    echo "               |-----------| ---------|           |-----------| ---------|"
    echo "               | ethsei00  | XGMAC64  |           | ethsei10  | XGMAC32  |"
    echo "               | ethsei01  | XGMAC65  |           | ethsei11  | XGMAC33  |"
    echo "               | ethsei02  | XGMAC80  |           | ethsei12  | XGMAC48  |"
    echo "               | ethsei03  | XGMAC81  |           | ethsei13  | XGMAC49  |"
    echo "               |-----------| ---------|           |-----------| ---------|"
    echo
    echo "   ASIK+ABIN/O"
    echo "       ./lfs-nw_switch-mirror-tool.sh -p 1 -d sei1 -f L2HI_L2RT -b \"C1B1(5)\" -s 1 -v 305"
    echo
    echo "                                 |--------| ----------|"
    echo "                                 | SEI    | ASIK Port |"
    echo "                                 |--------| ----------|"
    echo "                                 | sei1   |    10     |"
    echo "                                 | sei2   |    11     |"
    echo "                                 | sei3   |    12     |"
    echo "                                 | sei3   |    13     |"
    echo "                                 |--------| ----------|"
    echo
    echo "   ASIL+ABIN/O"
    echo "       ./lfs-nw_switch-mirror-tool.sh -p 1 -d sei11 -f L1_L2_UL -b \"C1B1(5)\" -s 1 -v 306"
    echo
    echo "               |--------| ----------|              |--------| ----------|"
    echo "               | SEI1   | 3ms Port  |              | SEI2   | 3ms Port  |"
    echo "               |--------| ----------|              |--------| ----------|"
    echo "               | sei11  |    21     |              | sei21  |    25     |"
    echo "               | sei12  |    22     |              | sei22  |    26     |"
    echo "               | sei13  |    23     |              | sei23  |    27     |"
    echo "               | sei14  |    24     |              | sei24  |    28     |"
    echo "               |--------| ----------|              |--------| ----------|"
    echo
    echo "   ASIL+ABIL"
    echo "       ./lfs-nw_switch-mirror-tool.sh -p 1 -d sei11 -f L1_TO_L2 -s 1"
    echo
    echo "               |--------| ----------|              |--------| ----------|"
    echo "               | SEI1   | 3ms Port  |              | SEI2   | 3ms Port  |"
    echo "               |--------| ----------|              |--------| ----------|"
    echo "               | sei11  |    21     |              | sei21  |    25     |"
    echo "               | sei12  |    22     |              | sei22  |    26     |"
    echo "               | sei13  |    23     |              | sei23  |    27     |"
    echo "               | sei14  |    24     |              | sei24  |    28     |"
    echo "               |--------| ----------|              |--------| ----------|"
    echo
    echo "   ASIM: "
    echo "               |-----------|---------------|                             "
    echo "               | SEI1      | harrier Port  |                             "
    echo "               |-----------|---------------|                             "
    echo "               | ethsei11  |      8        |                             "
    echo "               | ethsei12  |      9        |                             "
    echo "               | ethsei13  |      10       |                             "
    echo "               | ethsei14  |      11       |                             "
    echo "               |-----------|---------------|                             "
    echo
    echo " ./lfs-nw_switch-mirror-tool.sh -d ethsei11 -f backplane_link -b \"C1B1(5)\" -s X"
    echo
    echo "  ASOE"
    echo "      ./lfs-nw_switch-mirror-tool.sh -S <src_port> -f <data_flow> -d <dest_port> "
    echo "      example: "
    echo "      P18->P17 "
    echo "      ./lfs-nw_switch-mirror-tool.sh -S 40000 -f backplane_link -d 17 "
    echo "      P17->P18 "
    echo "      ./lfs-nw_switch-mirror-tool.sh -S 20000 -f backplane_link -d 18 "
    echo "      P4_P12->P17 "
    echo "      ./lfs-nw_switch-mirror-tool.sh -S 1010 -f L1_L2_LOKIA_SNF -d 17 "
    echo "      P4->P17 "
    echo "      ./lfs-nw_switch-mirror-tool.sh -S 10 -f L1_L2_LOKIA_SNF -d 17 "
    echo "      P12->P17 "
    echo "      ./lfs-nw_switch-mirror-tool.sh -S 1000 -f L1_L2_LOKIA_SNF -d 17 "
    echo "      P20->P17 "
    echo "      ./lfs-nw_switch-mirror-tool.sh -S 100000 -f L2HI_L2RT -d 17 "
    exit 1
}

#Deal option parameters
while getopts "p:d:f:b:s:S:l:v:h:D:L" option; do
    case $option in
        p)
            if [ "$OPTARG" -le 7 ]; then
                PCP_VALUE="$OPTARG"
                MIRROR_PARA["PCP_value"]="$PCP_VALUE"
            else
                die "Invalid pcp value $OPTARG" "$EXIT_FAILURE"
            fi
            ;;
        d)
            reg='^ethsei[0-1][0-3]|^sei[0-9]{1,2}|[0-9]$'
            if [[ "$OPTARG" =~ $reg ]]; then
                DEST_PORT="$OPTARG"
                MIRROR_PARA["dest_port"]="$DEST_PORT"
            else
                die "Unknown destination port $OPTARG" "$EXIT_FAILURE"
            fi
            ;;
        f)
            case "$OPTARG" in
                "$DATA_FLOW_L2HI_L2RT"|"$DATA_FLOW_L1_L2_UL"|"$DATA_FLOW_L1_L2_DL"| \
                "$DATA_FLOW_BACKPLANE_LINK"|"$DATA_FLOW_L1_L2_LOKIA_SNF"| \
                "$DATA_FLOW_L1_TO_L2"|"$DATA_FLOW_L2_TO_L1")
                    FLOW_TYPE="$OPTARG"
                    MIRROR_PARA["flow_type"]="$FLOW_TYPE"
                    ;;
                *)
                    die "Unknown data flow type $OPTARG" "$EXIT_FAILURE"
                    ;;
            esac
            ;;
        b)
            reg='^C[1-2]B[1-6]\([0-9]{1,2}\)$'
            if [[ "$OPTARG" =~ $reg ]]; then
                BACKPLANE_PORT="$OPTARG"
                MIRROR_PARA["backplane_port"]="$BACKPLANE_PORT"
            else
                die "Unknown backplane port $OPTARG" "$EXIT_FAILURE"
            fi
            ;;
        s)
            if [ $OPTARG -le 7 ]; then
                SLOT_ID="$OPTARG"
                MIRROR_PARA["slot_id"]="$SLOT_ID"
            else
                die "Unknown slot id $OPTARG" "$EXIT_FAILURE"
            fi
            ;;
        S)
            reg='[0-9]'
            if [[ "$OPTARG" =~ $reg ]]; then
                SRC_PORT="$OPTARG"
                MIRROR_PARA["src_port"]="$SRC_PORT"
            else
                die "Unknown src_port $OPTARG" "$EXIT_FAILURE"
            fi
            ;;
        l)
            reg='^eths[0,2,3]$'
            if [[ "$OPTARG" =~ $reg ]]; then
                LINK_PORT="$OPTARG"
                MIRROR_PARA["link_port"]="$LINK_PORT"
            else
                die "Unknown link port $OPTARG" "$EXIT_FAILURE"
            fi
            ;;
        v)
            #vlan range is [303-317]
            if [ $OPTARG -ge 303 ] && [ $OPTARG -le 317 ] ; then
                SVLAN="$OPTARG"
                MIRROR_PARA["service_vlan"]="$SVLAN"
            else
                die "Unknown service vlan $OPTARG" "$EXIT_FAILURE"
            fi
            ;;
        L)
            list_mirror_entries
            exit 1
            ;;
        D)
            delete_mirror_entry $OPTARG
            exit 1
            ;;
        h|*)
            usage
            ;;
    esac
done

main
