*** Settings ***
Documentation
...   Keywords for regression testing of feature CB008973
...   author: Mateusz Bugaj, Daniel Kulaga, Pawel Grabania
...   contact: mateusz.bugaj@nokia.com, daniel.kulaga@nokia.com, pawel.grabania@nokia.com

Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource     taf/rfrl/bts/robot/gnb.robot
Resource     taf/rfrl/ue/robot/REAL_UE.robot

Library      String
Library      taf.ul.sc.gnb.oam.rest.CommonOAM    oam_ip=${tl.gnbs[0].cu.oam_http_connection_details.addr}
...                                              mrbts_id=76209    nrbts_id=76209   WITH NAME    RestAPI

Library      OperatingSystem
Library      taf.config.scf                                                             WITH NAME    scfa
Library      taf.sbts.oam.coam.admin                                                    WITH NAME    admin
Library      taf.selenium.sbts                                                          WITH NAME    selenium
Library      taf.rfrl.utilities.logger.custom_logger                                    WITH NAME    logger
Library      taf.rfrl.bts.devices.du.commissioning.GnbCommissioning                     WITH NAME    comm
Library      taf.rfrl.bts.devices.asir.asir_operations.GnbAsirHubOperations                WITH NAME    asir
Library      taf.rfrl.procedures.resources.python.config_operations.ConfigOperations    WITH NAME    config_operations
Library      taf.rfrl.procedures.resources.python.common_allowed_alarms                 WITH NAME    alarm
Library      ./resources.py                                                             WITH NAME    local_resources
Library      ./ue_proxy.py                                                              WITH NAME    ue_proxy
Variables    ./common_variables.py

*** Variables ***
${tl_config}     /home/ute/auto/testline_configuration/`uname -n | sed -r 's/(.*)-[0-9]$/\1/' | tr "-" "_"`/__init__.py

*** Keywords ***
Verify snapshot
    Prepare logs path
    ${repo_path}=    taf.rfrl.utilities.test_config.Get Repository Path
    ${asir_csv_path}=    Set Variable    testsuite/Krakow/SISO/regression/RAN_PZ_KRK5/CB008973/resources/ASIR.csv
    General_SiSo_HWPTA_Collect_RFSW_Logs_From_RU_Into_BTS_Snapshot
	...    additional_documentation_path=${repo_path}/${asir_csv_path}
    local_resources.check_snapshot     directory=${logs_path}/Full/Full_snapshot.zip


Reset Ants
    [Arguments]         ${str_ants_list}=null
    ${all_ants_mod_id_list}   asir.get_all_antenna_ids
    logger.log_info_to_console  All Available Ant Mod ID: ${all_ants_mod_id_list}
    ${ants_list}  Set Variable If  '${str_ants_list}' == 'null'  ${all_ants_mod_id_list}  ${ants}
    logger.log_info_to_console  Reset ANTs in list @{ants_list}
    FOR  ${ant_id}  IN  @{ants_list}
        logger.log_info_to_console      Reset ANT ${ant_id}
        asir.reset_antenna      ant_id=${ant_id}
        Wait Until Keyword Succeeds     900 sec     30 sec   Verify Setup of All Cells
    END

Block Ants
    [Arguments]         ${str_ants_list}=null
    ${all_ants_mod_id_list}   asir.get_all_antenna_ids
    logger.log_info_to_console  All Available Ant Mod ID: ${all_ants_mod_id_list}
    ${ants_list}  Set Variable If  '${str_ants_list}' == 'null'  ${all_ants_mod_id_list}  ${ants}
    logger.log_info_to_console  Block ANTs in list @{ants_list}
    FOR  ${ant_id}  IN  @{ants_list}
        logger.log_info_to_console  Block ANT ${ant_id}
        asir.block_antenna      ant_id=${ant_id}
    END
    ${cell_ids}=        local_resources.prepare_cell_to_check       cell_ids=${CellIDs_Asir}
    FOR    ${Cell}     IN    @{cell_ids}
        Wait Until Keyword Succeeds     900 sec     30 sec   Verify Cell Statuses    cell_id=${Cell}
        ...                             operational_state=disabled     administrative_state=unlocked
        ...                             availability_status=failed     procedural_status=not initialized
    END

Unblock Ants
    [Arguments]         ${str_ants_list}=null
    ${all_ants_mod_id_list}   asir.get_all_antenna_ids
    logger.log_info_to_console  All Available Ant Mod ID: ${all_ants_mod_id_list}
    ${ants_list}  Set Variable If  '${str_ants_list}' == 'null'  ${all_ants_mod_id_list}  ${ants}
    logger.log_info_to_console  Block ANTs in list @{ants_list}
    FOR  ${ant_id}  IN  @{ants_list}
        logger.log_info_to_console  Unblock ANT ${ant_id}
        asir.unblock_antenna      ant_id=${ant_id}
    END

Lock BBMODs
    [Arguments]         ${str_bbmods_list}=null
    ${bbmods_list}   string.split string  ${str_bbmods_list}
    ${connection}    admin.Connect To
    ${bts_info} =    admin.Get BTS info       connection=${connection}
    ${all_avail_bbmods_list}  Create List
    FOR  ${bbmod_info}  IN  @{bts_info['basebandModules']}
         ${id_keys}=  Get Dictionary Keys  ${bbmod_info['id']}
         Continue For Loop If  'configuration' not in @{id_keys}
         ${prefix}  ${bbmod_id}   string.Split String From Right  ${bbmod_info['id']['configuration']}  separator=-
         ...                      max_split=${1}
         Append To List  ${all_avail_bbmods_list}  ${bbmod_id}
    END
    logger.log_info_to_console  All BBMODS Can be Locked ${all_avail_bbmods_list}
    ${bbmods_list}  Set Variable If  '${str_bbmods_list}' == 'null'  ${all_avail_bbmods_list}  ${bbmods_list}
    logger.log_info_to_console  BBMODS to be Locked ${bbmods_list}

    FOR  ${bbmod_id}  IN  @{bbmods_list}
         logger.log_info_to_console  Lock Baseband Module ${bbmod_id}
         RestAPI.Lock Baseband Module  ${bbmod_id}
    END

Unlock BBMODs
    [Arguments]         ${str_bbmods_list}=null
    ${bbmods_list}   string.split string  ${str_bbmods_list}
    ${connection}    admin.Connect To
    ${bts_info} =    admin.Get BTS info       connection=${connection}
    ${all_avail_bbmods_list}  Create List
    FOR  ${bbmod_info}  IN  @{bts_info['basebandModules']}
         ${id_keys}=  Get Dictionary Keys  ${bbmod_info['id']}
         Continue For Loop If  'configuration' not in @{id_keys}
         ${prefix}  ${bbmod_id} =  string.Split String From Right  ${bbmod_info['id']['configuration']}  separator=-
         ...                       max_split=${1}
         Append To List  ${all_avail_bbmods_list}  ${bbmod_id}
    END
    logger.log_info_to_console  All BBMODS Can be Unlocked ${all_avail_bbmods_list}
    ${bbmods_list}  Set Variable If  '${str_bbmods_list}' == 'null'  ${all_avail_bbmods_list}  ${bbmods_list}
    logger.log_info_to_console  BBMODS to be Unlocked ${bbmods_list}
    FOR  ${bbmod_id}  IN  @{bbmods_list}
         logger.log_info_to_console  Unlock Baseband Module ${bbmod_id}
         RestAPI.Unlock Baseband Module  ${bbmod_id}
    END

Get All BBMOD Status
    ${connection}    admin.Connect To
    ${bts_info} =    admin.Get BTS info       connection=${connection}
    ${raw_bbmod_list}  Set Variable  ${bts_info['basebandModules']}
    ${bbmods_list}  Create List
    FOR  ${raw_bbmod_info}  IN  @{raw_bbmod_list}
       Keep In Dictionary  ${raw_bbmod_info}  id  status
       logger.log_info_to_console  ${raw_bbmod_info}
       Append To List  ${bbmods_list}  ${raw_bbmod_info}
    END
    logger.log_info_to_console  All BBMOD Status: ${bbmods_list}
    [Return]  ${bbmods_list}

Check All BBMODs Status
    [Arguments]   &{dict_expected_status}
    ${list_bbmod_status}  Get All BBMOD Status
    logger.log_info_to_console  ${list_bbmod_status}
    ${check_result}   Get Check All BBMODs Status  ${list_bbmod_status}  ${dict_expected_status}
    logger.log_info_to_console  Check Result: ${check_result}
    should Be True  ${check_result['check_result']}

Lock HUBS
    [Arguments]         ${str_hubs_list}=null
    ${hubs_list}   string.split string  ${str_hubs_list}
    Run Keyword If  '${str_hubs_list}' == 'null'  logger.log_info_to_console  Lock All HUBs
    ...  ELSE  logger.log_info_to_console  Lock HUBs in list @{hubs_list}
    ${connection}    admin.Connect To
    ${bts_info} =    admin.Get BTS info       connection=${connection}
    FOR  ${hub_info}  IN  @{bts_info['radioModules']['asirmod']}
        ${prefix}  ${hub_id} =  string.Split String From Right  ${hub_info['id']['configuration']}  separator=-
        ...                     max_split=${1}
        Run Keyword If  '${hub_id}' in @{hubs_list} or '${str_hubs_list}' == 'null'  run keywords
        ...  logger.log_info_to_console  Lock HUB ${hub_id}
        ...  AND  RestAPI.Lock hub  ${hub_id}
    END

Unlock HUBS
    [Arguments]         ${str_hubs_list}=null
    ${hubs_list}   string.split string  ${str_hubs_list}
    Run Keyword If  '${str_hubs_list}' == 'null'  logger.log_info_to_console  Unlock All HUBs
    ...  ELSE  logger.log_info_to_console  Unlock HUBs in list @{hubs_list}
    ${connection}    admin.Connect To
    ${bts_info} =    admin.Get BTS info       connection=${connection}
    FOR  ${hub_info}  IN  @{bts_info['radioModules']['asirmod']}
        ${prefix}  ${hub_id} =  string.Split String From Right  ${hub_info['id']['configuration']}  separator=-
        ...                     max_split=${1}
        Run Keyword If  '${hub_id}' in @{hubs_list} or '${str_hubs_list}' == 'null'  run keywords
        ...  logger.log_info_to_console  Unlock HUB ${hub_id}
        ...  AND  RestAPI.Unlock hub  ${hub_id}
    END

Check Hub Status Via Gnb
    [Arguments]  ${hub_id}  &{dict_expected_status}
    ${list_hub_status}  Get All HUB Status Via Gnb
    logger.log_info_to_console  ${list_hub_status}
    ${check_result}   local_resources.Get Check Hub Status Via Gnb  ${list_hub_status}  ${hub_id}  ${dict_expected_status}
    logger.log_info_to_console  Check Result: ${check_result}
    should Be True  ${check_result['check_result']}

Get All HUB Status Via Gnb
    ${connection}    admin.Connect To
    ${bts_info} =    admin.Get BTS info       connection=${connection}
    ${raw_hub_list}  Set Variable  ${bts_info['radioModules']['asirmod']}
    ${hubs_list}  Create List
    FOR  ${raw_hub_info}  IN  @{raw_hub_list}
       Keep In Dictionary  ${raw_hub_info}  id  status
       logger.log_info_to_console  ${raw_hub_info}
       Append To List  ${hubs_list}  ${raw_hub_info}
    END
    logger.log_info_to_console  All HUB Status: ${hubs_list}
    [Return]  ${hubs_list}
    [Teardown]    admin.teardown_admin

Reset BBMODs
    [Arguments]    ${str_bbmods_list}=null
    ${bbmods_list}    string.split string    ${str_bbmods_list}
    Run Keyword If    '${str_bbmods_list}' == 'null'    logger.log_info_to_console    Reset All BBMODS
    ...    ELSE    logger.log_info_to_console    Reset BBMODs in list @{bbmods_list}
    ${connection}=       admin.connect_to
    ${fbb_info}=    admin.Get fbb info      connection=${connection}
    FOR    ${fbb}    IN    @{fbb_info}
        ${prefix}    ${fbb_full_id} =    string.Split String From Right    ${fbb['id']['internal']}    separator=/
        ...                              max_split=${1}
        ${prefix}    ${fbb_id} =    string.Split String From Right    ${fbb_full_id}    separator=-    max_split=${1}
        Run Keyword If    '${fbb_id}' in @{bbmods_list} or '${str_bbmods_list}' == 'null'    run keywords
        ...    logger.log_info_to_console    Reset BBMOD ${fbb_full_id}
        ...    AND    admin.Reset Unit    ${fbb['id']['internal']}    reset_type=Warm    timeout=${300}
        ...                                connection=${connection}
    END

NR RAT Reset
    Selenium Login And Disable Screen Lock
    selenium.reset_nr      cancel=${True}
    BuiltIn.Sleep    10s
    selenium.reset_nr
    FOR    ${Cell}     IN    @{CELL_MAP_FOR_NR_RAT_RESET}
        Wait Until Keyword Succeeds     900 sec     30 sec   Verify Cell Statuses    cell_id=${Cell}
        ...                             operational_state=disabled     administrative_state=unlocked
        ...                             availability_status=failed     procedural_status=not initialized
    END
    BuiltIn.Sleep    120s
    Wait Until Keyword Succeeds     900 sec     30 sec   Verify Setup of All Cells
    [Teardown]   Selenium Logout And Close Browser

Selenium Login And Disable Screen Lock
    [Arguments]    ${timeout}=${60}
    ...            ${gnb_index}=${0}
    ...            ${url}=https://${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.addr}
    ...            ${username}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...            ${password}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    ...            ${version}=SBTS22R3
    ...            ${browser}=Firefox
    selenium.enable_virtual_display
    selenium.login    url=${url}
    ...                    username=${username}
    ...                    password=${password}
    ...                    timeout=${timeout}
    ...                    version=${version}
    ...                    browser=${browser}
    selenium.disable_message_box
    selenium.disable_screen_lock

Selenium Logout And Close Browser
    Run Keyword And Ignore Error    selenium.logout
    Run Keyword And Ignore Error    selenium.disable_virtual_display
    Run Keyword And Ignore Error    selenium.close_browser

Start Transfer On Real UE In Specific Direction
    [Arguments]     ${direction}    ${duration}    ${tput}    ${protocol}    ${deviation}       ${cell}     ${index_run}
    ...             ${parallel_streams}=1    ${size_packet}=1350   ${buffer_client}=4M
    ...             ${buffer_server}=4M    ${interval}=1    ${qci}=${None}    ${linux_congestion}=reno
    ...             ${alias}=UE
    ${direction_upper}    Convert To Upper Case  ${direction}
    Start Data Transfer on Real UE   dt_name=DT_${cell}_${index_run}_${direction_upper}      ue_alias=${alias}     direction=${direction}
    ...     protocol=${protocol}    duration=${duration}   tput=${tput}     parallel_streams=${parallel_streams}
    ...     size_packet=${size_packet}      buffer_client=${buffer_client}  buffer_server=${buffer_server}
    ...     interval=${interval}      qci=${qci}    linux_congestion=${linux_congestion}

    Await Data Transfer Finish       dt_name=DT_${cell}_${index_run}_${direction_upper}
    Verify Average Throughput With Deviation   dt_name=DT_${cell}_${index_run}_${direction_upper}   tput=${tput}   deviation=${deviation}

Reset ue proxy
    ue_proxy.stop_ue_proxy_on_ue_pc
    ue_proxy.start_ue_proxy_on_ue_pc

Call to selected cells
    [Arguments]     ${CellIDs}      ${duration}     ${deviation}    ${tc_name}      ${prepareUE}=True     ${index_run}=1
    @{parameters}               local_resources.generate_list_of_bts_params_for_attach       cell_ids=${CellIDs}
    ...                         attenuator_matrix=${ATTENUATOR_MATRIX}
    Log    ${tc_name}
    Perform Delta Commissioning On gNB      delta=${parameters}

    Run Keyword If      '${prepareUE}'=='True'      Prepare Ue for L3 Call
    ...                                                                     capabilities=${capabilities}
    ...                                                                     reboot_ue=False
    ...                                                                     timeout_reboot_ue=100

    FOR     ${Cell}      IN      @{CellIDs}
        logger.log_info_to_console    ***Call for Cell ${Cell}***    log_hierarchy=${2}
        @{cells_list}    create list
        Append To List    ${cells_list}    ${Cell}
        local_resources.adjust_attenuation    cell_ids=${cells_list}        attenuation_level=avg
        ${dist_name}            Set Variable    ${ATTENUATOR_MATRIX}[${Cell}][dist_name]
        ${parameter}            Set Variable    ${ATTENUATOR_MATRIX}[${Cell}][parameter]
        ${qrxlevmin_max}        Set Variable    ${ATTENUATOR_MATRIX}[${Cell}][qrxlevmin_max]
        Perform Configuration Parameter Recommissioning On gNB        param_value=${qrxlevmin_max}
		...                                                           param_name=${parameter}       dist_name=${dist_name}
        ue.Attach Ue    UE

        local_resources.adjust_attenuation    cell_ids=${cells_list}        attenuation_level=min
        ${tput_dl}      Set Variable    ${TPUT_MATRIX}[${Cell}][tput_dl]
        ${tput_ul}      Set Variable    ${TPUT_MATRIX}[${Cell}][tput_ul]
        ${protocol}     Set Variable    ${TPUT_MATRIX}[${Cell}][protocol]
        Run Keyword And Continue On Failure        Start Transfer On Real UE In Specific Direction   direction=dl
        ...                                        duration=${duration}    tput=${tput_dl}      index_run=${index_run}
        ...                                        protocol=${protocol}     deviation=${deviation}      cell=${Cell}
        Run Keyword And Continue On Failure        Start Transfer On Real UE In Specific Direction   direction=ul
        ...                                        duration=${duration}     tput=${tput_ul}     index_run=${index_run}
        ...                                        protocol=${protocol}     deviation=${deviation}      cell=${Cell}

        sleep   5s
        ue.Detach Ue    UE

        local_resources.adjust_attenuation    cell_ids=${cells_list}        attenuation_level=max

        ${qrxlevmin_min}        Set Variable    ${ATTENUATOR_MATRIX}[${Cell}][qrxlevmin_min]
        Perform Configuration Parameter Recommissioning On gNB        param_value=${qrxlevmin_min}
		...                                                           param_name=${parameter}       dist_name=${dist_name}

#        Run Keyword And Continue On Failure         local_resources.generate_tput_graph    tput_dl=${tput_dl}
#        ...                                         tput_ul=${tput_ul}          dt_name=DT_${Cell}_
#        ...                                         file_name=${tc_name}_${Cell}_run${index_run}
    END
    ue.stop_using_ue    UE

Check BTS NotCommissioned State
    logger.log_info_to_console      [SISO] Check BTS NotCommissioned State
    ${bts_status}=                  Check BTS Procedural State
    logger.log_info_to_console      [SISO] Actual BTS Status: ${bts_status}
    Should Be Equal As Strings   ${bts_status}    NotCommissioned

Perform Full Commisioning After Configuration Reset
    [Arguments]     ${scf_file_path}    ${bts_host}=${tl.gnbs[${0}].cu.oam_http_connection_details.addr}
    ${connection}=                                  connections.get_default_admin_connection_alias
    ${bts_id}=                                      hw_info.get_mrbts_id
    config_operations.perform_commissioning_in_separate_process
    ...                                             connection_host=${bts_host}
    ...                                             bts_id=${bts_id}
    ...                                             scf_file_path=${scf_file_path}
    ${is_in_desired_state}=                         connections.wait_for_desired_site_state
    ...                                             url=https://${bts_host}
    ...                                             timeout=150
    ...                                             should_be_reachable=${False}
    should be true                                  ${is_in_desired_state}
    ...                                             msg=Commissioning did not cause expected site reset

SiSo_Commissioning_BTS_Template_Commissioning
    [Arguments]     ${scf_file_path}=/tmp/initial_configuration.xml
    ...             ${asir_file_path}=/tmp      ${asir_file_name}=initial_configuration_asir.xml
    Save current configuration                      file_name=initial_configuration.xml
    ${asir_path}=       asir.get_current_scf_file      local_dir_path=${asir_file_path}      file_name=${asir_file_name}
    comm.Reset Configuration
    Sleep       60s
    wait until keyword succeeds                     900sec   15sec   Verify gNB is Not Commissioned
    Sleep       180s
    Perform Full Commisioning After Configuration Reset     scf_file_path=${scf_file_path}
    Sleep       180s
    asir.perform_asir_commissioning                 scf_path=${asir_path}
    Wait Until Keyword Succeeds                     900 sec     30 sec   Verify gNB is onAir
    Wait Until Keyword Succeeds                     900 sec     30 sec   Verify Setup of All Cells
    Change Parameters In Commissioning              params_to_change=${PARAM_TO_CHANGE_WITH_COMM}
    Wait Until Keyword Succeeds                     600 sec     15 sec    Verify Setup Of All Cells

Check BTS Procedural State
    ${connection}     admin.Connect To

    ${bts_status}=    admin.get_bts_statuses
    ...               connection=${connection}
    logger.log_info_to_console      \n BTS procedural state is now: ${bts_status["proceduralState"]}
    [Return]          ${bts_status["proceduralState"]}

Check BTS State
    [Arguments]     ${expected_state}=NotCommissioned
    logger.log_info_to_console      [SISO] Check BTS State
    ${bts_status}=                  Check BTS Procedural State
    logger.log_info_to_console      [SISO] Actual BTS Status: ${bts_status}
    Should Be Equal As Strings   ${bts_status}    ${expected_state}

Perform_recommissoning
    [Arguments]     ${all_parameters_to_change}
    ${path_to_scf}    Download gNB Configuration File
    logger.log_info_to_console    Saving actual SCFC    log_hierarchy=${2}
    FOR    ${rat}    IN    @{all_parameters_to_change}
        logger.log_info_to_console    Changing parameters in BTS for specific RAT: ${rat}    log_hierarchy=${2}
        Change Parameters In Commissioning    params_to_change=${all_parameters_to_change}[${rat}]
    END
    logger.log_info_to_console    Restore proper SCFC    log_hierarchy=${2}
    Perform Full Commissioning on gNB    scf_file=${path_to_scf}
    Sleep       120s
    Wait Until Keyword Succeeds     900 sec     15 sec    Verify Setup Of All Cells

Change Parameters In Commissioning
    [Arguments]     ${params_to_change}
    FOR    ${param_to_change}    IN    @{params_to_change}
        ${param_name}           Set Variable    ${param_to_change}[param_name]
        ${dist_name}            Set Variable    ${param_to_change}[dist_name]
        ${correct_value}        Set Variable    ${param_to_change}[correct_value]
        ${incorrect_value}      Set Variable    ${param_to_change}[incorrect_value]
        ${mod_type}             Set Variable    ${param_to_change}[mod_type]
        ${fault_type}           Set Variable    ${param_to_change}[fault_type]
        ${dist_name}    local_resources.adjust_dist_name    dist_name=${dist_name}
        logger.log_info_to_console    msg=Modyfication type: ${mod_type}    log_hierarchy=${3}
        Change BTS parameter
            ...   dist_name=${dist_name}
            ...   param_name=${param_name}
            ...   correct_value=${correct_value}
            ...   incorrect_value=${incorrect_value}
            ...   fault_type=${fault_type}
    END

Change BTS parameter
    [Arguments]    ${dist_name}
             ...   ${param_name}
             ...   ${correct_value}
             ...   ${incorrect_value}
             ...   ${fault_type}

    logger.log_info_to_console    Changing ${param_name} in object ${dist_name} to correct value: ${correct_value}.
    ...                           log_hierarchy=${4}
    Perform Configuration Parameter Recommissioning On gNB
        ...    dist_name=${dist_name}
        ...    param_name=${param_name}
        ...    operation=update
        ...    param_value=${correct_value}
        ...    skip_parameter_relation_errors=True
        ...    should_activate=True
        ...    timeout=300

    Wait Until Keyword Succeeds     600 sec     15 sec    Verify Setup Of All Cells

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
            ...    timeout=120

    Should Contain    ${msg}    ${fault_type}

    Verify gNB Configuration Parameters Have Expected Values
        ...    param_dict=${param_to_verify}

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
    [Teardown]    Common Postconditions With Watching Alarms

Turn test line on
    ${power_on_cmd}=     Set Variable     ecolab_cli power_on -c ${tl_config}
    ${output}=     Run     ${power_on_cmd}
    logger.log_info_to_console     ${output}

Turn test line off
    ${power_off_cmd}=     Set Variable     ecolab_cli power_off -c ${tl_config}
    ${output}=     Run     ${power_off_cmd}
    logger.log_info_to_console     ${output}

Get Parameters from downloaded Commissioning
    [Documentation]  Get value of parameter in the commissioning file.
    [Arguments]    ${file_full_path}     ${param_name}
    scfa.load_scf     file_path=${file_full_path}
    ${param_value} =    scfa.get_value_from_scf   p_name=${param_name}
    [Return]    ${param_value}


CNI105353 IPsec feature activation in RuProtectEnabled mode
    logger.Log Info To Console    Get gNB commissioning file
    ${date}=    Get Current Date   exclude_millis=True
    ${scf_name}=    Set Variable    gnb_scf_${date}.xml
    Download gNB Configuration File    local_dir=${OUTPUT DIR}    filename=${scf_name}
    logger.Log Info To Console    Check actEcpriRuMPlaneSecurity parameter in configuration file
    ${featureFlag}=    Get Parameters from downloaded Commissioning    ${OUTPUT DIR}/${scf_name}    actEcpriRuMPlaneSecurity
    Run Keyword If    '${featureFlag}' != 'RuProtectDisabled'
    ...    Run Keywords
    ...        logger.Log Info To Console    Setting actEcpriRuMPlaneSecurity on RuProtectDisabled    AND
    ...        Perform Configuration Parameter Recommissioning On gNB
    ...            dist_name=MRBTS-${tl.gnbs[0].instance_id}/MNL-1/MNLENT-1/FEATCADM-1
    ...            param_name=actEcpriRuMPlaneSecurity
    ...            param_value=RuProtectDisabled
    ...            operation=update
    ...            skip_parameter_relation_errors=${False}
    ...            should_activate=${True}
    ...            timeout=${120}    AND
    ...        logger.Log Info To Console    Wait until all gNB cells are onair    AND
    ...        Wait Until Keyword Succeeds    10min    15s    gnbcell.Verify Setup Of All Cells    bts_id=0    du_id=0
    logger.Log Info To Console    Setting actEcpriRuMPlaneSecurity on RuProtectEnabled
    Perform Configuration Parameter Recommissioning On gNB
    ...    dist_name=MRBTS-${tl.gnbs[0].instance_id}/MNL-1/MNLENT-1/FEATCADM-1
    ...    param_name=actEcpriRuMPlaneSecurity
    ...    param_value=RuProtectEnabled
    ...    operation=update
    ...    skip_parameter_relation_errors=${False}
    ...    should_activate=${True}
    ...    timeout=${120}
    logger.Log Info To Console    Wait until all gNB cells are onair
    Wait Until Keyword Succeeds    10min    15s    gnbcell.Verify Setup Of All Cells    bts_id=0    du_id=0
    logger.Log Info To Console    Verify eNB Cell Statuses...
    gnbcell.Verify Setup Of All Cells    bts_id=0    du_id=0

CNI105353 IPsec feature deactivation from RuProtectEnabled to RuProtectDisabled
    logger.Log Info To Console    Setting actEcpriRuMPlaneSecurity on RuProtectDisabled
    Perform Configuration Parameter Recommissioning On gNB
    ...    dist_name=MRBTS-${tl.gnbs[0].instance_id}/MNL-1/MNLENT-1/FEATCADM-1
    ...    param_name=actEcpriRuMPlaneSecurity
    ...    param_value=RuProtectDisabled
    ...    operation=update
    ...    skip_parameter_relation_errors=${False}
    ...    should_activate=${True}
    ...    timeout=${360}
    logger.Log Info To Console    Wait until all gNB cells are onair
    Wait Until Keyword Succeeds    10min    15s    gnbcell.Verify Setup Of All Cells    bts_id=0    du_id=0
    logger.Log Info To Console    Verify eNB Cell Statuses...
    gnbcell.Verify Setup Of All Cells    bts_id=0    du_id=0
    logger.Log Info To Console    Verify Hubmod Status
    &{expected_hub_statuses}=    Create Dictionary    operationalState=enabled    commissioned=Yes    localState=unblocked
    ...                                               hardwareState=working    softwareState=configured
    asir.Verify Hubmod Status    expected_statuses=${expected_hub_statuses}

