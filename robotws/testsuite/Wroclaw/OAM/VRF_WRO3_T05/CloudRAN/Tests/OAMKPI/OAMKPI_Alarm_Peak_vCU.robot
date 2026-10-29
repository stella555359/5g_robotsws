*** Settings ***
Documentation
    ...    This test verifies that the vCU can reach the active alarm peak KPI target
    ...    within the allowed time limit, over multiple iterations.
    ...
    ...    Purpose:
    ...        - Ensure that the vCU generates the configured number of critical alarms
    ...          within the maximum allowed KPI time.
    ...        - Validate both average and per-iteration KPI compliance.
    ...
    ...    Steps:
    ...        1. Run the KPI measurement for the specified number of iterations.
    ...        2. For each iteration:
    ...            - Check active alarms before starting.
    ...            - Inject the configured number of alarms.
    ...            - Measure the time between the first and last alarm appearance.
    ...            - Store the duration for later analysis.
    ...            - Remove all injected alarms.
    ...        3. Calculate and compare the average KPI time with the target.
    ...        4. Ensure that no iteration exceeded the KPI time limit.
    ...        5. Verify that vCU and vDU cells are operational after the test.
    ...
    ...    Expected Results:
    ...        - All iterations meet the KPI target.
    ...        - Average KPI time is within the allowed limit.
    ...        - No alarms remain after cleanup.
    ...        - Network elements return to operational state.
    ...
    ...    Arguments:
    ...        - ${test_iterations}: Number of repetitions for the measurement.
    ...        - ${KPI_vCU_Alarm_Peak_vCU_target}: Target number of alarms.
    ...        - ${KPI_vCU_Alarm_Peak_Time_vCU_target}: Maximum allowed time (in seconds).
    ...
    ...    Change History:
    ...        11.08.2025 - Initial creation
    ...        Author: jakub.kokoszka@nokia.com

*** Keywords ***
OAMKPI Alarm Peak vCU
    [Documentation]
    ...    This keyword performs the KPI measurement for active alarm peak generation
    ...    on the vCU and stores the results for validation.
    ...
    ...    Actions Performed:
    ...        - Retrieves MRBTS and NRBTS IDs from the vCU plan.
    ...        - Confirms there are no active alarms at the start.
    ...        - Injects the target number of alarms for KPI measurement.
    ...        - Waits briefly for alarms to be registered.
    ...        - Validates that the number of active alarms matches the target.
    ...        - Collects and sorts alarm appearance timestamps.
    ...        - Calculates the duration between the first and last alarm.
    ...        - Appends the result to the KPI results list.
    ...        - Removes all injected alarms and ensures no alarms remain.
    ...
    ...    Arguments:
    ...        - ${test_iterations}:  Number of iterations to perform the lock/unlock operations.
    ...        - ${KPI_vCU_Alarm_Peak_vCU_target}:    Target Alarm Peak
    ...        - ${KPI_vCU_Alarm_Peak_Time_vCU_target}:    Target Alarm Peak Time
    ...          required for KPI validation.
    [Timeout]    12h
    [Arguments]    ${test_iterations}
    ...            ${KPI_vCU_Alarm_Peak_vCU_target}
    ...            ${KPI_vCU_Alarm_Peak_Time_vCU_target}

    @{KPI_vCU_Alarm_Peak_vCU_results}=    Create List

    FOR   ${i}    IN RANGE    ${test_iterations}
        ${index}    Evaluate    ${i} + 1
        Log To Console    \n--- Execution loop: ${index} ---\n

        ${MRBTS_ID}    ${NRBTS_ID}    Get MRBTS and NRBTS IDs    vCU
        Check active critical alarm summary is equal    0    vCU
        Log to console    ${KPI_vCU_Alarm_Peak_vCU_target} alarms will be injected for KPI validation
        Inject or delete alarms    1   ${KPI_vCU_Alarm_Peak_vCU_target}   ${MRBTS_ID}  ${NRBTS_ID}    ${CRAN_VCU}    9001    vCU
        Sleep    5s
        Run Keyword And Continue On Failure
        ...    Check active critical alarm summary is equal    ${KPI_vCU_Alarm_Peak_vCU_target}    vCU

        ${active_alarms}=    vcu_admin.get_active_alarms      connection=${vcu_connection}
        ${appear_times}=    Create List
        FOR    ${alarm}    IN    @{active_alarms['alarms']}
            ${appear_time}=    Set Variable    ${alarm['appear_time']}
            Append To List    ${appear_times}    ${appear_time}
        END

        ${sorted_times}=    Evaluate    sorted(${appear_times})
        ${earliest}=    Set Variable    ${sorted_times}[0]
        ${earliest_alarm_appere_time}    Get Substring    ${earliest}  0  26
        ${earliest_alarm_appere_time}=  Convert Date  ${earliest_alarm_appere_time}  %Y-%m-%d %H:%M:%S.%f
        ${latest}=      Set Variable    ${sorted_times}[-1]
        ${latest_alarm_appere_time}    Get Substring    ${latest}  0  26
        ${latest_alarm_appere_time}=  Convert Date  ${latest_alarm_appere_time}  %Y-%m-%d %H:%M:%S.%f

        ${conv_time_0}=   Convert Date    ${earliest_alarm_appere_time}    epoch
        ${conv_time_1}=   Convert Date    ${latest_alarm_appere_time}    epoch
        ${alarms_generate_time}=    Evaluate   ${conv_time_1}-${conv_time_0}

        Append To List    ${KPI_vCU_Alarm_Peak_vCU_results}    ${alarms_generate_time}
        Inject or delete alarms    0   ${KPI_vCU_Alarm_Peak_vCU_target}   ${MRBTS_ID}  ${NRBTS_ID}    ${CRAN_VCU}    9001    vCU
        Sleep    5s
        Check active critical alarm summary is equal    0    vCU
    END

    Log To Console    Calculating average kpi values and comparing with target..
    ${KPI_vCU_Alarm_Peak_avg}=    Run Keyword And Continue On Failure    Calculate Average KPI Values And Compare With Target
    ...                                                      kpi_results=${KPI_vCU_Alarm_Peak_vCU_results}
    ...                                                      kpi_target=${KPI_vCU_Alarm_Peak_vCU_target}

    FOR    ${result}    IN    @{KPI_vCU_Alarm_Peak_vCU_results}
        Run Keyword And Continue On Failure    Should Be True
        ...    ${result} <= ${KPI_vCU_Alarm_Peak_Time_vCU_target}
        ...    msg=KPI vCU Alarm Peak value ${result}s exceeds ${KPI_vCU_Alarm_Peak_Time_vCU_target}s
    END


    ${results}=     Create List
    ...    KPI vCU time to generate ${KPI_vCU_Alarm_Peak_vCU_target} alarms:
    ...    @{KPI_vCU_Alarm_Peak_vCU_results}
    ${averages}=    Create List
    ...    KPI vCU average time to generate ${KPI_vCU_Alarm_Peak_vCU_target} alarms in ${test_iterations} iterations:
    ...    ${KPI_vCU_Alarm_Peak_avg}s
    ${targets}=     Create List
    ...    KPI vCU Alarm Peak time:    ${KPI_vCU_Alarm_Peak_Time_vCU_target}s
    ...    vCU KPI - Number of Alarms:    ${KPI_vCU_Alarm_Peak_vCU_target}
    Create Results File    test_results=${results}     average_results=${averages}    target_values=${targets}

    Wait Until Keyword Succeeds  5m  30s  cloud_frame.Check Cell States On vCU    ${VCU_CONNECTION}
    Wait Until Keyword Succeeds  5m  30s  cloud_frame.Check Cell States On vDU    ${VDU_CONNECTION}




