*** Settings ***
Documentation
    ...    This test case is used to verify the KPI 51a (RMOD reset downtime) for every radio configured on vDU.
    ...    History of changes:
    ...    13.11.2024 - Initial creation
	...    17.11.2025 - TC Refactor - Iuliia Taupeka

Variables        ../../Resources/ru_families.yaml

*** Variables ***
@{KPI_51a_results}        # list to store KPI results
${accepted_degradation}    1.15    # 15% is max accepted degradation from prev release according to 11091878
@{RESULTS}
@{AVERAGES}
@{TARGETS}

*** Keywords ***
OAMKPI RMOD Reset vDU
    [Documentation]
    ...    This keyword verifies the KPI 51a (RMOD reset downtime) for every radio configured on vDU
    ...    It performs following steps:
    ...    1. Watchdog is started to monitor alarms on testline.
	...    2. Performs preconditions: RU units of testline are identified and corresponding necessary variables are set.
	...    3. In loop for each of RMODs:
	...    For each RMOD in range of test iterations (given in testsuite):
    ...    4. In each iteration, RMOD reset is performed.
    ...    5. Time from the first cell going down to the last cell coming up is measured
    ...    6. Measured time is compared against a calculated target. The target time is adjusted based on RU family exceptions.
	...    7. Average is calculated for each RMOD and its value compared to benchmark from previous SW release for this configuration.
	...    8. Results file containing the KPI results, averages and target values is generated.
	...    Arguments:
    ...        - ${test_iterations}: Number of iterations to perform the RMOD reset operations.
    ...    Returns:
    ...        - ${AVERAGES}: Average time for KPI 51a for each of RMODs.
    [Arguments]    ${test_iterations}

    Preconditions
	FOR    ${id}    IN    @{ids}
        Log    \nStarting loop of resets for ${id} RMOD procedure\n    console=${True}
        Set Test Variable    ${ok_logs_collected}    ${False}
        ${product_name}=    Get From Dictionary    ${rmod_id_product_dict}    ${id}
        Set Test Variable    ${product_name}
        ${downtimes}=    Create List
        Check Family And Extra Time If Its Excepted    ${id}    ${product_name}
        FOR    ${i}    IN RANGE    ${test_iterations}
            ${id_as_list}=    Create List    ${id}
			Set Test Variable    ${vDU_FILES_FROM_ITERATION}    ${SUITE_LOGS_DIR_PATH}/vDU_files_from_iteration_${i}
			OperatingSystem.Create Directory    ${vDU_FILES_FROM_ITERATION}
			${reset_time}=    DateTime.Get Current Date    time_zone=UTC

			vdu_admin.Reset Rmods    ${id_as_list}    vdu_connection=${vdu_connection}
            Wait Until Keyword Succeeds    2 min    200ms    CellStatus.Verify At Least One vDU Cell Is Disabled
            ...                                           vdu_connection=${vdu_connection}
			Log    Reset of RMOD ${id_as_list} done. Waiting for cells up.    console=${True}
            Wait Until Keyword Succeeds    10 min    200ms    CellStatus.Verify All vDU Cells Are Enabled
            ...                                            vdu_connection=${vdu_connection}
            ${all_cells_up_time}=    DateTime.Get Current Date    time_zone=UTC

			${vDU_syslog_path_cells_up}=    syslog_download_from_vdu_vcu.Download vDU Syslog
			OperatingSystem.Move File       ${vDU_syslog_path_cells_up}
			...                             ${vDU_FILES_FROM_ITERATION}/full_vDU_syslog_cells_down-up
			${vDU_syslog_path_cells_up}=    Set Variable    ${vDU_FILES_FROM_ITERATION}/full_vDU_syslog_cells_down-up

			${KPI_51a}=    Calculate RMOD Reset Downtime
			...    ${reset_time}    ${all_cells_up_time}    ${vDU_syslog_path_cells_up}


            Append To List    ${downtimes}    ${KPI_51a}
            Log    KPI 51a: downtime of RMOD ${product_name} with id ${id}, iteration ${${i}+1} = ${KPI_51a}s    console=${True}
            ${KPI_51a_max_target}=    Evaluate    ${KPI_51a_target} + ${extra_time}
            Set Test Variable    ${KPI_51a_max_target}

            Check RMOD Downtime Is In Target    ${KPI_51a}    ${product_name}    ${i}    ${id}
        END


        ${KPI_51a_average}=     Run Keyword And Continue On Failure    Calculate Average KPI Values And Compare With Target
        ...                                                           kpi_results=${downtimes}
        ...                                                           kpi_target=${KPI_51a_max_target}
        Check Degradation    ${KPI_51a_average}    ${product_name}
        ${result_string}=    Catenate    SEPARATOR=    ${product_name} id ${id} =    ${downtimes}
        Append To List    ${RESULTS}    ${result_string}
        ${average_string}=    Catenate    SEPARATOR=    ${product_name} id ${id} =    ${KPI_51a_average}
        Append To List    ${AVERAGES}    ${average_string}
        ${target_string}=    Catenate    SEPARATOR=    ${product_name} id ${id} =    ${KPI_51a_max_target}
        Append To List    ${TARGETS}    ${target_string}
    END

    Create Results File    test_results=${RESULTS}     average_results=${AVERAGES}    target_values=${TARGETS}

    Remove All Alarms from Allowed List    hw_type=vDU
    Remove All Alarms from Allowed List    hw_type=vCU
    watchdog.Check if Disallowed Alarm was Detected during Watchdog    hw_type=vCU
    watchdog.Check if Disallowed Alarm was Detected during Watchdog    hw_type=vDU
    watchdog.Stop Watchdog    hw_type=vCU
    watchdog.Stop Watchdog    hw_type=vDU
    [Return]    ${AVERAGES}




Preconditions
    [Documentation]    Description:    This keyword starts the alarm watchdog, adds a list of allowed alarms,
	...                                RU units of testline are identified and corresponding necessary variables are set

	Log  \nStep 0: Preconditions  console=${True}
	watchdog.Start Watchdog    hw_type=vCU    log_dir=${TEST_RESULTS_DIR}
    watchdog.Start Watchdog    hw_type=vDU    log_dir=${TEST_RESULTS_DIR}
    @{vdu_alarms}=    Create List    ${FAULT_16}    ${FAULT_16_critical}    ${FAULT_4405}    ${FAULT_4298}
    ...                              ${FAULT_4298_critical}    ${FAULT_4298_major}    ${FAULT_4647}
    @{vcu_alarms}=    Create List    ${FAULT_7104}
    Add Allowed Alarms    alarms_list=${vdu_alarms}    hw_type=vDU
    Add Allowed Alarms    alarms_list=${vcu_alarms}    hw_type=vCU

    ${rmod_listed}=    vdu_admin.Get Rmods Status    vdu_connection=${vdu_connection}
    Set Test Variable    ${rmod_listed}
    ${ids}=    Create List
    ${product_names}=      Create List

    FOR    ${item}    IN    @{rmod_listed}
        ${product_name}=    Get From Dictionary    ${item}    product_name
        ${id}=    Get From Dictionary    ${item}    id
        Append To List    ${product_names}    ${product_name}
        Append To List    ${ids}    ${id}
    END

    ${rmod_id_product_dict}=    Create Dictionary From Lists    keys=${ids}    values=${product_names}
    Set Test Variable    ${ids}
    Set Test Variable    ${product_names}
    Set Test Variable    ${rmod_id_product_dict}
	Log    RMODs available on config: ${rmod_id_product_dict} \n    console=${True}

Calculate RMOD Reset Downtime
	[Documentation]    This keyword checks RMOD reset duration from syslog prints (calculating from first cell down to last cell up)
    [Arguments]    ${starttime}    ${endtime}	${syslog_path}
    Log    Start calculation of RMOD reset duration  console=${True}
    ${cells_deactivation_syslog_filtered}=    Filter Log File
        ...    file_path=${syslog_path}
        ...    component=cprt
        ...    keyword=AntennaCarrierDeactivationResp - OK
		...    exclude=INF/CCSBinDecoder
        ...    start_time_str=${starttime}
        ...    end_time_str=${endtime}
        ...    match_all_keywords=True
        ...    case_sensitive=True
    ${first_cell_down_timestamp}=    Get Timestamp Of Event    ${cells_deactivation_syslog_filtered}    first
    Log    First cell down timestamp from syslog ${first_cell_down_timestamp}    console=${True}

    ${cells_up_syslog_filtered}=    Filter Log File
        ...    file_path=${syslog_path}
        ...    component=cprt
        ...    keyword=AntennaCarrierActivationResp - OK
		...    exclude=INF/CCSBinDecoder
        ...    start_time_str=${starttime}
        ...    end_time_str=${endtime}
        ...    match_all_keywords=True
        ...    case_sensitive=True
    ${last_cell_up_timestamp}=    Get Timestamp Of Event    ${cells_up_syslog_filtered}    last
    Log     Last cell up timestamp from syslog ${last_cell_up_timestamp}        console=${True}

    ${KPI_51a_ressult}=    DateTime.Subtract Date From Date    ${last_cell_up_timestamp}    ${first_cell_down_timestamp}
    [Return]     ${KPI_51a_ressult}


Check RMOD Downtime Is In Target
    [Documentation]     Description:    This keyword verifies that measured RMOD reset downtime is in target.
    [Arguments]    ${KPI_51a_result}    ${product_name}    ${i}    ${id}
    ${is_KPI_51a_in_target}=    Evaluate    ${KPI_51a_result} <= ${KPI_51a_max_target}
    Run Keyword And Continue On Failure    Should Be True    ${is_KPI_51a_in_target}
    ...                                    msg=KPI_51a value ${KPI_51a_result} exceeds ${KPI_51a_max_target}

    IF    ${is_KPI_51a_in_target} == False
          Log     KPI has exceeded the target. Gathering logs and continuing execution.    console=${True}
          Collect Logs    ${vDU_FILES_FROM_ITERATION}
    ELSE
          IF    not ${ok_logs_collected}
              Log To Console    Gathering ok logs and continuing execution.
              Set Test Variable    ${ok_logs_collected}    ${True}
              Collect Logs    ${TEST_RESULTS_DIR}/logs_from_${product_name}_${id}_iteration_${i+1}_PASS
          END
          Log    Deleting logs
          Log    KPI_51a value ${KPI_51a_result} is in target of ${KPI_51a_max_target} seconds    console=${True}
          OperatingSystem.Remove Directory    ${vDU_FILES_FROM_ITERATION}    recursive=True
    END


Create Dictionary From Lists
    [Documentation]    Description:    Creates a dictionary from two lists.
    ...                Input:          keys = desired keys of new dictionary
    ...                                values = desired values of each key in new dictionary
    ...                Output:         dictionary = created dictionary from input key-value pairs

    [Arguments]    ${keys}    ${values}
    ${dictionary}=    Create Dictionary
    ${len_keys}=    Evaluate    len(${keys})
    FOR    ${i}    IN RANGE    0    ${len_keys}
        Set To Dictionary    ${dictionary}    ${keys}[${i}]    ${values}[${i}]
    END
    [Return]    ${dictionary}


Get Interface Type For RMOD
    [Documentation]    Description:    Returns the interface type for given radio unit
    ...                Input:          RMOD_id = int of ID of desired RU
    ...                Output:         interface_type = str interface type of RU ("CPRI" or "eCPRI")

    [Arguments]    ${RMOD_id}
    FOR    ${rmod}    IN    @{rmod_listed}
        ${id}=    Get From Dictionary    ${rmod}    id
        Run Keyword If    ${id} == ${RMOD_id}    Set Test Variable    ${interface_type}    ${item['interface_type']}
    END
    [Return]    ${interface_type}

Check Family And Extra Time If Its Excepted
    [Documentation]    Description:    This keyword based on the RU family determines an additional time offset.
    ...                                DNG req ID for exceptions: 11121711
    ...                                Additionally the interface type is checked for PULSAR family as this impacts the exception extra time.
    ...                Input:          id = int of ID of desired RU
    ...                                product_name = str model of RU

    [Arguments]    ${id}    ${product_name}

    Check Excepted RMOD Family    ${product_name}
    IF    ${RMOD_excepted}
        Log   \nRMOD ${product_name} belongs to excepted family ${family_name}    console=${True}
        IF    '${family_name}' == 'PULSAR'
            ${interface_type}=    Get Interface Type For RMOD    ${id}
            IF    '${interface_type}' == 'eCPRI'
                ${extra_time}=    Set Variable    60
            ELSE
                ${extra_time}=    Set Variable    240
            END
            Set Test Variable    ${extra_time}
            Log    Additional time for family ${family_name} ${interface_type} as per OAM_GEN_SFS_PERF_CAP.12847 is ${extra_time}s    console=${True}
            Return From Keyword If    ${TRUE}
        END
        ${extra_time}=    Get From Dictionary    ${EXCEPTION_FAMILY_TIMES_DICT}    ${family_name}
        Set Test Variable    ${extra_time}
        Log    Additional time for family ${family_name} as per OAM_GEN_SFS_PERF_CAP.12847 is ${extra_time}s    console=${True}

    ELSE
        Log    RMOD ${product_name} does not belong to an excepted family    console=${True}
        Set Test Variable    ${extra_time}    0
    END

Check Excepted RMOD Family
    [Documentation]    Description:    Sets variable ${family_name} which contains the radio family of the input radio unit model.
    ...                Input:          product_name = str RU model

    [Arguments]    ${product_name}
    ${match}    Set Variable    ${FALSE}
    Set Test Variable    ${RMOD_excepted}    ${FALSE}
    FOR    ${family}    IN    &{FAMILY_DICT}
        FOR    ${product}    IN    ${family}[1]
            ${match}=    Run Keyword And Return Status    Should Contain    ${product}    ${product_name}
            IF    ${match}
                Set Test Variable    ${RMOD_excepted}  ${TRUE}
                ${family_name}=    Evaluate    "${family}[0]"
                Set Test Variable    ${family_name}
                Exit For Loop
            END
        IF    ${match}    Exit For Loop
        END
    IF    ${match}    Exit For Loop
    END

Add Allowed Alarms
     [Documentation]    Adds a list of allowed alarms for the watchdog.
     [Arguments]    ${alarms_list}    ${hw_type}
     FOR    ${alarm}    IN    @{alarms_list}
         watchdog.Add Alarm to the Allowed List    fault_id=${alarm.fault_id}    fault_name=${alarm.fault_name}
         ...                                       severity=${alarm.severity}    hw_type=${hw_type}
     END

Check Degradation
    [Documentation]    This keyword validates degradation comparing to previous release benchmarks.
	[Arguments]    ${KPI_avg}    ${product_name}
    ${degradation_check}=           Evaluate    ${KPI_avg} > ${KPI_51a_${product_name}_benchmark}
    ${benchmark_plus_15_proc}=      Evaluate    ${KPI_51a_${product_name}_benchmark} * ${accepted_degradation}
    ${degradation_over_15_proc}=    Evaluate    ${KPI_avg} > ${benchmark_plus_15_proc}
    IF    ${degradation_check} and not ${degradation_over_15_proc}
        Log    Average result (${KPI_avg}s) is worse than previous release (${KPI_51a_${product_name}_benchmark}s), but less than 15%
        ...    level=WARN
    END
    ${PR_degradation_msg}=    Catenate    SEPARATOR=
     ...    Average result (${KPI_avg}s) is degraded more than 15% over previous release
     ...    (${KPI_51a_${product_name}_benchmark}s). Potential Pronto according to DNG ID 11091878!
    Run Keyword And Continue On Failure    Should Not Be True    ${degradation_over_15_proc}    msg=${PR_degradation_msg}
    Log    Average result (${KPI_avg}s) is less than previous release (${KPI_51a_${product_name}_benchmark}s). OK    console=${True}
