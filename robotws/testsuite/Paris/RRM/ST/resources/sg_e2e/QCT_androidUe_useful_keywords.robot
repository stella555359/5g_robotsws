*** Settings ***
Documentation
...
...     AUTHOR (I&V-1):
...         Abderrahlamane Nezrouk

Library      OperatingSystem
Library      String
Library      Collections
Library      BuiltIn
Library      ute_ue
Library      taf.hw.pdu  WITH NAME   pdu

Library      ${CURDIR}/../custom_robot_keywords
Library      ${CURDIR}/../../../../resources/ST/python/LK_manager.py    WITH NAME    LK
Library      ${CURDIR}/../../../../resources/ST/python/LK_handler.py
Variables    ${CURDIR}/ue_messages_checker.py


*** Keywords ***
Activate Airplane Mode
    [Documentation]    This keyword
    [Arguments]        ${Ue_alias}
    ${err}    ${result}    run_adb_cmd_on_ue    alias=${Ue_alias}
    ...    cmd_line=settings${SPACE}put${SPACE}global${SPACE}airplane_mode_on${SPACE}1
    log       ${result}
    ${err}    ${result}    run_adb_cmd_on_ue    alias=${Ue_alias}
    ...    cmd_line=am${SPACE}broadcast${SPACE}-a${SPACE}android.intent.action.AIRPLANE_MODE
    log       ${result}

Deactivate Airplane Mode
    [Documentation]    This keyword
    [Arguments]        ${Ue_alias}
    ${err}    ${result}    run_adb_cmd_on_ue    alias=${Ue_alias}
    ...    cmd_line=settings${SPACE}put${SPACE}global${SPACE}airplane_mode_on${SPACE}0
    log       ${result}
    ${err}    ${result}    run_adb_cmd_on_ue    alias=${Ue_alias}
    ...    cmd_line=am${SPACE}broadcast${SPACE}-a${SPACE}android.intent.action.AIRPLANE_MODE
    log       ${result}

Enable Mobile data
    [Documentation]    This keyword
    [Arguments]        ${Ue_alias}
    # activation of the data
    ${err}    ${result}    run_adb_cmd_on_ue    alias=${Ue_alias}
    ...    cmd_line=svc${SPACE}data${SPACE}enable
    log       ${result}


Disable Mobile data
    [Documentation]    This keyword
    [Arguments]        ${Ue_alias}
    # activation of the data
    ${err}    ${result}    run_adb_cmd_on_ue    alias=${Ue_alias}
    ...    cmd_line=svc${SPACE}data${SPACE}disable
    log       ${result}

Start UeManager App
    [Documentation]    This keyword
    [Arguments]        ${Ue_alias}
    # activation of the data
    ${err}    ${result}    run_adb_cmd_on_ue    alias=${Ue_alias}
    ...    cmd_line=am${SPACE}start${SPACE}-n${SPACE}com.nokia.syve.uemanager.mobile/.gui.MainActivity
    log       ${result}

Prepar Ue for test
    [Documentation]    This keyword prepare Ue for test restar the Ue delete files in /sdcard/diag_logs/ and run UeManager service
    [Arguments]        ${Ue_alias}     ${power_reset}=False     ${ue_pdu_ip}=${None}    ${ue_pdu_port}=${None}    ${pdu_model}=${None}
    Run keyword if    '${power_reset}'=='True'
    ...               Power Reset UE     ue_pdu_ip=${ue_pdu_ip}    ue_pdu_port=${ue_pdu_port}    pdu_model=${pdu_model}
    ...    ELSE
    ...               Soft Ue reboot     ${Ue_alias}

    ${err}    ${result}    run_adb_cmd_noshell_on_ue    alias=${Ue_alias}    cmd_line=root
    log       ${result}
    Start UeManager App          ${Ue_alias}
    Deactivate Airplane Mode     ${Ue_alias}
    Enable Mobile data           ${Ue_alias}

Prepare lib and Ue
    [Documentation]    This keyword patches android qmdl file  and reserve Ue for test
    [Arguments]        ${Ue_alias}    ${power_reset}=False    ${ue_pdu_ip}=${None}    ${ue_pdu_port}=${None}    ${pdu_model}=${None}
    #prepar Ue for test
    Prepar Ue for test    ${Ue_alias}    ${power_reset}     ${ue_pdu_ip}     ${ue_pdu_port}     ${pdu_model}
    patch_qmdl_file
    ute_ue.Require Ue    ${Ue_alias}  capabilities=REAL_ANDROID_UE


Start RRC logs and Attach Ue
    [Documentation]    This keyword start RRC log and attch Ue
    [Arguments]        ${Ue_alias}    ${diag_cfg_path}=${None}    ${qmdl_size}=${None}

    ute_ue.Start RRC logs    ${Ue_alias}    diag_cfg_path=${diag_cfg_path}    qmdl_size=${qmdl_size}
    wait until keyword succeeds    10 sec     0 sec     Check Diag Log Process is Running     ${Ue_alias}
    # Run keyword and ignore error added to Attach Ue due to some SDX60
    ute_ue.Attach Ue    ${Ue_alias}   timeout=180
    # ${UE_IP}    Get Ue Info    UE_1    IP
    Enable Mobile data    ${Ue_alias}

Check Diag Log Process is Running
    [Arguments]        ${Ue_alias}
    ${err}    ${result}    run_adb_cmd_on_ue    alias=${Ue_alias}
    ...    cmd_line=ps${SPACE}-ef${SPACE}|${SPACE}grep${SPACE}mdlog
    @{output_list}=    string.Split string    ${result}
    @{list_items}=    Get Matches    ${output_list}    diag_mdlog
    Run Keyword If    @{list_items}==@{EMPTY}
    ...    Fail    diag log process did not start.

Stop RRC logs and collect
    [Documentation]    This keyword stop RRC log and attch Ue
    ...                ${Ue_alias}:   ue alias
    ...                ${techno}:    5G/LTE  Ue log technology to collect
    ...                ${filter}:     Ue logs filter
    ...                ${local_dir}:  path to wher to put Ue logs
    ...                ${timeout}:   Time out in seconde to give for logs file upload.
    [Arguments]        ${Ue_alias}    ${techno}=5G     ${filter_file_path}=${None}    ${local_dir}=${None}    ${timeout}=360
    #Reservation Of Qcat Licence
    #Prepare LKC
    #Get QCAT 5G Licence

    ${modem_chipset}=     get_ue_chipset_info     ${Ue_alias}
    ${mdm}    Set variable if
    ...            '${techno}'=='LTE' and '${modem_chipset}'=='SDX50'    ${None}
    ...            '${modem_chipset}'=='SDX60'                           ${None}
    ...             mdm
    Run Keyword and Ignore Error    ute_ue.Stop RRC logs   ${Ue_alias}   filter_file_path=${filter_file_path}   mdm=${mdm}
    ...                      timeout=${TIMEOUT}   transfer_log_files_from_uepc=false
    BuiltIn.Sleep    5
    ${Ue_log_path}=          get_decoded_qmdl_files_path   ${Ue_alias}   local_dir=${local_dir}    timeout=${TIMEOUT}

    #Release Of Qcat Licence
    #Release QCAT 5G Licence
	#Disconnect keeper
    [Return]       ${Ue_log_path}

Detach Ue Stop RRC logs and collect
    [Documentation]    This keyword detach Ue and stop logs traces and collect thems to VM
    [Arguments]        ${Ue_alias}    ${techno}=5G     ${filter_file_path}=${None}    ${local_dir}=${None}    ${timeout}=360

    Run keyword and ignore error    ute_ue.Detach Ue    ${Ue_alias}    timeout=30

    ${Ue_log_path}=    Stop RRC logs and collect    ${Ue_alias}    ${techno}     ${filter_file_path}    ${local_dir}    ${timeout}
    log      Ue log file path: <${Ue_log_path}>

    [Return]       ${Ue_log_path}

Perform Data Traffic
    [Documentation]    This keyword start one way UL or DL transfer
    [Arguments]        ${Ue_alias}    ${direction}=DL    ${duration}=40s    ${throughput}=520Mbits/sec
    ...                ${protocol}=udp    ${margin}=5
    ute_ue.Start Data Transfer
    ...     dt_name=DT_1
    ...     ue_alias=${Ue_alias}
    ...     direction=${direction}
    ...     duration=${duration}
    ...     throughput=${throughput}
    ...     protocol=${protocol}
    Sleep   10s
    ${error_margin}    Set variable    ${margin}%
    ute_ue.Check Data Transfer Is Alive    DT_1
    Run keyword     ute_ue.Await Data Transfer Finish      DT_1
    Run keyword     ute_ue.Verify Average Throughput With Deviation    DT_1     ${throughput}     ${error_margin}

Perform DLUL Data Traffic
    [Documentation]    This keyword start DL and UL transfer
    [Arguments]        ${Ue_alias}    ${duration}=20s    ${DL_Tput}=520Mbits/sec    ${UL_Tput}=110bits/sec    ${protocol}=udp    ${margin}=5
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
    ${error_margin}    Set variable    ${margin}%
    ute_ue.Check Data Transfer Is Alive    DT_1
    ute_ue.Check Data Transfer Is Alive    DT_2
    Run keyword     ute_ue.Await Data Transfer Finish      DT_1
    Run keyword     ute_ue.Await Data Transfer Finish      DT_2
    Run keyword     ute_ue.Verify Average Throughput With Deviation    DT_1    ${DL_Tput}     ${error_margin}
    Run keyword     ute_ue.Verify Average Throughput With Deviation    DT_2    ${UL_Tput}     ${error_margin}

Perform Data Traffic with Statictics
    [Documentation]    This keyword start DL and UL transfer
    [Arguments]        ${Ue_alias}    ${direction}=None    ${duration}=20s    ${DL_Tput}=520Mbits/sec    ${UL_Tput}=110bits/sec
    ...                ${protocol}=udp    ${margin}=5

    run keyword if     'DL' in '${direction}'
    ...    ute_ue.Start Data Transfer
    ...     dt_name=DT_1
    ...     ue_alias=${Ue_alias}
    ...     direction=DL
    ...     duration=${duration}
    ...     throughput=${DL_Tput}
    ...     protocol=${protocol}
    # Sleep   10s
    run keyword if     'UL' in '${direction}'
    ...    ute_ue.Start Data Transfer
    ...     dt_name=DT_2
    ...     ue_alias=${Ue_alias}
    ...     direction=UL
    ...     duration=${duration}
    ...     throughput=${UL_Tput}
    ...     protocol=${protocol}
    # Sleep   10s
    ${error_margin}    Set variable    ${margin}%
    run keyword if     DL in ${direction}
    ...    ute_ue.Check Data Transfer Is Alive    DT_1
    run keyword if     UL in ${direction}
    ...    ute_ue.Check Data Transfer Is Alive    DT_2

    ${stats_DL}=        Set Variable if    'DL' in '${direction}'
    ...     ute_ue.Get Data Transfer Statistics DL_TRF    DT_1
    ...     None
    ${stats_UL}=        Set Variable if    'UL' in '${direction}'
    ...     ute_ue.Get Data Transfer Statistics DL_TRF    DT_2
    ...     None

    [Return]    ${stats_DL}    ${stats_UL}

Perform Ue Attach Detach Traffic and Collect logs
    [Documentation]    This keyword:
    ...                Attach Ue, perform DL traffic, detach Ue and collects 5G Ue logs, X2 and L1L2 logs
    ...                Collects L1/L2 logs: mirroring is started and stop as close as possible of Ue attach and
    ...                detach to save disk space
    [Arguments]        ${Ue_alias}    ${direction}=DL    ${duration}=20s    ${DL_Tput}=800Mbits/sec    ${UL_Tput}=800Mbits/sec
    ...                ${protocol}=udp    ${margin}=5    ${techno}=5G    ${filter_file_path}=${None}    ${local_dir}=${None}
    [teardown]         Detach Ue Stop RRC logs and collect    ${Ue_alias}    techno=${techno}
    ...    filter_file_path=${filter_file_path}    local_dir=${local_dir}

    Start RRC logs and Attach Ue    ${Ue_alias}    qmdl_size=200

    Run keyword if    '${direction}'=='DLUL'
    ...                Perform DLUL Data Traffic    ${Ue_alias}    ${duration}    ${DL_Tput}    ${UL_Tput}    ${protocol}    ${margin}
    ...    ELSE IF     '${direction}'=='DL'
    ...                Perform Data Traffic         ${Ue_alias}    DL    ${duration}    ${DL_Tput}    ${protocol}    ${margin}
    ...    ELSE
    ...                Perform Data Traffic         ${Ue_alias}    UL    ${duration}    ${UL_Tput}    ${protocol}    ${margin}

Perform Ue Attach Detach Traffic with statictics and Collect logs
    [Documentation]    This keyword:
    ...                Attach Ue, perform DL traffic, detach Ue and collects 5G Ue logs, X2 and L1L2 logs
    ...                Collects L1/L2 logs: mirroring is started and stop as close as possible of Ue attach and
    ...                detach to save disk space
    [Arguments]        ${Ue_alias}    ${direction}=DL    ${duration}=20s    ${DL_Tput}=800Mbits/sec    ${UL_Tput}=800Mbits/sec
    ...                ${protocol}=udp    ${margin}=5    ${techno}=5G    ${filter_file_path}=${None}    ${local_dir}=${None}
    [teardown]         Detach Ue Stop RRC logs and collect    ${Ue_alias}    techno=${techno}
    ...    filter_file_path=${filter_file_path}    local_dir=${local_dir}

    Start RRC logs and Attach Ue    ${Ue_alias}    qmdl_size=200

    ${stats_DL}    ${stats_UL}    Perform Data Traffic with Statictics    ${Ue_alias}    ${direction}    ${duration}
    ...                              ${DL_Tput}    ${UL_Tput}    ${protocol}    ${margin}
    [Return]    ${stats_DL}    ${stats_UL}

Get Ue Current Time
    [Documentation]    This keyword return Ue current time
    [Arguments]        ${Ue_alias}

    # bypass robocop
    ${Ue_alias}    Set variable    ${Ue_alias}
    ${err}    ${result}    run_adb_cmd_on_ue    alias=UE_1    cmd_line=shell date +%Y-%m-%d_%R:%S%z
    ${err}=         set variable   ${err}
    ${result}=      set variable   ${result}
    [Return]    ${err}    ${result}

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

Soft Ue reboot
    [Documentation]  Soft Ue reset
    [Arguments]        ${Ue_alias}
    ${err}    ${result}    run_adb_cmd_on_ue    alias=${Ue_alias}    cmd_line=reboot
    log       ${err}
    log        ${result}
    BuiltIn.Sleep      20s

Check Rach procedure is successful
    [Documentation]    This keywords checks in collected traces if Rach procedure is successfull
    Is Ue Log Message Contain    NR5G:MAC_RACH_Attempt:    ${NR5G_MAC_RACH_Attempt_SUCCESS}

Is rrcReconfiguration with Mimo4x4
    [Documentation]    This keywords checks rrcReconfiguration is configured with Mimo4x4
    Is Ue Log Message Contain    LTE:RRC_OTA:RRCConnectionReconfiguration    ${mimoMode4x4}

Reservation Of Qcat Licence
    Prepare LK
    Get QCAT 5G Licence

Release Of Qcat Licence
    Release QCAT 5G Licence
	# Disconnect keeper
