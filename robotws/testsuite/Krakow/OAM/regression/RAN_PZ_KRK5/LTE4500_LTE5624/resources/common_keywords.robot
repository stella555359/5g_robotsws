*** Settings ***
Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot

Resource     taf/rfrl/ue/robot/REAL_UE.robot
Library      taf.rfrl.bts.devices.du.cell_operations.GnbCellOperations                      WITH NAME    cell_operations
Library      taf.rfrl.bts.devices.du.du_operations.GnbDuOperations                          WITH NAME    du_operations
Library      taf.rfrl.bts.devices.du.commissioning.GnbCommissioning                         WITH NAME    du_comm
Library      taf.rfrl.bts.devices.ru.ru_operations.GnbRuOperations                          WITH NAME    ru_operations
Library      taf.rfrl.bts.devices.asir.asir_operations.GnbAsirHubOperations                 WITH NAME    asir
Library      taf.rfrl.utilities.logger.custom_logger                                        WITH NAME    logger
Library      taf.rfrl.procedures.resources.python.common_allowed_alarms                     WITH NAME    alarm
Library      OperatingSystem
Library      SSHLibrary
Library      String
Library      ./resources.py                                                                 WITH NAME    local_resources
Library      DateTime                                                                       WITH NAME    dt
Library      taf.config.scf                                                                 WITH NAME    scf
Variables    ./common_variables.py

*** Variables ***
${tl_config}     /home/ute/auto/testline_configuration/7_7_UTE5GCLOUDT1SK007/__init__.py

*** Keywords ***
Get Parameters from downloaded Commissioning
    [Documentation]  Get value of parameter in the commissioning file.
    [Arguments]    ${file_full_path}    ${param_name}
    scf.Load Scf    file_path=${file_full_path}
    ${param_value} =    scf.Get Value From Scf    p_name=${param_name}
    [Return]    ${param_value}

CB007233-5G-A_TC01_Activation of the feature CB006114 in RuProtectEnabled mode
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

CB007233-5G-A_TC16_Deactivation of the feature CB006114 from RuProtectEnabled to RuProtectDisabled
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


Perform Params Recommisioning And Verify Alarms
    ${params_to_change}=        local_resources.prepare_params_to_delta     delta_template=${earfcn_to_change}
    ...                         first_val=1800      second_val=19800
    ${prev_val_of_earfcnDL}=       du_operations.get_param_value       param_name=earfcnDL
    ${prev_val_of_earfcnUL}=       du_operations.get_param_value       param_name=earfcnUL
    du_comm.perform_bts_delta_commissioning     delta=${params_to_change}
    Sleep   60s
    gnb_alarm.Verify Alarm is Active on gNB     fault_name=Failure detected on assigned antennas
    asir.Verify Only Allowed Alarms Are Active      allowed_alarms=${ASIR_ALARMS}[Earfcn_change]
    ${params_to_change}=        local_resources.prepare_params_to_delta     delta_template=${earfcn_to_change}
    ...                         first_val=${prev_val_of_earfcnDL}      second_val=${prev_val_of_earfcnUL}
    du_comm.perform_bts_delta_commissioning     delta=${params_to_change}
    Sleep   60s
    gnb_alarm.Verify Alarm is not Active on gNB      fault_name=Failure detected on assigned antennas
    asir.Verify Only Allowed Alarms Are Active      allowed_alarms=${ASIR_ALARMS}[Default_list_of_alarms]
    Wait Until Keyword Succeeds     180 sec     10 sec   gnbcell.Verify Setup Of All Cells

Block Hub And Verify Alarms
    [Arguments]     ${hub_to_block}=1
    Wait Until Keyword Succeeds     180 sec     10 sec   gnbcell.Verify Setup Of All Cells
    ru_operations.lock_radio_unit       radio_unit_id=${hub_to_block}       radio_type=asirmod
    Sleep   5s
    ru_operations.verify_radio_unit_status      radio_unit_id=${hub_to_block}     bts_state=locked    radio_type=asirmod
    asir.Verify Only Allowed Alarms Are Active      allowed_alarms=${ASIR_ALARMS}[Block_RF_Mod]
    ru_operations.unlock_radio_unit     radio_unit_id=${hub_to_block}       radio_type=asirmod
    Sleep   5s
    ru_operations.verify_radio_unit_status      radio_unit_id=${hub_to_block}     bts_state=online    radio_type=asirmod
    asir.Verify Only Allowed Alarms Are Active      allowed_alarms=${ASIR_ALARMS}[Default_list_of_alarms]
    Wait Until Keyword Succeeds     180 sec     10 sec   gnbcell.Verify Setup Of All Cells

Configuration Reset On ASIR
    [Arguments]     ${file_name}=initial_configuration.xml
    ...             ${file_path}=/tmp      ${asir_file_name}=initial_configuration_asir.xml
    gnb_bbu.Download gNB Configuration File      local_dir=${file_path}         filename=${file_name}
    ${asir_path}=       asir.Get Current Scf File      local_dir_path=${file_path}      file_name=${asir_file_name}
    asir.Reset Configuration
    Sleep       240s
    asir.Verify Only Allowed Alarms Are Active      allowed_alarms=${ASIR_ALARMS}[Config_Reset]
    asir.Perform Asir Commissioning     scf_path=${asir_path}
    Wait Until Keyword Succeeds     900 sec     30 sec   gnbcell.Verify Setup Of All Cells
    asir.Verify Only Allowed Alarms Are Active      allowed_alarms=${ASIR_ALARMS}[Default_list_of_alarms]

Start Transfer On Real UE In Specific Direction
    [Arguments]     ${direction}    ${duration}    ${tput}    ${protocol}    ${deviation}       ${run}=1
    ...             ${parallel_streams}=1    ${size_packet}=1320B   ${buffer_client}=${None}
    ...             ${buffer_server}=${None}    ${interval}=1    ${qci}=${None}    ${linux_congestion}=${None}
    ...             ${alias}=UE

    ${direction_upper}    Convert To Upper Case  ${direction}
    Start Data Transfer on Real UE   dt_name=DT_${run}_${direction_upper}      ue_alias=${alias}
    ...     protocol=${protocol}    duration=${duration}   tput=${tput}     parallel_streams=${parallel_streams}
    ...     size_packet=${size_packet}      buffer_client=${buffer_server}  buffer_server=${buffer_server}
    ...     interval=${interval}      qci=${qci}    linux_congestion=${linux_congestion}    direction=${direction}

    Check Data Transfer is Alive     dt_name=DT_${run}_${direction_upper}
    Await Data Transfer Finish       dt_name=DT_${run}_${direction_upper}
    Verify Average Throughput With Deviation   dt_name=DT_${run}_${direction_upper}   tput=${tput}      deviation=${deviation}

Perform Data Call
    [Arguments]     ${direction}    ${duration}    ${tput}      ${protocol}    ${deviation}     ${prepareUE}=True
    Run Keyword If      '${prepareUE}'=='True'      Prepare Ue for L3 Call      capabilities=${capabilities}
    ...                                             reboot_ue=False     timeout_reboot_ue=100
    ue.Attach Ue    UE      timeout=200
    Start Transfer On Real UE In Specific Direction     direction=${direction}    duration=${duration}    tput=${tput}
    ...                                                 protocol=${protocol}    deviation=${deviation}
    sleep   2s
    ue.Detach Ue    UE

Reset Hubs
    [Arguments]     ${hub_list}
    FOR     ${hub}      IN      ${hub_list}
        asir.Reset Hub      hub_id=${hub}
        Wait Until Keyword Succeeds    300 sec    20 sec    asir.Verify Hubmod Status       hub_ids=${hub}
        ...                                                 expected_statuses=${statuses_after_reset_hub}
        Connect To BTS
        Connect To HUB
        Wait Until Keyword Succeeds    300 sec    20 sec    Verify Direct Connection For CLI Interface Via An LMT Interface
        SSHLibrary.Close Connection
        ${ru_id}=       local_resources.prepare Ru Id For Checking Ip      ${hub}
        Verify If Ip Assigned To SW0 InterFace On HUBs     ru_id=${ru_id}
        Get Power Consumption       ant_id=${ru_id}
    END
    Wait Until Keyword Succeeds     900 sec     30 sec   gnbcell.Verify Setup Of All Cells

Connect To BTS
    [Arguments]      ${gnb_index}=0
    SSHLibrary.Open Connection     host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    SSHLibrary.Login       username=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.username}
    ...                    password=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.password}

Connect To HUB
    [Arguments]      ${gnb_index}=0      ${ru_id}=0
    ...              ${user}=${tl.gnbs[${gnb_index}].dus[${gnb_index}].rus[${ru_id}].default_ssh_connection_details.username}
    ...              ${password}=${tl.gnbs[${gnb_index}].dus[${gnb_index}].rus[${ru_id}].default_ssh_connection_details.password}
    ...              ${ru_ip}=${tl.gnbs[${gnb_index}].dus[${gnb_index}].rus[${ru_id}].default_ssh_connection_details.addr}
    SSHLibrary.Write               text=lxc-attach -n 0x1018
    SSHLibrary.Read Until          expected=root@FHNET00:~ >
    SSHLibrary.Write               text=ssh ${user}@${ru_ip}
    ${continue}=                   Run keyword and return status
    ...                            SSHLibrary.Read Until               expected=(yes/no/[fingerprint])?
    Run keyword if   ${continue}   SSHLibrary.Write                    text=yes
    ...              ELSE          SSHLibrary.Write                    text=wrong_password
    Sleep            time_=20s     reason=Waiting for password prompt...
    SSHLibrary.Read Until          expected=Password:
    SSHLibrary.Write               text=${password}
    SSHLibrary.Read Until          expected=#

Verify Direct Connection For CLI Interface Via An LMT Interface
    Sleep       5s
    SSHLibrary.Write        rfsw_cli
    SSHLibrary.Read Until       rfsw>

Verify If Ip Assigned To SW0 InterFace On HUBs
    [Arguments]      ${gnb_index}=0      ${ru_id}=0
    ...              ${user}=${tl.gnbs[${gnb_index}].dus[${gnb_index}].rus[${ru_id}].default_ssh_connection_details.username}
    ...              ${password}=${tl.gnbs[${gnb_index}].dus[${gnb_index}].rus[${ru_id}].default_ssh_connection_details.password}
    ...              ${ru_ip}=${tl.gnbs[${gnb_index}].dus[${gnb_index}].rus[${ru_id}].default_ssh_connection_details.addr}
     Connect To BTS
     Connect To HUB     ru_id=${ru_id}
     SSHLibrary.Write               text= ifconfig sw0| grep ether
     ${output}=      SSHLibrary.Read Until Regexp   ether ([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})
     logger.log_info_to_console      ${output}
     SSHLibrary.Close Connection

Get Power Consumption
    [Arguments]     ${ant_id}=0     ${action}=on
    Connect To BTS
    Connect To HUB      ru_id=${ant_id}
    SSHLibrary.Write    ${commands}[Hub][power_consumptions]
    ${output}=     SSHLibrary.Read      delay=0.5s
    local_resources.compare_power_consumption    command_output=${output}    ant_id=${ant_id}       action=${action}
    SSHLibrary.Close Connection

Cell Block And Unblock
    [Arguments]     ${CellIDs}
    Wait Until Keyword Succeeds      900 sec      30 sec      gnbcell.Verify Setup of All Cells
    FOR      ${Cell}      IN      @{CellIDs}
        ${cell_id}=      local_resources.get_ids_from_cell_list      cell=${Cell}
        cell_operations.Block Cell      cell_id=${cell_id}
        Sleep      5s
        cell_operations.Verify Cell Is Blocked      cell_id=${cell_id}
        gnb_alarm.Verify Alarm is Active on gNB     fault_name=Cell blocked
        Sleep      5s
        Verify Other Cell Are Actve On BTS      CellIDs=@{CellIDs}          blocked_cell=${cell_id}
        Sleep      5s
        cell_operations.Unblock Cell      cell_id=${cell_id}
        Sleep      5s
        gnb_alarm.Verify Alarm is not Active on gNB      fault_name=Cell blocked
    END
    Wait Until Keyword Succeeds      900 sec      30 sec      gnbcell.Verify Setup of All Cells

Verify Other Cell Are Actve On BTS
    [Arguments]     ${CellIDs}      ${blocked_cell}
    FOR     ${Cell}     IN      @{CellIDs}
        ${cell_id}=      local_resources.get_ids_from_cell_list      cell=${Cell}
        Run Keyword If    "${cell_id}" != "${blocked_cell}"    cell_operations.Verify Cell Is Onair    cell_id=${cell_id}
    END

Block Ants
    [Arguments]         ${ant_statuses}     ${str_ants_list}=null
    ${all_ants_mod_id_list}   asir.get_all_antenna_ids
    @{Cell_map}     cell_operations.get_all_cells_id
    logger.log_info_to_console  All Available Ant Mod ID: ${all_ants_mod_id_list}
    ${ants_list}  Set Variable If  '${str_ants_list}' == 'null'  ${all_ants_mod_id_list}  ${ants}
    logger.log_info_to_console  Block ANTs in list @{ants_list}
    FOR  ${ant_id}  IN  @{ants_list}
        logger.log_info_to_console  Block ANT ${ant_id}
        asir.block_antenna      ant_id=${ant_id}
        Sleep   5s
        @{ants_list}    create list
        Append To List    ${ants_list}    ${ant_id}
        Wait Until Keyword Succeeds      300 sec      30 sec      asir.verify_antmod_status       ant_ids=@{ants_list}
        ...                                                       expected_statuses=${ant_statuses_blocked}
    END
    asir.Verify Only Allowed Alarms Are Active      allowed_alarms=${ASIR_ALARMS}[Block_ants]

Unblock Ants
    [Arguments]         ${ant_statuses}     ${str_ants_list}=null
    ${all_ants_mod_id_list}   asir.get_all_antenna_ids
    logger.log_info_to_console  All Available Ant Mod ID: ${all_ants_mod_id_list}
    ${ants_list}  Set Variable If  '${str_ants_list}' == 'null'  ${all_ants_mod_id_list}  ${ants}
    logger.log_info_to_console  UnBlock ANTs in list @{ants_list}
    FOR  ${ant_id}  IN  @{ants_list}
        logger.log_info_to_console  Unblock ANT ${ant_id}
        asir.unblock_antenna      ant_id=${ant_id}
        Sleep   5s
    END
    Wait Until Keyword Succeeds      120 sec      20 sec      asir.verify_antmod_status       ant_ids=@{ants_list}
    ...                                                       expected_statuses=${ant_statuses_unblocked}
    asir.Verify Only Allowed Alarms Are Active      allowed_alarms=${ASIR_ALARMS}[Default_list_of_alarms]

Add custom alarms
    [Arguments]    ${alarms_for_test}
    Set Test Variable    ${additional_allowed_alarms}    ${alarms_for_test}
    Set Test Variable    ${CUSTOM_ALLOWED_ALARMS}    ${alarms_for_test}

Actions before test
    [Arguments]    ${alarms_for_test}=${None}
    ${default_alarms}=    alarm.get_variables
    Set Test Variable    ${allowed_alarms}    ${default_alarms}[allowed_alarms]
    Set Test Variable    ${ASIR_ALLOWED_ALARMS}    ${default_alarms}[ASIR_ALLOWED_ALARMS]
    Run keyword if    "${alarms_for_test}!=${None}"    Add custom alarms    ${alarms_for_test}
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

