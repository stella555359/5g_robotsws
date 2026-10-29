*** Settings ***
Documentation    todo

Library      OperatingSystem
Library      String
Library      Collections
Library      BuiltIn
Library      ute_ue
Library      taf.transport.ssh                           WITH NAME   ssh
Library      taf.hw.pdu  WITH NAME   pdu

Resource     ${CURDIR}/logs.robot
Resource     ${CURDIR}/configuration.robot
Resource     ${CURDIR}/basics.robot
Library      ${CURDIR}/../custom_robot_keywords
Variables    ${CURDIR}/ue_messages_checker.py
Variables    ${CURDIR}/filter_options.py

*** Variables ***
${filter_file_path_SDX50}         ${CURDIR}${/}filter_SDX50.txt
${filter_file_path_SDX55}         ${CURDIR}${/}filter_SDX55.txt
${TIMEOUT_NO_TRAFFIC}             90
${TIMEOUT_TRAFFIC}                360
${mdm}                      mdm
${UEPC_DECODED_QMDL_FILES}
${output}
${chipset_mode}
${L1L2_tcpdump_file}
${X2_tcpdump_file}



*** Keywords ***

Prepar Ue for test
    [Documentation]    This keyword prepare Ue for test restar the Ue delete files in /sdcard/diag_logs/ and run UeManager service
    [Arguments]        ${Ue_alias}

    # bypass robocop
    ${Ue_alias}    Set variable    ${Ue_alias}
    # Power Reset UE     ue_pdu_ip=${ue_pdu_ip}    ue_pdu_port=${ue_pdu_port}    pdu_model=${pdu_model}
    ${err}    ${result}    run_adb_cmd_on_ue    alias=UE_1    cmd_line=rm${SPACE}-rf${SPACE}/sdcard/diag_logs/*
    ${err}    ${result}    run_adb_cmd_on_ue    alias=UE_1    cmd_line=reboot
    sleep      80s
    ${err}    ${result}    run_adb_cmd_noshell_on_ue    alias=UE_1    cmd_line=root
    ${err}    ${result}    run_adb_cmd_on_ue    alias=UE_1
    ...    cmd_line=am${SPACE}start${SPACE}-n${SPACE}com.nokia.syve.uemanager.mobile/.gui.MainActivity

Prepare lib and Ue
    [Documentation]    This keyword patches android library to collect 5G Ue logs and reserve the Ue
    [Arguments]        ${Ue_alias}
    Prepar Ue for test    ${Ue_alias}
    patch_qmdl_file
    ute_ue.Require Ue    ${Ue_alias}  capabilities=REAL_ANDROID_UE
    ute_ue.Attach Ue     ${Ue_alias}
    sleep                10s
    ute_ue.Detach Ue     ${Ue_alias}
    sleep                10s


Get Ue chipset mode
    [Documentation]    This keyword reads chipset_NR5G_mode from ue configuration file

    ${ue_config_file}=    Set variable    %{ABSTRACT_LIB_CONFIG}
    import variables    ${ue_config_file}

    log    chipset_mode_from file:${UE_POOLS.AndroidUePool.inline_config.UE_1.CONSTRUCTOR_PARAMETERS.configuration.chipset_NR5G_mode}
    ${chipset_NR5G_mode}=    set variable    ${UE_POOLS.AndroidUePool.inline_config.UE_1.CONSTRUCTOR_PARAMETERS.configuration.chipset_NR5G_mode}

    Set test variable    ${chipset_mode}    ${chipset_NR5G_mode}


Is Ue Attached On NR5G
    [Documentation]    This keywords checks is Ue is attached on 5G in 5G Ue logs
    [Arguments]        ${Ue_alias}

    Get Ue chipset mode

    Perform Ue Attach Detach and Collect Traces     ${Ue_alias}    5G
    Is Ue Log Message Contain    NR5G:ML1_Searcher_ACQ_Config_And_Response:    ${NR5G_ML1_ACQ_SUCCESS}


Check Rach procedure is successful
    [Documentation]    This keywords checks in collected traces if Rach procedure is successfull
    [Arguments]        ${Ue_alias}

    # bypass robocop
    ${Ue_alias}    Set variable    ${Ue_alias}
    Is Ue Log Message Contain    NR5G:MAC_RACH_Attempt:    ${NR5G_MAC_RACH_Attempt_SUCCESS}


Is RRC Reconfiguration Set With Mimo4x4
    [Documentation]    This keyword checks RRC reconfiguration message in 4G Ue logs
    [Arguments]        ${Ue_alias}

    Get Ue chipset mode

    Perform Ue Attach Detach and Collect Traces    ${Ue_alias}    4G
    Is Ue Log Message Contain    LTE:RRC_OTA:RRCConnectionReconfiguration    ${mimoMode4x4}


Perform Ue Attach Detach and Collect Traces
    [Documentation]    This keyword:
    ...                Patches Ue related libraries
    ...                Attach and detach Ue and collects Ue 4G or 5G logs
    ...                Collects L1/L2 logs: mirroring is started and stop as close as possible of Ue attach and
    ...                detach to save disk space
    [Arguments]        ${Ue_alias}    ${radio_gen}
    [teardown]         Detach Ue and stop all traces    ${Ue_alias}    ${radio_gen}

    ute_ue.Start RRC Logs    ${Ue_alias}

    # Start gNB traces. Commands must be separated by some seconds sleep otherwise the first one is not correctly executed.
    configuration.Create ssh
    logs.Start X2 Traces Classical    AttachDetachUe
    BuiltIn.Sleep    10
    logs.Start Mirroring Traces on Asik    connection=asikFhCnx

    # attach Ue, sleep for 20s and detach Ue. 20s are necessary to ensure attach is correctly done
    ute_ue.Attach Ue    ${Ue_alias}
    BuiltIn.Sleep    20


Detach Ue and stop all traces
    [Documentation]    This keyword detach Ue and stops all traces
    [arguments]        ${Ue_alias}    ${radio_gen}

    Run keyword and ignore error    ute_ue.Detach Ue    ${Ue_alias}

    Run keyword and ignore error    logs.Stop X2 Traces Classical
	BuiltIn.Sleep    5s
    Run keyword and ignore error    logs.Stop and Collect Mirroring Traces on Asik    connection=asikFhCnx
	BuiltIn.Sleep    5s

    ${filter_file_path_SDX55}=     Get Qcat filter path
    Run keyword if    '${radio_gen}'=='4G' and '${chipset_mode}'=='SDX50'
    ...    Run keyword and ignore error    ute_ue.Stop RRC logs   ${Ue_alias}   timeout=${TIMEOUT_NO_TRAFFIC}
    Run keyword if    '${radio_gen}'=='5G' and '${chipset_mode}'=='SDX50'
    ...    Run keyword and ignore error    ute_ue.Stop RRC logs   ${Ue_alias}   filter_file_path=${filter_file_path_SDX50}
    ...                                    mdm=${mdm}   timeout=${TIMEOUT_NO_TRAFFIC}
    Run keyword if    '${radio_gen}'=='5G' and '${chipset_mode}'=='SDX55'
    ...    Run keyword and ignore error    ute_ue.Stop RRC logs   ${Ue_alias}   filter_file_path=${filter_file_path_SDX55}
    ...                                    mdm=${mdm}   timeout=${TIMEOUT_NO_TRAFFIC}

    BuiltIn.Sleep    5
    Run keyword and ignore error    Collect Ue Logs To VM    ${Ue_alias}
    configuration.Close Connections ssh

Perform Ue Attach Detach Traffic and Collect Traces
    [Documentation]    This keyword:
    ...                Attach Ue, perform DL traffic, detach Ue and collects 5G Ue logs, X2 and L1L2 logs
    ...                Collects L1/L2 logs: mirroring is started and stop as close as possible of Ue attach and
    ...                detach to save disk space
    [Arguments]        ${Ue_alias}    ${direction}=DL    ${duration}=20s    ${DL_Tput}=800Mbits/sec    ${UL_Tput}=800Mbits/sec
    ...                ${protocol}=udp    ${margin}=5
    [teardown]         Detach Ue with traffic and stop all traces    Ue_alias=${Ue_alias}   L1L2_filtering=on

    Get Ue chipset mode
    log    chipset_mode:${chipset_mode}

    # configuration.Create ssh
    # logs.Start X2 Traces Classical    AttachDetachUe
    # BuiltIn.Sleep    10s

    # logs.Start Mirroring Traces on Asik    connection=asikFhCnx    number_of_files=1    capturing_time=0
    # ...      file_size_mbytes=120    filtering=on    filter=${filter_5G19B_2}
    # BuiltIn.Sleep     10s
    logs.Start Mirroring Traces on Asik New    connection=abilXeonBCnx
    ute_ue.Start RRC Logs    ${Ue_alias}
    # ute_ue.Detach Ue    ${Ue_alias}
    ute_ue.Attach Ue    ${Ue_alias}
    BuiltIn.Sleep    5s
    Run keyword if    '${direction}'=='DL'
    ...                Perform DL Data Traffic    ${Ue_alias}    ${duration}    ${DL_Tput}    ${protocol}    ${margin}
    Run keyword if    '${direction}'=='UL'
    ...                Perform UL Data Traffic    ${Ue_alias}    ${duration}    ${UL_Tput}    ${protocol}    ${margin}
    Run keyword if    '${direction}'=='DLUL'
    ...                Perform DLUL Data Traffic    ${Ue_alias}    ${duration}    ${DL_Tput}    ${UL_Tput}    ${protocol}    ${margin}


Perform DL Data Traffic
    [Documentation]    This keywords starts DL transfer
    [Arguments]        ${Ue_alias}    ${duration}=20s    ${DL_Tput}=800Mbits/sec    ${protocol}=udp    ${margin}=5

    ute_ue.Start Data Transfer
    ...     dt_name=DT_1
    ...     ue_alias=${Ue_alias}
    ...     direction=DL
    ...     duration=${duration}
    ...     throughput=${DL_Tput}
    ...     protocol=${protocol}
    Sleep   10s
    ute_ue.Check Data Transfer Is Alive    DT_1
    ${error_margin}    Catenate     SEPARATOR=    ${margin}    %
    Run keyword    ute_ue.Await Data Transfer Finish      DT_1
    Run keyword    ute_ue.Verify Average Throughput With Deviation    DT_1    ${DL_Tput}    ${error_margin}

Perform UL Data Traffic
    [Documentation]    This keywords starts UL transfer
    [Arguments]        ${Ue_alias}    ${duration}=20s    ${UL_Tput}=800Mbits/sec    ${protocol}=udp    ${margin}=5
    ute_ue.Start Data Transfer
    ...     dt_name=DT_1
    ...     ue_alias=${Ue_alias}
    ...     direction=UL
    ...     duration=${duration}
    ...     throughput=${UL_Tput}
    ...     protocol=${protocol}
    Sleep   10s
    ute_ue.Check Data Transfer Is Alive    DT_1
    ${error_margin}    Catenate     SEPARATOR=    ${margin}    %
    Run keyword     ute_ue.Await Data Transfer Finish      DT_1
    Run keyword     ute_ue.Verify Average Throughput With Deviation    DT_1    ${UL_Tput}     ${error_margin}


Perform DLUL Data Traffic
    [Documentation]    This keywords starts DL and UL transfer
    [Arguments]        ${Ue_alias}    ${duration}=20s    ${DL_Tput}=800Mbits/sec    ${UL_Tput}=800Mbits/sec    ${protocol}=udp    ${margin}=5
    ute_ue.Start Data Transfer
    ...     dt_name=DT_1
    ...     ue_alias=${Ue_alias}
    ...     direction=DL
    ...     duration=${duration}
    ...     throughput=${DL_Tput}
    ...     protocol=${protocol}
    Sleep   10s
    ute_ue.Start Data Transfer
    ...     dt_name=DT_2
    ...     ue_alias=${Ue_alias}
    ...     direction=UL
    ...     duration=${duration}
    ...     throughput=${UL_Tput}
    ...     protocol=${protocol}
    Sleep   10s
    ${error_margin}    Catenate     SEPARATOR=    ${margin}    %
    ute_ue.Check Data Transfer Is Alive    DT_1
    ute_ue.Check Data Transfer Is Alive    DT_2
    Run keyword     ute_ue.Await Data Transfer Finish      DT_1
    Run keyword     ute_ue.Await Data Transfer Finish      DT_2
    Run keyword     ute_ue.Verify Average Throughput With Deviation    DT_1    ${DL_Tput}     ${error_margin}
    Run keyword     ute_ue.Verify Average Throughput With Deviation    DT_2    ${UL_Tput}     ${error_margin}

Detach Ue with traffic and stop all traces
    [Documentation]    This keyword detach Ue and stops all traces
    [arguments]        ${Ue_alias}    ${L1L2_filtering}=off

    # bypass robocop
    ${L1L2_filtering}    Set variable    ${L1L2_filtering}
    Run keyword and ignore error    ute_ue.Detach Ue    ${Ue_alias}

    # Run keyword and ignore error    logs.Stop X2 Traces Classical
	# BuiltIn.Sleep    5

    # Run keyword and ignore error    logs.Stop and Collect Mirroring Traces on Asik    connection=asikFhCnx
    # ...    filtering=${L1L2_filtering}
    logs.Stop and Collect Mirroring Traces on Asik New      connection=abilXeonBCnx
    BuiltIn.Sleep    5s

    Log    ${chipset_mode}
    Run keyword if    '${chipset_mode}'=='SDX50'
    ...    Run keyword and ignore error    ute_ue.Stop RRC logs   ${Ue_alias}   filter_file_path=${filter_file_path_SDX50}
    ...                                    mdm=${mdm}   timeout=${TIMEOUT_TRAFFIC}
    Run keyword if    '${chipset_mode}'=='SDX55'
    ...    Run keyword and ignore error    ute_ue.Stop RRC logs   ${Ue_alias}   filter_file_path=${filter_file_path_SDX55}
    ...                                    mdm=${mdm}   timeout=${TIMEOUT_TRAFFIC}
    BuiltIn.Sleep    5s

    Run keyword and ignore error    Collect Ue Logs To VM    ${Ue_alias}

    configuration.Close Connections ssh

Perform Ue Preparation and Attach
    [Documentation]    This keyword:
    ...                Attach Ue and start collecting 5G/4G Ue logs.
    [arguments]        ${Ue_alias}

    Prepare lib and Ue    ${Ue_alias}
    ute_ue.Attach Ue    ${Ue_alias}
    BuiltIn.Sleep    5
    ${err}    ${result}    run_adb_cmd_on_ue    alias=UE_1    cmd_line=root
    log    ${err}
    log    ${result}

Perform Stop Ue Traces and and collect Log To Vm
    [Documentation]    This keyword detach Ue and stops all traces
    [arguments]        ${Ue_alias}

    ${chipset_mode}=     get_ue_chipset_info     ${Ue_alias}

    Run keyword if    '${chipset_mode}'=='SDX50'
    ...    Run keyword and ignore error    ute_ue.Stop RRC logs   ${Ue_alias}   filter_file_path=${filter_file_path_SDX50}
    ...                                    mdm=${mdm}   timeout=${TIMEOUT_TRAFFIC}
    Run keyword if    '${chipset_mode}'=='SDX55'
    ...    Run keyword and ignore error    ute_ue.Stop RRC logs   ${Ue_alias}   filter_file_path=${filter_file_path_SDX55}
    ...                                    mdm=${mdm}   timeout=${TIMEOUT_TRAFFIC}
    BuiltIn.Sleep    5
    Run keyword and ignore error    Collect Ue Logs To VM    ${Ue_alias}

Collect Ue Logs To VM
    [Documentation]    This keyword collects the Ue log from PC mobile
    [Arguments]        ${Ue_alias}    ${directory}=10
    # Collect the decoded qmdl absolute files path
    ${UEPC_DECODED_QMDL_FILES_5G}=   Get Decoded Qmdl Files Path   ${Ue_alias}    ${directory}
    Set test variable    ${UEPC_DECODED_QMDL_FILES}    ${UEPC_DECODED_QMDL_FILES_5G}

Get Ue Current Time
    [Documentation]    This keyword return Ue current time
    [Arguments]        ${Ue_alias}

    # bypass robocop
    ${Ue_alias}    Set variable    ${Ue_alias}
    ${err}    ${result}    run_adb_cmd_on_ue    alias=UE_1    cmd_line=shell date +%Y-%m-%d_%R:%S%z
    ${err}=         set variable   ${err}
    ${result}=      set variable   ${result}
    [Return]    ${err}    ${result}

Get Qcat filter path
    [Documentation]    This keyword return the filter file path corresponding to the running ${SUITE NAME}
    ${suite_number}=    Get Regexp Matches    ${TEST NAME}    _\\d+_
    ${suite_number} =         Remove String    ${suite_number[0]}    _
    Return from keyword if    '${suite_number}'== '050'    ${CURDIR}${/}filter_Only_0xB88A.txt
    Return from keyword if    '${suite_number}'== '048'    ${CURDIR}${/}filter_Only_0xB88A.txt
    Return from keyword if    '${suite_number}'== '049'    ${CURDIR}${/}filter_Only_0xB88A.txt
    [Return]     ${CURDIR}${/}filter_SDX55.txt

Power Reset UE
    [Documentation]  Power reset for UE
    ...     :param ue_pdu_ip: the PB ip address to power cycle the ue.
    ...     :param ue_pdu_port: the PB port number that connected with ue
    ...     :pdu_model   FACOM/atenpdu
    [Arguments]  ${ue_pdu_ip}   ${ue_pdu_port}    ${pdu_model}
    pdu.setup_pdu    model=${pdu_model}
    ...              host=${ue_pdu_ip}
    ...              alias=pdu_devices_connect
    pdu.power_off    port=${ue_pdu_port}    pdu_device=pdu_devices_connect
    sleep    10s
    pdu.power_on    port=${ue_pdu_port}    pdu_device=pdu_devices_connect
    sleep    20s
    ${pdu_status}=    pdu.get_port_status    port=${ue_pdu_port}
    ...                                      pdu_device=pdu_devices_connect
    Should contain    ${pdu_status}      on
