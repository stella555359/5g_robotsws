*** Settings ***
Documentation    Test keyword resource file for CB008699-A-B5_B-B2_FDD

Resource    taf/rfrl/common_resources/robot/libraries_instances.robot
Library     OperatingSystem
Library     taf.hw.pdu     WITH NAME     pdu
Library     taf.sbts.oam.coam.admin    WITH NAME   admin
Library     ta5g_iperf_traffic
Library     ta5g_commissioning
Library     DateTime
Library     Telnet
Library     ute_wtssim
Library     ta5g_throughput
Library     ta5g_ue_measurements
Library     ta5g_ue_mobility
Library     ta5g_enb
Library     ta5g_iphy
Library     ta5g_egate
Library     ta5g_tshark
Library     ta5g_testline_management
Library     ta5g_setups_and_teardowns
Library     ta_messaging
Library     ute_admin_infomodel
Library     taf.wts.runner
Library     taf.config.wts
Library     taf.transport.ssh  WITH NAME  ssh
Library     taf.config.testline.info.testline_info.TestlineInfo    WITH NAME    testline_info
Library     ta5g_pm_counters
Library     taf.ul.sbts.pmi_ticket_collector

# For 5G please import like below
Library    taf.ccs.aashell

*** Variables ***
${DURATION}                  2s
${THROUGHPUT_DL}             1m
${THROUGHPUT_UL}             1m
${ICS_SETUP_RESP_SUCCESS}    ngap.procedureCode == 14 && ngap.NGAP_PDU == 1

${NSA_X2_UPDATED}          MasterInformationBlock-NR Updated
${NSA_SIB_UPDATED}         SystemInformationBlockType1 updated

*** Keywords ***

Testsuite Setup
		Run Keywords  Log to console  Testsuite Setup started ..
		...  AND  Start Vm Ethernet Interfaces
        # Workaround for hanging UPF that crashes egate startup (happens sometimes in case multiple qfi data transfer is used):
        ...  AND  Run  sudo ip link delete tunUPF
		...  AND  Backup Test Suite Files
		...  AND  Stop Edaemon Egate
		...  AND  Update And Put Iphy Xml    input_filepath=${IPHY_XML}
        # To reduce default log levels upload new swconfigs:
        ...  AND  Put Swconfig File  ${SWCONFIG}
        ...  AND  Send Swconfig for AP  ap_swconfig_path=${SWCONFIG_AP}
		...  AND  Set Aliases For Messaging Actors
		# Enable target ran container decoding (for example to verify HO req ack - nr-rrc content)
		...  AND  Run  echo "ngap.dissect_target_ng_ran_container_as: gNB" >> ~/.config/wireshark/preferences
		...  AND  Start Default Logging    output_dirpath=${OUTPUT_DIR}
		...  AND  Find Scfc And Fix And Send Full Commissioning  scfc_filename=scfc.xml  alias=commission
		...  AND  Sleep  30s
		...  AND  Reach Onair   lua_cfg=${EPCSIM_CFG_PATH}  align_tac_values=${False}
        ...  AND  Wait for gNB Configured state
		...  AND  Links up

Testsuite TearDown
		Run Keywords  Stop Tcpdump On Remote Interface
		...  AND  Stop Vm Ethernet Interfaces
		...  AND  Teardown Egate And Collect Logs
    # Workaround for hanging UPF that crashes egate startup (happens sometimes in case multiple qfi data transfer is used):
    ...  AND  Run  sudo ip link delete tunUPF
		...  AND  Stop Default Logging
		...  AND  stop_simenb_interface_and_stop_default_processes_and_gather_logs_without_infomodel

Testcase Setup
    Run Keywords   Start ext interface tshark for testcase
    ...    AND    Execute Egate Command  cmd=sim_trace amf=1 protocol=ng on
    ...    AND    Execute Egate Command  cmd=gnb_param id=3 sa_ho=ng_based
    ...    AND    Execute egate command  cmd=gnb_param id=3 ng_forwarding_tunnel_type=drb ran_status_transfer=true
    ...    AND    Run keyword and ignore error   Stop Collecting Pmi Tickets
    ...    AND    Prepare Pmi Tickets Config
    # Reset CB008699 params from previous TC for 5 UEs:
    ...    AND    Execute Egate Command   cmd=ue_gnb_ho_param id=1,2,3,4,5,6 gnb=3 reset

Testcase Teardown
    Run Keywords    Sleep  2s
    ...    AND    Teardown Tshark    alias=${TSHARKALIAS}
    ...    AND    Stop Tcpdump On Remote Interface
    ...    AND    Execute Egate Command    cmd=set_log flush
    ...    AND    Run  cp /opt/iphy/latest/egate_console.log ${OUTPUT_DIR}/egate_console_${TEST_NAME}.txt

Backup Test Suite Files
    Run  rsync -a ${CURDIR}/*.robot ${OUTPUT_DIR}/Robot/
    Run  rsync -a ${CURDIR}/config/*.txt ${OUTPUT_DIR}/Robot/

Send Swconfig for gNB
    [Arguments]  ${SWCONFIG}
    Log to console  Send Swconfig for gNB: ${SWCONFIG}
    Put Swconfig File  ${SWCONFIG}

Set Aliases For Messaging Actors
  Log To Console    Set Aliases For Messaging Actors
  Create GNB device with alias 'gNB3_NG' identified by ip=10.0.1.123
  Create GNB device with alias 'gNB3_XN' identified by ip=10.0.1.122
  Create GNB device with alias 'gNB2' identified by ip=10.0.1.2
  Create AMF device with alias 'AMF1' identified by ip=10.0.1.1
  #Enable internal mirroring for alias  gNB2

Start ext interface tshark for testcase
    ${tcpdump_process}  ${log_filepath}  ${alias}  Start Tcpdump On Remote Interface
    ...  alias=TSHARK_${TEST_NAME}  log_filename_prefix=${TEST_NAME}_tshark_NG_XN_E1_F1_call_flow  log_dirpath=${OUTPUT_DIR}/tshark/

    Set Test Variable    ${TSHARKALIAS}       ${alias}
    Set Test Variable    ${TSHARKALIAS_PATH}  ${log_filepath}

Xn link up
  Log to console  Xn link up gNB3 to gNB2..
  Execute Egate Command  cmd=sim_state_disp
  Execute Egate Command  cmd=amf_disp_guami id=1
  Execute Egate Command  cmd=gnb_param id=3 xn_listening_socket=1 send_xn_setup=true measEvent=A3
  Sleep  1s
  # In case real gnb inits xn link, ignore error:
  Run keyword and ignore error   Execute Egate Command  cmd=gnb_xn_link_up gnb=3 target=2  pass_regexp=GNB-3: XnAP Link with GNB-2

Start data
    [Arguments]  ${ue_id}=1
    Log to console  Start UL and DL data for UE: ${ue_id}, tput: ${THROUGHPUT_DL}, duration=${DURATION}
    Start Downlink Traffic  throughput=${THROUGHPUT_DL}  duration=${DURATION}
    Start Uplink Traffic    throughput=${THROUGHPUT_UL}  duration=${DURATION}

    Log to console    Data_transfer_is_started_ok
    Sleep  1s

UE Register And Establish PDU Session
    [Arguments]  ${ue_id}=1  ${pdu_id}=1  ${cell_id}=1  ${gnb_id}=2  ${nwslice}=1  ${gw_id}=1
    ${tshark_alias_ngap}=      Start Tshark For S1 Mme Interface
    ...                         log_dirpath=${OUTPUT_DIR}${/}${TEST_NAME}${/}tshark_ue_attach
    ...                         log_filename_prefix=ue_attach

    Log to console  UE Register And Establish PDU Session for UE: ${ue_id} using nwslice: ${nwslice} ..
    Change UE Location  ue_id=${ue_id}  gnb_id=${gnb_id}  cell_id=${cell_id}

    Attach Ue    ue_id=${ue_id}  cell=${cell_id}  enb=${gnb_id}

    Establish PDU Session For UE  ue_id=${ue_id}  pdu_id=${pdu_id}  nwslice=${nwslice}  gw_id=${gw_id}

    Sleep   1s
    Stop Capturing    alias=${tshark_alias_ngap}
    IF  "${gnb_id}"=="2"  Verify Tshark For Given Number Of Messages
    ...            alias=${tshark_alias_ngap}
    ...            packet_filter=${ICS_SETUP_RESP_SUCCESS}
    ...            number_of_messages=1
    Log to console    UE: ${ue_id} registered ok

    Print Measurements  ue_id=${ue_id}

    [Teardown]    Teardown Tshark    alias=${tshark_alias_ngap}

Establish PDU Session For UE
    [Arguments]  ${ue_id}=1  ${pdu_id}=2  ${nwslice}=2  ${gw_id}=2
    Log to console  Establish PDU Session For UE: ${ue_id}, PDU: ${pdu_id}, Slice: ${nwslice}, GW: ${gw_id} and set trf type as internal for data
    Execute Egate Command  cmd=set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal

    Establish Pdu Session  ue_id=${ue_id}  pdu_id=${pdu_id}  nwslice=${nwslice}  gw_id=${gw_id}
    ...    pass_regexp=Established PDU session

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
    #Log to console  Change UE Location to gnb_id: ${gnb_id}, cell_id: ${cell_id}..

    Execute egate command   cmd=ue_change_location id=${ue_id} enb=${gnb_id} cell=${cell_id}

    Execute egate command
    ...     cmd=ue_history_information_list_add_ngran id=1 gnb_id=3 cell_type=medium nrcgi=311:489|0x01 time_ue_stayed_in_cell=100
    Execute egate command
    ...     cmd=ue_history_information_list_add_ngran id=1 gnb_id=2 cell_type=medium nrcgi=311:489|0x01 time_ue_stayed_in_cell=100
    Execute egate command   cmd=ue_history_information_list id=1 action=commit
    Execute egate command   cmd=ue_enb_param id=${ue_id} ue_history_list=1

UE Deregister
    [Arguments]  ${ue_id}=1
    Sleep  1s
    Deregister Ue    ue_id=${ue_id}  pass_regexp=UE CONTEXT RELEASE COMPLETE
    Log to console    UE: ${ue_id} deregistered ok
    Sleep  10s

Start Vm Ethernet Interfaces
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
    Log to console  Wait for gNB Configured state..
    Wait Until Keyword Succeeds      5min     10sec     Ensure gNB state is Configured Or IntegratedToRan
    Wait Until Keyword Succeeds      3min     5sec      Ensure cell is configured

Ensure gNB state is Configured Or IntegratedToRan
    Setup admin
    ${bts_state}=       Get Mrbts State
    ${current_date}=    Get Current Date
    Log to console    ${current_date} : BTS STATE : ${bts_state}
    Should Contain Any            ${bts_state}    Configured    IntegratedToRan    OnAir    ignore_case=${TRUE}
    [Teardown]    Teardown admin

Ensure radio module is online
    Setup admin
    ${bts_hw_info}=             Get Bts Info
    ${availability_status}=     Set variable    ${bts_hw_info['radioModules']['rmod'][0]['status']['availabilityStatus']}
    ${current_date}=            Get Current Date
    Log to console     ${current_date} : RADIO STATE : ${availability_status}
    Should be Equal As Strings      ${availability_status}      Online      ignore_case=${TRUE}
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
    Log to console  MeasId for ${event_type} on carrier freq ${carrier_freq} is: ${meas_id}

    RETURN    ${meas_id}

Send Swconfig for AP
    [Arguments]    ${ap_swconfig_path}
    Log to console  Send Swconfig for AP: ${ap_swconfig_path}..
    Setup Wts Fsm Access
    Put Wts File    ${ap_swconfig_path}    /ffs/run/swconfig.txt    partition=active
    Execute Command On Wts    crasign /ffs/run/swconfig.txt
    Execute Command On Wts    craverify /ffs/run/swconfig.txt /ffs/run/swconfig.txt.p7
    Teardown Wts Fsm Access

Stop data
    [Arguments]    ${ue_id}=1
    #Check Ue Traffic For Both Directions
    Stop Data Traffic    ues=${ue_id}
    Log    Data_transfer_is_stopped_ok

Lock X2 Link Gnb2
    Log To Console  Lock X2 Link Gnb2
    Execute Egate Command    cmd=enb_x2_link_down enb\=1 target\=2

Unlock X2 Link Gnb2
    #Lock X2 Link Gnb2
    #Sleep  5s
    Log To Console  Unlock X2 Link Gnb2
    Execute Egate Command    cmd=enb_x2_link_up enb\=1 target\=2    pass_regexp=${NSA_X2_UPDATED}    timeout=20

Stop Edaemon Egate
    [Documentation]    Kill edaemon and egate if already running.
    Log to console  Stop Edaemon Egate..
    ${edaemon_pid}=    Run    pgrep edaemon
    ${edaemon_status}    Run Keyword and Return Status    Should Not Be Empty    ${edaemon_pid}
    IF    ${edaemon_status}    Run    sudo pkill -9 edaemon
    ${egate_pid}=    Run    pgrep egate
    ${egate_status}    Run Keyword and Return Status    Should Not Be Empty    ${egate_pid}
    IF    ${egate_status}    Run    sudo pkill -9 egate

Links up
    Log to console  X2 and Xn Links up ..
    Setup X2 link to gNB sim
    Sleep  1s
    Xn link up
    Sleep  1s

Setup X2 link to gNB sim
    Log To Console  Setup X2 link to gNB sim..
    Run keyword and ignore error   Execute Egate Command  cmd=enb_x2_link_up enb=1 target=3  pass_regexp=is up

Perform NG Handover
    [Arguments]    ${ue_id}=1  ${phycell_id}=381  ${direction}=outgoing  ${ho_failure}=${False}  ${carrier_freq}=0
    ...  ${carrier_freq2}=0  ${intrafreq}=${False}

    IF  "${intrafreq}"=="${False}"  Log to console  Perform ${direction} Inter Gnb inter freq NG Handover via AMF for UE: ${ue_id}
    ...   ELSE IF  "${intrafreq}"=="${True}"  Log to console  Perform ${direction} Inter Gnb intra freq NG Handover via AMF for UE: ${ue_id}

    ${time}    Get current date    result_format=%Y-%m%d_%H:%M:%SS    exclude_millis=${True}

    ${tcpdump_process}  ${log_filepath}  ${alias}  Start Tcpdump On Remote Interface
    ...  alias=NGAP_E1AP_F1AP_${ue_id}_${direction}_${time}  log_filename_prefix=${TEST_NAME}_UE${ue_id}_NGAP_E1AP_F1AP_${direction}_${time}
    ...  log_dirpath=${OUTPUT_DIR}

    Set Test Variable    ${TSHARKALIAS_NG}       ${alias}
    Set Test Variable    ${TSHARKALIAS_NG_PATH}  ${log_filepath}

    IF  "${ho_failure}"=="${False}"
    ...  inter-gNB handover message flow NG  ue_id=${ue_id}
    ...  ELSE IF  "${ho_failure}"=="${True}"
    ...  inter-gNB handover message flow NG With HO Preparation Failure  ue_id=${ue_id}

    Print Measurements  ue_id=${ue_id}

    ${ngho}=  Set variable  Inter-eNB handover from
    ${ngho_fail}=  Set variable  Handover Preparation Failure

    ${ret1}=  Set variable  DEFAULT
    IF  "${direction}"=="outgoing"
        IF  "${intrafreq}"!="${True}"  Get And Send A2 Meas Id  ue_id=${ue_id}  phycell_id=${phycell_id}  carrier_freq=${carrier_freq}
        Get And Send A3 Meas Id  ue_id=${ue_id}  phycell_id=${phycell_id}  carrier_freq=${carrier_freq2}
        ...  regexp=${ngho}
    ELSE IF  "${direction}"=="incoming"
        IF  "${ho_failure}"=="${False}"
            ${ret1}=    Get And Send A3 Meas Id  ue_id=${ue_id}  phycell_id=${phycell_id}
                        ...  carrier_freq=${carrier_freq}
                        ...  regexp=${ngho}
        ELSE IF  "${ho_failure}"=="${True}"
            Get And Send A3 Meas Id  ue_id=${ue_id}  phycell_id=${phycell_id}
            ...  carrier_freq=${carrier_freq}
            ...  regexp=${ngho_fail}
        END
    END

    Flow Occurred as expected  alias=UE${ue_id}_NG_Handover

    # Outgoing HO tshark capture can be started immediately after verifying it's succeeded..
    IF  "${direction}"=="outgoing"
        stop_tcpdump_on_remote_interface
        Log to console  Tshark stopped with alias: ${TSHARKALIAS_NG} ..
    END

    # Generate PDML
    ${filter}=  Set variable  e1ap or ngap or nr-rrc or f1ap
    ${out}=  Set variable  ${OUTPUT_DIR}/${TEST_NAME}_UE${ue_id}.pdml
    Set Test Variable  ${PDML}  ${out}
    Log to console  Setting PDML file as: ${out} for further checking ..

    IF  "${direction}"=="incoming"
    ...  Run  tshark -Y "${filter}" -r ${OUTPUT_DIR}/${TEST_NAME}_UE${ue_id}_NGAP_E1AP_F1AP_${direction}_${time}.pcap -T pdml > ${out}

    Print Measurements  ue_id=${ue_id}

    RETURN  ${ret1}

Get And Send A2 Meas Id
    [Arguments]    ${ue_id}=1  ${phycell_id}=381  ${carrier_freq}=0

    ${meas_id}=  Get Measurement Id For Frequency  ue_id=${ue_id}  event_type=EventA2  carrier_freq=${carrier_freq}
    Log to console  Sending A2Event so enable inter freq meas gaps with MeasId: ${meas_id}

    Execute Egate Command
    ...  cmd=ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 srsrp_nr=19 phycell_id=${phycell_id} nrsrp_nr=100
    ...  pass_regexp=UEC-1: UE${ue_id}
    Sleep  2s

Get And Send A3 Meas Id
    [Arguments]    ${ue_id}=1  ${phycell_id}=50  ${carrier_freq}=0  ${regexp}=FAIL

    ${meas_id}=  Get Measurement Id For Frequency  ue_id=${ue_id}  event_type=EventA3  carrier_freq=${carrier_freq}
    Log to console  Sending A3Event with MeasId: ${meas_id}

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
    Sleep  1s

inter-gNB handover message flow NG
    [Arguments]    ${ue_id}=1
    Expect Message Flow
    ...    AMF1:NGAP_HandoverRequired
    ...    AMF1:NGAP_HandoverCommand
    ...    AMF1:NGAP_UplinkRANStatusTransfer
    ...    AMF1:NGAP_UEContextReleaseCommand
    ...    AMF1:NGAP_UEContextReleaseComplete
    ...    alias=UE${ue_id}_NG_Handover   overall_timeout=15

inter-gNB handover message flow NG With HO Preparation Failure
    [Arguments]    ${ue_id}=1
    Expect Message Flow
    ...    AMF1:NGAP_HandoverRequired
    ...    AMF1:NGAP_HandoverPreparationFailure
    ...    alias=UE${ue_id}_NG_Handover   overall_timeout=15

Delta Commissioning Single Parameter Value
    [Arguments]  ${parameter}=NULL  ${value}=false  ${dist_name}=MRBTS-1/NRBTS-1
    Log to console  Delta Commissioning Single Parameter Value: ${dist_name}/${parameter}:${value} ..

    Perform Parameter Commissioning    dist_name=${dist_name}    parameter=${parameter}   value=${value}
    Wait Until Keyword Succeeds      3min     5sec      Ensure cell is configured

Trigger MeasGap Configuration Using A1 Or A2 Event
    [Arguments]    ${ue_id}=1    ${event}=A2
    Log to console  Trigger MeasGap Configuration Using ${event} Event..
    ${meas_id}=  Get Measurement id    Event${event}   ue_id=${ue_id}
    Execute Egate Command    cmd=ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} srsrp_nr=40 event=${event}
    ...  pass_regexp=rrcReconfigurationComplete
    Execute Egate Command  cmd=ue_meas_cfg_disp id=${ue_id} meas_obj_type=nr  pass_regexp=NR MEASUREMENT IDENTITIES
    Sleep  2s

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
    Sleep  1s

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

Start Or Stop Data On All QFIs
    [Arguments]  ${ue_id}=1  ${pdu}=1  ${qfis}=1  ${throughput}=1  ${operation}=start

    Log to console  Start Data For UE: ${ue_id} On All QFIs: ${qfis}, PDU: ${pdu}, throughput: ${throughput} kbps
    FOR    ${qfi}    IN    @{qfis}
      IF  "${operation}"=="start"
        Execute Egate Command  cmd=trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} dir=dl kbps=${throughput}
        Execute Egate Command  cmd=trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} dir=ul kbps=${throughput}
      ELSE IF  "${operation}"=="stop"
        Execute Egate Command  cmd=trf_data_stop ue=${ue_id} pdu=${pdu} qfi=${qfi} dir=dl
        Execute Egate Command  cmd=trf_data_stop ue=${ue_id} pdu=${pdu} qfi=${qfi} dir=ul
      END

      Sleep  1s
      IF  "${operation}"=="start"
      ...  Execute Egate Command And Wait For Data  cmd=trf_internal_disp ue=${ue_id} pdu=${pdu} qfi=${qfi} dir=bi
    END

Verify DRBs
    [Arguments]  ${proto}=NOT_SET  ${msg}=NOT_SET  ${inside_RRCReconf}=${False}
    ...  ${drb4}=${EMPTY}  ${drb5}=${EMPTY}  ${drb6}=${EMPTY}   ${drb7}=${EMPTY}
    ...  ${drb8}=${EMPTY}  ${drb9}=${EMPTY}  ${drb10}=${EMPTY}  ${drb11}=${EMPTY}

    # in case it's RRCReconf inside wanted msg, need to find drbs with nr-rrc inside it, otherwise proto1 of msg is same as drbid proto2:
    ${proto2}=  Set Variable If
    ...  "${inside_RRCReconf}"=="${False}"  ${proto}
    ...  "${inside_RRCReconf}"=="${True}"   nr-rrc

    ${drbName}=  Set Variable If
    ...  "${proto2}"=="nr-rrc"  drb_Identity
    ...  "${proto2}"=="ngap"    dRB_ID
    ...  "${proto2}"=="e1ap"    dRB_ID
    ...  "${proto2}"=="f1ap"    dRBID

    ${filter1}=  Set Variable  ${proto}.${msg}

    ${filter2}=  Set variable
    ...  (${drb4}${proto2}.${drbName}==4 && ${drb5}${proto2}.${drbName}==5 && ${drb6}${proto2}.${drbName}==6 && ${drb7}${proto2}.${drbName}==7 &&

    ${filter3}=  Set variable
    ...  ${drb8}${proto2}.${drbName}==8 && ${drb9}${proto2}.${drbName}==9 && ${drb10}${proto2}.${drbName}==10 && ${drb11}${proto2}.${drbName}==11)

    # Note! Uses tshark alias set in KW 'NG Handover':

    Verify Tshark For Single Message
    ...    alias=${TSHARKALIAS_NG}  packet_filter=${filter1} && ${filter2}${filter3}
    ...    pcap_file_path=${TSHARKALIAS_NG_PATH}  timeout=10

    Log to console  Verify DRBs, Check msg: ${msg} with filter=${filter1} && ${filter2} ${filter3} verified OK!

Verify FullConfig
    [Arguments]  ${fullConfigSet}=${False}

    Log to console  Verify if FullConfig exists in E1, F1 and NG interface messages: ${fullConfigSet}, tshark alias: ${TSHARKALIAS_NG}

    ${found}=  Set Variable If
    ...  "${fullConfigSet}"=="${False}"  !
    ...  "${fullConfigSet}"=="${True}"   ${EMPTY}

    ${foundSourceConfig}=  Set Variable If
    ...  "${fullConfigSet}"=="${False}"  ${EMPTY}
    ...  "${fullConfigSet}"=="${True}"   !

    # SourceConfig:
    ${filter1}=  Set Variable  f1ap.UEContextSetupRequest_element && ${foundSourceConfig}nr-rrc.sourceConfig_element

    Verify Tshark For Single Message
    ...    alias=${TSHARKALIAS_NG}  packet_filter=${filter1}
    ...    pcap_file_path=${TSHARKALIAS_NG_PATH}  timeout=10

    Log to console  Verify SourceConfig IE in UEContextSetupRequest: Check msg with filter=${filter1} verified OK!

    ${filter1}=  Set Variable  f1ap.UEContextSetupResponse_element && ${found}f1ap.id == 94

    Verify Tshark For Single Message
    ...    alias=${TSHARKALIAS_NG}  packet_filter=${filter1}
    ...    pcap_file_path=${TSHARKALIAS_NG_PATH}  timeout=10

    Log to console  Verify FullConfig IE in UEContextSetupResponse: Check msg with filter=${filter1} verified OK!

    ${filter1}=  Set Variable  ngap.HandoverRequestAcknowledge_element && ${found}nr-rrc.fullConfig

    Verify Tshark For Single Message
    ...    alias=${TSHARKALIAS_NG}  packet_filter=${filter1}
    ...    pcap_file_path=${TSHARKALIAS_NG_PATH}  timeout=10

    Log to console  Verify FullConfig IE in HandoverRequestAcknowledge: Check msg with filter=${filter1} verified OK!

Verify Handover Failure
    [Arguments]  ${cause}=8
    Log to console  Verify Handover Failure

    ${filter1}=  Set Variable  ngap.HandoverFailure_element && ngap.radioNetwork == ${cause}

    Verify Tshark For Single Message
    ...    alias=${TSHARKALIAS_NG}  packet_filter=${filter1}
    ...    pcap_file_path=${TSHARKALIAS_NG_PATH}  timeout=10

    Log to console  Verify Handover Failure: Check msg with filter=${filter1} verified OK!

Clear And Start Collecting PMI Tickets
    Log To Console  Clear And Start Collecting PMI Tickets ..
    Clear Pmi Tickets
    Start Collecting Pmi Tickets
    Sleep  5s

Stop Collecting PMI Tickets And Verify Full Config Counters
    [Arguments]  ${ho_fail}=${False}  ${HO_PREP_SUCC_FULLCONF_TRG}=1  ${RRC_RECONF_COMP_FULLCONF_TRG}=1
    ...          ${NG_HO_RES_ALC_F_OTH_TRG}=0

    Log to console  Stop Collecting PMI Tickets And Verify Full Config/HO failure Counters ..
    Stop Collecting Pmi Tickets
    ${msgs}=  Get All Pmi Tickets
    Log  All PMI tickets: ${msgs}

    IF  "${ho_fail}"=="${False}"
        Verify Pmi Counters In Records  3614113828 eq ${HO_PREP_SUCC_FULLCONF_TRG}
        ...  3614113829 eq ${RRC_RECONF_COMP_FULLCONF_TRG}
    ELSE IF  "${ho_fail}"=="${True}"
        Verify Pmi Counters In Records  3612679506 eq ${NG_HO_RES_ALC_F_OTH_TRG}
    END

    Log to console  PMI counters verified ok:
    IF  "${ho_fail}"=="${False}"
        Log to console  PMI: HO_PREP_SUCC_FULLCONF_TRG equals ${HO_PREP_SUCC_FULLCONF_TRG}
        Log to console  PMI: RRC_RECONF_COMP_FULLCONF_TRG equals ${RRC_RECONF_COMP_FULLCONF_TRG}
    ELSE IF  "${ho_fail}"=="${True}"
        Log to console  PMI: NG_HO_RES_ALC_F_OTH_TRG equals ${NG_HO_RES_ALC_F_OTH_TRG}
    END

Wait For Next Meas File And Verify Full Config Counters
    [Arguments]  ${NG_HO_RES_ALC_F_OTH_TRG}=0  ${HO_PREP_SUCC_FULLCONF_TRG}=1  ${RRC_RECONF_COMP_FULLCONF_TRG}=1  ${nrcell}=1

    Log to console  Wait For Next Meas File And Verify Full Config Counters ..
    Wait For Next Full Pm Interval
    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File

    Verify Any Counters In File
    ...    M55125C07506    ${NG_HO_RES_ALC_F_OTH_TRG}       NG_HO_RES_ALC_F_OTH_TRG
    ...    M55147C00036    ${HO_PREP_SUCC_FULLCONF_TRG}     HO_PREP_SUCC_FULLCONF_TRG
    ...    M55147C00037    ${RRC_RECONF_COMP_FULLCONF_TRG}  RRC_RECONF_COMP_FULLCONF_TRG
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${nrcell}
    ...    file_path=${pm_counter_file}

    RETURN  ${pm_counter_file}

Verify Received Data Forwarding Packets For 5QIs
    [Arguments]  ${pm_counter_file}

    Log to console  Verify Received Data Forwarding Packets For 5QIs ..

    # Received data forwarding packets from airphone during handover:
    Verify Any Counters In File
    ...    M55337C04001 	>1  VOL_DL_FWDT_RCV_PDUSES_QOS_01
    ...    M55337C04002 	 0  VOL_DL_FWDT_RCV_PDUSES_QOS_02
    ...    M55337C04003 	 0  VOL_DL_FWDT_RCV_PDUSES_QOS_03
    ...    M55337C04004 	>1  VOL_DL_FWDT_RCV_PDUSES_QOS_04
    ...    M55337C04005 	>1  VOL_DL_FWDT_RCV_PDUSES_QOS_05
    ...    M55337C04006 	>1  VOL_DL_FWDT_RCV_PDUSES_QOS_06
    ...    M55337C04007 	>1  VOL_DL_FWDT_RCV_PDUSES_QOS_07
    ...    M55337C04008 	>1  VOL_DL_FWDT_RCV_PDUSES_QOS_08
    ...    M55337C04009 	>1  VOL_DL_FWDT_RCV_PDUSES_QOS_09

    ...    M55337C05001   >1  NUM_DL_FWDT_RCV_PDUSES_QOS_01
    ...    M55337C05002    0  NUM_DL_FWDT_RCV_PDUSES_QOS_02
    ...    M55337C05003    0  NUM_DL_FWDT_RCV_PDUSES_QOS_03
    ...    M55337C05004   >1  NUM_DL_FWDT_RCV_PDUSES_QOS_04
    ...    M55337C05005   >1  NUM_DL_FWDT_RCV_PDUSES_QOS_05
    ...    M55337C05006   >1  NUM_DL_FWDT_RCV_PDUSES_QOS_06
    ...    M55337C05007   >1  NUM_DL_FWDT_RCV_PDUSES_QOS_07
    ...    M55337C05008   >1  NUM_DL_FWDT_RCV_PDUSES_QOS_08
    ...    M55337C05009   >1  NUM_DL_FWDT_RCV_PDUSES_QOS_09
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1
    ...    file_path=${pm_counter_file}

Set Sim Automatic Neighbour Relation
    [Arguments]  ${pci}=50

    Log to console  Set Sim Automatic Neighbour Relation to pci: ${pci}
    IF  "${pci}"=="50"  Execute Egate Command  cmd=gnb_cell_param id=1 gnb=3 enable_anr=on neighbor_pci=16:2
    ...   ELSE IF  "${pci}"=="51"  Execute Egate Command  cmd=gnb_cell_param id=1 gnb=3 enable_anr=on neighbor_pci=17:0
    ...   ELSE     Log to console  Error: Unsupported cell with PCI: ${pci}!

Set Default Bearer And Additional QoS Flows
    [Arguments]  ${def_qosflow}  ${add_qosflows}  ${integrity_prot}=${False}

    Log to console  Set Default Bearer And Additional QoS Flows .. Default bearer qos flow: ${def_qosflow}, additional qos flows: ${add_qosflows}

    Execute Egate Command  cmd=qosflow_modify qos_flow=${def_qosflow} default=on
    Execute Egate Command  cmd=smf_param id=1 reset
    IF  "${add_qosflows}"!="None"  Execute Egate Command  cmd=smf_param id=1 additional_qosflows_to_activate=${add_qosflows}

    # Activates 'CB008116-A U-Plane Integrity Protection Functionality' on Airphone side.. Causes problems if data is active ..
    IF  "${integrity_prot}"=="${True}"
    ...  Execute Egate Command  cmd=smf_param id=1 security_indication=pdu_session_setup:required:preferred max_data_rate=64kbps

Verify DefaultDRB In BearerContextSetupRequest
    [Arguments]  ${drbList}  ${times}

    ${msgpath}=  Set variable
    ...  .//field[@name='e1ap.BearerContextSetupRequest_element']//field[@name='e1ap.DRB_To_Setup_Item_NG_RAN_element']

    ${TIMES_Total}=  Evaluate  0
    FOR  ${drb}  IN  @{drbList}
        @{findStr}=  Set variable  dRB-ID: ${drb}  defaultDRB: true&&sDAP-Header-UL: present
        ${iTimes}  Find Msgpath With Searchfields From Pdml  PDML=${PDML}  msgpath=${msgpath}  searchfields=${findStr}
        ${TIMES_Total}=  Evaluate  ${TIMES_Total}+${iTimes}
    END

    IF   "${TIMES_Total}"!="${times}"
    ...  Log to console  ERROR: Expected DefaultDRB In BearerContextSetupRequest ${times} times, found: ${TIMES_Total}!
    SHOULD BE TRUE    ${TIMES_Total} == ${times}
    Log to console  PASS: Expected DefaultDRB In BearerContextSetupRequest ${times} times, found: ${TIMES_Total}!

Verify DefaultDRB In HandoverRequestAcknowledge
    [Arguments]  ${drbList}  ${times}

    ${msgpath}=  Set variable
    ...  .//field[@name='ngap.HandoverRequestAcknowledge_element']//field[@name='nr-rrc.DRB_ToAddMod_element']

    ${TIMES_Total}=  Evaluate  0
    FOR  ${drb}  IN  @{drbList}
        @{findStr}=  Set variable  drb-Identity: ${drb}  sdap-Config  defaultDRB: True&&sdap-HeaderUL: present
        ${iTimes}  Find Msgpath With Searchfields From Pdml  PDML=${PDML}  msgpath=${msgpath}  searchfields=${findStr}
        ${TIMES_Total}=  Evaluate  ${TIMES_Total}+${iTimes}
    END

    IF   "${TIMES_Total}"!="${times}"
    ...  Log to console  ERROR: Expected DefaultDRB In HandoverRequestAcknowledge ${times} times, found: ${TIMES_Total}!
    SHOULD BE TRUE    ${TIMES_Total} == ${times}
    Log to console  PASS: Expected DefaultDRB In HandoverRequestAcknowledge ${times} times, found: ${TIMES_Total}!

Verify DRB Tunnels In BearerContextSetupRequest
    [Arguments]  ${drbList}  ${times}

    ${msgpath}=  Set variable
    ...  .//field[@name='e1ap.BearerContextSetupRequest_element']//field[@name='e1ap.DRB_To_Setup_Item_NG_RAN_element']

    ${TIMES_Total}=  Evaluate  0
    FOR  ${drb}  IN  @{drbList}
        @{findStr}=  Set variable  dRB-ID: ${drb}&&dRB-Data-Forwarding-Information-Request  data-Forwarding-Request: dL
        ${iTimes}  Find Msgpath With Searchfields From Pdml  PDML=${PDML}  msgpath=${msgpath}  searchfields=${findStr}
        ${TIMES_Total}=  Evaluate  ${TIMES_Total}+${iTimes}
    END

    IF   "${TIMES_Total}"!="${times}"
    ...  Log to console  ERROR: Expected DRB Tunnels In BearerContextSetupRequest ${times} times, found: ${TIMES_Total}!
    SHOULD BE TRUE    ${TIMES_Total} == ${times}
    Log to console  PASS: Expected DRB Tunnels In BearerContextSetupRequest ${times} times, found: ${TIMES_Total}!

Verify DRB Tunnels In BearerContextSetupResponse
    [Arguments]  ${drbList}  ${times}

    ${msgpath}=  Set variable
    ...  .//field[@name='e1ap.BearerContextSetupResponse_element']//field[@name='e1ap.DRB_Setup_Item_NG_RAN_element']

    ${TIMES_Total}=  Evaluate  0
    FOR  ${drb}  IN  @{drbList}
        @{findStr}=  Set variable  dRB-ID: ${drb}&&dRB-data-Forwarding-Information-Response  dL-Data-Forwarding: gTPTunnel
        ${iTimes}  Find Msgpath With Searchfields From Pdml  PDML=${PDML}  msgpath=${msgpath}  searchfields=${findStr}
        ${TIMES_Total}=  Evaluate  ${TIMES_Total}+${iTimes}
    END

    IF   "${TIMES_Total}"!="${times}"
    ...  Log to console  ERROR: Expected DRB Tunnels In BearerContextSetupResponse ${times} times, found: ${TIMES_Total}!
    SHOULD BE TRUE    ${TIMES_Total} == ${times}
    Log to console  PASS: Expected DRB Tunnels In BearerContextSetupResponse ${times} times, found: ${TIMES_Total}!

Verify DRB Tunnels In HandoverRequestAcknowledge
    [Arguments]  ${drbList}  ${times}

    ${msgpath}=  Set variable
    ...  .//field[@name='ngap.HandoverRequestAcknowledge_element']//field[@name='ngap.DataForwardingResponseDRBItem_element']

    ${TIMES_Total}=  Evaluate  0
    FOR  ${drb}  IN  @{drbList}
        @{findStr}=  Set variable  dRB-ID: ${drb}&&dLForwardingUP-TNLInformation: gTPTunnel  gTPTunnel
        ${iTimes}  Find Msgpath With Searchfields From Pdml  PDML=${PDML}  msgpath=${msgpath}  searchfields=${findStr}
        ${TIMES_Total}=  Evaluate  ${TIMES_Total}+${iTimes}
    END

    IF   "${TIMES_Total}"!="${times}"
    ...  Log to console  ERROR: Expected DRB Tunnels In HandoverRequestAcknowledge ${times} times, found: ${TIMES_Total}!
    SHOULD BE TRUE    ${TIMES_Total} == ${times}
    Log to console  PASS: Expected DRB Tunnels In HandoverRequestAcknowledge ${times} times, found: ${TIMES_Total}!

Verify DRB IDs In BearerContextSetupRequest
    [Arguments]  ${drbList}  ${times}

    ${msgpath}=  Set variable
    ...  .//field[@name='e1ap.BearerContextSetupRequest_element']//field[@name='e1ap.DRB_To_Setup_Item_NG_RAN_element']

    ${TIMES_Total}=  Evaluate  0
    FOR  ${drb}  IN  @{drbList}
        @{findStr}=  Set variable  dRB-ID: ${drb}&&sDAP-Configuration  sDAP-Header
        ${iTimes}  Find Msgpath With Searchfields From Pdml  PDML=${PDML}  msgpath=${msgpath}  searchfields=${findStr}
        ${TIMES_Total}=  Evaluate  ${TIMES_Total}+${iTimes}
    END

    IF   "${TIMES_Total}"!="${times}"
    ...  Log to console  ERROR: DRB IDs In BearerContextSetupRequest ${times} times, found: ${TIMES_Total}!
    SHOULD BE TRUE    ${TIMES_Total} == ${times}
    Log to console  PASS: Expected DRB IDs In BearerContextSetupRequest ${times} times, found: ${TIMES_Total}!

Verify DRB IDs In BearerContextSetupResponse
    [Arguments]  ${drbList}  ${times}

    ${msgpath}=  Set variable
    ...  .//field[@name='e1ap.BearerContextSetupResponse_element']//field[@name='e1ap.DRB_Setup_Item_NG_RAN_element']

    ${TIMES_Total}=  Evaluate  0
    FOR  ${drb}  IN  @{drbList}
        # Find only one value and pass python script with empty variable:
        @{findStr}=  Set variable  dRB-ID: ${drb}  ${EMPTY}
        ${iTimes}  Find Msgpath With Searchfields From Pdml  PDML=${PDML}  msgpath=${msgpath}  searchfields=${findStr}
        ${TIMES_Total}=  Evaluate  ${TIMES_Total}+${iTimes}
    END

    IF   "${TIMES_Total}"!="${times}"
    ...  Log to console  ERROR: DRB IDs In BearerContextSetupResponse ${times} times, found: ${TIMES_Total}!
    SHOULD BE TRUE    ${TIMES_Total} == ${times}
    Log to console  PASS: Expected DRB IDs In BearerContextSetupResponse ${times} times, found: ${TIMES_Total}!

Verify DRB IDs In HandoverRequestAcknowledge
    [Arguments]  ${drbList}  ${times}

    ${msgpath}=  Set variable
    ...  .//field[@name='ngap.HandoverRequestAcknowledge_element']//field[@name='nr-rrc.DRB_ToAddMod_element']

    ${TIMES_Total}=  Evaluate  0
    FOR  ${drb}  IN  @{drbList}
        @{findStr}=  Set variable  drb-Identity: ${drb}&&pdcp-Config  drb
        ${iTimes}  Find Msgpath With Searchfields From Pdml  PDML=${PDML}  msgpath=${msgpath}  searchfields=${findStr}
        ${TIMES_Total}=  Evaluate  ${TIMES_Total}+${iTimes}
    END

    IF   "${TIMES_Total}"!="${times}"
    ...  Log to console  ERROR: DRB IDs In HandoverRequestAcknowledge ${times} times, found: ${TIMES_Total}!
    SHOULD BE TRUE    ${TIMES_Total} == ${times}
    Log to console  PASS: Expected DRB IDs In HandoverRequestAcknowledge ${times} times, found: ${TIMES_Total}!

Verify PDU Tunnels In BearerContextSetupRequest
    [Arguments]  ${pduList}  ${times}

    ${msgpath}=  Set variable
    ...  .//field[@name='e1ap.BearerContextSetupRequest_element']//field[@name='e1ap.PDU_Session_Resource_To_Setup_Item_element']

    ${TIMES_Total}=  Evaluate  0
    FOR  ${pdu}  IN  @{pduList}
        @{findStr}=  Set variable  pDU-Session-ID: ${pdu}&&pDU-Session-Data-Forwarding-Information-Request  data-Forwarding-Request: dL
        ${iTimes}  Find Msgpath With Searchfields From Pdml  PDML=${PDML}  msgpath=${msgpath}  searchfields=${findStr}
        ${TIMES_Total}=  Evaluate  ${TIMES_Total}+${iTimes}
    END

    IF   "${TIMES_Total}"!="${times}"
    ...  Log to console  ERROR: Expected PDU Tunnels In BearerContextSetupRequest ${times} times, found: ${TIMES_Total}!
    SHOULD BE TRUE    ${TIMES_Total} == ${times}
    Log to console  PASS: Expected PDU Tunnels In BearerContextSetupRequest ${times} times, found: ${TIMES_Total}!

Verify PDU Tunnels In BearerContextSetupResponse
    [Arguments]  ${pduList}  ${times}

    ${msgpath}=  Set variable
    ...  .//field[@name='e1ap.BearerContextSetupResponse_element']//field[@name='e1ap.PDU_Session_Resource_Setup_Item_element']

    ${TIMES_Total}=  Evaluate  0
    FOR  ${pdu}  IN  @{pduList}
        @{findStr}=  Set variable  pDU-Session-ID: ${pdu}&&pDU-Session-Data-Forwarding-Information-Response  dL-Data-Forwarding: gTPTunnel
        ${iTimes}  Find Msgpath With Searchfields From Pdml  PDML=${PDML}  msgpath=${msgpath}  searchfields=${findStr}
        ${TIMES_Total}=  Evaluate  ${TIMES_Total}+${iTimes}
    END

    IF   "${TIMES_Total}"!="${times}"
    ...  Log to console  ERROR: Expected PDU Tunnels In BearerContextSetupResponse ${times} times, found: ${TIMES_Total}!
    SHOULD BE TRUE    ${TIMES_Total} == ${times}
    Log to console  PASS: Expected PDU Tunnels In BearerContextSetupResponse ${times} times, found: ${TIMES_Total}!

Verify PDU Tunnels In HandoverRequestAcknowledge
    [Arguments]  ${pduList}  ${times}

    ${msgpath}=  Set variable
    ...  .//field[@name='ngap.HandoverRequestAcknowledge_element']//field[@name='ngap.PDUSessionResourceAdmittedItem_element']

    ${TIMES_Total}=  Evaluate  0
    FOR  ${pdu}  IN  @{pduList}
        @{findStr}=  Set variable  pDUSessionID: ${pdu}  HandoverRequestAcknowledgeTransfer  dLForwardingUP-TNLInformation: gTPTunnel
        ${iTimes}  Find Msgpath With Searchfields From Pdml  PDML=${PDML}  msgpath=${msgpath}  searchfields=${findStr}
        ${TIMES_Total}=  Evaluate  ${TIMES_Total}+${iTimes}
    END

    IF   "${TIMES_Total}"!="${times}"
    ...  Log to console  ERROR: Expected PDU Tunnels In HandoverRequestAcknowledge ${times} times, found: ${TIMES_Total}!
    SHOULD BE TRUE    ${TIMES_Total} == ${times}
    Log to console  PASS: Expected PDU Tunnels In HandoverRequestAcknowledge ${times} times, found: ${TIMES_Total}!

Verify DefaultDRB In E1 And NG
    [Arguments]  ${drbList}  ${times}
    Log to console  Verify DefaultDRB In E1 And NG for DRBs: ${drbList}, times: ${times}

    Verify DefaultDRB In BearerContextSetupRequest   drbList=${drbList}  times=${times}
    Verify DefaultDRB In HandoverRequestAcknowledge  drbList=${drbList}  times=${times}

Verify DRB IDs In E1 And NG
    [Arguments]  ${drbList}  ${times}

    Log To Console  Verify DRB IDs In E1 And NG for DRBs: ${drbList}, times: ${times}
    Verify DRB IDs In BearerContextSetupRequest   drbList=${drbList}  times=${times}
    Verify DRB IDs In BearerContextSetupResponse  drbList=${drbList}  times=${times}
    Verify DRB IDs In HandoverRequestAcknowledge  drbList=${drbList}  times=${times}

Verify DRB Tunnels In E1 And NG
    [Arguments]  ${drbList}  ${times}

    Log to console  Verify DRB Tunnels In E1 And NG for DRBs: ${drbList}, times: ${times}
    Verify DRB Tunnels In BearerContextSetupRequest   drbList=${drbList}  times=${times}
    Verify DRB Tunnels In BearerContextSetupResponse  drbList=${drbList}  times=${times}
    Verify DRB Tunnels In HandoverRequestAcknowledge  drbList=${drbList}  times=${times}

Verify PDU Tunnels In E1 And NG
    [Arguments]  ${pduList}  ${times}

    Log To Console  Verify PDU Tunnels In E1 And NG for PDUs: ${pduList}, times: ${times}
    Verify PDU Tunnels In BearerContextSetupRequest   pduList=${pduList}  times=${times}
    Verify PDU Tunnels In BearerContextSetupResponse  pduList=${pduList}  times=${times}
    Verify PDU Tunnels In HandoverRequestAcknowledge  pduList=${pduList}  times=${times}

Check Need Of Fresh PM Counter Interval
    ${status}  ${sMin}  ${sSec}  need_to_wait_for_counter_interval
    IF  "${status}"=="${True}"
        Log To Console  Need to wait for fresh interval, timing=${sMin}:${sSec} ..
        Get Next Unpacked Full Pm Counters File  output_dirpath=${OUTPUT DIR}/pm
    ELSE IF  "${status}"=="${False}"
        Log To Console  No need to wait for fresh interval, timing=${sMin}:${sSec} ..
    END
