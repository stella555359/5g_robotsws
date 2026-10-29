*** Settings ***
Documentation
    ...    This test case is used to verify the KPI 1d, 1e and UPUE for vCU
    ...    History of changes:     07.07.2025 - Initial creation
    ...    Author:         jakub.kokoszka@nokia.com

*** Keywords ***
OAMKPI CNF Reset vCU
    [Documentation]
    ...    This keyword verifies the KPI 1d, 1e and UPUE for vCU
    ...    It performs the following steps:
    ...    1. Performing vCU reset
    ...    2. Downloading vCU syslog to check when the cells went down
    ...    3. Downloading vCU syslog to check when the cells came up
    ...    4. Calculates the average KPI values and compares them with the target thresholds.
    ...    5. Validates that individual KPI results do not exceed 5% of the calculated average.
    ...    6. Generates a results file containing the KPI results, averages, and target values.
    ...    Arguments:
    ...        - ${test_iterations}:  Number of iterations to perform the lock/unlock operations.
    ...        - ${KPI_1d_target}:    Target time for KPI 1d.
    ...        - ${KPI_1e_target}:    Target time for KPI 1e.
    ...        - ${KPI_UPUE_target}:  Target time for UPUE KPI.
    ...        - ${KPI_1e_avg_benchmark}: Average result from the previous release
    ...        - ${KPI_1d_avg_benchmark}: Average result from the previous release
    ...        - ${KPI_UPUE_avg_benchmark}: Average result from the previous release
    ...    Returns:
    ...        - ${KPI_1d_avg}:    Average time for KPI 1d across all iterations.
    ...        - ${KPI_1e_avg}:    Average time for KPI 1e across all iterations.
    ...        - ${KPI_UPUE_avg}:  Average time for UPUE KPI across all iterations.
    [Timeout]    12h
    [Arguments]    ${test_iterations}
    ...            ${KPI_1d_target}
    ...            ${KPI_1e_target}
    ...            ${KPI_UPUE_target}
    ...            ${KPI_1e_avg_benchmark}
    ...            ${KPI_1d_avg_benchmark}
    ...            ${KPI_UPUE_avg_benchmark}

    @{KPI_1d_results}=    Create List
    @{KPI_1e_results}=    Create List
    @{KPI_UPUE_results}=    Create List

    ${vnfcs_states}=    vcu_admin.get_vnfcs_states    connection=${VCU_CONNECTION}
    ${upue_count}=    Set Variable    0
    ${upue_count}=    Convert To Integer    ${upue_count}
    FOR    ${vnfc}    IN    @{vnfcs_states}
        ${name}=    Get From Dictionary    ${vnfc}    name
        ${contains}=    Run Keyword And Return Status    Should Contain    ${name}    upue
        Run Keyword If    ${contains}    Set Test Variable    ${upue_count}    ${upue_count +1}
    END

    FOR   ${i}    IN RANGE    ${test_iterations}
        ${index}    Evaluate    ${i} + 1
        Log To Console    \n--- Execution loop: ${index} ---\n
        ${vcu_files_from_iteration}=    Set Variable  ${SUITE_LOGS_DIR_PATH}/vCU_files_from_${index}_iteration
        OperatingSystem.Create Directory    ${vcu_files_from_iteration}
        Log To Console    Performing vCU reset
        ${out}=    vcu_admin.reset cu    connection=${VCU_CONNECTION}
        Should Be Equal    ${out['status']}    ongoing
        ${reset_time}=    DateTime.Get Current Date    time_zone=UTC
        Wait Until Keyword Succeeds  20m  30s  cloud_frame.Check vCU state    ${VCU_CONNECTION}
        ${cells_downtime}=    DateTime.Get Current Date    time_zone=UTC
        Log To Console    Downloading vCU syslog to check when the cells went down
        ${vCU_syslog_path_cells_down}=    syslog_download_from_vdu_vcu.Download vCU Syslog
        OperatingSystem.Move File
        ...    ${SUITE_LOGS_DIR_PATH}/vCU/full_vCU_syslog
        ...    ${vcu_files_from_iteration}/full_vCU_syslog_cells_down

        ${vCU_syslog_path_cells_down}    Set Variable
        ...   ${vcu_files_from_iteration}/full_vCU_syslog_cells_down

        Wait Until Keyword Succeeds  30m  30s  cloud_frame.Check Cell States On vCU   ${VCU_CONNECTION}
        Wait Until Keyword Succeeds  30m  30s  cloud_frame.Check Cell States On vDU    ${VDU_CONNECTION}
        Log To Console    reset completed successfully, vCU and vDU are online...
        ${cells_uptime}=    DateTime.Get Current Date    time_zone=UTC
        Log To Console    Downloading vCU syslog to check when the cells came up
        ${vCU_syslog_path_cells_up}=    syslog_download_from_vdu_vcu.Download vCU Syslog
        OperatingSystem.Move File
        ...    ${SUITE_LOGS_DIR_PATH}/vCU/full_vCU_syslog
        ...    ${vcu_files_from_iteration}/full_vCU_syslog_cells_up

        ${vCU_syslog_path_cells_up}=    Set Variable
        ...   ${vcu_files_from_iteration}/full_vCU_syslog_cells_up

        ${offline_upue_filtered}=    Filter Log File
        ...    file_path=${vCU_syslog_path_cells_down}
        ...    component=oamext
        ...    keyword=K8sClusterSupervisor, readyForConfigStatus, po-upue-, availabilityStatus=["off line"]
        ...    exclude=INF/CCSBinDecoder
        ...    start_time_str=${reset_time}
        ...    end_time_str=
        ...    match_all_keywords=True
        ...    case_sensitive=True

        ${first_upue_goes_to_offline}=    Get Timestamp Of Event    ${offline_upue_filtered}    first
        ${last_upue_goes_to_offline}=     Get Timestamp Of Event    ${offline_upue_filtered}    last

        ${upue_filtered}=    Filter Log File
        ...    file_path=${vCU_syslog_path_cells_down}
        ...    component=oamext
        ...    keyword=K8sClusterSupervisor, readyForConfigStatus, po-upue-, to ON LINE, AGENT_HTTP
        ...    exclude=INF/CCSBinDecoder
        ...    start_time_str=${last_upue_goes_to_offline}
        ...    end_time_str=
        ...    match_all_keywords=True
        ...    case_sensitive=True

        ${time}=    Get Last Upue Online Timestamp    ${upue_filtered}    ${upue_count}

        #Timestamps for the first and last cell down will be updated once the correct logs are identified.
        ${first_cell_down}    Set Variable    ${reset_time}
        ${last_cell_down}     Set Variable    ${reset_time}
        Log To Console    Filtering vCU Syslog Looking For cells up timestamps...
        ${cells_up_syslog_filtered}=    Filter Log File
        ...    file_path=${vCU_syslog_path_cells_up}
        ...    component=cpnb
#       ...    keyword=OAMConfigurationHandler.cpp, cellToDeactivateList: []
        ...    keyword=ConcreteOAMInterface.cpp, cellToDeactivateList:[[]], cellToActivateList:[[{, CellStatusInd
        ...    exclude=INF/CCSBinDecoder
        ...    start_time_str=${reset_time}
        ...    end_time_str=
        ...    match_all_keywords=True
        ...    case_sensitive=True
        ${first_cell_up}=    Get Timestamp Of Event    ${cells_up_syslog_filtered}    first
        ${last_cell_up}=     Get Timestamp Of Event    ${cells_up_syslog_filtered}    last

        ${KPI_UPUE}=    DateTime.Subtract Date From Date    ${time}   ${reset_time}
        Append To List    ${KPI_UPUE_results}    ${KPI_UPUE}
        Log To Console    KPI UPUE (from first cell down to last UPUE ON LINE): ${KPI_UPUE} seconds

        ${KPI_1d}=    DateTime.Subtract Date From Date    ${last_cell_up}    ${first_cell_down}
        Append To List    ${KPI_1d_results}    ${KPI_1d}
        Log To Console    KPI 1d (from first cell down to last cell up): ${KPI_1d} seconds

        ${KPI_1e}=    DateTime.Subtract Date From Date    ${first_cell_up}    ${last_cell_down}
        Append To List    ${KPI_1e_results}    ${KPI_1e}
        Log To Console    KPI 1e (from last cell down to first cell up): ${KPI_1e} seconds

        ${KPI_UPUE_check}=    Evaluate    ${KPI_UPUE} <= ${KPI_UPUE_target}
        Run Keyword And Continue On Failure    Should Be True    ${KPI_UPUE_check}
        ...                                    msg=KPI_UPUE value ${KPI_UPUE} exceeds ${KPI_UPUE_target}

        ${KPI_1d_check}=    Evaluate    ${KPI_1d} <= ${KPI_1d_target}
        Run Keyword And Continue On Failure    Should Be True    ${KPI_1d_check}
        ...                                    msg=KPI_1d value ${KPI_1d} exceeds ${KPI_1d_target}

        ${KPI_1e_check}=    Evaluate    ${KPI_1e} <= ${KPI_1e_target}
        Run Keyword And Continue On Failure    Should Be True    ${KPI_1e_check}
        ...                                    msg=KPI_16a value ${KPI_1e} exceeds ${KPI_1e_target}

        IF    ${KPI_UPUE_check}==False or ${KPI_1e_check}==False or ${KPI_1d_check}==False
              Log To Console    One of measured KPIs has exceeded the target. Gathering logs and continuing execution.
              Collect Logs    ${vcu_files_from_iteration}
        ELSE
              OperatingSystem.Remove Directory    ${vcu_files_from_iteration}    recursive=True
        END
    END

    Log To Console    Calculating average kpi values and comparing with target..
    ${KPI_1d_avg}=    Run Keyword And Continue On Failure    Calculate Average KPI Values And Compare With Target
    ...                                                      kpi_results=${KPI_1d_results}
    ...                                                      kpi_target=${KPI_1d_target}

    ${KPI_1e_avg}=    Run Keyword And Continue On Failure    Calculate Average KPI Values And Compare With Target
    ...                                                      kpi_results=${KPI_1e_results}
    ...                                                      kpi_target=${KPI_1e_target}

    ${KPI_UPUE_avg}=    Run Keyword And Continue On Failure    Calculate Average KPI Values And Compare With Target
    ...                                                        kpi_results=${KPI_UPUE_results}
    ...                                                        kpi_target=${KPI_UPUE_target}

    Run Keyword And Continue On Failure    Verify KPI Benchmark    ${KPI_1d_avg}     ${KPI_1d_avg_benchmark}     KPI_1d
    Run Keyword And Continue On Failure    Verify KPI Benchmark    ${KPI_1e_avg}     ${KPI_1e_avg_benchmark}     KPI_1e
    Run Keyword And Continue On Failure    Verify KPI Benchmark    ${KPI_UPUE_avg}   ${KPI_UPUE_avg_benchmark}   KPI_UPUE

    ${KPI_1d_threshold}=    Evaluate    ${KPI_1d_avg} * 1.05
    ${KPI_1e_threshold}=    Evaluate    ${KPI_1d_avg} * 1.05
    ${KPI_UPUE_threshold}=    Evaluate    ${KPI_UPUE_avg} * 1.20

    FOR    ${result}    IN    @{KPI_1d_results}
        Run Keyword And Continue On Failure    Should Be True
        ...    ${result} <= ${KPI_1d_target}    msg=KPI_1d value ${result} exceeds ${KPI_1d_target}
        Run Keyword And Continue On Failure    Should Be True
        ...    ${result} <= ${KPI_1d_threshold}    msg=KPI_1d value ${result} exceeds 5% threshold ${KPI_1d_threshold}
    END

    FOR    ${result}    IN    @{KPI_1e_results}
        Run Keyword And Continue On Failure    Should Be True
        ...    ${result} <= ${KPI_1e_target}    msg=KPI_1e value ${result} exceeds ${KPI_1e_target}
        Run Keyword And Continue On Failure    Should Be True
        ...    ${result} <= ${KPI_1e_threshold}    msg=KPI_1e value ${result} exceeds 5% threshold ${KPI_1e_threshold}
    END

    FOR    ${result}    IN    @{KPI_UPUE_results}
        Run Keyword And Continue On Failure    Should Be True
        ...    ${result} <= ${KPI_UPUE_target}    msg=KPI_UPUE value ${result} exceeds ${KPI_UPUE_target}
        Run Keyword And Continue On Failure    Should Be True
        ...    ${result} <= ${KPI_UPUE_threshold}    msg=KPI_UPUE value ${result} exceeds 5% threshold ${KPI_UPUE_threshold}
    END

    ${results}=     Create List     KPI 1d:    @{KPI_1d_results}    KPI 1e:    @{KPI_1e_results}    KPI UPUE:    @{KPI_UPUE_results}
    ${averages}=    Create List     KPI 1d:    ${KPI_1d_avg}s       KPI 1e:    ${KPI_1e_avg}s       KPI UPUE:    ${KPI_UPUE_avg}s
    ${targets}=     Create List     KPI 1d:    ${KPI_1d_target}s    KPI 1e:    ${KPI_1e_target}s    KPI UPUE:    ${KPI_UPUE_target}s
    Create Results File    test_results=${results}     average_results=${averages}    target_values=${targets}
    [Return]    ${KPI_1e_avg}    ${KPI_1d_avg}    ${KPI_UPUE_avg}
