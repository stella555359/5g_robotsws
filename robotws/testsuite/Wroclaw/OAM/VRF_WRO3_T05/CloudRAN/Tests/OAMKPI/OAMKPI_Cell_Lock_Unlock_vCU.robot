*** Settings ***
Documentation
    ...    This test case is used to verify the KPI 17a (cell lock time) and
    ...    KPI 16b (cell unlock time) for vCU.
    ...    History of changes:     25.06.2025 - Initial creation
    ...    Author:         lukasz.lechowicz@nokia.com

*** Keywords ***
OAMKPI Cell Lock Unlock vCU
    [Documentation]
    ...    This keyword verifies the KPI 16a (cell lock time) and KPI 16b (cell unlock time) for vCU.
    ...    It performs the following steps:
    ...    1. Ensures all NRCELLs are enabled before starting the test.
    ...    2. Measures time taken to lock a cell (KPI 16a) by sending a lock request and waiting for deactivation.
    ...    3. Measures time taken to unlock a cell (KPI 16b) by sending an unlock request and waiting for activation.
    ...    4. Downloads and filters the vCU syslog to extract timestamps for lock and unlock operations.
    ...    5. Calculates the average KPI values and compares them with the target thresholds.
    ...    6. Validates that individual KPI results do not exceed 10% of the calculated average.
    ...    7. Generates a results file containing the KPI results, averages, and target values.
    ...    Arguments:
    ...        - ${test_iterations}: Number of iterations to perform the lock/unlock operations.
    ...        - ${KPI_16a_target}: Target time for KPI 16a (cell lock time).
    ...        - ${KPI_16b_target}: Target time for KPI 16b (cell unlock time).
    ...    Returns:
    ...        - ${KPI_16a_avg}: Average time for KPI 16a across all iterations.
    ...        - ${KPI_16b_avg}: Average time for KPI 16b across all iterations.
    [Timeout]    12h
    [Arguments]    ${test_iterations}
    ...            ${KPI_16a_target}
    ...            ${KPI_16b_target}

    ${vcu_cell_list}=    vcu_admin.get_cells_statuses    connection=${VCU_CONNECTION}
    ${selected_cell}=    Create List    ${vcu_cell_list[0]['id']}
    @{KPI_16a_results}=    Create List
    @{KPI_16b_results}=    Create List
    FOR   ${i}    IN RANGE    ${test_iterations}
        Log To Console    \n--- Execution loop: ${i + 1} ---\n
        Log To Console    Make sure all NRCELLs are enabled
        Wait Until Keyword Succeeds    200s    100ms    Verify All vCU Cells Are Enabled  connection=${VCU_CONNECTION}
        Log To Console    All NRCELLs are enabled

        ${KPI16a_start}=    DateTime.Get Current Date    time_zone=UTC
        sleep    1s    # small delay to avoid race condition
        Log To Console    Sending NRCELL Lock Request
        ${lock_operation}=    vcu_admin.lock cells    cell_ids=${selected_cell}    connection=${VCU_CONNECTION}
        ${lock_operation_id}=    Get From Dictionary    ${lock_operation}    id
        Log To Console    Waiting For NRCELL Deactivation
        Wait Until Keyword Succeeds    120s    200ms    Verify At Least One vCU Cell Is Disabled    connection=${VCU_CONNECTION}
        Wait Until Keyword Succeeds    60s    200ms    Check Cell Lock Is Completed    operation_id=${lock_operation_id}
        Log To Console    NRCELL Deactivated and Locked
        ${KPI16a_end}=    DateTime.Get Current Date    time_zone=UTC
        ${KPI16b_start}=    DateTime.Get Current Date    time_zone=UTC
        sleep    1s    # small delay to avoid race condition
        Log To Console    Sending NRCELL Unlock Request
        ${unlock_operation}=    vcu_admin.unlock cells    cell_ids=${selected_cell}    connection=${VCU_CONNECTION}
        ${unlock_operation_id}=    Get From Dictionary    ${unlock_operation}    id
        Log To Console    Waiting For NRCELL Activation
        Wait Until Keyword Succeeds    120s    200ms    Check Cell Unlock Is Completed    operation_id=${unlock_operation_id}
        Wait Until Keyword Succeeds    60s    200ms    Verify All vCU Cells Are Enabled   connection=${VCU_CONNECTION}
        Log To Console    NRCELL Unlocked And Activated
        ${KPI16b_end}=    DateTime.Get Current Date    time_zone=UTC

        Log To Console    Downloading vCU Syslog For KPI Calculation
        ${vCU_syslog_path}=    Download vCU Syslog
        Log To Console    Filtering vCU Syslog Looking For Timestamps...
        ${lock_request_syslog_filtered}=    Filter Log File
        ...    file_path=${vCU_syslog_path}
        ...    component=oamconfig
        ...    keyword=/api/cp-config/v1/cells/operations/locks?ids
        ...    exclude=INF/CCSBinDecoder
        ...    start_time_str=${KPI16a_start}
        ...    end_time_str=${KPI16a_end}
        ...    match_all_keywords=True
        ...    case_sensitive=True
        ${lock_request_timestamp}=    Get Timestamp Of Event    ${lock_request_syslog_filtered}    first

        ${cell_deactivation_syslog_filtered}=    Filter Log File
        ...    file_path=${vCU_syslog_path}
        ...    component=cpnb
        ...    keyword=ConcreteOAMInterface.cpp, cellToDeactivateList:[[{, cellToActivateList:[[]], CellStatusInd
        ...    exclude=INF/CCSBinDecoder
        ...    start_time_str=${KPI16a_start}
        ...    end_time_str=${KPI16a_end}
        ...    match_all_keywords=True
        ...    case_sensitive=True
        ${cell_deactivation_timestamp}=    Get Timestamp Of Event    ${cell_deactivation_syslog_filtered}    first

        ${unlock_request_syslog_filtered}=    Filter Log File
        ...    file_path=${vCU_syslog_path}
        ...    component=oamconfig
        ...    keyword=/api/cp-config/v1/cells/operations/unlocks?ids
        ...    exclude=INF/CCSBinDecoder
        ...    start_time_str=${KPI16b_start}
        ...    end_time_str=${KPI16b_end}
        ...    match_all_keywords=True
        ...    case_sensitive=True
        ${unlock_request_timestamp}=    Get Timestamp Of Event    ${unlock_request_syslog_filtered}    first
        ${cell_activation_syslog_filtered}=    Filter Log File
        ...    file_path=${vCU_syslog_path}
        ...    component=cpnb
        ...    keyword=ConcreteOAMInterface.cpp, cellToDeactivateList:[[]], cellToActivateList:[[{, CellStatusInd
        ...    exclude=INF/CCSBinDecoder
        ...    start_time_str=${KPI16b_start}
        ...    end_time_str=${KPI16b_end}
        ...    match_all_keywords=True
        ...    case_sensitive=True
        ${cell_activation_timestamp}=    Get Timestamp Of Event    ${cell_activation_syslog_filtered}    first

        ${KPI_16a}=    DateTime.Subtract Date From Date    ${cell_deactivation_timestamp}    ${lock_request_timestamp}
        Append To List    ${KPI_16a_results}    ${KPI_16a}
        Log To Console    KPI 16a (Cell Lock Time): ${KPI_16a} seconds
        ${KPI_16b}=    DateTime.Subtract Date From Date    ${cell_activation_timestamp}    ${unlock_request_timestamp}
        Append To List    ${KPI_16b_results}    ${KPI_16b}
        Log To Console    KPI 16b (Cell Unlock Time): ${KPI_16b} seconds
        ${KPI_16a_check}=    Evaluate    ${KPI_16a} <= ${KPI_16a_target}
        Run Keyword And Continue On Failure    Should Be True    ${KPI_16a_check}
        ...                                    msg=KPI_16a value ${KPI_16a} exceeds ${KPI_16a_target}
        ${KPI_16b_check}=    Evaluate    ${KPI_16b} <= ${KPI_16b_target}
        Run Keyword And Continue On Failure    Should Be True    ${KPI_16b_check}
        ...                                    msg=KPI_16a value ${KPI_16b} exceeds ${KPI_16b_target}
        IF    ${KPI_16a_check}==False or ${KPI_16b_check}==False
            Log To Console    One of measured KPIs has exceeded the target. Gathering logs and continuing execution.
            Collect Logs
        END

    END
    Log To Console    Calculating Average KPI Values And Comparing With Target...
    ${KPI_16a_avg}=    Run Keyword And Continue On Failure    Calculate Average KPI Values And Compare With Target
    ...                                                       kpi_results=${KPI_16a_results}
    ...                                                       kpi_target=${KPI_16a_target}
    ${KPI_16b_avg}=    Run Keyword And Continue On Failure    Calculate Average KPI Values And Compare With Target
    ...                                                       kpi_results=${KPI_16b_results}
    ...                                                       kpi_target=${KPI_16b_target}
    ${KPI_16a_threshold}=    Run Keyword And Continue On Failure    Evaluate    ${KPI_16a_avg} * 1.05
    ${KPI_16b_threshold}=    Run Keyword And Continue On Failure    Evaluate    ${KPI_16b_avg} * 1.05
    FOR    ${result}    IN    @{KPI_16a_results}
        Run Keyword And Continue On Failure    Should Be True    ${result} <= ${KPI_16a_threshold}
        ...                                    msg=KPI_16a value ${result} exceeds 5% threshold ${KPI_16a_threshold}
    END
    FOR    ${result}    IN    @{KPI_16b_results}
        Run Keyword And Continue On Failure    Should Be True    ${result} <= ${KPI_16b_threshold}
        ...                                    msg=KPI_16b value ${result} exceeds 5% threshold ${KPI_16b_threshold}
    END

    ${results}=     Create List     KPI 16a:    @{KPI_16a_results}    KPI 16b:    @{KPI_16b_results}
    ${averages}=    Create List     KPI 16a: ${KPI_16a_avg}s      KPI 16b: ${KPI_16b_avg}s
    ${targets}=     Create List     KPI 16a: ${KPI_16a_target}s       KPI 16b: ${KPI_16b_target}s
    Create Results File    test_results=${results}     average_results=${averages}    target_values=${targets}
    [Return]    ${KPI_16a_avg}    ${KPI_16b_avg}

Check Cell Lock Is Completed
    [Documentation]    Description:    Checks if the vCU cell lock operation is completed successfully
    ...                Input:          operation_id of the lock operation that needs to be checked
    ...                Author:         lukasz.lechowicz@nokia.com
    [Arguments]    ${operation_id}
    ${operation_summary}=    vcu_admin.Get Operation State Of Locking Cells    operation_id=${operation_id}
    ...                                                                        connection=${VCU_CONNECTION}
    ${lock_operation_status}=    Get From Dictionary    ${operation_summary}    status
    Should Be Equal    ${lock_operation_status}    success

Check Cell Unlock Is Completed
    [Documentation]    Description:    Checks if the vCU cell unlock operation is completed successfully
    ...                Input:          operation_id of the unlock operation that needs to be checked
    ...                Author:         lukasz.lechowicz@nokia.com
    [Arguments]    ${operation_id}
    ${operation_summary}=   vcu_admin.Get Operation State Of Unlocking Cells    operation_id=${operation_id}
    ...                                                                         connection=${VCU_CONNECTION}
    ${unlock_operation_status}=    Get From Dictionary    ${operation_summary}    status
    Should Be Equal    ${unlock_operation_status}    success
