*** Settings ***
Documentation
...    :copyright: Nokia
...    :contact: I_EXT_MN_RAN_VRF_WRO2_7_T03@internal.nsn.com

Library    OperatingSystem
Library    Collections
Library    String
Library    Process
Library    ../../../../../sim_resources/Krk_regression/rrm_resources/PCMD/verifier_msg_for_pcmd.py
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
Library    ta5g_testline_management
Library    ta_pcmd
Library    ta_messaging
Library    taf.transport.ssh           WITH NAME    ssh
Library    taf.sbts.oam.coam.admin     WITH NAME    admin
Library    taf.wts.runner    WITH NAME    wtsrunner
Library    taf.config.wts              WITH NAME    wtscfg
Library    taf.wts.config
Library    taf.config.scf    WITH NAME   scf

*** Variables ***
${WTS_CONFIG}                       /opt/wts/latest/basic_setup.cfg
${LOG_DIR}                          ${OUTPUT DIR}/Logs/
${WTS_DIR}                          ${LOG_DIR}/WTS/
${WTS_CONFIG_NEW}                   ${WTS_DIR}/basic_setup_mod.cfg
${WTS_LATEST_DIR}                   /opt/wts/latest

*** Keywords ***
Send Delta Commissioning and Reach OnAir
    [Arguments]    ${json_file}
    ...            ${wts_config_path}=${WTS_CONFIG}
    Send PCMD Delta Commissioning    ${json_file}
    Check Radios Availability
    Create Directory    ${WTS_DIR}
    Change Edaemon Port    ${wts_config_path}
    Configure UTE ETH3
    Reach Onair
    ...    lua_cfg=${WTS_CONFIG_NEW}
    ...    logs_dirpath=${WTS_DIR}
    ...    align_tac_values=False

Send PCMD Delta Commissioning
    [Arguments]    ${JSON_FILE}=delta_pcmd.json
    admin.Setup Admin
    ${sw_ver}    admin.Get SW Release Name
    admin.Teardown Admin
    Send Delta Commissioning    ${CURDIR}/${sw_ver}/${JSON_FILE}

Send HO Delta Commissioning
    [Arguments]    ${JSON_FILE}=delta_HO.json
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
    ...    timeout=15min
    admin.Teardown admin

Start AP Syslog
    [Arguments]    ${log_dir}=${LOG_DIR}/AP Syslog/
    Log to Console    Starting AP Syslog Collection
    ute_syslog.Start Syslog
    ...    log_dir=${log_dir}
    ...    log_name=AP_syslog
    ...    ip=192.168.200.126
    ...    alias=AP_syslog

Stop And Collect AP Syslog
    Log to Console    Stopping AP Syslog Collection
    ute_syslog.Collect Syslog Results    alias=AP_syslog

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
    wtscfg.Save Wts Cfg    ${WTS_CONFIG_MODIFIED}

Change UE Capabilities In WTS File
    [Arguments]    ${WTS_CONFIG_MODIFIED}=/opt/wts/latest/modified_basic_setup.cfg
    ...            ${ue_id}=1    ${ue_nr_capabilities}=01000000010900040004D10000800000080800000003C00000000000008A8000100000000010010AA8
    wtscfg.Load Wts Cfg    ${WTS_CONFIG_MODIFIED}
    wtscfg.Modify   ue_param id=${ue_id}    ue_nr_capabilities=${ue_nr_capabilities}
    wtscfg.Save Wts Cfg    ${WTS_CONFIG_MODIFIED}

Prepare Ue For Inter gNB HO
    ${cmd1}    Set Variable
    ...    ue_history_information_list_add_ngran id=1 gnb_id=2 cell_type=large nrcgi=311:489|0x01 time_ue_stayed_in_cell=97
    ${cmd2}    Set Variable
    ...    ue_history_information_list_add_ngran id=1 gnb_id=3 cell_type=large nrcgi=311:489|0x01 time_ue_stayed_in_cell=98
    ${cmd3}    Set Variable    ue_history_information_list id=1 action=commit
    ${cmd4}    Set Variable    ue_enb_param id=1 ue_history_list=1
    ute_wtssim.execute_egate_command    cmd=${cmd1}
    ute_wtssim.execute_egate_command    cmd=${cmd2}
    ute_wtssim.execute_egate_command    cmd=${cmd3}
    ute_wtssim.execute_egate_command    cmd=${cmd4}

Trigger Inter gNB HO
    [Arguments]    ${cell_id}=52    ${ue_id}=1
    ${meas_id}=                  Get Measurement ID    event_type=EventA3    ue_id=${ue_id}
    ${pattern}     Set Variable    Received PATH SWITCH REQUEST
    ${cmd}    Set Variable
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A3 srsrp_nr=19 srsrq_nr=10 phycell_id=${cell_id} nrsrp_nr=85 nrsrq_nr=31
    ute_wtssim.execute_egate_command    cmd=${cmd}    pass_regexp=${pattern}

Trigger Intra-gNB Intra-DU Inter-cell HO
    ${meas_id}=                  Get Measurement ID    EventA3
    ${pattern}     Set Variable    Intra-eNB handover from EXT_ENB-2.1 to EXT_ENB-2.2 performed
    ${cmd}         Set Variable
    ...    ue_measurement_send_nr id=1 meas_id=${meas_id} index=0 nrs_result=101:101:0 event=A3 srsrp_nr=19 phycell_id=51 nrsrp_nr=101
    ute_wtssim.execute_egate_command    cmd=${cmd}    pass_regexp=${pattern}

Trigger Intra-gNB Intra-DU Inter-cell HO Back To Originated Cell
    ${meas_id}=                  Get Measurement ID    EventA3
    ${pattern}     Set Variable    Intra-eNB handover from EXT_ENB-2.2 to EXT_ENB-2.1 performed
    ${cmd}         Set Variable
    ...    ue_measurement_send_nr id=1 meas_id=${meas_id} index=0 nrs_result=101:101:0 event=A3 srsrp_nr=19 phycell_id=50 nrsrp_nr=101
    ute_wtssim.execute_egate_command    cmd=${cmd}    pass_regexp=${pattern}

Trigger Intra-gNB Intra-DU Intra-cell HO
    [Arguments]    ${ue_id}=1
    Trigger Inter gNB HO    cell_id=52    ue_id=${ue_id}
    UE reauthentication     ue_id=${ue_id}
    Trigger Inter gNB HO    cell_id=50    ue_id=${ue_id}

UE reauthentication
    [Arguments]    ${ue_id}=1
    ${pattern}     Set Variable    Reauthentication procedure is complete
    ${cmd}         Set Variable    ue_reauth id=${ue_id} nr_sec_cap=null|zuc
    ute_wtssim.execute_egate_command    cmd=${cmd}    pass_regexp=${pattern}

Setup devices aliases
    Create ues alias    alias=UE   id_type=wts_5g
    Create GNB device with alias 'gNB2' identified by ip=10.0.1.2
    Enable Internal Mirroring For Alias    gNB2

SA Start Traffic
    [Arguments]    ${direction}=ul    ${duration}=60s    ${throughput}=1MB
    Start Traffic And Check If Average Throughput Is Reached
    ...           direction=${direction}    duration=${duration}    throughput=${throughput}    pdu_gw_id=1
    Stop Uplink Traffic

Get Measurement ID
    [Arguments]  ${event_type}=EventA3  ${ue_id}=1
    ${measurements}=    Execute Egate Command And Wait For Data
    ...    cmd=ue_meas_cfg_disp id=${ue_id}
    ...    pass_regexp=${event_type}
    ${matching_lines}=  Get Lines Containing String  ${measurements}  ${event_type}
    ${first_line}=  Get Line  ${matching_lines}  0
    @{words}=  Split String  ${first_line}
    [Return]  ${words}[0]

Set TrafficType To Internal
    [Arguments]  ${ue_id}=1
    ${cmd}    Set Variable    set_pdu_param ue=${ue_id} pdu=${ue_id} trf_type=internal
    Execute Egate Command    cmd=${cmd}

Start Internal Traffic
    [Arguments]  ${ue_id}=1    ${qfi}=1
    Log to Console    Starting Internal DL Traffic
    ${cmd}    Set Variable    trf_data_start ue\=${ue_id} pdu\=${ue_id} qfi\=${qfi} dir\=dl mbps\=5
    ${pass_cond}    Set Variable    Started Downlink Internal traffic over UDP on Ue:1 UpfId:1 Pdu:1 Qfi:1 TrfId:1
    Execute Egate Command    cmd=${cmd}    pass_regexp=${pass_cond}
    Log to Console    Starting Internal UL Traffic
    ${cmd}    Set Variable    trf_data_start ue\=${ue_id} pdu\=${ue_id} qfi\=${qfi} dir\=ul mbps\=5
    ${pass_cond}    Set Variable    Started Uplink Internal traffic over UDP on Ue:1 UecId:1 Pdu:1 Qfi:1 TrfId:1
    Execute Egate Command    cmd=${cmd}    pass_regexp=${pass_cond}

Stop All Internal Traffic
    [Arguments]  ${ue_id}=1
    Log to Console    Stopping All Internal Traffic
    ${cmd}    Set Variable    trf_data_stop ue\=${ue_id} pdu\=${ue_id}
    ${pass_cond}    Set Variable    Traffic was stopped
    ute_wtssim.execute_egate_command    cmd=${cmd}    pass_regexp=${pass_cond}

Start Vm Ethernet Interfaces
    Start Vm Ethernet Interface    if_name=eth3:GNB3_NG_ADDR    ip_with_mask=10.0.1.3/24
    Start Vm Ethernet Interface    if_name=eth3:GNB3_XN_ADDR    ip_with_mask=10.0.1.4/24

Stop Vm Ethernet Interfaces
    Stop Vm Ethernet Interface    if_name=eth3:GNB3_NG_ADDR    ip_with_mask=10.0.1.3/24
    Stop Vm Ethernet Interface    if_name=eth3:GNB3_XN_ADDR    ip_with_mask=10.0.1.4/24
