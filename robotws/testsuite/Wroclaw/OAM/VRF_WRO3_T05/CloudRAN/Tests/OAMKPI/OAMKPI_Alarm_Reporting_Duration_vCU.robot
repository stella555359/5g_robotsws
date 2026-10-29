*** Settings ***
Documentation
    ...    This test case is used to verify Alarm Reporting Duration KPI on vCU
    ...    History of changes:     05.12.2025 - Initial creation
    ...    Author:         jakub.kokoszka@nokia.com

*** Variables ***
@{vCU_KPI_BTS_results}                                 #list to store BTS KPI results
@{vCU_KPI_E2E_results}                                 #list to store UPLOAD KPI results
${Temporary_Alarm_Active}             ${False}         #Used to track if Temporary Alarm is Active
${MRBTS_ID}                                            #to store BTS id
${NRBTS_ID}                                            #to store NRBTS id
${FID_ID}                             9001             #FID id
${ALARM_NAME}                         TEMPORARY ALARM  #Alarm name

*** Keywords ***
OAMKPI Alarm Reporting Duration vCU
    [Documentation]
    ...    This test case verifies the Alarm Reporting Duration KPI on vCU.
    ...    It performs multiple iterations, injecting and clearing alarms,
    ...    measuring the time between alarm injection and reporting,
    ...    and comparing results against defined KPI targets and benchmarks.
    ...    The test collects logs if KPIs are exceeded and calculates average values
    ...    for further validation. Results and averages are saved to a results file for reporting.
    [Timeout]    12h
    [Arguments]    ${test_iterations}
    ...    ${KPI_Alarm_Duration_BTS_target}
    ...    ${KPI_Alarm_Duration_E2E_target}
    ...    ${KPI_Alarm_Duration_BTS_avg_benchmark_target}
    ...    ${KPI_Alarm_Duration_E2E_avg_benchmark_target}

    Log To Console    Getting MRBTS and NRBTS IDs
    ${MRBTS_ID}  ${NRBTS_ID}    Get MRBTS and NRBTS IDs    vCU
    Set Test Variable    ${PMCADM_DN}    MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/PMCADM-1
    ${ok_logs_collected}=    Set Variable    ${False}

    FOR   ${i}    IN RANGE    ${test_iterations}
        ${index}    Evaluate    ${i} + 1
        Log To Console    \n--- Execution loop: ${index} ---\n

        Log    Creating directory for iteration files
        ${vcu_files_from_iteration}=    Set Variable  ${SUITE_LOGS_DIR_PATH}/vCU_files_from_${index}_iteration
        OperatingSystem.Create Directory    ${vcu_files_from_iteration}
        Check active critical alarm summary is equal    0    vCU

        Log    Getting current UTC time for injection
        ${Inject_time}=    DateTime.Get Current Date    time_zone=UTC
        Sleep    1s

        Log    Injecting alarm
        ${alarm_injection_timestamp}    Inject or delete alarms
        ...    1   1   ${MRBTS_ID}    ${NRBTS_ID}    ${CRAN_VCU}    ${FID_ID}    vCU
        Set Test Variable    ${Temporary_Alarm_Active}    ${True}
        Log To Console    Extracting timestamp from alarm injection
        ${regex_timestamp_pattern}=    Set Variable    \\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}\\.\\d+\\+\\d{2}:\\d{2}
        ${timestamp}=    Get Regexp Matches    ${alarm_injection_timestamp}    ${regex_timestamp_pattern}
        Set Test Variable    ${alarm_injection_timestamp}    ${timestamp[0]}

        Log    Checking active critical alarm summary is equal to 1
        Check active critical alarm summary is equal    1    vCU

        Log    Getting active alarms from vCU
        ${active_alarms}    vcu_admin.get_active_alarms    connection=${vcu_connection}
        ${FID_appear_time}    Set Variable    ${NONE}
        ${alarms}    Set Variable    ${active_alarms['alarms']}

            FOR    ${alarm}    IN    @{alarms}
                ${fault_id}      Set Variable    ${alarm['fault_id']}
                ${alarm_name}    Set Variable    ${alarm['alarm_name']}

                Run Keyword If    "${fault_id}" == "${FID_ID}" and "${alarm_name}" == "${ALARM_NAME}"
                ...    Run Keywords    Set Test Variable    ${FID_appear_time}    ${alarm['appear_time']}    AND
                ...    Exit For Loop
            END

        Log To Console    Appear time on WebEM for fault_id: ${FID_ID} ${FID_appear_time}

        Log To Console    Downloading vCU syslog...
        ${vCU_syslog_path}=    syslog_download_from_vdu_vcu.Download vCU Syslog
        OperatingSystem.Move File
        ...    ${SUITE_LOGS_DIR_PATH}/vCU/full_vCU_syslog
        ...    ${vcu_files_from_iteration}/full_vCU_syslog_alarm_check

        ${vCU_syslog_path_first_DC}    Set Variable
        ...   ${vcu_files_from_iteration}/full_vCU_syslog_alarm_check

        Log To Console    Filtering vCU syslog looking for Alarm notification transaction is finished
        ${FID_appear_time_syslog}=    Filter Log File
        ...    file_path=${vCU_syslog_path_first_DC}
        ...    component=oamfm
        ...    keyword=AlarmService.cpp, Alarm notification transaction is finished
        ...    exclude=INF/CCSBinDecoder
        ...    start_time_str=${Inject_time}
        ...    end_time_str=
        ...    match_all_keywords=True
        ...    case_sensitive=True
        ${FID_appear_time_syslog}=     Get Timestamp Of Event    ${FID_appear_time_syslog}    last

        Log    Clearing injected alarm
        Inject or delete alarms    0   1   ${MRBTS_ID}  ${NRBTS_ID}    ${CRAN_VCU}    ${FID_ID}    vCU
        Set Test Variable    ${Temporary_Alarm_Active}    ${False}
        Log    Checking active critical alarm summary is equal to 0
        Check active critical alarm summary is equal    0    vCU

        Log To Console    Calculating KPI values
        ${BTS_target_result}=     calculate_time_diff    ${alarm_injection_timestamp}    ${FID_appear_time_syslog}
        ${E2E_target_result}=     calculate_time_diff    ${alarm_injection_timestamp}    ${FID_appear_time}

        Log    Appending KPI results to lists
        Append to List    ${vCU_KPI_BTS_results}    ${BTS_target_result}
        Append to List    ${vCU_KPI_E2E_results}    ${E2E_target_result}

        Log To Console    Checking BTS KPI target
        ${is_BTS_KPI_fitting_target}=    Evaluate    ${BTS_target_result} <= ${KPI_Alarm_Duration_BTS_target}
        Run Keyword And Continue On Failure    Should Be True    ${is_BTS_KPI_fitting_target}
        ...      msg=KPI_BTS value ${BTS_target_result} exceeds ${KPI_Alarm_Duration_BTS_target}

        Log To Console    Checking E2E KPI target
        ${is_E2E_KPI_fitting_target}=    Evaluate    ${E2E_target_result} <= ${KPI_Alarm_Duration_E2E_target}
        Run Keyword And Continue On Failure    Should Be True    ${is_E2E_KPI_fitting_target}
        ...      msg=KPI_E2E value ${E2E_target_result} exceeds ${KPI_Alarm_Duration_E2E_target}

        IF    ${is_BTS_KPI_fitting_target}==False or ${is_E2E_KPI_fitting_target}==False
              Log To Console    One of measured KPIs has exceeded the target. Gathering logs and continuing execution.
              Log    Collecting logs due to KPI exceedance
              Collect Logs    ${vcu_files_from_iteration}
        ELSE IF    not ${ok_logs_collected}
              Log To Console    Loop passed! Gathering ok logs to compare.
              ${ok_logs_collected}=    Set Variable    ${True}
              Collect Logs    results_directory=${TEST_RESULTS_DIR}/loop_${index}_ok_logs
              OperatingSystem.Remove Directory    ${vcu_files_from_iteration}    recursive=True
        ELSE
              Log    Removing iteration directory as KPIs are within target
              OperatingSystem.Remove Directory    ${vcu_files_from_iteration}    recursive=True

        END

    END

    Log To Console    Calculating average KPI values and comparing with target..
    ${KPI_BTS_results_avg}=    Run Keyword And Continue On Failure
    ...                                                      Calculate Average KPI Values And Compare With Target
    ...                                                      kpi_results=${vCU_KPI_BTS_results}
    ...                                                      kpi_target=${KPI_Alarm_Duration_BTS_target}

    ${KPI_E2E_results_avg}=    Run Keyword And Continue On Failure
    ...                                                      Calculate Average KPI Values And Compare With Target
    ...                                                      kpi_results=${vCU_KPI_E2E_results}
    ...                                                      kpi_target=${KPI_Alarm_Duration_E2E_target}

    Log    Calculating BTS benchmark plus 40%
    ${KPI_BTS_benchmark_plus_40}=    Evaluate
    ...    ${KPI_Alarm_Duration_BTS_avg_benchmark_target} * 1.40    #DNG11091878
    Run Keyword And Continue On Failure
    ...    Verify KPI Benchmark
    ...    ${KPI_BTS_results_avg}
    ...    ${KPI_BTS_benchmark_plus_40}
    ...    KPI Alarm Reporting Duration vCU

    Log    Calculating E2E benchmark plus 40%
    ${KPI_E2E_benchmark_plus_40}=    Evaluate
    ...    ${KPI_Alarm_Duration_E2E_avg_benchmark_target} * 1.40    #DNG11091878
    Run Keyword And Continue On Failure
    ...    Verify KPI Benchmark
    ...    ${KPI_E2E_results_avg}
    ...    ${KPI_E2E_benchmark_plus_40}
    ...    KPI Alarm Reporting Duration vCU

    Log    Creating results and averages lists
    ${results}=     Create List
    ...    BTS target: KPI Alarm Reporting Duration vCU: @{vCU_KPI_BTS_results}
    ...    E2E target: KPI Alarm Reporting Duration vCU: @{vCU_KPI_E2E_results}

    ${averages}=    Create List
    ...    BTS target: KPI Alarm Reporting Duration vCU: ${KPI_BTS_results_avg}s
    ...    E2E target: KPI Alarm Reporting Duration vCU: ${KPI_E2E_results_avg}s

    ${targets}=     Create List
    ...    BTS target: KPI Alarm Reporting Duration vCU: ${KPI_Alarm_Duration_BTS_target}
    ...    E2E target: KPI Alarm Reporting Duration vCU: ${KPI_Alarm_Duration_E2E_target}

    Log    Creating results file for reporting
    Create Results File    test_results=${results}     average_results=${averages}    target_values=${targets}

    [Teardown]    OAMKPI_Alarm_Reporting_Duration_vCU.Custom Test Teardown

Custom Test Teardown
    [Documentation]
    ...    Custom Test Teardown ensures that any temporary alarms activated during the test are properly cleared.
    ...    If a temporary alarm is still active at the end of the test, this keyword will:
    ...    - Log the start of the teardown process.
    ...    - Delete the temporary alarm using the appropriate injection/deletion keyword.
    ...    - Reset the ${Temporary_Alarm_Active} variable to False.
    ...    - Log the verification step for alarm clearance.
    ...    - Check that the active critical alarm summary is zero to confirm cleanup.
    ...    This prevents test environment contamination and ensures a clean state for subsequent tests.

    Run Keyword If    ${Temporary_Alarm_Active}    Run Keywords
        ...    Log to Console    Custom Test Teardown  AND
        ...    Inject or delete alarms    0   1   ${MRBTS_ID}  ${NRBTS_ID}    ${CRAN_VCU}    ${FID_ID}    vCU    AND
        ...    Set Test Variable    ${Temporary_Alarm_Active}    ${False}    AND
        ...    Log    Checking active critical alarm summary is equal to 0    AND
        ...    Check active critical alarm summary is equal    0    vCU
