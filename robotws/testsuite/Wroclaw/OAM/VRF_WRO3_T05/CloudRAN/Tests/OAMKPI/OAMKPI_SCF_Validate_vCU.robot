*** Settings ***
Documentation
    ...    This test case is used to verify the KPI SCF validate for vCU.
    ...    History of changes:     18.08.2025 - Initial creation
    ...    Author:                 karol.sadowski@nokia.com

*** Keywords ***
OAMKPI SCF Validate vCU
    [Documentation]
    ...    This keyword verifies the KPI SCF validate for vCU.
    ...    BTS target - from syslog, E2E target - from operations history
    ...    It performs the following steps:
    ...    1. Download current full scf from vCU.
    ...    2. Upload SCF from step 1. on vCU.
    ...    3. Validate SCF from step 1. on vCU.
    ...    4. Measures time taken to successfully validate SCF from operations history.
    ...    5. Downloads and filters the vCU syslog to extract timestamps for validate SCF operation.
    ...    6. Calculates the average KPI values and compares them with the target thresholds.
    ...    7. Validates that individual KPI results do not exceed 10% of the calculated average.
    ...    8. Generates a results file containing the KPI results, averages, and target values.
    ...    Arguments:
    ...        - ${test_iterations}: Number of iterations to perform the validate SCF operation.
    ...        - ${BTS_KPI_target}: Target time for validate SCF based on syslog.
    ...        - ${E2E_KPI_target}: Target time for validate SCF based on operations history.
    ...        - ${BTS_KPI_benchmark}: KPI measurement from previous release.
    ...        - ${E2E_KPI_benchmark}: KPI measurement from previous release.
    [Timeout]    12h
    [Arguments]    ${test_iterations}    ${BTS_KPI_target}    ${E2E_KPI_target}    ${BTS_KPI_benchmark}    ${E2E_KPI_benchmark}

    @{BTS_KPI_results}=    Create List
    @{E2E_KPI_results}=    Create List
    @{SCF_SIZE_results}=    Create List
    ${OK_logs_collected}=    Set Variable    ${False}

    Log To Console    Download initial full SCF from vCU
    Download SCF    scf_path=${LOGS_DIR}/vCU_Full_SCF.xml    hw_type=vCU    include_runtime_data=True
    ${SCF_SIZE}=    Get File Size    ${LOGS_DIR}/vCU_Full_SCF.xml
    Append To List    ${SCF_SIZE_results}    ${SCF_SIZE}

    FOR   ${i}    IN RANGE    ${test_iterations}
        TRY
            Log To Console    \n--- Execution loop: ${i + 1} ---\n

            Log To Console    Upload initial full SCF on vCU
            &{plan_vCU}=    Upload SCF    scf_path=${LOGS_DIR}/vCU_Full_SCF.xml    hw_type=vCU

            ${BTS_KPI_start}=    DateTime.Get Current Date    time_zone=UTC
            ${E2E_KPI_start}=    Get Current Date

            Log To Console    Validate full SCF on vCU
            &{validate_operation}=   Validate SCF    hw_type=vCU    plan_id=${plan_vCU['plan_id']}

            ${BTS_KPI_end}=    DateTime.Get Current Date    time_zone=UTC
            ${E2E_KPI_end}=    Get Current Date

            Log To Console    Remove initial SCF on vCU
            Delete SCF    hw_type=vCU    plan_id=${plan_vCU['plan_id']}

            Log To Console    Checking results
            Log To Console    Downloading vCU Syslog For KPI Calculation...
            ${vCU_syslog_path}=    Download vCU Syslog
            Log To Console    Filtering vCU Syslog Looking For Timestamps...
            ${operation_id}=    Get From Dictionary    ${validate_operation}    action_id
            ${start_print}=    Set Variable    PlanValidationScenario: [s_${operation_id[2:]}] Start
            ${end_print}=    Set Variable    PlanValidationScenario: [s_${operation_id[2:]}] Finished

            ${scf_validate_start_syslog_filtered}=    Filter Log File
            ...    file_path=${vCU_syslog_path}
            ...    component=oamasm
            ...    keyword=${start_print}
            ...    start_time_str=${BTS_KPI_start}
            ...    end_time_str=${BTS_KPI_end}
            ...    match_all_keywords=True
            ...    case_sensitive=True
            ${scf_validate_start_timestamp}=    Get Timestamp Of Event    ${scf_validate_start_syslog_filtered}    first

            ${scf_validate_end_syslog_filtered}=    Filter Log File
            ...    file_path=${vCU_syslog_path}
            ...    component=oamasm
            ...    keyword=${end_print}
            ...    start_time_str=${BTS_KPI_start}
            ...    end_time_str=${BTS_KPI_end}
            ...    match_all_keywords=True
            ...    case_sensitive=True
            ${scf_validate_end_timestamp}=    Get Timestamp Of Event    ${scf_validate_end_syslog_filtered}    first

            ${BTS_KPI_result}=    DateTime.Subtract Date From Date    ${scf_validate_end_timestamp}    ${scf_validate_start_timestamp}
            ${BTS_KPI_result}=    Round KPI result    ${BTS_KPI_result}
            Append To List    ${BTS_KPI_results}    ${BTS_KPI_result}

            Sleep    5s    msg=Wait for WebEM operation history to update after SCF upload completion
            ${validate_SCF_vCU_operation}=    Get Operation History    hw_type=vCU    operation_name=Validate plan
            ...   start_time=${E2E_KPI_start}    end_time=${E2E_KPI_end}
            ${E2E_KPI_status}    ${E2E_KPI_measure}=    Check If Operation Meets Target    ${validate_SCF_vCU_operation[0]}    ${E2E_KPI_target}
            ${E2E_KPI_result}=    Convert Operation Duration To Seconds    ${E2E_KPI_measure}
            ${E2E_KPI_result}=    Round KPI result    ${E2E_KPI_result}
            Append To List    ${E2E_KPI_results}    ${E2E_KPI_result}

            Log To Console    Results for loop ${i + 1}:
            Log To Console    KPI SCF validate from syslog: ${BTS_KPI_result} seconds
            Log To Console    KPI SCF validate from operations history: ${E2E_KPI_result} seconds

            ${BTS_KPI_target_check}=    Evaluate    ${BTS_KPI_result} <= ${BTS_KPI_target}
            Run Keyword And Continue On Failure    Should Be True    ${BTS_KPI_target_check}
            ...        msg=KPI value ${BTS_KPI_result} exceeds ${BTS_KPI_target}

            ${E2E_KPI_target_check}=    Evaluate    ${E2E_KPI_result} <= ${E2E_KPI_target}
            Run Keyword And Continue On Failure    Should Be True    ${E2E_KPI_target_check}
            ...        msg=KPI value ${E2E_KPI_result} exceeds ${E2E_KPI_target}

            ${BTS_KPI_result_below_E2E_result}=    Set Variable    ${True}
            # ${BTS_KPI_result_below_E2E_result}=    Evaluate    ${BTS_KPI_result} <= ${E2E_KPI_result}
            # Run Keyword And Continue On Failure    Should Be True    ${BTS_KPI_result_below_E2E_result}
            # ...                                    msg=It is expected to [BTS_kpi (${BTS_KPI_result}) < E2E_kpi (${E2E_KPI_result})

            IF    ${BTS_KPI_target_check} and ${E2E_KPI_target_check} and ${BTS_KPI_result_below_E2E_result} and ${E2E_KPI_status}
                IF    not ${OK_logs_collected}
                    Log To Console    Gathering OK logs and continuing execution.
                    Collect Logs    results_directory=${TEST_RESULTS_DIR}/logs_from_${i}_iteration_PASS
                    ${OK_logs_collected}=    Set Variable    ${True}
                END
                Log To Console   \n--- Loop PASSED! ---\n
            ELSE
                Log To Console    \n--- Loop FAILED! ---\nError during measurement analysis. Gathering logs and continuing execution.\n
                Collect Logs    results_directory=${TEST_RESULTS_DIR}/logs_from_${i}_iteration_FAIL
            END
        EXCEPT    AS    ${ERROR}
            Log To Console    \n--- Loop FAILED! ---\nException occurred:\n${ERROR}\nGathering logs and continuing execution.\n
            Collect Logs    results_directory=${TEST_RESULTS_DIR}/logs_from_${i}_iteration_EXCEPTION
        END
    END

    Log To Console    Calculating Average KPI Values And Comparing With Target...
    ${BTS_KPI_avg}=    Run Keyword And Continue On Failure    Calculate Average KPI Values And Compare With Target
    ...                                                       kpi_results=${BTS_KPI_results}
    ...                                                       kpi_target=${BTS_KPI_target}
    ${E2E_KPI_avg}=    Run Keyword And Continue On Failure    Calculate Average KPI Values And Compare With Target
    ...                                                       kpi_results=${E2E_KPI_results}
    ...                                                       kpi_target=${E2E_KPI_target}
    Log To Console     Comparing Average KPI Values With Previous Release Results...
    Run Keyword And Continue On Failure    Check Average KPI Value With Previous Release Result    ${BTS_KPI_avg}    ${BTS_KPI_benchmark}
    Run Keyword And Continue On Failure    Check Average KPI Value With Previous Release Result    ${E2E_KPI_avg}    ${E2E_KPI_benchmark}

    ${results}=     Create List     BTS:    @{BTS_KPI_results}s      E2E:    @{E2E_KPI_results}s    SCF_SIZE:    @{SCF_SIZE_results}bytes
    ${averages}=    Create List     BTS:    ${BTS_KPI_avg}s          E2E:    ${E2E_KPI_avg}s
    ${targets}=     Create List     BTS:    ${BTS_KPI_benchmark}s    E2E:    ${E2E_KPI_benchmark}s
    Create Results File    test_results=${results}     average_results=${averages}    target_values=${targets}

    [Teardown]    Run Keyword And Ignore Error    Delete SCF    hw_type=vCU    plan_id=${plan_vCU['plan_id']}
    [Return]    ${BTS_KPI_avg}    ${E2E_KPI_avg}