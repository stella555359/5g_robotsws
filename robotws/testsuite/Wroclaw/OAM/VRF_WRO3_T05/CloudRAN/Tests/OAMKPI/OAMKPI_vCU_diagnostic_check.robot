*** Settings ***
Documentation
    ...    This test case is used to verify KPI Duration of DC procedure on vCU
    ...    History of changes:     18.11.2025 - Initial creation
    ...    Author:         jakub.kokoszka@nokia.com

*** Keywords ***
OAMKPI Diagnostic Check vCU
    [Documentation]
    ...    This test case verifies the KPI Duration of a Diagnostic Check (DC) procedure on vCU.
    ...    It executes the DC procedure multiple times, calculates the duration, and compares
    ...    the results against a defined KPI target and a benchmark from a previous release.
    ...    The test ensures KPI stability across releases and compliance with performance requirements.
    ...    Arguments:
    ...        - ${test_iterations}: Number of iterations to perform the Diagnostic Check.
    ...        - ${KPI_Duration_of_DC_procedure}: The target KPI duration for the Diagnostic Check procedure.
    ...        - ${KPI_Duration_of_DC_procedure_avg_benchmark}: The average result from the previous software release
    ...                                                        to be used as a benchmark for comparison.
    [Timeout]    12h
    [Arguments]    ${test_iterations}
    ...    ${KPI_Duration_of_DC_procedure}
    ...    ${KPI_Duration_of_DC_procedure_avg_benchmark}

    ${vCU_E2E_results}=    Create List
    ${vCU_BTS_results}=    Create List
    Set Test Variable    ${parameter_changes}        ${False}
    ${mrbts_id}    ${nrbts_id}    Get MRBTS and NRBTS IDs    vCU
    Set Test Variable  ${TRBLCADM_DN}    MRBTS-${mrbts_id}/MNL-1/MNLENT-1/TRBLCADM-1
    ${excluded_checkpoint_id}    Set Variable     39

    FOR   ${i}    IN RANGE    ${test_iterations}
        ${index}    Evaluate    ${i} + 1
        Log To Console    \n--- Execution loop: ${index} ---\n
        ${vcu_files_from_iteration}=    Set Variable  ${SUITE_LOGS_DIR_PATH}/vCU_files_from_${index}_iteration
        OperatingSystem.Create Directory    ${vcu_files_from_iteration}

        Log to console  Start vCU Diagnostic Check
        ${first_DC_time}=    DateTime.Get Current Date    time_zone=UTC
        ${DC}    Start Diagnostic Check    hw_type=vCU    allow_service_impact=${False}    wait_for_completion=${True}
        ...                connection=${vcu_connection}
        ${operationId}=    Get From Dictionary    ${DC}    operationId

        Log to console  Get vCU Diagnostic Check Status
        Wait Until Keyword Succeeds    600s    5s    Verify Diagnostic Check Succeeded on vCU    ${operationId}

        Log to console  Get vCU Diagnostic Check Report
        ${diag_check_report}    Get Diagnostic Check Report    hw_type=vCU    connection=${vcu_connection}
        ${diag_check_report_str}=    Convert To String    ${diag_check_report}
        Create File    ${vcu_files_from_iteration}/vCU_DC_from_${index}_iteration.txt    ${diag_check_report_str}

        Validate Checkpoints for vCU    ${diag_check_report}    ${first_DC_time}


        ${DC_operation_history_start_time}    ${DC_operation_history_end_time}    Get Last Launch Diagnostic Check Times

        Log to console    DC start: ${DC_operation_history_start_time}
        Log to console    DC end: ${DC_operation_history_end_time}
        ${DC_duration} =    Calculate DC Duration    ${DC_operation_history_start_time}    ${DC_operation_history_end_time}
        Log to console    E2E target for ${index} iteration == ${DC_duration}s
        Append To List    ${vCU_E2E_results}    ${DC_duration}


        ${vCU_syslog_path}=    syslog_download_from_vdu_vcu.Download vCU Syslog
        OperatingSystem.Move File
        ...    ${SUITE_LOGS_DIR_PATH}/vCU/full_vCU_syslog
        ...    ${vcu_files_from_iteration}/full_vCU_syslog_first_DC

        ${vCU_syslog_path_first_DC}    Set Variable
        ...   ${vcu_files_from_iteration}/full_vCU_syslog_first_DC

        Log To Console    Filtering vCU syslog looking for DC start timestamps...
        ${first_DC_syslog_filtered}=    Filter Log File
        ...    file_path=${vCU_syslog_path_first_DC}
        ...    component=oamasm
        ...    keyword=DiagnosticCheck Runner, Run Diagnostic Check Request is received
        ...    exclude=INF/CCSBinDecoder
        ...    start_time_str=${first_DC_time}
        ...    end_time_str=
        ...    match_all_keywords=True
        ...    case_sensitive=True
        ${first_DC_start_time}=     Get Timestamp Of Event    ${first_DC_syslog_filtered}    last

        Log To Console    Filtering vCU syslog looking for DC end timestamps...
        ${first_DC_syslog_filtered}=    Filter Log File
        ...    file_path=${vCU_syslog_path_first_DC}
        ...    component=oamasm
        ...    keyword=DiagnosticCheck Runner, Diagnostic check operation, finished.
        ...    exclude=INF/CCSBinDecoder
        ...    start_time_str=${first_DC_time}
        ...    end_time_str=
        ...    match_all_keywords=True
        ...    case_sensitive=True
        ${first_DC_end_time}=     Get Timestamp Of Event    ${first_DC_syslog_filtered}    last

        ${first_DC_KPI}=    DateTime.Subtract Date From Date    ${first_DC_end_time}    ${first_DC_start_time}
        Log to console    BTS target for ${index} iteration == ${first_DC_KPI}s
        Append To List    ${vCU_BTS_results}    ${first_DC_KPI}

        ${is_first_DC_fitting_target}=    Evaluate    ${first_DC_KPI} <= ${KPI_Duration_of_DC_procedure}
        Run Keyword And Continue On Failure    Should Be True    ${is_first_DC_fitting_target}
        ...                                 msg=KPI vCU DC value ${first_DC_KPI} exceeds ${KPI_Duration_of_DC_procedure}

        IF    ${is_first_DC_fitting_target}==False
              Log To Console    One of measured KPIs has exceeded the target. Gathering logs and continuing execution.
              Collect Logs    ${vcu_files_from_iteration}
        ELSE
              OperatingSystem.Remove Directory    ${vcu_files_from_iteration}    recursive=True
        END

    END

    ${checkpoint_to_remove}=    Create List    ${excluded_checkpoint_id}
    Change Parameter on BTS    ${TRBLCADM_DN}    excludedDiagnosticCheckPoints  ${checkpoint_to_remove}  update  vCU
    Set Test Variable    ${parameter_changes}        ${True}
    Log to console  Start vCU Diagnostic Check without CP ${excluded_checkpoint_id}
    ${DC}    Start Diagnostic Check
        ...    hw_type=vCU
        ...    allow_service_impact=${False}
        ...    timeout=1200
        ...    wait_for_completion=${True}
        ...    connection=${vcu_connection}
    ${operationId}=    Get From Dictionary    ${DC}    operationId
    Log to console  Get vCU Diagnostic Check Status
    Wait Until Keyword Succeeds    600s    5s    Verify Diagnostic Check Succeeded on vCU    ${operationId}

    Log to console  Get vCU Diagnostic Check Report without CP ${excluded_checkpoint_id}
    ${diag_check_report}    Get Diagnostic Check Report    hw_type=vCU    connection=${vcu_connection}
    ${diag_check_report_str}=    Convert To String    ${diag_check_report}
    Create File    ${SUITE_LOGS_DIR_PATH}/DC_without_${excluded_checkpoint_id}.txt    ${diag_check_report_str}

    Validate Checkpoints for vCU which excluded    ${diag_check_report}    ${excluded_checkpoint_id}

    Log To Console    Calculating average kpi values and comparing with target...
    ${KPI_Duration_of_DC_procedure_avg}=    Run Keyword And Continue On Failure
    ...    Calculate Average KPI Values And Compare With Target
    ...    kpi_results=${vCU_BTS_results}
    ...    kpi_target=${KPI_Duration_of_DC_procedure}

    ${KPI_benchmark_plus_40}=    Evaluate
    ...    ${KPI_Duration_of_DC_procedure_avg_benchmark} * 1.40    #DNG11091878
    Run Keyword And Continue On Failure
    ...    Verify KPI Benchmark
    ...    ${KPI_Duration_of_DC_procedure_avg}
    ...    ${KPI_benchmark_plus_40}
    ...    KPI Duration of DC procedure without reset

    ${results}=     Create List
    ...    KPI Duration of DC procedure: @{vCU_BTS_results}

    ${averages}=    Create List
    ...    KPI Duration of DC procedure: ${KPI_Duration_of_DC_procedure_avg}s

    ${targets}=     Create List
    ...    KPI Duration of DC procedure: ${KPI_Duration_of_DC_procedure}s

    Create Results File    test_results=${results}     average_results=${averages}    target_values=${targets}

    [Teardown]    OAMKPI_vCU_diagnostic_check.Custom Test Teardown

Custom Test Teardown
    Run Keyword If    ${parameter_changes}    Remove ExcludedDiagnosticCheckPoints

Remove ExcludedDiagnosticCheckPoints
    [Documentation]
    ...    Removes the 'excludedDiagnosticCheckPoints' parameter from the specified
    ...    TRBLCADM managed object on the vCU.

    ${delta}              _Create Delta JSON object for single parameter delete
    ...                   dist_name=${TRBLCADM_DN}   param_name=excludedDiagnosticCheckPoints    dist_operation=update
    ...                   param_operation=delete
    vcu_admin.perform_delta_recommissioning    delta_file=${delta}    connection=${vcu_connection}
    ${parameter_changes}    Set Test Variable    ${False}

Validate Checkpoints for vCU which excluded
    [Documentation]
    ...    Validates a list of Diagnostic Check (DC) checkpoints for a vCU, ensuring that a
    ...    specific checkpoint, identified by `${excluded_checkpoint_id}`, is *not* present
    ...    in the provided list. This is crucial for scenarios where certain checkpoints
    ...    are expected to be excluded or filtered out from the diagnostic results.
    ...
    ...    Arguments:
    ...        - ${checkpoints}: A list of dictionaries, where each dictionary represents a
    ...                          checkpoint and is expected to have a 'checkpoint' key
    ...                          containing the checkpoint's identifier.
    ...        - ${excluded_checkpoint_id}: The ID of the checkpoint that should *not* be
    ...                                     found in the `${checkpoints}` list.
    ...
    ...    Assertions:
    ...        - The test will `Fail` immediately if any checkpoint in the `${checkpoints}`
    ...          list matches the `${excluded_checkpoint_id}`.
    ...
    ...    Logs:
    ...        - A success message is logged to the console if the `FOR` loop completes
    ...          without finding the excluded checkpoint.
    [Arguments]    ${checkpoints}    ${excluded_checkpoint_id}

    FOR    ${item}    IN    @{checkpoints}
        IF    ${item['checkpoint']} == ${excluded_checkpoint_id}
              Fail    Checkpoint ID ${excluded_checkpoint_id} was found in the list, but it should have been excluded.
        END
    END
    Log To Console    All checkpoints validated successfully. Excluded checkpoint ID ${excluded_checkpoint_id} was not found.

Calculate DC Duration
    [Documentation]
    ...    Calculates the duration in seconds between a given start time and end time.
    ...    Both times are expected to be in ISO 8601 format (e.g., 'YYYY-MM-DDTHH:MM:SS.ffffff+HH:MM').
    ...
    ...    Arguments:
    ...        - ${start_time}: The start timestamp of the operation.
    ...        - ${end_time}: The end timestamp of the operation.
    ...
    ...    Returns:
    ...        - ${duration_seconds}: The calculated duration in total seconds.
    [Arguments]    ${start_time}    ${end_time}

    ${cmd}    Catenate    SEPARATOR=
        ...    (datetime.datetime.fromisoformat('${end_time}')${SPACE}
        ...    - datetime.datetime.fromisoformat('${start_time}')).total_seconds()
    ${duration_seconds}=    Evaluate
    ...    ${cmd}
    ...    modules=datetime
    [Return]    ${duration_seconds}

Get Last Launch Diagnostic Check Times
    [Documentation]
    ...    Parses a history dictionary to find the start and end times of the most recent
    ...    'launch diagnostic check' operation with status 'succeeded'.
    ...    If the first found operation is not succeeded, it retries up to 3 times with 5s wait.
    ...
    ...    Returns:
    ...        - ${DC_operation_history_start_time}: The start time of the last 'launch diagnostic check' operation.
    ...        - ${DC_operation_history_end_time}: The end time of the last 'launch diagnostic check' operation.

    ${found}    Set Variable    ${False}
    ${last_status}    Set Variable    None
    FOR    ${attempt}    IN RANGE    3
        ${history}    vcu_admin.Get CU Operation History    connection=${vcu_connection}
        FOR    ${item}    IN    @{history['created']}
            IF    '${item["name"]}' == 'launch diagnostic check'
                ${last_status}    Set Variable    ${item["status"]}
                IF    '${item["status"]}' == 'succeeded'
                    ${DC_operation_history_start_time}    Set Variable    ${item["start_time"]}
                    ${DC_operation_history_end_time}      Set Variable    ${item["end_time"]}
                    ${found}    Set Variable    ${True}
                    Exit For Loop
                ELSE
                    Log    Status is '${item["status"]}', retrying in 5 seconds...
                    Sleep    5s
                    Exit For Loop
                END
            END
        END
        IF    ${found}
            Exit For Loop
        END
    END

    IF    not ${found}
        Fail    Diagnostic check did not succeed after 3 attempts. Last status: ${last_status}
    END

    [Return]    ${DC_operation_history_start_time}    ${DC_operation_history_end_time}

Validate Checkpoints for vCU
    [Documentation]
    ...    Validates a list of diagnostic checkpoints for a vCU. It checks if each checkpoint
    ...    was successful and if its execution started within a specified time frame relative
    ...    to the overall Diagnostic Check's start time.
    ...
    ...    Arguments:
    ...        - ${checkpoints}: A list of dictionaries, where each dictionary represents a checkpoint
    ...                          and is expected to have 'checkpoint', 'lastDefinitiveCheckStatus',
    ...                          and 'executionTime' keys.
    ...        - ${first_DC_time}: The ISO 8601 formatted start time of the overall Diagnostic Check procedure.
    ...
    ...    Assertions:
    ...        - Each checkpoint's 'lastDefinitiveCheckStatus' must be "Check point successful".
    ...        - The time difference between 'executionTime' of a checkpoint and 'first_DC_time'
    ...          must be less than or equal to 30 seconds.
    [Arguments]    ${checkpoints}    ${first_DC_time}

    FOR    ${item}    IN    @{checkpoints}
        Log    Checking checkpoint: ${item["checkpoint"]}

        Should Be Equal    ${item["lastDefinitiveCheckStatus"]}    Check point successful
        ${cmd}    Catenate    SEPARATOR=
            ...    (datetime.datetime.fromisoformat("${item['executionTime']}")
            ...    - datetime.datetime.fromisoformat("${first_DC_time}").replace(tzinfo=datetime.timezone.utc)
            ...    ).total_seconds()

        ${diff}    Evaluate    ${cmd}    modules=datetime

        Should Be True   ${diff} <= 30    msg=Checkpoint ${item["checkpoint"]} didn't start within 600s
    END

Verify Diagnostic Check Succeeded on vCU
    [Documentation]
    ...    Retrieves and implicitly verifies the success status of a Diagnostic Check operation
    ...    on a vCU using its operation ID.
    ...
    ...    Arguments:
    ...        - ${operationId}: The unique identifier for the Diagnostic Check operation.
    ...
    ...    Returns:
    ...        - ${diag_check_status}: The status of the diagnostic check. (Further processing
    ...                                or assertion of this status is expected after this keyword call).
    [Arguments]    ${operationId}

    ${diag_check_status}=    Get Diagnostic Check Status    hw_type=vCU    operation_id=${operationId}    connection=${vcu_connection}
    ${diag_check_status}=    Convert To Lowercase    ${diag_check_status}
    Should Be Equal    ${diag_check_status}    succeeded
