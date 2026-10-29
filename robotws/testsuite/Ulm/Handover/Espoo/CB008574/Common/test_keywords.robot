*** Settings ***
Documentation    Test keyword resource file for CB008574

Resource    taf/rfrl/common_resources/robot/libraries_instances.robot
Resource    ../../resources/keywordbook-resourceUsage.robot
Resource    ../../../../resources/Common/reporting.robot
Library     OperatingSystem
Library     taf.hw.pdu     WITH NAME     pdu
Library     taf.sbts.oam.coam.admin      WITH NAME  admin
Library     ta5g_iperf_traffic
Library     ta5g_commissioning
Library     DateTime
Library     Telnet
Library     ta5g_throughput
Library     ta5g_ue_measurements
Library     ta5g_ue_mobility
Library     ta5g_enb
Library     ta5g_iphy
Library     ta5g_egate
Library     ta5g_tshark
Library     ta5g_testline_management
Library     ta5g_setups_and_teardowns
Library     SSHLibrary
Library     ta_messaging
Library     ute_admin_infomodel
Library     taf.wts.runner
Library     taf.config.wts
Library     taf.transport.ssh  WITH NAME  SSHH
Library     taf.config.testline.info.testline_info.TestlineInfo    WITH NAME    testline_info
Library     ta5g_pm_counters
#Library     taf.ul.pmi_ticket_collector
Library     ute_syslog
Library     ta5g_scfc_analysis
Library     ta_a2a

# For 5G please import like below
Library    taf.ccs.aashell
Library     taf.sw.dcap.rd		WITH NAME	DCAP

*** Variables ***
${DCAP_port}    9443
&{bts_classical}      alias=gnb_1    host=192.168.255.129    username=Nemuadmin    password=nemuuser
    ...     port=443    bts_id=1

*** Keywords ***
Testsuite Setup
    Timestamp Prints  log=Testsuite Setup Start
		Run Keywords  Put Swconfig File  ${SWCONFIG}
		...  AND  Update And Put Iphy Xml    input_filepath=${IPHY_XML}
		# For exploratory CP-UE blacklisting with CB008574 TC only:
    #...  AND  Enable RD flag of rdCellBlacklistSDL
		#...  AND  Reboot Airphone via Console
		...  AND  Find Scfc And Fix And Send Full Commissioning  scfc_filename=scfc.xml  alias=commission
		...  AND  Initialize Misc Configurations
		...  AND  Start Default Tshark On S1 MME And UU Interfaces For Testcase  log_dirpath=${OUTPUT_DIR}/tshark
		...  AND  Start Egate
		...  AND  Start TCE
		...  AND  Links up
    Timestamp Prints  log=Testsuite Setup End

Testcase Setup
    Timestamp Prints  log=Testcase Setup Start
    Run Keywords  Execute Egate Command  cmd=sim_trace amf=1 protocol=ng on
    ...    AND    Reset UE Params  ue_id=1,2,3,4,5,6,7,8
    ...    AND    Execute Egate Command  cmd=gnb_xn_handover_preparation_param id=3 reset
    ...    AND    Set Sim Automatic Neighbour Relation  pci=50
    ...    AND    Start ext interface tshark for testcase
    ...    AND    Start GNB Syslog
    #...    AND    Start DCAP log    bts=${bts_classical}
    #...    AND    Start AP Syslog
    #...    AND    Get Resources Taken Before_test
    Timestamp Prints  log=Testcase Setup End

Testsuite TearDown
		Run Keywords  Stop Tcpdump On Remote Interface
		...  AND  Stop Default Tshark On S1 MME And UU Interfaces For Testcase
		...  AND  Stop Vm Ethernet Interfaces
		...  AND  Teardown Egate And Collect Logs
    # Workaround for hanging UPF that crashes egate startup (happens sometimes in case multiple qfi data transfer is used):
    ...  AND  Run  sudo ip link delete tunUPF
		...  AND  Run Keyword And Warn On Failure  stop_simenb_interface_and_stop_default_processes_and_gather_logs_without_infomodel

Testcase Teardown
    Run Keywords    Log to console  Testcase Teardown started ..
    ...    AND    Stop And Collect GNB Syslog
    ...    AND    Stop Tcpdump On Remote Interface
    ...    AND    Execute Egate Command    cmd=set_log flush
    ...    AND    Run  cp /opt/iphy/latest/egate_console.log ${OUTPUT_DIR}/egate_console_${TEST_NAME}.txt
    # Set log off and on to stop old and start new egate_console log after every executed TC so one run in one file neatly:
    ...    AND    Execute Egate Command    cmd=set_log log_to_file=off
    ...    AND    Execute Egate Command    cmd=set_log log_to_file=on
    #...    AND    Stop And Download DCAP log
    #...    AND    Stop And Collect AP Syslog
    ...    AND    Run keyword and ignore error  Stop Tshark  alias=PCMD
    #...    AND    Get Resources Taken After_test
    #...    AND    Verify Resource Usage
    ...    AND    Run Keyword and Warn on Failure    Set SCOUT TC ID for Reporting

Testcase Teardown No Resource Checking
    Run Keywords    Log to console  Testcase Teardown started ..
    ...    AND    Stop And Collect GNB Syslog
    ...    AND    Stop Tcpdump On Remote Interface
    ...    AND    Execute Egate Command    cmd=set_log flush
    ...    AND    Run  cp /opt/iphy/latest/egate_console.log ${OUTPUT_DIR}/egate_console_${TEST_NAME}.txt
    # Set log off and on to stop old and start new egate_console log after every executed TC so one run in one file neatly:
    ...    AND    Execute Egate Command    cmd=set_log log_to_file=off
    ...    AND    Execute Egate Command    cmd=set_log log_to_file=on
    #...    AND    Stop And Download DCAP log
    #...    AND    Stop And Collect AP Syslog
    ...    AND    Run keyword and ignore error  Stop Tshark  alias=PCMD
    #...    AND    Get Resources Taken After_test
    #...    AND    Verify Resource Usage
    ...    AND    Run Keyword and Warn on Failure    Set SCOUT TC ID for Reporting

Initialize Misc Configurations
    Log to console  Initialize Misc Configurations while gNB in reset after full commissioning to save time ..
		Start Vm Ethernet Interfaces
		Backup Test Suite Files
		Set Aliases For Messaging Actors
		# Create dir for a2a logs
		Run  mkdir ${OUTPUT_DIR}/a2a

		# Enable target ran container decoding (for example to verify HO req ack - nr-rrc content)
		Run  echo "ngap.dissect_target_ng_ran_container_as: gNB" >> ~/.config/wireshark/preferences
		Run  echo "xnap.dissect_target_ng_ran_container_as: gNB" >> ~/.config/wireshark/preferences
    # Workaround for hanging UPF that crashes egate startup (happens sometimes in case multiple qfi data transfer is used):
    Run  sudo ip link delete tunUPF
		#Prepare DCAP Logging

Enable RD flag of rdCellBlacklistSDL
    ${ALIAS_ASIL}    Connect to gNB
    # https://confluence.ext.net.nokia.com/display/CDSSCM/Architecture+mapping
    Modify RD flag of rdCellBlacklistSDL
    ...    before_value=rdCellBlacklistSDL=False  after_value=rdCellBlacklistSDL=True
    ...    file=cp_ue.enb_conf.ini  ALIAS_ASIL=${ALIAS_ASIL}  hw=sm6-snowfish

Connect to gNB
    [Arguments]    ${ALIAS_ASIL}=gNB_conn
    SSHH.Connect_to       hostname=${GNB_IP}
    ...                   username=${NOKIA_LOGIN}
    ...                   password=${NOKIA_PASS}
    ...                   alias=${ALIAS_ASIL}
    RETURN    ${ALIAS_ASIL}

Modify RD flag of rdCellBlacklistSDL
    [Arguments]    ${before_value}    ${after_value}    ${file}    ${ALIAS_ASIL}=${ALIAS_ASIL}    ${hw}=sm6-snowfish
    # root@fct-4a:~ >cd /ffs/run/swpool/CPLANE-5G/
    # airscale5g-xeon/ sm6-snowfish/    sm7-marlin/

    Timestamp Prints  log=Starting to Modify RD flag of rdCellBlacklistSDL for HW: ${hw}
    Log to console  *** DO NOT INTERRUPT! ***
    SSHH.Execute    command=rm -rf /tmp/cpue && mkdir /tmp/cpue    connection=${ALIAS_ASIL}  timeout=250
    ${output}    SSHH.Execute    command=cd /ffs/run/swpool/CPLANE-5G/${hw}/ && ls cp-ue_*.txz  connection=${ALIAS_ASIL}  timeout=250
    ${filename}=    Remove String    ${output}    \r\n
    Log to console  Modify RD flag of rdCellBlacklistSDL filename: ${filename}
    Log to console  Modify RD flag of ${before_value} to ${after_value}
    SSHH.Execute    command=tar -xvf /ffs/run/swpool/CPLANE-5G/${hw}/${filename} -C /tmp/cpue   connection=${ALIAS_ASIL}  timeout=250
    SSHH.Execute    command=sed -i "s/${before_value}/${after_value}/g" /tmp/cpue/opt/nokia/SS_CPLANE/etc/${file}  connection=${ALIAS_ASIL}
    ...    timeout=250
    SSHH.Execute    command=cd /tmp/cpue && tar -Jcvf ${filename} opt/ usr/    connection=${ALIAS_ASIL}  timeout=250
    # nokia/SS_CPLANE/etc/${file}
    SSHH.Execute    command=cd /tmp/cpue && cp ${filename} /ffs/run/swpool/CPLANE-5G/${hw}/    connection=${ALIAS_ASIL}  timeout=250
    SSHH.Execute    command=cd /ffs/run/swpool/CPLANE-5G/${hw}/ && crasign ${filename} && rm /ffs/run/HashContainer*
    ...    connection=${ALIAS_ASIL}  timeout=250
    SSHH.Disconnect    connection=${ALIAS_ASIL}
    Timestamp Prints  log=Modify RD flag of rdCellBlacklistSDL complete!
    #Run  scp toor4nsn@192.168.255.129:/ffs/run/swpool/CPLANE-5G/${hw}/${filename} /home/ute/logs/

Prepare DCAP Logging
    Log to console  Prepare DCAP Logging..
    Start Dcap Lite
    Wait Until Keyword Succeeds  3 min  10 sec  Connect To DCAP
    # Continue in case already created in previous suite execution..
    Run keyword and ignore error   Create Bts On DCAP

Start Dcap Lite
  	SSHLibrary.open connection    10.0.1.1    prompt=$   timeout=600 seconds
  	SSHLibrary.Login With Public Key    ute    /home/ute/.ssh/id_rsa
  	SSHLibrary.Write    cd /home/ute/robotlte
  	SSHLibrary.Write    DCAP_Basic_controller status
  	#SSHLibrary.Write    DCAP_Basic_controller stop
  	SSHLibrary.Write    DCAP_Basic_controller start

  	SSHLibrary.Read Until Prompt

Connect To DCAP
    DCAP.connect_to    host=${tl.test_pcs[0].default_ssh_connection_details.addr}     port=${DCAP_port}     username=dcapuser
	  ...    password=dcapadmin!    rd_version=dcapv3    secure=${True}

Create Bts On DCAP
    [Arguments]    ${host}=192.168.255.129    ${bts_alias}=gnb_1
    DCAP.create_bts    host=${host}    bts_alias=${bts_alias}

Start DCAP log
    [Arguments]    ${bts}
	  ${gnb_custom_profile}=    Create List    cp_5g
	  #${gnb_custom_profile}=    Create List    cp_5g  immediateSnapshot_5g  condor5gSyslog

	  Log to console  Start DCAP logging with profile: ${gnb_custom_profile}

	  ${output}    DCAP.start_trace     bts=${bts}    gnb_custom_profile=${gnb_custom_profile}    wait_for_activation=${True}
	  ...    control_plane_interface=${True}
	  Log    ${output}[id]
    ${result_id}      Convert To Integer      ${output}[id]
    set suite variable    ${result_id}

Stop And Download DCAP log
    log to console    Stop And Download DCAP log
    DCAP.stop_trace    trace_id=${result_id}
    ${downloaded_emil_file_path}    DCAP.get_results    result_id=${result_id}   target_dir=${OUTPUT_DIR}/
    RETURN    ${downloaded_emil_file_path}

Start Egate
    Log to console  Starting Egate ..
    Stop Edaemon Egate
    Reach Onair   lua_cfg=${EPCSIM_CFG_PATH}  timeout=300  align_tac_values=${False}
    #reach_onair_without_confirmation  lua_cfg=${EPCSIM_CFG_PATH}  align_tac_values=${False}

Connect to Airphone Common Unit
    [Arguments]    ${alias}=ssh-ap-1
    SSHH.Connect_to       hostname=${AP_IP}
    ...                   username=${NOKIA_LOGIN}
    ...                   password=${NOKIA_PASS}
    ...                   alias=${alias}
    SSHH.Force Reconnect  connection=${alias}
    RETURN    ${alias}

Reboot Airphone via Console
    Timestamp Prints  log=Reboot Airphone via Console started
    ${ap_alias}=    Wait Until Keyword Succeeds    3 min    5 sec     Connect to Airphone Common Unit
    SSHH.send command    set -m ; system-module-reboot    connection=${ap_alias}
    # Wait until AP reset has been triggered before trying re-connect
    #Sleep  15s
    #Reconnect Airphone via Console

Reconnect Airphone via Console
    Wait Until Keyword Succeeds    3 min    5 sec     Connect to Airphone Common Unit
    Timestamp Prints  log=Airphone re-connected after reboot

Timestamp Prints
    [Arguments]  ${log}=Timestamp Prints
    ${time}    Get current date    result_format=%Y-%m%d_%H:%M:%S    exclude_millis=${True}
		Log to console  ${log} time: ${time}

Start GNB Syslog
    [Arguments]    ${log_dir}=${OUTPUT_DIR}/GNB_Syslog/
    Timestamp Prints  log=Starting GNB Syslog Collection to ${log_dir}
    ute_syslog.Start Syslog
    ...    log_dir=${log_dir}
    ...    log_name=GNB_syslog_${TEST_NAME}.log
    ...    ip=192.168.255.126
    ...    alias=GNB_syslog

Stop And Collect GNB Syslog
    ute_syslog.Collect Syslog Results    alias=GNB_syslog
    Timestamp Prints  log=GNB Syslog Collected

Start AP Syslog
    [Arguments]    ${log_dir}=${OUTPUT_DIR}/AP_Syslog/
    Log to Console    Starting AP Syslog Collection
    ute_syslog.Start Syslog
    ...    log_dir=${log_dir}
    ...    log_name=AP_syslog_${TEST_NAME}.log
    ...    ip=192.168.200.126
    ...    alias=AP_syslog

Stop And Collect AP Syslog
    Log to Console    Stopping AP Syslog Collection
    ute_syslog.Collect Syslog Results    alias=AP_syslog

Backup Test Suite Files
    Run  rsync -a ${ROBOT_SUITE_DIR}/*.robot ${OUTPUT_DIR}/Robot/
    Run  rsync -a ${ROBOT_SUITE_DIR}/config/*.txt ${OUTPUT_DIR}/Robot/
    Run  rsync -a ${CURDIR}/*.robot ${OUTPUT_DIR}/Robot/

Set Aliases For Messaging Actors
    Log To Console    Set Aliases For Messaging Actors
    Create GNB device with alias 'gNB3_NG' identified by ip=10.0.1.123
    Create GNB device with alias 'gNB3_XN' identified by ip=10.0.1.122
    Create GNB device with alias 'gNB2' identified by ip=10.0.1.2
    Create AMF device with alias 'AMF1' identified by ip=10.0.1.1
    #Enable internal mirroring for alias  gNB2

Start ext interface tshark for testcase
    ${tcpdump_process}  ${log_filepath}  ${alias}  Start Tcpdump On Remote Interface
    ...  alias=TSHARK_${TEST_NAME}  log_filename_prefix=${TEST_NAME}_NG_XN_E1_F1_call_flow  log_dirpath=${OUTPUT_DIR}/tshark/

Teardown For UE Register And Establish PDU Session
    [Arguments]  ${gnb_id}  ${tcpdump_process}
    IF  "${gnb_id}"=="2"  kill_tshark_process  ${tcpdump_process}

UE Register And Establish PDU Session
    [Arguments]  ${ue_id}=1  ${pdu_id}=1  ${cell_id}=1  ${gnb_id}=2  ${nwslice}=1  ${gw_id}=1  ${CA}=${False}  ${NumSCells}=1

    ${time}    Get current date    result_format=%Y-%m%d_%H:%M:%S    exclude_millis=${True}

    # Only useful to capture if registering with real gNB:
    ${tcpdump_process}  ${log_filepath}  ${alias}  IF  "${gnb_id}"=="2"
    ...  Start Tcpdump On Remote Interface
    ...  alias=Reg_UE_${ue_id}_${time}  log_filename_prefix=${TEST_NAME}_UE${ue_id}_reg_and_pdu${pdu_id}_${time}
    ...  log_dirpath=${OUTPUT_DIR}/tshark

    Log to console  UE Register And Establish PDU Session for UE: ${ue_id} using nwslice: ${nwslice} ..
    Change UE Location  ue_id=${ue_id}  gnb_id=${gnb_id}  cell_id=${cell_id}

    Attach Ue    ue_id=${ue_id}  cell=${cell_id}  enb=${gnb_id}

    Establish PDU Session For UE  ue_id=${ue_id}  pdu_id=${pdu_id}  nwslice=${nwslice}  gw_id=${gw_id}
    Sleep   2s

    Log to console    UE: ${ue_id} registered ok

    IF  "${CA}"=="${True}" and "${gnb_id}"=="2"
    ...  Verify CA allocation  pcell=${cell_id}  sCellToAddModList=${NumSCells}  alias=${alias}  alias_path=${log_filepath}

    Print Measurements  ue_id=${ue_id}

    [Teardown]    Teardown For UE Register And Establish PDU Session  gnb_id=${gnb_id}  tcpdump_process=${tcpdump_process}

Establish PDU Session For UE
    [Arguments]  ${ue_id}=1  ${pdu_id}=2  ${nwslice}=2  ${gw_id}=2
    Log to console  Establish PDU Session For UE: ${ue_id}, PDU: ${pdu_id}, Slice: ${nwslice}, GW: ${gw_id} and set trf type as internal for data

    Execute Egate Command  cmd=set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal

    Establish Pdu Session  ue_id=${ue_id}  pdu_id=${pdu_id}  nwslice=${nwslice}  gw_id=${gw_id}
    ...    pass_regexp=Established PDU session
    Sleep  2s

UE Register And Establish PDU Session Sim
    [Arguments]  ${ue_id}=1  ${pdu_id}=1  ${cell_id}=1  ${gnb_id}=3  ${nwslice}=1
    Log to console  UE Register And Establish PDU Session on simulator side..
    Change UE Location  ue_id=${ue_id}  gnb_id=${gnb_id}  cell_id=${cell_id}

    Execute Egate Command  cmd=set_pdu_param ue=${ue_id} pdu=1 trf_type=internal

    Execute Egate Command  cmd=ue_register id=${ue_id} selected_plmn=1
    ...    pass_regexp=UE now in NG RM Registered    timeout=10s

    Establish Pdu Session    ue_id=${ue_id}  pdu_id=${pdu_id}  gw_id=${pdu_id}  nwslice=${nwslice}
    Print Measurements  ue_id=${ue_id}

Change UE Location
    [Arguments]  ${ue_id}=1  ${cell_id}=1  ${gnb_id}=2
    Execute egate command   cmd=ue_change_location id=${ue_id} enb=${gnb_id} cell=${cell_id}
    Execute egate command
    ...     cmd=ue_history_information_list_add_ngran id=1 gnb_id=3 cell_type=medium nrcgi=311:489|0x01 time_ue_stayed_in_cell=100
    Execute egate command
    ...     cmd=ue_history_information_list_add_ngran id=1 gnb_id=2 cell_type=medium nrcgi=311:489|0x01 time_ue_stayed_in_cell=100
    Execute egate command   cmd=ue_history_information_list id=1 action=commit
    Execute egate command   cmd=ue_enb_param id=${ue_id} ue_history_list=1

UE Deregister
    [Arguments]  ${ue_id}=1
    Deregister Ue    ue_id=${ue_id}  pass_regexp=UE CONTEXT RELEASE COMPLETE
    Log to console    UE: ${ue_id} deregistered ok
    Sleep  1s

Start Vm Ethernet Interfaces
    Start Vm Ethernet Interface    if_name=eth3:TCE        ip_with_mask=10.0.1.11/24
    Start Vm Ethernet Interface    if_name=eth3:SGNB3_S1U  ip_with_mask=10.0.1.125/24
    Start Vm Ethernet Interface    if_name=eth3:SGNB3_X2   ip_with_mask=10.0.1.124/24
    Start Vm Ethernet Interface    if_name=eth3:SGNB3_NG   ip_with_mask=10.0.1.123/24
    Start Vm Ethernet Interface    if_name=eth3:SGNB3_XN   ip_with_mask=10.0.1.122/24
    Start Vm Ethernet Interface    if_name=eth3:AMF2       ip_with_mask=10.0.1.102/24

    Start Vm Ethernet Interface    if_name=eth3:mme     ip_with_mask=10.0.1.131/24
    Start Vm Ethernet Interface    if_name=eth3:ser     ip_with_mask=10.0.1.132/24
    Start Vm Ethernet Interface    if_name=eth3:sgwu    ip_with_mask=10.0.1.133/24
    Start Vm Ethernet Interface    if_name=eth3:swg1    ip_with_mask=10.0.1.134/24
    Start Vm Ethernet Interface    if_name=eth3:enbx2u  ip_with_mask=10.0.1.135/24
    Start Vm Ethernet Interface    if_name=eth3:enbs1   ip_with_mask=10.0.1.136/24
    Start Vm Ethernet Interface    if_name=eth3:enbx2   ip_with_mask=10.0.1.137/24

    Start Vm Ethernet Interface    if_name=eth3:enb4s1   ip_with_mask=10.0.1.138/24
    Start Vm Ethernet Interface    if_name=eth3:enb4x2   ip_with_mask=10.0.1.139/24

Stop Vm Ethernet Interfaces
    Stop Vm Ethernet Interface    if_name=eth3:TCE         ip_with_mask=10.0.1.11/24
    Stop Vm Ethernet Interface    if_name=eth3:SGNB3_S1U   ip_with_mask=10.0.1.125/24
    Stop Vm Ethernet Interface    if_name=eth3:SGNB3_X2    ip_with_mask=10.0.1.124/24
    Stop Vm Ethernet Interface    if_name=eth3:SGNB3_NG    ip_with_mask=10.0.1.123/24
    Stop Vm Ethernet Interface    if_name=eth3:SGNB3_XN    ip_with_mask=10.0.1.122/24
    Stop Vm Ethernet Interface    if_name=eth3:AMF2        ip_with_mask=10.0.1.102/24

    Stop Vm Ethernet Interface    if_name=eth3:mme     ip_with_mask=10.0.1.131/24
    Stop Vm Ethernet Interface    if_name=eth3:ser     ip_with_mask=10.0.1.132/24
    Stop Vm Ethernet Interface    if_name=eth3:sgwu    ip_with_mask=10.0.1.133/24
    Stop Vm Ethernet Interface    if_name=eth3:swg1    ip_with_mask=10.0.1.134/24
    Stop Vm Ethernet Interface    if_name=eth3:enbx2u  ip_with_mask=10.0.1.135/24
    Stop Vm Ethernet Interface    if_name=eth3:enbs1   ip_with_mask=10.0.1.136/24
    Stop Vm Ethernet Interface    if_name=eth3:enbx2   ip_with_mask=10.0.1.137/24

    Stop Vm Ethernet Interface    if_name=eth3:enb4s1   ip_with_mask=10.0.1.138/24
    Stop Vm Ethernet Interface    if_name=eth3:enb4x2   ip_with_mask=10.0.1.139/24

Wait for gNB Configured state
    Log to console  Wait for gNB Configured state is Commissioned or Configured or IntegratedToRan or OnAir ..
    Wait Until Keyword Succeeds      5min     5sec     Ensure gNB state is Configured Or IntegratedToRan
    #Wait Until Keyword Succeeds      3min     5sec      Ensure cell is configured

Ensure gNB state is Configured Or IntegratedToRan
    Setup admin
    ${bts_state}=       Get Mrbts State
    ${current_date}=    Get Current Date
    Log to console    ${current_date} : BTS STATE : ${bts_state}
    Should Contain Any            ${bts_state}    Commissioned    Configured    IntegratedToRan    OnAir    ignore_case=${TRUE}
    [Teardown]    Teardown admin

Ensure cell is configured
    Setup admin
    ${cells_info}=           Get cells info
    ${procedural_status}=    Set variable     ${cells_info[0]['status']['proceduralStatus']}
    ${current_date}=         Get Current Date
    Log to console     ${current_date} : CELL STATE : ${procedural_status}
    Should be Equal As Strings       ${procedural_status}     configured      ignore_case=${TRUE}
    [Teardown]    Teardown admin

Set XNAP Protocol
    [Arguments]   ${file_name}
    ${XNAP}   OperatingSystem.Run   tshark -r ${OUTPUT_DIR}/${file_name} -P | grep -i xnap |awk 'NR==1{print $(NF-2)}'
    ${XNAP}   Strip String   ${XNAP}
    ${XNAP}   Convert To Lower Case   ${XNAP}

    Log to console  Detected XNAP version: ${XNAP}
    Set Global Variable  ${XNAP_VER}  ${XNAP}

Get Measurement Id For Frequency
    [Arguments]  ${ue_id}=1  ${event_type}=EventA3  ${carrier_freq}=0  ${trigger}=rsrp

    get_ue_measurement_configuration  ue_id=${ue_id}  alias=${ue_id}_meas

    ${meas_id}    get_meas_id_for_measurement_on_frequency  event_type=${event_type}  carrier_freq=${carrier_freq}
    ...    alias=${ue_id}_meas  trigger=${trigger}
    #Log to console  MeasId for ${event_type} on carrier freq ${carrier_freq} is: ${meas_id}

    RETURN    ${meas_id}

Send Swconfig for AP
    [Arguments]    ${ap_swconfig_path}
    Log to console  Send Swconfig for AP: ${ap_swconfig_path}..
    Setup Wts Fsm Access
    Put Wts File    ${ap_swconfig_path}    /ffs/run/swconfig.txt    partition=active
    Execute Command On Wts    crasign /ffs/run/swconfig.txt
    Execute Command On Wts    craverify /ffs/run/swconfig.txt /ffs/run/swconfig.txt.p7
    Teardown Wts Fsm Access

Stop Edaemon Egate
    ${edaemon_pid}=    Run    pgrep edaemon
    ${edaemon_status}    Run Keyword and Return Status    Should Not Be Empty    ${edaemon_pid}
    IF    ${edaemon_status}    Run    sudo pkill -9 edaemon
    ${egate_pid}=    Run    pgrep egate
    ${egate_status}    Run Keyword and Return Status    Should Not Be Empty    ${egate_pid}
    IF    ${egate_status}    Run    sudo pkill -9 egate

Links up
    Log to console  X2 and Xn Links up ..
    Xn link up
    Setup X2 link to gNB sim

Xn link up
    Log to console  Xn link up gNB3 to gNB2..
    Execute Egate Command  cmd=sim_state_disp
    Execute Egate Command  cmd=gnb_param id=3 xn_listening_socket=1 send_xn_setup=true measEvent=A3
    # In case real gnb inits xn link, ignore error:
    Run keyword and ignore error   Execute Egate Command  cmd=gnb_xn_link_up gnb=3 target=2  pass_regexp=GNB-3: XnAP Link with GNB-2
    #Execute Egate Command  cmd=gnb_xn_link_up gnb=3 target=2  pass_regexp=GNB-3: XnAP Link with GNB-2

Setup X2 link to gNB sim
    Log To Console  Setup X2 link to gNB sim..
    Run keyword and ignore error   Execute Egate Command  cmd=enb_x2_link_up enb=1 target=3  pass_regexp=is up

Perform Xn Handover
    [Arguments]    ${ue_id}=1  ${phycell_id}=381  ${direction}=outgoing  ${ho_failure}=${False}  ${carrier_freq}=0
    ...  ${carrier_freq2}=0  ${intrafreq}=${False}  ${RRE}=${True}  ${ue_ctx_release}=${False}  ${fallbackRRCSetup}=${False}
    ...  ${blacklist}=${False}

    ${time}    Get current date    result_format=%Y-%m%d_%H:%M:%SS    exclude_millis=${True}
    ${tcpdump_process}  ${log_filepath}  ${alias}  Start Tcpdump On Remote Interface
    ...  alias=XNAP_E1AP_F1AP_${ue_id}_${direction}_${time}  log_filename_prefix=${TEST_NAME}_UE${ue_id}_XNAP_E1AP_F1AP_${direction}_${time}
    ...  log_dirpath=${OUTPUT_DIR}/tshark
    Set Test Variable    ${TSHARKALIAS_XN}       ${alias}
    Set Test Variable    ${TSHARKALIAS_XN_PATH}  ${log_filepath}
    IF  "${blacklist}"=="${False}"  Sleep  2

    IF  "${ho_failure}"=="${False}"
      inter-gNB handover message flow Xn  ue_id=${ue_id}
    ELSE IF  "${ho_failure}"=="${True}"
      inter-gNB handover message flow Xn HO Prep Fail  ue_id=${ue_id}
      #inter-gNB handover message flow Xn Cancel  ue_id=${ue_id}
    END

    ${xnho}=  Set Variable If
    ...  "${ho_failure}"=="${True}"        HandoverPreparationFailure
    ...  "${ue_ctx_release}"=="${True}"    Unexpected timeout
    #Received RRC Release while
    ...  "${fallbackRRCSetup}"=="${True}"  reestablishment complete
    ...  "${RRE}"=="${False}"              Inter-eNB handover from
    ...  "${RRE}"=="${True}"               RRC Reestablishment sucessfully completed

    Log to console  Perform ${direction} Inter Gnb Xn Handover for UE: ${ue_id}, pass_regexp: ${xnho}

    # Enable inter-freq A3 via A2 event:
    IF  "${direction}"=="outgoing" and "${intrafreq}"!="${True}"
    ...  Get And Send A2 Meas Id  ue_id=${ue_id}  phycell_id=${phycell_id}  carrier_freq=${carrier_freq}
    # Trigger A3 event:
    Get And Send A3 Meas Id  ue_id=${ue_id}  phycell_id=${phycell_id}  carrier_freq=${carrier_freq2}
    ...  regexp=${xnho}

    Flow Occurred as expected  alias=UE${ue_id}_XN_Handover

    # Generate PDML
    #${filter}=  Set variable  e1ap or xnap or ngap or nr-rrc or f1ap
    #${out}=  Set variable  ${OUTPUT_DIR}/tshark/${TEST_NAME}_UE${ue_id}_${direction}.pdml
    #Set Test Variable  ${PDML}  ${out}
    #Run  tshark -Y "${filter}" -r ${OUTPUT_DIR}/tshark/${TEST_NAME}_UE${ue_id}_XNAP_E1AP_F1AP_${direction}_${time}.pcap -T pdml > ${out}

    Log to console  Xn Handover KW completed - UE: ${ue_id}, Direction: ${direction}
    Log  UE measurements after HO complete:
    # ignore error in case UE drops:
    Run keyword and ignore error   Print Measurements  ue_id=${ue_id}

    # SNStatusTransfer delay case to wait for all messages. Note in blacklist timer 10s case cannot sleep here:
    IF  "${blacklist}"=="${False}"  Sleep  5s

    RETURN  ${tcpdump_process}

Get And Send A1 Meas Id
    [Arguments]    ${ue_id}=1  ${phycell_id}=381  ${carrier_freq}=0

    ${meas_id}=  Get Measurement Id For Frequency  ue_id=${ue_id}  event_type=EventA1  carrier_freq=${carrier_freq}
    Log to console  Sending A1Event to enable covBasedA1 for CA

    Print Measurements  ue_id=${ue_id}

    Execute Egate Command
    ...  cmd=ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=72 phycell_id=${phycell_id} nrsrp_nr=100 ssinr_nr=127
    ...  pass_regexp=UEC-1: UE${ue_id}
    Sleep  1s

Get And Send A2 Meas Id
    [Arguments]    ${ue_id}=1  ${phycell_id}=381  ${carrier_freq}=0

    ${meas_id}=  Get Measurement Id For Frequency  ue_id=${ue_id}  event_type=EventA2  carrier_freq=${carrier_freq}
    Log to console  Sending A2Event to enable inter freq meas gaps with MeasId: ${meas_id}

    Print Measurements  ue_id=${ue_id}

    Execute Egate Command
    ...  cmd=ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 srsrp_nr=19 phycell_id=${phycell_id} nrsrp_nr=100
    ...  pass_regexp=UEC-1: UE${ue_id}
    Sleep  1s

Get And Send A3 Meas Id
    [Arguments]    ${ue_id}=1  ${phycell_id}=50  ${carrier_freq}=0  ${regexp}=FAIL

    ${meas_id}=  Get Measurement Id For Frequency  ue_id=${ue_id}  event_type=EventA3  carrier_freq=${carrier_freq}
    Log to console  Sending A3Event with MeasId: ${meas_id}

    Print Measurements  ue_id=${ue_id}

    ${ret1}=  Execute Egate Command
    ...  cmd=ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A3 srsrp_nr=19 phycell_id=${phycell_id} nrsrp_nr=100
    ...  pass_regexp=${regexp}

    RETURN  ${ret1}

Print Measurements
    [Arguments]    ${ue_id}=1
    ${out}  Execute Egate Command  cmd=ue_meas_cfg_disp id=${ue_id} meas_obj_type=nr  pass_regexp=NR MEASUREMENT IDENTITIES
    Log  UE MEAS NR: ${out}

    ${out}  Execute Egate Command  cmd=qosrule_disp  pass_regexp=Qosflow
    Log  QosFlows: ${out}

inter-gNB handover message flow Xn
    [Arguments]    ${ue_id}=1
    Expect Message Flow
    ...     gNB2:XNAP_HandoverRequest as HO_Req
    ...     gNB2:XNAP_HandoverRequestAcknowledge as HO_Req_Ack
    # Commented out due to EC19 handling, will be verified by other KWs
    #...     gNB2:XNAP_SNStatusTransfer
    ...     alias=UE${ue_id}_XN_Handover   overall_timeout=15

inter-gNB handover message flow Xn Cancel
    [Arguments]    ${ue_id}=1
    Expect Message Flow
    ...     gNB2:XNAP_HandoverRequest as HO_Req
    ...     gNB2:XNAP_HandoverRequestAcknowledge as HO_Req_Ack
    ...     gNB2:XNAP_HandoverCancel
    ...     alias=UE${ue_id}_XN_Handover   overall_timeout=15
    Sleep  5s

inter-gNB handover message flow Xn HO Prep Fail
    [Arguments]    ${ue_id}=1
    Expect Message Flow
    ...     gNB2:XNAP_HandoverRequest as HO_Req
    ...     gNB2:XNAP_HandoverPreparationFailure as HO_Prep_Fail
    ...     alias=UE${ue_id}_XN_Handover   overall_timeout=15
    Sleep  5s

Delta Commissioning Single Parameter Value
    [Arguments]  ${parameter}=NULL  ${value}=false  ${dist_name}=MRBTS-1/NRBTS-1
    Timestamp Prints  log=Delta Commissioning Single Parameter Value: ${dist_name}/${parameter}:${value} ..

    Perform Parameter Commissioning    dist_name=${dist_name}    parameter=${parameter}   value=${value}
    Wait for gNB Configured state
    Timestamp Prints  log=Delta Commissioning Single Parameter Value finished!

Get Measurement id
    [Arguments]  ${event_type}=EventA3  ${ue_id}=1  ${matching_line}=0
    Log to console  Get Measurement id for UE: ${ue_id}, event: ${event_type}
    ${measurements}=    Execute Egate Command And Wait For Data    cmd=ue_meas_cfg_disp id=${ue_id}  pass_regexp=${event_type}  timeout=10s
    ${matching_lines}=  Get Lines Containing String  ${measurements}  ${event_type}
    ${first_line}=  Get Line  ${matching_lines}  ${matching_line}
    @{words}=  Split String  ${first_line}
    Log to console  MeasId: ${words}[0] for event: ${words}[2] found for RAT: ${words}[1]
    RETURN  ${words}[0]

UE VoNR Call
    [Arguments]   ${ue_id}=1  ${pdu_id}=1

    Log to console  UE VoNR Call add 5QI-1 QoS flow for UE: ${ue_id}

    Execute Egate Command     cmd=ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id} qosflows_to_add=1 by=amf  pass_regexp=Added QosFlow with QFI
    Log to console  QoS flow 5qi1 added successfully

Verify Data Forwarding
   [Arguments]   ${ret1}=DEFAULT  ${pdu1}=${False}  ${pdu2}=${False}  ${pdu3}=${False}  ${pdu4}=${False}

   IF  "${pdu1}"=="${True}"
        ${tunnels}=  Get Lines Containing String  ${ret1}  For SEID: 1 for UE IP:
        Log to console  Data Forwarding tunnels for PDU:1 in incoming HO: ${tunnels}
   END

   IF  "${pdu2}"=="${True}"
        ${tunnels}=  Get Lines Containing String  ${ret1}  For SEID: 2 for UE IP:
        Log to console  Data Forwarding tunnels for PDU:2 in incoming HO: ${tunnels}
   END

   IF  "${pdu3}"=="${True}"
        ${tunnels}=  Get Lines Containing String  ${ret1}  For SEID: 3 for UE IP:
        Log to console  Data Forwarding tunnels for PDU:3 in incoming HO: ${tunnels}
   END

   IF  "${pdu4}"=="${True}"
        ${tunnels}=  Get Lines Containing String  ${ret1}  For SEID: 4 for UE IP:
        Log to console  Data Forwarding tunnels for PDU:4 in incoming HO: ${tunnels}
   END

Start And Stop Data On All QFIs
    [Arguments]  ${ue_id}=1  ${pdu}=1  ${qfis}=1  ${throughput}=1  ${CA}=${False}  ${timer}=10s  ${phys_pcell}=1
    ...  ${a1CovBasedCA}=${False}  ${carrier_freq}=126530

    Log to console  Start DL data: UE: ${ue_id} On All QFIs: ${qfis}, PDU: ${pdu}, tput: ${throughput} kbps, CA: ${CA}, a1CovBased: ${a1CovBasedCA}

    IF  "${CA}"=="${True}"
    ...  Log to console  CB008311: Data activity aware NR SCell addition and release verification for scell addition ..

    ${time}    Get current date    result_format=%Y-%m%d_%H:%M:%SS    exclude_millis=${True}
    ${tcpdump_process}  ${log_filepath}  ${alias}  Start Tcpdump On Remote Interface
    ...  alias=XNAP_E1AP_F1AP_${ue_id}_${time}  log_filename_prefix=${TEST_NAME}_UE${ue_id}_data_transfer_${time}
    ...  log_dirpath=${OUTPUT_DIR}/tshark
    Sleep  1s

    FOR    ${qfi}    IN    @{qfis}
      Execute Egate Command  cmd=trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} dir=dl kbps=${throughput}
      #Execute Egate Command  cmd=trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} dir=ul kbps=${throughput}
    END

    FOR    ${qfi}    IN    @{qfis}
      Execute Egate Command And Wait For Data  cmd=trf_internal_disp ue=${ue_id} pdu=${pdu} qfi=${qfi} dir=dl
    END

    IF  "${a1CovBasedCA}"=="${True}"
    ...  Get And Send A1 Meas Id  ue_id=${ue_id}  phycell_id=${phys_pcell}  carrier_freq=${carrier_freq}

    # Wait CA to trigger:
    Sleep  ${timer}
    Verify CA allocation  pcell=${phys_pcell}  sCellToAddModList=1  alias=${alias}  alias_path=${log_filepath}

    kill_tshark_process  ${tcpdump_process}

    Log to console  Stop Data For UE: ${ue_id} On All QFIs: ${qfis}, PDU: ${pdu}
    FOR    ${qfi}    IN    @{qfis}
      Execute Egate Command  cmd=trf_data_stop ue=${ue_id} pdu=${pdu} qfi=${qfi} dir=dl
    END

Verify FullConfig
    [Arguments]  ${fullConfigSet}=${False}

    Log to console  Verify CB008699 FullConfig is ${fullConfigSet}, tshark alias: ${TSHARKALIAS_XN}

    ${found}=  Set Variable If
    ...  "${fullConfigSet}"=="${False}"  !
    ...  "${fullConfigSet}"=="${True}"   ${EMPTY}

    ${foundSourceConfig}=  Set Variable If
    ...  "${fullConfigSet}"=="${False}"  ${EMPTY}
    ...  "${fullConfigSet}"=="${True}"   !

    # SourceConfig:
    ${filter1}=  Set Variable  f1ap.UEContextSetupRequest_element && ${foundSourceConfig}nr-rrc.sourceConfig_element

    Verify Tshark For Single Message
    ...    alias=${TSHARKALIAS_XN}  packet_filter=${filter1}
    ...    pcap_file_path=${TSHARKALIAS_XN_PATH}  timeout=10

    Log to console  Verify SourceConfig IE in UEContextSetupRequest: Check msg with filter=${filter1} verified OK!

    ${filter1}=  Set Variable  f1ap.UEContextSetupResponse_element && ${found}f1ap.id == 94

    Verify Tshark For Single Message
    ...    alias=${TSHARKALIAS_XN}  packet_filter=${filter1}
    ...    pcap_file_path=${TSHARKALIAS_XN_PATH}  timeout=10

    Log to console  Verify FullConfig IE in UEContextSetupResponse: Check msg with filter=${filter1} verified OK!

    ${filter1}=  Set Variable  xnap.HandoverRequestAcknowledge_element && ${found}nr-rrc.fullConfig

    Verify Tshark For Single Message
    ...    alias=${TSHARKALIAS_XN}  packet_filter=${filter1}
    ...    pcap_file_path=${TSHARKALIAS_XN_PATH}  timeout=10

    Log to console  Verify FullConfig IE in HandoverRequestAcknowledge: Check msg with filter=${filter1} verified OK!

Set Sim Automatic Neighbour Relation
    [Arguments]  ${pci}=50

    Log to console  Set Sim Automatic Neighbour Relation to pci: ${pci}
    IF  "${pci}"=="50"
      Execute Egate Command  cmd=gnb_cell_param id=1 gnb=3 enable_anr=on neighbor_pci=16:2
      Execute Egate Command  cmd=gnb_cell_param id=2 gnb=3 enable_anr=on neighbor_pci=16:2
    ELSE IF  "${pci}"=="51"
      Execute Egate Command  cmd=gnb_cell_param id=1 gnb=3 enable_anr=on neighbor_pci=17:0
      Execute Egate Command  cmd=gnb_cell_param id=2 gnb=3 enable_anr=on neighbor_pci=17:0
    ELSE
        Log to console  Error: Unsupported cell with PCI: ${pci}!
    END

Set Default Bearer And Additional QoS Flows
    [Arguments]  ${def_qosflow}  ${add_qosflows}  ${integrity_prot}=${False}

    Log to console  Set Default Bearer And Additional QoS Flows .. Default bearer qos flow: ${def_qosflow}, additional qos flows: ${add_qosflows}

    Execute Egate Command  cmd=qosflow_modify qos_flow=${def_qosflow} default=on
    Execute Egate Command  cmd=smf_param id=1 reset
    IF  "${add_qosflows}"!="None"  Execute Egate Command  cmd=smf_param id=1 additional_qosflows_to_activate=${add_qosflows}

    # Activates 'CB008116-A U-Plane Integrity Protection Functionality' on Airphone side.. Causes problems if data is active ..
    IF  "${integrity_prot}"=="${True}"
    ...  Execute Egate Command  cmd=smf_param id=1 security_indication=pdu_session_setup:required:preferred max_data_rate=64kbps

Verify CA allocation
    [Arguments]  ${pcell}=1  ${sCellToAddModList}=1  ${alias}=${TSHARKALIAS_XN}  ${alias_path}=${TSHARKALIAS_XN_PATH}

    ${pci}=  Set Variable If
    ...  "${pcell}"=="1"    51
    ...  "${pcell}"=="2"    50
    # XnHO part:
    ...  "${pcell}"=="50"   51
    ...  "${pcell}"=="51"   50

    ${F1AP_SCELL_TO_ADD_MOD_LIST}=    Set Variable
    ...  nr-rrc.c1 == 0 && nr-rrc.sCellToAddModList == ${sCellToAddModList} && nr-rrc.sCellIndex == 1 && nr-rrc.physCellId == ${pci}

    Verify Tshark For Single Message
    ...    alias=${alias}  packet_filter=${F1AP_SCELL_TO_ADD_MOD_LIST}
    ...    pcap_file_path=${alias_path}  timeout=5

    Log to console  Verify CA allocation for scell: ${pci}, sCellToAddModList: ${sCellToAddModList} OK!

Verify Pre-emption
    [Arguments]    ${alias}=${TSHARKALIAS_XN}  ${alias_path}=${TSHARKALIAS_XN_PATH}

    # procedureCode: id-UEContextReleaseRequest (10)
    # radioNetwork: release-due-to-pre-emption (16)

    ${PREEMPT}=    Set Variable
    ...  (f1ap.procedureCode == 10) && (f1ap.radioNetwork == 16)

    Verify Tshark For Single Message
    ...    alias=${alias}  packet_filter=${PREEMPT}
    ...    pcap_file_path=${alias_path}  timeout=10

    Log to console  Verify Pre-emption OK!

Verify RRCReconfiguration And PathSwitch And SNStatusTransfer
    [Arguments]    ${alias}=${TSHARKALIAS_XN}  ${alias_path}=${TSHARKALIAS_XN_PATH}  ${fallbackRRCSetup}=${False}

    ${Reconfig}=    Set Variable
    ...  (f1ap.DLRRCMessageTransfer_element && nr-rrc.rrcReconfiguration_element && nr-rrc.criticalExtensions == 0)

    ${ReconfigComplete}=    Set Variable
    ...  (f1ap.ULRRCMessageTransfer_element && nr-rrc.rrcReconfigurationComplete_element && nr-rrc.criticalExtensions == 0)

    IF  "${fallbackRRCSetup}"=="${False}"
        Verify Tshark For Single Message
        ...    alias=${alias}  packet_filter=ngap.PathSwitchRequest_element
        ...    pcap_file_path=${alias_path}  timeout=10
        Verify Tshark For Single Message
        ...    alias=${alias}  packet_filter=ngap.PathSwitchRequestAcknowledge_element
        ...    pcap_file_path=${alias_path}  timeout=10
    END

    # Verify that at least one RRCReconfig is there, not checking measgap/drx etc subsequent msgs..
    Verify Tshark
    ...    alias=${alias}  packet_filter=${Reconfig}
    ...    pass_criteria=>=1  pcap_file_path=${alias_path}
    ...    timeout=5  continue_on_failure=${False}

    # Verify that at least one RRCReconfigComplete is there
    Verify Tshark
    ...    alias=${alias}  packet_filter=${ReconfigComplete}
    ...    pass_criteria=>=1  pcap_file_path=${alias_path}
    ...    timeout=5  continue_on_failure=${False}

    Verify Tshark For Single Message
    ...    alias=${alias}  packet_filter=xnap.SNStatusTransfer_element
    ...    pcap_file_path=${alias_path}  timeout=10

    Log to console  Verify RRCReconfiguration And PathSwitch And SNStatusTransfer msgs OK after RRE procedure!

Verify A4event Activation
    [Arguments]    ${alias}=${TSHARKALIAS_XN}  ${alias_path}=${TSHARKALIAS_XN_PATH}

    ${ReconfigWithA4}=    Set Variable
    #eventId: eventA4 (3)
    ...  (f1ap.DLRRCMessageTransfer_element && nr-rrc.rrcReconfiguration_element && nr-rrc.criticalExtensions == 0 && nr-rrc.eventId == 3)

    Verify Tshark For Single Message
    ...    alias=${alias}  packet_filter=${ReconfigWithA4}
    ...    pcap_file_path=${alias_path}  timeout=10

    Log to console  Verify A4 Event Activation OK after RRE procedure!

Verify A1event Activation
    [Arguments]    ${alias}=${TSHARKALIAS_XN}  ${alias_path}=${TSHARKALIAS_XN_PATH}

    ${ReconfigWithA1}=    Set Variable
    #eventId: eventA1 (0)
    ...  (f1ap.DLRRCMessageTransfer_element && nr-rrc.rrcReconfiguration_element && nr-rrc.criticalExtensions == 0 && nr-rrc.eventId == 0)

    Verify Tshark For Single Message
    ...    alias=${alias}  packet_filter=${ReconfigWithA1}
    ...    pcap_file_path=${alias_path}  timeout=10

    Log to console  Verify A1 Event Activation OK after RRE procedure!

Start PCMD Capture
    Log to console  Start PCMD capture..
    Start Tshark  log_filename=${TEST_NAME}_pcmd.pcap  eth_interface=eth3:TCE  capture_filter=host 10.0.1.11
    ...    log_dirpath=${OUTPUT_DIR}/a2a  alias=PCMD
    Sleep  2s

Stop PCMD Capture and Convert To TXT
    Log to console  Stop PCMD Capture and Convert To TXT ..
    Sleep  2s
    ${time}    Get current date    result_format=%Y-%m%d_%H:%M:%S    exclude_millis=${True}

    Stop Tshark  alias=PCMD
    ${VAR1}=  Set variable  tshark -o ntrstr.defragment:TRUE -d tcp.port==15000-15100,ntrstr -d tcp.port==49151,ntrstr -r
    ${VAR2}=  Set variable  ${OUTPUT_DIR}/a2a/${TEST_NAME}_pcmd.pcap -V > ${OUTPUT_DIR}/a2a/${TEST_NAME}_PCMD_${time}.txt
    Log  Tshark decoding cmd: ${VAR1} ${VAR2}
    Run  ${VAR1} ${VAR2}
    # Copy latest step file for analysis later and store all pcmd txt instances with timestamp:
    Run  cp ${OUTPUT_DIR}/a2a/${TEST_NAME}_PCMD_${time}.txt ${OUTPUT_DIR}/a2a/wireshark.txt
    Run  cp ${OUTPUT_DIR}/a2a/${TEST_NAME}_pcmd.pcap ${OUTPUT_DIR}/a2a/${TEST_NAME}_PCMD_${time}.pcap

Check Log With Au2analysis
    [Arguments]  ${ini_file}
    Log to console  A2A analyze ${OUTPUT DIR}/a2a/wireshark.txt file contents against ${ini_file}
    Check Log With Au2anlysis    ini_path=${ROBOT_SUITE_DIR}/../Common/a2a/${ini_file}  log_need_to_check=w  save_log_directory=${OUTPUT DIR}/a2a
    Run    cp ${OUTPUT DIR}/a2a/wireshark.txt.a2a_decode ${OUTPUT DIR}/a2a/${TEST_NAME}_wireshark.txt.a2a_decode

Replace PDM Info In A2A Ini File
    [Arguments]   ${ini_file}=test.ini  ${PDM_file}=test.pdm  ${step}=1
    Log to console  Replace PDM Info In A2A Ini File. ini_file: ${ini_file} pdm_file: ${PDM_file}

    Run    sed -i 's/PARADIGM.*/PARADIGM: .\\\\${PDM_file}/g' ${ROBOT_SUITE_DIR}/../Common/a2a/${ini_file}
    # Backup changed file as part of testlogs:
    Run    cp ${ROBOT_SUITE_DIR}/a2a/${ini_file} ${OUTPUT DIR}/a2a/${TEST_NAME}_step${step}_${ini_file}

Replace Field Value in PDM File
    [Arguments]   ${pdm_file}=test.pdm  ${field}=trigger  ${value}=1  ${step}=1
    Log to console  Replace Field Value in PDM File: ${ROBOT_SUITE_DIR}/../Common/a2a/${pdm_file} field: ${field} value: ${value}
    Run    sed -i 's/${field}.=.*/${field} = ${value}/' ${ROBOT_SUITE_DIR}/../Common/a2a/${pdm_file}
    # Backup changed file as part of testlogs:
    Run    cp ${ROBOT_SUITE_DIR}/../Common/a2a/${pdm_file} ${OUTPUT DIR}/${TEST_NAME}_step${step}_${pdm_file}

Modify A2A Ini File Template And Run A2A Analysis
    [Arguments]  ${PDM_file}  ${step}
    Replace PDM Info In A2A Ini File  ini_file=Template.ini  PDM_file=${PDM_file}  step=${step}
    Check Log With Au2analysis  ini_file=Template.ini

Start TCE
    Timestamp Prints  log=Start TCE
    SSHLibrary.open connection    10.0.1.11    timeout=30 seconds
    SSHLibrary.Login With Public Key    ute    /home/ute/.ssh/id_rsa
    SSHLibrary.Write    nc -lvnp 49151 &> /home/ute/logs/tce_49151.txt&
    #${status}    Run Keyword And Return Status    Check Connection between GNB and L3DC
    #Timestamp Prints  log=TCE connected from gNB: 10.0.1.2 ..

Check Connection between GNB and L3DC
    wait until keyword succeeds    30s    5s    Check That Trace Connection Is Established

Check That Trace Connection Is Established
    ${output}    Run    cat /home/ute/logs/tce_49151.txt |grep -a "10.0.1.2"
    Should contain    ${output}    Connection from 10.0.1.2
    Sleep  1s

Set UE RRC Reestablishment Param
    [Arguments]    ${ue_id}=1  ${action}=${EMPTY}
    Log to console  Set UE RRC Reestablishment Param for UE: ${ue_id} with action=${action}
    Execute egate command  cmd=ue_rrc_reestablish_param id=${ue_id} if_contains=any action=${action}

Reset UE Params
    [Arguments]    ${ue_id}=1
    Log to console  Reset UE Params for UE: ${ue_id}
    Execute Egate Command  cmd=ue_gnb_ho_param id=${ue_id} gnb=3 reset
    Execute Egate Command  cmd=gnb_param id=3 ciphering_algorithm=nea0 integrityprotection_algorithm=nia2
    Execute Egate Command  cmd=gnb_xn_status_transfer_param id=3 reset
    Configure Sidelink IE in Xn Handover  enable_sidelink=false
    Execute Egate Command  cmd=gnb_param id=3 xn_listening_socket=1 send_xn_setup=true measEvent=A3
    #Execute Egate Command  cmd=gnb_xn_handover_preparation_param id=3 include_security_config=false
    Execute egate command  cmd=ue_rrc_reestablish_param id=1 reset
    Execute egate command  cmd=ue_rrc_reestablish_param id=2 reset
    Execute egate command  cmd=ue_rrc_reestablish_param id=3 reset
    Execute egate command  cmd=ue_rrc_reestablish_param id=4 reset
    Execute egate command  cmd=ue_rrc_reestablish_param id=5 reset
    Execute egate command  cmd=ue_rrc_reestablish_param id=6 reset
    Execute egate command  cmd=ue_rrc_reestablish_param id=7 reset
    Execute egate command  cmd=ue_rrc_reestablish_param id=8 reset
    Execute egate command  cmd=ue_nr_rrc_reconf_param id=1 reset
    Execute egate command  cmd=ue_nr_rrc_reconf_param id=2 reset
    Execute egate command  cmd=ue_nr_rrc_reconf_param id=3 reset
    Execute egate command  cmd=ue_nr_rrc_reconf_param id=4 reset
    Execute egate command  cmd=ue_nr_rrc_reconf_param id=5 reset
    Execute egate command  cmd=ue_nr_rrc_reconf_param id=6 reset
    Execute egate command  cmd=ue_nr_rrc_reconf_param id=7 reset
    Execute egate command  cmd=ue_nr_rrc_reconf_param id=8 reset

Perform UE RRC Reestablishment
    [Arguments]    ${ue_id}=1  ${gnb_id}=2  ${cell_id}=1  ${action}=${EMPTY}  ${cause}=otherFailure
    Log to console  Perform UE RRC Reestablishment for UE: ${ue_id}, gNB: ${gnb_id}, cell: ${cell_id}, action: ${action}, cause: ${cause}

    IF  "${action}"=="${EMPTY}"
        Execute Egate Command
        ...  cmd=ue_rrc_reestablish id=${ue_id} gnb=${gnb_id} cell=${cell_id} cause=${cause}
        ...  pass_regexp=RRC Reestablishment sucessfully completed  timeout=15s
    ELSE
        Execute Egate Command
        ...  cmd=ue_rrc_reestablish id=${ue_id} gnb=${gnb_id} cell=${cell_id} cause=${cause} action=${action}
        ...  pass_regexp=rrcSetup  timeout=15s
    END
    # Should it be fallback to RRC Setup check on pass_regexp above??

Set UE RRC Reestablishment During RRCReconfiguration
    [Arguments]    ${ue_id}=1  ${gnb_id}=2  ${cell_id}=1  ${cause}=otherFailure  ${crnti}=source  ${action}=reestablish  ${nth}=1
    ...  ${num_reest_reqs}=1
    Log to console
    ...  Set UE RRC Reestablishment During RRCReconf UE: ${ue_id}, gNB: ${gnb_id}, Cell: ${cell_id}, Cause: ${cause}, CRNTI: ${crnti}, nth: 1

    ${cmd}  Catenate  ue_nr_rrc_reconf_param id=${ue_id} if_contains=any action=${action} gnb=${gnb_id}
    ...  cell=${cell_id} cause=${cause} crnti=${crnti} nth=${nth} num_reestablishment_reqs=${num_reest_reqs}

    Execute egate command  cmd=${cmd}

Set UE To Drop Or Send Invalid RRC Reconfiguration Complete After RRE
    [Arguments]    ${ue_id}=1  ${gnb_id}=2  ${cell_id}=1  ${crnti}=source  ${action}=reestablish
    ...  ${action2}=drop
    Log to console
    ...  Set UE To Drop Or Send Invalid RRC Reconfiguration Complete After RRE: UE: ${ue_id}, gNB: ${gnb_id}, Cell: ${cell_id}
    Log to console  Action nth=1 ${action}, Action nth=2 ${action2}, Fixed cause: otherFailure

    ${cmd}  Catenate  ue_nr_rrc_reconf_param id=${ue_id} if_contains=any action=${action} cell=${cell_id} gnb=${gnb_id}
    ...  crnti=${crnti} if_contains=any action=${action2} nth=2

    Execute egate command  cmd=${cmd}

Check Need Of Fresh PM Counter Interval
    ${status}  ${sMin}  ${sSec}  need_to_wait_for_counter_interval
    IF  "${status}"=="${True}"
        Log To Console  Need to wait for fresh interval, timing=${sMin}:${sSec} ..
        Get Next Unpacked Full Pm Counters File  output_dirpath=${OUTPUT DIR}/pm
    ELSE IF  "${status}"=="${False}"
        Log To Console  No need to wait for fresh interval, timing=${sMin}:${sSec} ..
    END

Verify RRE Msg Flow
    [Arguments]  ${fallbackRRCSetup}=${False}  ${dropReestComplete}=${False}  ${alias}=${TSHARKALIAS_XN}  ${alias_path}=${TSHARKALIAS_XN_PATH}
    ...  ${RRE_req_times}=1

    ${ReestablishReq}=    Set Variable
    # c1: rrcReestablishmentRequest (2)
    ...  nr-rrc.c1 == 2 && nr-rrc.rrcReestablishmentRequest_element

    ${Reestablish}=    Set Variable
    # c1: rrcReestablishment (3)
    ...  nr-rrc.c1 == 3 && nr-rrc.rrcReestablishment_element

    ${ReestablishComplete}=    Set Variable
    # c1: rrcReestablishmentComplete (3)
    ...  nr-rrc.c1 == 3 && nr-rrc.rrcReestablishmentComplete_element

    ${RRCSetup}=    Set Variable
    # c1: rrcSetup
    ...  nr-rrc.c1 == 1 && nr-rrc.rrcSetup_element

    Verify Tshark
    ...    alias=${alias}  packet_filter=${ReestablishReq}
    ...    pass_criteria=>=${RRE_req_times}  pcap_file_path=${alias_path}
    ...    timeout=5  continue_on_failure=${False}

    IF  "${fallbackRRCSetup}"=="${False}"
        Verify Tshark For Single Message
        ...    alias=${alias}  packet_filter=${Reestablish}
        ...    pcap_file_path=${alias_path}  timeout=5
        Verify Tshark For Single Message
        ...    alias=${alias}  packet_filter=${ReestablishComplete}
        ...    pcap_file_path=${alias_path}  timeout=5
        Log to console  Verify RRE Msg Flow OK!
    ELSE IF  "${fallbackRRCSetup}"=="${True}" and "${dropReestComplete}"=="${False}"
        Verify Tshark For Single Message
        ...    alias=${alias}  packet_filter=${RRCSetup}
        ...    pcap_file_path=${alias_path}  timeout=5
        Log to console  Verify RRE -> Fallback to RRCSetup Msg Flow OK!
    END
    IF  "${dropReestComplete}"=="${True}"  Log to console  Verify RRE + drop dropReestComplete -> Error scenario Flow OK!

Configure Sidelink IE in Xn Handover
    [Arguments]  ${enable_sidelink}=false
    #Log to console  Configure Sidelink IE in Xn Handover with AP to value: ${enable_sidelink} ..
    Execute Egate Command  cmd=gnb_xn_handover_preparation_param id=3 include_sidelink=${enable_sidelink}

Verify Sidelink Release During RRE
    [Arguments]  ${alias}=${TSHARKALIAS_XN}  ${alias_path}=${TSHARKALIAS_XN_PATH}

    ${SidelinkIE}=    Set Variable  (xnap.HandoverRequest_element && nr-rrc.sidelinkUEInformationNR_r16)

    # todo add sidelink rel when wshark can decode it fully, now just use non-crit extension to verify:
    ${SidelinkRel}=    Set Variable
    ...  (nr-rrc.rrcReestablishment_element && nr-rrc.nonCriticalExtension_element)

    Verify Tshark For Single Message
    ...    alias=${alias}  packet_filter=${SidelinkIE}
    ...    pcap_file_path=${alias_path}  timeout=5

    Verify Tshark For Single Message
    ...    alias=${alias}  packet_filter=${SidelinkRel}
    ...    pcap_file_path=${alias_path}  timeout=5

    Log to console  Verify Sidelink Release During RRE OK!

Configure ReestablishmentInfo For Xn Handover
    [Arguments]  ${tgt_cell_info}=${EMPTY}  ${prep_cell_list}=${EMPTY}

    Log to console  Configure ReestablishmentInfo with target cell: ${tgt_cell_info}, prepared cell: ${prep_cell_list}

    IF  "${tgt_cell_info}"=="${EMPTY}" and "${prep_cell_list}"=="${EMPTY}"
      Execute Egate Command  cmd=gnb_xn_handover_preparation_param id=3 reset
    ELSE IF  "${tgt_cell_info}"=="${EMPTY}" and "${prep_cell_list}"!="${EMPTY}"
      Execute Egate Command  cmd=gnb_xn_handover_preparation_param id=3 reestab_ncell_info=${prep_cell_list}
    ELSE IF  "${tgt_cell_info}"!="${EMPTY}" and "${prep_cell_list}"!="${EMPTY}"
      Execute Egate Command  cmd=gnb_xn_handover_preparation_param id=3 reestab_info=${tgt_cell_info} reestab_ncell_info=${prep_cell_list}
    ELSE IF  "${tgt_cell_info}"!="${EMPTY}" and "${prep_cell_list}"=="${EMPTY}"
      Execute Egate Command  cmd=gnb_xn_handover_preparation_param id=3 reestab_info=${tgt_cell_info}
    END

    # Print values:
    Execute Egate Command  cmd=gnb_xn_handover_preparation_param id=3
    Execute Egate Command  cmd=gnb_xn_status_transfer_param id=1

Verify Partial HO
    [Arguments]  ${alias}=${TSHARKALIAS_XN}  ${alias_path}=${TSHARKALIAS_XN_PATH}

    ${PartHO}=    Set Variable
    # radioNetwork: slice-not-supported-by-NG-RAN (45)
    ...  (xnap.PDUSessionResourcesNotAdmitted_List == 2 && xnap.radioNetwork == 45)

    Verify Tshark For Single Message
    ...    alias=${alias}  packet_filter=${PartHO}
    ...    pcap_file_path=${alias_path}  timeout=5

    Log to console  Verify CB008700 Partial HO OK!

Verify DRB and Bearer Release List In Partial HO
    Verify DRBToReleaseList In Partial HO
    Verify BearerToReleaseList In Partial HO

Verify DRBToReleaseList In Partial HO
    [Arguments]  ${alias}=${TSHARKALIAS_XN}  ${alias_path}=${TSHARKALIAS_XN_PATH}

    ${DrbReleaseInRRCReconfig}=    Set Variable
    ...  (f1ap.procedureCode == 12 && nr-rrc.c1 == 0 && nr-rrc.drb_ToReleaseList)

    Verify Tshark For Single Message
    ...    alias=${alias}  packet_filter=${DrbReleaseInRRCReconfig}
    ...    pcap_file_path=${alias_path}  timeout=5

    Log to console  Verify DRBToReleaseList during Partial HO OK!

Verify BearerToReleaseList In Partial HO
    [Arguments]  ${alias}=${TSHARKALIAS_XN}  ${alias_path}=${TSHARKALIAS_XN_PATH}

    ${BearerReleaseInRRCReconfig}=    Set Variable
    ...  (f1ap.procedureCode == 12 && nr-rrc.c1 == 0 && nr-rrc.rlc_BearerToReleaseList)

    Verify Tshark For Single Message
    ...    alias=${alias}  packet_filter=${BearerReleaseInRRCReconfig}
    ...    pcap_file_path=${alias_path}  timeout=5

    Log to console  Verify BearerToReleaseList during Partial HO OK!

Verify ReestablishmentInfo In Ho Req
    [Arguments]  ${phycell_id}=${False}  ${ReestablishmentInfo}=${False}  ${ReestabNCellInfo}=${False}
    ...  ${alias}=${TSHARKALIAS_XN}  ${alias_path}=${TSHARKALIAS_XN_PATH}

    ${ReestInfoTrue}  Catenate  (xnap.HandoverRequest_element && nr-rrc.reestablishmentInfo_element &&
    ...  nr-rrc.sourcePhysCellId == ${ReestablishmentInfo} && nr-rrc.targetCellShortMAC_I)

    ${ReestablishmentInfo_filter}=  Set Variable If
    ...  "${ReestablishmentInfo}"=="${False}"  (xnap.HandoverRequest_element && !nr-rrc.reestablishmentInfo_element)
    ...  "${ReestablishmentInfo}"!="${False}"  ${ReestInfoTrue}

    # Prepared cell is the other cell than tgt cell, for 50 it is 51 and for 381 it is 382 ..
    ${ncell}=  Set Variable If
    ...  "${phycell_id}"=="${False}"   !nr-rrc.cellIdentity
    ...  "${phycell_id}"=="50"   nr-rrc.cellIdentity == 00:00:04:00:20
    ...  "${phycell_id}"=="51"   nr-rrc.cellIdentity == 00:00:04:00:10
    ...  "${phycell_id}"=="381"  nr-rrc.cellIdentity == 00:00:0c:00:20
    ...  "${phycell_id}"=="382"  nr-rrc.cellIdentity == 00:00:0c:00:10

    ${ReestNCellInfoTrue}  Catenate  (xnap.HandoverRequest_element && nr-rrc.additionalReestabInfoList && ${ncell} &&
    ...  nr-rrc.key_gNodeB_Star && nr-rrc.shortMAC_I)

    ${ReestabNCellInfo_filter}=  Set Variable If
    ...  "${ReestabNCellInfo}"=="${False}"  (xnap.HandoverRequest_element && !nr-rrc.additionalReestabInfoList)
    ...  "${ReestabNCellInfo}"=="${True}"   ${ReestNCellInfoTrue}

    Verify Tshark For Single Message
    ...    alias=${alias}  packet_filter=${ReestablishmentInfo_filter} && ${ReestabNCellInfo_filter}
    ...    pcap_file_path=${alias_path}  timeout=5

    Log to console  Verify HO Req: ReestInfo: ${ReestablishmentInfo}, ReestNCellInfo: ${ReestabNCellInfo}, PrepCell: ${ncell} OK!

Verify SecurityConfig In Ho Req
    [Arguments]  ${nia}=nia2  ${nea}=nea0  ${alias}=${TSHARKALIAS_XN}  ${alias_path}=${TSHARKALIAS_XN_PATH}

    ${SecurityConfig}=  Set Variable  (xnap.HandoverRequest_element && nr-rrc.securityConfig_element)

    ${nia_used}=  Set Variable If
    ...  "${nia}"=="nia0"   0
    ...  "${nia}"=="nia1"   1
    ...  "${nia}"=="nia2"   2
    ...  "${nia}"=="nia3"   3

    ${nea_used}=  Set Variable If
    ...  "${nea}"=="nea0"   0
    ...  "${nea}"=="nea1"   1
    ...  "${nea}"=="nea2"   2
    ...  "${nea}"=="nea3"   3

    ${nia_nea}=  Set Variable  (nr-rrc.integrityProtAlgorithm == ${nia_used} && nr-rrc.cipheringAlgorithm == ${nea_used})

    Verify Tshark For Single Message
    ...    alias=${alias}  packet_filter=(${SecurityConfig} && ${nia_nea})
    ...    pcap_file_path=${alias_path}  timeout=5

    Log to console  Verify SecurityConfig In Ho Req with NIA: ${nia_used}, NEA: ${nea_used} OK!

Verify UEContextRelease During Failed RRE
    [Arguments]  ${alias}=${TSHARKALIAS_XN}  ${alias_path}=${TSHARKALIAS_XN_PATH}  ${times}=1
    ...  ${rrcRelease}=${False}

    ${UECtxReleaseCmd}=    Set Variable
    ...  (f1ap.procedureCode == 6 && f1ap.UEContextReleaseCommand_element)

    ${UECtxReleaseComplete}=    Set Variable
    ...  (f1ap.procedureCode == 6 && f1ap.UEContextReleaseComplete_element)

    ${rrcRel}=    Set Variable
    ...  (f1ap.procedureCode == 6 && nr-rrc.rrcRelease_element)


    Verify Tshark
    ...    alias=${alias}  packet_filter=${UECtxReleaseCmd}
    ...    pass_criteria=>=${times}  pcap_file_path=${alias_path}
    ...    timeout=5  continue_on_failure=${False}

    Verify Tshark
    ...    alias=${alias}  packet_filter=${UECtxReleaseComplete}
    ...    pass_criteria=>=${times}  pcap_file_path=${alias_path}
    ...    timeout=5  continue_on_failure=${False}

    IF  "${rrcRelease}"=="${True}"      Verify Tshark
    ...    alias=${alias}  packet_filter=${rrcRel}
    ...    pass_criteria=>=${times}  pcap_file_path=${alias_path}
    ...    timeout=5  continue_on_failure=${False}

    Log to console  Verify UEContextRelease During Failed RRE, Check also rrcRelease: ${rrcRelease}, times: ${times} OK!

Delta Commission With Json
    [Arguments]  ${json}
    Timestamp Prints  log=Delta Commission With Json file: ${json} started ..
    Find SCFC and Send Delta Commissioning    scfc_filename=${json}
    Wait for gNB Configured state
    Timestamp Prints  log=Delta Commission With Json file: ${json} complete

Delta Commissioning NIA And NEA List
  [Arguments]   ${nia0}=0  ${nia1}=0  ${nia2}=0  ${nia3}=0
  ...  ${nea0}=0  ${nea1}=0  ${nea2}=0  ${nea3}=0

  &{integrityProtPrefL_dict}    Create Dictionary    nia0=${nia0}    nia1_128=${nia1}    nia2_128=${nia2}    nia3_128=${nia3}
  @{integrityProtPrefL_list}    Evaluate    [&{integrityProtPrefL_dict}]

  &{cipherprefl_dict}    Create Dictionary    nea0=${nea0}    nea1_128=${nea1}    nea2_128=${nea2}    nea3_128=${nea3}
  @{cipherprefl_list}    Evaluate    [&{cipherprefl_dict}]

  Timestamp Prints  log=Delta Commissioning NIA And NEA List: integrity=${integrityProtPrefL_list}, cipher=${cipherprefl_list}

  Perform Parameter Commissioning  dist_name=MRBTS-1/NRBTS-1  parameter=integrityProtPrefL  value=${integrityProtPrefL_list}

  IF  "${nea0}"!="0" or "${nea1}"!="0" or "${nea2}"!="0" or "${nea3}"!="0"
  ...  Perform Parameter Commissioning  dist_name=MRBTS-1/NRBTS-1  parameter=cipherPrefL  value=${cipherprefl_list}
  Ensure cell is configured
  Timestamp Prints  log=Delta Commissioning NIA And NEA List done!

Set Ciphering And Integrity Protection Algorithms On Sim gNB
  [Arguments]   ${gnb_id}=3  ${nia}=nia1  ${nea}=nea1

  Log To Console  Set Ciphering And Integrity Protection Algorithms On Sim gNB, NIA: ${nia}, NEA: ${nea}
  Execute Egate Command  cmd=gnb_param id=${gnb_id} ciphering_algorithm=${nea} integrityprotection_algorithm=${nia}

    #${nia_used}=  Set Variable If
    #...  "${nia}"=="nia0"   null
    #...  "${nia}"=="nia1"   snow3g
    #...  "${nia}"=="nia2"   aes
    #...  "${nia}"=="nia3"   zuc
    #
    #${nea_used}=  Set Variable If
    #...  "${nea}"=="nea0"   null
    #...  "${nea}"=="nea1"   snow3g
    #...  "${nea}"=="nea2"   aes
    #...  "${nea}"=="nea3"   zuc

  Execute Egate Command
  ...  cmd=gnb_xn_handover_preparation_param id=3 include_security_config=true sec_config_nea=${nea} sec_config_nia=${nia}

Verify CB008574 Related RD Counters
    [Arguments]   ${file}  ${nrcell}=1  ${IEGNB_REEST_ACC_HO_FAIL}=0  ${IEGNB_REEST_ACC_OTHER_FAIL}=0  ${IEGNB_REEST_ACC_VONR}=0

    Log to console  Verify CB008574 Related RD Counters:
    Log to console  PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${nrcell}
    Log to console  ----------------------------------------------
    Log to console  IEGNB_REEST_ACC_HO_FAIL ${IEGNB_REEST_ACC_HO_FAIL}
    Log to console  IEGNB_REEST_ACC_OTHER_FAIL ${IEGNB_REEST_ACC_OTHER_FAIL}
    Log to console  IEGNB_REEST_ACC_VONR ${IEGNB_REEST_ACC_VONR}

    verify_if_latest_rd_counter_has_exact_value
    ...  counter_id=IEGNB_REEST_ACC_HO_FAIL
    ...  value=${IEGNB_REEST_ACC_HO_FAIL}
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${nrcell}
    ...  filepath=${file}

    verify_if_latest_rd_counter_has_exact_value
    ...  counter_id=IEGNB_REEST_ACC_OTHER_FAIL
    ...  value=${IEGNB_REEST_ACC_OTHER_FAIL}
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${nrcell}
    ...  filepath=${file}

    verify_if_latest_rd_counter_has_exact_value
    ...  counter_id=IEGNB_REEST_ACC_VONR
    ...  value=${IEGNB_REEST_ACC_VONR}
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${nrcell}
    ...  filepath=${file}

Kill Latest Tshark Process
   [Arguments]   ${tcpdump_process}
   #Log to console  Kill Latest Tshark Process with pid: ${tcpdump_process}
   kill_tshark_process  ${tcpdump_process}

Verify PCMD Records For Incoming HO
    [Arguments]   ${targetCell}=${True}
    # Note! if targetCell=true then A#B1 scenario PCMD records will be checked, otherwise A#B2 scenario

    IF  "${targetCell}"=="${True}"
      Log to console  Verify PCMD Records For Incoming HO. RRE to target cell ..
    ELSE IF  "${targetCell}"=="${False}"
      Log to console  Verify PCMD Records For Incoming HO. RRE to prepared cell ..
    END

    Modify A2A Ini File Template And Run A2A Analysis  PDM_file=DU_ueCtxSetup_HO_a2a.pdm  step=1
    Modify A2A Ini File Template And Run A2A Analysis  PDM_file=DU_ueCtxSetup_RRE_a2a.pdm  step=2

    Modify A2A Ini File Template And Run A2A Analysis  PDM_file=DU_bearer_HO_a2a.pdm  step=3

    Modify A2A Ini File Template And Run A2A Analysis  PDM_file=CU_ueDuConnectivity_HO_a2a.pdm  step=4
    Modify A2A Ini File Template And Run A2A Analysis  PDM_file=CU_ueDuConnectivity_RRE_a2a.pdm  step=5

    # ueSetup always with trigger rrcReestHo on both tgt and prep cell scenario (PR721411)
    Modify A2A Ini File Template And Run A2A Analysis  PDM_file=CU_ueSetup_RRE_a2a.pdm  step=6

    # 2nd ueSetup when RRE to prep cell:
    IF  "${targetCell}"=="${False}"
      Modify A2A Ini File Template And Run A2A Analysis  PDM_file=CU_ueSetup_RRE_failed_a2a.pdm  step=7
      Modify A2A Ini File Template And Run A2A Analysis  PDM_file=CU_pduSessionInformation_RRE_a2a.pdm  step=8
      # 2nd pduSession when RRE to prep cell:
      Modify A2A Ini File Template And Run A2A Analysis  PDM_file=CU_pduSessionInformation_HO_prep_a2a.pdm  step=9
      Modify A2A Ini File Template And Run A2A Analysis  PDM_file=CU_xnHoTgt_RRE_prep_a2a.pdm  step=10
    ELSE IF  "${targetCell}"=="${True}"
      Modify A2A Ini File Template And Run A2A Analysis  PDM_file=CU_pduSessionInformation_HO_tgt_a2a.pdm  step=8
      Modify A2A Ini File Template And Run A2A Analysis  PDM_file=CU_xnHoTgt_RRE_tgt_a2a.pdm  step=10
    END
    Log to console  Verify PCMD Records For Incoming HO finished OK

Verify PCMD Records For Incoming HO With Fallback To RRCSetup
    [Arguments]   ${targetCell}=${True}
    # Note! if targetCell=true then A#B1 scenario PCMD records will be checked, otherwise A#B2 scenario

    IF  "${targetCell}"=="${True}"
      Log to console  Verify PCMD Records For Incoming HO - Fallback To RRCSetup. RRE to target cell ..
    ELSE IF  "${targetCell}"=="${False}"
      Log to console  Verify PCMD Records For Incoming HO - Fallback To RRCSetup. RRE to prepared cell ..
    END

    Modify A2A Ini File Template And Run A2A Analysis  PDM_file=DU_ueCtxSetup_HO_a2a.pdm  step=1
    Modify A2A Ini File Template And Run A2A Analysis  PDM_file=DU_ueCtxSetup_RRE_a2a.pdm  step=2

    Modify A2A Ini File Template And Run A2A Analysis  PDM_file=DU_bearer_HO_a2a.pdm  step=3

    Modify A2A Ini File Template And Run A2A Analysis  PDM_file=CU_ueDuConnectivity_HO_a2a.pdm  step=4
    Modify A2A Ini File Template And Run A2A Analysis  PDM_file=CU_ueDuConnectivity_RRE_a2a.pdm  step=5

    Modify A2A Ini File Template And Run A2A Analysis  PDM_file=CU_ueSetup_FallbackToRRCSetup.pdm  step=6
    Modify A2A Ini File Template And Run A2A Analysis  PDM_file=CU_pduSessionInformation_FallbackToRRCSetup.pdm  step=7

    IF  "${targetCell}"=="${False}"
      Modify A2A Ini File Template And Run A2A Analysis  PDM_file=CU_pduSessionInformation_HO_prep_a2a.pdm  step=8
      Modify A2A Ini File Template And Run A2A Analysis  PDM_file=CU_ueSetup_HO_prep_a2a.pdm  step=9
    ELSE IF  "${targetCell}"=="${True}"
      Modify A2A Ini File Template And Run A2A Analysis  PDM_file=CU_ueSetup_HO_tgt_a2a.pdm  step=9
    END

    # No xnHoTgt expected here..
    Log to console  Verify PCMD Records For Incoming HO With Fallback To RRCSetup finished OK

Verify PCMD Records For Outgoing HO
    Log to console  Verify PCMD Records For Outgoing HO ..
    Modify A2A Ini File Template And Run A2A Analysis  PDM_file=CU_xnHoSrc_a2a.pdm  step=1

# EC4:
Verify PCMD Records For Incoming HO Admission Control Scenario
    Log to console  Verify PCMD Records For Incoming HO Admission Control Scenario ..
    Modify A2A Ini File Template And Run A2A Analysis  PDM_file=DU_ueCtxSetup_HO_a2a.pdm  step=1
    Modify A2A Ini File Template And Run A2A Analysis  PDM_file=DU_bearer_HO_a2a.pdm  step=2
    Modify A2A Ini File Template And Run A2A Analysis  PDM_file=DU_ueCtxSetup_RRE_failed_a2a.pdm  step=3

    Modify A2A Ini File Template And Run A2A Analysis  PDM_file=CU_ueDuConnectivity_HO_a2a.pdm  step=4
    Modify A2A Ini File Template And Run A2A Analysis  PDM_file=CU_ueDuConnectivity_RRE_EC4_a2a.pdm  step=5

    Modify A2A Ini File Template And Run A2A Analysis  PDM_file=CU_ueSetup_RRE_failed_a2a.pdm  step=6

    Modify A2A Ini File Template And Run A2A Analysis  PDM_file=CU_pduSessionInformation_HO_prep_a2a.pdm  step=7

    Modify A2A Ini File Template And Run A2A Analysis  PDM_file=CU_xnHoTgt_RRE_prep_fail_a2a.pdm  step=9

    Log to console  Verify PCMD Records For Incoming HO Admission Control Scenario finished OK

Verify PCMD Records For Incoming HO Error Scenario
    Log to console  Verify PCMD Records For Incoming HO Error Scenario ..
    Modify A2A Ini File Template And Run A2A Analysis  PDM_file=DU_ueCtxSetup_HO_a2a.pdm  step=1
    Modify A2A Ini File Template And Run A2A Analysis  PDM_file=DU_bearer_HO_a2a.pdm  step=2
    Modify A2A Ini File Template And Run A2A Analysis  PDM_file=DU_ueCtxSetup_RRE_a2a.pdm  step=3

    Modify A2A Ini File Template And Run A2A Analysis  PDM_file=CU_ueDuConnectivity_HO_a2a.pdm  step=4
    Modify A2A Ini File Template And Run A2A Analysis  PDM_file=CU_ueDuConnectivity_RRE_a2a.pdm  step=5
    Modify A2A Ini File Template And Run A2A Analysis  PDM_file=CU_ueSetup_RRE_failed_a2a.pdm  step=6

    Modify A2A Ini File Template And Run A2A Analysis  PDM_file=CU_pduSessionInformation_HO_prep_a2a.pdm  step=7

    Modify A2A Ini File Template And Run A2A Analysis  PDM_file=CU_xnHoTgt_RRE_prep_fail_a2a.pdm  step=8

    Log to console  Verify PCMD Records For Incoming HO Error Scenario finished OK

Verify PCMD Records For Incoming HO Partial Admission Scenario
    [Arguments]   ${targetCell}=${True}
    Log to console  Verify PCMD Records For Incoming HO Partial Admission Scenario ..
    Modify A2A Ini File Template And Run A2A Analysis  PDM_file=DU_ueCtxSetup_HO_a2a.pdm  step=1
    Modify A2A Ini File Template And Run A2A Analysis  PDM_file=DU_bearer_HO_a2a.pdm  step=2
    Modify A2A Ini File Template And Run A2A Analysis  PDM_file=DU_ueCtxSetup_RRE_a2a.pdm  step=3

    Modify A2A Ini File Template And Run A2A Analysis  PDM_file=CU_ueDuConnectivity_HO_a2a.pdm  step=4
    Modify A2A Ini File Template And Run A2A Analysis  PDM_file=CU_ueDuConnectivity_RRE_a2a.pdm  step=5
    Modify A2A Ini File Template And Run A2A Analysis  PDM_file=CU_ueSetup_RRE_a2a.pdm  step=6

    # 2nd ueSetup when RRE to prep cell:
    IF  "${targetCell}"=="${False}"
    ...  Modify A2A Ini File Template And Run A2A Analysis  PDM_file=CU_ueSetup_RRE_failed_a2a.pdm  step=7

    Modify A2A Ini File Template And Run A2A Analysis  PDM_file=CU_pduSessionInformation_RRE_a2a.pdm  step=8
    # 2nd pduSession when RRE to prep cell:
    IF  "${targetCell}"=="${False}"
    ...  Modify A2A Ini File Template And Run A2A Analysis  PDM_file=CU_pduSessionInformation_HO_prep_a2a.pdm  step=9

    Modify A2A Ini File Template And Run A2A Analysis  PDM_file=CU_xnHoTgt_RRE_prep_a2a.pdm  step=10

    Log to console  Verify PCMD Records For Incoming HO Partial Admission Scenario finished OK

Delay Xn SN Status Transfer
    [Arguments]   ${delay}=1  ${drop}=${False}
    Log to console  Delay or Drop Xn SN Status Transfer .. Delay: ${delay}s, drop: ${drop}

    Execute Egate Command  cmd=gnb_xn_status_transfer_param id=3 reset

    # time_to_wait=none or v1s|v2s|v5s|v10s|v20s|v60s
    IF  "${delay}"!="0" and "${drop}"=="${False}"
        Execute Egate Command
        ...  cmd=gnb_xn_status_transfer_param id=3 action=delayed_rsp time_to_wait=v${delay}s
        # nth=1
    ELSE IF  "${delay}"=="0" and "${drop}"=="${False}"
        Execute Egate Command
        ...  cmd=gnb_xn_status_transfer_param id=3 reset
    ELSE IF  "${drop}"=="${True}"
        Execute Egate Command
        ...  cmd=gnb_xn_status_transfer_param id=3 action=drop nth=1
    END

Delay Xn SN Status Transfer With Error
    [Arguments]   ${delay}=1
    Log to console  Delay Xn SN Status Transfer With Abstract Syntax Error .. Delay: ${delay}s

    Execute Egate Command  cmd=gnb_xn_status_transfer_param id=3 reset

    # time_to_wait=none or v1s|v2s|v5s|v10s|v20s|v60s
    IF  "${delay}"!="0"
        Execute Egate Command
        ...  cmd=gnb_xn_status_transfer_param id=3 action=delay_with_abstract_syntax_error time_to_wait=v${delay}s nth=1
    ELSE
        Execute Egate Command
        ...  cmd=gnb_xn_status_transfer_param id=3 action=delay_with_abstract_syntax_error time_to_wait=none nth=1
    END

# Dropped from CB008574 content after all:
Verify SecurityConfig In RRCReconfiguration
    [Arguments]  ${nia}=nia0  ${nea}=nea0  ${alias}=${TSHARKALIAS_XN}  ${alias_path}=${TSHARKALIAS_XN_PATH}

    ${nia_used}=  Set Variable If
    ...  "${nia}"=="nia0"   0
    ...  "${nia}"=="nia1"   1
    ...  "${nia}"=="nia2"   2
    ...  "${nia}"=="nia3"   3

    ${nea_used}=  Set Variable If
    ...  "${nea}"=="nea0"   0
    ...  "${nea}"=="nea1"   1
    ...  "${nea}"=="nea2"   2
    ...  "${nea}"=="nea3"   3

    ${SecConfig}=    Set Variable
    ...  (f1ap.DLRRCMessageTransfer_element && nr-rrc.rrcReconfiguration_element && nr-rrc.securityAlgorithmConfig_element)

    ${algos}=    Set Variable
    ...  (nr-rrc.cipheringAlgorithm == ${nea_used} && nr-rrc.integrityProtAlgorithm == ${nia_used})

    Run keyword and ignore error   Verify Tshark For Single Message
    ...    alias=${alias}  packet_filter=${SecConfig} && ${algos}
    ...    pcap_file_path=${alias_path}  timeout=5

    Log to console  Verify SecurityConfig In RRCReconfiguration after RRE procedure OK!


