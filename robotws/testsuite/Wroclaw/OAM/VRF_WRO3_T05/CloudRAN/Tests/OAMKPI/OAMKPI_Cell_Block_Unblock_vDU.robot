*** Settings ***
Documentation
...    This test case is used to verify the KPI 17a (cell lock time) and
...    KPI 17b (cell unlock time) for vDU.
...    History of changes:     25.06.2025 - Initial creation
...                            06.11.2025 - TC Refactor for ute-ca - kasadows
...    Author:         lukasz.lechowicz@nokia.com

*** Keywords ***
OAMKPI Cell Block Unblock vDU
    [Documentation]
    ...    This keyword verifies the KPI 17a (cell block time) and KPI 17b (cell unblock time) for vDU.
    ...    It performs the following steps:
    ...    1. Ensures all NRCELLs are enabled before starting the test.
    ...    2. Measures time taken to block a cell (KPI 17a) by sending a block request and waiting for deactivation.
    ...    3. Measures time taken to unblock a cell (KPI 17b) by sending an unblock request and waiting for activation.
    ...    4. Downloads and filters the vDU syslog to extract timestamps for block and unblock operations.
    ...    5. Calculates the average KPI values and compares them with the target thresholds.
    ...    6. Validates that individual KPI results do not exceed 10% of the calculated average.
    ...    7. Generates a results file containing the KPI results, averages and target values.
    ...    Arguments:
    ...        - ${test_iterations}: Number of iterations to perform the block/unblock operations.
    ...        - ${KPI_17a_target}: Target time for KPI 17a (cell block time).
    ...        - ${KPI_17b_benchmark}: KPI 17b result (cell unblock time) from previous release.
    ...        - ${KPI_17a_benchmark}: KPI 17a result (cell block time) from previous release.
    ...        - ${KPI_17b_target}: Target time for KPI 17b (cell unblock time).
    ...    Returns:
    ...        - ${KPI_17a_avg}: Average time for KPI 17a across all iterations.
    ...        - ${KPI_17b_avg}: Average time for KPI 17b across all iterations.
    [Timeout]    12h
    [Arguments]    ${test_iterations}
    ...            ${KPI_17a_target}
    ...            ${KPI_17b_target}
    ...            ${KPI_17a_benchmark}
    ...            ${KPI_17b_benchmark}

    ${vDU_cell_list}=    vdu_admin.Get Vdu Cells Status    vdu_connection=${VDU_CONNECTION}
    ${selected_cell}=    Set Variable    ${vDU_cell_list[0]['id']}
    @{KPI_17a_results}=    Create List
    @{KPI_17b_results}=    Create List
    ${ok_logs_collected}=    Set Variable    ${False}
    FOR   ${i}    IN RANGE    ${test_iterations}
        ${index}    Evaluate    ${i} + 1
        Log To Console    \n--- Execution loop: ${index} ---\n
        Log To Console    Make sure all NRCELLs are enabled
        Wait Until Keyword Succeeds    200s    100ms    Verify All vDU Cells Are Enabled     vdu_connection=${VDU_CONNECTION}
        Log To Console    All NRCELLs are enabled
        ${KPI17a_start}=    DateTime.Get Current Date    time_zone=UTC
        sleep    1s    # small delay to avoid race condition
        Log To Console    Sending NRCELL block Request
        ${block_operation}=    vdu_admin.Block Cell    cell_id=${selected_cell}    vdu_connection=${VDU_CONNECTION}
        ${block_operation_id}=    Get From Dictionary    ${block_operation}    id
        Log To Console    Waiting For NRCELL Deactivation
        Wait Until Keyword Succeeds    60s    200ms    Verify At Least One vDU Cell Is Disabled    vdu_connection=${VDU_CONNECTION}
        Wait Until Keyword Succeeds    20s    200ms    Check Cell Block Is Completed    operation_id=${block_operation_id}
        Log To Console    NRCELL deactivated and blocked
        ${KPI17a_end}=    DateTime.Get Current Date    time_zone=UTC
        ${KPI17b_start}=    DateTime.Get Current Date    time_zone=UTC
        sleep    1s    # small delay to avoid race condition
        Log To Console    Sending NRCELL Unblock Request
        ${unblock_operation}=    vdu_admin.Unblock Cell    cell_id=${selected_cell}    vdu_connection=${VDU_CONNECTION}
        ${unblock_operation_id}=    Get From Dictionary    ${unblock_operation}    id
        Log To Console    Waiting For NRCELL Activation
        Wait Until Keyword Succeeds    60s    200ms    Check Cell Unblock Is Completed    operation_id=${unblock_operation_id}
        Wait Until Keyword Succeeds    60s    200ms    Verify All vDU Cells Are Enabled   vdu_connection=${VDU_CONNECTION}
        ${KPI17b_end}=    DateTime.Get Current Date    time_zone=UTC

        Log To Console    Downloading vDU Syslog For KPI Calculation
        ${vDU_syslog_path}=    Download vDU Syslog
        Log To Console    Filtering vDU Syslog Looking For Timestamps...
        ${block_request_syslog_filtered}=    Filter Log File
        ...    file_path=${vDU_syslog_path}
        ...    component=oamconfig
#        ...    keyword=BlockTaskHandler, Send block task    # keywords for 25R3
        ...    keyword=BlockIndHandler, Send block ind    # keywords for 26R1
        ...    exclude=INF/CCSBinDecoder
        ...    start_time_str=${KPI17a_start}
        ...    end_time_str=${KPI17a_end}
        ...    match_all_keywords=True
        ...    case_sensitive=True
        ${block_request_timestamp}=    Get Timestamp Of Event    ${block_request_syslog_filtered}    first

        ${cell_deactivation_syslog_filtered}=    Filter Log File
        ...    file_path=${vDU_syslog_path}
        ...    component=cprt
        ...    keyword=AntennaCarrierDeactivationResp
        ...    exclude=INF/CCSBinDecoder, oamconfig
        ...    start_time_str=${KPI17a_start}
        ...    end_time_str=${KPI17a_end}
        ...    match_all_keywords=True
        ...    case_sensitive=True
        ${cell_deactivation_timestamp}=    Get Timestamp Of Event    ${cell_deactivation_syslog_filtered}    first

        ${unblock_request_syslog_filtered}=    Filter Log File
        ...    file_path=${vDU_syslog_path}
        ...    component=oamconfig
#        ...    keyword=UnblockTaskHandler, Send unblock task    # keywords for 25R3
        ...    keyword=UnblockIndHandler, Send unblock ind    # keywords for 26R1
        ...    exclude=INF/CCSBinDecoder
        ...    start_time_str=${KPI17b_start}
        ...    end_time_str=${KPI17b_end}
        ...    match_all_keywords=True
        ...    case_sensitive=True
        ${unblock_request_timestamp}=    Get Timestamp Of Event    ${unblock_request_syslog_filtered}    first
        ${cell_activation_syslog_filtered}=    Filter Log File
        ...    file_path=${vDU_syslog_path}
        ...    component=cprt
        ...    keyword=AntennaCarrierActivationResp
        ...    exclude=INF/CCSBinDecoder, oamconfig
        ...    start_time_str=${KPI17b_start}
        ...    end_time_str=${KPI17b_end}
        ...    match_all_keywords=True
        ...    case_sensitive=True
        ${cell_activation_timestamp}=    Get Timestamp Of Event    ${cell_activation_syslog_filtered}    first

        ${KPI_17a}=    DateTime.Subtract Date From Date    ${cell_deactivation_timestamp}    ${block_request_timestamp}
        Append To List    ${KPI_17a_results}    ${KPI_17a}
        Log To Console    KPI 17a (Cell block Time): ${KPI_17a} seconds
        ${KPI_17b}=    DateTime.Subtract Date From Date    ${cell_activation_timestamp}    ${unblock_request_timestamp}
        Append To List    ${KPI_17b_results}    ${KPI_17b}
        Log To Console    KPI 17b (Cell Unblock Time): ${KPI_17b} seconds
        ${KPI_17a_check}=    Evaluate    ${KPI_17a} <= ${KPI_17a_target}
        Run Keyword And Continue On Failure    Should Be True    ${KPI_17a_check}
        ...                                    msg=KPI_17a value ${KPI_17a} exceeds ${KPI_17a_target}
        ${KPI_17b_check}=    Evaluate    ${KPI_17b} <= ${KPI_17b_target}
        Run Keyword And Continue On Failure    Should Be True    ${KPI_17b_check}
        ...                                    msg=KPI_17a value ${KPI_17b} exceeds ${KPI_17b_target}
        IF    ${KPI_17a_check}==False or ${KPI_17b_check}==False
            Log To Console    One of measured KPIs has exceeded the target. Gathering logs and continuing execution.
            Collect Logs    ${TEST_RESULTS_DIR}/logs_from_${index}_iteration_FAIL
        ELSE IF    not ${ok_logs_collected}
            Log To Console    Loop passed! Gathering ok logs to compare.
            ${ok_logs_collected}=    Set Variable    ${True}
            Collect Logs    ${TEST_RESULTS_DIR}/logs_from_${index}_iteration_PASS
        END

    END
    Log To Console    Calculating Average KPI Values And Comparing With Target...
    ${KPI_17a_avg}=    Run Keyword And Continue On Failure    Calculate Average KPI Values And Compare With Target
    ...                                                       kpi_results=${KPI_17a_results}
    ...                                                       kpi_target=${KPI_17a_target}
    ${KPI_17b_avg}=    Run Keyword And Continue On Failure    Calculate Average KPI Values And Compare With Target
    ...                                                       kpi_results=${KPI_17b_results}
    ...                                                       kpi_target=${KPI_17b_target}
    Log To Console     Comparing Average KPI Values With Previous Release Results...
    Run Keyword And Continue On Failure    Check Average KPI Value With Previous Release Result    ${KPI_17a_avg}    ${KPI_17a_benchmark}
    Run Keyword And Continue On Failure    Check Average KPI Value With Previous Release Result    ${KPI_17b_avg}    ${KPI_17b_benchmark}

    ${results}=     Create List     KPI 17a:    @{KPI_17a_results}s    KPI 17b:    @{KPI_17b_results}s
    ${averages}=    Create List     KPI 17a: ${KPI_17a_avg}s      KPI 17b: ${KPI_17b_avg}s
    ${targets}=     Create List     KPI 17a: ${KPI_17a_target}s       KPI 17b: ${KPI_17b_target}s
    ...                             KPI 17a_benchmark: ${KPI_17a_benchmark}s       KPI 17b_benchmark: ${KPI_17b_benchmark}s
    Create Results File    test_results=${results}     average_results=${averages}    target_values=${targets}
    [Return]    ${KPI_17a_avg}    ${KPI_17b_avg}

Check Cell Block Is Completed
    [Documentation]    Description:    Checks if the vDU cell block operation is completed successfully
    ...                Input:          operation_id of the block operation that needs to be checked
    ...                Author:         lukasz.lechowicz@nokia.com
    [Arguments]    ${operation_id}
    ${operation_summary}=    vdu_admin.Get Block Cell Operation Status    operation_id=${operation_id}
    ...                                                                   vdu_connection=${VDU_CONNECTION}
    ${block_operation_status}=    Get From Dictionary    ${operation_summary}    status
    Should Be Equal    ${block_operation_status}    success

Check Cell Unblock Is Completed
    [Documentation]    Description:    Checks if the vDU cell unblock operation is completed successfully
    ...                Input:          operation_id of the unblock operation that needs to be checked
    ...                Author:         lukasz.lechowicz@nokia.com
    [Arguments]    ${operation_id}
    ${operation_summary}=    vdu_admin.Get Unblock Cell Operation Status    operation_id=${operation_id}
    ...                                                                     vdu_connection=${VDU_CONNECTION}
    ${unblock_operation_status}=    Get From Dictionary    ${operation_summary}    status
    Should Be Equal    ${unblock_operation_status}    success