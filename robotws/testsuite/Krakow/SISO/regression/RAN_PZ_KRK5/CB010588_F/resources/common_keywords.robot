*** Settings ***
Documentation
...   Keywords for regression testing of feature CB0010588
...   author: Mateusz Bugaj, Daniel Kulaga, Pawel Grabania
...   contact: mateusz.bugaj@nokia.com, daniel.kulaga@nokia.com, pawel.grabania@nokia.com

#Resource     taf/rfrl/procedures/SISO/General_SiSo_HWPTA_Collect_RFSW_Logs_From_RU_Into_BTS_Snapshot.robot
Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource     taf/rfrl/procedures/resources/robot/BtsConfiguration.robot
Resource     taf/rfrl/bts/robot/common/gnb_bbu.robot
Resource     taf/rfrl/bts/robot/common/gnb_scf.robot
Library      String
Library      taf.rfrl.bts.devices.asir.asir_operations.GnbAsirHubOperations          WITH NAME    asir
Library      taf.rfrl.utilities.logger.custom_logger                              WITH NAME    logger
Library      taf.rfrl.procedures.resources.python.common_allowed_alarms           WITH NAME    alarm
Library      taf.rfrl.bts.devices.du.cell_operations.GnbCellOperations            WITH NAME    cell_operations
Library      ./resources.py                                                       WITH NAME    local_resources
Library      ./call_procedure/ue_proxy.py                                         WITH NAME    ue_proxy
Library      ./call_procedure/bts_operations.py
Library      ./call_procedure/ue_operations.py
Library      ./call_procedure/common_operations.py
Library      ./call_procedure/attenuator_operations.py
Library      ./call_procedure/console_thput_table.py
Library      ./call_procedure/html_thput_table.py
Variables    ./common_variables.py

*** Variables ***
${tl_config}=     /home/ute/auto/testline_configuration/`uname -n | sed -r 's/(.*)-[0-9]$/\1/' | tr "-" "_"`/__init__.py


*** Keywords ***
Set additional alarms
    [Arguments]    ${alarms_for_test}
    Set Test Variable    ${CUSTOM_ALLOWED_ALARMS}    ${alarms_for_test}


Actions before test
    [Arguments]    ${alarms_for_test}=${None}
    ${default_alarms}=    alarm.get_variables
    Set Test Variable    ${allowed_alarms}    ${default_alarms}[allowed_alarms]
    Set Test Variable    ${ASIR_ALLOWED_ALARMS}    ${default_alarms}[ASIR_ALLOWED_ALARMS]
    Run keyword if    "${alarms_for_test}!=${None}"    Set additional alarms    ${alarms_for_test}
    Common Preconditions With Watching Alarms


Actions after test
    Remove custom allowed alarms if defined
    Common Postconditions With Watching Alarms


Verify snapshot
    Fail    KW not supported due to the General_SiSo_HWPTA_Collect_RFSW_Logs_From_RU_Into_BTS_Snapshot removed
#    Prepare logs path
#    ${repo_path}=    taf.rfrl.utilities.test_config.Get Repository Path
#    ${asir_csv_path}=    Set Variable    testsuite/Krakow/SISO/regression/RAN_PZ_KRK5/CB010588_F/resources/ASIR.csv
#    General_SiSo_HWPTA_Collect_RFSW_Logs_From_RU_Into_BTS_Snapshot
#	...    additional_documentation_path=${repo_path}/${asir_csv_path}
#    local_resources.check_snapshot     directory=${logs_path}/Full/snapshot.zip


RAT reset
    [Arguments]    ${rat}=LTE
    local_resources.action_with_rat    rat=${rat}    action=reset
    Set Test Variable    ${CELL_MAP_FOR_RAT_RESET_tmp}      ${CELL_MAP_FOR_RAT_RESET}[${rat}]
    ${rat_to_reset}=        Convert To Lowercase        ${rat}
    FOR    ${Cell}     IN    @{CELL_MAP_FOR_RAT_RESET_tmp}
        Run Keyword If      '${rat}'=='NR'     Wait Until Keyword Succeeds     600 sec     1 sec
        ...                             cell_operations.verify_all_cells_statuses       cell_type=${rat_to_reset}
        ...                             operational_state=disabled     administrative_state=unlocked
        ...                             availability_status=failed     procedural_status=not initialized

        Run Keyword If      '${rat}'=='LTE'     Wait Until Keyword Succeeds     600 sec     1 sec
        ...                             cell_operations.verify_all_cells_statuses       cell_type=${rat_to_reset}
        ...                             operational_state=disabled     administrative_state=unlocked
        ...                             availability_status=offline     procedural_status=configured

    END
    logger.log_info_to_console     All ${rat} cells were disabled, waiting till all cells are up.
    Wait Until Keyword Succeeds    900 sec    30 sec    gnbcell.Verify All Cells Are OnAir


Change BTS parameter
    [Arguments]    ${dist_name}    ${param_name}    ${correct_value}    ${incorrect_value}
    ...            ${fault_type}
    logger.log_info_to_console    Changing ${param_name} in object ${dist_name} to correct value: ${correct_value}.
    ...                           log_hierarchy=${4}
    Perform Configuration Parameter Recommissioning On gNB    dist_name=${dist_name}    param_name=${param_name}
    ...                                                       operation=update    param_value=${correct_value}
    ...                                                       skip_parameter_relation_errors=True
    ...                                                       should_activate=True    timeout=600
    Wait Until Keyword Succeeds    900 sec    15 sec    gnbcell.Verify All Cells Are OnAir
    ${maxParallelXnSetup_to_verify}=    Create Dictionary
    ...    ${param_name}=${correct_value}
    ${param_to_verify}=    Create Dictionary
    ...    ${dist_name}=${maxParallelXnSetup_to_verify}
    Verify gNB Configuration Parameters Have Expected Values
        ...    param_dict=${param_to_verify}
    logger.log_info_to_console    Changing ${param_name} in object ${dist_name} to incorrect value: ${incorrect_value}
    ...                           log_hierarchy=${4}
    ${msg}=    Run Keyword And Expect Error    AdminApiProcedureFailureException*
        ...    Perform Configuration Parameter Recommissioning On gNB
            ...    dist_name=${dist_name}
            ...    param_name=${param_name}
            ...    operation=update
            ...    param_value=${incorrect_value}
            ...    skip_parameter_relation_errors=True
            ...    should_activate=True
            ...    timeout=600
    Should Contain    ${msg}    ${fault_type}
    Verify gNB Configuration Parameters Have Expected Values
        ...    param_dict=${param_to_verify}
    Wait Until Keyword Succeeds    900 sec    30 sec    gnbcell.Verify All Cells Are OnAir


Change Parameters In Commissioning
    [Arguments]    ${params_to_change}
    FOR    ${param_to_change}    IN    @{params_to_change}
        ${param_name}         Set Variable    ${param_to_change}[param_name]
        ${dist_name}          Set Variable    ${param_to_change}[dist_name]
        ${correct_value}      Set Variable    ${param_to_change}[correct_value]
        ${incorrect_value}    Set Variable    ${param_to_change}[incorrect_value]
        ${mod_type}           Set Variable    ${param_to_change}[mod_type]
        ${fault_type}         Set Variable    ${param_to_change}[fault_type]
        ${dist_name}    local_resources.adjust_dist_name    dist_name=${dist_name}
        logger.log_info_to_console    msg=Modyfication type: ${mod_type}    log_hierarchy=${3}
        Change BTS parameter    dist_name=${dist_name}    param_name=${param_name}
        ...                     correct_value=${correct_value}    incorrect_value=${incorrect_value}
        ...                     fault_type=${fault_type}
    END


Save Configuration
    [Arguments]    ${scf_file_name}=initial_configuration.xml
    ...            ${file_path}=/tmp    ${asir_file_name}=initial_configuration_asir.xml
    Save current configuration    file_name=initial_configuration.xml
    ${asir_path}=    asir.get_current_scf_file    local_dir_path=${file_path}    file_name=${asir_file_name}
    [Return]    ${file_path}/${scf_file_name}    ${file_path}/${asir_file_name}


Manual_SiSo_CM_Recommissioning
    [Arguments]    ${scf_file_path}=/tmp/initial_configuration.xml
    ...            ${asir_file_path}=/tmp    ${asir_file_name}=initial_configuration_asir.xml
    Save current configuration    file_name=initial_configuration.xml
    ${asir_path}=    asir.get_current_scf_file    local_dir_path=${asir_file_path}    file_name=${asir_file_name}
    FOR    ${rat}    IN    @{all_parameters_to_change}
        logger.log_info_to_console    Changing parameters in BTS for specific RAT: ${rat}    log_hierarchy=${2}
        Change Parameters In Commissioning    params_to_change=${all_parameters_to_change}[${rat}]
    END
    logger.log_info_to_console    Restore proper SCFC    log_hierarchy=${2}
    Perform Full Commissioning on gNB    scf_file=${scf_file_path}      timeout=${600}
    BuiltIn.Sleep    180s
    asir.perform_asir_commissioning    scf_path=${asir_path}
    BuiltIn.Sleep    60s
    Wait Until Keyword Succeeds    600 sec    15 sec    gnbcell.Verify All Cells Are OnAir


Lock BBMODs
    [Arguments]    ${str_bbmods_list}=null
    ${bbmods_list}=    local_resources.get_bbmods_list    str_bbmods_list=${str_bbmods_list}
    logger.log_info_to_console    BBMODS to be Locked ${bbmods_list}
    FOR    ${bbmod_id}    IN    @{bbmods_list}
         logger.log_info_to_console    Lock Baseband Module ${bbmod_id}
         local_resources.action_with_bbmod    action=Lock    bbmod_id=${bbmod_id}
    END


Unlock BBMODs
    [Arguments]    ${str_bbmods_list}=null
    ${bbmods_list}=    local_resources.get_bbmods_list    str_bbmods_list=${str_bbmods_list}
    logger.log_info_to_console    BBMODS to be Unlocked ${bbmods_list}
    FOR  ${bbmod_id}    IN    @{bbmods_list}
         logger.log_info_to_console    Unlock Baseband Module ${bbmod_id}
         local_resources.action_with_bbmod    action=Unlock    bbmod_id=${bbmod_id}
    END

Lock Unlock BBMODs
    [Arguments]    ${str_bbmods_list}=null
    Lock BBMODs    str_bbmods_list=${str_bbmods_list}
    UnLock BBMODs    str_bbmods_list=${str_bbmods_list}
    Wait Until Keyword Succeeds    600 sec    15 sec    gnbcell.Verify All Cells Are OnAir

RAT Block Unblock
   [Arguments]    ${rat}
   local_resources.action_with_rat    rat=${rat}    action=block
   Wait Until Keyword Succeeds     180 sec     10 sec       gnb_alarm.Verify Alarm is Active on gNB
   ...                                                      fault_name=RAT blocked     fault_id=4614
   local_resources.action_with_rat    rat=${rat}    action=unblock
   logger.log_info_to_console     All ${rat} cells were disabled, waiting till all cells are up.
   Wait Until Keyword Succeeds     180 sec     10 sec   gnbcell.Verify All Cells Are OnAir
   Wait Until Keyword Succeeds     180 sec     10 sec       gnb_alarm.Verify Alarm is not Active on gNB
   ...                                                      fault_name=RAT blocked     fault_id=4614

Turn test line on
    ${power_on_cmd}=     Set Variable     ecolab_cli power_on -c ${tl_config}
    ${output}=     Run     ${power_on_cmd}
    logger.log_info_to_console     ${output}


Turn test line off
    ${power_off_cmd}=     Set Variable     ecolab_cli power_off -c ${tl_config}
    ${output}=     Run     ${power_off_cmd}
    logger.log_info_to_console     ${output}

########################################################################################################################

Call To Selected Cells
    [Arguments]     ${cell_list}     ${duration}     ${alias}=UE     ${run_num}=1     ${deviation}=${None}
    ue_proxy.Restart UE Proxy On UE PC
    Call Procedure      cell_list=${cell_list}      alias=${alias}      raise_errors=${False}       run_num=${run_num}
    ...                 deviation=${deviation}      duration=${duration}
    ${recall}=         Check If Need Recall
    ${failed_cells_to_call}=         Get Failed Cells
    Run Keyword If     ${recall}==${True}     logger.log_info_to_console
    ...                                       Performing data call for previously failed cells: ${failed_cells_to_call}
    Run Keyword If     ${recall}==${True}     ue_proxy.restart_ue_proxy_on_ue_pc
    Run Keyword If     ${recall}==${True}     Call Procedure        cell_list=${failed_cells_to_call}     alias=${alias}
    ...                                       deviation=${deviation}      duration=${duration}
    ...                                       run_num=Prepare Num Run Before Recall    run_num=${run_num}
    ...                                       rerun=${True}
    html_thput_table.Generate Html Thput Table      run_num=${run_num}
    console_thput_table.Generate Console Thput Table


Call Procedure
    [Arguments]     ${cell_list}     ${deviation}     ${duration}     ${alias}=UE     ${run_num}=1
    ...             ${raise_errors}=${True}     ${rerun}=${False}
    Prepare Setup Before Call Procedure
    Prepare UE For Test     alias=${alias}        capabilities=${capabilities}
    ${auto_deviation}=    Set Variable    False
    FOR     ${cell}     IN      @{cell_list}
        logger.log_info_to_console      *** Call for cell: ${cell} ***
        Prepare Cell Before Call Procedure      cell=${cell}
        ${attach_status}=       Run Keyword And Return Status       Try To Make Attach      expected_cell=${cell}
        ...                     alias=${alias}
        ${tput_dl}      Set Variable    ${TPUT_MATRIX}[${cell}][tput_dl]
        ${tput_ul}      Set Variable    ${TPUT_MATRIX}[${cell}][tput_ul]
        ${protocol}     Set Variable    ${TPUT_MATRIX}[${cell}][protocol]
        ${parallel_streams}      Set Variable    ${TPUT_MATRIX}[${cell}][parallel_streams]
        ${linux_congestion}      Set Variable    ${TPUT_MATRIX}[${cell}][linux_congestion]
        ${deviation}      ${auto_deviation}      Get Proper Deviation    deviation=${deviation}     cell=${cell}
        ...                                      auto_dev=${auto_deviation}
        Prepare Cell Before Data Transfer       cell=${cell}     attenuation_level=atten_dl
        Run Keyword If      ${attach_status}==${True}       Run Keyword And Continue On Failure
        ...                 Perform Data Transfer On UE     direction=dl    duration=${duration}    protocol=${protocol}
        ...                                                 parallel_streams=${parallel_streams}    tput=${tput_dl}
        ...                                                 deviation=${deviation}    cell_name=${cell}
        ...                                                 raise_errors=${raise_errors}        run_num=${run_num}
        ...                                                 rerun=${rerun}    linux_congestion=${linux_congestion}
        Prepare Cell Before Data Transfer       cell=${cell}     attenuation_level=atten_ul
        Run Keyword If      ${attach_status}==${True}       Run Keyword And Continue On Failure
        ...                 Perform Data Transfer On UE     direction=ul    duration=${duration}    protocol=${protocol}
        ...                                                 parallel_streams=1      tput=${tput_ul}
        ...                                                 deviation=${deviation}       cell_name=${cell}
        ...                                                 raise_errors=${raise_errors}        run_num=${run_num}
        ...                                                 rerun=${rerun}     linux_congestion=${linux_congestion}

        Wait Until Keyword Succeeds     5x      10s        Try To Make Detach      alias=${alias}
        Prepare Setup Before Next Call      cell=${cell}
    END
    [Teardown]      Release Resources      ${alias}

Perform Data Transfer On UE
    [Documentation]     Parameters mapping for their aliases:
    ...                 duration                -t
    ...                 parallel_streams        -P - CLIENT
    ...                 size_packet             -l (for UDP) - CLIENT; -M (for TCP) - CLIENT
    ...                 buffer_(client/server)  -w
    ...                 interval                -i - CLIENT&SERVER
    ...                 linux_congestion        -Z - CLIENT
    [Arguments]     ${direction}    ${duration}    ${tput}    ${protocol}    ${deviation}           ${cell_name}
    ...             ${parallel_streams}     ${linux_congestion}
    ...             ${size_packet}=1320B   ${buffer_client}=${None}     ${run_num}=1
    ...             ${buffer_server}=${None}    ${interval}=1          ${alias}=UE
    ...             ${raise_errors}=${True}     ${rerun}=${False}

    Perform Data Transfer In Specific Direction     direction=${direction}      duration=${duration}    tput=${tput}
    ...                                             protocol=${protocol}        deviation=${deviation}
    ...                                             cell_name=${cell_name}      run_num=${run_num}
    ...                                             buffer_client=${buffer_client}      buffer_server=${buffer_server}
    ...                                             parallel_streams=${parallel_streams}    size_packet=${size_packet}
    ...                                             interval=${interval}        linux_congestion=${linux_congestion}
    ...                                             alias=${alias}      raise_errors=${raise_errors}    rerun=${rerun}

Prepare Setup Before Call Procedure
    Prepare Bts Before Call
    Adjust Attenuation      attenuation_level=max

Prepare Cell Before Call Procedure
    [Arguments]     ${cell}
    @{cell_to_call}       create list
    Append To List      ${cell_to_call}    ${cell}
    Perform Parameter Recommisioning        cell_list=${cell_to_call}       param_level=min
    Adjust Attenuation      cell_ids=${cell_to_call}    attenuation_level=avg

Prepare Setup Before Next Call
    [Arguments]     ${cell}
    @{cell_to_call}       create list
    Append To List      ${cell_to_call}    ${cell}
    Perform Parameter Recommisioning        cell_list=${cell_to_call}       param_level=max
    Adjust Attenuation      cell_ids=${cell_to_call}        attenuation_level=max

Prepare Cell Before Data Transfer
    [Arguments]     ${cell}     ${attenuation_level}
    @{cell_to_call}       create list
    Append To List      ${cell_to_call}    ${cell}
    Adjust Attenuation      cell_ids=${cell_to_call}        attenuation_level=${attenuation_level}
