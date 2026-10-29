*** Settings ***
Documentation
...   Common keywords for test suite for regression testing of feature CB010969
...   author: Mateusz Bugaj, Daniel Kulaga, Pawel Grabania
...   contact: mateusz.bugaj@nokia.com, daniel.kulaga@nokia.com, pawel.grabania@nokia.com
#Resource     taf/rfrl/procedures/SISO/General_SiSo_HWPTA_Collect_RFSW_Logs_From_RU_Into_BTS_Snapshot.robot
Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot

Library      Collections
Library      taf.rfrl.utilities.logger.custom_logger                              WITH NAME    logger
Library      taf.rfrl.bts.devices.ru.ru_operations.GenericRuOperations            WITH NAME   GnbRadio
Library      taf.rfrl.bts.devices.asir.asir_operations.GnbAsirHubOperations       WITH NAME    asir
Library     ./asir_hub_actions.py                                                 WITH NAME    asir_hub_actions
Library     ./commisioning_actions.py                                             WITH NAME    commisioning_actions
Library     ./resources.py                                                        WITH NAME    local_resources
Library      taf.rfrl.procedures.resources.python.config_operations.ConfigOperations    WITH NAME    config_operations
Library      taf.rfrl.bts.devices.du.du_operations.GnbDuOperations                WITH NAME    gnb_du
Library      taf.hw.pdu                                                                 WITH NAME    pdu
Library      ./call_procedure/ue_proxy.py                                         WITH NAME    ue_proxy
Library      ./call_procedure/bts_operations.py
Library      ./call_procedure/ue_operations.py
Library      ./call_procedure/attenuator_operations.py
Library      ./call_procedure/html_thput_table.py
Library      ./call_procedure/console_thput_table.py
Library      taf/rfrl/procedures/resources/python/connections.py
Library      taf/rfrl/procedures/resources/python/hw_info/hw_info.py

*** Keywords ***
###end test if tput failed###
Call To Selected Cells and fail
    [Arguments]     ${cell_list}     ${deviation}     ${duration}     ${alias}=UE     ${run_num}=1
    ue_proxy.Restart UE Proxy On UE PC
    Call Procedure and fail     cell_list=${cell_list}      alias=${alias}      raise_errors=${True}       run_num=${run_num}
    ...                         deviation=${deviation}      duration=${duration}

Call Procedure and fail
    [Arguments]     ${cell_list}     ${deviation}     ${duration}        ${alias}=UE     ${run_num}=1
    ...             ${raise_errors}=${True}     ${rerun}=${False}
    Prepare Setup Before Call Procedure
    Prepare UE For Test     alias=${alias}        capabilities=${capabilities}
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
        Prepare Cell Before Data Transfer       cell=${cell}     attenuation_level=atten_dl
        Run Keyword If      ${attach_status}==${True}       Perform Data Transfer On UE
        ...                                                 direction=dl    duration=${duration}    protocol=${protocol}
        ...                                                 parallel_streams=${parallel_streams}     linux_congestion=${linux_congestion}
        ...                                                 deviation=${deviation}    cell_name=${cell}    tput=${tput_dl}
        ...                                                 raise_errors=${raise_errors}        run_num=${run_num}
        ...                                                 rerun=${rerun}
        Prepare Cell Before Data Transfer       cell=${cell}     attenuation_level=atten_ul
        Run Keyword If      ${attach_status}==${True}       Perform Data Transfer On UE
        ...                                                 direction=ul        duration=${duration}        protocol=${protocol}
        ...                                                 parallel_streams=${parallel_streams}     linux_congestion=${linux_congestion}
        ...                                                 deviation=${deviation}       cell_name=${cell}      tput=${tput_ul}
        ...                                                 raise_errors=${raise_errors}        run_num=${run_num}
        ...                                                 rerun=${rerun}

        Wait Until Keyword Succeeds     5x      10s        Try To Make Detach      alias=${alias}
        Prepare Setup Before Next Call      cell=${cell}
    END
    [Teardown]      Release Resources      ${alias}

########################################################################################################################

Call To Selected Cells
    [Arguments]     ${cell_list}     ${deviation}     ${duration}     ${alias}=UE     ${run_num}=1
    ue_proxy.Restart UE Proxy On UE PC
    Call Procedure      cell_list=${cell_list}      alias=${alias}      raise_errors=${False}       run_num=${run_num}
    ...                 deviation=${deviation}      duration=${duration}
    ${recall}=          Check If Need Recall
    ${failed_cells}=         Get Failed Cells List
    Run Keyword If     ${recall}==${True}     logger.log_info_to_console
    ...                                       Performing data call for previously failed cells: ${failed_cells}
    Run Keyword If     ${recall}==${True}     ue_proxy.restart_ue_proxy_on_ue_pc
    Run Keyword If     ${recall}==${True}     Call Procedure        cell_list=${failed_cells}     alias=${alias}
    ...                                       deviation=${deviation}      duration=${duration}
    ...                                       run_num=Prepare Num Run Before Recall    run_num=${run_num}    rerun=${True}
    html_thput_table.Generate Html Thput Table      run_num=${run_num}
    console_thput_table.Generate Console Thput Table

Call Procedure
    [Arguments]     ${cell_list}     ${deviation}     ${duration}       ${alias}=UE     ${run_num}=1
    ...             ${raise_errors}=${True}     ${rerun}=${False}
    Prepare Setup Before Call Procedure
    Prepare UE For Test     alias=${alias}
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
        Prepare Cell Before Data Transfer       cell=${cell}     attenuation_level=atten_dl
        Run Keyword If      ${attach_status}==${True}       Run Keyword And Continue On Failure
        ...                 Perform Data Transfer On UE     direction=dl    duration=${duration}    protocol=${protocol}
        ...                                                 parallel_streams=${parallel_streams}     linux_congestion=${linux_congestion}
        ...                                                 deviation=${deviation}    cell_name=${cell}    tput=${tput_dl}
        ...                                                 raise_errors=${raise_errors}        run_num=${run_num}
        ...                                                 rerun=${rerun}
        Prepare Cell Before Data Transfer       cell=${cell}     attenuation_level=atten_ul
        Run Keyword If      ${attach_status}==${True}       Run Keyword And Continue On Failure
        ...                 Perform Data Transfer On UE     direction=ul        duration=${duration}        protocol=${protocol}
        ...                                                 parallel_streams=${parallel_streams}     linux_congestion=${linux_congestion}
        ...                                                 deviation=${deviation}       cell_name=${cell}      tput=${tput_ul}
        ...                                                 raise_errors=${raise_errors}        run_num=${run_num}
        ...                                                 rerun=${rerun}

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
    bts_operations.Perform Parameter Recommisioning        cell_list=${cell_to_call}       param_level=min
    Adjust Attenuation      cell_ids=${cell_to_call}    attenuation_level=avg

Prepare Setup Before Next Call
    [Arguments]     ${cell}
    @{cell_to_call}       create list
    Append To List      ${cell_to_call}    ${cell}
    bts_operations.Perform Parameter Recommisioning        cell_list=${cell_to_call}       param_level=max
    Adjust Attenuation      cell_ids=${cell_to_call}        attenuation_level=max

Prepare Cell Before Data Transfer
    [Arguments]     ${cell}     ${attenuation_level}
    @{cell_to_call}       create list
    Append To List      ${cell_to_call}    ${cell}
    Adjust Attenuation      cell_ids=${cell_to_call}        attenuation_level=${attenuation_level}

########################################################################################################################

Verify snapshot
    Prepare logs path
    ${repo_path}=    taf.rfrl.utilities.test_config.Get Repository Path
#    ${asir_csv_path}=    Set Variable    testsuite/Krakow/SISO/features/CB010969/resources/ASIR.csv
    Fail    General_SiSo_HWPTA_Collect_RFSW_Logs_From_RU_Into_BTS_Snapshot has been removed
#    General_SiSo_HWPTA_Collect_RFSW_Logs_From_RU_Into_BTS_Snapshot
#	...    additional_documentation_path=${repo_path}/${asir_csv_path}
    local_resources.check_snapshot     directory=${logs_path}/Full/Full_snapshot.zip

Add custom alarms
    [Arguments]    ${alarms_for_test}
    Set Test Variable    ${additional_allowed_alarms}    ${alarms_for_test}
    Set Test Variable    ${CUSTOM_ALLOWED_ALARMS}    ${alarms_for_test}

Actions after test
    Remove custom allowed alarms if defined
    [Teardown]    Common Postconditions With Watching Alarms

Actions before test
    [Arguments]    ${alarms_for_test}=${None}
    Run keyword if    "${alarms_for_test}!=${None}"    Add custom alarms    ${alarms_for_test}
    Common Preconditions With Watching Alarms


SISO reset all ASiR hubs
    asir_hub_actions.action_with_asir_hub    action=Reset     gnb_oam_ip=${gnb_oam_ip}     mrbts_id=${mrbts_id}
    ...    nrbts_id=${nrbts_id}
    Wait Until Keyword Succeeds    600 sec    15 sec    Verify Setup Of All Cells

SISO Lock unlock all ASiR hubs
    logger.log_info_to_console      Locking All HUBs
    asir_hub_actions.action_with_asir_hub        action=Lock     gnb_oam_ip=${gnb_oam_ip}     mrbts_id=${mrbts_id}
    ...    nrbts_id=${nrbts_id}
    logger.log_info_to_console      Unlocking All HUBs
    asir_hub_actions.action_with_asir_hub        action=Unlock     gnb_oam_ip=${gnb_oam_ip}     mrbts_id=${mrbts_id}
    ...    nrbts_id=${nrbts_id}
    Wait Until Keyword Succeeds    600 sec    15 sec    Verify Setup Of All Cells

Check Fault Id After Parameters Change
    [Arguments]     ${fault_id}
    ${params_to_change}=      commisioning_actions.Get Parameter Value From Bts
    ...                       params=${params_to_change_for_trigger_fault_${fault_id}}
    commisioning_actions.perform parameter recommisioning    params_to_change=${params_to_change}
    ...                                                      value_name=new_param_val
    Sleep    300s
    logger.log_info_to_console      Verifying if alarms are visible on WEBEM and AsirWEBEM      log_hierarchy=2
    Wait Until Keyword Succeeds      600 sec     30 sec      Verify Alarm is Active on gNB       fault_id=4479
    ...                              fault_name=Failure detected on assigned antennas
    Wait Until Keyword Succeeds      600 sec     30 sec      asir.Verify Alarm Is Active        fault_id=${fault_id}
    commisioning_actions.perform parameter recommisioning    params_to_change=${params_to_change}
    ...                                                      value_name=act_param_val
    Sleep    300s
    logger.log_info_to_console      Verifying if alarms are not visible on WEBEM and AsirWEBEM      log_hierarchy=2
    Wait Until Keyword Succeeds      600 sec     30 sec      Verify Alarm is not Active on gNB       fault_id=4479
    ...                              fault_name=Failure detected on assigned antennas
    Wait Until Keyword Succeeds      600 sec     30 sec      asir.Verify Alarm Is Not Active        fault_id=${fault_id}
    Sleep    300s

Change pMax parameter and verify If Changed
    ${params_to_change}=      commisioning_actions.Get Pmax Value From Bts        params=${change_cell_power}
    commisioning_actions.perform parameter recommisioning    params_to_change=${params_to_change}
    ...                                                      value_name=new_param_val
    Wait Until Keyword Succeeds    600 sec    15 sec    Verify Setup Of All Cells
    commisioning_actions.verify if parameters changed        params_to_change=${params_to_change}
    ...                                                      value_name=new_param_val
    commisioning_actions.perform parameter recommisioning    params_to_change=${params_to_change}
    ...                                                      value_name=act_param_val
    Wait Until Keyword Succeeds    600 sec    15 sec    Verify Setup Of All Cells
    commisioning_actions.verify if parameters changed        params_to_change=${params_to_change}
    ...                                                      value_name=act_param_val

Discovery With eCPRI Link After Commissioning
    [Arguments]    ${file_path}=/tmp        ${bts_file_name}=initial_configuration.xml
    ...            ${asir_file_name}=initial_configuration_asir.xml
    Download gNB Configuration File    local_dir=${file_path}       filename=${bts_file_name}
    ${asir_path}=    asir.get_current_scf_file    local_dir_path=${file_path}    file_name=${asir_file_name}
    Reset Configuration on gNB
    Sleep   600s
    Wait Until Keyword Succeeds    900sec    15sec    Verify gNB is Not Commissioned
    Perform Full Commisioning After Configuration Reset    scf_file_path=${file_path}/${bts_file_name}
    Sleep    600s
    asir.perform_asir_commissioning    scf_path=${asir_path}
    Wait Until Keyword Succeeds    900 sec    30 sec    Verify gNB is onAir
    Wait Until Keyword Succeeds    900 sec    30 sec    gnbcell.Verify All Cells Are Onair

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
    ...     timeout=600
    ...     should_be_reachable=${False}
    should be true    ${is_in_desired_state}
    ...     msg=Commissioning did not cause expected site reset

Configuration Reset Of The AsirWebEM
    [Arguments]    ${file_path}=/tmp        ${asir_file_name}=initial_configuration_asir.xml
    ${asir_path}=    asir.get_current_scf_file    local_dir_path=${file_path}    file_name=${asir_file_name}
    asir.Reset Configuration
    Verify Disabled Status
    Verify RU Status After Asir Configuration Reset
    asir.perform_asir_commissioning    scf_path=${asir_path}
    Wait Until Keyword Succeeds    900 sec    30 sec    Verify gNB is onAir
    Wait Until Keyword Succeeds    900 sec    30 sec    gnbcell.Verify All Cells Are Onair

Verify Disabled Status
    Wait Until Keyword Succeeds    5 min    15 sec    GnbRadio.wait_for_all_radio_unit_statuses    radio_type=asirmod
    ...                            operational_state=disabled

Verify RU Status After Asir Configuration Reset
    Wait Until Keyword Succeeds    5 min    15 sec    GnbRadio.verify_all_radio_units_are_online    radio_type=asirmod

Remove Cell And Restore Config
    [Arguments]    ${cell_id}      ${cell_group_id}=${cell_id}      ${file_path}=/tmp/commisionings
    ...            ${bts_file_name}=initial_configuration.xml       ${asir_file_name}=initial_configuration_asir.xml

    Download gNB Configuration File    local_dir=${file_path}       filename=${bts_file_name}
    ${asir_path}=    asir.get_current_scf_file    local_dir_path=${file_path}    file_name=${asir_file_name}
    ${params_to_change}=      commisioning_actions.get_runtime_parameter_value_from_bts
    ...                       params=${params_to_verify_pmax_after_cell_add_del}        field=act_param_val
    Remove Fr1 Cell And Nrcellgrp From Configuration      cell_id=${cell_id}   cell_group_id=${cell_group_id}
    Wait Until Keyword Succeeds    900 sec    30 sec    Verify gNB is onAir
    Wait Until Keyword Succeeds    900 sec    30 sec    gnbcell.Verify All Cells Are Onair
    ${params_to_change}=      commisioning_actions.get_runtime_parameter_value_from_bts
    ...                       params=${params_to_verify_pmax_after_cell_add_del}        field=new_param_val
    Perform Full Commisioning After Cell Remove    scf_file_path=${file_path}/${bts_file_name}
    logger.log_info_to_console    DEBUG1
#    Upload BTS Configuration via GUI        path=${file_path}/${bts_file_name}
    Sleep    500s
    asir.perform_asir_commissioning    scf_path=${asir_path}
#    local_resources.change bts configuration
    Wait Until Keyword Succeeds    900 sec    30 sec    Verify gNB is onAir
    Wait Until Keyword Succeeds    900 sec    30 sec    gnbcell.Verify All Cells Are Onair
    commisioning_actions.verify if parameters not changed    params_to_change=${params_to_change}
    Sleep    360s

Remove Dirs
    [Arguments]    @{directory_path}
    FOR    ${dir}    IN    @{directory_path}
        ${status}=    Run Keyword And Return Status    Directory Should Exist    ${dir}
        Run Keyword If    ${status}    Remove Directory    ${dir}    force=True
    END

Prepare BTS Before UUF UPGRADE Test
    [Arguments]     ${5G_SOURCE_SW}     ${path_to_download}=/home/ute/preparation_build
    local_resources.Prepare Bts before Test     sw_to_load=${5G_SOURCE_SW}      path_to_download=${path_to_download}
    Remove Dirs       ${path_to_download}
    gnb_du.Wait Unitl Connection Via Admin Is Possible      timeout=${600}
    local_resources.Perform Setup Reconfiguration
    Wait Until Keyword Succeeds    900 sec    30 sec    gnbcell.Verify All Cells Are Onair

Perform Full Commisioning After Cell Remove
    [Arguments]    ${scf_file_path}    ${bts_host}=${tl.gnbs[${0}].cu.oam_ssh_connection_details.addr}
    ${connection}=    connections.get_default_admin_connection_alias
    ${bts_id}=    hw_info.get_mrbts_id
    config_operations.perform_commissioning_in_separate_process
    ...     connection_host=${bts_host}
    ...     bts_id=${bts_id}
    ...     scf_file_path=${scf_file_path}
    ${is_in_desired_state}=    connections.wait_for_desired_site_state
    ...     url=https://${bts_host}
    ...     timeout=600
    ...     should_be_reachable=${True}
    should be true    ${is_in_desired_state}
    ...     msg=Commissioning did not cause expected site reset

Power Reset UE PC
    [Arguments]     ${host}     ${port}      ${alias}        ${model}
    IF    '${UEPC_RESET}' == 'True'
        logger.Log Info To Console      Reseting UE PC
        local_resources.power off on    host=${host}     port=${port}      alias=${alias}        model=${model}
        logger.Log Info To Console      Wait 60s
        BuiltIn.Sleep       60s
        Set Suite Variable    ${UEPC_RESET}     ${False}
    END
