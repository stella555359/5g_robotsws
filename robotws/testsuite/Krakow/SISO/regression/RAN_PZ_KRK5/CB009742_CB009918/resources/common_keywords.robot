*** Settings ***
Documentation
...   Keywords for regression testing of CB009742 and CB009918
...   author: Mateusz Bugaj, Daniel Kulaga, Pawel Grabania
...   contact: mateusz.bugaj@nokia.com, daniel.kulaga@nokia.com, pawel.grabania@nokia.com

Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource     taf/rfrl/bts/robot/common/gnb_bbu.robot
Resource     taf/rfrl/bts/robot/common/gnb_log.robot
Resource     taf/rfrl/ue/robot/REAL_UE.robot
Library      taf.rfrl.bts.devices.asir.asir_operations.GnbAsirHubOperations       WITH NAME    asir_operations
Library      taf.rfrl.bts.devices.du.commissioning.GnbCommissioning               WITH NAME    gnb_comm
Library      taf.rfrl.bts.operations                                              WITH NAME    bts_oper
Library      taf.rfrl.utilities.logger.custom_logger                              WITH NAME    logger
Library      taf.rfrl.procedures.resources.python.common_allowed_alarms           WITH NAME    alarm
Library      ./resources.py                                                       WITH NAME    local_resources
Library      ./ue_proxy.py                                                        WITH NAME    ue_proxy
Library      ./cell_actions.py                                                    WITH NAME    cell_actions

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
    Run Keyword If Test Failed    Change BTS configuration


Activate power savings in bts
    local_resources.load_gnb_delta_from_file     delta_json_file=activate_power_savings_in_bts.json


Create PSGRP in bts and verify ue
    [Arguments]     ${rat}     ${duration}     ${ue_alias}     ${cell_id}
    ${rat_lower}=    Convert To Lower Case  ${rat}
    logger.log_info to console     UE is attached to proper cell    log_hierarchy=${2}
    local_resources.load_gnb_delta_from_file     delta_json_file=activate_power_savings_in_${rat_lower}_cells.json
    ...                                          set_lbpsday=True
    logger.log_info to console     Activating power savings in ${rat} cells
    BuiltIn.Sleep     ${duration}
    logger.log_info to console     Verify ue
    ${actual_cell_id}=     ue.Get Ue info     ${ue_alias}     CELL_ID
    Run Keyword and continue on failure     local_resources.verify_cell_id_after_ps_activation
    ...     actual_cell_id=${actual_cell_id}     origin_cell_id=${cell_id}


Deactivate power savings in bts
    logger.log_info_to_console      Deactivating power savings in BTS
    local_resources.load_gnb_delta_from_file     delta_json_file=deactivate_power_savings_in_bts.json


Activate power savings in hubs
    [Arguments]     ${bts_id}=0
    logger.log_info_to_console      Activating power savings in hubs in bts${bts_id}
    local_resources.set_actlbenergysaving     bts_id=${bts_id}     value=true


Deactivate power savings in hubs
    [Arguments]     ${bts_id}=0
    logger.log_info_to_console      Deactivating power savings in hubs in bts${bts_id}
    local_resources.set_actlbenergysaving     bts_id=${bts_id}     value=false


Verify cells energy saving state
   [Arguments]    ${energy_saving_state}     ${cells_id}=${None}
   logger.log_info_to_console      Verifing that cells are in proper ${energy_saving_state} state
   local_resources.verify_cells_energy_saving_state     energy_saving_state=${energy_saving_state}
   ...                                                  cells_id=${cells_id}


Verify poe status
    [Arguments]     ${antenna_ports}     ${bts_id}=0
    local_resources.check_poe_status     bts_id=${bts_id}     antenna_ports=${antenna_ports}


Get hubs average power consumption
    [Arguments]     ${measurements}     ${power_savings_status}     ${bts_id}=0
    ${result}=     local_resources.get_hubs_average_power_consumption     bts_id=${bts_id}
    Set To Dictionary     ${measurements}     ${power_savings_status}     ${result}
    [Return]     ${measurements}


Compare power consumption
    [Arguments]     ${measurements}    ${reduction}     ${hub_id}=all
    local_resources.compare_power_consumption     measurements=${measurements}     reduction=${reduction}
    ...                                           hub_id=${hub_id}


Start Transfer On Real UE In Specific Direction QC
    [Arguments]     ${duration}    ${tput}    ${deviation}      ${cell}     ${direction}=dl       ${protocol}=udp
    ...             ${parallel_streams}=1    ${size_packet}=${None}    ${buffer_client}=${None}
    ...             ${buffer_server}=${None}    ${interval}=1    ${qci}=${None}    ${linux_congestion}=${None}
    ...             ${alias}=UE     ${index_run}=1      ${measure_power_consumption}=${None}
    ...             ${power_consumption_level}=${None}


    ${direction_upper}    Convert To Upper Case  ${direction}
    ${dt_name}=     Set Variable     DT_${cell}_${index_run}_${direction_upper}
    Start Data Transfer on Real UE   dt_name=${dt_name}      ue_alias=${alias}
    ...     protocol=${protocol}    duration=${duration}   tput=${tput}     parallel_streams=${parallel_streams}
    ...     size_packet=${size_packet}      buffer_client=${buffer_client}  buffer_server=${buffer_server}
    ...     interval=${interval}      qci=${qci}    linux_congestion=${linux_congestion}    direction=${direction}
    Run Keyword If      ${measure_power_consumption}!=${None}       BuiltIn.Sleep       40s
    Run Keyword If      ${measure_power_consumption}!=${None}       Get hubs average power consumption
    ...                                                                 measurements=${measure_power_consumption}
    ...                                                                 power_savings_status=${power_consumption_level}

    Await Data Transfer Finish       dt_name=${dt_name}
    ${tput_status}=      Run Keyword And Return Status    Verify Average Throughput With Deviation
    ...                                                   dt_name=${dt_name}   tput=${tput}    deviation=${deviation}
    Run Keyword and continue on failure    local_resources.tput_status    status=${tput_status}    cell=${cell}
    ...                                                                   direction=${direction_upper}


Run tput
    [Arguments]     ${ue_alias}     ${duration}    ${deviation}    ${cell}    ${cells_list}     ${index_run}=1
    ...             ${verify_power_saving_during_test}=${None}
    ${tput_dl}      Set Variable    ${TPUT_MATRIX}[${cell}][tput_dl]
    ${tput_ul}      Set Variable    ${TPUT_MATRIX}[${cell}][tput_ul]
    ${protocol}     Set Variable    ${TPUT_MATRIX}[${cell}][protocol]
    logger.log_info to console      UE is attached to proper cell    log_hierarchy=${2}
    logger.log_info to console      Start transfer in DL direction    log_hierarchy=${2}
    local_resources.adjust_attenuation         cell_ids=${cells_list}        attenuation_level=atten_dl
    Run Keyword and continue on failure    Start Transfer On Real UE In Specific Direction QC    direction=dl
    ...                                    duration=${duration}        tput=${tput_dl}     protocol=${protocol}
    ...                                    deviation=${deviation}      alias=${ue_alias}     cell=${cell}
    ...                                    index_run=${index_run}    size_packet=1400B
    Run Keyword If      ${verify_power_saving_during_test}!=${None}     Verify Power Saving
    ...                                                                 ${verify_power_saving_during_test}
    logger.log_info to console      Start transfer in UL direction    log_hierarchy=${2}
    local_resources.adjust_attenuation         cell_ids=${cells_list}        attenuation_level=atten_ul
    Run Keyword and continue on failure    Start Transfer On Real UE In Specific Direction QC    direction=ul
    ...                                    duration=${duration}        tput=${tput_ul}     protocol=${protocol}
    ...                                    deviation=${deviation}      alias=${ue_alias}     cell=${cell}
    ...                                    index_run=${index_run}    size_packet=1400B    parallel_streams=3
    BuiltIn.Sleep     5s
    ue.Detach Ue    ${ue_alias}
    [Teardown]     ue.Detach Ue    ${ue_alias}

Run tput In One Direction
    [Arguments]     ${ue_alias}     ${duration}    ${deviation}    ${cell}    ${cells_list}     ${index_run}=1
    ...             ${measure_power_consumption}=${None}        ${power_consumption_level}=${None}      ${tput}=${None}
    logger.log_info to console      UE is attached to proper cell    log_hierarchy=${2}
    logger.log_info to console      Start transfer in DL direction    log_hierarchy=${2}
    local_resources.adjust_attenuation         cell_ids=${cells_list}        attenuation_level=atten_dl
    Run Keyword and continue on failure    Start Transfer On Real UE In Specific Direction QC    direction=dl
    ...                                    duration=${duration}        tput=${tput}     protocol=udp
    ...                                    deviation=${deviation}      alias=${ue_alias}     cell=${cell}
    ...                                    index_run=${index_run}    size_packet=1400B
    ...                                    measure_power_consumption=${measure_power_consumption}
    ...                                    power_consumption_level=${power_consumption_level}
    [Teardown]     ue.Detach Ue    ${ue_alias}


Report problem with attach
    [Arguments]     ${cell_id}
    local_resources.report_problem_with_attach_to_wrong_cell     cell_id=${cell_id}


Reset ue proxy
    ue_proxy.stop_ue_proxy_on_ue_pc
    ue_proxy.start_ue_proxy_on_ue_pc


Apn Change
    [Arguments]     ${apn_name_to_change}       ${ue_alias}     ${prepareUE}=True
    Run Keyword If      '${prepareUE}'=='True'      Prepare Ue for L3 Call
    ...                                                                     capabilities=${capabilities}
    ...                                                                     reboot_ue=False
    ...                                                                     timeout_reboot_ue=100
    Run Keyword And Ignore Error        ue.Attach Ue    ${ue_alias}    timeout=10

    ue.Change Apn    UE    apn_name=${apn_name_to_change}
    ...                    labels_to_apn_settings=Network & internet,SIMs,Access Point Names
    Run Keyword And Ignore Error        ue.Detach Ue    ${ue_alias}    timeout=100
    [Teardown]      ue.Stop Using UE        UE


Action with ue
    [Arguments]     ${CellIDs}     ${duration}     ${action}=call     ${deviation}=7%    ${cap}=${capabilities}
    ...             ${ue_alias}=UE     ${prepareUE}=True     ${rat}=NR     ${index_run}=1
    ...             ${verify_power_saving_during_test}=${None}     ${measure_power_consumption}=${None}
    ...             ${power_consumption_level}=${None}      ${tput}=${None}
    local_resources.adjust_attenuation    cell_ids=${CellIDs}        attenuation_level=max
    Run Keyword If      '${prepareUE}'=='True'      Prepare Ue for L3 Call
    ...                                                                     capabilities=${cap}
    ...                                                                     reboot_ue=False
    ...                                                                     timeout_reboot_ue=100

    FOR     ${Cell}      IN      @{CellIDs}
        logger.log_info_to_console    ***${action} for cell ${Cell}***
        @{cells_list}       create list
        Append To List      ${cells_list}    ${Cell}
        local_resources.adjust_attenuation    cell_ids=${cells_list}        attenuation_level=min
        ${dist_name}            Set Variable    ${ATTENUATOR_MATRIX}[${Cell}][dist_name]
        ${parameter}            Set Variable    ${ATTENUATOR_MATRIX}[${Cell}][parameter]
        ${qrxlevmin_max}        Set Variable    ${ATTENUATOR_MATRIX}[${Cell}][qrxlevmin_max]
        Perform Configuration Parameter Recommissioning On gNB     param_value=${qrxlevmin_max}     timeout=${120}
		...                                                        param_name=${parameter}     dist_name=${dist_name}
        logger.log_info_to_console      Attaching UE    log_hierarchy=${2}
        Run Keyword and continue on failure    ue.Attach Ue    ${ue_alias}    timeout=100
        BuiltIn.Sleep     5s
        ${cell_id}=     ue.Get Ue info     ${ue_alias}     CELL_ID
        ${desired_cell_id}     Set Variable    ${ATTENUATOR_MATRIX}[${Cell}][real_cell_id]
        Run Keyword If  '${cell_id}'=='${desired_cell_id}' and '${action}'=='CALL'
        ...    Run Keyword and continue on failure     Run tput     ue_alias=${ue_alias}
        ...                 duration=${duration}    deviation=${deviation}    cell=${Cell}    cells_list=${cells_list}
        ...                 index_run=${index_run}     verify_power_saving_during_test=${verify_power_saving_during_test}
        ...    ELSE IF   '${cell_id}'=='${desired_cell_id}' and '${action}'=='MEASURE_POWER_CONSUMPTION'
        ...                 Run Keyword and continue on failure     Run tput In One Direction     ue_alias=${ue_alias}
        ...                 duration=${duration}    deviation=${deviation}    cell=${Cell}    cells_list=${cells_list}
        ...                 index_run=${index_run}      measure_power_consumption=${measure_power_consumption}
        ...                 power_consumption_level=${power_consumption_level}      tput=${tput}
        ...    ELSE IF   '${cell_id}'=='${desired_cell_id}' and '${action}'=='ATTACH_ONLY'
        ...             Run Keyword and continue on failure     Create PSGRP in bts and verify ue     rat=${rat}
        ...                 duration=${duration}     ue_alias=${ue_alias}     cell_id=${cell_id}
        ...    ELSE     Run Keyword and continue on failure     Report problem with attach    cell_id=${cell_id}

        local_resources.adjust_attenuation    cell_ids=${cells_list}        attenuation_level=max
        ${qrxlevmin_min}        Set Variable    ${ATTENUATOR_MATRIX}[${Cell}][qrxlevmin_min]
        Perform Configuration Parameter Recommissioning On gNB     param_value=${qrxlevmin_min}     timeout=${120}
		...                                                        param_name=${parameter}     dist_name=${dist_name}
    END
    [Teardown]      ue.Detach Ue    ${ue_alias}


Verify Power Saving
    [Arguments]     ${power_saving_values}
    FOR     ${power_saving_state}       IN      @{power_saving_values.keys()}
        Wait Until Keyword Succeeds    1200 sec    30 sec
        ...                            Verify cells energy saving state     energy_saving_state=${power_saving_state}
        ...                                                     cells_id=${power_saving_values}[${power_saving_state}]
    END

ASIR Power
    [Arguments]     ${pdu_index}     ${action}=off
    logger.log_info_to_console     Powering ${action} all ASIR hubs
    local_resources.asir_power     pdu_index=${pdu_index}     action=${action}


Change lbpsSuspended value
    [Arguments]     ${value}
    logger.log_info_to_console      Changing lbpsSuspended to ${value}
    Run Keyword If     '${value}'=='suspended'
    ...    local_resources.load_gnb_delta_from_file    delta_json_file=lbpsSuspended_suspended.json    set_lbpsday=True
    ...    ELSE     local_resources.load_gnb_delta_from_file    delta_json_file=lbpsSuspended_notSuspended.json
    ...                                                         set_lbpsday=True


Activate power savings in asir for rfc
    [Arguments]     ${bts_id}=1
    logger.log_info_to_console     Activation of power saving for ASIR RFC
    ${delta_xml_file}=     Set Variable     activate_power_savings_in_asir_rfc.xml
    local_resources.update_power_saving_day_of_week_in_asir     delta_xml_file=${delta_xml_file}
    local_resources.load_asir_delta_from_file     bts_id=${bts_id}     delta_xml_file=${delta_xml_file}


Dectivate power savings in asir for rfc
    [Arguments]     ${bts_id}=1
    logger.log_info_to_console     Deactivation of power saving for ASIR RFC

    local_resources.load_asir_delta_from_file     bts_id=${bts_id}
    ...                                           delta_xml_file=deactivate_power_savings_in_asir_rfc.xml


Verify rfc cells energy saving state
     [Arguments]     ${energy_saving_state}     ${bts_id}=1
     logger.log_info_to_console      Verifying that rfc cells are in proper ${energy_saving_state} state
     local_resources.verify_rfc_cells_energy_saving_state     energy_saving_state=${energy_saving_state}
     ...                                                      bts_id=${bts_id}


Verify number of rfc cells
    [Arguments]     ${bts_id}=1
    logger.log_info_to_console      Verifying counts of rfc cells
    local_resources.verify_number_of_rfc_cells     bts_id=${bts_id}


Verify tbEnergySavingEnabled state of rfc cells
    [Arguments]     ${tbEnergySavingEnabled}     ${bts_id}=1
    logger.log_info_to_console      Verifying that tbEnergySavingEnabled for rfc cells has proper state
    local_resources.verify_tb_energy_saving_enabled     bts_id=${bts_id}     state=${tbEnergySavingEnabled}


Reset all asir hubs
    [Arguments]     ${bts_id}=1
    local_resources.reset_all_asir_hubs     bts_id=${bts_id}


Verify all rfc cells are operational
    [Arguments]     ${bts_id}=1
    logger.log_info_to_console      Verifying that all rfc cells are operational in bts_id=${bts_id}
    local_resources.verify_all_rfc_cells_are_operational     bts_id=${bts_id}


Create external alarms
    [Arguments]     ${bts_id}=0
    logger.log_info_to_console      Creating external alarms inputs
    local_resources.load_gnb_delta_from_file     delta_json_file=create_eac.json     bts_id=${bts_id}


Activate eeea
    [Arguments]    ${rat}=${EMPTY}    ${bts_id}=0
    logger.log_info_to_console      Activate energy-efficient emergency
    local_resources.load_gnb_delta_from_file     delta_json_file=activate_eeea${rat}.json     bts_id=${bts_id}


Deactivate eeea
    [Arguments]    ${rat}=${EMPTY}    ${bts_id}=0
    logger.log_info_to_console      Deactivate energy-efficient emergency
    local_resources.load_gnb_delta_from_file     delta_json_file=deactivate_eeea${rat}.json     bts_id=${bts_id}


Create eeea group
    [Arguments]     ${alarm}    ${bts_id}=0
    logger.log_info_to_console      Create energy-efficient emergency group for ${alarm}
    local_resources.load_gnb_delta_from_file     delta_json_file=eeea_group_${alarm}.json     bts_id=${bts_id}


Activate alarm
    [Arguments]     ${alarm}    ${bts_id}=0
    logger.log_info_to_console      Activate ${alarm}
    local_resources.load_gnb_delta_from_file     delta_json_file=activate_${alarm}.json     bts_id=${bts_id}


Dectivate alarm
    [Arguments]     ${alarm}    ${bts_id}=0
    logger.log_info_to_console      Deactivate ${alarm}
    local_resources.load_gnb_delta_from_file     delta_json_file=deactivate_${alarm}.json     bts_id=${bts_id}


Prepare both gnbs
    logger.log_info_to_console      Prepare second GNB
    local_resources.change_bts_configuration     bts_id=1
    logger.log_info_to_console      Prepare main GNB
    Common Suite Setup With OnAir Test Line Preparation


Actions before test on second gnb
    [Arguments]    ${alarms_for_test}=${None}
    ${default_alarms}=    alarm.get_variables
    Set Test Variable    ${allowed_alarms}    ${default_alarms}[allowed_alarms]
    Set Test Variable    ${ASIR_ALLOWED_ALARMS}    ${default_alarms}[ASIR_ALLOWED_ALARMS]
    Run keyword if    "${alarms_for_test}!=${None}"    Set additional alarms    ${alarms_for_test}
    Add Custom Allowed Alarms If Defined
    gnb_alarm.Start watching alarms    allowed_alarms=${allowed_alarms}    gnb_id=${1}
    gnb_alarm.Watch Active Alarms and Collect Logs on Unexpected Alarm    gnb_id=${1}
    Start Collecting gNB Btslog    gnb_id=${1}
    Common Preconditions With Watching Alarms


Actions after test on second gnb
    gnb_alarm.Stop watching alarms    gnb_id=${1}
    Remove custom allowed alarms if defined
    Common Postconditions With Watching Alarms
    Collect Snapshot From gNB    gnb_id=${1}    log_dir=${LOG_PATH}
    Collect IM Snapshot From gNB    gnb_id=${1}    log_dir=${LOG_PATH}
    Collect IMS Log From gNB    gnb_id=${1}    log_dir=${LOG_PATH}
    Run Keyword If Test Failed    Change BTS configuration     bts_id=${1}
    Stop Collecting gNB Btslog    gnb_id=${1}    log_dir=${LOG_PATH}


Turn test line on
    ${power_on_cmd}=     Set Variable     ecolab_cli power_on -c ${tl_config}
    ${output}=     Run     ${power_on_cmd}
    logger.log_info_to_console     ${output}


Turn test line off
    ${power_off_cmd}=     Set Variable     ecolab_cli power_off -c ${tl_config}
    ${output}=     Run     ${power_off_cmd}
    logger.log_info_to_console     ${output}


Get BTS counter with energy consumption
    [Arguments]    ${measurements}     ${power_savings_status}     ${bts_id}=0
    ${result}=     local_resources.get_counter     bts_id=${bts_id}
    Set To Dictionary     ${measurements}     ${power_savings_status}     ${result}
    [Return]     ${measurements}


Activate Power Saving CB009918
    [Arguments]     ${delta}
    logger.log_info_to_console      Activating power savings in BTS
    local_resources.load_gnb_delta_from_file     delta_json_file=${delta}       set_lbpsday=True

Move cells from eeagrp to psgrp
    [Arguments]     ${delta}
    logger.log_info_to_console      Moving NR and LTE cells from EEAGRP to PSGRP
    local_resources.load_gnb_delta_from_file     delta_json_file=${delta}

Change BTS configuration
    [Arguments]     ${bts_id}=0   ${prefix_tag}=${None}    ${wait_for_cells}=${True}
    local_resources.change_bts_configuration        bts_id=${bts_id}     prefix_tag=${prefix_tag}
    ...                                             wait_for_cells=${wait_for_cells}


Cells Actions
    [Arguments]     ${action}       ${cell_list}=${None}
    cell_actions.Action With Cells     action=${action}        cell_id=${cell_list}
    BuiltIn.Sleep     5s


Activate uDTX
    [Arguments]     ${delta}=uDTX_activate.json
    logger.log_info_to_console      Activating uDTX in BTS
    local_resources.load_gnb_delta_from_file     delta_json_file=${delta}


Verify that no asir crash occured
   [Arguments]     ${bts_id}    ${timeout}
   logger.log_info_to_console      Verifing that no asir crash occurs on bts${1} during next ${timeout}s
   local_resources.verify_that_no_asir_crash_occured    bts_id=${bts_id}    timeout=${timeout}


Try to change not exist parameters via admin
    [Arguments]     ${delta}    ${parameters}
    ${msg}=    Run Keyword And Expect Error     AdminApiProcedureFailureException*
    ...    Activate uDTX    delta=${delta}
    logger.log_info_to_console    ${msg}
    FOR    ${parameter}    IN    @{parameters}
        Should Contain    ${msg}    '${parameter}', 'error': ['parameter cannot be updated']
        logger.log_info_to_console    '${parameter}' was not updated via admin.    log_hierarchy=2
    END


Try to change not exist parameter via webem
    [Arguments]    ${dist_name}    ${parameter}    ${value}
    ${msg}=    local_resources.change_bts_parameter_via_gui    dist_name=${dist_name}    parameter=${parameter}
    ...                                                        value=${value}
    Should be equal    ${msg}    Parameter ${parameter} was not found via Webem.


Try to change actMicroDTXAdvanced via webem
    Run Keyword And Expect Error    IndexError: list index out of range
    ...    gnb_comm.change_parameter_via_gui    dist_name=MRBTS-77135/NRBTS-77135    parameter=actMicroDTXAdvanced
    ...                                         value=true


Wait until bts is on_air
    [Arguments]    ${bts_id}=${0}    ${timeout}=${300}
    bts_oper.wait_until_bts_is_up_and_on_air    bts_id=${bts_id}    timeout=${timeout}


Verify MicroDTX feature in syslog
    [Arguments]    ${cell_ids}    ${syslog_dir}=/tmp/btslog2
    logger.log_info_to_console    Verify MicroDTX feature in syslog
    FOR    ${cell_id}    IN    @{cell_ids}
        ${string_to_find}=    Set Variable    enableMicroDTX_ = 1, enableAdvanceDTX = 1.*NR-${cell_id}
        ${syslog_lines}=    run    grep -i -r -E "${string_to_find}" --include=*.LOG ${syslog_dir}
        Should Not Be Empty    ${syslog_lines}
        logger.log_info_to_console    MicroDTX for NRCELL-${cell_id}    log_hierarchy=2
        logger.log_info_to_console    ${syslog_lines}    log_hierarchy=3

    END
