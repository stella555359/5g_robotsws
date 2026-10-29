*** Settings ***
Documentation
...    This test case is used to verify the KPI 52a and 52b for vDU
...    History of changes:     14.07.2025 - Initial creation
...                            06.11.2025 - TC Refactor for ute-ca - kasadows
...    Author:         jakub.kokoszka@nokia.com

*** Keywords ***
OAMKPI CNF Reset vDU
    [Documentation]
    ...    This keyword verifies the KPI 52a and 52b for vDU
    ...    It performs the following steps:
    ...    0. Retrieves the list of NR cell identities, checks the technology of each cell (FDD, TDD or MIX),
    ...       and sets the KPI target based on the technology.
    ...    1. Performing vDU reset
    ...    2. Downloading vDU syslog to check when the cells went down
    ...    3. Downloading vDU syslog to check when the cells came up
    ...    4. Calculates the average KPI values and compares them with the target thresholds.
    ...    5. Validates that individual KPI results do not exceed 5% of the calculated average.
    ...    6. Generates a results file containing the KPI results, averages, and target values.
    ...    Arguments:
    ...        - ${test_iterations}: Number of iterations to perform the lock/unlock operations.
    ...        - ${targets}: list of KPI targets
    ...    Returns:
    ...        - ${KPI_52a_avg}: Average time for KPI 52a across all iterations.
    ...        - ${KPI_52b_avg}: Average time for KPI 52b across all iterations.

    [Timeout]    12h
    [Arguments]    ${test_iterations}
    ...            ${targets}


    @{KPI_52a_results}=     Create List
    @{KPI_52b_results}=    Create List
    ${ok_logs_collected}=    Set Variable    ${False}

    Log To Console    \n--- Precondition ---\n

    ${cells_info}=    Get Nr Cell Identity
    ${cells_status}     vdu.Get Vdu Cells Status    vdu_connection=${vdu_connection}
    ${cells_id}    Evaluate    [item['id'] for item in ${cells_status}]
    ${cells_technology}    Evaluate    [item['technology'] for item in ${cells_status}]
    ${fdd_or_tdd}    Check If All Cells Are FDD or TDD    ${cells_technology}
    ${count}=    Get Length    ${cells_id}
    Set Test Variable  ${count}
    IF    '${fdd_or_tdd}' == 'TDD'
        Run Keyword    Set TDD KPI target    ${targets}
    ELSE IF    '${fdd_or_tdd}' == 'FDD'
        Run Keyword    Set FDD KPI target    ${targets}
    ELSE IF    '${fdd_or_tdd}' == 'MIX'
        Run Keyword    Set MIX KPI target    ${targets}
    ELSE
        Fail    Unsupported configuration: Fatal error.
    END

    FOR   ${i}    IN RANGE    ${test_iterations}
        TRY
            ${index}    Evaluate    ${i} + 1
            Log To Console    \n--- Execution loop: ${index} ---\n
            ${vdu_files_from_iteration}=    Set Variable  ${SUITE_LOGS_DIR_PATH}/vDU_files_from_${index}_iteration
            OperatingSystem.Create Directory    ${vdu_files_from_iteration}
            Log To Console    Performing vDU reset
            ${out}=    vdu_admin.Reset vDU    vdu_connection=${vdu_connection}
            Should Be Equal    ${out['status']}    ongoing
            ${reset_time}=    DateTime.Get Current Date    time_zone=UTC
            Wait Until Keyword Succeeds  20m  5s    Check vDU states    ${vdu_connection}
            Log To Console    Downloading vDU syslog to check when the cells went down
            ${vDU_syslog_path_cells_down}=    syslog_download_from_vdu_vcu.Download vDU Syslog
            OperatingSystem.Move File
            ...    ${SUITE_LOGS_DIR_PATH}/vDU/full_vDU_syslog
            ...    ${vdu_files_from_iteration}/full_vDU_syslog_cells_down

            ${vDU_syslog_path_cells_down}    Set Variable
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

            ${vDU_syslog_path_cells_up}    Set Variable
            ...   ${vdu_files_from_iteration}/full_vDU_syslog_cells_up

            Log To Console    Filtering vDU Syslog Looking For cells down timestamps...
            ${cell_deactivation_syslog_filtered}=    Filter Log File
            ...    file_path=${vDU_syslog_path_cells_down}
            ...    component=cprt
            ...    keyword=AntennaCarrierDeactivationResp - OK
            ...    exclude=INF/CCSBinDecoder
            ...    start_time_str=${reset_time}
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
            ...    start_time_str=${reset_time}
            ...    end_time_str=${cells_uptime}
            ...    match_all_keywords=True
            ...    case_sensitive=True
            ${first_cell_up}=    Get Timestamp Of Event    ${cells_up_syslog_filtered}    first
            ${last_cell_up}=     Get Timestamp Of Event    ${cells_up_syslog_filtered}    last


            ${KPI_52a}=    DateTime.Subtract Date From Date    ${last_cell_up}    ${first_cell_down}
            Append To List    ${KPI_52a_results}    ${KPI_52a}
            Log To Console    KPI 52a (from first cell down to last cell up): ${KPI_52a} seconds
            ${KPI_52b}=    DateTime.Subtract Date From Date    ${first_cell_up}    ${last_cell_down}
            Append To List    ${KPI_52b_results}    ${KPI_52b}
            Log To Console    KPI 52b (from last cell down to first cell up): ${KPI_52b} seconds

            ${KPI_52a_check}=    Evaluate    ${KPI_52a} <= ${KPI_52a_target}
            Run Keyword And Continue On Failure    Should Be True    ${KPI_52a_check}
            ...                                    msg=KPI_52a value ${KPI_52a} exceeds ${KPI_52a_target}

            ${KPI_52b_check}=    Evaluate    ${KPI_52b} <= ${KPI_52b_target}
            Run Keyword And Continue On Failure    Should Be True    ${KPI_52b_check}
            ...                                    msg=KPI_52b value ${KPI_52b} exceeds ${KPI_52b_target}

            IF    ${KPI_52b_check}==False or ${KPI_52a_check}==False
                Log To Console    One of measured KPIs has exceeded the target. Gathering logs and continuing execution.
                Collect Logs    ${TEST_RESULTS_DIR}/logs_from_${index}_iteration_FAIL
            ELSE
                OperatingSystem.Remove Directory    ${vdu_files_from_iteration}    recursive=True
                IF    not ${ok_logs_collected}
                    Log To Console    Gathering ok logs and continuing execution.
                    ${ok_logs_collected}=    Set Variable    ${True}
                    Collect Logs    ${TEST_RESULTS_DIR}/logs_from_${index}_iteration_PASS
                END
            END
        EXCEPT    AS    ${ERROR}
            Run Keyword And Continue On Failure    Fail
            ...    msg=\n--- Loop FAILED! ---\nException occurred:\n${ERROR}\nGathering logs and continuing execution.\n
            Collect Logs    results_directory=${TEST_RESULTS_DIR}/logs_from_${i}_iteration_EXCEPTION
        END
    END

    Log To Console    Calculating average kpi values and comparing with target...
    ${KPI_52a_avg}=    Run Keyword And Continue On Failure    Calculate Average KPI Values And Compare With Target
    ...                                                      kpi_results=${KPI_52a_results}
    ...                                                      kpi_target=${KPI_52a_target}

    ${KPI_52b_avg}=    Run Keyword And Continue On Failure    Calculate Average KPI Values And Compare With Target
    ...                                                      kpi_results=${KPI_52b_results}
    ...                                                      kpi_target=${KPI_52b_target}

    Run Keyword And Continue On Failure    Check Average KPI Value With Previous Release Result    ${KPI_52a_avg}    ${KPI_52a_avg_benchmark}
    Run Keyword And Continue On Failure    Check Average KPI Value With Previous Release Result    ${KPI_52b_avg}    ${KPI_52b_avg_benchmark}

    ${results}=     Create List     KPI 52a: @{KPI_52a_results}    KPI 52b: @{KPI_52b_results}
    ${averages}=    Create List     KPI 52a: ${KPI_52a_avg}s       KPI 52b: ${KPI_52b_avg}s
    ${targets}=     Create List     KPI 52a: ${KPI_52a_target}s    KPI 52b: ${KPI_52b_target}s
    Create Results File    test_results=${results}     average_results=${averages}    target_values=${targets}
    [Return]    ${KPI_52a_avg}    ${KPI_52b_avg}

Get Nr Cell Identity
    [Documentation]
    ...  This KW retrieves the list of nr cells identity

    ${nr_cell_identity}=    Create List
    ${cells_info}=    vdu_admin.Get Vdu Cells Status    vdu_connection=${vdu_connection}
    FOR    ${cell_info}    IN    @{cells_info}
          Append To List    ${nr_cell_identity}    ${cell_info["nr_cell_identity"]}
    END
   [Return]    ${nr_cell_identity}

Check If All Cells Are FDD or TDD
    [Documentation]
    ...  This KW checks if all cells are FDD or TDD and returns the appropriate value.
    [Arguments]    ${cells_technology}
    ${all_fdd}=    Evaluate    all(item == 'FDD' for item in ${cells_technology})
    ${all_tdd}=    Evaluate    all(item == 'TDD' for item in ${cells_technology})
    Return From Keyword If    ${all_fdd}    FDD
    Return From Keyword If    ${all_tdd}    TDD
    RETURN    MIX

Set TDD KPI target
    [Documentation]
    ...  This KW sets the TDD KPI target based on the number of cells in the configuration
    [Arguments]    ${targets}

    ${adjusted_count_TDD}=    Set Variable    0
    ${adjusted_count_TDD}=    Evaluate    ${count} > 3 and ${count} * 15 or 0

    ${vDU_release}=       Get From Dictionary    ${sw_info['vDU']}    release
    ${KPI_52a_target_TDD}=     Get From Dictionary    ${targets}    KPI_52a_TDD_${vDU_release}_target
    ${KPI_52b_target_TDD}=     Get From Dictionary    ${targets}    KPI_52b_TDD_${vDU_release}_target
    ${KPI_52a_avg_benchmark}=     Get From Dictionary    ${targets}    KPI_52a_TDD_${vDU_release}_avg_benchmark
    Set Test Variable    ${KPI_52a_avg_benchmark}
    ${KPI_52b_avg_benchmark}=     Get From Dictionary    ${targets}    KPI_52b_TDD_${vDU_release}_avg_benchmark
    Set Test Variable    ${KPI_52b_avg_benchmark}

    ${KPI_52a_target_TDD}=    Evaluate    ${KPI_52a_target_TDD} + ${adjusted_count_TDD}
    Set Test Variable    ${KPI_52a_target}    ${KPI_52a_target_TDD}
    ${KPI_52b_target_TDD}=    Evaluate    ${KPI_52b_target_TDD} + ${adjusted_count_TDD}
    Set Test Variable    ${KPI_52b_target}    ${KPI_52b_target_TDD}

Set FDD KPI target
    [Documentation]
    ...  This KW sets the FDD KPI target based on the number of cells in the configuration
    [Arguments]    ${targets}

    ${adjusted_count_FDD}=    Set Variable    0
    ${adjusted_count_FDD}=    Evaluate    ${count} > 3 and ${count} * 10 or 0

    ${vDU_release}=       Get From Dictionary    ${sw_info['vDU']}    release
    ${KPI_52a_target_FDD}=     Get From Dictionary    ${targets}    KPI_52a_FDD_${vDU_release}_target
    ${KPI_52b_target_FDD}=     Get From Dictionary    ${targets}    KPI_52b_FDD_${vDU_release}_target
    ${KPI_52a_avg_benchmark}=     Get From Dictionary    ${targets}    KPI_52a_FDD_${vDU_release}_avg_benchmark
    Set Test Variable    ${KPI_52a_avg_benchmark}
    ${KPI_52b_avg_benchmark}=     Get From Dictionary    ${targets}    KPI_52b_FDD_${vDU_release}_avg_benchmark
    Set Test Variable    ${KPI_52b_avg_benchmark}

    ${KPI_52a_target_FDD}=    Evaluate    ${KPI_52a_target_FDD} + ${adjusted_count_FDD}
    Set Test Variable    ${KPI_52a_target}    ${KPI_52a_target_FDD}
    ${KPI_52b_target_FDD}=    Evaluate    ${KPI_52b_target_FDD} + ${adjusted_count_FDD}
    Set Test Variable    ${KPI_52b_target}    ${KPI_52b_target_FDD}

Set MIX KPI target
    [Documentation]
    ...  This KW sets the FDD & TDD KPI target based on the number of cells in the configuration
    [Arguments]    ${targets}

    ${cells_status}     vdu.Get Vdu Cells Status    vdu_connection=${vdu_connection}
    ${tdd_cells}=    Evaluate    [item['id'] for item in ${cells_status} if item['technology'] == 'TDD']
    ${tdd_cells_count}=    Get Length    ${tdd_cells}
    ${fdd_cells}=    Evaluate    [item['id'] for item in ${cells_status} if item['technology'] == 'FDD']
    ${fdd_cells_count}=    Get Length    ${fdd_cells}
    ${adjusted_count_FDD}=    Set Variable    0
    ${adjusted_count_TDD}=    Set Variable    0
    ${adjusted_count_FDD}=    Evaluate    ${fdd_cells_count} > 3 and ${fdd_cells_count} * 10 or 0
    ${adjusted_count_TDD}=    Evaluate    ${tdd_cells_count} > 3 and ${tdd_cells_count} * 15 or 0

    ${vDU_release}=       Get From Dictionary    ${sw_info['vDU']}    release
    ${KPI_52a_target_MIX}=     Get From Dictionary    ${targets}    KPI_52a_MIX_${vDU_release}_target
    ${KPI_52b_target_MIX}=     Get From Dictionary    ${targets}    KPI_52b_MIX_${vDU_release}_target
    ${KPI_52a_avg_benchmark}=     Get From Dictionary    ${targets}    KPI_52a_MIX_${vDU_release}_avg_benchmark
    Set Test Variable    ${KPI_52a_avg_benchmark}
    ${KPI_52b_avg_benchmark}=     Get From Dictionary    ${targets}    KPI_52b_MIX_${vDU_release}_avg_benchmark
    Set Test Variable    ${KPI_52b_avg_benchmark}


    ${KPI_52a_target_MIX}=    Evaluate    ${KPI_52a_target_MIX} + ${adjusted_count_FDD} + ${adjusted_count_TDD}
    Set Test Variable    ${KPI_52a_target}    ${KPI_52a_target_MIX}
    ${KPI_52b_target_MIX}=    Evaluate    ${KPI_52b_target_MIX} + ${adjusted_count_FDD} + ${adjusted_count_TDD}
    Set Test Variable    ${KPI_52b_target}    ${KPI_52b_target_MIX}

Check vDU states
    [Arguments]        ${connection}=${vdu_connection}
    ${vdu_state}=    vdu_admin.Get Vdu State Data    vdu_connection=${connection}

    Log    vDU operational state is "${vdu_state["operational_state"]}"    console=${True}
    Should Be Equal As Strings    ${vdu_state["operational_state"].lower()}    commissioned
