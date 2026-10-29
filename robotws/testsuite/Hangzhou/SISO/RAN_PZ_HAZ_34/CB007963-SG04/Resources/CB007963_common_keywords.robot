*** Settings ***
Documentation    This suite contains common keywords for CB007963
...    Author: Shifu Lan
...    contact:shifu.lan@nokia-sbell.com
...    squad group:VRF_HAZ4_SG04
Library    ./nokia_tps1830.py
Library    taf.sbts.oam.coam.admin   WITH NAME    coam
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/operate_cell_and_check.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/nr_feature_on.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/recommissioning_and_make_throughput.robot
Variables   testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/libraries/global_vars.py
Variables   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/made_variable.py

*** Variables ***
${PLACEHOLDER}    placeholder_value

*** Keywords ***
Switch Current Best ToP Master With L3CALL Check Alarm
    [Arguments]  ${with_call}=${True}  ${with_peak}=${False}  ${duration}=${60}  ${ue_num_each_call}=1
    Selenium Login And Disable Screen Lock
    Activate Single TOP Master Via Webem    localPriority=128    ruECpriPortNumber=1    topMasterId=1

    ${cell_list}    get all cell id    ru_index=1
    run keyword if    ${with_call}    Get UE From Init File and Make call    cell_list=${cell_list}
    ...    with_peak=${with_peak}    duration=${duration}    ue_num_each_call=${ue_num_each_call}

    # Modify TOP Master To Not Exist RRU Port And Rollback    wrong_rru_port=4    right_rru_port=1    localPriority=128    topMasterId=1
    Activate And Switch Multiple TOP Master During L3 Call
    [Teardown]  Selenium Logout And Close Browser

Activate Single TOP Master Via Webem
    [Arguments]  ${localPriority}=128  ${ruECpriPortNumber}=1    ${topMasterId}=1
    Modify TOP Master Parameters    localPriority=${localPriority}    ruECpriPortNumber=${ruECpriPortNumber}    topMasterId=${topMasterId}
    Wait Until Keyword Succeeds    10min    30s    Check all cells info should be onair
    ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
    should be true    ${alarm_status}

    ${top_master_port_number} =    Get topMasterPortNumber from topMasterUsed    nodes=1
    Disable Switch Port Ptp Clock Synchronization    port=${top_master_port_number}
    Wait Until Keyword Succeeds    2min    10s    Expect Fault Should Present    faultId=61631    alarmId=7115
    Wait Until Keyword Succeeds    2min    10s    Expect Fault Should Absent    faultId=61631
    Wait Until Keyword Succeeds    2min    20s    Expect Fault Should Present    faultId=4298    alarmId=7108
    Wait Until Keyword Succeeds    2min    20s    Expect Fault Should Present    faultId=16    alarmId=7116
    Enable Switch Port Ptp Clock Synchronization    port=${top_master_port_number}
    Wait Until Keyword Succeeds    10min    30s    Check all cells info should be onair
    ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
    should be true    ${alarm_status}
    [Teardown]  Enable Switch Port Ptp Clock Synchronization    port=${top_master_port_number}

Modify TOP Master To Not Exist RRU Port And Rollback
    [Arguments]  ${wrong_rru_port}  ${right_rru_port}=1  ${localPriority}=128  ${topMasterId}=1
    Modify TOP Master Parameters    localPriority=${localPriority}    ruECpriPortNumber=${wrong_rru_port}    topMasterId=${topMasterId}
    Wait Until Keyword Succeeds    2min    10s    Expect Fault Should Present    faultId=61631    alarmId=7115
    Wait Until Keyword Succeeds    2min    10s    Expect Fault Should Absent    faultId=61631
    Wait Until Keyword Succeeds    2min    20s    Expect Fault Should Present    faultId=4298    alarmId=7108
    Wait Until Keyword Succeeds    2min    20s    Expect Fault Should Present    faultId=16    alarmId=7116
    Modify TOP Master Parameters    localPriority=${localPriority}    ruECpriPortNumber=${right_rru_port}    topMasterId=${topMasterId}
    Wait Until Keyword Succeeds    10min    30s    Check all cells info should be onair
    ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
    should be true    ${alarm_status}

Activate And Switch Multiple TOP Master During L3 Call
    [Arguments]  ${suite_name}=default    ${test_name}=default
    ${check_cell}    Get Ues Attached Cell    ue_num_each_call=1
    ${cell_list}    create list    ${check_cell}
    ${ue_index_list}    ${cell_list}    Get UE List for Given Cell List    cell_list=${cell_list}    ue_num_each_call=1
    ${cell_and_peak_info}    generate peak information     cell_list=${cell_list}    duration=900
    ...    suite_name=${suite_name}    test_name=${test_name}
    ${ue_and_cell}    Ue Attach and Start DL UL Traffic    ue_index_list=${ue_index_list}    cell_and_peak_info=${cell_and_peak_info}
    UE Verify Peak Throughput    ue_index_list=${ue_index_list}    ue_and_cell=${ue_and_cell}    cell_and_peak_info=${cell_and_peak_info}
    ...    duration=${30}
    Activate Multiple TOP Master Via Webem
    Switch TOP Master To Slave

    UE Verify Peak Throughput    ue_index_list=${ue_index_list}    ue_and_cell=${ue_and_cell}    cell_and_peak_info=${cell_and_peak_info}
    ...    duration=${30}
    Ue Stop DL UL Traffic and Detach    ue_index_list=${ue_index_list}

Activate Multiple TOP Master Via Webem
    log to console     \n***Activate Multiple TOP Master***
    ${dist_name}    Set Variable    MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1/TOPP-1
    FOR    ${index}    IN RANGE    1    3
        ${ruECpriPortNumber} =    Evaluate    ${index} + ${1}
        selenium_coam.add_element    dist_name=${dist_name}
        ...    filter_param=Timing over Packet master properties list    abbr=topMasterList    timeout=15
        selenium_coam.set_parameter_value    dist_name=${dist_name}    filter_param=Local priority of slave port towards ToP master
        ...    abbr=localPriority    new_value=128    node_index=${index}
        selenium_coam.set_parameter_value    dist_name=${dist_name}    filter_param=RU eCPRI port Number
        ...    abbr=ruECpriPortNumber    new_value=${ruECpriPortNumber}    node_index=${index}
        selenium_coam.set_parameter_value    dist_name=${dist_name}    filter_param=Top Master identifier
        ...    abbr=topMasterId    new_value=${ruECpriPortNumber}    node_index=${index}
    END
    selenium_coam.validate_plan
    run keyword and ignore error    selenium_coam.activate_plan    activate_plan_despite_errors=${False}    timeout=360
    Wait Until Keyword Succeeds    10min    30s    Check all cells info should be onair
    ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
    should be true    ${alarm_status}

Switch TOP Master To Slave
    log to console     \n***Switch TOP Master***
    ${top_master_port_number} =    Get topMasterPortNumber from topMasterUsed    nodes=3
    Disable Switch Port Ptp Clock Synchronization    port=${top_master_port_number}
    Wait Until Keyword Succeeds    10min    30s    Check all cells info should be onair
    Wait Until Keyword Succeeds    2min    10s    Expect Fault Should Present    faultId=61631    alarmId=7115
    Enable Switch Port Ptp Clock Synchronization    port=${top_master_port_number}
    Wait Until Keyword Succeeds    10min    30s    Check all cells info should be onair
    Wait Until Keyword Succeeds    2min    10s    Expect Fault Should Absent    faultId=61631
    ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
    should be true    ${alarm_status}
    [Teardown]  Enable Switch Port Ptp Clock Synchronization    port=${top_master_port_number}

Disable Switch Port Ptp Clock Synchronization
    [Arguments]  ${port}
    log to console     \n***Disable Switch Port Ptp Clock Synchronization***
    connect_to_switch    hostname=${switch_addr}    username=${switch_username}    password=${switch_password}    alias=nokia_tps1830
    ${result} =    config_port_sync_down    port=${port}
    Should Not Be True    ${result}

Enable Switch Port Ptp Clock Synchronization
    [Arguments]  ${port}
    log to console     \n***Enable Switch Port Ptp Clock Synchronization***
    connect_to_switch    hostname=${switch_addr}    username=${switch_username}    password=${switch_password}    alias=nokia_tps1830
    ${result} =    config_port_sync_up    port=${port}
    Should Be True    ${result}

Modify TOP Master Parameters
    [Arguments]  ${localPriority}=128  ${ruECpriPortNumber}=1    ${topMasterId}=1
    log to console    \n***Modify the TOP Master Parameters***
    ${modify_params}  create list
    ${dist_name}    Set Variable    MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1/TOPP-1

    ${item}    create dictionary    dist_name=${dist_name}    filter_param=Local priority of slave port towards ToP master
    ...    p_name=localPriority    value=${localPriority}
	append to list    ${modify_params}    ${item}
    ${item}    create dictionary    dist_name=${dist_name}    filter_param=RU eCPRI port Number
    ...    p_name=ruECpriPortNumber    value=${ruECpriPortNumber}
	append to list    ${modify_params}    ${item}
    ${item}    create dictionary    dist_name=${dist_name}    filter_param=Top Master identifier
    ...    p_name=topMasterId    value=${topMasterId}
	append to list    ${modify_params}    ${item}
    Modify Parameters On Webem    modify_params=${modify_params}

Get topMasterPortNumber from topMasterUsed
    [Arguments]  ${nodes}
    [Documentation]  There are 3 SFP links between BTS RRU and NokiaTPS1830 Switch, port mapping as below.
    ...    portIndex=18    assPort=1/4/C20    rru port1
    ...    portIndex=23    assPort=1/4/C22    rru port2
    ...    portIndex=27    assPort=1/4/C24    rru port3
    log to console    \n***Get the used TOP Master Parameter***
    ${dist_name}    Set Variable    MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1/TOPP-1/TOPP_R-1
    FOR    ${index}    IN RANGE    ${nodes}
        ${value} =    selenium_coam.get_parameter_value    dist_name=${dist_name}    filter_param=ToP master used    node_index=${index}
        Continue For Loop If    "${value}"!="used"
        ${topMasterPortNumber} =  selenium_coam.get_parameter_value    dist_name=${dist_name}    filter_param=Timing over Packet master port number
        ...    node_index=${index}
    END
    [Return]    ${topMasterPortNumber}