*** Settings ***
Documentation
...   Keywords for regression testing of CRT_4G_ASIR_LTE4861_LTE5244_LTE4500-F_CR31552
...   author: Mateusz Bugaj, Daniel Kulaga, Pawel Grabania
...   contact: mateusz.bugaj@nokia.com, daniel.kulaga@nokia.com, pawel.grabania@nokia.com

Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource     taf/rfrl/bts/robot/common/gnb_bbu.robot
Resource     taf/rfrl/ue/robot/REAL_UE.robot

Library      SSHLibrary
Library      OperatingSystem
Library      taf.rfrl.utilities.logger.custom_logger                              WITH NAME    logger
Library      taf.rfrl.bts.devices.du.cell_operations.GnbCellOperations            WITH NAME    gnbcell
Library      taf.rfrl.bts.devices.du.du_operations.GnbDuOperations                WITH NAME    gnbdu
Library      taf.rfrl.procedures.resources.python.common_allowed_alarms           WITH NAME    alarm
Library      taf.rfrl.bts.devices.asir.asir_operations.EnbAsirHubOperations       WITH NAME    asir
Library      ./resources.py                                                       WITH NAME    local_resources

Variables    ./common_variables.py

*** Variables ***
${tl_config}     /home/ute/auto/testline_configuration/`uname -n | sed -r 's/(.*)-[0-9]$/\1/' | tr "-" "_"`/__init__.py

*** Keywords ***
Start Transfer On Real UE In Specific Direction
    [Arguments]     ${direction}    ${duration}    ${tput}    ${protocol}    ${deviation}       ${run}=1
    ...             ${parallel_streams}=1    ${size_packet}=1320B
    ...             ${buffer_server}=${None}    ${interval}=1    ${qci}=${None}    ${linux_congestion}=${None}
    ...             ${alias}=UE

    ${direction_upper}    Convert To Upper Case  ${direction}
    Start Data Transfer on Real UE   dt_name=DT_${run}_${direction_upper}      ue_alias=${alias}     direction=${direction}
    ...     protocol=${protocol}    duration=${duration}   tput=${tput}     parallel_streams=${parallel_streams}
    ...     size_packet=${size_packet}      buffer_client=${buffer_server}  buffer_server=${buffer_server}
    ...     interval=${interval}      qci=${qci}    linux_congestion=${linux_congestion}

    Check Data Transfer is Alive     dt_name=DT_${run}_${direction_upper}
    Await Data Transfer Finish       dt_name=DT_${run}_${direction_upper}
    Verify Average Throughput With Deviation   dt_name=DT_${run}_${direction_upper}   tput=${tput}   deviation=${deviation}

Call to selected cells
    [Arguments]     ${CellIDs}      ${duration}     ${deviation}     ${prepareUE}=True

    Run Keyword If      '${prepareUE}'=='True'      Prepare Ue for L3 Call
    ...                                                                     capabilities=${capabilities}
    ...                                                                     reboot_ue=False
    ...                                                                     timeout_reboot_ue=100

    FOR     ${Cell}      IN      @{CellIDs}
        logger.log_info_to_console    ***Call for Cell ${Cell}***    log_hierarchy=${2}
        local_resources.perform_action_according_to_matrix     cell=${Cell}     action=block
        ue.Attach Ue    UE      timeout=200
        ${tput_dl}      Set Variable    ${TPUT_MATRIX}[${Cell}][tput_dl]
        ${tput_ul}      Set Variable    ${TPUT_MATRIX}[${Cell}][tput_ul]
        ${protocol}     Set Variable    ${TPUT_MATRIX}[${Cell}][protocol]

        Run Keyword And Continue On Failure     Start Transfer On Real UE In Specific Direction     direction=dl
        ...                                     duration=${duration}    tput=${tput_dl}
        ...                                     protocol=${protocol}    deviation=${deviation}
        Run Keyword And Continue On Failure     Start Transfer On Real UE In Specific Direction     direction=ul
        ...                                     duration=${duration}    tput=${tput_ul}
        ...                                     protocol=${protocol}    deviation=${deviation}
        sleep   2s
        ue.Detach Ue    UE
        local_resources.perform_action_according_to_matrix     cell=${Cell}     action=unblock
    END

Verify number of Rfc
    [Arguments]     ${number}
    ${number_of_rfc}=    local_resources.get_number_of_rfc
    Should Be Equal     ${number_of_rfc}   ${number}

Load delta asir from file
    [Arguments]     ${delta_xml_file}
    local_resources.replace_nidd_version     xml_file=${delta_xml_file}
    local_resources.load_asir_delta_from_file     delta_xml_file=${delta_xml_file}

Verify state of Rfc channels
    [Arguments]     ${state}
    local_resources.verify_the_state_of_all_rfccell_channels     expected_state=${state}

Verify state of antresource under rfcchannel
    [Arguments]     ${state}     ${ant_id}=${None}
    local_resources.verify_the_state_of_antresource_under_rfcchannel     expected_state=${state}     ant_id=${ant_id}

Wait for Rfc Cpri link establishment
    [Arguments]     ${timeout}
    local_resources.wait_for_rfc_cpri_link_establishment     timeout=${timeout}

Verify Rfc cells state
    [Arguments]     ${expected_state}=operational
    local_resources.verify_rfc_cells_state     expected_state=${expected_state}

Verify antennas led status
    [Arguments]     ${ant_ids}
    local_resources.verify_ant_led_status     ant_ids=${ant_ids}

Verify antennas status
    [Arguments]     ${ant_ids}
    local_resources.verify_ant_status     ant_ids=${ant_ids}

Verify hub led status
    local_resources.verify_hub_led_status

Verify rfc parameters
    [Arguments]     ${parameters}
    local_resources.verify_rfc_parameters     parameters=${parameters}

Get Ids Of Ants For Rfc Hub
    ${ants}=     local_resources.get_list_of_ids_of_asir_objects     object_type=ANTMOD_R
    [Return]     ${ants}

Verify number of antennas
    [Arguments]     ${ant_ids}     ${nr_of_antennas}
    local_resources.verify_number_of_antennas     ant_ids=${ant_ids}     nr_of_antennas=${nr_of_antennas}

Reset Asiant
    [Arguments]     ${ant_id}
    local_resources.reset_asiant     ant_id=${ant_id}

Reset Hub
    local_resources.reset_hub

Verify alarm is active on AsirWebem
    [Arguments]     ${fault_id}     ${fault_name}=${None}
    local_resources.verify_alarm_is_active_on_asir     fault_id=${fault_id}     fault_name=${fault_name}

Verify alarm is not active on AsirWebem
    [Arguments]     ${fault_id}
    local_resources.verify_alarm_is_not_active_on_asir     fault_id=${fault_id}

Verify Asiant alarm
     [Arguments]     ${ant_id}
     local_resources.verify_asiant_alarm     ant_id=${ant_id}

Verify Hub alarm
    local_resources.verify_hub_alarm

Get allowed alarms
    [Arguments]    ${alarms_for_test}
    ${allowed_alarms}=     local_resources.get_allowed_alarms     custom_alarms=${alarms_for_test}
    [Return]     ${allowed_alarms}

Load delta gNB from file
    [Arguments]    ${delta_json_file}
    ${sw_version}=      gnbdu.get_bts_sw_release_name
    local_resources.load_gnb_delta_from_file     delta_json_file=${delta_json_file}_${sw_version}.json

Verify gNB cells state
    gnbcell.Verify All Cells Are Onair

Connect To BTS
    [Arguments]      ${gnb_index}=0
    SSHLibrary.Open Connection
    ...     host=${tl.gnbs[${gnb_index}].dus[0].airscale.common_units[${gnb_index}].lmp_connection.addr}
    SSHLibrary.Login
    ...     username=${tl.gnbs[${gnb_index}].dus[0].airscale.common_units[${gnb_index}].lmp_connection.username}
    ...     password=${tl.gnbs[${gnb_index}].dus[0].airscale.common_units[${gnb_index}].lmp_connection.password}

Connect To HUB
    [Arguments]      ${gnb_index}=0      ${ru_id}=0
    ...              ${user}=${tl.gnbs[${gnb_index}].dus[0].rus[${ru_id}].default_ssh_connection_details.username}
    ...              ${password}=${tl.gnbs[${gnb_index}].dus[0].rus[${ru_id}].default_ssh_connection_details.password}
    ...              ${ru_ip}=${tl.gnbs[${gnb_index}].dus[0].rus[${ru_id}].default_ssh_connection_details.addr}
    SSHLibrary.Write               text=lxc-attach -n 0x2018
    SSHLibrary.Read Until          expected=root@FHNET80:~ >
    SSHLibrary.Write               text=ssh ${user}@${ru_ip}
    ${continue}=                   Run keyword and return status
    ...                            SSHLibrary.Read Until               expected=(yes/no/[fingerprint])?
    Run keyword if   ${continue}   SSHLibrary.Write                    text=yes
    ...              ELSE          SSHLibrary.Write                    text=wrong_password
    Sleep            time_=20s     reason=Waiting for password prompt...
    SSHLibrary.Read Until          expected=Password:
    SSHLibrary.Write               text=${password}
    SSHLibrary.Read Until          expected=#

Verify hub Processes
    Connect To BTS
    Connect To HUB
    SSHLibrary.Write    ${commands}[Hub][display_processes]
    ${output}=     SSHLibrary.Read      delay=0.5s
    local_resources.verify_hub_processes    command_output=${output}     rfsw_processes=${rfsw_processes}
    SSHLibrary.Close Connection

Verify hub systemctl status
    Connect To BTS
    Connect To HUB
    SSHLibrary.Write    ${commands}[Hub][systemctl_status]
    ${output}=     SSHLibrary.Read      delay=0.5s
    local_resources.verify_hub_systemctl_status    command_output=${output}
    SSHLibrary.Close Connection

Verify if ip assigned to sw0 if on hub
    Connect To BTS
    Connect To HUB
    SSHLibrary.Write    ${commands}[Hub][dhcp]
    ${output}=     SSHLibrary.Read      delay=0.5s
    local_resources.verify_if_ip_assigned_to_sw0_if_on_hub    command_output=${output}
    SSHLibrary.Close Connection

Reset gNB and wait until it is up
    Reset gNB
    Wait Until Keyword Succeeds      900 sec      30 sec      Verify gNB is onAir
    Wait Until Keyword Succeeds      900 sec      30 sec      gnbcell.Verify All Cells Are Onair

Verify number of Rfc cells
    [Arguments]     ${expected_nr_of_cells}
    local_resources.verify_number_of_rfc_cells    expected_nr_of_cells=${expected_nr_of_cells}

Verify BBU cells
    Wait Until Keyword Succeeds      900 sec      30 sec      Verify gNB is onAir
    Wait Until Keyword Succeeds      900 sec      30 sec      gnbcell.Verify All Cells Are Onair

Set additional alarms
    [Arguments]    ${alarms_for_test}
    Set Test Variable    ${CUSTOM_ALLOWED_ALARMS}    ${alarms_for_test}

Verify no active asir alarms
    local_resources.verify_no_alarm_on_asir

Verify Power Consumption
    local_resources.verify_power_consumption

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

Turn test line on
    ${power_on_cmd}=     Set Variable     ecolab_cli power_on -c ${tl_config}
    ${output}=     Run     ${power_on_cmd}
    logger.log_info_to_console     ${output}

Turn test line off
    ${power_off_cmd}=     Set Variable     ecolab_cli power_off -c ${tl_config}
    ${output}=     Run     ${power_off_cmd}
    logger.log_info_to_console     ${output}
