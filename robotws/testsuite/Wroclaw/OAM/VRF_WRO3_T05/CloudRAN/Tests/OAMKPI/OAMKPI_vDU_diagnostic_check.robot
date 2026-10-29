*** Settings ***
Documentation
    ...    This test case is used to verify KPI Duration of DC procedure without reset
    ...    and KPI Duration of DC procedure with RU reset for vDU
    ...    History of changes:     02.10.2025 - Initial creation
    ...    Author:         jakub.kokoszka@nokia.com

*** Keywords ***
OAMKPI Diagnostic Check vDU
    [Documentation]
    ...    This test case is used to verify KPI Duration of DC procedure without reset
    ...    and KPI Duration of DC procedure with RU reset for vDU. Each iteration executes
    ...    a Diagnostic Check (DC) without reset and a Diagnostic Check with RU reset,
    ...    capturing syslog start and end timestamps to calculate KPI durations. Results
    ...    are validated against defined KPI targets, and average values are calculated
    ...    after all iterations. The calculated averages are then compared with benchmark
    ...    values obtained from the previous software release, with configurable margins
    ...    (40% for DC without reset, 15% for DC with RU reset). This ensures KPI stability
    ...    across releases and compliance with performance requirements.
    ...    Arguments:
    ...        - ${test_iterations}: Number of iterations to perform the lock/unlock operations.
    ...        - ${KPI_Duration_of_DC_procedure_without_reset_target}: KPI targets for DC procedure without reset
    ...        - ${KPI_Duration_of_DC_procedure_without_reset_avg_benchmark}: Average result from the previous release
    ...        - ${KPI_Duration_of_DC_procedure_with_RU_reset_target}: KPI targets for DC procedure with RU reset
    ...        - ${KPI_Duration_of_DC_procedure_with_RU_reset_avg_benchmark}: Average result from the previous release


    [Timeout]    12h
    [Arguments]    ${test_iterations}
    ...    ${KPI_Duration_of_DC_procedure_without_reset_target}
    ...    ${KPI_Duration_of_DC_procedure_without_reset_avg_benchmark}
    ...    ${KPI_Duration_of_DC_procedure_with_RU_reset_target}
    ...    ${KPI_Duration_of_DC_procedure_with_RU_reset_avg_benchmark}

    ${mrbts_id}    ${nrbts_id}    Get MRBTS and NRBTS IDs    vDU
    ${rmod_listed}=    vdu_admin.Get Rmods Status    vdu_connection=${vdu_connection}
    ${rmods_ids}=    Create List
    @{KPI_Duration_of_DC_procedure_without_reset_results}=     Create List
    @{KPI_Duration_of_DC_procedure_with_RU_reset_results}=    Create List


    FOR    ${item}    IN    @{rmod_listed}
        ${id}=    Get From Dictionary    ${item}    id
        Append To List    ${rmods_ids}    ${id}
    END

    FOR   ${i}    IN RANGE    ${test_iterations}
        ${index}    Evaluate    ${i} + 1
        Log To Console    \n--- Execution loop: ${index} ---\n
        ${vdu_files_from_iteration}=    Set Variable  ${SUITE_LOGS_DIR_PATH}/vDU_files_from_${index}_iteration
        OperatingSystem.Create Directory    ${vdu_files_from_iteration}

        Log to console  Start Diagnostic Check
        ${first_DC_time}=    DateTime.Get Current Date    time_zone=UTC
        ${DC}    Start Diagnostic Check    hw_type=vDU    allow_service_impact=${False}    wait_for_completion=${True}
        ...                connection=${vdu_connection}
        ${operationId}=    Get From Dictionary    ${DC}    operationId

        Log to console  Get Diagnostic Check Status
        Wait Until Keyword Succeeds    600s    5s    Verify Diagnostic Check Succeeded    ${operationId}

        Log to console  Get Diagnostic Check Report
        ${diag_check_report}    Get Diagnostic Check Report    hw_type=vDU    connection=${vdu_connection}
        ${diag_check_report_str}=    Convert To String    ${diag_check_report}
        Create File    ${vdu_files_from_iteration}/DC.txt    ${diag_check_report_str}

        Wait Until Keyword Succeeds  20m  10s    cloud_frame.Check vDU And RMOD states    ${vdu_connection}
        Wait Until Keyword Succeeds  15m  10s    cloud_frame.Check Cell States On vDU    ${vdu_connection}
        Wait Until Keyword Succeeds  15m  10s    cloud_frame.Check vCU state    ${vcu_connection}

        ${vDU_syslog_path_}=    syslog_download_from_vdu_vcu.Download vDU Syslog
        OperatingSystem.Move File
        ...    ${SUITE_LOGS_DIR_PATH}/vDU/full_vDU_syslog
        ...    ${vdu_files_from_iteration}/full_vDU_syslog_first_DC

        ${vDU_syslog_path_first_DC}    Set Variable
        ...   ${vdu_files_from_iteration}/full_vDU_syslog_first_DC

        Log To Console    Filtering vDU syslog looking for first DC start timestamps...
        ${first_DC_syslog_filtered}=    Filter Log File
        ...    file_path=${vDU_syslog_path_first_DC}
        ...    component=oamasm
        ...    keyword=DiagnosticCheck Runner, Run Diagnostic Check Request is received
        ...    exclude=INF/CCSBinDecoder
        ...    start_time_str=${first_DC_time}
        ...    end_time_str=
        ...    match_all_keywords=True
        ...    case_sensitive=True
        ${first_DC_start_time}=     Get Timestamp Of Event    ${first_DC_syslog_filtered}    last

        Log To Console    Filtering vDU syslog looking for first DC end timestamps...
        ${first_DC_syslog_filtered}=    Filter Log File
        ...    file_path=${vDU_syslog_path_first_DC}
        ...    component=oamasm
        ...    keyword=DiagnosticCheck Runner, Diagnostic check operation, finished.
        ...    exclude=INF/CCSBinDecoder
        ...    start_time_str=${first_DC_time}
        ...    end_time_str=
        ...    match_all_keywords=True
        ...    case_sensitive=True
        ${first_DC_end_time}=     Get Timestamp Of Event    ${first_DC_syslog_filtered}    last

        ${first_DC_KPI}=    DateTime.Subtract Date From Date    ${first_DC_end_time}    ${first_DC_start_time}

        Log to console    Duration of first Diagnostic check procedure = ${first_DC_KPI}s
        Append To List    ${KPI_Duration_of_DC_procedure_without_reset_results}    ${first_DC_KPI}

        ${KPI_Duration_of_DC_procedure_without_reset_check}=    Evaluate
        ...    ${first_DC_KPI} <= ${KPI_Duration_of_DC_procedure_without_reset_target}
        Run Keyword And Continue On Failure    Should Be True
        ...    ${KPI_Duration_of_DC_procedure_without_reset_check}
        ...    msg=KPI Duration of DC procedure without reset exceeds target

        ${TRBLCADM_DN}=    Set Variable    MRBTS-${mrbts_id}/MNL-1/MNLENT-1/TRBLCADM-1
        ${vnf_checkpoints}=    diag_check_vdu.Get Vnf And Rmod Checkpoints    vdu_connection=${vdu_connection}

        @{checkpoint_ids}=    Create List
        FOR    ${item}    IN    @{vnf_checkpoints}
            Run Keyword If    '${item["checkModule"]}' == 'vnf'    Append To List    ${checkpoint_ids}    ${item["id"]}
            Run Keyword If    '${item["checkModule"]}' == 'rf'     Append To List    ${checkpoint_ids}    ${item["id"]}
        END

        ${checkpoint_to_remove}=    Convert To Integer    43
        Remove Values From List    ${checkpoint_ids}    ${checkpoint_to_remove}

        Change Parameter on BTS    ${TRBLCADM_DN}    excludedDiagnosticCheckPoints  ${checkpoint_ids}  update  vDU

        ${second_DC_time}=    DateTime.Get Current Date    time_zone=UTC
        Log to console  Start Diagnostic Check CP43
        ${DC}    Start Diagnostic Check
        ...    hw_type=vDU
        ...    allow_service_impact=${True}
        ...    timeout=1200
        ...    wait_for_completion=${True}
        ...    connection=${vdu_connection}
        ${operationId}=    Get From Dictionary    ${DC}    operationId

        Log to console  Get Diagnostic Check Status
        Wait Until Keyword Succeeds    600s    5s    Verify Diagnostic Check Succeeded    ${operationId}

        Wait Until Keyword Succeeds  20m  10s    cloud_frame.Check vDU And RMOD states    ${vdu_connection}
        Wait Until Keyword Succeeds  15m  10s    cloud_frame.Check Cell States On vDU    ${vdu_connection}
        Wait Until Keyword Succeeds  15m  10s    cloud_frame.Check vCU state    ${vcu_connection}

        ${vDU_syslog_path_}=    syslog_download_from_vdu_vcu.Download vDU Syslog
        OperatingSystem.Move File
        ...    ${SUITE_LOGS_DIR_PATH}/vDU/full_vDU_syslog
        ...    ${vdu_files_from_iteration}/full_vDU_syslog_second_DC

        ${vDU_syslog_path_second_DC}    Set Variable
        ...   ${vdu_files_from_iteration}/full_vDU_syslog_second_DC

        Log To Console    Filtering vDU syslog looking for second DC start timestamps...
        ${second_DC_syslog_filtered}=    Filter Log File
        ...    file_path=${vDU_syslog_path_second_DC}
        ...    component=oamfh
        ...    keyword=RemSupervisor, RemController, startProcedure, DiagnosticCheck:
        ...    exclude=INF/CCSBinDecoder
        ...    start_time_str=${second_DC_time}
        ...    end_time_str=
        ...    match_all_keywords=True
        ...    case_sensitive=True
        ${second_DC_start_time}=     Get Timestamp Of Event    ${second_DC_syslog_filtered}    first


        Log To Console    Filtering vDU syslog looking for second DC end timestamps...
        ${second_DC_syslog_filtered}=    Filter Log File
        ...    file_path=${vDU_syslog_path_second_DC}
        ...    component=oamasm
        ...    keyword=DiagnosticCheck, DiagnosticCheck Runner, Diagnostic check operation, finished.
        ...    exclude=INF/CCSBinDecoder
        ...    start_time_str=${second_DC_time}
        ...    end_time_str=
        ...    match_all_keywords=True
        ...    case_sensitive=True

        ${second_DC_end_time}=     Get Timestamp Of Event    ${second_DC_syslog_filtered}    last
        ${second_DC_KPI}=    DateTime.Subtract Date From Date    ${second_DC_end_time}    ${second_DC_start_time}

        Log to console    Duration of second Diagnostic check procedure = ${second_DC_KPI}

        Append To List    ${KPI_Duration_of_DC_procedure_with_RU_reset_results}    ${second_DC_KPI}

        ${KPI_Duration_of_DC_procedure_with_RU_reset_check}=    Evaluate
        ...    ${second_DC_KPI} <= ${KPI_Duration_of_DC_procedure_with_RU_reset_target}
        Run Keyword And Continue On Failure    Should Be True
        ...    ${KPI_Duration_of_DC_procedure_with_RU_reset_check}
        ...    msg=KPI Duration of DC procedure with RU reset exceeds target

       ${is_KPI_with_RU_reset_exceeded}=    Evaluate    ${KPI_Duration_of_DC_procedure_with_RU_reset_check}==False
       ${is_KPI_without_reset_exceeded}=    Evaluate    ${KPI_Duration_of_DC_procedure_without_reset_check}==False

       IF     ${is_KPI_with_RU_reset_exceeded}==True or ${is_KPI_without_reset_exceeded}==True
              Log To Console    One of measured KPIs has exceeded the target. Gathering logs and continuing execution.
              Collect Logs    ${vdu_files_from_iteration}
       ELSE
              OperatingSystem.Remove Directory    ${vdu_files_from_iteration}    recursive=True
              Delete Parameter on BTS    ${TRBLCADM_DN}    excludedDiagnosticCheckPoints    vDU
       END

    END

    Log To Console    Calculating average kpi values and comparing with target...
    ${KPI_Duration_of_DC_procedure_without_reset_avg}=    Run Keyword And Continue On Failure
    ...    Calculate Average KPI Values And Compare With Target
    ...    kpi_results=${KPI_Duration_of_DC_procedure_without_reset_results}
    ...    kpi_target=${KPI_Duration_of_DC_procedure_without_reset_target}

    ${KPI_Duration_of_DC_procedure_with_RU_reset_avg}=    Run Keyword And Continue On Failure
    ...    Calculate Average KPI Values And Compare With Target
    ...    kpi_results=${KPI_Duration_of_DC_procedure_with_RU_reset_results}
    ...    kpi_target=${KPI_Duration_of_DC_procedure_with_RU_reset_target}

    ${KPI_benchmark_plus_40}=    Evaluate
    ...    ${KPI_Duration_of_DC_procedure_without_reset_avg_benchmark} * 1.40    #DNG11091878
    Run Keyword And Continue On Failure
    ...    Verify KPI Benchmark
    ...    ${KPI_Duration_of_DC_procedure_without_reset_avg}
    ...    ${KPI_benchmark_plus_40}
    ...    KPI Duration of DC procedure without reset

    ${KPI_benchmark_plus_15}=    Evaluate
    ...    ${KPI_Duration_of_DC_procedure_with_RU_reset_avg_benchmark} * 1.15    #DNG11091878
    Run Keyword And Continue On Failure
    ...    Verify KPI Benchmark
    ...    ${KPI_Duration_of_DC_procedure_with_RU_reset_avg}
    ...    ${KPI_benchmark_plus_15}
    ...    KPI Duration of DC procedure with RU reset

    ${results}=     Create List
    ...    KPI Duration of DC procedure without reset: @{KPI_Duration_of_DC_procedure_without_reset_results}
    ...    KPI Duration of DC procedure with RU reset: @{KPI_Duration_of_DC_procedure_with_RU_reset_results}

    ${averages}=    Create List
    ...    KPI Duration of DC procedure without reset: ${KPI_Duration_of_DC_procedure_without_reset_avg}s
    ...    KPI Duration of DC procedure with RU reset: ${KPI_Duration_of_DC_procedure_with_RU_reset_avg}s

    ${targets}=     Create List
    ...    KPI Duration of DC procedure without reset: ${KPI_Duration_of_DC_procedure_without_reset_target}
    ...    KPI Duration of DC procedure with RU reset: ${KPI_Duration_of_DC_procedure_with_RU_reset_target}

    Create Results File    test_results=${results}     average_results=${averages}    target_values=${targets}

Verify Diagnostic Check Succeeded
    [Arguments]    ${operationId}
    ${diag_check_status}=    Get Diagnostic Check Status    hw_type=vDU    operation_id=${operationId}    connection=${vdu_connection}
    ${diag_check_status}=    Convert To Lowercase    ${diag_check_status}
    Should Be Equal    ${diag_check_status}    succeeded
