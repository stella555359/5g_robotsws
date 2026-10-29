*** Settings ***
Documentation
...    Test case to verify RANNIC Reset duration on vDU. This test case runs a specified number of iterations.
...    In each iteration, it resets the RANNIC,measures the time from the first cell going down to the last cell coming up,
...    and compares thisduration against a calculated target. The target time is adjusted based on RU family exceptions.
...    Author:    jakub.ozierski@nokia.com
...    Change history:
...    18.11.2024 - Initial creation
...    21.03.2025 - Watchdog implementation for alarms handling
...    16.04.2025 - Removed 20min sleep between resets (backoff time) as it's not valid anymore.
...    29.09.2025 - TC Refactor - dkotula
...    06.11.2025 - TC Refactor for ute-ca - kasadows
...    Arguments:
...        - ${test_iterations}:   Number of iterations to perform the lock/unlock operations.
...        - ${KPI_60a_target}:    Target time for KPI 60a.
...        - ${KPI_60c_target}:    Target time for KPI 60c.
...        - ${KPI_60a_benchmark}: KPI 60a result from previous release.
...        - ${KPI_60c_benchmark}: KPI 60c result from previous release.

*** Keywords ***
OAMKPI_RANNIC_Reset_vDU
    [Arguments]    ${test_iterations}
    ...            ${KPI_30_target}
    ...            ${KPI_30_FDD_benchmark}
    ...            ${KPI_30_TDD_benchmark}

    @{KPI_30_results}=    Create List
    ${ok_logs_collected}=    Set Variable    ${False}

    Log  \nStep 0: Preconditions  console=${True}
    watchdog.Start Watchdog    hw_type=vCU    log_dir=${TEST_RESULTS_DIR}
    watchdog.Start Watchdog    hw_type=vDU    log_dir=${TEST_RESULTS_DIR}
    @{vdu_alarms}=    Create List    ${FAULT_16}    ${FAULT_16_critical}    ${FAULT_4405}    ${FAULT_4298}
    ...                              ${FAULT_4298_critical}    ${FAULT_4298_major}    ${FAULT_4647}
    @{vcu_alarms}=    Create List    ${FAULT_7104}
    Add Allowed Alarms    alarms_list=${vdu_alarms}    hw_type=vDU
    Add Allowed Alarms    alarms_list=${vcu_alarms}    hw_type=vCU
    ${cell_technology}=    Check Cell Technology on BTS
    IF    '${cell_technology}' == 'MIX'    Fail    Test is not applicable for TL's with mixed FDD/TDD cells.
    Set Test Variable    ${CELL_TECHNOLOGY}
    ${rannic_info}=      vdu_admin.Get Rnic Info From Plan    mrbts_id=${MRBTS}    vdu_connection=${vdu_connection}
    Set Test Variable    ${RANNIC_DN}    ${rannic_info[0]['r_nic_mod_dist_name']}
    IF    ${FHGW_OBJ}
        Log To Console    Testline uses FHGW, RU exceptions are not applicable
        ${additional_time}=    Set Variable    0
    ELSE
        Log To Console    Testline uses direct connectivity, RU exceptions will be considered
        ${additional_time}=    Get Max Additional Time For RUs With Exceptions
    END
    ${KPI_30_target}=    Evaluate    ${KPI_30_target} + ${additional_time}


    FOR   ${i}    IN RANGE    ${test_iterations}
        ${index}    Evaluate    ${i} + 1
        Log    \n--- Execution loop: ${index} of ${test_iterations} ---\n    console=${True}
        Set Test Variable    ${vDU_FILES_FROM_ITERATION}    ${SUITE_LOGS_DIR_PATH}/vDU_files_from_iteration_${i}
        OperatingSystem.Create Directory    ${vDU_FILES_FROM_ITERATION}
        ${reset_time}=    DateTime.Get Current Date    time_zone=UTC
        vdu_admin.Reset Rannic
        ...    rannic_r_dn=${RANNIC_DN}    graceful_cell_shutdown=${FALSE}    vdu_connection=${vdu_connection}
        Wait Until Keyword Succeeds    4 min    1s    CellStatus.Verify All vDU Cells Are Disabled
        ...                                           vdu_connection=${vdu_connection}

        Log To Console    Downloading vDU syslog to check when the cells went down
        ${vDU_syslog_path_cells_down}=    syslog_download_from_vdu_vcu.Download vDU Syslog
        OperatingSystem.Move File         ${vDU_syslog_path_cells_down}
        ...                               ${vDU_FILES_FROM_ITERATION}/full_vDU_syslog_cells_down
        ${vDU_syslog_path_cells_down}=    Set Variable    ${vDU_FILES_FROM_ITERATION}/full_vDU_syslog_cells_down

        Wait Until Keyword Succeeds    10 min    1s    CellStatus.Verify All vDU Cells Are Enabled
        ...                                            vdu_connection=${vdu_connection}
        ${cells_uptime}=    DateTime.Get Current Date    time_zone=UTC

        Log To Console    Downloading vDU syslog to check when the cells came up
        ${vDU_syslog_path_cells_up}=    syslog_download_from_vdu_vcu.Download vDU Syslog
        OperatingSystem.Move File       ${vDU_syslog_path_cells_up}
        ...                             ${vDU_FILES_FROM_ITERATION}/full_vDU_syslog_cells_up
        ${vDU_syslog_path_cells_up}=    Set Variable    ${vDU_FILES_FROM_ITERATION}/full_vDU_syslog_cells_up

        Log To Console    Filtering vDU syslog looking for cells down timestamps...
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

        Log To Console    Filtering vDU syslog looking for cells up timestamps...
        ${cells_up_syslog_filtered}=    Filter Log File
        ...    file_path=${vDU_syslog_path_cells_up}
        ...    component=cprt
        ...    keyword=AntennaCarrierActivationResp - OK
        ...    exclude=INF/CCSBinDecoder
        ...    start_time_str=${reset_time}
        ...    end_time_str=${cells_uptime}
        ...    match_all_keywords=True
        ...    case_sensitive=True
        ${last_cell_up}=     Get Timestamp Of Event    ${cells_up_syslog_filtered}    last

        ${KPI_30_result}=    DateTime.Subtract Date From Date    ${last_cell_up}    ${first_cell_down}
        Append To List    ${KPI_30_results}    ${KPI_30_result}
        Log To Console    KPI 30 (from first cell down to last cell up): ${KPI_30_result} seconds
        ${is_KPI_30_in_limits}=    Evaluate    ${KPI_30_result} <= ${KPI_30_target}
        Run Keyword And Continue On Failure    Should Be True    ${is_KPI_30_in_limits}
        ...                                    msg=KPI_30 value ${KPI_30_result} exceeds ${KPI_30_target}

        IF    ${is_KPI_30_in_limits} == False
              Log To Console    KPI has exceeded the target. Gathering logs and continuing execution.
              Collect Logs    ${TEST_RESULTS_DIR}/logs_from_${index}_iteration_FAIL
        ELSE
              Log    Deleting log files
              OperatingSystem.Remove Directory    ${vDU_FILES_FROM_ITERATION}    recursive=True
              IF    not ${ok_logs_collected}
                  Log To Console    Gathering ok logs to compare and continuing execution.
                  ${ok_logs_collected}=    Set Variable    ${True}
                  Collect Logs    ${TEST_RESULTS_DIR}/logs_from_${index}_iteration_PASS
              END
        END
    END

    Log To Console    Calculating Average KPI Values And Comparing With Target...
    ${KPI_30_average}=     Run Keyword And Continue On Failure    Calculate Average KPI Values And Compare With Target
    ...                                                           kpi_results=${KPI_30_results}
    ...                                                           kpi_target=${KPI_30_target}

    Log To Console     Comparing Average KPI Values With Previous Release Results...
    ${KPI_30_benchmark}=    Set Variable If    "${CELL_TECHNOLOGY}"=="TDD"    ${KPI_30_TDD_benchmark}    ${KPI_30_FDD_benchmark}
    Run Keyword And Continue On Failure    Check Average KPI Value With Previous Release Result    ${KPI_30_average}    ${KPI_30_benchmark}

    ${results}=     Create List     KPI_30_${CELL_TECHNOLOGY} =    @{KPI_30_results}s
    ${averages}=    Create List     KPI_30_${CELL_TECHNOLOGY} =    ${KPI_30_average}s
    ${targets}=     Create List     KPI_30_${CELL_TECHNOLOGY}_target =    ${KPI_30_target}s
    ...                             KPI_30_${CELL_TECHNOLOGY}_benchmark =    ${KPI_30_${CELL_TECHNOLOGY}_benchmark}s
    Create Results File    test_results=${results}     average_results=${averages}    target_values=${targets}
    OperatingSystem.Remove Directory    ${SUITE_LOGS_DIR_PATH}/vDU

    watchdog.Check if Disallowed Alarm was Detected during Watchdog    hw_type=vCU
    watchdog.Check if Disallowed Alarm was Detected during Watchdog    hw_type=vDU
    Remove All Alarms from Allowed List    hw_type=vDU
    Remove All Alarms from Allowed List    hw_type=vCU
    watchdog.Stop Watchdog    hw_type=vCU
    watchdog.Stop Watchdog    hw_type=vDU

    [Return]    ${KPI_30_average}

Get Max Additional Time For RUs With Exceptions
    [Documentation]    Description:    This keyword gets the info of all connected RMODs and based on the RU family
    ...                                determines an additional time offset.
    ...                Output:         Max additional time due to exceptions of connected RU (integer).

    ${rmod_list}=    vdu_admin.Get Rmods Status    vdu_connection=${vdu_connection}
    ${additional_time_list}=    Create List

    FOR    ${item}    IN    @{rmod_list}
        ${product_name}=    Set Variable    ${item['product_name']}
        ${interface_type}=    Set Variable    ${item['interface_type']}
        ${additional_time}=    Set Variable    0
        FOR    ${family_name}    ${product_list}    IN    &{FAMILY_DICT}
            IF    '${product_name}' in @{product_list}
                Log To Console    \nRMOD ${product_name} belongs to excepted family ${family_name}
                IF    '${family_name}' == 'PULSAR'
                    ${additional_time}=    Set Variable If    '${interface_type}' == 'eCPRI'    60    240
                    Log To Console    Additional time for family ${family_name} (${interface_type}) is ${additional_time}s
                ELSE
                    ${additional_time}=    Get From Dictionary    ${EXCEPTION_FAMILY_TIMES_DICT}    ${family_name}
                    Log To Console    Additional time for family ${family_name} is ${additional_time}s
                END
                Exit For Loop
            END
        END
        ${additional_time_int}=    Convert To Integer    ${additional_time}
        Append To List    ${additional_time_list}    ${additional_time_int}
    END
    ${max_additional_time}=    Evaluate    max(${additional_time_list}) if ${additional_time_list} else 0
    Log To Console    \nMaximum time added to target is ${max_additional_time}s
    [Return]    ${max_additional_time}

Add Allowed Alarms
     [Documentation]    Adds a list of allowed alarms for the watchdog.
     [Arguments]    ${alarms_list}    ${hw_type}
     FOR    ${alarm}    IN    @{alarms_list}
         watchdog.Add Alarm to the Allowed List    fault_id=${alarm.fault_id}    fault_name=${alarm.fault_name}
         ...                                       severity=${alarm.severity}    hw_type=${hw_type}
     END

Check Cell Technology on BTS
    [Documentation]
    ...  This KW checks if all cells are FDD or TDD and returns the appropriate value.
    ${cells_status}=        vdu.Get Vdu Cells Status    vdu_connection=${vdu_connection}
    ${cells_id}=            Evaluate    [item['id'] for item in ${cells_status}]
    ${cells_technology}=    Evaluate    [item['technology'] for item in ${cells_status}]
    ${all_fdd}=    Evaluate    all(item == 'FDD' for item in ${cells_technology})
    ${all_tdd}=    Evaluate    all(item == 'TDD' for item in ${cells_technology})
    Return From Keyword If    ${all_fdd}    FDD
    Return From Keyword If    ${all_tdd}    TDD
    RETURN    MIX