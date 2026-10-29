*** Settings ***
Documentation
...    author: qingqing.zhang
...    contact: qingqing.zhang@nokia-sbell.com
...    squad group: SG_03
...    feature : CNI132544

Library     DateTime
Library     taf.analyzer.pcap    WITH NAME    cap
Library     taf.transport.ssh    WITH NAME    csn
Library     taf.hw.rf_attenuator    WITH NAME    atten
Library     taf.config.testline    WITH NAME    testline
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Classical_gNB.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Collect_logs.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Common_setup_and_teardown.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/UE.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/eNB.robot

*** Variables ***
#${ue_type}           ${tl.ues[0].capabilities[0]}
${connection_name}    GNB_OAM
${MRBTS_ID}                 ${tl.gnbs[0].instance_id}

####----PA----####
${vendor_34811}                     HBTE
${att_api_port_34811}               ${tl.attenuator[1].port}
${model_34811}                      ${tl.attenuator[1].model}
${att_ipaddr_34811}                 ${tl.attenuator[1].ip_addr}
${att_port_1_cell5_34811}    ${tl.gnbs[0].dus[0].rus[4].attenuation_ports[0].port_no}
${att_port_2_cell5_34811}    ${tl.gnbs[0].dus[0].rus[4].attenuation_ports[1].port_no}
${att_port_3_cell5_34811}    ${tl.gnbs[0].dus[0].rus[4].attenuation_ports[2].port_no}
${att_port_4_cell5_34811}    ${tl.gnbs[0].dus[0].rus[4].attenuation_ports[3].port_no}
*** Keywords ***
### SISO action###
block unblock needed cell action
    [Timeout]    2 hours
    [Arguments]    ${gnb_index}=${0}    ${cell_type_need}=all    ${action}=block    ${cell_index}=${1}
    Connect with BTS    gnb_index=${gnb_index}    connection=${connection_name}
    ${cell_list}=    Get cell list info
    ${cells_type}=    Get Dictionary Keys    ${cell_list}[cells]
    ${cells_info}=    Get Dictionary Values    ${cell_list}[cells]
    ${cells_type}    Set variable    ${cells_type}
#    ...    ELSE    Create List    ${cell_type_need}
    FOR    ${index}    ${cell_type}    IN ENUMERATE    @{cells_type}
        Run Keyword If    '${cell_type}' == '${cell_type_need}'
        ...    Run keywords    Set Suite Variable    ${cell_type_index_find}    ${index}     AND    Exit For Loop
    END
    ${Length}=    Get Length    ${cells_info}[${cell_type_index_find}]
    Run Keyword If    '${Length}' != '0' and '${action}'=='block'    Run keywords
    ...    block unblock needed cell
    ...    action=block    cells_info=${cell_list}[cells]    cell_type=${cell_type}    cell_index=${cell_index}
    ...    AND    Sleep    5s
    ...    ELSE IF    '${Length}' != '0' and '${action}'=='unblock'    Run keywords    block unblock needed cell
    ...    action=unblock    cells_info=${cell_list}[cells]   cell_type=${cell_type}    cell_index=${cell_index}
    ...    AND    Sleep    5s
    ...    ELSE    Continue For Loop
    [Teardown]    Disconnect With BTS    connection=${connection_name}

block unblock needed cell
    [Arguments]    ${action}    ${cells_info}    ${cell_type}    ${cell_index}
    ${cell_length}=    Get Length    ${cells_info}[${cell_type}]
    ${cell_dist_name_list}    Create List
    FOR    ${index}    IN RANGE    ${cell_length}
        Append To List    ${cell_dist_name_list}    ${cells_info}[${cell_type}][${index}][id][configuration]
    END
    FOR    ${index}    ${cell}    IN ENUMERATE    @{cell_dist_name_list}
        ${cell_serch}    Split String    ${cell}    /
        Run keyword IF
        ...    '${cell_serch}[-1]' == 'NRCELL-${cell_index}' or '${cell_serch}[-1]' == 'LNCEL-${cell_index}'
        ...    Run keywords    Set Suite Variable    ${cell_index_find}    ${index}    AND    Exit For Loop
    END
    IF    '${action}' == 'block'
        IF    '${cell_type}' == 'lte'
            IF    '${cells_info}[${cell_type}][${cell_index}][technology]' != 'NB-IoT-FDD'
                Block cell with BTS    dist_name=${cells_info}[${cell_type}][${cell_index_find}][id][configuration]
            END
        ELSE
            Block cell with BTS    dist_name=${cells_info}[${cell_type}][${cell_index_find}][id][configuration]
        END
    ELSE IF    '${action}' == 'unblock'
        IF    '${cell_type}' == 'lte'
            IF    '${cells_info}[${cell_type}][${cell_index}][technology]' != 'NB-IoT-FDD'
                Unblock cell with BTS    dist_name=${cells_info}[${cell_type}][${cell_index_find}][id][configuration]
            END
        ELSE
            Unblock cell with BTS    dist_name=${cells_info}[${cell_type}][${cell_index_find}][id][configuration]
        END
    END

lock unlock needed RU action
    [Timeout]    2 hours
    [Arguments]    ${gnb_index}=${0}    ${RMOD_index}=${1}    ${action}=lock
    Connect with BTS    gnb_index=${gnb_index}    connection=${connection_name}
    ${bts_info}=    Get info with BTS
    ${radioModules}    set variable    ${bts_info}[radioModules][rmod]
    ${RMOD_length}=    Get Length    ${radioModules}
    ${RMOD_dist_name_list}    Create List
    FOR    ${index}    IN RANGE    ${RMOD_length}
        Append To List    ${RMOD_dist_name_list}    ${bts_info}[radioModules][rmod][${index}][id][configuration]
    END
    FOR    ${index}    ${RMOD}    IN ENUMERATE    @{RMOD_dist_name_list}
        ${RMOD_serch}    Split String    ${RMOD}    /
        Run keyword IF    '${RMOD_serch}[-1]' == 'RMOD-${RMOD_index}'
        ...    Run keywords    Set Suite Variable    ${RMOD_index_find}    ${index}    AND    Exit For Loop
    END
    IF    '${action}'=='lock'
        Lock required dist_name with BTS
        ...    dist_name=${bts_info}[radioModules][rmod][${RMOD_index_find}][id][configuration]    connection=${connection_name}
    ELSE IF    '${action}'=='unlock'
        Unlock required dist_name with BTS
        ...    dist_name=${bts_info}[radioModules][rmod][${RMOD_index_find}][id][configuration]    connection=${connection_name}
    END
    [Teardown]    Disconnect With BTS    connection=${connection_name}

reset needed RMOD action
    [Arguments]    ${reset_type}=hard    ${gnb_index}=${0}    ${force_radio_reset}=${True}    ${RMOD_index}=${1}
    ...    ${need_reset}=true
    Connect with BTS    gnb_index=${gnb_index}    connection=${connection_name}
    ${bts_info}=    Get info with BTS
    ${radioModules}    set variable    ${bts_info}[radioModules][rmod]
    ${RMOD_length}=    Get Length    ${radioModules}
    ${RMOD_dist_name_list}    Create List
    FOR    ${index}    IN RANGE    ${RMOD_length}
        Append To List    ${RMOD_dist_name_list}    ${bts_info}[radioModules][rmod][${index}][id][configuration]
    END
    FOR    ${index}    ${RMOD}    IN ENUMERATE    @{RMOD_dist_name_list}
        ${RMOD_serch}    Split String    ${RMOD}    /
        Run keyword IF    '${RMOD_serch}[-1]' == 'RMOD-${RMOD_index}'
        ...    Run keywords    Set Suite Variable    ${RMOD_index_find}    ${index}    AND    Exit For Loop
    END
    Run keyword If    '${need_reset}'=='true'
    ...    Run keywords    Reset Unit with BTS    dist_name=${bts_info}[radioModules][rmod][${RMOD_index_find}][id][runtime]
    ...    reset_type=${reset_type}    connection=${connection_name}    force_radio_reset=${force_radio_reset}
    ...    AND    sleep    30s
    Wait Until Keyword Succeeds    10min    10s    Check needed radioModule status    RMOD_index=${RMOD_index_find}
    [Teardown]    Disconnect With BTS    connection=${connection_name}

Check needed radioModule status
    [Arguments]    ${connection}=GNB_OAM    ${RMOD_index}=${1}
    ${sw_version}     coam.get_sw_version    connection=${connection}
    ${result}    run keyword and return status    should contain any
    ...    ${sw_version}
    ...    12.400    14.400    22R1    22R2    21B
    ${unlocked}    Set Variable If    ${result}    Unlocked    Unlocked
    ${enabled}    Set Variable If    ${result}    Enabled    enabled
    ${detected_info}    coam.get_detected_hw_info    connection=${connection}
    Set Suite Variable    ${detected_info}
    @{list_radioModules}    Set variable    ${detected_info['radioModules']['rmod']}
    Run keyword and continue on failure
    ...    Should be equal as strings    ${list_radioModules[${RMOD_index}]['status']['administrativeState']}    ${unlocked}
    ...    msg=Current radioModule administrativeState is not in Unlocked status
    Run keyword and continue on failure
    ...    Should be equal as strings    ${list_radioModules[${RMOD_index}]['status']['operationalState']}    ${enabled}
    ...    msg=Current radioModule operationalState is not in enabled status
    Run keyword and continue on failure
    ...    Should be equal as strings    ${list_radioModules[${RMOD_index}]['status']['proceduralStatus']}    configured
    ...    msg=Current radioModule proceduralStatus is not in configured status

Adjust the HBTE attenuation value
    [Arguments]     ${tl}=${MRBTS_ID}    ${gnb_cell5_value}=${0}

    ####create cell list#####
    @{att_ports_gnb_cell5}    Create List    ${att_port_1_cell5_${tl}}      ${att_port_2_cell5_${tl}}
    ...        ${att_port_3_cell5_${tl}}      ${att_port_4_cell5_${tl}}
    ###create value list####
    @{values_gnb_cell5}    Create List    ${gnb_cell5_value}    ${gnb_cell5_value}
    ...    ${gnb_cell5_value}    ${gnb_cell5_value}
    ###Adjust the HBTE attenuation value###
    Set the attenuation value    att_api_port=${att_api_port_${tl}}    vendor=${vendor_${tl}}
    ...    att_ports=${att_ports_gnb_cell5}    values=${values_gnb_cell5}
    ...    att_connection_port=${att_port_1_cell5_${tl}}    att_ipaddr=${att_ipaddr_${tl}}    model=${model_${tl}}