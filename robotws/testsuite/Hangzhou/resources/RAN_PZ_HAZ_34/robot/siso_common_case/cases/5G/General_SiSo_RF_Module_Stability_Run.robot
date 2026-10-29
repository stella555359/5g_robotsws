*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/operate_cell_and_check.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/rf_diagnostic_test.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/common/gnb_ru.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/5G/Cell/General_SiSo_Cell_block_and_unblock.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/5G/General_SiSo_RU_lock_unlock.robot


*** Keywords ***
General_SiSo_RF_Module_Stability_Run
    [Documentation]
    ...    *****************
    ...    Owner_shifu.lan@nokia-sbell.com
    ...    [TEST PURPOSE] Stability testing for RU families in regression.
    ...    ******************
    [Arguments]  ${ru_index}=${None}  ${temperature}=${100}  ${max_temp}=95  ${rf_port}=0  ${times}=${4}  ${ue_num_each_call}=${2}
    add fault to the history allowed fault list    faultId=${49}
    Selenium Login And Disable Screen Lock
    IF    ${ru_index}==${None}
        ${ru_index_list}    Get RU index list
    ELSE
        ${ru_index_list}    create list    ${ru_index}
    END
    Set Test Variable    ${ru_index_list}
    FOR    ${time}    IN RANGE    1    ${times}+1
        Log to console    \n---------------------\nstability run: ${time}/${times}
        Make L3 Call Stability Test    ru_index=${ru_index}    ue_num_each_call=${ue_num_each_call}
        Save Snapshot
        Cell Block And Unblock In WebEM    ru_index=${ru_index}
        RU Lock And Unlock In WebEM
        Enable 956 And Check In WebEM  RF_temperature_high_threshold=${temperature}  max_temperature=${max_temp}  rf_port_id=${rf_port}
    END
    [Teardown]  selenium logout and close browser

Make L3 Call Stability Test
    [Arguments]  ${ru_index}=${None}  ${duration}=${25200}  ${check_duration}=${1800}  ${ue_num_each_call}=${1}
    ...  ${suite_name}=default    ${test_name}=default
    log to console    \n========== Step 1: Make L3 Call Stability Test ==========
    ${cell_list}  Get All Cell Id    ru_index=${ru_index}
    ${ue_index_list}    ${cell_list}    Get UE List for Given Cell List    cell_list=${cell_list}    ue_num_each_call=${ue_num_each_call}
    ${testline_name}    Get Testline Name
    ${scf_dir}    ${scf_name}    split path    path=${Case_SCF_Path}
    ${ue_ul_layer}    get_ue_ul_layer_from_ue_mapping_file    testline_name=${testline_name}    scf_name=${scf_name}
    ${cell_and_peak_info}    generate peak information     cell_list=${cell_list}    duration=${duration}    ue_ul_layer=${ue_ul_layer}
    ...    suite_name=${suite_name}    test_name=${test_name}
    ${customized_cell_and_peak_info}    Get Customized Peak Info    src_peak_dict=${cell_and_peak_info}    percent=${0.4}
    ${ue_and_cell}    Ue Attach and Start DL UL Traffic    ue_index_list=${ue_index_list}
    ...    cell_and_peak_info=${customized_cell_and_peak_info}    duration=${duration}
    ${snapshot_flag}    Set Variable    ${True}
    ${check_tput_times}    Set Variable    ${{$duration // $check_duration}}    # check tput per 30min
    FOR  ${i}  IN RANGE  1  ${check_tput_times}
        ${status}    Run Keyword And Return Status    Ue Verify Peak Throughput    ue_index_list=${ue_index_list}
        ...    ue_and_cell=${ue_and_cell}    cell_and_peak_info=${customized_cell_and_peak_info}    duration=${check_duration}
        IF    ${status}==${False}
            IF    ${snapshot_flag}
                Log    \nPeak throughput verification failed at first time, save snapshot log for analysis.
                Save Coam Snapshot    target_dir=${SAVE LOG DIRECTORY}
                ${snapshot_flag}    Set Variable    ${False}
            END
            Run Keyword And Continue On Failure    Fail    msg=Peak throughput verification failed at ${i}th check
        END
    END
    Ue Stop DL UL Traffic and Detach    ue_index_list=${ue_index_list}
    check testline and alarm status

Get Customized Peak Info
    [Arguments]  ${src_peak_dict}  ${percent}=${0.4}  ${tp_unit}=M
    ${customized_peak_info}    create dictionary
    FOR    ${item}    IN    &{src_peak_dict}
        Log    Key is '${item}[0]' and value is '${item}[1]'.
        ${item_peak_info}        Set Variable    ${item}[1]
        Customize Peak Info With Number Format  src_tput_dict=${item}[1]  dst_tput_dict=${item_peak_info}  tput_key=dl_exp  percent=${percent}
        Customize Peak Info With Number Format  src_tput_dict=${item}[1]  dst_tput_dict=${item_peak_info}  tput_key=ul_exp  percent=${percent}
        Customize Peak Info With Number Format  src_tput_dict=${item}[1]  dst_tput_dict=${item_peak_info}  tput_key=peak_dl_tp  percent=${percent}
        Customize Peak Info With Number Format  src_tput_dict=${item}[1]  dst_tput_dict=${item_peak_info}  tput_key=peak_ul_tp  percent=${percent}
        Customize Peak Info With String Format  src_tput_dict=${item}[1]  dst_tput_dict=${item_peak_info}
        ...  tput_key=ul_tp  percent=${percent}  tp_unit=${tp_unit}
        Customize Peak Info With String Format  src_tput_dict=${item}[1]  dst_tput_dict=${item_peak_info}
        ...  tput_key=dl_tp  percent=${percent}  tp_unit=${tp_unit}
        Set To Dictionary    ${customized_peak_info}    ${item}[0]    ${item_peak_info}
    END
    Log    message=\n${customized_peak_info}
    RETURN    ${customized_peak_info}

Customize Peak Info With Number Format
    [Arguments]  ${src_tput_dict}  ${dst_tput_dict}  ${tput_key}  ${percent}=${0.4}
    Set To Dictionary    ${dst_tput_dict}    ${tput_key}    ${{$src_tput_dict['${tput_key}'] * $percent}}

Customize Peak Info With String Format
    [Arguments]  ${src_tput_dict}  ${dst_tput_dict}  ${tput_key}  ${percent}=${0.4}  ${tp_unit}=M
    ${tmp_tput}    Fetch From Left    ${src_tput_dict}[${tput_key}]    ${tp_unit}
    ${tmp_tput}    Catenate    SEPARATOR=    ${{float($tmp_tput) * $percent}}    ${tp_unit}
    Set To Dictionary    ${dst_tput_dict}    ${tput_key}    ${tmp_tput}

Save Snapshot
    log to console    \n========== Step 2: Save Snapshot ==========
    Save Coam Snapshot    target_dir=${SAVE LOG DIRECTORY}
    check testline and alarm status

Cell Block And Unblock In WebEM
    [Arguments]  ${ru_index}=${None}   ${technology}=NR
    log to console    \n========== Step 3: Cell Block And Unblock In WebEM ==========
    ${cell_type}    Set Variable    ${technology.lower()}
    ${cell_list}  Get All Cell Id    cell_type=${cell_type}    ru_index=${ru_index}
    FOR  ${cell_index}  IN  @{cell_list}
        selenium_coam.block_cell    cell_idx=${cell_index}    technology=${technology}
        Wait Until Keyword Succeeds   3 min  10 sec   check single cell should be blocked   cell_idx=${cell_index}   cell_type=${cell_type}
    END
    Wait For Expect Fault Present    faultId=49    timeout=30
    FOR  ${cell_index}  IN  @{cell_list}
        selenium_coam.unblock_cell    cell_idx=${cell_index}    technology=${technology}
        Wait Until Keyword Succeeds   5 min  10 sec   check single cell should be unblocked   cell_idx=${cell_index}   cell_type=${cell_type}
    END
    Wait For Expect Fault To Disappear  faultId=49    timeout=60
    check testline and alarm status

RU Lock And Unlock In WebEM
    log to console    \n========== Step 4: RU Lock And Unlock In WebEM ==========
    FOR  ${ru_index}  IN  @{ru_index_list}
        selenium_coam.lock_ru    ru_index=${ru_index}
        sleep  15
        wait until keyword succeeds    5min    20sec    RU Should Be Locked    ru_index=${ru_index}
        ${cell_id_ru}    Get All Cell Id    ru_index=${ru_index}
        wait until keyword succeeds    5min    20sec    Cell status Should Be Disabled    cell_list=${cell_id_ru}
    END
    FOR  ${ru_index}  IN  @{ru_index_list}
        ${status}    run keyword and return status  Expect Fault Should Present    faultId=4687
        selenium_coam.unlock_ru    ru_index=${ru_index}
        sleep  15
        Run Keyword If  ${status}==${True}    wait until keyword succeeds    10min    20sec    RU Should Be Offline    ru_index=${ru_index}
        wait until keyword succeeds    10min    20sec    RU Should Be Online    ru_index=${ru_index}
        ${cell_id_ru}    Get All Cell Id    ru_index=${ru_index}
        sort list    ${cell_id_ru}
        wait until keyword succeeds    5min    20sec    RU Should Be Unlocked    ru_index=${ru_index}
        wait until keyword succeeds    5min    20sec    Cell status Should Be enabled    cell_list=${cell_id_ru}
    END
    check testline and alarm status

Enable 956 And Check In WebEM
    log to console    \n========== Step 5: Enable 956 And Check In WebEM ==========
    [Arguments]  ${RF_temperature_high_threshold}=${100}    ${outcome}=Pass
    ...          ${min_temperature}=40    ${max_temperature}=95    ${rf_port_id}=0
    Delete RFTHLD If Exist
    Set default value for RFTHLD If Feature 956 Enabled
    ${bts_thresholds}    create dictionary    RF temperature high threshold=${RF_temperature_high_threshold}
    FOR  ${ru_index}  IN  @{ru_index_list}
        RF statistics diagnostic test setup    bts_thresholds=${bts_thresholds}    radio_id=${ru_index}
        sleep  30
        Check Statistics General Information    radio_id=${ru_index}    outcome=${outcome}
        Check RF Temperature Supervision    radio_id=${ru_index}    min_temperature=${min_temperature}    max_temperature=${max_temperature}
        Check RF Ethernet Packet Monitoring    radio_id=${ru_index}    rf_port_id=${rf_port_id}
    END
    check testline and alarm status

check testline and alarm status
    log to console    \ncheck testline and alarm status
    ${ru_status}    Run Keyword And Return Status    COAM Check GNB RU status
    should be true  ${ru_status}
    ${cell_status}    Run Keyword And Return Status    Check all cells info should be onair
    should be true  ${cell_status}
    ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
    should be true  ${alarm_status}
    ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist
    ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}
