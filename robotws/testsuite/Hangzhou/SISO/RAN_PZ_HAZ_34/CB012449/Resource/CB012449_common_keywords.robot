*** Settings ***
Documentation    Common keywords for CB012449 feature testing

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/recommissioning_and_make_throughput.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/aasyslog.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot


*** Keywords ***
Verify Throughput Stability With SRS Subband BM
    [Documentation]    Verify throughput stability during SrsSubbandBm parameter changes.
    ...                The keyword checks if traffic remains stable when actDlSrsSubbandBm is toggled.
    ...                Steps:
    ...                1. Configure actDlSrsSubbandBm=true
    ...                2. Verify cell is OnAir
    ...                3. Start syslog capture
    ...                4. Run traffic and verify peak throughput meets target
    ...                5. Stop syslog capture and check for "reason WIDEBAND"
    ...                6. Start syslog capture again
    ...                7. Stop traffic
    ...                8. Stop syslog and check for "reason SUBBAND"
    ...                9. Configure actDlSrsSubbandBm=false
    ...                10. Verify cell is OnAir
    [Arguments]    ${suite_name}=default    ${test_name}=default    ${cell_id}=${1}    ${duration}=${900}
    ...    ${check_duration}=${60}    ${ue_num_each_call}=${1}
    # Step 0: Get cell_id
    ${cell_list}    get all cell id    ru_index=1
    ${cell_id}    Get From List    ${cell_list}    0

    # Step 1: Configure actDlSrsSubbandBm=true
    Log    message=Step 1: Setting actDlSrsSubbandBm to true
    Modify Parameter Via REST API    parameter=actDlSrsSubbandBm    value=true    cell_id=${cell_id}

    # Step 2: Verify cell is OnAir
    Log    message=Step 2: Verifying cell is OnAir
    Verify Cell If OnAir

    # Step 3: Start syslog capture
    Log    message=Step 3: Starting syslog capture
    Start To Capture AASyslog    filter=L2-PS    log_name=Aasys_SrsSubbandBm.txt

    # Step 4: Run traffic and verify peak throughput
    Log    message=Step 4: Running traffic and verifying throughput
    Run L3 Call Traffic Test    suite_name=${suite_name}    test_name=${test_name}    duration=${duration}
    ...    check_duration=${check_duration}    ue_num_each_call=${ue_num_each_call}

    # Step 5: Stop syslog capture and check for WIDEBAND
    Log    message=Step 5: Stopping syslog capture and checking for 'reason WIDEBAND'
    Verify AASyslog Via Filter    filter_param=reason WIDEBAND

    # Step 6: Start syslog capture again
    Log    message=Step 6: Starting syslog capture again
    Start To Capture AASyslog    filter=L2-PS    log_name=Aasys_SrsSubbandBm.txt

    # Step 7: Stop traffic
    Log    message=Step 7: Stopping traffic
    Stop L3 Call Traffic Test

    # Step 8: Stop syslog and check for SUBBAND
    Log    message=Step 8: Stopping syslog capture and checking for 'reason SUBBAND'
    Verify AASyslog Via Filter    filter_param=reason SUBBAND

    # Step 9: Configure actDlSrsSubbandBm=false
    Log    message=Step 9: Setting actDlSrsSubbandBm to false
    Modify Parameter Via REST API    parameter=actDlSrsSubbandBm    value=false    cell_id=${cell_id}

    # Step 10: Verify cell is OnAir
    Log    message=Step 10: Verifying cell is OnAir
    Verify Cell If OnAir

Modify Parameter Via REST API
    [Documentation]    Modify a single parameter in a gNB cell via REST API.
    ...                Steps:
    ...                1. Online modify the parameter
    ...                2. Wait for parameter to take effect
    ...                3. Check if gNB and cells are ready
    ...                4. Verify the parameter value is as expected
    [Arguments]    ${parameter}    ${value}    ${cell_id}=${1}    ${connection}=GNB_OAM
    Log To Console    \nOnline modify ${parameter} to ${value}
    ${dist_name}    Set Variable    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl    connection=${connection}
    coam.perform_parameter_recommissioning    dist_name=${dist_name}    parameter=${parameter}
    ...    value=${value}    operation=update    connection=${connection}
    Log To Console    \nWait ${parameter} parameter to take effect
    Sleep    90s
    COAM Wait gnb And Cells ready    timeout=15min    connection=${connection}
    Connect to gnb coam via ssl    connection=${connection}
    ${dist_parameters}    coam.get_parameter_by_distname    dist_name=${dist_name}    connection=${connection}
    ${dist_parameter_value}    Set Variable    ${dist_parameters[0]['parameters']['${parameter}']}
    IF    ${{$dist_parameter_value in [True, False, 'True', 'False']}}
        ${dist_parameter_value}    Convert To String    ${dist_parameter_value}
        ${dist_parameter_value}    Set Variable    ${dist_parameter_value.lower()}
    END
    Should Be Equal As Strings    ${dist_parameter_value}    ${value}
    ...    msg=parameter ${parameter} value is not equal to ${value}

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
    [Documentation]    Run L3 call traffic test on all cells and check if the peak reaches 80% of target.
    ...                Steps:
    ...                1. Get all cell IDs and UEs for traffic test
    ...                2. Get traffic peak information
    ...                3. Attach UEs and start traffic
    ...                4. Verify peak throughput
    [Arguments]    ${suite_name}=default    ${test_name}=default    ${duration}=${900}
    ...    ${check_duration}=${90}    ${ue_num_each_call}=${1}
    ${cell_list}    Get All Cell Id
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
    ...    cell_and_peak_info=${cell_and_peak_info}    duration=${duration}
    UE Verify Peak Throughput    ue_index_list=${ue_index_list}    ue_and_cell=${ue_and_cell}
    ...    cell_and_peak_info=${cell_and_peak_info}    duration=${check_duration}

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
