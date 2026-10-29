#!/bin/bash

function get_asp_board_type(){
    echo "input frame_id: "$1
    frame_id=$1
    asp_board_type=$(bsh $frame_id:0 cat /proc/device-tree/module-identity/unit-id)
    echo -E "get_asp_board_type: "$asp_board_type
    echo -E $frame_id":"$asp_board_type
}

function get_ownnid(){
    echo "input asp_board_type: "$1
    echo "input frame_id: "$2
    asp_board_type=$1
    frame_id=$2
    if [ $asp_board_type == 'ABIL' ]; then
        ownnid=$(bsh $frame_id:1 ownnid)
    elif [ $asp_board_type == 'ABIO' ]; then
        ownnid=$(bsh $frame_id:0 ownnid)
    fi
    echo "ownnid: " $ownnid
}

function get_L1BypassMap(){
    echo "input ownnid: "$1
    echo "input frame_id: "$2
    ownnid=$1
    frame_id=$2
    ownnid_2=$(printf "0x%x\n" $(($ownnid+0x10)))
    l1_node_id=$(echo $ownnid_2 | tr [d] [D])

    if [ '$frame_id'=='1' ]; then l1_frame_id='0x574A'
    elif [ '$frame_id'=='2' ]; then l1_frame_id='0x584A'
    elif [ '$frame_id'=='3' ]; then l1_frame_id='0x594A'
    fi
    
    L1BypassMap=$l1_node_id":"$l1_frame_id
    echo "L1BypassMap: "$L1BypassMap
}

function check_l1bypass_tag(){
    check_result=$(echo "tag -3r app.btsom.nts.L1BypassMap" | nc 0 15007)
    echo "***check l1bypass tag result: "$check_result
}

sysbshtopo_output=$(chk sysbshtopo)
frame_num=$(chk sysbshtopo| grep -c loner)
echo "frame_num: "$frame_num

declare -a L1BypassMap_list
for frame_id in $(seq 1 $frame_num)
do
    get_asp_board_type $frame_id
    echo "1: "$asp_board_type
    get_ownnid $asp_board_type $frame_id
    echo "2: "$ownnid
    get_L1BypassMap $ownnid $frame_id
    echo "3: "$L1BypassMap
    L1BypassMap_list[${#L1BypassMap_list[@]}]=$L1BypassMap
    echo "L1BypassMap_list: "$L1BypassMap_list
done

check_l1bypass_tag
L1BypassMap_all=$(IFS=,; echo "${L1BypassMap_list[*]}")
echo "L1BypassMap_all: "$L1BypassMap_all
set_l1bypass=$(echo "tag -3w app.btsom.nts.L1BypassMap $L1BypassMap_all" | nc 0 15007)
echo "set_l1bypass: "$set_l1bypass
check_l1bypass_tag


echo "Set Fullstuck to L1bypass on GNB done"

# rm -rf /ffs/run/swpool/OAM/tmp
# cd /ffs/run/swpool/OAM
# gNB_Position="$1"

# if [[ $gNB_Position == left_side ]]; then
#     new_tag='<tag name="app.btsom.nts.L1BypassMap"type="string">0x125D:0x524A<\/tag>'
# else
#     new_tag='<tag name="app.btsom.nts.L1BypassMap"type="string">0x225D:0x524A<\/tag>'
# fi
# echo $gNB_Position":"$new_tag

# name=$(ls | grep "psconfig-A.*.txz$")
# tar -xvf $name

# status=$(sed -n "/${new_tag}/=" /ffs/run/swpool/OAM/tmp/rat_psconfig.xml)

# if [[ -z $status ]]; then
#     line_number=$(sed -n "/<\/config>/=" /ffs/run/swpool/OAM/tmp/rat_psconfig.xml)
#     sed -i "${line_number}i\    ${new_tag}" /ffs/run/swpool/OAM/tmp/rat_psconfig.xml
#     tar -czvf $name tmp/
#     knife install $name /ffs/run/swpool/OAM/
# fi
