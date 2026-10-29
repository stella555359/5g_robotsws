#!/bin/bash
function get_L1BypassMap(){
    L1BypassMap=$(echo "tag -3r app.btsom.nts.L1BypassMap" | nc 0 15007 | grep -Eoi "0x.*")
    echo "L1BypassMap: "$L1BypassMap
}

function check_l1bypass_tag(){
    check_result=$(echo "tag -3r app.btsom.nts.L1BypassMap" | nc 0 15007)
    echo "***check l1bypass tag result: "$check_result
}

get_L1BypassMap
check_l1bypass_tag
delete_l1bypass_tag=$(echo "tag -fd app.btsom.nts.L1BypassMap" | nc 0 15007)
echo "***Excute delete l1bypass tag result: "$delete_l1bypass_tag
check_l1bypass_tag