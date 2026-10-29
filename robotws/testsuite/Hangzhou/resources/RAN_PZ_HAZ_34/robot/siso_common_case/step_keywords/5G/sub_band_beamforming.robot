*** Settings ***
Documentation    Common keywords for sub-Band beamforming testing

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/recommissioning_and_make_throughput.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/aasyslog.robot

*** Keywords ***
Verify Cell If OnAir
    [Documentation]    Verify if a cell is OnAir and no unexpected alarms exist.
    ...                Steps:
    ...                1. Check if all cells are OnAir
    ...                2. Check that no unexpected alarms exist
    ...                3. Check that no unexpected history alarms exist
    Wait Until Keyword Succeeds    10min    30s    Check all cells info should be onair
    ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist    allowed_faults=${ALLOWED_FAULT}
    Should Be True    ${alarm_status}
    ${history_alarm_status}    Run Keyword And Return Status
    ...    Unexpect History Alarm Should Not Exist    allowed_faults=${ALLOWED_HISTORY_FAULT}
    Should Be True    ${history_alarm_status}

Run L3 Call Traffic Test
    [Documentation]    Run L3 call traffic test on all cells and check if the peak reaches target.
    ...                Steps:
    ...                1. Get all cell IDs and UEs for traffic test
    ...                2. Get traffic peak information
    ...                3. Attach UEs and start traffic
    ...                4. Verify peak throughput
    [Arguments]    ${suite_name}=default    ${test_name}=default    ${duration}=${900}
    ...    ${check_duration}=${90}    ${ue_num_each_call}=${1}    ${cell_list}=${None}    ${direction}=BOTH
    ${cell_list}    Run Keyword If    "${cell_list}" == "${None}"    Get All Cell Id    ELSE    Set Variable    ${cell_list}
    ${ue_index_list}    ${cell_list}    Get UE List for Given Cell List
    ...    cell_list=${cell_list}    ue_num_each_call=${ue_num_each_call}
    Set Test Variable    ${ue_index_list}
    ${testline_name}    Get Testline Name
    ${scf_dir}    ${scf_name}    Split Path    path=${Case_SCF_Path}
    ${ue_ul_layer}    Get UE UL Layer From UE Mapping File
    ...    testline_name=${testline_name}    scf_name=${scf_name}
    ${cell_and_peak_info}    Generate Peak Information    cell_list=${cell_list}    duration=${duration}
    ...    ue_ul_layer=${ue_ul_layer}    suite_name=${suite_name}    test_name=${test_name}
    ${ue_and_cell}    UE Attach And Start DL UL Traffic    ue_index_list=${ue_index_list}
    ...    cell_and_peak_info=${cell_and_peak_info}    duration=${duration}    direction=${direction}
    UE Verify Peak Throughput    ue_index_list=${ue_index_list}    ue_and_cell=${ue_and_cell}
    ...    cell_and_peak_info=${cell_and_peak_info}    duration=${check_duration}    direction=${direction}

Stop L3 Call Traffic Test
    [Documentation]    Stop L3 call traffic test and detach UEs.
    UE Stop DL UL Traffic And Detach    ue_index_list=${ue_index_list}

Start To Capture AASyslog
    [Documentation]    Start capturing AASyslog with specified filter.
    ...                Steps:
    ...                1. Teardown any existing AASyslog capture
    ...                2. Set up AASyslog preconditions
    ...                3. Start the AASyslog capture process
    [Arguments]    ${filter}=L2    ${log_name}=Aasys_SrsSubbandBm.txt    ${mode}=tcpdump
    Teardown the Aasyslog save progress    mode=${mode}
    Start the Aasyslog save progress    filter=${filter}    log_name=${log_name}    mode=${mode}
    Sleep    30

Verify AASyslog Via Filter
    [Documentation]    Verify AASyslog content by filtering for specific text.
    ...                Steps:
    ...                1. Stop AASyslog capture
    ...                2. Download the log file from gNB
    ...                3. Filter the log for specific content
    ...                4. Verify the filtered content exists
    [Arguments]    ${filter_param}    ${log_dir}=/tmp/    ${log_name}=Aasys_SrsSubbandBm.txt    ${mode}=tcpdump
    Teardown the Aasyslog save progress    mode=${mode}
    ${current_time}    DateTime.Get Current Date    result_format=%Y%m%d%H%M%S
    ${local_path}    Set Variable    ${TS_CASE_LOG_PATH}${current_time}_${log_name}
    Download aasyslog file from gNB    log_path=${log_dir}${log_name}    local_path=${local_path}
    ${filter_result}    Run    grep "${filter_param}" ${local_path}
    Should Contain    ${filter_result}    ${filter_param}    msg=Could not find '${filter_param}' in the log file
