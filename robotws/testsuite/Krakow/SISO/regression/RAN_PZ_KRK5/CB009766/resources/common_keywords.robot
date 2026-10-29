*** Settings ***
Documentation
...   Keywords for regression testing of feature CB009766
...   author: Mateusz Bugaj, Daniel Kulaga, Pawel Grabania
...   contact: mateusz.bugaj@nokia.com, daniel.kulaga@nokia.com, pawel.grabania@nokia.com

Library      OperatingSystem
Library      SSHLibrary
Library      taf.sbts.oam.coam.admin                                                   WITH NAME  admin
Library      taf.rfrl.bts.devices.du.commissioning.GnbCommissioning                    WITH NAME  comm
Library      taf.rfrl.utilities.logger.custom_logger                                   WITH NAME  logger
Library      taf.rfrl.procedures.resources.python.common_allowed_alarms                WITH NAME  alarm
Library      taf.rfrl.bts.devices.du.sw_update.GnbSwUpdate                             WITH NAME  gnb_sw_update
Library      taf.rfrl.bts.commissioning                                                WITH NAME  bts_comm
Library      taf.rfrl.bts.devices.du.du_operations.GnbDuOperations                     WITH NAME  gnb_du
Library     ./resources.py                                                             WITH NAME  local_resources
Library     ./asir_hub_actions.py                                                      WITH NAME  asir_hub_actions
Library     ./ru_actions.py                                                            WITH NAME  ru_actions
Library     ./prrh_actions.py                                                          WITH NAME  prrh_actions
Library     ./bbmod_actions.py                                                         WITH NAME  bbmod_actions
Library      ./call_procedure/ue_proxy.py                                              WITH NAME  ue_proxy
Library      ./call_procedure/bts_operations.py
Library      ./call_procedure/ue_operations.py
Library      ./call_procedure/common_operations.py
Library      ./call_procedure/console_thput_table.py
Library      ./call_procedure/attenuator_operations.py
Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot

*** Variables ***
${tl_config}     /home/ute/auto/testline_configuration/7_7_UTE5GCLOUDT1SK100/__init__.py

*** Keywords ***
Verify snapshot
    Prepare logs path
    ${repo_path}=    taf.rfrl.utilities.test_config.Get Repository Path
    ${asir_csv_path}=    Set Variable    testsuite/Krakow/SISO/regression/RAN_PZ_KRK5/CB009766/resources/ASIR.csv
    General_SiSo_HWPTA_Collect_RFSW_Logs_From_RU_Into_BTS_Snapshot
	...    additional_documentation_path=${repo_path}/${asir_csv_path}
    local_resources.check_snapshot     directory=${logs_path}/Full/Full_snapshot.zip

Reset Hubs Via AsirWebEm
    asir_hub_actions.action_with_asir_hub        action=Reset     gnb_oam_ip=${gnb_oam_ip}     mrbts_id=${mrbts_id}
    ...    nrbts_id=${nrbts_id}
    Wait Until Keyword Succeeds    600 sec    15 sec    gnbcell.Verify All Cells Are Onair

Reset pRRH Via AsirWebEm
    prrh_actions.Action With pRRHs    action=Reset
    Wait Until Keyword Succeeds    600 sec    15 sec    gnbcell.Verify All Cells Are Onair

Lock Unlock BBMOD Via WebEm
    bbmod_actions.Action With BBMOD     action=Lock
    BuiltIn.Sleep       5s
    bbmod_actions.Action With BBMOD     action=Unlock
    Wait Until Keyword Succeeds    600 sec    15 sec    gnbcell.Verify All Cells Are Onair

Block Unblock pRRH Via AsirWebEm
    prrh_actions.Action With pRRHs    action=Block
    BuiltIn.Sleep       5s
    prrh_actions.Action With pRRHs    action=Unblock
    Wait Until Keyword Succeeds    600 sec    15 sec    gnbcell.Verify All Cells Are Onair

Lock Unlock Hubs Via WebEm
    ru_actions.Actions With Ru       action=Lock
    BuiltIn.Sleep       5s
    ru_actions.Actions With Ru       action=Unlock
    Wait Until Keyword Succeeds    600 sec    15 sec    gnbcell.Verify All Cells Are Onair

Reset Hubs Via WebEm
    ru_actions.Actions With Ru       action=Reset
    Wait Until Keyword Succeeds    600 sec    15 sec    gnbcell.Verify All Cells Are Onair

Perform_recommissoning
    [Arguments]     ${all_parameters_to_change}
    ${path_to_scf}    Download gNB Configuration File
    logger.log_info_to_console    Saving actual SCFC    log_hierarchy=${2}
    FOR    ${rat}    IN    @{all_parameters_to_change}
        logger.log_info_to_console    Changing parameters in BTS for specific RAT: ${rat}    log_hierarchy=${2}
        Change Parameters In Commissioning    params_to_change=${all_parameters_to_change}[${rat}]
    END
    logger.log_info_to_console    Restore proper SCFC    log_hierarchy=${2}
    Perform Full Commissioning on gNB    scf_file=${path_to_scf}     timeout=900
    BuiltIn.Sleep       200s
    Wait Until Keyword Succeeds     900 sec     15 sec    gnbcell.Verify All Cells Are Onair

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

Change BTS parameter
    [Arguments]    ${dist_name}    ${param_name}    ${correct_value}    ${incorrect_value}
    ...            ${fault_type}
    logger.log_info_to_console    Changing ${param_name} in object ${dist_name} to correct value: ${correct_value}.
    ...                           log_hierarchy=${4}
    Perform Configuration Parameter Recommissioning On gNB    dist_name=${dist_name}    param_name=${param_name}
    ...                                                       operation=update    param_value=${correct_value}
    ...                                                       skip_parameter_relation_errors=True
    ...                                                       should_activate=True    timeout=300
    Wait Until Keyword Succeeds    900 sec    15 sec    gnbcell.Verify All Cells Are Onair
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
            ...    dist_name=${dist_name}       param_name=${param_name}        operation=update
            ...    param_value=${incorrect_value}       skip_parameter_relation_errors=True
            ...    should_activate=True     timeout=120
    Should Contain    ${msg}    ${fault_type}
    Verify gNB Configuration Parameters Have Expected Values
        ...    param_dict=${param_to_verify}
    Wait Until Keyword Succeeds    900 sec    30 sec    gnbcell.Verify All Cells Are Onair

Add custom alarms
    [Arguments]    ${alarms_for_test}
    Set Test Variable    ${additional_allowed_alarms}    ${alarms_for_test}
    Set Test Variable    ${CUSTOM_ALLOWED_ALARMS}    ${alarms_for_test}

Actions before test
    [Arguments]    ${correct_config}       ${alarms_for_test}=${None}
    local_resources.Verify Is Correct Config        correct_config=${correct_config}
    Run keyword if    "${alarms_for_test}!=${None}"    Add custom alarms    ${alarms_for_test}
    Common Preconditions With Watching Alarms

Actions after test
    Remove custom allowed alarms if defined
    [Teardown]    Common Postconditions With Watching Alarms

Actions before test With Checking Configuration and Changing It If Needed
    [Arguments]    ${config_name}    ${prefix_tag}=${None}       ${alarms_for_test}=${None}
    local_resources.Verify Is Correct Config And Change It If Needed
    ...   correct_config=${bts_names_for_features}[${config_name}]    prefix_tag=${prefix_tag}
    Wait Until Keyword Succeeds     900 sec     30 sec      gnbcell.Verify All Cells Are Onair
    Run keyword if    "${alarms_for_test}!=${None}"    Add custom alarms    ${alarms_for_test}
    Common Preconditions With Watching Alarms

Call To Selected Cells
    [Arguments]     ${cell_list}     ${duration}    ${alias}=UE     ${run_num}=1
    ...             ${additional_action}=${None}      ${additional_action_params}=${None}     ${deviation}=${None}
    ue_proxy.Restart UE Proxy On UE PC
    Call Procedure      cell_list=${cell_list}      alias=${alias}      raise_errors=${False}       run_num=${run_num}
    ...                 deviation=${deviation}      duration=${duration}
    ...                 additional_action=${additional_action}      additional_action_params=${additional_action_params}
    ${recall}=         Check If Need Recall
    ${failed_cells}=         Get Failed Cells List
    Run Keyword If     ${recall}==${True}     logger.log_info_to_console
    ...                                       Performing data call for previously failed cells: ${failed_cells}
    Run Keyword If     ${recall}==${True}     ue_proxy.restart_ue_proxy_on_ue_pc
    Run Keyword If     ${recall}==${True}     Call Procedure        cell_list=${failed_cells}     alias=${alias}
    ...                                       deviation=${deviation}      duration=${duration}
    ...                                       run_num=Prepare Num Run Before Recall    run_num=${run_num}    rerun=${True}
    ...                                       additional_action=${additional_action}
    ...                                       additional_action_params=${additional_action_params}
    console_thput_table.Generate Console Thput Table

Call Procedure
    [Arguments]     ${cell_list}     ${deviation}     ${duration}    ${alias}=UE     ${run_num}=1
    ...             ${raise_errors}=${True}     ${rerun}=${False}       ${additional_action}=${None}
    ...             ${additional_action_params}=${None}
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
        ${action}=       Get Additional Action During Call    action_name=${additional_action}
        ${deviation}      ${auto_deviation}      Get Proper Deviation    deviation=${deviation}     cell=${cell}
        ...                                      auto_dev=${auto_deviation}
        Prepare Cell Before Data Transfer       cell=${cell}     attenuation_level=atten_dl
        Run Keyword If      ${attach_status}==${True}       Run Keyword And Continue On Failure
        ...                 Perform Data Transfer On UE     direction=dl    duration=${duration}    protocol=${protocol}
        ...                                                 parallel_streams=${parallel_streams}    tput=${tput_dl}
        ...                                                 deviation=${deviation}    cell_name=${cell}
        ...                                                 raise_errors=${raise_errors}        run_num=${run_num}
        ...                                                 rerun=${rerun}     linux_congestion=reno
        ...                                                 additional_action=${action}
        ...                                                 additional_action_params=${additional_action_params}
        Prepare Cell Before Data Transfer       cell=${cell}     attenuation_level=atten_ul
        Run Keyword If      ${attach_status}==${True}       Run Keyword And Continue On Failure
        ...                 Perform Data Transfer On UE     direction=ul    duration=${duration}    protocol=${protocol}
        ...                                                 parallel_streams=${parallel_streams}    tput=${tput_ul}
        ...                                                 deviation=${deviation}    cell_name=${cell}
        ...                                                 raise_errors=${raise_errors}    run_num=${run_num}
        ...                                                 rerun=${rerun}    linux_congestion=${linux_congestion}
        ...                                                 additional_action=${action}
        ...                                                 additional_action_params=${additional_action_params}

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
    ...             ${parallel_streams}     ${linux_congestion}     ${size_packet}=1320B   ${buffer_client}=${None}
    ...             ${buffer_server}=${None}    ${run_num}=1        ${interval}=1          ${alias}=UE
    ...             ${raise_errors}=${True}     ${rerun}=${False}       ${additional_action}=${None}
    ...             ${additional_action_params}=${None}

    Perform Data Transfer In Specific Direction     direction=${direction}      duration=${duration}    tput=${tput}
    ...                                             protocol=${protocol}        deviation=${deviation}
    ...                                             cell_name=${cell_name}      run_num=${run_num}
    ...                                             buffer_client=${buffer_client}      buffer_server=${buffer_server}
    ...                                             parallel_streams=${parallel_streams}    size_packet=${size_packet}
    ...                                             interval=${interval}        linux_congestion=${linux_congestion}
    ...                                             alias=${alias}      raise_errors=${raise_errors}    rerun=${rerun}
    ...                                             additional_action=${additional_action}
    ...                                             additional_action_params=${additional_action_params}

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

Remove Dirs
    [Arguments]    ${directory_paths}
    FOR    ${dir}    IN    @{directory_paths}
        ${status}=    Run Keyword And Return Status    OperatingSystem.Directory Should Exist    ${dir}
        Run Keyword If    ${status}    Remove Directory    ${dir}    recursive=True
    END

Load configuration
    [Arguments]     ${build_directory}=/home/ute/temp_builds
    logger.log_info_to_console    Load configuration after config reset started
    BuiltIn.Sleep    300s
    gnb_du.Wait Unitl Connection Via Admin Is Possible      timeout=${600}
    bts_comm.perform_commissioning_on_gnb_to_onair_state    prefix_tag=TRIMODE      awaiting_time=${1200}
    ...          readiness_timeout=${1200}     build_directory=${build_directory}     asir_hub=True
    ...          update_timeout=${1200}       commissioning_timeout=${1200}   delay_for_checking_on_air=${600}
    local_resources.upload_swconfig_to_bts
    BuiltIn.Sleep    10s
    Reset gNB
    Wait Until Keyword Succeeds     900 sec     30 sec   gnbcell.Verify All Cells Are Onair
    logger.log_info_to_console    Load configuration stopped

Get source sw version for upgrade
    [Arguments]    ${n}    ${build_version}=${None}
    ${source_build}=        local_resources.Get SW Version From WFT Upgrade Path    n=${n}
    ...                                                                             build_version=${build_version}
    logger.log_info_to_console    Source SW version for upgrade path ${n}: ${source_build}
    [Return]    ${source_build}

Wait for sw update possible
    logger.log_info_to_console    Wait SW update is possible    log_hierarchy=4
    gnb_sw_update.wait_sw_update_possible    readiness_timeout=${900}

Delete Builds from Tmp
    local_resources.delete files from dir    dir_path=/tmp/     prefix=SBTS
