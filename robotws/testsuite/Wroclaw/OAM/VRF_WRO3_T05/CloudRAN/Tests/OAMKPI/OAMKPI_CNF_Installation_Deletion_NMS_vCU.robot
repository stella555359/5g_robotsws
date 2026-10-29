*** Settings ***
Documentation    Test case to verify duration of vCU Installation and Termination triggered from Mantaray.
...              Author:    damian.kotula@nokia.com
...              Change history:
...              04.11.2025 - Initial creation

*** Variables ***
@{installation_kpi_results}        # list to store installation KPI results
@{deletion_kpi_results}            # list to store deletion KPI results
${accepted_degradation}    1.15    # 15% is max accepted degradation from prev release according to 11091878

*** Keywords ***
OAMKPI_CNF_Installation_Deletion_NMS_vCU
    [Documentation]
    ...    This test case measures the KPI of vCU installation and termination via Mantaray.
    ...    Testline must be deployed from Mantaray and onAir as precondition for this test.
    ...    It performs a specified number of iterations, and in each iteration it:
    ...    1. Terminates the vCU and measures the deletion duration.
    ...    2. Deploys the vCU and measures the installation duration.
    ...    3. Compares the measured times against KPI targets.
    ...    4. Collects logs if KPIs are not met.
    ...    Input:    test_iterations = The number of installation/termination cycles to run.
    ...              nms_lab = NMS lab number where TL is currently deployed, will be used for test (e.g., '5007').
    ...              ccr_name = The name of the CCR on selected lab be used for deployment.
    ...              installation_KPI_target = target of Installation procedure in seconds
    ...              installation_KPI_benchmark = last release result of Installation procedure in seconds
    ...              deletion_KPI_target = target of Deletion procedure in seconds
    ...              deletion_KPI_benchmark = last release result of Deletion procedure in seconds
    [Arguments]    ${test_iterations}    ${nms_lab}    ${ccr_name}    ${installation_KPI_target}
    ...            ${installation_KPI_benchmark}    ${deletion_KPI_target}    ${deletion_KPI_benchmark}

    Set Test Variable    ${NMS_LAB_IP}    ${SRNCLAB${nms_lab}}
    @{vdu_alarms}=    Create List    ${FAULT_7504}    ${FAULT_7505}
    watchdog.Add Allowed Alarms To Watchdog    alarms_list=${vdu_alarms}    hw_type=vDU
    watchdog.Start Watchdog    hw_type=vDU    log_dir=${TEST_RESULTS_DIR}
    FOR   ${i}    IN RANGE    ${test_iterations}
        Log    \n--- Execution loop: ${i + 1} of ${test_iterations} ---\n    console=${True}
        Log    Starting vCU Termination    console=${True}
        ${terminate_feedback}=       Terminate CNF    nms_lab_ip=${NMS_LAB_IP}    hw_type=vCU
        ${terminate_group_id}=       Get Group ID From Feedback    ${terminate_feedback}
        ${deletion_duration}=        kpi.Check Operation Duration At MR Operations History    nms_lab_ip=${nms_lab_ip}
        ...                          id=${terminate_group_id}
        ...                          start_event_text=Prepare CNF Terminate started
        ...                          end_event_text=Delete CNF configuration finished
        Log    Deletion duration: ${deletion_duration}s    console=${True}
        Append To List    ${deletion_kpi_results}    ${deletion_duration}
        ${is_deletion_kpi_in_limits}=          Evaluate    ${deletion_duration} <= ${deletion_KPI_target}
        Run Keyword And Continue On Failure    Should Be True    ${is_deletion_kpi_in_limits}
        ...                                    msg=Deletion KPI value ${deletion_duration} exceeds ${deletion_KPI_target} s

        Set Test Variable    ${vCU_FILES_FROM_ITERATION}    ${SUITE_LOGS_DIR_PATH}/vCU_files_from_iteration_${i}
        Integrate Cloud Server with NMS    nms_lab_ip=${NMS_LAB_IP}    nms_lab_number=${NMS_LAB}    hw_type=vCU
        ${deploy_feedback}=          Perform CNF Deployment        hw_type=vCU    sw_version=${SW_INFO.vCU.sw_version}-amd64
        ...                          nms_lab_number=${NMS_LAB}     nms_lab_ip=${NMS_LAB_IP}    ccr_name=${ccr_name}
        ${deploy_group_id}=          Get Group ID From Feedback    ${deploy_feedback}
        ${comminssioning_time}=      Commission BTS And Wait For OnAir
        ${deployment_duration}=      kpi.Check Operation Duration At MR Operations History    nms_lab_ip=${nms_lab_ip}
        ...                          id=${deploy_group_id}
        ...                          start_event_text=Install helm charts of CNF instance started
        ...                          end_event_text=Install helm charts of CNF instance successfully
        ${installation_duration}=    DateTime.Add Time To Time    ${deployment_duration}    ${comminssioning_time}
        Log    Installation duration: ${installation_duration}s    console=${True}
        Append To List    ${installation_kpi_results}    ${installation_duration}
        ${is_installation_kpi_in_limits}=      Evaluate    ${installation_duration} <= ${installation_KPI_target}
        Run Keyword And Continue On Failure    Should Be True    ${is_installation_kpi_in_limits}
        ...                                    msg=Installation KPI value ${installation_duration} exceeds ${installation_KPI_target} s
        IF    not ${is_installation_kpi_in_limits}
              Log To Console    Installation KPI has exceeded the target. Gathering logs and continuing execution.
              Collect Logs    ${vcu_files_from_iteration}
        ELSE
              OperatingSystem.Remove Directory    ${vcu_files_from_iteration}    recursive=True
        END
        Remove All Alarms from Allowed List    hw_type=vCU
        watchdog.Check if Disallowed Alarm was Detected during Watchdog    hw_type=vCU
        watchdog.Stop Watchdog    hw_type=vCU
    END
    Check Averages And Degradation    installation_KPI_target=${installation_KPI_target}
    ...                               installation_KPI_benchmark=${installation_KPI_benchmark}
    ...                               deletion_KPI_target=${deletion_KPI_target}
    ...                               deletion_KPI_benchmark=${deletion_KPI_benchmark}
    Remove All Alarms from Allowed List    hw_type=vDU
    watchdog.Check if Disallowed Alarm was Detected during Watchdog    hw_type=vDU
    watchdog.Stop Watchdog    hw_type=vDU


Commission BTS And Wait For OnAir
    [Documentation]    Description:    Commissions the vCU by deploying an SCF and waits for all cells to be operational.
    ...                Output:         time_to_cells_up = The duration of the commissioning process (in seconds).

    ${scf_start_time}=    DateTime.Get Current Date    time_zone=UTC
    ${VCU_CONNECTION}=    vcu_admin.connect_to    host=${LMP_VCU_IP}    port=${DEFAULT_PORT}    username=${WEBEM_USERNAME}
    ...                                           password=nemuuser     alias=vcu_after_deploy    secure=${True}
    ...                                           update_expired_password=${True}
    Set Test Variable    ${VCU_CONNECTION}
    Deploy SCF    hw_type=vCU    scf_path=${LOGS_DIR}/vCU_SCF_before_suite.xml    wait_until_done=${True}
    @{vcu_alarms}=    Create List    ${FAULT_4592}    ${FAULT_4681}
    watchdog.Add Allowed Alarms To Watchdog    alarms_list=${vcu_alarms}    hw_type=vCU
    watchdog.Start Watchdog      hw_type=vCU    log_dir=${TEST_RESULTS_DIR}
    Wait Until Keyword Succeeds  15m  30s  cloud_frame.Check Cell States On vDU   ${VDU_CONNECTION}
    Wait Until Keyword Succeeds  10m  30s  cloud_frame.Check Cell States On vCU   ${VCU_CONNECTION}
    ${scf_finished_time}=    DateTime.Get Current Date    time_zone=UTC
    OperatingSystem.Create Directory    ${vCU_FILES_FROM_ITERATION}
    Log To Console    Downloading vCU syslog to check when the cells came up
    ${vCU_syslog_path_cells_up}=    syslog_download_from_vdu_vcu.Download vCU Syslog
    OperatingSystem.Move File       ${vCU_syslog_path_cells_up}
    ...                             ${vCU_FILES_FROM_ITERATION}/full_vCU_syslog_cells_up
    ${vCU_syslog_path_cells_up}=    Set Variable    ${vCU_FILES_FROM_ITERATION}/full_vCU_syslog_cells_up
    Log To Console    Filtering vCU syslog looking for cells up timestamps...
    ${cells_up_syslog_filtered}=    Filter Log File
        ...    file_path=${vCU_syslog_path_cells_up}
        ...    component=cpnb
        ...    keyword=ConcreteOAMInterface.cpp, cellToDeactivateList:[[]], cellToActivateList:[[{, CellStatusInd
        ...    exclude=INF/CCSBinDecoder
        ...    start_time_str=${scf_start_time}
        ...    end_time_str=${scf_finished_time}
        ...    match_all_keywords=True
        ...    case_sensitive=True
    ${last_cell_up}=     Get Timestamp Of Event    ${cells_up_syslog_filtered}    last
    ${time_to_cells_up}=    DateTime.Subtract Date From Date    ${last_cell_up}    ${scf_start_time}
    [Return]    ${time_to_cells_up}

Get Group ID From Feedback
     [Documentation]    Description:    Parses feedback text from an NMS operation to extract the 'Operation Group ID'.
     ...                Input:          feedback_string = The raw text output from an NMS operation.
     ...                Output:         The extracted Operation Group ID as a string.
     [Arguments]    ${feedback_string}
     @{matches}=    Get Regexp Matches    ${feedback_string}    Operation Group ID: (\\d+)    1
     [Return]    ${matches[0]}

Check Averages And Degradation
    [Documentation]    Description:    This Keyword calculates and evaluates average KPI results after all iterations
    ...                                are complete, creates a results file with all results.
    ...                                installation_KPI_target = target of Installation procedure in seconds
    ...                                installation_KPI_benchmark = last release result of Installation procedure in seconds
    ...                                deletion_KPI_target = target of Deletion procedure in seconds
    ...                                deletion_KPI_benchmark = last release result of Deletion procedure in seconds
    [Arguments]     ${installation_KPI_target}    ${installation_KPI_benchmark}    ${deletion_KPI_target}
    ...             ${deletion_KPI_benchmark}
    ${installation_average}=     Run Keyword And Continue On Failure    Calculate Average KPI Values And Compare With Target
    ...                                                                 kpi_results=${installation_kpi_results}
    ...                                                                 kpi_target=${installation_KPI_target}
    ${deletion_average}=         Run Keyword And Continue On Failure    Calculate Average KPI Values And Compare With Target
    ...                                                                 kpi_results=${deletion_kpi_results}
    ...                                                                 kpi_target=${deletion_KPI_target}

    ${installation_degradation_check}=           Evaluate    ${installation_average} > ${installation_KPI_benchmark}
    ${install_benchmark_plus_15_proc}=           Evaluate    ${installation_KPI_benchmark} * ${accepted_degradation}
    ${installation_degradation_over_15_proc}=    Evaluate    ${installation_average} > ${install_benchmark_plus_15_proc}

    ${deletion_degradation_check}=               Evaluate    ${deletion_average} > ${deletion_KPI_benchmark}
    ${deletion_benchmark_plus_15_proc}=          Evaluate    ${deletion_KPI_benchmark} * ${accepted_degradation}
    ${deletion_degradation_over_15_proc}=        Evaluate    ${deletion_average} > ${deletion_benchmark_plus_15_proc}

    IF    ${installation_degradation_check} and not ${installation_degradation_over_15_proc}
        Log    Average installation result is worse than previous release, but less than 15%    level=WARN
    END
    IF    ${deletion_degradation_check} and not ${deletion_degradation_over_15_proc}
        Log    Average deletion result is worse than previous release, but less than 15%        level=WARN
    END

    ${PR_installation_degradation_msg}=    Catenate    SEPARATOR=
    ...    Average installation result (${installation_average}s) is degraded more than 15% over previous release
    ...    (${installation_KPI_benchmark}s). Potential Pronto according to DNG ID 11091878!
    ${PR_deletion_degradation_msg}=    Catenate    SEPARATOR=
    ...    Average deletion result (${deletion_average}s) is degraded more than 15% over previous release
    ...    (${deletion_KPI_benchmark}s). Potential Pronto according to DNG ID 11091878!

    Run Keyword And Continue On Failure    Should Not Be True    ${installation_degradation_over_15_proc}
    ...                                                          msg=${PR_installation_degradation_msg}
    Run Keyword And Continue On Failure    Should Not Be True    ${deletion_degradation_over_15_proc}
    ...                                                          msg=${PR_deletion_degradation_msg}

    ${results}=     Create List     Installation KPI:    @{installation_kpi_results}     Deletion KPI:    @{deletion_kpi_results}
    ${averages}=    Create List     Installation KPI: ${installation_average}s           Deletion KPI: ${deletion_average}s
    ${targets}=     Create List     Installation KPI: ${installation_KPI_target}s        Deletion KPI: ${deletion_KPI_target}s
    Create Results File    test_results=${results}     average_results=${averages}    target_values=${targets}
    OperatingSystem.Remove Directory    ${SUITE_LOGS_DIR_PATH}/vCU
    Log    Average results: ${averages}    console=${True}