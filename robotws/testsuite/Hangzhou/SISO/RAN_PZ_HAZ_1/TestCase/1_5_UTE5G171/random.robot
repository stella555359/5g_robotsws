*** Settings ***
Library    ./utilities.py

Resource    ../../resources/bts_common_interface.robot

*** Variables ***
@{RANDOM_ACTIONS}    Random Lock RRU
...                  Random Unlock RRU
...                  Random Reset BBMOD
...                  Random Block Cell
...                  Random Unblock Cell
...                  Random Make Tput
...                  Random Save Snapshot
...                  Random Check RFSW logs In BTS Snapshot
...                  Random Online Commission

*** Keywords ***
Random Setup
    ${logger}    start_logging    ${TEST_LOGS_DIR_PATH}/step.txt
    Set Test Variable    ${LOGGER}
    ${scf_file}    Set Variable    ${NODE_CFG["${MASTER_BTS_ID}"]["scf_file_path"]}
    ${smod_product_name}    Get SMOD Product Name    ${scf_file}
    Run Keyword If    "ASOE" in "${smod_product_name}"    Remove Values From List    ${RANDOM_ACTIONS}    Random Reset BBMOD

Get RRU With Specific Status
    [Arguments]    &{kwargs}
    ${bts_info}    coam.get_bts_info     connection=${CASE_NAME}_${MASTER_BTS_ID}
    ${ru_list}    Set Variable    ${bts_info["radioModules"]["rmod"]}
    ${specific_ru_list}   get_specific_resource_list    ${ru_list}    &{kwargs}
    [Return]    ${specific_ru_list}

Get RRU Status
    ${bts_info}    coam.get_bts_info     connection=${CASE_NAME}_${MASTER_BTS_ID}
    ${ru_list}    Set Variable    ${bts_info["radioModules"]["rmod"]}
    [Return]    ${ru_list}

Get Cell Status
    ${cell_list}    coam.get_cell_list    connection=${CASE_NAME}_${MASTER_BTS_ID}
    ${cell_list}    Evaluate  ${cell_list["cells"]["lte"]}+${cell_list["cells"]["nr"]}+${cell_list["cells"]["wcdma"]}+${cell_list["cells"]["gsm"]}
    [Return]     ${cell_list}

Get And Compare RRU Status
    [Arguments]    ${ru_before}    ${apart}=${None}
    ${ru_after}    Get RRU Status
    compare_ru_status    ${ru_before}    ${ru_after}    apart=${apart}

Get And Compare Cell Status
    [Arguments]    ${cell_before}    ${apart}=${None}
    ${cell_after}    random.Get Cell Status
    compare_cell_status     ${cell_before}    ${cell_after}    apart=${apart}

Get Cell With Specific Status
    [Arguments]    &{kwargs}
    ${cell_list}    coam.get_cell_list    connection=${CASE_NAME}_${MASTER_BTS_ID}
    ${cell_list}    Evaluate  ${cell_list["cells"]["lte"]}+${cell_list["cells"]["nr"]}+${cell_list["cells"]["wcdma"]}+${cell_list["cells"]["gsm"]}
    ${specific_cell_list}   get_specific_resource_list    ${cell_list}    &{kwargs}
    [Return]    ${specific_cell_list}

Get Available Cell List
    ${available_cell_list}    Get Cell With Specific Status    administrativeState=Unlocked    operationalState=enabled   blockingState=Unblocked
    ${cell_list}    Create List
    FOR    ${cell_info}    IN    @{available_cell_list}
        ${m_cell_info}    Get Cell Info With PCI    ${ALL_CELL_LIST}    ${cell_info["physicalCellId"]}
        Append To List    ${cell_list}    ${m_cell_info}
    END
    [Return]    ${cell_list}

Lock RRU
    [Arguments]    ${fr_sn}    ${bts_id}=${MASTER_BTS_ID}
    ${connection_id}    Set Variable   ${CASE_NAME}_${bts_id}
    ${rmod_distname}    Get R Object Distname By SN    class_name=RMOD_R    sn=${fr_sn}    connection=${connection_id}
    ${ru_before}    Get RRU Status
    coam.lock    dist_name=${rmod_distname}    connection=${connection_id}    timeout=180
    RU Should Be Locked With Admin    distName=${rmod_distname}    connection=${connection_id}
    Get And Compare RRU Status    ${ru_before}   apart=${fr_sn}

Random Lock RRU
    ${unlock_ru_list}    Get RRU With Specific Status    administrativeState=Unlocked
    ${ru_num}    Get Length    ${unlock_ru_list}
#    ${status}    Run Keyword And Return Status    Should Be Empty    ${unlock_ru_list}
    Return From Keyword If    ${ru_num}==${0}
    ${ru_info}    Evaluate    random.choice(${unlock_ru_list})    modules=random
#    Log to console    Lock RRU ${ru_info["serialNumber"]}
    logging_info    Lock RRU:${ru_info["serialNumber"]}
    Lock RRU    ${ru_info["serialNumber"]}    ${MASTER_BTS_ID}
    Run Keyword If    "Random Unlock RRU" not in "${RANDOM_ACTIONS}"
    ...    Append To List    ${RANDOM_ACTIONS}    Random Unlock RRU
    Run Keyword If    ${ru_num}==${1}    Remove Values From List    ${RANDOM_ACTIONS}     Random Lock RRU
    ${available_cell_list}    Get Available Cell List
    ${status}    Run Keyword And Return Status     Should Be Empty    ${available_cell_list}
    Run Keyword If    ${status} and "Random Make Tput" in "${RANDOM_ACTIONS}"    Remove Values From List
    ...    ${RANDOM_ACTIONS}     Random Make Tput

Unlock RRU
    [Arguments]    ${fr_sn}    ${bts_id}=${MASTER_BTS_ID}
    ${connection_id}    Set Variable   ${CASE_NAME}_${bts_id}
    ${rmod_distname}    Get R Object Distname By SN    class_name=RMOD_R    sn=${fr_sn}    connection=${connection_id}
    ${ru_before}    Get RRU Status
    coam.unlock    dist_name=${rmod_distname}    connection=${connection_id}    timeout=180
    RU Should Be Unlocked With Admin    distName=${rmod_distname}    connection=${connection_id}
    sleep    30 sec
    Get And Compare RRU Status    ${ru_before}    apart=${fr_sn}

Random Unlock RRU
    ${lock_ru_list}    Get RRU With Specific Status    administrativeState=Locked
    ${ru_num}    Get Length    ${lock_ru_list}
    Return From Keyword If    ${ru_num}==${0}
#    ${status}    Run Keyword And Return Status    Should Be Empty    ${lock_ru_list}
#    Return From Keyword If    ${status}
    ${ru_info}    Evaluate    random.choice(${lock_ru_list})    modules=random
#    Log to console    Unlock RRU ${ru_info["serialNumber"]}
    logging_info    Unlock RRU:${ru_info["serialNumber"]}
    Unlock RRU    ${ru_info["serialNumber"]}    ${MASTER_BTS_ID}
    Run Keyword If    "Random Lock RRU" not in "${RANDOM_ACTIONS}"
    ...    Append To List    ${RANDOM_ACTIONS}    Random Lock RRU
    Run Keyword If    ${ru_num}==${1}    Remove Values From List    ${RANDOM_ACTIONS}     Random Unlock RRU
    ${available_cell_list}    Get Available Cell List
    ${status}    Run Keyword And Return Status     Should Not Be Empty    ${available_cell_list}
    Run Keyword If    ${status} and "Random Make Tput" not in "${RANDOM_ACTIONS}"
    ...   Append To List    ${RANDOM_ACTIONS}     Random Make Tput

Unlock RRU All
    ${lock_ru_list}    Get RRU With Specific Status    administrativeState=Locked
    FOR    ${ru_info}    IN    @{lock_ru_list}
        Unlock RRU    ${ru_info["serialNumber"]}    ${MASTER_BTS_ID}
    END

Reset BBMOD
    [Arguments]    ${bbmod_sn}    ${bts_id}=${MASTER_BTS_ID}
    ${available_cell_list}    Get Available Cell List
    ${connection_id}    Set Variable   ${CASE_NAME}_${bts_id}
    ${bbmod_distname}    Get R Object Distname By SN    BBMOD_R    ${bbmod_sn}    ${connection_id}
    ${ru_before}    Get RRU Status
    ${cell_before}    random.Get Cell Status
    coam.reset_unit    dist_name=${bbmod_distname}    reset_type=Warm
    ...    force_radio_reset=${True}    timeout=300    connection=${connection_id}
    Wait Until Keyword Succeeds    ${ONAIR_TIME}    10 sec    Get And Compare RRU Status    ${ru_before}
    Wait Until Keyword Succeeds    ${ONAIR_TIME}    10 sec    Get And Compare Cell Status    ${cell_before}
    Wait Until Keyword Succeeds    ${ONAIR_TIME}    30 sec    Verify All Cells OnAir    check_cell_list=${available_cell_list}

Random Reset BBMOD
    ${loop}    Evaluate    random.randint(1,2)    modules=random
    FOR    ${i}   IN RANGE    ${loop}
        ${bbmod_sn_list}    Set Variable    ${NODE_CFG["${MASTER_BTS_ID}"]["bbmod_sn_list"]}
        ${bbmod_sn}    Evaluate    random.choice(${bbmod_sn_list})    modules=random
        logging_info    Reset BBMOD:${bbmod_sn}
        Reset BBMOD    ${bbmod_sn}    ${MASTER_BTS_ID}
    END

Cell Block
    [Arguments]    ${pci}    ${timeout}=20s
    ${cell_info}    Get Cell Info With PCI    ${ALL_CELL_LIST}    ${pci}
    ${connection_id}    Set Variable   ${CASE_NAME}_${cell_info["btsId"]}
    ${R_class_name}   Get R CELL Class Name   ${cell_info}
    ${cell_distname}    Get R Object Distname    class_name=${R_class_name}
    ...     id=${cell_info["cellId"]}    connection=${connection_id}
    coam.Block Cell    dist_name=${cell_distname}    timeout=${timeout}
    ...    connection=${connection_id}

    ${cell_R_info}    coam.Get Cell Specific Info    cell_id=${cell_info["distName"]}    connection=${connection_id}
    Should Be Equal As Strings  ${cell_R_info["status"]["blockingState"]}  Blocked

    ${alarms}   coam.assert_alarm_active
    ...    parameters=faultId=49,severity=Critical,alarmingResource=${cell_distname}
    ...     connection=${connection_id}

Random Block Cell
    ${unblocked_cell_list}    Get Cell With Specific Status    blockingState=Unblocked
    ${cell_num}    Get Length    ${unblocked_cell_list}
    Return From Keyword If    ${cell_num}==${0}
#    ${status}    Run Keyword And Return Status    Should Be Empty    ${unblocked_cell_list}
#    Return From Keyword If    ${status}
    ${cell_info}    Evaluate    random.choice(${unblocked_cell_list})    modules=random
    logging_info    Cell Block:${cell_info["physicalCellId"]}
#    Log to console    Block cell ${cell_info["physicalCellId"]}
    Cell Block    ${cell_info["physicalCellId"]}
    Run Keyword If    "Random Unblock Cell" not in "${RANDOM_ACTIONS}"
    ...    Append To List    ${RANDOM_ACTIONS}    Random Unblock Cell
    Run Keyword If    ${cell_num}==${1}    Remove Values From List    ${RANDOM_ACTIONS}    Random Block Cell
    ${available_cell_list}    Get Available Cell List
    ${status}    Run Keyword And Return Status     Should Be Empty    ${available_cell_list}
    Run Keyword If    ${status} and "Random Make Tput" in "${RANDOM_ACTIONS}"    Remove Values From List
    ...    ${RANDOM_ACTIONS}     Random Make Tput

Cell Unblock
    [Arguments]    ${pci}    ${timeout}=20s
    ${cell_info}    Get Cell Info With PCI    ${ALL_CELL_LIST}    ${pci}
    ${connection_id}    Set Variable   ${CASE_NAME}_${cell_info["btsId"]}
    ${R_class_name}   Get R CELL Class Name   ${cell_info}
    ${cell_distname}    Get R Object Distname    class_name=${R_class_name}
    ...     id=${cell_info["cellId"]}    connection=${connection_id}     connection=${connection_id}
    coam.Unblock Cell    dist_name=${cell_distname}    timeout=${timeout}
    ...    connection=${connection_id}
    Sleep    5 sec

    ${cell_R_info}    coam.Get Cell Specific Info    cell_id=${cell_info["distName"]}    connection=${connection_id}
    Should Be Equal As Strings  ${cell_R_info["status"]["blockingState"]}  Unblocked

    coam.assert_alarm_inactive
    ...    parameters=faultId=49,severity=Critical,alarmingResource=${cell_distname}
    ...    connection=${connection_id}

Random Unblock Cell
    ${blocked_cell_list}    Get Cell With Specific Status    blockingState=Blocked
    ${cell_num}    Get Length    ${blocked_cell_list}
    Return From Keyword If    ${cell_num}==${0}
    ${cell_info}    Evaluate    random.choice(${blocked_cell_list})   modules=random
#    ${m_cell_info}    Get Cell Info With PCI    ${ALL_CELL_LIST}    ${cell_info["physicalCellId"]}
    logging_info    Cell Unblock:${cell_info["physicalCellId"]}
#    Log to console    Unblock cell ${cell_info["physicalCellId"]}
    Cell Unblock    ${cell_info["physicalCellId"]}
    Run Keyword If    "Random Block Cell" not in "${RANDOM_ACTIONS}"
    ...    Append To List    ${RANDOM_ACTIONS}    Random Block Cell
    Run Keyword If    ${cell_num}==${1}    Remove Values From List    ${RANDOM_ACTIONS}    Random Unblock Cell
    ${available_cell_list}    Get Available Cell List
    ${status}    Run Keyword And Return Status     Should Not Be Empty    ${available_cell_list}
    Run Keyword If    ${status} and "Random Make Tput" not in "${RANDOM_ACTIONS}"
    ...   Append To List    ${RANDOM_ACTIONS}     Random Make Tput

Unblock Cell All
    ${blocked_cell_list}    Get Cell With Specific Status    blockingState=Blocked
    FOR    ${cell_info}    IN    @{blocked_cell_list}
        ${m_cell_info}    Get Cell Info With PCI    ${ALL_CELL_LIST}    ${cell_info["physicalCellId"]}
        Unblock Cell    ${m_cell_info}
    END

Get Avaliable Required Cells
    [Arguments]    ${available_cell_list}   ${required_cells}
    ${cell_list}    Split String    ${required_cells}    :
    ${aval_cells}    Create List
    FOR   ${pci}   IN    @{cell_list}
        ${status}    Run Keyword And Return Status    Get Cell Info With PCI    ${available_cell_list}    ${pci}
        Run Keyword If    ${status}    Append To List    ${aval_cells}    ${pci}
    END
    ${req_cells}     Catenate    SEPARATOR=:    @{aval_cells}
    [Return]    ${req_cells}

Random Make Tput
    ${tmp_cell_list}    Set Variable    ${ALL_CELL_LIST}
    ${available_cell_list}    Get Available Cell List
    Set Test Variable    ${ALL_CELL_LIST}    ${available_cell_list}
    ${req_cells}    Get Avaliable Required Cells    ${available_cell_list}    ${REQUIRED_CELLS}
    ${status}    Run Keyword And Return Status    Should Be Empty    ${req_cells}
    Run Keyword If    ${status}    Set Test Variable    ${ALL_CELL_LIST}    ${tmp_cell_list}
    Return From Keyword If    ${status}
    logging_info    Random Make Tput
#    Log to console    Make Tput
    Askey Power Reset
    Make Tput    cell_list=${available_cell_list}    required_cells=${req_cells}
    Set Test Variable    ${ALL_CELL_LIST}    ${tmp_cell_list}

Random Save Snapshot
    Log to console    Save Snapshot
    Logging Save Snapshot    ${TEST_LOGS_DIR_PATH}    alias=${CASE_NAME}_${MASTER_BTS_ID}

Random Check RFSW logs In BTS Snapshot
    logging_info    Random Check RFSW logs In BTS Snapshot
#    Log to console    Random Check RFSW logs In BTS Snapshot
    Check_RFSW_logs_In_BTS_Snapshot    ${MASTER_BTS_ID}

Random Online Commission
#    Log to console    Random Online Commission
    ${ONLINE_PARAMETERS}     Evaluate    ${ONLINE_PARAMETERS}
    ${parameter}    Evaluate    random.choice(${ONLINE_PARAMETERS})    modules=random
    logging_info    Online Commission:${parameter}
    Online Commission    ${parameter}

Online Commission
    [Arguments]    ${parameter}
    ${available_cell_list}    Get Available Cell List
    ${type}    Evaluate    type(${parameter}).__name__
    ${paramter}    Run Keyword If    "${type}"=="str"    Evaluate    ${parameter}
    ...    ELSE    Set Variable    ${parameter}
    ${set_value}    Random Get Parameter Value    ${parameter}
    coam.Create delta
    coam.Append parameter update to delta    ${parameter['distName']}    ${parameter['paraName']}    ${set_value}
    ${delta_update}=    coam.Get delta
    coam.Perform delta recommissioning    ${delta_update}    skip_parameter_relation_errors=True
    ...    connection=${CASE_NAME}_${MASTER_BTS_ID}
    Wait Until Keyword Succeeds    ${ONAIR_TIME}    30 sec    Verify All Cells OnAir    check_cell_list=${available_cell_list}
    ${value}    Get Parameter Value From Scfc    ${parameter}
    Should Be Equal    ${set_value}    ${value}
    [Teardown]    coam.Remove delta

Get Parameter Value From Scfc
    [Arguments]    ${parameter}    ${bts_id}=${MASTER_BTS_ID}
    ${current_scfc}    Get Current Scfc    ${bts_id}
    ${value}    Get Element Text   ${current_scfc}
    ...    xpath=//managedObject[@distName='${parameter['distName']}']/p[@name="${parameter['paraName']}"]
    [Return]    ${value}

Random Get Parameter Value
    [Arguments]    ${parameter}    ${bts_id}=${MASTER_BTS_ID}
    ${current_value}    Get Parameter Value From Scfc     ${parameter}    bts_id=${bts_id}
    ${all_values}    Set Variable    ${parameter['paraValue']}
    Remove Values From List    ${all_values}    ${current_value}
    ${set_value}    Evaluate    random.choice(${all_values})    modules=random
    [Return]    ${set_value}

Random Test Keyword
    ${loop}    Evaluate    random.randint(50, 51)    modules=random
    FOR    ${i}    IN RANGE    ${loop}
        ${test_keyword}    Evaluate    random.choice(${RANDOM_ACTIONS})    modules=random
        Run Keyword    ${test_keyword}
    END
    [Teardown]    Run Keywords    Unlock RRU All
    ...    AND    Unblock Cell All
    ...    AND    Wait For All Cells OnAir    timeout=${ONAIR_TIME}

Execute Specific Random Steps
    [Arguments]    ${steps_txt}
    ${logger}    start_logging    ${TEST_LOGS_DIR_PATH}/step.txt
    Set Test Variable    ${LOGGER}
    ${step_content}    OperatingSystem.Get File    ${steps_txt}
    ${step_content}    Strip String    ${step_content}    characters=\n
    ${steps_list}    Split String    ${step_content}    \n
    FOR    ${step}    IN    @{steps_list}
        ${shot_status}    Run Keyword And Return Status    Should Start With    ${step}    \#
        Continue For Loop If    ${shot_status}
        ${keyword_name}    @{paramter}    Split String    ${step}    :    1
        ${status}    Run Keyword And Return Status    Should Be Empty    ${paramter}
        Run Keyword If    ${status}    Run Keyword    ${keyword_name}
        ...    ELSE    Run Keyword    ${keyword_name}    ${paramter[0]}
    END
    [Teardown]    Run Keywords    Unlock RRU All
    ...    AND    Unblock Cell All
    ...    AND    Wait For All Cells OnAir    timeout=${ONAIR_TIME}
