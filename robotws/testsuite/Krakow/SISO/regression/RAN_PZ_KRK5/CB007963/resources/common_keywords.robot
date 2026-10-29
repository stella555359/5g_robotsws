*** Settings ***
Documentation
...   Keywords for regression testing of feature CB010546
...   author: Mateusz Bugaj, Daniel Kulaga, Pawel Grabania
...   contact: mateusz.bugaj@nokia.com, daniel.kulaga@nokia.com, pawel.grabania@nokia.com

Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource     taf/rfrl/procedures/resources/robot/BtsConfiguration.robot
Resource     taf/rfrl/ue/robot/REAL_UE.robot
Library      String
Library      taf.transport.ssh                                                    WITH NAME    ssh
Library      taf.sbts.oam.coam.admin                                              WITH NAME    admin
Library      taf.rfrl.procedures.resources.python.common_allowed_alarms           WITH NAME    alarm
Library      taf.rfrl.utilities.logger.custom_logger                              WITH NAME    logger
Library      taf.rfrl.bts.devices.asir.asir_operations.GnbAsirHubOperations          WITH NAME    asir
Library      ./resources.py                                                       WITH NAME    local_resources


*** Variables ***
${tl_config}     /home/ute/auto/testline_configuration/`uname -n | sed -r 's/(.*)-[0-9]$/\1/' | tr "-" "_"`/__init__.py

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
    local_resources.check_scout_scf_id_is_present


SISO lock unlock all cells
    local_resources.action_with_cells_using_delta    action=Lock
    BuiltIn.Sleep    5s
    local_resources.action_with_cells_using_delta    action=Unlock
    Wait Until Keyword Succeeds    600 sec    15 sec    Verify Setup Of All Cells


SISO block unblock all cells
    local_resources.action_with_cells_using_delta    action=Block
    BuiltIn.Sleep    5s
    local_resources.action_with_cells_using_delta    action=Unblock
    Wait Until Keyword Succeeds    600 sec    15 sec    Verify Setup Of All Cells


SISO block unblock all pRRHs
    local_resources.action_with_prrhs    action=Block
    BuiltIn.Sleep    5s
    local_resources.action_with_prrhs    action=Unblock
    Wait Until Keyword Succeeds    600 sec    15 sec    Verify Setup Of All Cells


SISO reset all pRRHs
    [Arguments]    ${prrh_to_reset}=${None}
    local_resources.action_with_prrhs    action=Reset    prrh_id=${prrh_to_reset}
    Wait Until Keyword Succeeds    600 sec    15 sec    Verify Setup Of All Cells


SISO Lock unlock all ASiR hubs
    local_resources.action_with_asir_hub    action=Lock
    BuiltIn.Sleep    5s
    local_resources.action_with_asir_hub    action=Unlock
    Wait Until Keyword Succeeds    600 sec    15 sec    Verify Setup Of All Cells


SISO reset all ASiR hubs
    local_resources.action_with_asir_hub    action=Reset
    Wait Until Keyword Succeeds    600 sec    15 sec    Verify Setup Of All Cells


Perform Full Commisioning After Configuration Reset
    [Arguments]    ${scf_file_path}    ${bts_host}=${tl.gnbs[${0}].cu.oam_ssh_connection_details.addr}
    ${connection}=    connections.get_default_admin_connection_alias
    ${bts_id}=    hw_info.get_mrbts_id
    config_operations.perform_commissioning_in_separate_process
    ...     connection_host=${bts_host}
    ...     bts_id=${bts_id}
    ...     scf_file_path=${scf_file_path}
    ${is_in_desired_state}=    connections.wait_for_desired_site_state
    ...     url=https://${bts_host}
    ...     timeout=150
    ...     should_be_reachable=${False}
    should be true    ${is_in_desired_state}
    ...     msg=Commissioning did not cause expected site reset


Change Configuration On BTS
    [Arguments]    ${path_to_bts_config}    ${path_to_asir_config}
    logger.log_info_to_console    Loading new config to BTS and ASIR
    Perform Full Commissioning on gNB    scf_file=${path_to_bts_config}
    BuiltIn.Sleep    180s
    asir.perform_asir_commissioning    scf_path=${path_to_asir_config}
    Wait Until Keyword Succeeds    900 sec    30 sec    Verify gNB is onAir
    Wait Until Keyword Succeeds    900 sec    30 sec    Verify Setup of All Cells


Perform_recommissoning
    [Arguments]    ${all_parameters_to_change}    ${scf_file_path}    ${asir_file_path}
    FOR    ${rat}    IN    @{all_parameters_to_change}
        logger.log_info_to_console    Changing parameters in BTS for specific RAT: ${rat}    log_hierarchy=${2}
        Change Parameters In Commissioning    params_to_change=${all_parameters_to_change}[${rat}]
    END
    logger.log_info_to_console    Restore proper SCFC    log_hierarchy=${2}
    Perform Full Commisioning After Configuration Reset    scf_file_path=${scf_file_path}
    BuiltIn.Sleep    180s
    asir.perform_asir_commissioning    scf_path=${asir_file_path}
    Wait Until Keyword Succeeds    600 sec    15 sec    Verify Setup Of All Cells


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
    Wait Until Keyword Succeeds    900 sec    15 sec    Verify Setup Of All Cells
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
    Wait Until Keyword Succeeds    900 sec    30 sec    Verify Setup Of All Cells


Save Configuration
    [Arguments]    ${scf_file_name}=initial_configuration.xml
    ...            ${file_path}=/tmp    ${asir_file_name}=initial_configuration_asir.xml
    Save current configuration    file_name=initial_configuration.xml
    ${asir_path}=    asir.get_current_scf_file    local_dir_path=${file_path}    file_name=${asir_file_name}
    [Return]    ${file_path}/${scf_file_name}    ${file_path}/${asir_file_name}


SiSo_Commissioning_BTS_Template_Commissioning
    [Arguments]    ${scf_file_path}=/tmp/initial_configuration.xml
    ...            ${asir_file_path}=/tmp    ${asir_file_name}=initial_configuration_asir.xml
    Save current configuration    file_name=initial_configuration.xml
    ${asir_path}=    asir.get_current_scf_file    local_dir_path=${asir_file_path}    file_name=${asir_file_name}
    Reset Configuration on gNB
    BuiltIn.Sleep    180s
    Wait Until Keyword Succeeds    900sec    15sec    Verify gNB is Not Commissioned
    BuiltIn.Sleep    180s
    Perform Full Commisioning After Configuration Reset    scf_file_path=${scf_file_path}
    BuiltIn.Sleep    180s
    asir.perform_asir_commissioning    scf_path=${asir_path}
    Wait Until Keyword Succeeds    900 sec    30 sec    Verify gNB is onAir
    Wait Until Keyword Succeeds    900 sec    30 sec    Verify Setup of All Cells
    Perform_recommissoning    all_parameters_to_change=${ALL_PARAMETERS_TO_CHANGE}
    ...                       scf_file_path=${scf_file_path}
    ...                       asir_file_path=${asir_path}


Start Transfer On Real UE In Specific Direction
    [Arguments]    ${direction}    ${duration}    ${tput}    ${protocol}    ${deviation}    ${cell}     ${index_run}
    ...            ${parallel_streams}=4    ${size_packet}=1320B
    ...            ${buffer_server}=${None}    ${interval}=1    ${qci}=${None}    ${linux_congestion}=reno
    ...            ${alias}=UE
    ${direction_upper}    Convert To Upper Case    ${direction}
    Start Data Transfer on Real UE    dt_name=DT_${cell}_${index_run}_${direction_upper}    ue_alias=${alias}
    ...     direction=${direction}    protocol=${protocol}    duration=${duration}   tput=${tput}
    ...     parallel_streams=${parallel_streams}    size_packet=${size_packet}    buffer_client=${buffer_client}
    ...     buffer_server=${buffer_server}    interval=${interval}    qci=${qci}    linux_congestion=${linux_congestion}
    Check Data Transfer is Alive    dt_name=DT_${cell}_${index_run}_${direction_upper}
    Await Data Transfer Finish    dt_name=DT_${cell}_${index_run}_${direction_upper}
    Verify Average Throughput With Deviation    dt_name=DT_${cell}_${index_run}_${direction_upper}    tput=${tput}
    ...                                         deviation=${deviation}


Start Transfer On Real UE In Specific Direction With Action
    [Arguments]    ${direction}    ${duration}    ${tput}    ${protocol}    ${deviation}    ${cell}
    ...            ${additional_action}    ${sec_additional_action}    ${arguments}    ${time_to_wait}      ${index_run}
    ...            ${size_packet}=1320B    ${parallel_streams}=4
    ...            ${buffer_server}=${None}    ${interval}=1    ${qci}=${None}    ${linux_congestion}=reno
    ...            ${alias}=UE
    ${direction_upper}    Convert To Upper Case    ${direction}
    Run Keyword And Continue On Failure
    ...     Start Data Transfer on Real UE    dt_name=DT_${cell}_${index_run}_${direction_upper}    ue_alias=${alias}
    ...         direction=${direction}    protocol=${protocol}    duration=${duration}    tput=${tput}
    ...         parallel_streams=${parallel_streams}    size_packet=${size_packet}    buffer_client=${buffer_server}
    ...         buffer_server=${buffer_server}    interval=${interval}    qci=${qci}
    ...         linux_congestion=${linux_congestion}
    BuiltIn.Sleep    ${time_to_wait}
    Run Keyword And Continue On Failure    ${additional_action}    ${arguments}
    Run Keyword If    '${sec_additional_action}'!='none'    BuiltIn.Sleep    ${time_to_wait}
    Run Keyword If    '${sec_additional_action}'!='none'    Run Keyword And Continue On Failure
    ...                                                     ${sec_additional_action}    ${arguments}
    Await Data Transfer Finish       dt_name=DT_${cell}_${index_run}_${direction_upper}
    Verify Average Throughput With Deviation    dt_name=DT_${cell}_${index_run}_${direction_upper}    tput=${tput}
    ...                                         deviation=${deviation}


Run Tput With Actions
    [Arguments]    ${duration}    ${tput_dl}    ${tput_ul}    ${protocol}    ${deviation}    ${Cell}
    ...            ${additional_action}    ${arguments}    ${time_to_wait}    ${cells_list}     ${index_run}
    ${run_before_call}=    local_resources.check_if_action_should_be_run_before_call    act_action=${additional_action}
    ${sec_additional_action}=    local_resources.set_sec_additional_action    act_action=${additional_action}
    ${action_before_call}=    Set Variable If    ${run_before_call}==${True}    ${additional_action}
    ...     ${sec_additional_action}
    ${additional_action}=    Set Variable If    ${run_before_call}==${True}    ${sec_additional_action}
    ...     ${additional_action}
    ${sec_additional_action}=    Set Variable If    ${run_before_call}==${True}    none    ${sec_additional_action}
    Run Keyword If    ${run_before_call}==${True}    Run Keyword And Continue On Failure    ${action_before_call}
    ...     ${arguments}
    Run Keyword And Continue On Failure    ue.Attach Ue    UE
    Run Keyword And Continue On Failure
    ...    Start Transfer On Real UE In Specific Direction With Action    direction=dl    duration=${duration}
    ...                                        tput=${tput_dl}    protocol=${protocol}    deviation=${deviation}
    ...                                        cell=${Cell}    parallel_streams=8    linux_congestion=cubic
    ...                                        size_packet=1400B    additional_action=${additional_action}
    ...                                        arguments=${arguments}    time_to_wait=${time_to_wait}
    ...                                        sec_additional_action=${sec_additional_action}     index_run=${index_run}
    Wait Until Keyword Succeeds    600 sec    15 sec    Verify Setup Of All Cells
    BuiltIn.Sleep    5s
    ue.Detach Ue    UE
    local_resources.adjust_attenuation    cell_ids=${cells_list}    attenuation_level=atten_ul
    Run Keyword If    ${run_before_call}==${True}    Run Keyword And Continue On Failure    ${action_before_call}
    ...     ${arguments}
    Run Keyword And Continue On Failure    ue.Attach Ue    UE
    Run Keyword And Continue On Failure
    ...    Start Transfer On Real UE In Specific Direction With Action    direction=ul    duration=${duration}
    ...                                        tput=${tput_ul}    protocol=${protocol}     deviation=${deviation}
    ...                                        cell=${Cell}    additional_action=${additional_action}
    ...                                        arguments=${arguments}    time_to_wait=${time_to_wait}
    ...                                        sec_additional_action=${sec_additional_action}     index_run=${index_run}
    Wait Until Keyword Succeeds    600 sec    15 sec    Verify Setup Of All Cells
    BuiltIn.Sleep    5s
    ue.Detach Ue    UE


Run Tput Without Any Actions
    [Arguments]     ${duration}    ${tput_dl}       ${tput_ul}      ${protocol}     ${deviation}      ${Cell}
    ...             ${cells_list}       ${index_run}
    ue.Attach Ue    UE
    ${tput_dl}     Set Variable    ${TPUT_MATRIX}[${Cell}][tput_dl]
    ${tput_ul}     Set Variable    ${TPUT_MATRIX}[${Cell}][tput_ul]
    ${protocol}    Set Variable    ${TPUT_MATRIX}[${Cell}][protocol]
    Run Keyword And Continue On Failure        Start Transfer On Real UE In Specific Direction    direction=dl
    ...                                        duration=${duration}    tput=${tput_dl}      index_run=${index_run}
    ...                                        protocol=${protocol}    deviation=${deviation}    cell=${Cell}
    ...                                        parallel_streams=8    linux_congestion=cubic    size_packet=1400B
    local_resources.adjust_attenuation    cell_ids=${cells_list}    attenuation_level=atten_ul
    Run Keyword And Continue On Failure        Start Transfer On Real UE In Specific Direction    direction=ul
    ...                                        duration=${duration}    tput=${tput_ul}    protocol=${protocol}
    ...                                        deviation=${deviation}    cell=${Cell}       index_run=${index_run}
#    ...                                        size_packet=1400B
    BuiltIn.Sleep    5s
    ue.Detach Ue    UE


Call to selected cells
    [Arguments]    ${CellIDs}    ${duration}    ${deviation}    ${additional_action}=none
    ...            ${arguments}=none    ${time_to_wait}=40s    ${prepareUE}=True    ${index_run}=1
    local_resources.adjust_attenuation    cell_ids=${CellIDs}    attenuation_level=max
    Run Keyword If    '${prepareUE}'=='True'    Prepare Ue for L3 Call    capabilities=${capabilities}
    ...                                                                   reboot_ue=True    timeout_reboot_ue=100
    Run Keyword If    '${prepareUE}'=='False'    ue.Reboot Ue    UE    timeout=120
    FOR     ${Cell}    IN    @{CellIDs}
        logger.log_info_to_console    ***Call for Cell ${Cell}***    log_hierarchy=${2}
        @{cells_list}    create list
        Append To List    ${cells_list}    ${Cell}
        ${dist_name}        Set Variable    ${ATTENUATOR_MATRIX}[${Cell}][dist_name]
        ${parameter}        Set Variable    ${ATTENUATOR_MATRIX}[${Cell}][parameter]
        ${qrxlevmin_max}    Set Variable    ${ATTENUATOR_MATRIX}[${Cell}][qrxlevmin_max]
        Perform Configuration Parameter Recommissioning On gNB    param_value=${qrxlevmin_max}
        ...                                                       param_name=${parameter}    dist_name=${dist_name}
        ${tput_dl}     Set Variable    ${TPUT_MATRIX}[${Cell}][tput_dl]
        ${tput_ul}     Set Variable    ${TPUT_MATRIX}[${Cell}][tput_ul]
        ${protocol}    Set Variable    ${TPUT_MATRIX}[${Cell}][protocol]
        local_resources.adjust_attenuation    cell_ids=${cells_list}        attenuation_level=atten_dl
#        ue.Reboot Ue    UE    timeout=100
        Run Keyword And Continue On Failure    Run Keyword If    '${additional_action}'=='none'
        ...     Run Tput Without Any Actions    duration=${duration}    tput_dl=${tput_dl}    tput_ul=${tput_ul}
        ...                                     protocol=${protocol}    deviation=${deviation}    Cell=${Cell}
        ...                                     cells_list=${cells_list}        index_run=${index_run}
        Run Keyword And Continue On Failure    Run Keyword If    '${additional_action}'!='none'
        ...     Run Tput With Actions    duration=${duration}    tput_dl=${tput_dl}    tput_ul=${tput_ul}
        ...                              protocol=${protocol}    deviation=${deviation}    Cell=${Cell}
        ...                              additional_action=${additional_action}    arguments=${arguments}
        ...                              time_to_wait=${time_to_wait}    cells_list=${cells_list}       index_run=${index_run}
        local_resources.adjust_attenuation    cell_ids=${cells_list}    attenuation_level=max
        ${qrxlevmin_min}    Set Variable    ${ATTENUATOR_MATRIX}[${Cell}][qrxlevmin_min]
        Perform Configuration Parameter Recommissioning On gNB    param_value=${qrxlevmin_min}
        ...                                                       param_name=${parameter}    dist_name=${dist_name}
#        Run Keyword And Continue On Failure         local_resources.generate_tput_graph    tput_dl=${tput_dl}
#        ...                                         tput_ul=${tput_ul}    dt_name=DT_${Cell}_${index_run}_
#        ...                                         file_name=${tc_name}_${Cell}_run${index_run}
    END


RAT reset
    [Arguments]    ${rat}=LTE
    ${connection}    admin.Connect To
    admin.Reset Rat    rat_type=${rat}    timeout=600    connection=${connection}
    @{Cells_list}     Set Variable    ${CELL_MAP_FOR_RAT_RESET}[${rat}]
    logger.log_info_to_console     ${rat} RAT reset
    FOR    ${Cell}    IN    @{Cells_list}
        Wait Until Keyword Succeeds    600 sec     1 sec
        ...     Verify Cell Statuses    cell_id=${Cell}
        ...                             operational_state=disabled    administrative_state=unlocked
        ...                             availability_status=offline    procedural_status=configured
    END
    Wait Until Keyword Succeeds    900 sec    30 sec    Verify Setup of All Cells


Change swconfig with corresponding flag
    [Arguments]    ${flag_code}=0x4F0214    ${flag_value}=0    ${operate}=add    ${gnb_index}=${0}
    ssh.connect to    hostname=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ...               username=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.username}
    ...               password=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.password}
    ...               alias=alias_bbmod
    ssh.execute    command=chmod 777 /ffs/run/swconfig.txt    connection=alias_bbmod
    ${swconfig_output}=    ssh.execute    command=cat /ffs/run/swconfig.txt    connection=alias_bbmod
    ${tail_output}=    ssh.execute    command=tail -1 /ffs/run/swconfig.txt    connection=alias_bbmod
    ${last_line}=    local_resources.remove_eol_from_line    line=${tail_output}
    ${cmd}=    Set Variable If
    ...                     '${operate}'=='add'    /${last_line}/a ${flag_code}=${flag_value}
    ...                     '${operate}'=='del'    /${flag_code}=${flag_value}/d
    ...                     undefined
    ssh.execute             command=sed -i '${cmd}' /ffs/run/swconfig.txt    connection=alias_bbmod
    ${swconfig_output}      ssh.execute    command=cat /ffs/run/swconfig.txt    connection=alias_bbmod
    ssh.execute             command=crasign /ffs/run/swconfig.txt    connection=alias_bbmod
    [Teardown]   ssh.disconnect    connection=alias_bbmod


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


Recommission
    [Arguments]    ${prefix_tag}=null
    logger.log_info_to_console    Loading new config to BTS and ASIR
    local_resources.perform_bts_recommissioning    prefix_tag=${prefix_tag}
    Wait Until Keyword Succeeds    900 sec    30 sec    Verify gNB is onAir
    Wait Until Keyword Succeeds    900 sec    30 sec    Verify Setup of All Cells

Prepare cell
    [Arguments]     ${cell_id}    ${qrxlevmin}    ${atten_level}=atten_dl    ${attach_ue}=False
    @{CellIDs_List}=    Create List    ${cell_id}
    local_resources.adjust_attenuation    cell_ids=${CellIDs_List}        attenuation_level=${atten_level}
    ${dist_name}            Set Variable    ${ATTENUATOR_MATRIX}[${cell_id}][dist_name]
    ${parameter}            Set Variable    ${ATTENUATOR_MATRIX}[${cell_id}][parameter]
    Perform Configuration Parameter Recommissioning On gNB     param_value=${qrxlevmin}
    ...                                                        param_name=${parameter}     dist_name=${dist_name}
    Run Keyword If      '${attach_ue}'=='True'      Prepare Ue for L3 Call
    ...                                                                     capabilities=${capabilities}
    ...                                                                     reboot_ue=False
    ...                                                                     timeout_reboot_ue=100
    Run Keyword If      '${attach_ue}'=='True'      ue.Attach Ue    UE
