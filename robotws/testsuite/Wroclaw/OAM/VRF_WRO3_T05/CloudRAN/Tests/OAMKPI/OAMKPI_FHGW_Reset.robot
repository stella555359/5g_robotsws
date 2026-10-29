*** Settings ***
Documentation
    ...    This test case verifies KPI 60a and 60c for FHGW reset procedure.
    ...    History of changes:     14.09.2025 - Initial creation
    ...    Author:         jakub.kokoszka@nokia.com

*** Keywords ***
OAMKPI FHGW Reset
    [Documentation]
    ...    This test case verifies KPI 60a and 60c for the FHGW reset process.
    ...    It performs multiple iterations of FHGW reset and monitors vDU cell behavior
    ...    to measure the time metrics for KPI calculation.
    ...
    ...    Steps performed in each iteration:
    ...        1. Initiates FHGW reset and records the reset start timestamp.
    ...        2. Creates a directory to store iteration-specific vDU syslog files.
    ...        3. Waits until at least one vDU cell is disabled.
    ...        4. Downloads vDU syslog to capture timestamps of cells going down.
    ...        5. Waits until vDU, RMOD, and vCU states are stable.
    ...        6. Downloads vDU syslog to capture timestamps of cells coming back up.
    ...        7. Filters syslog files to extract first/last cell down and first/last cell up timestamps.
    ...        8. Calculates KPI 60a (from first cell down to last cell up).
    ...        9. Calculates KPI 60c (from FHGW reset request to last cell up).
    ...       10. Validates KPI results against target thresholds.
    ...       11. Collects logs if KPI thresholds are exceeded; otherwise, removes temporary files.
    ...       12. Calculates average KPI values and compares with target values (+5% margin).
    ...       13. Generates a results file including iteration results, averages, and target values.

    ...    Arguments:
    ...        - ${test_iterations}:   Number of iterations to perform the lock/unlock operations.
    ...        - ${KPI_60a_target}:    Target time for KPI 60a.
    ...        - ${KPI_60c_target}:    Target time for KPI 60c.
    ...        - ${KPI_60a_benchmark}: KPI 60a result from previous release.
    ...        - ${KPI_60c_benchmark}: KPI 60c result from previous release.

    [Timeout]    12h
    [Arguments]    ${test_iterations}
    ...            ${KPI_60a_target}
    ...            ${KPI_60c_target}
    ...            ${KPI_60a_benchmark}
    ...            ${KPI_60c_benchmark}

    @{KPI_60a_results}=    Create List
    @{KPI_60c_results}=    Create List
    ${ok_logs_collected}=    Set Variable    ${False}

    FOR   ${i}    IN RANGE    ${test_iterations}
        ${index}=    Evaluate    ${i} + 1
        Log To Console    \n--- Execution loop: ${index} ---\n
        Log To Console    Start Reset FHGW
        ${FHGW_reboot_start_timestamp}=    Reset FHGW

        Log to console  FHGW reset time: ${FHGW_reboot_start_timestamp} UTC
        ${vdu_files_from_iteration}=    Set Variable  ${SUITE_LOGS_DIR_PATH}/vDU_files_from_${index}_iteration
        OperatingSystem.Create Directory    ${vdu_files_from_iteration}
        Wait Until Keyword Succeeds    90s    45s
        ...  Verify At Least One vDU Cell Is Disabled
        ...  vdu_connection=${VDU_CONNECTION}
        Log To Console    Downloading vDU syslog to check when the cells went down
        ${vDU_syslog_path_cells_down}=    syslog_download_from_vdu_vcu.Download vDU Syslog
        OperatingSystem.Move File
        ...    ${SUITE_LOGS_DIR_PATH}/vDU/full_vDU_syslog
        ...    ${vdu_files_from_iteration}/full_vDU_syslog_cells_down

        ${vDU_syslog_path_cells_down}=    Set Variable
        ...   ${vdu_files_from_iteration}/full_vDU_syslog_cells_down
        Wait Until Keyword Succeeds  20m  30s    cloud_frame.Check vDU And RMOD states    ${vdu_connection}
        Wait Until Keyword Succeeds  15m  30s    cloud_frame.Check Cell States On vDU    ${vdu_connection}
        Wait Until Keyword Succeeds  15m  30s    cloud_frame.Check vCU state    ${vcu_connection}

        ${cells_uptime}=    DateTime.Get Current Date    time_zone=UTC

        Log To Console    Downloading vDU syslog to check when the cells came up
        ${vCU_syslog_path_cells_up}=    syslog_download_from_vdu_vcu.Download vDU Syslog
        OperatingSystem.Move File
        ...    ${SUITE_LOGS_DIR_PATH}/vDU/full_vDU_syslog
        ...    ${vdu_files_from_iteration}/full_vDU_syslog_cells_up

        ${vDU_syslog_path_cells_up}=    Set Variable
        ...   ${vdu_files_from_iteration}/full_vDU_syslog_cells_up

        Log To Console    Filtering vDU Syslog Looking For cells down timestamps...
        ${cell_deactivation_syslog_filtered}=    Filter Log File
        ...    file_path=${vDU_syslog_path_cells_down}
        ...    component=cprt
        ...    keyword=AntennaCarrierDeactivationResp - OK
        ...    exclude=INF/CCSBinDecoder
        ...    start_time_str=${FHGW_reboot_start_timestamp}
        ...    end_time_str=
        ...    match_all_keywords=True
        ...    case_sensitive=True
        ${first_cell_down}=    Get Timestamp Of Event    ${cell_deactivation_syslog_filtered}    first
        ${last_cell_down}=     Get Timestamp Of Event    ${cell_deactivation_syslog_filtered}    last


        Log To Console    Filtering vDU Syslog Looking For cells up timestamps...
        ${cells_up_syslog_filtered}=    Filter Log File
        ...    file_path=${vDU_syslog_path_cells_up}
        ...    component=cprt
        ...    keyword=AntennaCarrierActivationResp - OK
        ...    exclude=INF/CCSBinDecoder
        ...    start_time_str=${FHGW_reboot_start_timestamp}
        ...    end_time_str=${cells_uptime}
        ...    match_all_keywords=True
        ...    case_sensitive=True
        ${first_cell_up}=    Get Timestamp Of Event    ${cells_up_syslog_filtered}    first
        ${last_cell_up}=     Get Timestamp Of Event    ${cells_up_syslog_filtered}    last

        ${KPI_60a}=    DateTime.Subtract Date From Date    ${last_cell_up}    ${first_cell_down}
        Append To List    ${KPI_60a_results}    ${KPI_60a}
        Log To Console    KPI 60a (from first cell down to last cell up): ${KPI_60a} seconds

        ${KPI_60c}=    DateTime.Subtract Date From Date    ${last_cell_up}    ${FHGW_reboot_start_timestamp}
        Append To List    ${KPI_60c_results}    ${KPI_60c}
        Log To Console    KPI 60c (from FHGW reset request to last cell up): ${KPI_60c} seconds



        ${KPI_60a_check}=    Evaluate    ${KPI_60a} <= ${KPI_60a_target}
        Run Keyword And Continue On Failure    Should Be True    ${KPI_60a_check}
        ...                                    msg=KPI_60a value ${KPI_60a} exceeds ${KPI_60a_target}


        ${KPI_60c_check}=    Evaluate    ${KPI_60c} <= ${KPI_60c_target}
        Run Keyword And Continue On Failure    Should Be True    ${KPI_60c_check}
        ...                                    msg=KPI_60c value ${KPI_60c} exceeds ${KPI_60c_target}

        IF    ${KPI_60a_check}==False or ${KPI_60c_check}==False
              Log To Console    One of measured KPIs has exceeded the target. Gathering logs and continuing execution.
              Collect Logs    ${TEST_RESULTS_DIR}/logs_from_${index}_iteration_FAIL
        ELSE
              OperatingSystem.Remove Directory    ${vdu_files_from_iteration}    recursive=True
              IF    not ${ok_logs_collected}
                  Log To Console    Gathering ok logs to compare and continuing execution.
                  ${ok_logs_collected}=    Set Variable    ${True}
                  Collect Logs    ${TEST_RESULTS_DIR}/logs_from_${index}_iteration_PASS
              END
        END
    END


    Log To Console    Calculating average KPI values and comparing with target...
    ${KPI_60a_avg}=    Run Keyword And Continue On Failure    Calculate Average KPI Values And Compare With Target
    ...                                                      kpi_results=${KPI_60a_results}
    ...                                                      kpi_target=${KPI_60a_target}

    ${KPI_60c_avg}=    Run Keyword And Continue On Failure    Calculate Average KPI Values And Compare With Target
    ...                                                      kpi_results=${KPI_60c_results}
    ...                                                      kpi_target=${KPI_60c_target}

    Log To Console     Comparing Average KPI Values With Previous Release Results...
    Run Keyword And Continue On Failure    Check Average KPI Value With Previous Release Result    ${KPI_60a_avg}    ${KPI_60a_benchmark}
    Run Keyword And Continue On Failure    Check Average KPI Value With Previous Release Result    ${KPI_60c_avg}    ${KPI_60c_benchmark}

    ${results}=     Create List     KPI 60a: @{KPI_60a_results}   KPI 60c: @{KPI_60c_results}
    ${averages}=    Create List     KPI 60a: ${KPI_60a_avg}s      KPI 60c: ${KPI_60c_avg}s
    ${targets}=     Create List     KPI 60a: ${KPI_60a_target}s       KPI 60c: ${KPI_60c_target}s
    ...                             KPI 60a benchmark: ${KPI_60a_benchmark}s       KPI 60c benchmark: ${KPI_60c_benchmark}s
    Create Results File    test_results=${results}     average_results=${averages}    target_values=${targets}
    [Return]     ${KPI_60a_avg}     ${KPI_60c_avg}

Reset FHGW
    ${fhgw_connection}=    connections.Connect to FHGW
    ${cmd_result}=         issh.Execute
    ...    command=fhgwcli has restart managed-object-type FMOD <<< y
    ...    alias=${fhgw_connection}
    ...    check_result=False
    ${time_match}=    String.Get Regexp Matches    ${cmd_result}    \\d{2}:\\d{2}:\\d{2}
    ${time_only}=     Set Variable    ${time_match[0]}
    ${minutes_seconds}=    Set Variable    ${time_only}[3:]
    ${utc_hour}=    DateTime.Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H
    ${FHGW_reboot_start_timestamp}=    Set Variable    ${utc_hour}:${minutes_seconds}.000

    [Return]      ${FHGW_reboot_start_timestamp}
    [Teardown]    issh.Disconnect    alias=${fhgw_connection}
