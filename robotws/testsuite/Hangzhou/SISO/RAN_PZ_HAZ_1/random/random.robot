*** Settings ***
Documentation
...    Author:        amy.wu@nokia-sbell.com
...    Maintainer:    Wu Amy

Library    ./utilities.py

Resource    ../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/bts_common_interface.robot

*** Variables ***
@{RANDOM_ACTIONS}    Random Lock RRU
...                  Random Reset BBMOD
...                  Random Block Cell
...                  Random Make Tput
...                  Random Check RFSW logs In BTS Snapshot
...                  Random Reset RU
...                  Random Online Commission
...                  Random Power Off RU
...                  Random RAT Reset
...                  Random Remove Fiber

*** Keywords ***
Random Setup
    ${logger}    start_logging    ${TEST_LOGS_DIR_PATH}/step.txt
    Set Test Variable    ${LOGGER}
    ${unlinkmap}    Create Dictionary
    Set Suite Variable    ${UNLINKMAP}    ${unlinkmap}
    ${status}    Run Keyword And Return Status    Variable Should Exist    ${GGMAP}
    ${GGMAP}    Run keyword If    ${status}    Evaluate    ${GGMAP}
    Set Test Variable    ${GGMAP}
    Run Keyword If    not ${status}    Remove Values From List    ${RANDOM_ACTIONS}
    ...    Random Remove Fiber    Random Insert Fiber
    ${ru_operate_count_dict}    Create Dictionary
    FOR    ${ru}    IN    @{TESTED_FR_SN_LIST}
        Set To Dictionary    ${ru_operate_count_dict}    ${ru}=${0}
    END
    ${copy_all_cell_list}    copy list    ${ALL_CELL_LIST}
    ${copy_all_ru_cell_list}    copy list    ${ALL_CELL_LIST}
    ${onair_cell_dict}    Create Dictionary    cell=${copy_all_cell_list}    ru=${copy_all_ru_cell_list}
    Set Suite Variable    ${ONAIR_CELL_DICT}    ${onair_cell_dict}
    Set Suite Variable    ${RU_OPERATE_COUNT_DICT}    ${ru_operate_count_dict}
    Return From Keyword If    ${NODE_CFG["${MASTER_BTS_ID}"]["fullrack"]}
    ${scf_file}    Set Variable    ${NODE_CFG["${MASTER_BTS_ID}"]["scf_file_path"]}
    ${smod_product_name}    Get SMOD Product Name    ${scf_file}
    Run Keyword If    "ASOE" in "${smod_product_name}"    Remove Values From List    ${RANDOM_ACTIONS}    Random Reset BBMOD

Get RRU With Specific Status
    [Arguments]    ${parameters}
    ${ru_list}    Wait Until Keyword Succeeds    120s    10s    Check RRU Status
    ${specific_ru_list}   get_specific_resource_list    ${ru_list}    ${parameters}
    [Return]    ${specific_ru_list}

Check RRU Status
    [Arguments]    ${status}=proceduralStatus    ${value}=initializing
    Log    ${status}
    Log    ${value}
    Sleep    10s
    ${bts_info}    coam.get_bts_info     connection=${CASE_NAME}_${MASTER_BTS_ID}
    ${rmod_list}    Set Variable    ${bts_info["radioModules"]["rmod"]}
    FOR    ${rmod_info}    IN    @{rmod_list}
        Should Not Be True    "${rmod_info["status"]["proceduralStatus"]}"=="initializing"
    END
    [Return]    ${rmod_list}

Check All Site Procedural Status
    Sleep    10s
    ${bts_info}    coam.get_bts_info     connection=${CASE_NAME}_${MASTER_BTS_ID}
    ${bbmod_list}    Set Variable    ${bts_info["basebandModules"]}
    ${smod_list}    Set Variable    ${bts_info["systemModules"]}
    ${rmod_list}    Set Variable    ${bts_info["radioModules"]["rmod"]}
    FOR    ${bbmod_info}    IN    @{bbmod_list}
        Should Not Be True   "${bbmod_info["status"]["proceduralStatus"]}"=="initializing"
    END
    FOR    ${smod_info}    IN    @{smod_list}
        Should Not Be True    "${smod_info["status"]["proceduralStatus"]}"=="initializing"
    END
    FOR    ${rmod_info}    IN    @{rmod_list}
        Should Not Be True    "${rmod_info["status"]["proceduralStatus"]}"=="initializing"
    END

Get Ru Onair Cells
    [Arguments]    ${ru_sn}    ${operate}=append    ${all_cell_list}=${ALL_CELL_LIST}
    ${ru_operate_count}    Set Variable    ${RU_OPERATE_COUNT_DICT["${ru_sn}"]}
    ${ru_operate_count_new}    Run Keyword If     "${operate}"=="remove"    Evaluate    ${ru_operate_count}+1
    ...    ELSE IF    "${operate}"=="append"    Evaluate    ${ru_operate_count}-1
    Set To Dictionary    ${RU_OPERATE_COUNT_DICT}   ${ru_sn}=${ru_operate_count_new}
    ${copy_all_cell_list}    Copy List    ${all_cell_list}
    ${ru_cell_list}    get_ru_cells     ${ru_sn}     ${copy_all_cell_list}
    FOR    ${ru_cell}    IN    @{ru_cell_list}
        Run Keyword If   "${operate}"=="append" and ${ru_operate_count_new}==0
        ...    Append To List    ${ONAIR_CELL_DICT["ru"]}    ${ru_cell}
        ...    ELSE IF   "${operate}"=="remove"    Remove Values From List    ${ONAIR_CELL_DICT["ru"]}    ${ru_cell}
    END

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
    [Arguments]    ${parameters}
    ${cell_list}    random.Get Cell Status
    ${specific_cell_list}   get_specific_resource_list    ${cell_list}    ${parameters}
    ${status}    Run Keyword And Return Status    Variable Should Exist    ${NO_REQUIRED_CELL_ID}
    ${specific_cell_list}    Run Keyword If    ${status}    Remove No Required Cells    ${specific_cell_list}
    ...    ELSE    Set Variable    ${specific_cell_list}
    [Return]    ${specific_cell_list}

Remove No Required Cells
    [Arguments]    ${cell_list}
    ${no_required_cell_list}    split_string     ${NO_REQUIRED_CELL_ID}    :
    FOR    ${cell_info}    IN    @{cell_list}
         ${status}    Run Keyword And Return Status    Variable Should Exist    ${cell_info["cellId"]}
         ${cell_id}    Set Variable If    ${status}    ${cell_info["cellId"]}    ${cell_info["globalCellId"]}
         Run Keyword If    '${cell_id}' in ${no_required_cell_list} and ${status}
         ...    Remove Values From List    ${cell_list}    ${cell_info}
    END
    [Return]    ${cell_list}

Get Available Cell List
    Wait Until Keyword Succeeds    300s    10s    Check All Site Procedural Status
    ${available_cell_list}    Get Cell With Specific Status
    ...    operationalState=enabled,blockingState=Unblocked,availabilityStatus=online
    ${cell_list}    Create List
    FOR    ${cell_info}    IN    @{available_cell_list}
        ${m_cell_info}    Get Cell Info With PCI    ${ALL_CELL_LIST}    ${cell_info["physicalCellId"]}
        Append To List    ${cell_list}    ${m_cell_info}
    END
    [Return]    ${cell_list}

Check Alarms Exclude Legacy
    [Arguments]    ${orig_alarms}    ${additional_allowed_alarm}=${EMPTY}    ${bts_id}=${MASTER_BTS_ID}
    ${additional_allowed_alarm_list}    split_string    ${additional_allowed_alarm}    :
    ${allowed_alarm_list}     combine_lists    ${GLO_ADMIN_ALLOWED_ALARM}    ${additional_allowed_alarm_list}
    Remove Values From List    ${allowed_alarm_list}    ${empty}
    ${out_active_alarms_list}=    coam.Get Active Alarms   connection=${CASE_NAME}_${bts_id}
    ${key_list}    Create List    btsLastUpdateTime    alarmAttribute    hwPath    alarmingObjectIds
    ${orig_alarms}    remove_keys    ${orig_alarms}    ${key_list}
    ${out_active_alarms_list}    remove_keys    ${out_active_alarms_list}    ${key_list}
    Remove Values From List    ${out_active_alarms_list}    @{orig_alarms}
    Admin Alarms Check    available=${out_active_alarms_list}    allowed=${allowed_alarm_list}

Lock RRU
    [Arguments]    ${fr_sn}    ${bts_id}=${MASTER_BTS_ID}
    ${connection_id}    Set Variable   ${CASE_NAME}_${bts_id}
    ${rmod_distname}    Get R Object Distname By SN    class_name=RMOD_R    sn=${fr_sn}    connection=${connection_id}
    ${ru_before}    Get RRU Status
    ${orig_alarms}    coam.Get Active Alarms   connection=${CASE_NAME}_${bts_id}
    coam.lock    dist_name=${rmod_distname}    connection=${connection_id}    timeout=180
    RU Should Be Locked With Admin    distName=${rmod_distname}    connection=${connection_id}
    Get And Compare RRU Status    ${ru_before}   apart=${fr_sn}
    Check Alarms Exclude Legacy    ${orig_alarms}    bts_id=${bts_id}

Random Lock RRU
    ${unlock_ru_list}    Get RRU With Specific Status    administrativeState=Unlocked,availabilityStatus!=not installed
    ${ru_num}    Get Length    ${unlock_ru_list}
    Return From Keyword If    ${ru_num}==${0}
    ${ru_info}    Evaluate    random.choice(${unlock_ru_list})    modules=random
    ${loop}    Evaluate    random.randint(1,10)    modules=random
    FOR    ${i}    IN RANGE    ${loop}
        logging_info    Lock RRU:${ru_info["serialNumber"]}
        Lock RRU    ${ru_info["serialNumber"]}    ${MASTER_BTS_ID}
        Get Ru Onair Cells    ${ru_info["serialNumber"]}    remove
        Random Verify Available Cells OnAir
        logging_info    Unlock RRU:${ru_info["serialNumber"]}
        Unlock RRU    ${ru_info["serialNumber"]}    ${MASTER_BTS_ID}
        Get Ru Onair Cells    ${ru_info["serialNumber"]}    append
        Random Verify Available Cells OnAir
    END
    logging_info    Lock RRU:${ru_info["serialNumber"]}
    Lock RRU    ${ru_info["serialNumber"]}    ${MASTER_BTS_ID}
    Get Ru Onair Cells    ${ru_info["serialNumber"]}    remove
    Run Keyword If    "Random Unlock RRU" not in "${RANDOM_ACTIONS}"
    ...    Append To List    ${RANDOM_ACTIONS}    Random Unlock RRU
    Run Keyword If    ${ru_num}==${1}    Remove Values From List    ${RANDOM_ACTIONS}     Random Lock RRU
#    ${available_cell_list}    Get Available Cell List
#    ${status}    Run Keyword And Return Status     Should Be Empty    ${available_cell_list}
#    Run Keyword If    ${status} and "Random Make Tput" in "${RANDOM_ACTIONS}"    Remove Values From List
#    ...    ${RANDOM_ACTIONS}     Random Make Tput
    Random Verify Available Cells OnAir

Unlock RRU
    [Arguments]    ${fr_sn}    ${bts_id}=${MASTER_BTS_ID}
    ${connection_id}    Set Variable   ${CASE_NAME}_${bts_id}
    ${rmod_distname}    Get R Object Distname By SN    class_name=RMOD_R    sn=${fr_sn}    connection=${connection_id}
    ${ru_before}    Get RRU Status
    ${orig_alarms}    coam.Get Active Alarms   connection=${CASE_NAME}_${bts_id}
    coam.unlock    dist_name=${rmod_distname}    connection=${connection_id}    timeout=180
    RU Should Be Unlocked With Admin    distName=${rmod_distname}    connection=${connection_id}
    sleep    30 sec
    Get And Compare RRU Status    ${ru_before}    apart=${fr_sn}
    Check Alarms Exclude Legacy    ${orig_alarms}    bts_id=${bts_id}

Random Unlock RRU
    ${lock_ru_list}    Get RRU With Specific Status    administrativeState=Locked,availabilityStatus!=not installed
    ${ru_num}    Get Length    ${lock_ru_list}
    Return From Keyword If    ${ru_num}==${0}
    ${ru_info}    Evaluate    random.choice(${lock_ru_list})    modules=random
    logging_info    Unlock RRU:${ru_info["serialNumber"]}
    Unlock RRU    ${ru_info["serialNumber"]}    ${MASTER_BTS_ID}
    Get Ru Onair Cells    ${ru_info["serialNumber"]}    append
    Run Keyword If    "Random Lock RRU" not in "${RANDOM_ACTIONS}"
    ...    Append To List    ${RANDOM_ACTIONS}    Random Lock RRU
    Run Keyword If    ${ru_num}==${1}    Remove Values From List    ${RANDOM_ACTIONS}     Random Unlock RRU
#    ${available_cell_list}    Get Available Cell List
#    ${status}    Run Keyword And Return Status     Should Not Be Empty    ${available_cell_list}
#    Run Keyword If    ${status} and "Random Make Tput" not in "${RANDOM_ACTIONS}"
#    ...   Append To List    ${RANDOM_ACTIONS}     Random Make Tput
    Random Verify Available Cells OnAir

Unlock RRU All
    ${lock_ru_list}    Get RRU With Specific Status    administrativeState=Locked
    FOR    ${ru_info}    IN    @{lock_ru_list}
        Unlock RRU    ${ru_info["serialNumber"]}    ${MASTER_BTS_ID}
        Get Ru Onair Cells    ${ru_info["serialNumber"]}    append
    END
    Random Verify Available Cells OnAir

Reset RU
    [Arguments]    ${fr_serial_number}
    ${rfs_bts_id}    Get Bts Id With FR Serial Number    ${fr_serial_number}
    ${reset_bts_id}    Get RF Reset Btsid    ${rfs_bts_id}
    ${ru_before}    Get RRU Status
    ${cell_before}    random.Get Cell Status
    ${orig_alarms}    coam.Get Active Alarms   connection=${CASE_NAME}_${reset_bts_id}
    Radio Reset With Admin     ${fr_serial_number}    ${reset_bts_id}    timeout=600
    Get And Compare RRU Status    ${ru_before}    apart=${fr_serial_number}
    Wait Until Keyword Succeeds    ${ONAIR_TIME}    10s    Get And Compare RRU Status    ${ru_before}
    Wait Until Keyword Succeeds    ${ONAIR_TIME}    10s    Get And Compare Cell Status    ${cell_before}
    Check Alarms Exclude Legacy    ${orig_alarms}    bts_id=${reset_bts_id}

Random Reset RU
    ${loop}    Evaluate    random.randint(1,10)    modules=random
    ${fr_list}    Get RRU With Specific Status    availabilityStatus!=not installed
    ${status}    Run Keyword And Return Status    Should Be Empty    ${fr_list}
    Return From Keyword If    ${status}
    ${fr_sn}    Evaluate    random.choice(${fr_list})    modules=random
    log to console    Reset RU(${fr_sn["serialNumber"]}): ${loop}
    FOR    ${i}   IN RANGE    ${loop}
        logging_info    Reset RU:${fr_sn["serialNumber"]}
        Reset RU    ${fr_sn["serialNumber"]}
        Random Verify Available Cells OnAir
    END

Power Off RU
    [Arguments]    ${fr_serial_number}
    ${cell_mapping_rf_list}    Get Cells State On Specific FR    ${fr_serial_number}
    ${cells_pci}    Create List
    FOR    ${cell}    IN    @{cell_mapping_rf_list}
         Append To List    ${cells_pci}    ${cell["phyCellId"]}
    END
    ${cells_str}    Catenate    SEPARATOR=:    @{cells_pci}
    ${ru_before}    Get RRU Status
    ${cell_before}    random.Get Cell Status
    ${orig_alarms}    coam.Get Active Alarms   connection=${CASE_NAME}_${MASTER_BTS_ID}
    PDU Turn Off Unit    pdu_type=${BTS_CONFIG['FR']['${fr_serial_number}']['pdu']['type']}
    ...    pdu_ip=${BTS_CONFIG['FR']['${fr_serial_number}']['pdu']['ip_addr']}
    ...    pdu_port=${BTS_CONFIG['FR']['${fr_serial_number}']['pdu']['port']}
    Radio Should Be Off    ${fr_serial_number}    ${MASTER_BTS_ID}
    coam.assert_alarm_active    parameters=faultId=10,serialNo=${fr_serial_number}    timeout=120    connection=${CASE_NAME}_${MASTER_BTS_ID}
    Wait Until Keyword Succeeds   ${ONAIR_TIME}   10s   Get And Compare RRU Status    ${ru_before}    apart=${fr_serial_number}
    Wait Until Keyword Succeeds   ${ONAIR_TIME}   10s   Get And Compare Cell Status   ${cell_before}   apart=${cells_str}

Random Power Off RU
    ${loop}    Evaluate    random.randint(1,10)    modules=random
    ${fr_list}    Get RRU With Specific Status    availabilityStatus!=not installed
    ${remove_frs}    Get Dictionary Keys    ${UNLINKMAP}
    ${new_fr_list}    create list
    FOR    ${fr_info}    IN    @{fr_list}
        Run Keyword If    "${fr_info["serialNumber"]}" not in "${remove_frs}"    Append To List    ${new_fr_list}    ${fr_info}
    END
    Return From Keyword If    ${new_fr_list.__len__()}==${0}
    ${fr_info}    Evaluate    random.choice(${new_fr_list})    modules=random
    FOR    ${i}   IN RANGE    ${loop}
        logging_info    Power Off RU:${fr_info["serialNumber"]}
        Power Off RU    ${fr_info["serialNumber"]}
        Get Ru Onair Cells    ${fr_info["serialNumber"]}    remove
        Random Verify Available Cells OnAir
        sleep    30s
        logging_info    Power On RU:${fr_info["serialNumber"]}
        Power On RU    ${fr_info["serialNumber"]}
        Get Ru Onair Cells    ${fr_info["serialNumber"]}    append
        Random Verify Available Cells OnAir
    END
    logging_info    Power Off RU:${fr_info["serialNumber"]}
    Power Off RU    ${fr_info["serialNumber"]}
    Get Ru Onair Cells    ${fr_info["serialNumber"]}    remove
    Run Keyword If    "Random Power On RU" not in "${RANDOM_ACTIONS}"
    ...    Append To List    ${RANDOM_ACTIONS}    Random Power On RU
    Run Keyword If    ${new_fr_list.__len__()}==${1}    Remove Values From List    ${RANDOM_ACTIONS}     Random Power Off RU
    Random Verify Available Cells OnAir

Power On RU
    [Arguments]    ${fr_serial_number}
    ${cell_mapping_rf_list}    Get Cells State On Specific FR    ${fr_serial_number}
    ${cells_pci}    Create List
    FOR    ${cell}    IN    @{cell_mapping_rf_list}
         Append To List    ${cells_pci}    ${cell["phyCellId"]}
    END
    ${cells_str}    Catenate    SEPARATOR=:    @{cells_pci}
    ${ru_before}    Get RRU Status
    ${cell_before}    random.Get Cell Status
    ${orig_alarms}    coam.Get Active Alarms   connection=${CASE_NAME}_${MASTER_BTS_ID}
    PDU Turn On Unit    pdu_type=${BTS_CONFIG['FR']['${fr_serial_number}']['pdu']['type']}
    ...    pdu_ip=${BTS_CONFIG['FR']['${fr_serial_number}']['pdu']['ip_addr']}
    ...    pdu_port=${BTS_CONFIG['FR']['${fr_serial_number}']['pdu']['port']}
    coam.assert_alarm_inactive    parameters=faultId=10,serialNo=${fr_serial_number}    timeout=300    connection=${CASE_NAME}_${MASTER_BTS_ID}
    Wait Until Keyword Succeeds    ${ONAIR_TIME}    10s    Get And Compare RRU Status    ${ru_before}    apart=${fr_serial_number}
    Wait Until Keyword Succeeds    ${ONAIR_TIME}    10s    Get And Compare Cell Status    ${cell_before}    apart=${cells_str}
    coam.assert any    class_name=RMOD    parameters=operationalState=regex"(?i)Enabled", serialNumber=${fr_serial_number}
    ...    timeout=600s    alias=${CASE_NAME}_${MASTER_BTS_ID}
    sleep    1min
    FOR    ${cell}    IN    @{cell_mapping_rf_list}
        ${cell_info}    coam.Get Cell Specific Info    cell_id=${cell["distName"]}
        ...    connection=${CASE_NAME}_${cell["btsId"]}
        ${status}    Run Keyword And Return Status    Variable Should Exist    ${cell_info["status"]["availabilityStatus"]}
        Run Keyword If    ${status}    Should Not Be Equal As Strings    ${cell_info["status"]["availabilityStatus"]}    failed
    END
    Check Alarms Exclude Legacy    ${orig_alarms}    bts_id=${MASTER_BTS_ID}

Get Power Off Radio
    ${power_off_radios}    Create List
    FOR    ${fr_sn}    IN    @{USED_FR_SN_LIST}
        pdu.Setup Pdu        host=${BTS_CONFIG['FR']['${fr_sn}']['pdu']['ip_addr']}
        ...    model=${BTS_CONFIG['FR']['${fr_sn}']['pdu']['type']}
       ${port_status}    pdu.Get Port Status    port=${BTS_CONFIG['FR']['${fr_sn}']['pdu']['port']}
       Run Keyword If    "${port_status}" == "off"    Append To List    ${power_off_radios}    ${fr_sn}
    END
    [Return]   ${power_off_radios}

Random Power On RU
    ${power_off_radios}    Get Power Off Radio
    ${ru_num}    Get Length    ${power_off_radios}
    Return From Keyword If    ${ru_num}==${0}
    ${fr_sn}    Evaluate    random.choice(${power_off_radios})    modules=random
    logging_info    Power On RU:${fr_sn}
    Power On RU    ${fr_sn}
    Get Ru Onair Cells    ${fr_sn}   append
    Run Keyword If    "Random Power Off RU" not in "${RANDOM_ACTIONS}"
    ...    Append To List    ${RANDOM_ACTIONS}    Random Power Off RU
#    Run Keyword If    "Random Reset RU" not in "${RANDOM_ACTIONS}"
#    ...    Append To List    ${RANDOM_ACTIONS}    Random Reset RU
    Run Keyword If    ${ru_num}==${1}    Remove Values From List    ${RANDOM_ACTIONS}     Random Power On RU
    Random Verify Available Cells OnAir

Reset BBMOD
    [Arguments]    ${bbmod_sn}    ${bts_id}=${MASTER_BTS_ID}
    ${available_cell_list}    Get Available Cell List
    ${connection_id}    Set Variable   ${CASE_NAME}_${bts_id}
    ${bbmod_distname}    Get R Object Distname By SN    BBMOD_R    ${bbmod_sn}    ${connection_id}
    ${ru_before}    Get RRU Status
    ${cell_before}    random.Get Cell Status
    ${orig_alarms}    coam.Get Active Alarms   connection=${CASE_NAME}_${bts_id}
    coam.reset_unit    dist_name=${bbmod_distname}    reset_type=Warm
    ...    force_radio_reset=${True}    timeout=300    connection=${connection_id}
    Wait Until Keyword Succeeds    ${ONAIR_TIME}    10s    Get And Compare RRU Status    ${ru_before}
    Wait Until Keyword Succeeds    ${ONAIR_TIME}    10s    Get And Compare Cell Status    ${cell_before}
    Check Alarms Exclude Legacy    ${orig_alarms}    bts_id=${bts_id}

Random Reset BBMOD
    ${loop}    Evaluate    random.randint(1,10)    modules=random
    FOR    ${i}   IN RANGE    ${loop}
        ${bbmod_sn_list}    Set Variable    ${NODE_CFG["${MASTER_BTS_ID}"]["bbmod_sn_list"]}
        ${bbmod_sn}    Evaluate    random.choice(${bbmod_sn_list})    modules=random
        logging_info    Reset BBMOD:${bbmod_sn}
        random.Reset BBMOD    ${bbmod_sn}    ${MASTER_BTS_ID}
        Random Verify Available Cells OnAir
    END

Cell Block
    [Arguments]    ${pci}    ${timeout}=20s

    ${cell_info}    Get Cell Info With PCI    ${ALL_CELL_LIST}    ${pci}
    ${connection_id}    Set Variable   ${CASE_NAME}_${cell_info["btsId"]}
    ${R_class_name}   Get R CELL Class Name   ${cell_info}
    ${cell_distname}    Get R Object Distname    class_name=${R_class_name}
    ...     id=${cell_info["cellId"]}    connection=${connection_id}
    ${orig_alarms}    coam.Get Active Alarms   connection=${CASE_NAME}_${cell_info["btsId"]}
    coam.Block Cell    dist_name=${cell_distname}    timeout=${timeout}
    ...    connection=${connection_id}

    ${cell_R_info}    coam.Get Cell Specific Info    cell_id=${cell_info["distName"]}    connection=${connection_id}
    Should Be Equal As Strings  ${cell_R_info["status"]["blockingState"]}  Blocked

    ${alarmingResource}    Set Variable If    "${cell_info["NetworkType"]}" == "4G"    ${cell_distname}
    ...    ${cell_info["distName"]}
    ${alarms}   coam.assert_alarm_active
    ...    parameters=faultId=49,severity=Critical,alarmingResource=${alarmingResource}
    ...     connection=${connection_id}
    Check Alarms Exclude Legacy    ${orig_alarms}    additional_allowed_alarm=Cell blocked    bts_id=${cell_info["btsId"]}

Random Block Cell
    ${unblocked_cell_list}    Get Cell With Specific Status    blockingState=Unblocked
    ${cell_num}    Get Length    ${unblocked_cell_list}
    Return From Keyword If    ${cell_num}==${0}
    ${cell_info}    Evaluate    random.choice(${unblocked_cell_list})    modules=random
    ${m_cell_info}    Get Cell Info With PCI    ${ALL_CELL_LIST}    ${cell_info["physicalCellId"]}
    ${loop}    Evaluate    random.randint(1,10)    modules=random
    log to console    block/unblock cell(${cell_info["physicalCellId"]}): ${loop}
    FOR    ${i}    IN RANGE    ${loop}
        logging_info    Cell Block:${cell_info["physicalCellId"]}
        Cell Block    ${cell_info["physicalCellId"]}
        Remove Values From List     ${ONAIR_CELL_DICT["cell"]}     ${m_cell_info}
        Random Verify Available Cells OnAir
        logging_info    Cell Unblock:${cell_info["physicalCellId"]}
        Cell Unblock    ${cell_info["physicalCellId"]}
        Sleep    5s
        Append To List     ${ONAIR_CELL_DICT["cell"]}     ${m_cell_info}
        Random Verify Available Cells OnAir
    END
    logging_info    Cell Block:${cell_info["physicalCellId"]}
    Cell Block    ${cell_info["physicalCellId"]}
    Remove Values From List     ${ONAIR_CELL_DICT["cell"]}     ${m_cell_info}
    Run Keyword If    "Random Unblock Cell" not in "${RANDOM_ACTIONS}"
    ...    Append To List    ${RANDOM_ACTIONS}    Random Unblock Cell
    Run Keyword If    ${cell_num}==${1}    Remove Values From List    ${RANDOM_ACTIONS}    Random Block Cell
#    ${available_cell_list}    Get Available Cell List
#    ${status}    Run Keyword And Return Status     Should Be Empty    ${available_cell_list}
#    Run Keyword If    ${status} and "Random Make Tput" in "${RANDOM_ACTIONS}"    Remove Values From List
#    ...    ${RANDOM_ACTIONS}     Random Make Tput
    Random Verify Available Cells OnAir

Cell Unblock
    [Arguments]    ${pci}    ${timeout}=20s
    ${cell_info}    Get Cell Info With PCI    ${ALL_CELL_LIST}    ${pci}
    ${connection_id}    Set Variable   ${CASE_NAME}_${cell_info["btsId"]}
    ${R_class_name}   Get R CELL Class Name   ${cell_info}
    ${cell_distname}    Get R Object Distname    class_name=${R_class_name}
    ...     id=${cell_info["cellId"]}    connection=${connection_id}     connection=${connection_id}
    ${orig_alarms}    coam.Get Active Alarms   connection=${CASE_NAME}_${cell_info["btsId"]}
    coam.Unblock Cell    dist_name=${cell_distname}    timeout=${timeout}
    ...    connection=${connection_id}
    Sleep    60 sec

    ${cell_R_info}    coam.Get Cell Specific Info    cell_id=${cell_info["distName"]}    connection=${connection_id}
    Should Be Equal As Strings  ${cell_R_info["status"]["blockingState"]}  Unblocked

    coam.assert_alarm_inactive
    ...    parameters=faultId=49,severity=Critical,alarmingResource=${cell_distname}
    ...    connection=${connection_id}
    Check Alarms Exclude Legacy    ${orig_alarms}    bts_id=${cell_info["btsId"]}

Random Unblock Cell
    ${blocked_cell_list}    Get Cell With Specific Status    blockingState=Blocked
    ${cell_num}    Get Length    ${blocked_cell_list}
    Return From Keyword If    ${cell_num}==${0}
    ${cell_info}    Evaluate    random.choice(${blocked_cell_list})   modules=random
    logging_info    Cell Unblock:${cell_info["physicalCellId"]}
    Cell Unblock    ${cell_info["physicalCellId"]}
    ${m_cell_info}    Get Cell Info With PCI    ${ALL_CELL_LIST}    ${cell_info["physicalCellId"]}
    Append To List     ${ONAIR_CELL_DICT["cell"]}     ${m_cell_info}
    Run Keyword If    "Random Block Cell" not in "${RANDOM_ACTIONS}"
    ...    Append To List    ${RANDOM_ACTIONS}    Random Block Cell
    Run Keyword If    ${cell_num}==${1}    Remove Values From List    ${RANDOM_ACTIONS}    Random Unblock Cell
#    ${available_cell_list}    Get Available Cell List
#    ${status}    Run Keyword And Return Status     Should Not Be Empty    ${available_cell_list}
#    Run Keyword If    ${status} and "Random Make Tput" not in "${RANDOM_ACTIONS}"
#    ...   Append To List    ${RANDOM_ACTIONS}     Random Make Tput
    Random Verify Available Cells OnAir

Unblock Cell All
    ${blocked_cell_list}    Get Cell With Specific Status    blockingState=Blocked
    FOR    ${cell_info}    IN    @{blocked_cell_list}
        ${m_cell_info}    Get Cell Info With PCI    ${ALL_CELL_LIST}    ${cell_info["physicalCellId"]}
        Unblock Cell    ${m_cell_info}
        Append To List     ${ONAIR_CELL_DICT["cell"]}     ${m_cell_info}
    END
    Random Verify Available Cells OnAir

Get Available Required Cells
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
    ${req_cells}    Get Available Required Cells    ${available_cell_list}    ${REQUIRED_CELLS}
    ${status}    Run Keyword And Return Status    Should Be Empty    ${req_cells}
    Run Keyword If    ${status}    Set Test Variable    ${ALL_CELL_LIST}    ${tmp_cell_list}
    Return From Keyword If    ${status}
    logging_info    Random Make Tput
    Make Tput    cell_list=${available_cell_list}    required_cells=${req_cells}
    Set Test Variable    ${ALL_CELL_LIST}    ${tmp_cell_list}
    Random Verify Available Cells OnAir

Random Save Snapshot
    Log to console    Save Snapshot
    Logging Save Snapshot    ${TEST_LOGS_DIR_PATH}    alias=${CASE_NAME}_${MASTER_BTS_ID}

Random Check RFSW logs In BTS Snapshot
    logging_info    Random Check RFSW logs In BTS Snapshot
    Random Check RFSW logs In BTS Snapshot Exclude NotInstalled RUs    ${MASTER_BTS_ID}

Random Check RFSW logs In BTS Snapshot Exclude NotInstalled RUs
    [Arguments]    ${btsId}
    log to console    start to Collect Snapshot
    ${unlock_ru_list}    Get RRU With Specific Status    availabilityStatus!=not installed
    Logging Save Snapshot    ${TEST_LOGS_DIR_PATH}    alias=${CASE_NAME}_${btsId}
#    ${bts_info}    Get From Dictionary    ${NODE_CFG}    ${btsId}
#    ${rru_info}    Get From Dictionary    ${bts_info}    rmod_info
#    ${rru_sn_list}    Get Dictionary Keys    ${rru_info}
    ${snapshotfile}   get_snapshot_file    ${btsId}    ${TEST_LOGS_DIR_PATH}
    unzipfile    ${snapshotfile}    ${snapshotfile[:-4]}
    FOR    ${ru_info}    IN    @{unlock_ru_list}
        ${snapshot_file_list}    OperatingSystem.Get File    ${snapshotfile[:-4]}/snapshot_file_list.txt
        Should Match Regexp    ${snapshot_file_list}    ${ru_info["serialNumber"]}_RMOD_L_\\d+_.*startup
        Should Match Regexp    ${snapshot_file_list}    ${ru_info["serialNumber"]}_RMOD_L_\\d+_.*runtime
    END

Remove Fiber
    [Arguments]    ${fr_sn}
    ${link_map}    get_link_map    ${GGMAP}    ${UNLINKMAP}
    ${link_dict}    Get From Dictionary    ${link_map}    ${fr_sn}
    ${link_ports}    Get Dictionary Keys    ${link_dict}
    ${link_num}    Get Length    ${link_ports}
    ${type}    Run Keyword If    ${link_num}>${1}    Evaluate    random.choice(["primary", "secondary"])    modules=random
    ...    ELSE    Set Variable    primary
    ${connection_id}    Set Variable    ${CASE_NAME}_${MASTER_BTS_ID}
    ${cablink_r}     coam.Get Managed Objects    CABLINK_R    connection=${connection_id}
    ${rmod_r}     coam.Get Managed Objects    RMOD_R    connection=${connection_id}
    ${smod_r}     coam.Get Managed Objects    SMOD_R    connection=${connection_id}
    ${bbmod_r}     coam.Get Managed Objects    BBMOD_R    connection=${connection_id}
    ${topo}    get_current_topo    ${cablink_r}    ${rmod_r}    ${bbmod_r}    ${smod_r}
    ${link}    ${linktype}     get_selected_link    ${topo}    ${LINKMAP}    ${fr_sn}      ${type}
    ${status}    Run Keyword And Return Status     DIctionary Should Contain Key    ${UNLINKMAP}    ${fr_sn}
    ${link_list}    Create List    ${link}
    Run Keyword If    ${status}    Append To List    ${UNLINKMAP["${fr_sn}"]}    ${link}
    ...    ELSE    Set To Dictionary    ${UNLINKMAP}    ${fr_sn}=${link_list}
    Break Link    ${tl_config.FW_INFO['IP']}
    ...    ${tl_config.FW_INFO['USERNAME']}    ${tl_config.FW_INFO['PASSWORD']}    ${link}
    ...    link_type=single    FW_type=${tl_config.FW_INFO['TYPE']}
    Run Keyword If     '${type}'== 'Primary'    coam.assert_alarm_active
    ...    parameters=faultId=10,severity=Critical,serialNo=${fr_sn}
    ...    timeout=300    connection=${CASE_NAME}_${MASTER_BTS_ID}
    Run Keyword If    ${link_num}>${1}    Run Keywords     coam.assert_alarm_active
    ...    parameters=faultId=regex"1868|2002|16|4741|1815"    timeout=600    connection=${CASE_NAME}_${MASTER_BTS_ID}
    ...    AND    wait until keyword succeeds    7 min    10 sec    Check Cell Status To Remove Fiber     ${fr_sn}
    ${status}    Run Keyword And Return Status    List Should Not Contain Value
    ...    ${GLO_ADMIN_ALLOWED_ALARM}    Unstable eCPRI Link Detected
    Run Keyword If    ${status}    Append To List    ${GLO_ADMIN_ALLOWED_ALARM}    Unstable eCPRI Link Detected

Check Cell Status To Remove Fiber
    [Arguments]    ${fr_serial_number}
    ${cell_mapping_rf_list}    Get Cells State On Specific FR    ${fr_serial_number}
    FOR    ${cell_info}    IN     @{cell_mapping_rf_list}
        ${cell_R_info}    coam.Get Cell Specific Info
        ...    cell_id=${cell_info["distName"]}    connection=${CASE_NAME}_${cell_info["btsId"]}
        ${status}  Run Keyword And Return Status  Variable Should Exist  ${cell_R_info["status"]["availabilityStatus"]}
        Run Keyword If  ${status}  Should Not Be Equal As Strings  ${cell_R_info["status"]["availabilityStatus"]}  off line
    END

Random Remove Fiber
    ${not_installed_ru_list}    Get RRU With Specific Status    availabilityStatus!=not installed
    ${link_sn_list}    Get Dictionary Keys    ${GGMAP}
    ${has_fiber_rus}    intersection    ${not_installed_ru_list}    ${link_sn_list}
    ${ru_num}    Get Length    ${has_fiber_rus}
    Return From Keyword If    ${ru_num}==${0}
    ${fr_sn}    Evaluate    random.choice(${has_fiber_rus})    modules=random
    logging_info    Remove Fiber:${fr_sn}
    Remove Fiber    ${fr_sn}
    Run Keyword If    "Random Insert Fiber" not in "${RANDOM_ACTIONS}"
    ...    Append To List    ${RANDOM_ACTIONS}    Random Insert Fiber
    Get Ru Onair Cells    ${fr_sn}    remove
    Random Verify Available Cells OnAir

Insert Fiber
    [Arguments]    ${fr_sn}
    ${link}    Get From Dictionary    ${UNLINKMAP}    ${fr_sn}
    ${link_num}    Get Length    ${link}
    ${lin}    Evaluate    random.choice(${link})    modules=random
    ${status}    Run Keyword And Return Status    coam.assert_alarm_active
    ...    parameters=faultId=10,severity=Critical,serialNo=${fr_sn}
    ...    timeout=10    connection=${CASE_NAME}_${MASTER_BTS_ID}

    Connect Link    ${tl_config.FW_INFO['IP']}
    ...    ${tl_config.FW_INFO['USERNAME']}    ${tl_config.FW_INFO['PASSWORD']}    ${lin}
    ...    FW_type=${tl_config.FW_INFO['TYPE']}
    Run Keyword If    ${status}    coam.assert_alarm_inactive
    ...    parameters=faultId=10,severity=Critical,serialNo=${fr_sn}
    ...    timeout=600    connection=${CASE_NAME}_${MASTER_BTS_ID}
    ...    ELSE IF    ${link_num}==1    coam.assert_alarm_inactive
    ...    parameters=faultId=regex"1868|2002|16|4741|1815"    timeout=600    connection=${CASE_NAME}_${MASTER_BTS_ID}
    coam.assert any    class_name=RMOD    parameters=operationalState=regex"(?i)Enabled", serialNumber=${fr_sn}
    ...    timeout=600s    alias=${CASE_NAME}_${MASTER_BTS_ID}
    Sleep    2 min
    Remove Values From List      ${UNLINKMAP["${fr_sn}"]}      ${lin}
    ${status}    Run Keyword And Return Status    Should Be Empty    ${UNLINKMAP["${fr_sn}"]}
    Run Keyword If    ${status}    Remove From Dictionary    ${UNLINKMAP}    ${fr_sn}

Random Insert Fiber
    ${fr_list}    Get Dictionary Keys    ${UNLINKMAP}
    ${ru_num}    Get Length    ${fr_list}
    Return From Keyword If    ${ru_num}==${0}
    ${fr_sn}    Evaluate    random.choice(${fr_list})    modules=random
    logging_info    Insert Fiber:${fr_sn}
    Insert Fiber    ${fr_sn}
    ${status}    Run Keyword And Return Status    Should Be Empty    ${UNLINKMAP}
    Run Keyword If    ${status} and "Random Insert Fiber" in "${RANDOM_ACTIONS}"
    ...    Remove Values From List    ${RANDOM_ACTIONS}    Random Insert Fiber
    Get Ru Onair Cells    ${fr_sn}    append
    Random Verify Available Cells OnAir

Insert All Fibers
    ${fr_list}    Get Dictionary Keys    ${UNLINKMAP}
    ${all_links}      Create List
    FOR    ${fr_sn}    IN    @{fr_list}
        Append To List      ${all_links}     @{UNLINKMAP["${fr_sn}"]}
    END
    FOR    ${link}    IN    @{all_links}
        Connect Link    ${tl_config.FW_INFO['IP']}
        ...    ${tl_config.FW_INFO['USERNAME']}    ${tl_config.FW_INFO['PASSWORD']}    ${link}
        ...    FW_type=${tl_config.FW_INFO['TYPE']}
    END

Random Online Commission
    ${ONLINE_PARAMETERS}     Evaluate    ${ONLINE_PARAMETERS}
    ${parameter}    Evaluate    random.choice(${ONLINE_PARAMETERS})    modules=random
    logging_info    Online Commission:${parameter}
    Online Commission    ${parameter}

Online Commission
    [Arguments]    ${parameter}    ${bts_id}=${MASTER_BTS_ID}
    ${orig_alarms}    coam.Get Active Alarms   connection=${CASE_NAME}_${bts_id}
    ${available_cell_list}    Get Available Cell List
#    ${type}    Evaluate    type(${parameter}).__name__
    ${status}    Run Keyword And Return Status    Evaluate    ${parameter}
    ${parameter}    Run Keyword If    ${status}    Evaluate    ${parameter}
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
    Random Verify Available Cells OnAir
    Check Alarms Exclude Legacy    ${orig_alarms}    bts_id=${bts_id}
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

Get Rat Cell List
    ${NR_Cell_List}    Create List
    ${LTE_Cell_List}    Create List
    ${available_cell_list}    Get Available Cell List
    FOR    ${cell_info}    IN    @{ALL_CELL_LIST}
        Run Keyword If    "${cell_info["NetworkType"]}"=="SA"    Append To List    ${NR_Cell_List}    ${cell_info}
        ...    ELSE IF    "${cell_info["NetworkType"]}" == "4G"    Append To List    ${LTE_Cell_List}    ${cell_info}
    END
    ${ALL_NR_CELL_LIST}    Copy List    ${NR_Cell_List}
    ${ALL_LTE_CELL_LIST}    Copy List    ${LTE_Cell_List}
    Set Test Variable    ${ALL_NR_CELL_LIST}
    Set Test Variable    ${ALL_LTE_CELL_LIST}
    ${phycellid_list}    Get Key Values From Json List    phyCellId    ${available_cell_list}
    FOR    ${nr_cell}    IN    @{NR_Cell_List}
        Run Keyword If    ${nr_cell["phyCellId"]} not in ${phycellid_list}
        ...    Remove Values From List    ${NR_Cell_List}   ${nr_cell}
    END
    FOR    ${lte_cell}    IN    @{LTE_Cell_List}
        Run Keyword If    ${lte_cell["phyCellId"]} not in ${phycellid_list}
        ...    Remove Values From List    ${LTE_Cell_List}   ${lte_cell}
    END
    set test variable    ${NR_RAT_CELL_LIST}    ${NR_Cell_List}
    set test variable    ${LTE_RAT_CELL_LIST}    ${LTE_Cell_List}

Get Due Mode Cell List
    ${Due_mode_rru_list}    Create List
    ${Due_mode_rru_list}    Get Due Mode RRU List    ${NR_RAT_CELL_LIST}     ${LTE_RAT_CELL_LIST}
    FOR    ${fr_sn}    IN    @{Due_mode_rru_list}
        Remove Invalid Cell    ${fr_sn}
    END

Random RAT Reset
    Get Rat Cell List
    ${net_type_list}    Get Key Values From Json List    NetworkType    ${ALL_CELL_LIST}
    ${net_type_list}    Remove Duplicates    ${net_type_list}
    ${length}    Get Length    ${net_type_list}
#    Run Keyword If    ${length}>=2    Get Due Mode Cell List
    ${concurrent_list}    Create List    4G   SA
    ${network_type}    Run Keyword If    ${length}>=2    Evaluate    random.choice(${concurrent_list})    modules=random
    ...    ELSE    Set Variable    ${net_type_list[0]}
    ${tec}    Set Variable If    "${network_type}"=="SA"    NR     LTE
    FOR    ${cell_info}     IN    @{ALL_${tec}_CELL_LIST}
        Append To List     ${ONAIR_CELL_DICT["cell"]}     ${cell_info}
    END
    logging_info    RAT Reset:${tec}
    Run Keyword If    ${length}>=2     Reset RAT    ${tec}    ${${tec}_RAT_CELL_LIST}    ${True}
    ...    ELSE IF    ${length}==1     Reset RAT    ${tec}
    ...    ELSE    FAIL    Not Supported

Reset RAT
    [Arguments]    ${rat_type}    ${check_cell_list}=${EMPTY}    ${is_concurrent}=${False}   ${bts_id}=${MASTER_BTS_ID}
    Log    ${check_cell_list}
    Log    ${is_concurrent}
    ${orig_alarms}    coam.Get Active Alarms   connection=${CASE_NAME}_${bts_id}
    coam.rat_reset    rat_type=${rat_type}    timeout=260    connection=${CASE_NAME}_${MASTER_BTS_ID}
#    Run Keyword If    ${is_concurrent}    Verify All Cells OnAir    check_cell_list=${check_cell_list}
    Random Verify Available Cells OnAir
    Check Alarms Exclude Legacy    ${orig_alarms}    bts_id=${bts_id}

Random Verify Available Cells OnAir
    [Arguments]    ${timeout}=${ONAIR_TIME}
    ${onair_cell_list}     lists_intersection    ${ONAIR_CELL_DICT["ru"]}    ${ONAIR_CELL_DICT["cell"]}
    Wait Until Keyword Succeeds    ${timeout}    10 sec    Verify All Cells OnAir    check_cell_list=${onair_cell_list}

Random Test Keyword
    filtering_syslog.start_filter_log    EU name    alias=eu_name
    ${loop}    Evaluate    random.randint(50, 51)    modules=random
    FOR    ${i}    IN RANGE    ${loop}
        log to console    **************************** ${i} ****************************\n
        ${test_keyword}    Evaluate    random.choice(${RANDOM_ACTIONS})    modules=random
        Run Keyword    ${test_keyword}
    END
    ${filtered_log}    filtering_syslog.get_filtered_log    alias=eu_name
    Should Be Empty    ${filtered_log}
    filtering_syslog.stop_filter_log    alias=eu_name
    [Teardown]    Run Keywords    Pdu Turn On All Devices From Serial Number List    ${USED_FR_SN_LIST}       ${BTS_CONFIG}    FR
    ...    AND    Insert All Fibers
    ...    AND    coam.assert every    class_name=RMOD    parameters=operationalState=regex"(?i)Enabled"
    ...    timeout=600s    alias=${CASE_NAME}_${MASTER_BTS_ID}
    ...    AND    Unlock RRU All
    ...    AND    coam.assert any    class_name=RMOD    parameters=operationalState=regex"(?i)Enabled"
    ...    timeout=600s    alias=${CASE_NAME}_${MASTER_BTS_ID}
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
        ${exe_step}    Fetch From Right    ${step}    -
        ${keyword_name}    @{paramter}    Split String    ${exe_step}    :    1
        ${status}    Run Keyword And Return Status    Should Be Empty    ${paramter}
        Run Keyword If    ${status}    Run Keyword    ${keyword_name}
        ...    ELSE    Run Keyword    ${keyword_name}    ${paramter[0]}
    END
    [Teardown]    Run Keywords    Pdu Turn On All Devices From Serial Number List    ${USED_FR_SN_LIST}       ${BTS_CONFIG}    FR
    ...    AND    Insert All Fibers
    ...    AND    coam.assert every    class_name=RMOD    parameters=operationalState=regex"(?i)Enabled"
    ...    timeout=600s    alias=${CASE_NAME}_${MASTER_BTS_ID}
    ...    AND    Unlock RRU All
    ...    AND    Unblock Cell All
    ...    AND    Wait For All Cells OnAir    timeout=${ONAIR_TIME}
