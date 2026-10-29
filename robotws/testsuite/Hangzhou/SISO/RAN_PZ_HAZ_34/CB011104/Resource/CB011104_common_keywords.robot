*** Settings ***
Documentation
...    Author: Shifu Lan
...    contact:shifu.lan@nokia-sbell.com
...    squad group:VRF_HAZ4_SG04

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/recommissioning_and_make_throughput.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/operate_cell_and_check.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Library     DateTime
Variables   testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB011104/Resource/CB011104_variables.py


*** Keywords ***
L3Call_setup_with_data_transfer_conducted_100M_20M_100M_20M
    [Arguments]  ${with_call}=${True}  ${with_peak}=${False}  ${duration}=${60}  ${ue_num_each_call}=1  ${ru_index}=1
    Selenium Login And Disable Screen Lock
    ${ru_info}   COAM get ru detial info by ru index  ru_index=${ru_index}
    ${ru_type}   set variable  ${ru_info}[productName]
    ${support_rus}    Get Dictionary Keys    dictionary=${chbw_target_dict}
    ${status}    Run Keyword And Return Status    List Should Contain Value    ${support_rus}    ${ru_type}
    IF    ${status}
        Modify nrCellType And chBw Online With MAA    parameters_dict=${chbw_target_dict}[${ru_type}]
    ELSE
        Fail    msg=RU type ${ru_type} is not in supported list: ${support_rus}
    END

    ${cell_list}    get all cell id
    Run Keyword If    ${with_call}    Get UE From Init File and Make call    cell_list=${cell_list}
    ...    with_peak=${with_peak}    duration=${duration}    ue_num_each_call=${ue_num_each_call}
    [Teardown]  Selenium Logout And Close Browser

CB009301_measure_eCPRI_delay_with_MSG5
    [Arguments]    ${with_call}=${True}  ${with_peak}=${False}  ${call_duration}=${60}    ${upload_tp}=${True}
    ...    ${upload_duration}=${True}    ${suite_name}=default    ${test_name}=default
    ...    ${ue_num_each_call}=1    ${connection}=GNB_OAM
    Modify actEcpriDelayMeasurement Parameter    new_value=${True}    connection=${connection}

    Log To Console    \nMake call for nr cells and check tput
    ${cell_list}    get all cell id
    run keyword if  ${with_call}    Get UE From Init File and Make call    cell_list=${cell_list}
    ...    with_peak=${with_peak}    duration=${call_duration}    upload_tp=${upload_tp}    upload_duration=${upload_duration}
    ...    suite_name=${suite_name}    test_name=${test_name}    ue_num_each_call=${ue_num_each_call}
    Check If Exist Crash During Capture Snapshot
    Modify actEcpriDelayMeasurement Parameter    new_value=${False}    connection=${connection}

CB007935_Assisted_SyncE_HO_Estimate_No_impairment
    [Arguments]    ${with_call}=${True}  ${with_peak}=${False}  ${duration}=${60}
    ...    ${ue_num_each_call}=1    ${connection}=GNB_OAM  ${ru_index}=${1}    ${made_type}=rf7
    Staged Check Clock estimatedHoldoverTime    ru_index=${ru_index}    made_type=${made_type}

    ${cell_list}    get all cell id
    AlarmWatchdog.add_allow_alarms    fault_id=4298
    Modify topDomainNumber Via Rest    value=${25}    connection=${connection}
    Wait until keyword succeeds    5min    5s    Expect Fault Should Present    faultId=4298
    Cell status Should Be Degraded    cell_list=${cell_list}
    Check syncStatus Via Rest    value=Holdover    connection=${connection}

    Log To Console    \nMake call for nr cells and check tput
    run keyword if  ${with_call}    Get UE From Init File and Make call    cell_list=${cell_list}
    ...    with_peak=${with_peak}    duration=${duration}    ue_num_each_call=${ue_num_each_call}

    Modify topDomainNumber Via Rest    value=${24}    connection=${connection}
    Wait until keyword succeeds    5min    5s    Expect Fault Should Absent    faultId=4298
    Check syncStatus Via Rest    value=Locked    connection=${connection}
    AlarmWatchdog.remove_allow_alarms    fault_id=4298

    ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
    Should Be True    ${alarm_status}

KPI_counter_check_in_dual_band_radio
    [Arguments]  ${with_call}=${True}  ${with_peak}=${False}    ${call_duration}=${60}    ${upload_tp}=${True}
    ...    ${upload_duration}=${True}    ${suite_name}=default    ${test_name}=default
    ...    ${ue_num_each_call}=1    ${counter_duration}=5min
    Selenium Login And Disable Screen Lock
    ${cell_list}    get all cell id
    Modify KPI Counter Parameters    cell_list=${cell_list}    counter_duration=${counter_duration}
    Log To Console    \nWait ${counter_duration} for generating counter data before L3 call
    Sleep   ${counter_duration}

    Run Keyword If    ${with_call}    Get UE From Init File and Make call    cell_list=${cell_list}
    ...    with_peak=${with_peak}    duration=${call_duration}    upload_tp=${upload_tp}    upload_duration=${upload_duration}
    ...    suite_name=${suite_name}    test_name=${test_name}    ue_num_each_call=${ue_num_each_call}
    Log To Console    \nWait ${counter_duration} for generating counter data during L3 call
    Sleep   ${counter_duration}

    Log To Console    \nWait ${counter_duration} for generating counter data after L3 call
    Sleep   ${counter_duration}

    ${testline_name}    Get Testline Name
    ${check_cell_list}    get_all_cell_id_list_from_ue_mapping_file    testline_name=${testline_name}
    Check CB011104_E Counters    cell_list=${check_cell_list}
    [Teardown]  Selenium Logout And Close Browser

CB011104_SiSo_Cell_block_and_unblock_4CC
    [Arguments]  ${ru_index}=${None}  ${duration}=${3600}  ${check_duration}=${180}  ${ue_num_each_call}=1
    ...  ${suite_name}=default    ${test_name}=default
    Get X2 link shutdown waiting time
    Selenium Login And Disable Screen Lock

    Modify Parameter if Need Modify    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ...    filter_param=Activate radio deep sleep time schedule
    ...    new_value=false
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=${False}    timeout=${300}
    Sleep    300s   reason=Wait for cell status stable and Call could reach Peak.
    ${cell_id_list}  Get All Cell Id    ru_index=${ru_index}
    ${ue_index_list}    ${cell_id_list}    Get UE List for Given Cell List    cell_list=${cell_id_list}    ue_num_each_call=${ue_num_each_call}
    ${testline_name}    Get Testline Name
    ${scf_dir}    ${scf_name}    split path    path=${Case_SCF_Path}
    ${ue_ul_layer}    get_ue_ul_layer_from_ue_mapping_file    testline_name=${testline_name}    scf_name=${scf_name}
    ${cell_and_peak_info}    generate peak information     cell_list=${cell_id_list}    duration=${duration}    ue_ul_layer=${ue_ul_layer}
    ...    suite_name=${suite_name}    test_name=${test_name}
    ${cell_num}    get length  ${cell_id_list}
    ${check_alarm}  set variable if  ${cell_num}==1  ${True}  ${False}
    FOR  ${block_id}  IN  @{cell_id_list}
        ${operate_list}    create list    ${block_id}
        ${operate_ue_index_list}    ${operate_cell_list}    Get UE List for Given Cell List    cell_list=${operate_list}
        ...    ue_num_each_call=${ue_num_each_call}
        ${other_ue_index_list}    Evaluate    [x for x in ${ue_index_list} if x not in ${operate_ue_index_list}]

        ${ue_and_cell}    Ue Attach and Start DL UL Traffic    ue_index_list=${ue_index_list}
        ...    cell_and_peak_info=${cell_and_peak_info}    duration=${duration}
        Ue Verify Peak Throughput    ue_index_list=${ue_index_list}    ue_and_cell=${ue_and_cell}
        ...    cell_and_peak_info=${cell_and_peak_info}    duration=${check_duration}
        Ue Stop DL UL Traffic and Detach    ue_index_list=${operate_ue_index_list}

        Block cells and check status   block_list=${operate_list}   check_alarm=${check_alarm}    gnb_type='${gNb_CuType}'
        Sleep    30s
        Ue Verify Peak Throughput    ue_index_list=${other_ue_index_list}    ue_and_cell=${ue_and_cell}
        ...    cell_and_peak_info=${cell_and_peak_info}    duration=${check_duration}

        UnBlock Cells and check status   block_list=${operate_list}   check_alarm=${check_alarm}    gnb_type='${gNb_CuType}'
        Sleep    300s   reason=Wait for cell status stable and Call could reach Peak.
        Ue Attach and Start DL UL Traffic    ue_index_list=${operate_ue_index_list}
        ...    cell_and_peak_info=${cell_and_peak_info}    duration=${duration}
        Ue Verify Peak Throughput    ue_index_list=${ue_index_list}    ue_and_cell=${ue_and_cell}
        ...    cell_and_peak_info=${cell_and_peak_info}    duration=${check_duration}
        Ue Stop DL UL Traffic and Detach    ue_index_list=${ue_index_list}
    END
    [Teardown]   Selenium Logout And Close Browser

Modify nrCellType And chBw Online
    [Arguments]  ${default_nrcelltype}=16DL8UL  ${new_nrcelltype}=8DL8UL  ${default_chbw}=80MHz  ${new_chbw}=100MHz
    ...    ${connection}=GNB_OAM
    ${cells_info}    coam.get cells info    connection=${connection}
    ${cell_list}    Create List
    FOR    ${cell_info}    IN    @{cells_info}
        IF    ${{$cell_info['nrCellType']==$default_nrcelltype and $cell_info['chBw']==$default_chbw}}
            Append To List    ${cell_list}    ${cell_info['globalCellId']}
        END
    END
    ${delta_id}    Set Variable    Online_modify_nrCellType_and_chBw_for_cells
    ${delta_json_path}    Set Variable    ${SAVE LOG DIRECTORY}/delta.json
    coam.Create Delta    delta_id=${delta_id}
    Log To Console    \nModify nrCellType(${default_nrcelltype}->${new_nrcelltype}) and chBw(${default_chbw}->${new_chbw}) in ${cell_list}
    FOR    ${cell_id}    IN    @{cell_list}
        Log To Console    \nModify the nrCellType and chBw for cell ${cell_id}
        ${remove_dist_name_list}    Create List    MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cell_id}/CHANNELGROUP-3
        ...    MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cell_id}/CHANNELGROUP-4
        FOR    ${remove_dist_name}    IN    @{remove_dist_name_list}
            coam.Append Managed Object To Delta    dist_name=${remove_dist_name}    operation=delete    delta_id=${delta_id}
        END
        ${cell_dist_name}    set variable    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
        coam.Append Parameter Update To Delta  dist_name=${cell_dist_name}  parameter=nrCellType  value=${new_nrcelltype}  delta_id=${delta_id}
        coam.Append Parameter Update To Delta    dist_name=${cell_dist_name}    parameter=chBw    value=${new_chbw}    delta_id=${delta_id}
    END
    coam.Get Delta    delta_id=${delta_id}
    coam.Save Delta    target_file_name=${delta_json_path}    delta_id=${delta_id}
    coam.Perform delta recommissioning    delta_file=${delta_json_path}    skip_parameter_relation_errors=${True}    connection=${connection}
    coam.Remove Delta    delta_id=${delta_id}
    Wait Until Keyword Succeeds    10min    30s    Check all cells info should be onair
    ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
    Should Be True    ${alarm_status}

Modify nrCellType And chBw Online With MAA
    [Arguments]   ${parameters_dict}    ${target_nrcelltype}=8DL8UL    ${connection}=GNB_OAM
    Log To Console    \nModify nrCellType and chBw for cells
    ${cells_info}    coam.get cells info    connection=${connection}
    ${delta_id}    Set Variable    Online_modify_nrCellType_and_chBw_for_cells
    ${delta_json_path}    Set Variable    ${SAVE LOG DIRECTORY}/delta.json
    coam.Create Delta    delta_id=${delta_id}
    FOR    ${cell_info}    IN    @{cells_info}
        ${cell_id}    Set Variable    ${cell_info['globalCellId']}
        Log To Console    \nModify the nrCellType and chBw for cell ${cell_id}
        ${cell_dist_name}    set variable    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
        IF    ${{$cell_info['nrCellType'] != $target_nrcelltype}}
            coam.Append Parameter Update To Delta  dist_name=${cell_dist_name}  parameter=nrCellType  value=${target_nrcelltype}  delta_id=${delta_id}
        END
        ${cell_chbw}    Set Variable    ${parameters_dict}[${cell_id}]
        IF    ${{$cell_info['chBw'] != $cell_chbw}}
            coam.Append Parameter Update To Delta    dist_name=${cell_dist_name}    parameter=chBw    value=${cell_chbw}    delta_id=${delta_id}
        END
    END
    coam.Get Delta    delta_id=${delta_id}
    coam.Save Delta    target_file_name=${delta_json_path}    delta_id=${delta_id}
    coam.Perform delta recommissioning    delta_file=${delta_json_path}    skip_parameter_relation_errors=${True}    connection=${connection}
    coam.Remove Delta    delta_id=${delta_id}
    Wait Until Keyword Succeeds    10min    30s    Check all cells info should be onair
    ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
    Should Be True    ${alarm_status}

Modify actEcpriDelayMeasurement Parameter
    [Arguments]    ${parameter}=actEcpriDelayMeasurement    ${new_value}=${True}    ${connection}=GNB_OAM
    Log To Console    \nOnline modify actEcpriDelayMeasurement to ${new_value}
    ${dist_name}    Set Variable    MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    coam.perform_parameter_recommissioning    dist_name=${dist_name}    parameter=${parameter}
    ...    value=${new_value}    operation=update    connection=${connection}
    Log To Console    \nWait actEcpriDelayMeasurement parameter to take effect
    Sleep    90s
    COAM Wait gnb And Cells ready    timeout=15min    connection=${connection}
    Connect to gnb coam via ssl    connection=${connection}
    ${dist_parameters}    coam.get_parameter_by_distname    dist_name=${dist_name}    connection=${connection}
    ${dist_parameter_value}    Set Variable    ${dist_parameters[0]['parameters']['${parameter}']}
    Should Be Equal As Strings   ${dist_parameter_value}     ${new_value}
    ...    msg=parameter ${parameter} value is not equal to ${new_value}
    ${FHLKDLY_R_OBJECT}    coam.get_managed_objects    class_name=FHLKDLY_R    connection=${connection}
    IF    ${dist_parameter_value}
        Should Be True    ${{len($FHLKDLY_R_OBJECT) > 0}}
        Log    \nThe FHLKDLY_R object is exist
    ELSE
        Should Be True    ${{len($FHLKDLY_R_OBJECT) == 0}}
        Log    \nThe FHLKDLY_R object is not exist
    END

Check If Exist Crash During Capture Snapshot
    [Arguments]   ${snapshot_path}=${TS_CASE_LOG_PATH}  ${connection}=GNB_OAM    ${timeout}=600
    ${timestamp}    DateTime.Get current date    result_format=%Y%m%d%H%M%S
    ${snapshot_zip_file_path}    Join Path    ${snapshot_path}    snapshot_${timestamp}.zip
    Run   rm -rf ${snapshot_zip_file_path}
    coam.get_snapshot    target_file_name=${snapshot_zip_file_path}   timeout=${timeout}   connection=${connection}

    Sleep    120
    COAM Wait gnb And Cells ready    timeout=15min
    ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
    Should Be True    ${alarm_status}

Modify KPI Counter Parameters
    [Arguments]  ${cell_list}   ${counter_duration}=5min    ${connection}=GNB_OAM
    ${delta_id}    Set Variable    Online_modify_KPI_counter_parameters
    ${delta_json_path}    Set Variable    ${SAVE LOG DIRECTORY}/delta_kpi.json
    coam.Create Delta    delta_id=${delta_id}
    Log To Console    \nModify KPI Counter Parameters
    ${nrpmrnl_dist_name}    Set Variable    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRPMRNL-1
    coam.Append Parameter Update To Delta  dist_name=${nrpmrnl_dist_name}  parameter=miNrRip  value=${counter_duration}  delta_id=${delta_id}
    coam.Append Parameter Update To Delta  dist_name=${nrpmrnl_dist_name}  parameter=miNrRtwp  value=${counter_duration}  delta_id=${delta_id}
    ${bts_dist_name}    Set Variable    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    coam.Append Parameter Update To Delta  dist_name=${bts_dist_name}  parameter=actFdmScheduling  value=${True}  delta_id=${delta_id}
    FOR    ${cell_id}    IN    @{cell_list}
        ${cell_dist_name}    set variable    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
        coam.Append Parameter Update To Delta  dist_name=${cell_dist_name}  parameter=pucchModeSelect  value=longPucch  delta_id=${delta_id}
    END
    coam.Get Delta    delta_id=${delta_id}
    coam.Save Delta    target_file_name=${delta_json_path}    delta_id=${delta_id}
    coam.Perform delta recommissioning    delta_file=${delta_json_path}    skip_parameter_relation_errors=${True}    connection=${connection}
    coam.Remove Delta    delta_id=${delta_id}
    Wait Until Keyword Succeeds    10min    30s    Check all cells info should be onair
    ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
    Should Be True    ${alarm_status}

Check CB011104_E Counters
    [Arguments]    ${cell_list}
    ${counter_info}    Get Full PM Counters Info
    FOR    ${cell_id}    IN    @{cell_list}
        Check CB011104_E Counters Via Cell    counter_info=${counter_info}    cell_id=${cell_id}
        ...    counter_type=NRRIP    counter_ids=${counter_ids_rip_avg}
        Check CB011104_E Counters Via Cell    counter_info=${counter_info}    cell_id=${cell_id}
        ...    counter_type=NRRTP    counter_ids=${counter_ids_rtp_avg}
    END

Get Full PM Counters Info
    [Arguments]    ${connection}=PM_Counter
    Connect to gnb coam via ssl    connection=${connection}
    ${full_counter_info}    coam.get_pm_counters    connection=${connection}
    [Return]    ${full_counter_info}
    [Teardown]  COAM Teardown gnb connections    connection=${connection}

Check CB011104_E Counters Via Cell
    [Arguments]    ${counter_info}    ${cell_id}    ${counter_type}    ${counter_ids}
    ${counter_dist_name}    Set Variable    BTS/MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}/${counter_type}
    TRY
        ${cell_counter_value}    Set Variable
        ...    ${counter_info['BTS']['MRBTS-${MRBTS_ID}']['NRBTS-${NRBTS_ID}']['NRCELL-${cell_id}']['${counter_type}']}
        FOR    ${counter_id}    IN    @{counter_ids}
            ${key_status}    Run Keyword And Return Status    Dictionary Should Contain Key
            ...    dictionary=${cell_counter_value}    key=${counter_id}
            IF  not ${key_status}
                Log    \nCounter data for ${counter_id} is not exist
                CONTINUE
            END
            ${sorted_counter_value}    Get Dictionary Values    ${cell_counter_value}[${counter_id}]
            FOR    ${single_counter_value}    IN    @{sorted_counter_value}
                ${counter_status}    Run Keyword And Return Status    Should Be True     ${single_counter_value} <= 0
                IF    not ${counter_status}    Should Be Equal As Strings    ${single_counter_value}    -
            END
        END
    EXCEPT
        Log    \nCounter data for ${counter_dist_name} is not exist
    ELSE
        Log    \nCounter data for ${counter_dist_name} is exist
    END

Staged Check Clock estimatedHoldoverTime
    [Arguments]    ${ru_index}=${1}    ${made_type}=rf7    ${silent_time}=${4000}
    ${keyword_name}    set variable    Connect to Radio and Operate and Check ${made_type}
    ${stage_time_list}    Create List    ${420}    ${900}    ${1860}    ${3780}
    ${list_length}    Get Length    ${stage_time_list}
    ${start_time}    Set Variable    ${{time.time()}}
    ${end_time}    Set Variable    ${{$start_time + $silent_time}}
    ${stage_time_index}    Set Variable    ${0}
    ${stage_time}    Get From List    ${stage_time_list}    ${stage_time_index}
    WHILE    ${{time.time()}} < ${end_time}
        # RRU runtime log record estimatedHoldoverTime earler than cell onair, so check time should be 150s earlier than stage time
        IF    ${stage_time_index} < ${list_length} and ${{time.time() - $start_time}} > ${{$stage_time - 150}}
            run keyword    ${keyword_name}    ru_index=${ru_index}    stage_time=${stage_time}
            ${stage_time_index}    Set Variable    ${{$stage_time_index + 1}}
            IF   ${stage_time_index} >= ${list_length}
                Sleep    60
                CONTINUE
            END
            ${stage_time}    Get From List    ${stage_time_list}    ${stage_time_index}
        END
        Sleep    60
    END
    log to console    \nBTS kept silent for ${silent_time} seconds

Connect to Radio and Operate and Check rf7
    [Arguments]  ${ru_index}    ${stage_time}    ${asik_alias}=ASIK Master    ${retry_times}=${3}
    connect to common unit master    alias=${asik_alias}
    ${ru_alias}    set variable    RU_${ru_index}
    Connect to RU With Allocated IP    ru_index=${ru_index}    ru_alias=${ru_alias}    asik_alias=${asik_alias}

    ${query_cmd}    Set Variable    cat /var/log/runtime.log | grep estimatedHoldoverTime | awk '{print $8}'
    FOR    ${counter}    IN RANGE    0    ${retry_times}
        ${output}    Execute Command On RF7 Thor Chip    ru_index=${ru_index}    ru_alias=${ru_alias}    command=${query_cmd}
        ${LastEstimatedHoldoverTime}    Get Line    ${output}    -1
        TRY
            ${LastEstimatedHoldoverTime}    Convert To Integer    ${LastEstimatedHoldoverTime}
            Log    \nEstimatedHoldoverTime is found in runtime.log
            ${equal_status}    Run Keyword And Return Status    Should Be Equal As Strings   ${LastEstimatedHoldoverTime}     ${stage_time}
            IF    not ${equal_status}   Fail    msg=Last estimatedHoldoverTime ${LastEstimatedHoldoverTime} is not equal to ${stage_time}
            BREAK
        EXCEPT
            Log    \nEstimatedHoldoverTime is not found in runtime.log
            Sleep    60
        END
    END
    [Teardown]    csn.disconnect    connection=${asik_alias}

Execute Command On RF7 Thor Chip
    [Arguments]  ${ru_index}    ${ru_alias}    ${command}    ${thor_ip}=192.168.101.17
    ...    ${ru_username}=${tl.gnbs[0].dus[0].rus[${ru_index}-1].default_ssh_connection_details.username}
    ${query_cmd}    Set Variable    ssh ${ru_username}@${thor_ip} ${command}
    ${output}    csn.Execute    command=${query_cmd}    connection=${ru_alias}
    [Return]    ${output}

Modify topDomainNumber Via Rest
    [Arguments]    ${parameter}=topDomainNumber    ${value}=${25}    ${skip_parameter_relation_errors}=${True}    ${connection}=GNB_OAM
    ${dist_name}    Set Variable    MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1
    Modify Parameter Via Rest    dist_name=${dist_name}    parameter=${parameter}    value=${value}
    ...    skip_parameter_relation_errors=${skip_parameter_relation_errors}    connection=${connection}
    ${dist_parameter_value}    Get Parameter Value Via Rest    dist_name=${dist_name}    parameter=${parameter}    connection=${connection}
    Should Be Equal As Strings   ${dist_parameter_value}     ${value}
    ...    msg=parameter ${parameter} value is not equal to ${value}

Check syncStatus Via Rest
    [Arguments]    ${parameter}=syncStatus    ${value}=Locked    ${connection}=GNB_OAM
    ${dist_name}    Set Variable    MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/CLOCK_R-1
    ${dist_parameter_value}    Get Parameter Value Via Rest    dist_name=${dist_name}    parameter=${parameter}    connection=${connection}
    Should Be Equal As Strings   ${dist_parameter_value}     ${value}
    ...    msg=parameter ${parameter} value is not equal to ${value}

Modify Parameter Via Rest
    [Arguments]    ${dist_name}    ${parameter}    ${value}    ${skip_parameter_relation_errors}=${True}    ${connection}=GNB_OAM
    Log To Console    \nOnline modify ${parameter} to ${value}
    coam.perform_parameter_recommissioning    dist_name=${dist_name}    parameter=${parameter}    value=${value}    operation=update
    ...    skip_parameter_relation_errors=${skip_parameter_relation_errors}    connection=${connection}
    Sleep    90s
    COAM Wait gnb And Cells ready    timeout=15min    connection=${connection}

Get Parameter Value Via Rest
    [Arguments]    ${dist_name}    ${parameter}    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    connection=${connection}
    ${parameter_list}    Create List    ${parameter}
    ${dist_parameters}    coam.get_parameter_by_distname    dist_name=${dist_name}    parameter_list=${parameter_list}    connection=${connection}
    ${dist_parameter_value}    Set Variable    ${dist_parameters[0]['parameters']['${parameter}']}
    [Return]    ${dist_parameter_value}

Add_Note_MO_Configuration
    [Documentation]    Add multiple Note MO configurations to the base station
    [Arguments]    ${note_mo_list}=${add_note_mo_list}    ${connection}=GNB_OAM
    Log To Console    \nStep 1: Add multiple Note MO configurations to the base station via REST API
    COAM add several MOs via rest api    objects_to_add_via_api=${note_mo_list}    connection=${connection}
    Sleep    30s
    ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
    Should Be True    ${alarm_status}

Disable_UL_IQ_Capture_And_Reset_PhyEventEnable
    [Documentation]    Disable user plane L1 IQ capture, and reset R&D debug parameters
    [Arguments]    ${connection}=GNB_OAM    ${domain}=NrUlPhy    ${parameter_name}=phyEventEnableExt
    Log To Console    \nStep 2: Disable user plane L1 IQ capture, and reset R&D debug parameters

    # Disable user plane L1 IQ capture using TAF API
    Log To Console    \nDisable user plane L1 IQ capture
    ${fail_msg}    Set Variable    Failed to disable user plane L1 IQ capture, possibly because it is not yet configured.
    TRY
        # Call TAF API to disable user plane L1 IQ capture
        ${disable_status}    Run Keyword And Return Status    coam.disable_uplane_l1_iq_capture    connection=${connection}
        Should Be True    ${disable_status}    msg=${fail_msg}
    EXCEPT
        # Warning: Failed to disable U-plane L1 IQ capture, possibly because it is not yet configured. Continue with subsequent steps.
        Log To Console    \nWarning: ${fail_msg} Continue with subsequent steps.
    END

    # Reset R&D debug parameters (phyEventEnableExt parameter in NrUlPhy domain) using TAF API
    ${reset_status}    Run Keyword And Return Status    coam.reset_rad_debug_parameters    domain=${domain}
    ...    name=${parameter_name}    connection=${connection}
    Should Be True    ${reset_status}    msg=Failed to reset R&D debug parameters

    Sleep    30s
    COAM Wait gnb And Cells ready    timeout=10min    connection=${connection}
    ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
    Should Be True    ${alarm_status}

Set_PhyEventEnableExt_Parameter
    [Documentation]    Set the value of phyEventEnableExt parameter in R&D debug parameters for NrUlPhy domain
    [Arguments]    ${parameters}=${rad_parameters}    ${domain}=NrUlPhy    ${persistency}=Persistent    ${connection}=GNB_OAM
    Log To Console    \nStep 3: Set the value of phyEventEnableExt parameter in R&D debug parameters for NrUlPhy domain

    # Set R&D debug parameters using TAF API
    Log To Console    \nSet R&D debug parameters ${parameters}
    ${set_status}    Run Keyword And Return Status    coam.set_multiple_rad_debug_parameters    domain=${domain}    persistency=${persistency}
    ...    rad_parameters=${parameters}    connection=${connection}
    Should Be True    ${set_status}    msg=Failed to set R&D debug parameters

    Sleep    30s
    COAM Wait gnb And Cells ready    timeout=10min    connection=${connection}
    ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
    Should Be True    ${alarm_status}

Get_Subcell_And_RU_Lists_By_Cell_Id
    [Documentation]    Get ul_nr_subcell_list and capture_ru_list based on cell ID
    [Arguments]    ${cell_id}    ${connection}=GNB_OAM    ${profile}=UL_PROFILE_3
    # Get antenna information from L1 IQ profile
    ${profile_info}    coam.get_antenna_info_by_l1_iq_profile    profile=${profile}    detailed_output=${False}    connection=${connection}

    # Verify results
    Should Not Be Empty    ${profile_info}    msg=Failed to get antenna information, please check if L1 IQ profile is valid
    Log To Console    \nSuccessfully obtained antenna information from L1 IQ profile

    # Get profile
    ${ul_nr_subcell_list}    Create List
    ${capture_ru_list}    Create List

    # Iterate through ulNrSubcellList to find matching cell_id
    ${found}    Set Variable    ${False}
    ${local_mrbts_id}    Set Variable    ${MRBTS_ID}
    ${local_nrbts_id}    Set Variable    ${NRBTS_ID}

    # Track matching subcells for the same cell ID
    ${found_cell_ids}    Create List
    FOR    ${subcell}    IN    @{profile_info['ulNrSubcellList']}
        # Extract cell ID from nrcellDN
        ${nrcell_dn}    Set Variable    ${subcell['nrcellDN']}
        ${nrcell_parts}    Split String    ${nrcell_dn}    /
        ${nrcell_last_part}    Set Variable    ${nrcell_parts[-1]}
        ${nrcell_id_parts}    Split String    ${nrcell_last_part}    -
        ${nrcell_id}    Set Variable    ${nrcell_id_parts[-1]}

        # Check if it matches the target cell ID
        IF    '${nrcell_id}' == '${cell_id}'
            ${found}    Set Variable    ${True}
            # Modify nrcellDN to use the MRBTS and NRBTS ID of the current environment
            ${new_nrcell_dn}    Set Variable    MRBTS-${local_mrbts_id}/NRBTS-${local_nrbts_id}/NRCELL-${cell_id}

            # Create subcell_info and add to ul_nr_subcell_list if not already added
            ${subcell_key}    Set Variable    ${cell_id}_${subcell['subcellId']}
            IF    '${subcell_key}' not in ${found_cell_ids}
                Append To List    ${found_cell_ids}    ${subcell_key}
                ${subcell_info}    Create Dictionary    nrcellDN=${new_nrcell_dn}    subcellId=${subcell['subcellId']}
                Append To List    ${ul_nr_subcell_list}    ${subcell_info}
            END

            # Process captureRUList
            IF    'captureRUList' in ${subcell}
                FOR    ${ru}    IN    @{subcell['captureRUList']}
                    # Extract RMOD part from targetRMOD
                    ${target_rmod}    Set Variable    ${ru['targetRMOD']}
                    ${rmod_parts}    Split String    ${target_rmod}    /
                    ${rmod_last_part}    Set Variable    ${rmod_parts[-1]}

                    # Create new targetRMOD using the MRBTS ID of the current environment
                    ${new_target_rmod}    Set Variable    MRBTS-${local_mrbts_id}
                    FOR    ${i}    IN RANGE    1    ${rmod_parts.__len__()}
                        ${part}    Set Variable    ${rmod_parts[${i}]}
                        ${new_target_rmod}    Set Variable    ${new_target_rmod}/${part}
                    END

                    # Check if this RU is already in the capture_ru_list
                    ${ru_exists}    Set Variable    ${False}
                    FOR    ${existing_ru}    IN    @{capture_ru_list}
                        IF    '${existing_ru["targetRMOD"]}' == '${new_target_rmod}'
                            ${ru_exists}    Set Variable    ${True}
                            BREAK
                        END
                    END

                    # Only add the RU if it doesn't already exist in the list
                    IF    not ${ru_exists}
                        # Process antennaList
                        # Randomly select a set key
                        ${set_keys}    Get Dictionary Keys    ${ru['antennaList']}
                        ${random_index}    Evaluate    random.randint(0, len(${set_keys})-1)
                        ${selected_set_key}    Get From List    ${set_keys}    ${random_index}

                        # Directly use the value corresponding to the selected key
                        ${antenna_list}    Set Variable    ${ru['antennaList']['${selected_set_key}']}

                        # Create ru_info and add to capture_ru_list
                        ${ru_info}    Create Dictionary    targetRMOD=${new_target_rmod}    antennaList=${antenna_list}    captureActivityTimer=${2}
                        Append To List    ${capture_ru_list}    ${ru_info}
                    END
                END
            END
        END
    END

    # If no matching cell ID is found, use the default configuration
    IF    not ${found}
        ${cell_dist_name}    Set Variable    MRBTS-${local_mrbts_id}/NRBTS-${local_nrbts_id}/NRCELL-${cell_id}
        ${subcell_info}    Create Dictionary    nrcellDN=${cell_dist_name}    subcellId=${0}
        Append To List    ${ul_nr_subcell_list}    ${subcell_info}
    END

    [Return]    ${ul_nr_subcell_list}    ${capture_ru_list}

Configure_L1_IQ_Capture_For_Cell
    [Documentation]    Check if the specified cell status is Unblocked, and configure user plane L1 IQ capture for the specified cell
    [Arguments]    ${cell_id}    ${connection}=GNB_OAM    ${profile}=UL_PROFILE_3    ${module_dn}=${EMPTY}    ${capture_on_event}=${True}
    ...    ${capture_on_event_bb_ru}=${True}    ${buffer_cycle}=16frames    ${capture_frame_offset}=${2}
    Log To Console    \nStep 4: Check cell status and configure user plane L1 IQ capture
    # Check cell status
    Cell Should Be Unlocked    cell_idx=${cell_id}    connection=${connection}

    # Get cell DN path and configuration information
    ${ul_nr_subcell_list}    ${capture_ru_list}    Get_Subcell_And_RU_Lists_By_Cell_Id    cell_id=${cell_id}    profile=${profile}

    # Configure user plane L1 IQ capture using TAF API
    Log To Console    \nConfigure user plane L1 IQ capture for cell ${cell_id}

    # Configure L1 IQ capture
    ${config_status}    Run Keyword And Return Status    coam.configure_uplane_l1_iq_data
    ...    module_dn=${module_dn}
    ...    capture_on_event=${capture_on_event}
    ...    capture_on_event_bb_ru=${capture_on_event_bb_ru}
    ...    ul_nr_subcell_list=${ul_nr_subcell_list}
    ...    buffer_cycle=${buffer_cycle}
    ...    capture_frame_offset=${capture_frame_offset}
    ...    profile=${profile}
    ...    capture_ru_list=${capture_ru_list}
    ...    connection=${connection}

    Should Be True    ${config_status}    msg=Configure L1 IQ capture failed

    Log To Console    \nUser plane L1 IQ capture has been successfully configured for cell ${cell_id}

    # Wait for the configuration to take effect
    Sleep    30s
    COAM Wait gnb And Cells ready    timeout=10min    connection=${connection}

Perform_L3_Call_And_Verify
    [Documentation]    Perform L3 call traffic test on the specified cell list and verify the traffic peak
    [Arguments]    ${cell_list}=${None}    ${with_call}=${True}    ${with_peak}=${True}
    ...    ${duration}=300    ${upload_tp}=${True}    ${upload_duration}=${True}    ${direction}=BOTH
    ...    ${suite_name}=default    ${test_name}=default    ${ue_num_each_call}=1
    Log To Console    \nStep 5: Perform L3 call traffic test for 5 minutes and verify the traffic peak
    Run Keyword If    ${with_call}    Get UE From Init File and Make call    cell_list=${cell_list}
    ...    with_peak=${with_peak}    duration=${duration}    upload_tp=${upload_tp}    direction=${direction}
    ...    upload_duration=${upload_duration}    suite_name=${suite_name}    test_name=${test_name}
    ...    ue_num_each_call=${ue_num_each_call}

    Log To Console    \nL3 call traffic test completed

Check_For_Alarm_8101
    [Documentation]    Check if the base station reports an alarm with fault ID 8101
    [Arguments]    ${fault_id}=8101
    Log To Console    \nStep 6: Check if the base station reports an alarm with fault ID ${fault_id}
    Wait Until Keyword Succeeds    5min    10s    Expect Fault Should Present    faultId=${fault_id}
    Log To Console    \nThe base station has reported an alarm with fault ID ${fault_id}

Capture_And_Verify_Snapshot
    [Documentation]    Capture and decompress snapshot log, check if IQ log files exist
    [Arguments]    ${snapshot_path}=${TS_CASE_LOG_PATH}    ${connection}=GNB_OAM    ${timeout}=600
    ...    ${radio_iq_data_pattern}=fcpTriggeredCapture    ${fault_id}=8101
    ...    ${du_iq_data_pattern}=IqSnapshotBuffer
    Log To Console    \nStep 7: Capture and decompress snapshot log, check IQ log files and alarm status
    ${timestamp}    DateTime.Get Current Date    result_format=%Y%m%d%H%M%S
    ${snapshot_zip_file_path}    Join Path    ${snapshot_path}    IQ_snapshot_${timestamp}.zip
    ${snapshot_extract_path}    Join Path    ${snapshot_path}    IQ_snapshot_${timestamp}
    ${snapshot_file_list_path}    Join Path    ${snapshot_extract_path}    snapshot_file_list.txt

    # Capture snapshot using TAF API
    Log To Console    \nCapture snapshot to ${snapshot_zip_file_path}
    ${snapshot_status}    Run Keyword And Return Status    coam.get_snapshot    target_file_name=${snapshot_zip_file_path}
    ...    timeout=${timeout}    connection=${connection}
    Should Be True    ${snapshot_status}    msg=Failed to capture snapshot

    # Decompress snapshot
    Log To Console    \nDecompress snapshot to ${snapshot_extract_path}
    Create Directory    ${snapshot_extract_path}
    Run    unzip -o ${snapshot_zip_file_path} -d ${snapshot_extract_path}

    # Check if IQ log files exist
    ${radio_iq_files}    Run    grep ${radio_iq_data_pattern} ${snapshot_file_list_path} | wc -l
    ${radio_iq_files_count}    Convert To Integer    ${radio_iq_files}
    Should Be True    ${radio_iq_files_count} > 0    msg=IQ log files not found
    Log To Console    \nFound ${radio_iq_files_count} IQ log files
    ${du_iq_files}    Run    grep ${du_iq_data_pattern} ${snapshot_file_list_path} | wc -l
    ${du_iq_files_count}    Convert To Integer    ${du_iq_files}
    Should Be True    ${du_iq_files_count} > 0    msg=DU IQ log files not found
    Log To Console    \nFound ${du_iq_files_count} DU IQ log files

    # Check if the alarm is cleared
    Sleep    60s    # Wait for alarm status to update
    Wait Until Keyword Succeeds    5min    10s    Expect Fault Should Absent    faultId=${fault_id}
    Log To Console    \nThe alarm with fault ID ${fault_id} has been cleared

    # Check other alarms
    ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
    Should Be True    ${alarm_status}

TEST_UL_Time_Domain_IQ_Raw_Data_snapshot_for_eCPRI
    [Documentation]    This keyword simulates a single-user single-cell (SiSo) scenario to verify IQ data during L3 call
    ...                该关键字模拟单用户单小区（SiSo）场景下，验证L3通话情况下IQ data是否符合预期
    [Arguments]    ${with_call}=${True}    ${with_peak}=${False}    ${duration}=900    ${direction}=BOTH
    ...    ${upload_tp}=${True}    ${upload_duration}=${True}    ${ue_num_each_call}=1
    ...    ${suite_name}=default    ${test_name}=default    ${cell_id}=141
    Log To Console    \nExecuting TEST_UL_Time_Domain_IQ_Raw_Data_snapshot_for_eCPRI test

    # Get cell information
    ${cell_list}    Run Keyword If    ${cell_id} == ${None}    Get All Cell Id    ELSE    Create List    ${cell_id}
    ${cell_id}    Set Variable If    ${cell_id} == ${None}    ${cell_list[0]}    ${cell_id}

    # Step 1: Add Note MO configurations via REST API
    Add_Note_MO_Configuration

    # Step 2: Disable UL IQ capture and reset R&D debug parameters
    Disable_UL_IQ_Capture_And_Reset_PhyEventEnable

    # Step 3: Set R&D debug parameters for NrUlPhy domain
    Set_PhyEventEnableExt_Parameter

    # Step 4: Check cell status and configure UL L1 IQ capture
    Configure_L1_IQ_Capture_For_Cell    cell_id=${cell_id}

    # Step 5: Perform L3 call traffic test and verify throughput peaks
    Perform_L3_Call_And_Verify
    ...    cell_list=${cell_list}
    ...    with_call=${with_call}
    ...    with_peak=${with_peak}
    ...    duration=${duration}
    ...    direction=${direction}
    ...    upload_tp=${upload_tp}
    ...    upload_duration=${upload_duration}
    ...    suite_name=${suite_name}
    ...    test_name=${test_name}
    ...    ue_num_each_call=${ue_num_each_call}

    # Step 6: Check if base station reports fault ID 8101
    Check_For_Alarm_8101

    # Step 7: Capture and verify snapshot log, check IQ log files
    Capture_And_Verify_Snapshot

    # Step 8: Reset configuration by disabling UL IQ capture again
    Disable_UL_IQ_Capture_And_Reset_PhyEventEnable

    Log To Console    \nTEST_UL_Time_Domain_IQ_Raw_Data_snapshot_for_eCPRI test completed
