*** Settings ***
Documentation
...    :copyright: Nokia
...    :contact: I_EXT_MN_RAN_VRF_WRO2_7_T03@internal.nsn.com

Library    OperatingSystem
Library    Collections
Library    String
Library    Process
Library    ../../../../sim_resources/Krk_regression/rrm_resources/PCMD/verifier_msg_for_pcmd.py
Library    ute_wtssim
Library    ute_fsmaccess
Library    ute_syslog
Library    ute_tshark
Library    ta5g_egate
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
    ...            ${loki}=${False}
    Perform Delta Commissioning    ${json_file}
    Wait Until Radio Unit Online
    Create Directory    ${WTS_DIR}
    Change Edaemon Port    ${wts_config_path}
    Run Keyword If    ${loki}    Change Airphone XML Path For Loki WTS
    Configure UTE ETH3
    Reach Onair
    ...    lua_cfg=${WTS_CONFIG_NEW}
    ...    logs_dirpath=${WTS_DIR}
    ...    align_tac_values=False

Perform Delta Commissioning
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

Change Airphone XML Path For Loki WTS
    [Arguments]    ${wts_config_path}=${WTS_CONFIG_NEW}
    ${default_ap_xml}       Set Variable    AirphoneConfig.xml
    ${ls}    Run    ls ${WTS_LATEST_DIR}/*.xml
    Log To Console    ${ls}
    ${ap_xml_exist}     Run Keyword And Return Status     File Should Exist    ${WTS_LATEST_DIR}/${default_ap_xml}
    Run Keyword If     ${ap_xml_exist}    Set Suite Variable    ${airphone_xml}     ${default_ap_xml}
    ...     ELSE      Set Newest WTS AP XML Config Filename
    wtscfg.Load Wts Cfg    ${wts_config_path}
    wtscfg.Modify    set_uec id=1    file=${airphone_xml}
    wtscfg.Save Wts Cfg    ${WTS_CONFIG_NEW}
    Copy File    ${WTS_LATEST_DIR}/${airphone_xml}      ${WTS_DIR}/${airphone_xml}

Set Newest WTS AP XML Config Filename
    [Documentation]  Gets the newest *.xml file in WTS directory
    @{files}=   List Files In Directory     ${WTS_LATEST_DIR}    *.xml
    Log List    ${files}
    ${lastModifiedFile} =   Get From List   ${files}    0
    ${time1} =  OperatingSystem.Get Modified Time       ${WTS_LATEST_DIR}/${lastModifiedFile}    epoch
    FOR    ${file}    IN    @{files}
        ${time}    Get Modified Time   ${WTS_LATEST_DIR}/${file}    epoch
        ${lastModifiedFile}    Set Variable If    ${time1} < ${time}    ${file}    ${lastModifiedfile}
    END
    Set Suite Variable    ${airphone_xml}     ${lastModifiedFile}

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

Check If Radio Unit Online
    ${frm_list}    admin.Get FRM
    ${availability}    Get variable value    ${frm_list[0]['status']['availabilityStatus']}
    ...                                      Online
    Should Be Equal    ${availability}    Online

Reboot If Radio Unit Offline
    [Arguments]    ${timeout}=5 min
    ${passed}    Run Keyword And Return Status    Wait Until Keyword Succeeds    ${timeout}    10 sec    Check If Radio Unit Online
    Run Keyword If    ${passed}==False    Log to Console    Radio Unit offline after ${timeout}, rebooting.
    Run Keyword If    ${passed}==False    Run Keywords    admin.Reset site    Fail

Wait Until Radio Unit Online
    admin.Setup admin
    Log to Console    Wait until Radio Unit online...
    Wait Until Keyword Succeeds    3x    2 min    Reboot If Radio Unit Offline
    Log to Console    Radio Unit Online
    admin.Teardown admin

NSA Establish X2
    Log to Console    Establishing X2AP Link
    ${cmd}    Set Variable    enb_x2_link_up enb\=1 target\=2
    ${pass_cond}    Set Variable    X2AP Link with GNB-2.*is up
    ute_wtssim.execute_egate_command    cmd=${cmd}    pass_regexp=${pass_cond}

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
    Perform Intracell Handover And Wait For Confirmation    ue_id=${ue_id}

Collect SCF to Logs
    Log to Console    Collecting SCF
    ${scf_dir}    Set Variable    ${LOG_DIR}/Configs/
    ${scf_filename}    Set Variable    SCF.xml
    admin.Setup admin
    Create Directory    ${LOG_DIR}/Configs/
    admin.Get Current SCF File
    ...    local_dir_path=${LOG_DIR}/Configs/
    ...    file_name=SCF.xml
    Create Directory    ${scf_dir}
    admin.Get Current SCF File    export_type=configurationAndRuntimeObjects
    ...    local_dir_path=${scf_dir}
    ...    file_name=${scf_filename}
    admin.Teardown admin
    ${scf_filepath}    Set Variable    ${scf_dir}${scf_filename}
    [Return]    ${scf_filepath}

Get SCF Parameter Value
    [Arguments]    ${dist_name}    ${p_name}
    ${scf_filepath}    Collect SCF to Logs
    scf.Load Scf    ${scf_filepath}
    ${p_value}    scf.Get Value From Scf    dist_name=${dist_name}    p_name=${p_name}
    [Return]    ${p_value}

Collect Snapshot to Logs
    Log to Console    Collecting Snapshot
    admin.Setup admin
    admin.Get Snapshot
    ...    target_file_name=${LOG_DIR}/Snapshot/Snapshot.zip
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
    [Arguments]    ${file_name}=pcmd_eth3
    Log    ${OUTPUT DIR}
    Setup tshark
    ...   alias=tshark_testcase
    ...   log_name=${file_name}.pcap
    ...   interface=eth3
    ...   log_dir=${OUTPUT DIR}
    Start capturing
    ...   alias=tshark_testcase
    ...   log_name=${file_name}.pcap
    ...   log_dir=${OUTPUT DIR}

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

Change ue params in wts file
    [Arguments]    ${WTS_CONFIG_MODIFIED}=/opt/wts/latest/modified_basic_setup.cfg
    wtscfg.Load Wts Cfg    ${WTS_CONFIG_MODIFIED}
    wtscfg.Modify   set_ue simulated id=1     nia=null+zuc+snow3g+aes nea=null+zuc+snow3g+aes
    wtscfg.Save Wts Cfg    ${WTS_CONFIG_MODIFIED}

Add Additional UE to WTS Config File
    [Arguments]    ${WTS_CONFIG_MODIFIED}=/opt/wts/latest/modified_basic_setup.cfg
    wtscfg.Load Wts Cfg    ${WTS_CONFIG}
    wtscfg.Modify    set_ue simulated id=2    enb=2 cell=1
    wtscfg.Clone And Modify    set_ue simulated id=2    id=3 suci=0:311:489:0000:0:0:021645402
    wtscfg.Clone And Modify    ue_param id=2    id=3
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

UE${ue_id} triggers XNAP Inter-gNB Handover from simulated gNB${src_gnb} to real gNB${tgt_gnb}
	${meas_id}    Get Measurement ID    EventA5
	ute_wtssim.execute_egate_command
	...     cmd=ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A5 srsrp_nr=18 phycell_id=50 nrsrp_nr=85
    ...     pass_regexp=UE${ue_id}: Inter-eNB handover from ENB-${src_gnb}.1 to EXT_ENB-${tgt_gnb}.1 performed

Trigger Inter gNB HO
    [Arguments]    ${cell_id}=52    ${meas_id}=2
    ${pattern}     Set Variable    Received PATH SWITCH REQUEST
    ${cmd}    Set Variable
    ...    ue_measurement_send_nr id=1 meas_id=${meas_id} event=A3 srsrp_nr=19 srsrq_nr=10 phycell_id=${cell_id} nrsrp_nr=85 nrsrq_nr=31
    ute_wtssim.execute_egate_command    cmd=${cmd}    pass_regexp=${pattern}

Setup devices aliases
    Create ues alias    alias=UE   id_type=wts_5g
    Create GNB device with alias 'gNB2' identified by ip=10.0.1.2
    Enable Internal Mirroring For Alias    gNB2

Set Allowed PDU Sessions to Zero
    Log to Console    Setting Allowed PDU Sessions to Zero
    admin.Setup admin
    admin.Perform Parameter Recommissioning
    ...    dist_name=MRBTS-1/NRBTS-1/NRCELL-1
    ...    parameter=maxNumOfNonGBRBearersSA
    ...    operation=update
    ...    value=0
    ...    skip_parameter_relation_errors=True
    admin.Teardown admin

Establish PDU Session With Expected Failure
    Establish PDU Session
    ...    pass_regexp=PDU Session with ID.*in UE.*was not provided

Disable ciphering
    Send Delta Commissioning    ${CURDIR}/delta_cipher_for_messaging.json

SA Start Traffic
    [Arguments]    ${direction}=ul    ${duration}=60s    ${throughput}=1MB
    Start Traffic And Check If Average Throughput Is Reached
    ...           direction=${direction}    duration=${duration}    throughput=${throughput}    pdu_gw_id=1
    Sleep    5s
    Stop Uplink Traffic

Get Last initialTa Value from GNB Syslog
    [Arguments]    ${log_dir}=${LOG_DIR}/GNB Syslog/
    ${cmd}    Set Variable
    ...    grep -o 'initialTa\=[0-9]*' '${log_dir}/GNB_syslog' | tail -1 | cut -d "=" -f2
    ${rc}    ${output}    Run And Return Rc And Output    ${cmd}
    [Return]  ${output}

Get Measurement ID
    [Arguments]    ${event_type}    ${ue_id}=1
    ${measurements}    Execute Egate Command And Wait For Data
    ...    cmd=ue_meas_cfg_disp id=${ue_id}
    ...    pass_regexp=${event_type}
    ${meas_list}    Get Regexp Matches    ${measurements}    (\\S+).*${event_type}    1
    [Return]    ${meas_list}[0]
