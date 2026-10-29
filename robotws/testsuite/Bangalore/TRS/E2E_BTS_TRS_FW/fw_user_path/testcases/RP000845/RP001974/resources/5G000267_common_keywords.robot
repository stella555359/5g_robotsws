*** Settings ***
Documentation
...        [Feature_ID]       "5G000267"

Variables       ta_e2e_bts_trs_fw
Resource        ${CURDIR}/../../../resources/common_keywords.robot
Resource        ${CURDIR}/../../../resources/Admin_Common_Library.robot

***Keywords***
Verify IPSEC Security Association on eNB
    [Arguments]     ${policy}=${Primary_policy}       ${Enb_IP}=192.168.255.129
    FOR    ${i}    IN      @{policy}
        Execute command on ENodeB       ipsec status | grep conn${i}        ${Enb_IP}
        Should Match Regexp     ${stdout}   .*ESTABLISHED.*
        Should Match Regexp     ${stdout}   .*INSTALLED.*
     END

Verify BU_State
    [Documentation]        This keyword checks for the backup ipsec status
    [Arguments]         ${backup_state}

    @{parent_tunnel_moc_list} =  Query Admin Infomodel  query=get list ${ikeprotgrp_read_moc_path}
    FOR  ${ike_tunnel}  IN  @{parent_tunnel_moc_list}
        Log     ${ike_tunnel}
        ${output}=  Get From Dictionary     dictionary=${ike_tunnel}  key=ikeProtState
        Log     ${output}
        Should Match Regexp    string=${output}    pattern=${backup_state}
        END