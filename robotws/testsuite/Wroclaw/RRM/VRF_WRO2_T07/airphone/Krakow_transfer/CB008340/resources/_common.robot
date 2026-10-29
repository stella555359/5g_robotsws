*** Settings ***
Documentation
...    :copyright: Nokia
...    :contact: I_EXT_MN_RAN_VRF_WRO2_7_T03@internal.nsn.com

Library    OperatingSystem
Library    Collections
Library    String
Library    Process
Library    ../../../../resources/PCMD/verifier_msg_for_pcmd.py
Library    ute_wtssim
Library    ute_fsmaccess
Library    ute_syslog
Library    ute_tshark
Library    ta5g_egate
Library    ta5g_iphy
Library    ta5g_ue_mobility
Library    ta5g_iperf_traffic
Library    ta5g_enb
Library    ta5g_commissioning
Library    ta5g_throughput
Library    ta_pcmd
Library    ta_messaging
Library    taf.transport.ssh           WITH NAME    ssh
Library    taf.sbts.oam.coam.admin     WITH NAME    admin
Library    taf.wts.runner    WITH NAME    wtsrunner
Library    taf.config.wts              WITH NAME    wtscfg
Library    taf.wts.config
Library    taf.config.scf    WITH NAME   scf
Library    DateTime

Resource    variables.robot

*** Variables ***
${WTS_CONFIG}                       /opt/wts/latest/basic_setup.cfg
${LOG_DIR}                          ${OUTPUT DIR}/Logs/
${WTS_DIR}                          ${LOG_DIR}/WTS/
${WTS_CONFIG_NEW}                   ${WTS_DIR}/basic_setup_mod.cfg
${WTS_LATEST_DIR}                   /opt/wts/latest

*** Keywords ***
Send Delta Commissioning and Reach OnAir
    [Arguments]    ${json_file_path}
    ...            ${wts_config_path}=${WTS_CONFIG}
    Send Delta Commissioning    ${json_file_path}
    Check Radios Availability
    Create Directory    ${WTS_DIR}
    Change Edaemon Port    ${wts_config_path}
    Configure UTE ETH3
    Reach Onair
    ...    lua_cfg=${WTS_CONFIG_NEW}
    ...    logs_dirpath=${WTS_DIR}
    ...    align_tac_values=False

Send HO Delta Commissioning
    [Arguments]    ${JSON_FILE}=delta_pcmd.json
    admin.Setup Admin
    ${sw_ver}    admin.Get SW Release Name
    admin.Teardown Admin
    Send Delta Commissioning    ${CURDIR}/${sw_ver}/${JSON_FILE}


Change Edaemon Port
    [Arguments]    ${wts_config_path}
    wtscfg.Load Wts Cfg    ${wts_config_path}
    wtscfg.Modify    set DAEMON_PORT="22222"    DAEMON_PORT="30000"
    wtscfg.Save Wts Cfg    ${WTS_CONFIG_NEW}

Configure UTE ETH3
    Run    sudo ip addr add 10.0.1.131/24 dev eth3
    Run    sudo ip addr add 10.0.1.132/24 dev eth3
    Run    sudo ip addr add 10.0.1.133/24 dev eth3
    Run    sudo ip addr add 10.0.1.134/24 dev eth3
    Run    sudo ip addr add 10.0.1.135/24 dev eth3
    Run    sudo ip addr add 10.0.1.136/24 dev eth3
    Run    sudo ip addr add 10.0.1.99/24 dev eth3
    Run    sudo ip addr add 10.0.1.121/24 dev eth3
    Run    sudo ip addr add 10.0.1.137/24 dev eth3

Set Test Start Time
    ${test_start_time}    Get Time    epoch
    Set Suite Variable    ${test_start_time}

NSA Attach UE
    [Arguments]    ${ue_id}=11
    Attach UE to ENB    ue_id=${ue_id}

NSA Detach UE
    [Arguments]    ${ue_id}=11
    Detach UE    ue_id=${ue_id}

NSA Establish DC
    [Arguments]    ${ue_id}=11
    Start GNB Addition Procedure
    ...    ue=${ue_id}
    ...    target_cells=1
    ...    bearer=2
    ...    dc_type=split_scg
    ...    timeout=10s

NSA Intracell HO UE
    [Arguments]    ${ue_id}=11
    Perform Intracell Handover And Wait For Confirmation    ue_id=${ue_id}    timeout=10s

Collect Snapshot to Logs
    Log to Console    Collecting Snapshot
    admin.Setup admin
    admin.Get Snapshot
    ...    target_file_name=${LOG_DIR}/Snapshot/Snapshot.zip
    admin.Teardown admin

Start GNB Syslog
    [Arguments]    ${log_dir}=${LOG_DIR}/GNB Syslog/
    Log to Console    Starting GNB Syslog Collection
    ute_syslog.Start Syslog
    ...    log_dir=${log_dir}
    ...    log_name=GNB_syslog
    ...    ip=192.168.255.126
    ...    alias=GNB_syslog

Stop And Collect GNB Syslog
    Log to Console    Stopping GNB Syslog Collection
    ute_syslog.Collect Syslog Results    alias=GNB_syslog

Start gNB tshark On eth3
    [Arguments]    ${file_name}=pcmd_eth3    ${log_dir}=${OUTPUT DIR}
    Setup tshark
    ...   alias=tshark_testcase
    ...   log_name=${file_name}.pcap
    ...   interface=eth3
    ...   log_dir=${log_dir}
    Start capturing
    ...   alias=tshark_testcase
    ...   log_name=${file_name}.pcap
    ...   log_dir=${log_dir}

Stop gNB tshark On eth3
    Stop capturing
    ...   alias=tshark_testcase
    Teardown tshark
    ...   alias=tshark_testcase

Configure UTE ETH3 For inter gNB HO
    Run    sudo ip addr add 10.44.76.27/24 dev eth3
    Run    sudo ip addr add 10.44.76.28/24 dev eth3

Configure Interfaces For Inter-RAT HO
    Run    sudo ip addr add 10.0.1.111/24 dev eth3
    Run    sudo ip addr add 10.0.1.5/24 dev eth3
    Run    sudo ip addr add 10.0.1.110/24 dev eth3
    Run    sudo ip addr add 10.0.2.2/24 dev eth4

Change wts file for inter gNB HO
    [Arguments]    ${WTS_CONFIG_MODIFIED}=/opt/wts/latest/modified_basic_setup.cfg
    wtscfg.Load Wts Cfg    ${WTS_CONFIG}
    wtscfg.Insert    set GNB2_ID="3"    after   set DAEMON_PORT="22222"
    wtscfg.Insert    set GNB2_NG_ADDR="10.44.76.27"    after   set GNB2_ID="3"
    wtscfg.Insert    set GNB2_XN_ADDR="10.44.76.28"    after   set GNB2_NG_ADDR="10.44.76.27"
    wtscfg.Insert    set GNB_XN_ADDR="10.0.1.2"    after   set GNB2_XN_ADDR="10.44.76.28"
    wtscfg.Insert    set_gnb id=3 type=simulated plmn=311:489 gnb_id=0x2 ng=$GNB2_NG_ADDR x2_peers=none xn=$GNB2_XN_ADDR
    ...              after    set_cell id=2 gnb=2
    wtscfg.Modify    set_gnb id=3 type=simulated     nssai=0x1:0xd143a5 daemon=$SERVER_IP:$DAEMON_PORT amf=1
    wtscfg.Insert    gnb_param id=3 xn_listening_socket=1 send_xn_setup=off    after    set_gnb id=3
    wtscfg.Insert    set_cell id=1 gnb=3 tac=0 nrci=0x01 pci=17:1 tdd_cell=on proxy=$SERVER_IP:$DAEMON_PORT nr_arfcn=636666:636666 gscn=7880
    ...              after    gnb_param id=3
    wtscfg.Modify    set_gnb id=2 type=external     xn=$GNB_XN_ADDR
    wtscfg.Modify    set_gnb id=2 type=external     gnb_id=0x01
    wtscfg.Modify   set_cell id=1 gnb=2    gscn=7880
    wtscfg.Modify   set_cell id=2 gnb=2    gscn=7880
    wtscfg.Save Wts Cfg    ${WTS_CONFIG_MODIFIED}

Change WTS File For Cell PLMN Change
    [Arguments]    ${WTS_CONFIG_MODIFIED}=/opt/wts/latest/modified_basic_setup.cfg
    wtscfg.Load Wts Cfg    ${WTS_CONFIG}
    wtscfg.Modify    set_amf_region id=1       plmn=311:489,311:402
    wtscfg.Modify    set_cell id=2 gnb=2       tac=100
    wtscfg.Modify    set_ue simulated id=2     mode=nr enb=2 cell=1
    wtscfg.Delete    nwslice_set id=1
    wtscfg.Insert
    ...    nwslice_set id=1 qos_flows=1,2,3 qos_rules=1,2 snssai=0x01:0xD143A5 default=on ue=all amf_region_id=1 plmn_list=311:489,311:402
    ...    before    set_pdu_gateway id=1
    wtscfg.Save Wts Cfg    ${WTS_CONFIG_MODIFIED}

Prepare Ue For Inter gNB HO
    ${cmd1}    Set Variable
    ...    ue_history_information_list_add_ngran id=1 gnb_id=3 cell_type=large nrcgi=311:489|0x01 time_ue_stayed_in_cell=98
    ${cmd2}    Set Variable
    ...    ue_history_information_list_add_ngran id=1 gnb_id=2 cell_type=large nrcgi=311:489|0x01 time_ue_stayed_in_cell=97
    ${cmd3}    Set Variable    ue_history_information_list id=1 action=commit
    ${cmd4}    Set Variable    ue_enb_param id=1 ue_history_list=1
    ute_wtssim.execute_egate_command    cmd=${cmd1};${cmd2};${cmd3};${cmd4}

Trigger Inter gNB HO
    [Arguments]    ${cell_id}=52    ${ue_id}=1
    ${meas_id}    Get Measurement ID    event_type=EventA3    ue_id=${ue_id}
    ${pattern}    Set Variable    Received PATH SWITCH REQUEST
    ${cmd}    Set Variable
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A3 srsrp_nr=19 srsrq_nr=10 phycell_id=${cell_id} nrsrp_nr=85 nrsrq_nr=31
    ute_wtssim.execute_egate_command    cmd=${cmd}    pass_regexp=${pattern}

Trigger Inter-gNB NG-based HO
    [Arguments]    ${cell_id}=52    ${ue_id}=1
    ${meas_id}    Get Measurement ID    event_type=EventA5    ue_id=${ue_id}
    ute_wtssim.execute egate command    cmd=gnb_param id=3 sa_ho=ng_based
    ute_wtssim.execute_egate_command
    ...    cmd=ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A5 srsrp_nr=18 phycell_id=${cell_id} nrsrp_nr=85
    ...    pass_regexp=Inter-eNB handover.*performed

Trigger Inter-gNB NG-based HO Interrupted By RRC Reestablishment
    ute_wtssim.execute_egate_command
    ...    cmd=ue_nr_rrc_reconf_param id=1 if_contains=reconfiguration_with_sync action=reestablish gnb=2 cell=1
    Trigger Inter-gNB NG-based HO
    Sleep    10s    reason=Wait for ue context release complete

Trigger Inter-RAT HO To LTE
    ${meas_id}    Get Measurement ID    EventA2
    ute_wtssim.execute_egate_command
    ...    cmd=ue_measurement_send_nr id=1 meas_id=${meas_id} event=A2 phycell_id=11 nrsrp_nr=19 nrsrq_nr=17
    Sleep    2s    reason=Wait before sending next measurement
    ${meas_id}    Get Measurement ID    event_type=EventB2    rat=EUTRA
    ute_wtssim.execute_egate_command
    ...    cmd=ue_measurement_send_nr id=1 meas_id=${meas_id} event=B2 phycell_id=11 nrsrp_nr=19 nrsrq_nr=17
    ...    pass_regexp=IRAT Handover from NR to EUTRA completed

Trigger Inter-RAT HO To 5G
    ute_wtssim.execute_egate_command
    ...   cmd=handover_gnb_trigger_inter_rat_to_5g ue=1 target_gnb=2 target_cell=1 plmn=311:489
    ...   pass_regexp=Inter-eNB handover from ENB-3.1 to EXT_ENB-2.1 performed
    Sleep    5s    reason=Wait for inter-RAT HO to be completed properly

Setup Devices Aliases
    Create ues alias    alias=UE   id_type=wts_5g
    Create GNB device with alias 'gNB2' identified by ip=10.0.1.2
    Enable Internal Mirroring For Alias    gNB2

Get Measurement ID
    [Arguments]    ${event_type}=EventA3    ${ue_id}=1    ${rat}=NR
    ${measurements}    Execute Egate Command And Wait For Data
    ...    cmd=ue_meas_cfg_disp id=${ue_id}
    ...    pass_regexp=${event_type}
    ${matching_lines}    Get Lines Matching Regexp  ${measurements}  ^[0-9].*${rat}.*${event_type}.*
    ${first_line}    Get Line  ${matching_lines}  0
    @{words}    Split String  ${first_line}
    [Return]  ${words}[0]

Set TrafficType To Internal
    [Arguments]    ${ue_id}=1
    ute_wtssim.execute_egate_command    cmd=set_pdu_param ue=${ue_id} pdu=${ue_id} trf_type=internal

Start Internal Traffic
    [Arguments]    ${ue_id}=1    ${qfi}=1
    Log to Console    Starting Internal DL Traffic
    ute_wtssim.execute_egate_command
    ...   cmd=trf_data_start ue\=${ue_id} pdu\=${ue_id} qfi\=${qfi} dir\=dl mbps\=5
    ...   pass_regexp=Started Downlink Internal traffic over UDP on Ue:1 UpfId:1 Pdu:1 Qfi:1 TrfId:1
    Log to Console    Starting Internal UL Traffic
    ute_wtssim.execute_egate_command
    ...   cmd=trf_data_start ue\=${ue_id} pdu\=${ue_id} qfi\=${qfi} dir\=ul mbps\=5
    ...   pass_regexp=Started Uplink Internal traffic over UDP on Ue:1 UecId:1 Pdu:1 Qfi:1 TrfId:1

Stop All Internal Traffic
    [Arguments]    ${ue_id}=1
    Log to Console    Stopping All Internal Traffic
    ute_wtssim.execute_egate_command
    ...   cmd=trf_data_stop ue\=${ue_id} pdu\=${ue_id}
    ...   pass_regexp=Traffic was stopped

Start NSA Traffic
    Log to Console    Starting Traffic
    ute_wtssim.execute_egate_command    cmd=trf_data_start ue=11 id=2 dir=dl mbps=1    pass_regexp=UE 11: UDP DL TRF:.*
    ute_wtssim.execute_egate_command    cmd=trf_data_start ue=11 id=2 dir=ul mbps=1    pass_regexp=UE 11: UDP UL TRF:.*

Stop All NSA Traffic
    Log to Console    Stopping Traffic
    ute_wtssim.execute_egate_command    cmd=trf_data_stop ue\=11    pass_regexp=Traffic was stopped

Enter Idle Mode
    [Arguments]    ${ue_id}=1
    ute_wtssim.execute_egate_command    cmd=ue_im_entry id=${ue_id} by=ue    pass_regexp=UE${ue_id}: IS IDLE
    Sleep    5s    reason=Wait for UE to be in IDLE mode

Exit Idle Mode To Connected
    [Arguments]    ${ue_id}=1
    Exit Idle Mode     ue_id=${ue_id}    pass_regexp=UE${ue_id}: RrcState: NR CONNECTED

Change rrcReestabTypeSA Parameter To ${value}
    [Documentation]   Parameter rrcReestabTypeSA can be set to specific values: "deactivated", "sameGNB", "viaRRCSetup"
    Log to Console    Changing rrcReestabTypeSA parameter
    Perform Parameter Commissioning
    ...    parameter=rrcReestabTypeSA
    ...    value=${value}
    ...    dist_name=MRBTS-1/NRBTS-1
    Sleep    3s        reason=Wait for proper parameter activation

Get Message Timestamp
    [Arguments]    ${syslog_path}=${LOG_DIR}/${TEST NAME}/GNB_syslog
    ...    ${message_pattern}=sending HandoverRequired    ${which_message}=0
    ${timestamp_pattern}    Set Variable    [0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}.[0-9]{6}
    ${cmd}                  Set Variable    grep -w '${message_pattern}' '${syslog_path}'
    ${rc}    ${output}      Run And Return Rc And Output    ${cmd}
    Run keyword if    ${rc} != 0    Log To Console    Timestamp not found in syslog, check if it is properly defined
    ${timestamp}     Get Regexp Matches    ${output}    ${timestamp_pattern}
    ${epoch_date}    Convert Date    ${timestamp}[${which_message}]    epoch
    ${date_UTC+1}    Convert Time To UTC+1       ${epoch_date}
    ${date}          Convert To String    ${date_UTC+1}
    ${splitted_date}    Split String    ${date}    separator=.
    ${ms_range}     Create Miliseconds Range    ${splitted_date}[1]
    ${date_list}    Create List    ${splitted_date}[0]    ${ms_range}
    Log to console    ${date_list}
    [Return]    ${date_list}

Create Miliseconds Range
    [Arguments]    ${ms}=1000
    ${ms_pattern}     Set Variable    [0-9]{6}
    ${upper_range_in_seconds}    Add Time To Time           0.${ms}s    15.0001ms
    ${lower_range_in_seconds}    Subtract Time From Time    0.${ms}s    15.0001ms
    ${upper_range_in_seconds}    Set Variable If    ${upper_range_in_seconds} > 0.999999    999999    ${upper_range_in_seconds}
    ${lower_range_in_seconds}    Set Variable If    ${lower_range_in_seconds} < 0           000001    ${lower_range_in_seconds}
    ${upper_range}    Convert To String    ${upper_range_in_seconds}
    ${lower_range}    Convert To String    ${lower_range_in_seconds}
    ${upper_range}    Get Regexp Matches    ${upper_range}    ${ms_pattern}
    ${lower_range}    Get Regexp Matches    ${lower_range}    ${ms_pattern}
    ${ms_range}       Set Variable    IN_RANGE(${lower_range}[0],${upper_range}[0])
    [Return]   ${ms_range}

Convert Time To UTC+1
    [Arguments]    ${epoch_time}=1661940794
    ${epoch_time_UTC+1}    Add Time To Time    ${epoch_time}    1hour
    [Return]    ${epoch_time_UTC+1}

Enable Debug Logs and Create cp_runtime.ini File
    ssh.Connect To      hostname=192.168.255.1    username=toor4nsn    password=oZPS0POrRieRtu    alias=gNB
    ssh.Send Command    command=echo -e "[control]\nLoggingSeverity=trace" > /ffs/run/cp_runtime.ini    connection=gNB
    Log to Console      Updating gNB swconfig with debug flags
    Put swconfig file   input_filepath=${CURDIR}/swconfig_flags.txt
    ssh.Send Command    command=crasign /ffs/run/swconfig.txt    connection=gNB
    Perform Reset Site
    Sleep    60s    reason=Wait to be able to establish connection with AP
    Check Radios Availability
    [Teardown]    ssh.Disconnect      connection=gNB

Perform Reset Site
    admin.Connect To
    admin.Reset Site
    [Teardown]    admin.Teardown
