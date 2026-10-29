*** Settings ***
Documentation    Test keyword resource file for CB008699-A-B5_B-B2_TDD

Resource    taf/rfrl/common_resources/robot/libraries_instances.robot

Library     OperatingSystem
Library     DateTime
Library     Telnet

Library     taf.hw.pdu                                            WITH NAME   pdu
Library     taf.sbts.oam.coam.admin                               WITH NAME   admin
Library     taf.transport.ssh                                     WITH NAME   ssh
Library     taf.config.testline.info.testline_info.TestlineInfo   WITH NAME   testline_info
Library     taf.wts.runner
Library     taf.config.wts
Library     taf.ccs.aashell

Library     ute_wtssim
Library     ute_admin_infomodel

Library     ta5g_iperf_traffic
Library     ta5g_commissioning
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
Library     ta5g_pm_counters

Library     taf.ul.sbts.pmi_ticket_collector


*** Variables ***
${DURATION}                2s
${THROUGHPUT_DL}           1m
${THROUGHPUT_UL}           1m
${ICS_SETUP_RESP_SUCCESS}  ngap.procedureCode == 14 && ngap.NGAP_PDU == 1

${NSA_X2_UPDATED}          MasterInformationBlock-NR Updated
${NSA_SIB_UPDATED}         SystemInformationBlockType1 updated

*** Keywords ***
Testsuite Setup
    Run Keywords    Start Vm Ethernet Interfaces
    ...  AND  Run  echo "ngap.dissect_target_ng_ran_container_as: gNB" >> ~/.config/wireshark/preferences
    # Workaround for hanging UPF that crashes egate startup (happens sometimes in case multiple qfi data transfer is used):
    ...  AND  Run  sudo ip link delete tunUPF
    ...  AND  Backup Test Suite Files
    ...  AND  Stop Edaemon Egate
    ...  AND  Update And Put Iphy Xml    input_filepath=${IPHY_XML}
    ...  AND  Put Swconfig File  ${SWCONFIG}
    ...  AND  Set Aliases For Messaging Actors
    ...  AND  Find Scfc And Fix And Send Full Commissioning  scfc_filename=scfc.xml  alias=commission
    ...  AND  Wait for gNB Configured state
    ...  AND  Start Default Logging    output_dirpath=${OUTPUT_DIR}
    ...  AND  Reach Onair   lua_cfg=${EPCSIM_CFG_PATH}
    ...  AND  Wait for gNB Configured state
    ...  AND  Links up

Testsuite TearDown
    Run Keywords   Stop Tcpdump On Remote Interface
    ...    AND    Stop Vm Ethernet Interfaces
    ...    AND    Teardown Egate And Collect Logs
    # Workaround for hanging UPF that crashes egate startup (happens sometimes in case multiple qfi data transfer is used):
    ...    AND    Run  sudo ip link delete tunUPF
    ...    AND    Stop Default Logging
    ...    AND    stop_simenb_interface_and_stop_default_processes_and_gather_logs_without_infomodel

Testcase Setup
    Run Keywords   Start ext interface tshark for testcase
    #...    AND    Start Tcpdump On Remote Interface  alias=remote  log_filename_prefix=${TEST_NAME}_NRRRC  log_dirpath=${OUTPUT_DIR}/tshark
    ...    AND    Execute Egate Command  cmd=sim_trace amf=1 protocol=ng on
    ...    AND    Execute Egate Command  cmd=gnb_param id=3 sa_ho=ng_based
    ...    AND    Execute egate command  cmd=gnb_param id=3 ng_forwarding_tunnel_type=drb ran_status_transfer=true
    # Reset CB008699 params from previous TC:
    #...    AND    Execute Egate Command  cmd=gnb_common_handover_preparation_param id=3
    ...    AND    Prepare Pmi Tickets Config
    #...    AND    Resources Usage At Test Start
    ...    AND    Execute Egate Command   cmd=ue_gnb_ho_param id=1,2,3,4,5,6 gnb=3 reset

Testcase Teardown
    Run Keywords  Log To Console  Testcase teardown started for TC: ${TEST_NAME}
    ...    AND    Teardown Tshark    alias=${TSHARKALIAS}
    #...    AND    Stop Tcpdump On Remote Interface
    ...    AND    Execute Egate Command    cmd=set_log flush
    ...    AND    Run  cp /opt/iphy/latest/egate_console.log ${OUTPUT_DIR}/egate_console_${TEST_NAME}.txt
    #...    AND    Resources Usage At Test End

Backup Test Suite Files
    Run  rsync -a ${CURDIR}/*.robot ${OUTPUT_DIR}/Robot/
    Run  rsync -a ${CURDIR}/config/*.txt ${OUTPUT_DIR}/Robot/

Set Aliases For Messaging Actors
    Log To Console    Set Aliases For Messaging Actors
    Create GNB device with alias 'gNB3_NG' identified by ip=10.0.1.123
    Create GNB device with alias 'gNB3_XN' identified by ip=10.0.1.122
    Create GNB device with alias 'gNB2' identified by ip=10.0.1.2
    Create AMF device with alias 'AMF1' identified by ip=10.0.1.1
    Enable internal mirroring for alias  gNB2

Start ext interface tshark for testcase
    ${tcpdump_process}  ${log_filepath}  ${alias}  Start Tcpdump On Remote Interface
    ...  alias=TSHARK_${TEST_NAME}  log_filename_prefix=${TEST_NAME}_tshark_NG_XN_E1_F1_call_flow  log_dirpath=${OUTPUT_DIR}/tshark/

    Set Test Variable    ${TSHARKALIAS}       ${alias}
    Set Test Variable    ${TSHARKALIAS_PATH}  ${log_filepath}

UE Register And Establish PDU Session
    [Arguments]  ${ue_id}=1  ${pdu_id}=1  ${cell_id}=1  ${gnb_id}=2  ${nwslice}=1  ${gw_id}=1
    ${tshark_alias_ngap}=      Start Tshark For S1 Mme Interface
    ...                         log_dirpath=${OUTPUT_DIR}${/}${TEST_NAME}${/}tshark_ue_attach
    ...                         log_filename_prefix=ue_attach

    Log To Console  UE Register And Establish PDU Session for UE: ${ue_id} using nwslice: ${nwslice} ..
    Change UE Location  ue_id=${ue_id}  gnb_id=${gnb_id}  cell_id=${cell_id}

    Attach Ue    ue_id=${ue_id}  cell=${cell_id}  enb=${gnb_id}

    Establish PDU Session For UE  ue_id=${ue_id}  pdu_id=${pdu_id}  nwslice=${nwslice}  gw_id=${gw_id}

    Sleep   1s
    Stop Capturing    alias=${tshark_alias_ngap}
    IF   "${gnb_id}"=="2"   Verify Tshark For Given Number Of Messages
    ...   alias=${tshark_alias_ngap}
    ...   packet_filter=${ICS_SETUP_RESP_SUCCESS}
    ...   number_of_messages=1
    Log To Console    UE: ${ue_id} registered ok

    Print Measurements  ue_id=${ue_id}

    [Teardown]    Teardown Tshark    alias=${tshark_alias_ngap}

Establish PDU Session For UE
    [Arguments]  ${ue_id}=1  ${pdu_id}=2  ${nwslice}=2  ${gw_id}=2
    Log To Console  Establish PDU Session For UE: ${ue_id}, PDU: ${pdu_id}, Slice: ${nwslice}, GW: ${gw_id} and set trf type as internal for data
    Execute Egate Command  cmd=set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal

    Establish Pdu Session  ue_id=${ue_id}  pdu_id=${pdu_id}  nwslice=${nwslice}  gw_id=${gw_id}
    ...    pass_regexp=Established PDU session

Start Or Stop Data On All QFIs
    [Arguments]  ${ue_id}=1  ${pdu}=1  ${qfis}=1  ${throughput}=1  ${operation}=start

    Log To Console  Start Data On All QFIs for UE: ${ue_id}, PDU: ${pdu}, throughput: ${throughput} kbps
    FOR    ${qfi}    IN    @{qfis}
      IF  "${operation}"=="start"
          Execute Egate Command  cmd=trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} dir=dl kbps=${throughput}
          Execute Egate Command  cmd=trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} dir=ul kbps=${throughput}
      ELSE IF   "${operation}"=="stop"
          Execute Egate Command  cmd=trf_data_stop ue=${ue_id} pdu=${pdu} qfi=${qfi} dir=dl
          Execute Egate Command  cmd=trf_data_stop ue=${ue_id} pdu=${pdu} qfi=${qfi} dir=ul
      END

      Sleep  2s
      IF  "${operation}"=="start"
      ...  Execute Egate Command And Wait For Data  cmd=trf_internal_disp ue=${ue_id} pdu=${pdu} qfi=${qfi} dir=bi
    END

Change UE Location
    [Arguments]  ${ue_id}=1  ${cell_id}=1  ${gnb_id}=2
    #Log To Console  Change UE Location to gnb_id: ${gnb_id}, cell_id: ${cell_id}..

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
    Log To Console    UE: ${ue_id} deregistered ok
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
    Log To Console  Wait for gNB Configured state..
    Wait Until Keyword Succeeds      5min     10sec     Ensure gNB state is Configured Or IntegratedToRan
    Wait Until Keyword Succeeds      3min     5sec      Ensure cell is configured

Ensure gNB state is Configured Or IntegratedToRan
    Setup admin
    ${bts_state}=       Get Mrbts State
    ${current_date}=    Get Current Date
    Log To Console    ${current_date} : BTS STATE : ${bts_state}
    Should Contain Any            ${bts_state}    Configured    IntegratedToRan    OnAir    ignore_case=${TRUE}
    [Teardown]    Teardown admin

Ensure cell is configured
    Setup admin
    ${cells_info}=           Get cells info
    ${procedural_status}=    Set Variable     ${cells_info[0]['status']['proceduralStatus']}
    ${current_date}=         Get Current Date
    Log To Console     ${current_date} : CELL STATE : ${procedural_status}
    Should be Equal As Strings       ${procedural_status}     configured      ignore_case=${TRUE}
    [Teardown]    Teardown admin

Get Measurement Id For Frequency
    [Arguments]  ${ue_id}=1  ${event_type}=EventA3  ${carrier_freq}=0  ${trigger}=rsrp

    get_ue_measurement_configuration  ue_id=${ue_id}  alias=${ue_id}_meas

    ${meas_id}    get_meas_id_for_measurement_on_frequency  event_type=${event_type}  carrier_freq=${carrier_freq}
    ...    alias=${ue_id}_meas  trigger=${trigger}
    Log To Console  MeasId for ${event_type} on carrier freq ${carrier_freq} is: ${meas_id}

    RETURN    ${meas_id}

# Same flow can be used for incoming and outgoing Xn if HO
inter-gNB handover message flow Xn
    [Arguments]    ${ue_id}=1
    Expect Message Flow
    ...     gNB2:XNAP_HandoverRequest as HO_Req
    ...     gNB2:XNAP_HandoverRequestAcknowledge as HO_Req_Ack
    ...     gNB2:XNAP_SNStatusTransfer
    ...     alias=UE${ue_id}_Handover   overall_timeout=15

inter-gNB handover message flow Xn Cancel
    [Arguments]    ${ue_id}=1
    Expect Message Flow
    ...     gNB2:XNAP_HandoverRequest as HO_Req
    ...     gNB2:XNAP_HandoverRequestAcknowledge as HO_Req_Ack
    ...     gNB2:XNAP_HandoverCancel
    ...     alias=UE${ue_id}_Handover   overall_timeout=15
    Sleep  5s

inter-gNB handover message flow failure
    [Arguments]    ${ue_id}=1
    Expect Message Flow
    ...     gNB3_XN:XNAP_HandoverRequest as HO_Req
    ...     gNB3_XN:XNAP_HandoverRequestAcknowledge as HO_Req_Ack
    ...     gNB3_XN:XNAP_SNStatusTransfer
    ...     alias=UE${ue_id}_Handover   overall_timeout=15

    Expect Message Flow
    ...     gNB2:E1AP_BearerContextSetupRequest
    ...     gNB2:E1AP_BearerContextSetupResponse
    ...     alias=E1AP_bearer_context_UE_${ue_id}  overall_timeout=15

    Expect Message Flow
    ...     gNB2:F1AP_UEContextSetupRequest
    ...     gNB2:F1AP_UEContextSetupResponse
    ...     alias=F1AP_context_UE_${ue_id}  overall_timeout=15

    #Expect Message Will Not Occur
    #...     UE_${ue_id}:NR-RRC_RRCReconfigurationComplete as HORRCReconfigurationComplete
    #...     alias=no_UE${ue_id}_NR-RRC_ReconfComplete_ho  overall_timeout=15

Send Swconfig for AP
    [Arguments]    ${ap_swconfig_path}
    Log To Console  Send Swconfig for AP: ${ap_swconfig_path}..
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
    Log To Console  Stop Edaemon Egate..
    ${edaemon_pid}=    Run    pgrep edaemon
    ${edaemon_status}    Run Keyword And Return Status    Should Not Be Empty    ${edaemon_pid}
    IF   ${edaemon_status}   Run   sudo pkill -9 edaemon
    ${egate_pid}=    Run    pgrep egate
    ${egate_status}    Run Keyword And Return Status    Should Not Be Empty    ${egate_pid}
    IF   ${egate_status}   Run   sudo pkill -9 egate

Links up
    Setup X2 link to gNB sim
    Sleep  1s
    #Xn link up
    #Sleep  1s

Setup X2 link to gNB sim
    Log To Console  Setup X2 link to gNB sim..
    ${cmd}    Catenate    enb_x2_link_up    enb\=1 target\=3
    Execute Egate Command    ${cmd}    pass_regexp=is up

Perform NG Handover
    [Arguments]    ${ue_id}=1  ${phycell_id}=381  ${direction}=outgoing  ${ho_failure}=${False}  ${carrier_freq}=0
    ...  ${carrier_freq2}=0  ${intrafreq}=${False}

    IF  "${intrafreq}"=="${False}"
        Log To Console  Perform ${direction} Inter Gnb inter freq NG Handover via AMF for UE: ${ue_id}
    ELSE IF  "${intrafreq}"=="${True}"
        Log To Console  Perform ${direction} Inter Gnb intra freq NG Handover via AMF for UE: ${ue_id}
    END

    ${time}    Get Current Date    result_format=%Y-%m%d_%H:%M:%SS    exclude_millis=${True}

    ${tcpdump_process}  ${log_filepath}  ${alias}  Start Tcpdump On Remote Interface
    ...  alias=NGAP_E1AP_F1AP_${ue_id}_${direction}_${time}  log_filename_prefix=${TEST_NAME}_UE${ue_id}_NGAP_E1AP_F1AP_${direction}_${time}
    ...  log_dirpath=${OUTPUT_DIR}

    Set Test Variable    ${TSHARKALIAS_NG}       ${alias}
    Set Test Variable    ${TSHARKALIAS_NG_PATH}  ${log_filepath}

    IF  "${ho_failure}"=="${False}"
        Inter-gNB Handover Message Flow NG  ue_id=${ue_id}
    ELSE IF   "${ho_failure}"=="${True}"
        Inter-gNB Handover Message Flow NG With HO Preparation Failure  ue_id=${ue_id}
    END

    Print Measurements  ue_id=${ue_id}

    ${ngho}=  Set Variable  Inter-eNB handover from
    ${ngho_fail}=  Set Variable  Handover Preparation Failure

    ${ret1}=  Set Variable  DEFAULT
    IF  "${direction}"=="outgoing" and "${intrafreq}"!="${True}"
    ...   Get And Send A2 Meas Id  ue_id=${ue_id}  phycell_id=${phycell_id}  carrier_freq=${carrier_freq}

    IF  "${direction}"=="outgoing"   Get And Send A3 Meas Id
    ...   ue_id=${ue_id}   phycell_id=${phycell_id}   carrier_freq=${carrier_freq2}   regexp=${ngho}

    IF  "${direction}"=="incoming" and "${ho_failure}"=="${False}"
        ${ret1}   Get And Send A3 Meas Id  ue_id=${ue_id}  phycell_id=${phycell_id}  carrier_freq=${carrier_freq}  regexp=${ngho}
    ELSE IF  "${direction}"=="incoming" and "${ho_failure}"=="${True}"
        Get And Send A3 Meas Id  ue_id=${ue_id}  phycell_id=${phycell_id}  carrier_freq=${carrier_freq}  regexp=${ngho_fail}
    END

    Flow Occurred as expected  alias=UE${ue_id}_NG_Handover
    Sleep  1s

    # Outgoing HO tshark capture can be started immediately after verifying it's succeeded..
    IF  "${direction}"=="outgoing"
        Stop Tshark  ${TSHARKALIAS_NG}
        Log To Console  Tshark stopped with alias: ${TSHARKALIAS_NG} ..
    END

    Print Measurements  ue_id=${ue_id}

    # Generate PDML
    ${filter}=  Set Variable  e1ap or ngap or nr-rrc or f1ap
    ${out}=  Set Variable  ${OUTPUT_DIR}/${TEST_NAME}_UE${ue_id}.pdml
    Set Test Variable  ${PDML}  ${out}

    IF  "${direction}"=="incoming"
    ...  Run  tshark -Y "${filter}" -r ${OUTPUT_DIR}/${TEST_NAME}_UE${ue_id}_NGAP_E1AP_F1AP_${direction}_${time}.pcap -T pdml > ${out}

    RETURN  ${ret1}

Get And Send A2 Meas Id
    [Arguments]    ${ue_id}=1  ${phycell_id}=381  ${carrier_freq}=0

    ${meas_id}=  Get Measurement Id For Frequency  ue_id=${ue_id}  event_type=EventA2  carrier_freq=${carrier_freq}
    Log To Console  Sending A2Event with MeasId: ${meas_id}

    Execute Egate Command
    ...  cmd=ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 srsrp_nr=19 phycell_id=${phycell_id} nrsrp_nr=100
    ...  pass_regexp=UEC-1: UE${ue_id}
    Sleep  2s

Get And Send A3 Meas Id
    [Arguments]    ${ue_id}=1  ${phycell_id}=50  ${carrier_freq}=0  ${regexp}=FAIL

    ${meas_id}=  Get Measurement Id For Frequency  ue_id=${ue_id}  event_type=EventA3  carrier_freq=${carrier_freq}
    Log To Console  Sending A3Event with MeasId: ${meas_id}

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

inter-gNB handover message flow NG SIM
    [Arguments]    ${ue_id}=1
    Expect Message Flow
    ...    AMF1:NGAP_HandoverRequired
    #...    AMF1:NGAP_HandoverCommand
    ...    AMF1:NGAP_UplinkRANStatusTransfer
    #...    AMF1:NGAP_UEContextReleaseCommand
    ...    AMF1:NGAP_UEContextReleaseComplete
    ...    alias=UE${ue_id}_NG_Handover   overall_timeout=15

inter-gNB handover message flow NG
    [Arguments]    ${ue_id}=1
    Expect Message Flow
    ...    AMF1:NGAP_HandoverRequired
    #...    AMF1:NGAP_HandoverCommand
    ...    AMF1:NGAP_UplinkRANStatusTransfer
    #...    AMF1:NGAP_UEContextReleaseCommand
    ...    AMF1:NGAP_UEContextReleaseComplete
    ...    alias=UE${ue_id}_NG_Handover   overall_timeout=15

inter-gNB handover message flow NG With HO Preparation Failure
    [Arguments]    ${ue_id}=1
    Expect Message Flow
    ...    AMF1:NGAP_HandoverRequired
    ...    AMF1:NGAP_HandoverPreparationFailure
    ...    alias=UE${ue_id}_NG_Handover   overall_timeout=15

F1AP UE Context Mod Failure Flow
    [Arguments]    ${ue_id}=1
    Expect Message Flow
    ...    gNB2:F1AP_UEContextModificationRequest
    ...    gNB2:F1AP_UEContextModificationFailure
    ...    alias=UE${ue_id}_F1AP_ctx_mod   overall_timeout=30

F1AP UE Context Mod Success Flow
    [Arguments]    ${ue_id}=1
    Expect Message Flow
    ...    gNB2:F1AP_UEContextModificationRequest
    ...    gNB2:F1AP_UEContextModificationResponse
    ...    alias=UE${ue_id}_F1AP_ctx_mod   overall_timeout=30

F1AP No UE Context Mod Flow
    [Arguments]    ${ue_id}=1
    Expect Message Will Not Occur
    ...    gNB2:F1AP_UEContextModificationRequest
    ...    alias=UE${ue_id}_F1AP_ctx_mod   overall_timeout=10

Trigger MeasGap Configuration Using A1 Or A2 Event
    [Arguments]    ${ue_id}=1    ${event}=A2
    Log To Console  Trigger MeasGap Configuration Using ${event} Event..
    ${meas_id}=  Get Measurement id    Event${event}   ue_id=${ue_id}
    Execute Egate Command    cmd=ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} srsrp_nr=40 event=${event}
    ...  pass_regexp=rrcReconfigurationComplete
    Execute Egate Command  cmd=ue_meas_cfg_disp id=${ue_id} meas_obj_type=nr  pass_regexp=NR MEASUREMENT IDENTITIES
    Sleep  2s

Get Measurement id
    [Arguments]  ${event_type}=EventA3  ${ue_id}=1  ${matching_line}=0
    Log To Console  Get Measurement id for UE: ${ue_id}, event: ${event_type}
    ${measurements}=    Execute Egate Command And Wait For Data    cmd=ue_meas_cfg_disp id=${ue_id}  pass_regexp=${event_type}  timeout=10s
    ${matching_lines}=  Get Lines Containing String  ${measurements}  ${event_type}
    ${first_line}=  Get Line  ${matching_lines}  ${matching_line}
    @{words}=  Split String  ${first_line}
    Log To Console  MeasId: ${words}[0] for event: ${words}[2] found for RAT: ${words}[1]
    RETURN  ${words}[0]

UE VoNR Call
    [Arguments]   ${ue_id}=1  ${pdu_id}=1

    Log To Console  UE VoNR Call add 5QI-1 QoS flow for UE: ${ue_id}

    Execute Egate Command     cmd=ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id} qosflows_to_add=1 by=amf  pass_regexp=Added QosFlow with QFI
    Log To Console  QoS flow 5qi1 added successfully
    Sleep  2s

Verify Data Forwarding
   [Arguments]   ${ret1}=DEFAULT  ${pdu1}=${False}  ${pdu2}=${False}  ${pdu3}=${False}  ${pdu4}=${False}

   IF  "${pdu1}"=="${True}"
       ${tunnels}   Get Lines Containing String  ${ret1}  For SEID: 1 for UE IP:
       Log To Console  Data Forwarding tunnels for PDU:1 in incoming HO: ${tunnels}
   END

   IF  "${pdu2}"=="${True}"
      ${tunnels}   Get Lines Containing String  ${ret1}  For SEID: 2 for UE IP:
      Log To Console  Data Forwarding tunnels for PDU:2 in incoming HO: ${tunnels}
   END

   IF  "${pdu3}"=="${True}"
       ${tunnels}   Get Lines Containing String  ${ret1}  For SEID: 3 for UE IP:
       Log To Console  Data Forwarding tunnels for PDU:3 in incoming HO: ${tunnels}
   END

   IF  "${pdu4}"=="${True}"
       ${tunnels}   Get Lines Containing String  ${ret1}  For SEID: 4 for UE IP:
       Log To Console  Data Forwarding tunnels for PDU:4 in incoming HO: ${tunnels}
   END

Verify Expected Number Of Elements In PDML
    [Arguments]    ${PDML}    ${msg}=msg  ${field}=field  ${proto}=ngap
    ...  ${times}=1

    Log To Console  Verify Expected Number Of Elements In PDML ..
    ${pdml_xml}    parse xml    ${PDML}

    # Find ${msg}, should be found always one time
    ${elements}   get elements    ${pdml_xml}    xpath=.//proto[@name="${proto}"]//field[@name="${proto}.${msg}"]
    ${LENGTH}=    Get Length   ${elements}
    IF   "${LENGTH}"!="1"   Log To Console  ERROR: Wrong number of ${msg} found: ${LENGTH}, expected 1 times!!
    SHOULD BE TRUE    ${LENGTH} == 1

    # Calculate total number of ${field} IEs in all found messages
    ${LENGTH_Total}=  Evaluate  0
    ${VAR1}=  Set Variable  ${field}
    FOR  ${i}  IN   @{elements}
        ${elements2}   get elements    ${i}    xpath=.//field[@name="${proto}.${VAR1}"]
        ${LENGTH}=    Get Length   ${elements2}
        ${LENGTH_Total}=  Evaluate  ${LENGTH_Total}+${LENGTH}
    END
    IF   "${LENGTH_Total}"!="${times}"  Log To Console  ERROR: Expected ${VAR1} n ${times}, found: ${LENGTH_Total}!
    SHOULD BE TRUE    ${LENGTH_Total} == ${times}

    Log To Console  Number of ${field}: ${LENGTH_Total} found in ${msg} from PDML file successfully!

Check Item Exists n Times In PDML
    [Arguments]  ${proto}=ngap  ${msg}=msg  ${field}=field  ${times}=1
    Verify Expected Number Of Elements In PDML   PDML=${OUTPUT_DIR}/${TEST_NAME}.pdml  msg=${msg}
    ...  field=${field}  times=${times}  proto=${proto}

Verify Expected Number Of Elements In PDML Enhanced
    [Arguments]    ${PDML}    ${msg}=msg  ${field}=field  ${proto}=ngap
    ...  ${times}=1

    Log To Console  Verify Expected Number Of Elements In PDML ..
    ${pdml_xml}    parse xml    ${PDML}

    # Find ${msg}, should be found always one time
    ${elements}   get elements    ${pdml_xml}    xpath=.//proto[@name="${proto}"]//field[@name="${proto}.${msg}"]
    ${LENGTH}=    Get Length   ${elements}
    IF   "${LENGTH}"!="1"  Log To Console  ERROR: Wrong number of ${msg} found: ${LENGTH}, expected 1 times!!
    SHOULD BE TRUE    ${LENGTH} == 1

    # Calculate total number of ${field} IEs in all found messages
    ${LENGTH_Total}=  Evaluate  0
    ${VAR1}=  Set Variable  ${field}
    FOR  ${i}  IN   @{elements}
        ${elements2}   get elements    ${i}    xpath=.//field[@name="${proto}.${VAR1}"]
        ${LENGTH}=    Get Length   ${elements2}
        ${LENGTH_Total}=  Evaluate  ${LENGTH_Total}+${LENGTH}
    END
    IF   "${LENGTH_Total}"!="${times}"  Log To Console  ERROR: Expected ${VAR1} n ${times}, found: ${LENGTH_Total}!
    SHOULD BE TRUE    ${LENGTH_Total} == ${times}

    Log To Console  Number of ${field}: ${LENGTH_Total} found in ${msg} from PDML file successfully!

Handle ElemenList
  [Arguments]  ${elementlist}  ${searchparameterlist}

  ${found}=  Set Variable  FAIL
  FOR  ${i}  IN  @{elementlist}
    ${found}=  Handle Parameter Search  element=${i}  searchparameterlist=${searchparameterlist}
    IF  "${found}"!="FAIL"  BREAK
  END
  RETURN  ${found}

Handle Parameter Search
  [Arguments]  ${element}  ${searchparameterlist}

  ${found}       Create List    ${element}
  FOR  ${i}  IN  @{searchparameterlist}
    ${element1}  Run keyword and ignore error  Get element  ${element}  .//field[@showname="${i}"]
    IF  "${element1}[0]"=="PASS"
        Append To List   ${found}  ${element1}[1]
    ELSE
        ${found}   Set Variable   FAIL
        BREAK
    END
  END
  RETURN  ${found}

Verify FullConfig
    [Arguments]  ${fullConfigSet}=${False}

    Log To Console  Verify if FullConfig exists in E1, F1 and NG interface messages: ${fullConfigSet}

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

    Log To Console  Verify SourceConfig IE in UEContextSetupRequest: Check msg with filter=${filter1} verified OK!

    ${filter1}=  Set Variable  f1ap.UEContextSetupResponse_element && ${found}f1ap.id == 94

    Verify Tshark For Single Message
    ...    alias=${TSHARKALIAS_NG}  packet_filter=${filter1}
    ...    pcap_file_path=${TSHARKALIAS_NG_PATH}  timeout=10

    Log To Console  Verify FullConfig IE in UEContextSetupResponse: Check msg with filter=${filter1} verified OK!

    ${filter1}=  Set Variable  ngap.HandoverRequestAcknowledge_element && ${found}nr-rrc.fullConfig

    Verify Tshark For Single Message
    ...    alias=${TSHARKALIAS_NG}  packet_filter=${filter1}
    ...    pcap_file_path=${TSHARKALIAS_NG_PATH}  timeout=10

    Log To Console  Verify FullConfig IE in HandoverRequestAcknowledge: Check msg with filter=${filter1} verified OK!

Verify DefaultDRB In E1 And NG
    [Arguments]  ${drbList}  ${times}
    Log To Console  Verify DefaultDRB In E1 And NG for DRBs: ${drbList}, times: ${times}

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

    Log To Console  Verify DRB Tunnels In E1 And NG for DRBs: ${drbList}, times: ${times}
    Verify DRB Tunnels In BearerContextSetupRequest   drbList=${drbList}  times=${times}
    Verify DRB Tunnels In BearerContextSetupResponse  drbList=${drbList}  times=${times}
    Verify DRB Tunnels In HandoverRequestAcknowledge  drbList=${drbList}  times=${times}

Verify PDU Tunnels In E1 And NG
    [Arguments]  ${pduList}  ${times}

    Log To Console  Verify PDU Tunnels In E1 And NG for PDUs: ${pduList}, times: ${times}
    Verify PDU Tunnels In BearerContextSetupRequest   pduList=${pduList}  times=${times}
    Verify PDU Tunnels In BearerContextSetupResponse  pduList=${pduList}  times=${times}
    Verify PDU Tunnels In HandoverRequestAcknowledge  pduList=${pduList}  times=${times}

Verify DefaultDRB In BearerContextSetupRequest
    [Arguments]  ${drbList}  ${times}

    ${msgpath}=  Set Variable
    ...  .//field[@name='e1ap.BearerContextSetupRequest_element']//field[@name='e1ap.DRB_To_Setup_Item_NG_RAN_element']

    ${TIMES_Total}=  Evaluate  0
    FOR  ${drb}  IN  @{drbList}
        @{findStr}=  Set Variable  dRB-ID: ${drb}  defaultDRB: true&&sDAP-Header-UL: present
        ${iTimes}  Find Msgpath With Searchfields From Pdml  PDML=${PDML}  msgpath=${msgpath}  searchfields=${findStr}
        ${TIMES_Total}=  Evaluate  ${TIMES_Total}+${iTimes}
    END

    IF   "${TIMES_Total}"!="${times}"
    ...  Log To Console  ERROR: Expected DefaultDRB In BearerContextSetupRequest ${times} times, found: ${TIMES_Total}!
    SHOULD BE TRUE    ${TIMES_Total} == ${times}
    Log To Console  PASS: Expected DefaultDRB In BearerContextSetupRequest ${times} times, found: ${TIMES_Total}!

Verify DefaultDRB In HandoverRequestAcknowledge
    [Arguments]  ${drbList}  ${times}

    ${msgpath}=  Set Variable
    ...  .//field[@name='ngap.HandoverRequestAcknowledge_element']//field[@name='nr-rrc.DRB_ToAddMod_element']

    ${TIMES_Total}=  Evaluate  0
    FOR  ${drb}  IN  @{drbList}
        @{findStr}=  Set Variable  drb-Identity: ${drb}  sdap-Config  defaultDRB: True&&sdap-HeaderUL: present
        ${iTimes}  Find Msgpath With Searchfields From Pdml  PDML=${PDML}  msgpath=${msgpath}  searchfields=${findStr}
        ${TIMES_Total}=  Evaluate  ${TIMES_Total}+${iTimes}
    END

    IF   "${TIMES_Total}"!="${times}"
    ...  Log To Console  ERROR: Expected DefaultDRB In HandoverRequestAcknowledge ${times} times, found: ${TIMES_Total}!
    SHOULD BE TRUE    ${TIMES_Total} == ${times}
    Log To Console  PASS: Expected DefaultDRB In HandoverRequestAcknowledge ${times} times, found: ${TIMES_Total}!

Verify DRB Tunnels In BearerContextSetupRequest
    [Arguments]  ${drbList}  ${times}

    ${msgpath}=  Set Variable
    ...  .//field[@name='e1ap.BearerContextSetupRequest_element']//field[@name='e1ap.DRB_To_Setup_Item_NG_RAN_element']

    ${TIMES_Total}=  Evaluate  0
    FOR  ${drb}  IN  @{drbList}
        @{findStr}=  Set Variable  dRB-ID: ${drb}&&dRB-Data-Forwarding-Information-Request  data-Forwarding-Request: dL
        ${iTimes}  Find Msgpath With Searchfields From Pdml  PDML=${PDML}  msgpath=${msgpath}  searchfields=${findStr}
        ${TIMES_Total}=  Evaluate  ${TIMES_Total}+${iTimes}
    END

    IF   "${TIMES_Total}"!="${times}"
    ...  Log To Console  ERROR: Expected DRB Tunnels In BearerContextSetupRequest ${times} times, found: ${TIMES_Total}!
    SHOULD BE TRUE    ${TIMES_Total} == ${times}
    Log To Console  PASS: Expected DRB Tunnels In BearerContextSetupRequest ${times} times, found: ${TIMES_Total}!

Verify DRB Tunnels In BearerContextSetupResponse
    [Arguments]  ${drbList}  ${times}

    ${msgpath}=  Set Variable
    ...  .//field[@name='e1ap.BearerContextSetupResponse_element']//field[@name='e1ap.DRB_Setup_Item_NG_RAN_element']

    ${TIMES_Total}=  Evaluate  0
    FOR  ${drb}  IN  @{drbList}
        @{findStr}=  Set Variable  dRB-ID: ${drb}&&dRB-data-Forwarding-Information-Response  dL-Data-Forwarding: gTPTunnel
        ${iTimes}  Find Msgpath With Searchfields From Pdml  PDML=${PDML}  msgpath=${msgpath}  searchfields=${findStr}
        ${TIMES_Total}=  Evaluate  ${TIMES_Total}+${iTimes}
    END

    IF   "${TIMES_Total}"!="${times}"
    ...  Log To Console  ERROR: Expected DRB Tunnels In BearerContextSetupResponse ${times} times, found: ${TIMES_Total}!
    SHOULD BE TRUE    ${TIMES_Total} == ${times}
    Log To Console  PASS: Expected DRB Tunnels In BearerContextSetupResponse ${times} times, found: ${TIMES_Total}!

Verify DRB Tunnels In HandoverRequestAcknowledge
    [Arguments]  ${drbList}  ${times}

    ${msgpath}=  Set Variable
    ...  .//field[@name='ngap.HandoverRequestAcknowledge_element']//field[@name='ngap.DataForwardingResponseDRBItem_element']

    ${TIMES_Total}=  Evaluate  0
    FOR  ${drb}  IN  @{drbList}
        @{findStr}=  Set Variable  dRB-ID: ${drb}&&dLForwardingUP-TNLInformation: gTPTunnel  gTPTunnel
        ${iTimes}  Find Msgpath With Searchfields From Pdml  PDML=${PDML}  msgpath=${msgpath}  searchfields=${findStr}
        ${TIMES_Total}=  Evaluate  ${TIMES_Total}+${iTimes}
    END

    IF   "${TIMES_Total}"!="${times}"
    ...  Log To Console  ERROR: Expected DRB Tunnels In HandoverRequestAcknowledge ${times} times, found: ${TIMES_Total}!
    SHOULD BE TRUE    ${TIMES_Total} == ${times}
    Log To Console  PASS: Expected DRB Tunnels In HandoverRequestAcknowledge ${times} times, found: ${TIMES_Total}!

Verify DRB IDs In BearerContextSetupRequest
    [Arguments]  ${drbList}  ${times}

    ${msgpath}=  Set Variable
    ...  .//field[@name='e1ap.BearerContextSetupRequest_element']//field[@name='e1ap.DRB_To_Setup_Item_NG_RAN_element']

    ${TIMES_Total}=  Evaluate  0
    FOR  ${drb}  IN  @{drbList}
        @{findStr}=  Set Variable  dRB-ID: ${drb}&&sDAP-Configuration  sDAP-Header
        ${iTimes}  Find Msgpath With Searchfields From Pdml  PDML=${PDML}  msgpath=${msgpath}  searchfields=${findStr}
        ${TIMES_Total}=  Evaluate  ${TIMES_Total}+${iTimes}
    END

    IF   "${TIMES_Total}"!="${times}"
    ...  Log To Console  ERROR: DRB IDs In BearerContextSetupRequest ${times} times, found: ${TIMES_Total}!
    SHOULD BE TRUE    ${TIMES_Total} == ${times}
    Log To Console  PASS: Expected DRB IDs In BearerContextSetupRequest ${times} times, found: ${TIMES_Total}!

Verify DRB IDs In BearerContextSetupResponse
    [Arguments]  ${drbList}  ${times}

    ${msgpath}=  Set Variable
    ...  .//field[@name='e1ap.BearerContextSetupResponse_element']//field[@name='e1ap.DRB_Setup_Item_NG_RAN_element']

    ${TIMES_Total}=  Evaluate  0
    FOR  ${drb}  IN  @{drbList}
        # Find only one value and pass python script with empty variable:
        @{findStr}=  Set Variable  dRB-ID: ${drb}  ${EMPTY}
        ${iTimes}  Find Msgpath With Searchfields From Pdml  PDML=${PDML}  msgpath=${msgpath}  searchfields=${findStr}
        ${TIMES_Total}=  Evaluate  ${TIMES_Total}+${iTimes}
    END

    IF   "${TIMES_Total}"!="${times}"
    ...  Log To Console  ERROR: DRB IDs In BearerContextSetupResponse ${times} times, found: ${TIMES_Total}!
    SHOULD BE TRUE    ${TIMES_Total} == ${times}
    Log To Console  PASS: Expected DRB IDs In BearerContextSetupResponse ${times} times, found: ${TIMES_Total}!

Verify DRB IDs In HandoverRequestAcknowledge
    [Arguments]  ${drbList}  ${times}

    ${msgpath}=  Set Variable
    ...  .//field[@name='ngap.HandoverRequestAcknowledge_element']//field[@name='nr-rrc.DRB_ToAddMod_element']

    ${TIMES_Total}=  Evaluate  0
    FOR  ${drb}  IN  @{drbList}
        @{findStr}=  Set Variable  drb-Identity: ${drb}&&pdcp-Config  drb
        ${iTimes}  Find Msgpath With Searchfields From Pdml  PDML=${PDML}  msgpath=${msgpath}  searchfields=${findStr}
        ${TIMES_Total}=  Evaluate  ${TIMES_Total}+${iTimes}
    END

    IF   "${TIMES_Total}"!="${times}"
    ...  Log To Console  ERROR: DRB IDs In HandoverRequestAcknowledge ${times} times, found: ${TIMES_Total}!
    SHOULD BE TRUE    ${TIMES_Total} == ${times}
    Log To Console  PASS: Expected DRB IDs In HandoverRequestAcknowledge ${times} times, found: ${TIMES_Total}!

Verify PDU Tunnels In BearerContextSetupRequest
    [Arguments]  ${pduList}  ${times}

    ${msgpath}=  Set Variable
    ...  .//field[@name='e1ap.BearerContextSetupRequest_element']//field[@name='e1ap.PDU_Session_Resource_To_Setup_Item_element']

    ${TIMES_Total}=  Evaluate  0
    FOR  ${pdu}  IN  @{pduList}
        @{findStr}=  Set Variable  pDU-Session-ID: ${pdu}&&pDU-Session-Data-Forwarding-Information-Request  data-Forwarding-Request: dL
        ${iTimes}  Find Msgpath With Searchfields From Pdml  PDML=${PDML}  msgpath=${msgpath}  searchfields=${findStr}
        ${TIMES_Total}=  Evaluate  ${TIMES_Total}+${iTimes}
    END

    IF   "${TIMES_Total}"!="${times}"
    ...  Log To Console  ERROR: Expected PDU Tunnels In BearerContextSetupRequest ${times} times, found: ${TIMES_Total}!
    SHOULD BE TRUE    ${TIMES_Total} == ${times}
    Log To Console  PASS: Expected PDU Tunnels In BearerContextSetupRequest ${times} times, found: ${TIMES_Total}!

Verify PDU Tunnels In BearerContextSetupResponse
    [Arguments]  ${pduList}  ${times}

    ${msgpath}=  Set Variable
    ...  .//field[@name='e1ap.BearerContextSetupResponse_element']//field[@name='e1ap.PDU_Session_Resource_Setup_Item_element']

    ${TIMES_Total}=  Evaluate  0
    FOR  ${pdu}  IN  @{pduList}
        @{findStr}=  Set Variable  pDU-Session-ID: ${pdu}&&pDU-Session-Data-Forwarding-Information-Response  dL-Data-Forwarding: gTPTunnel
        ${iTimes}  Find Msgpath With Searchfields From Pdml  PDML=${PDML}  msgpath=${msgpath}  searchfields=${findStr}
        ${TIMES_Total}=  Evaluate  ${TIMES_Total}+${iTimes}
    END

    IF   "${TIMES_Total}"!="${times}"
    ...  Log To Console  ERROR: Expected PDU Tunnels In BearerContextSetupResponse ${times} times, found: ${TIMES_Total}!
    SHOULD BE TRUE    ${TIMES_Total} == ${times}
    Log To Console  PASS: Expected PDU Tunnels In BearerContextSetupResponse ${times} times, found: ${TIMES_Total}!

Verify PDU Tunnels In HandoverRequestAcknowledge
    [Arguments]  ${pduList}  ${times}

    ${msgpath}=  Set Variable
    ...  .//field[@name='ngap.HandoverRequestAcknowledge_element']//field[@name='ngap.PDUSessionResourceAdmittedItem_element']

    ${TIMES_Total}=  Evaluate  0
    FOR  ${pdu}  IN  @{pduList}
        @{findStr}=  Set Variable  pDUSessionID: ${pdu}  HandoverRequestAcknowledgeTransfer  dLForwardingUP-TNLInformation: gTPTunnel
        ${iTimes}  Find Msgpath With Searchfields From Pdml  PDML=${PDML}  msgpath=${msgpath}  searchfields=${findStr}
        ${TIMES_Total}=  Evaluate  ${TIMES_Total}+${iTimes}
    END

    IF   "${TIMES_Total}"!="${times}"
    ...  Log To Console  ERROR: Expected PDU Tunnels In HandoverRequestAcknowledge ${times} times, found: ${TIMES_Total}!
    SHOULD BE TRUE    ${TIMES_Total} == ${times}
    Log To Console  PASS: Expected PDU Tunnels In HandoverRequestAcknowledge ${times} times, found: ${TIMES_Total}!

Stop Collecting PMI Tickets And Verify Full Config Counters
    [Arguments]  ${ho_fail}=${False}  ${HO_PREP_SUCC_FULLCONF_TRG}=1  ${RRC_RECONF_COMP_FULLCONF_TRG}=1
    ...          ${NG_HO_RES_ALC_F_OTH_TRG}=0

    Log To Console  Stop Collecting PMI Tickets And Verify Full Config/HO failure Counters ..
    Stop Collecting Pmi Tickets
    ${msgs}=  Get All Pmi Tickets
    Log  All PMI tickets: ${msgs}

    IF  "${ho_fail}"=="${False}"
        Verify Pmi Counters In Records  3614113828 eq ${HO_PREP_SUCC_FULLCONF_TRG}  3614113829 eq ${RRC_RECONF_COMP_FULLCONF_TRG}
    ELSE IF  "${ho_fail}"=="${True}"
        Verify Pmi Counters In Records  3612679506 eq ${NG_HO_RES_ALC_F_OTH_TRG}
    END

    Log To Console  PMI counters verified ok:
    IF  "${ho_fail}"=="${False}"
        Log To Console  PMI: HO_PREP_SUCC_FULLCONF_TRG equals ${HO_PREP_SUCC_FULLCONF_TRG}
        Log To Console  PMI: RRC_RECONF_COMP_FULLCONF_TRG equals ${RRC_RECONF_COMP_FULLCONF_TRG}
    ELSE IF  "${ho_fail}"=="${True}"
        Log To Console  PMI: NG_HO_RES_ALC_F_OTH_TRG equals ${NG_HO_RES_ALC_F_OTH_TRG}
    END

Wait For Next Meas File And Verify Full Config Counters
    [Arguments]  ${NG_HO_RES_ALC_F_OTH_TRG}=0  ${HO_PREP_SUCC_FULLCONF_TRG}=1  ${RRC_RECONF_COMP_FULLCONF_TRG}=1  ${nrcell}=1

    Log To Console  Wait For Next Meas File And Verify Full Config Counters ..
    Wait For Next Full Pm Interval
    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File

    Verify Any Counters In File
    ...    M55125C07506    ${NG_HO_RES_ALC_F_OTH_TRG}       NG_HO_RES_ALC_F_OTH_TRG
    ...    M55147C00036    ${HO_PREP_SUCC_FULLCONF_TRG}     HO_PREP_SUCC_FULLCONF_TRG
    ...    M55147C00037    ${RRC_RECONF_COMP_FULLCONF_TRG}  RRC_RECONF_COMP_FULLCONF_TRG
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${nrcell}
    ...    file_path=${pm_counter_file}

    RETURN  ${pm_counter_file}

Verify Received Data Forwarding Packets For 5QIs Case01
    [Arguments]  ${pm_counter_file}

    Log To Console  Verify Received Data Forwarding Packets For 5QIs ..

    # Received data forwarding packets from airphone during handover:
    Verify Any Counters In File
    ...    M55337C04001 	>1  VOL_DL_FWDT_RCV_PDUSES_QOS_01
    ...    M55337C04002 	>1  VOL_DL_FWDT_RCV_PDUSES_QOS_02
    ...    M55337C04003 	 0  VOL_DL_FWDT_RCV_PDUSES_QOS_03
    ...    M55337C04004 	 0  VOL_DL_FWDT_RCV_PDUSES_QOS_04
    ...    M55337C04005 	>1  VOL_DL_FWDT_RCV_PDUSES_QOS_05
    ...    M55337C04006 	>1  VOL_DL_FWDT_RCV_PDUSES_QOS_06
    ...    M55337C04007 	>1  VOL_DL_FWDT_RCV_PDUSES_QOS_07
    ...    M55337C04008 	>1  VOL_DL_FWDT_RCV_PDUSES_QOS_08
    ...    M55337C04009 	>1  VOL_DL_FWDT_RCV_PDUSES_QOS_09

    ...    M55337C05001   >1  NUM_DL_FWDT_RCV_PDUSES_QOS_01
    ...    M55337C05002   >1  NUM_DL_FWDT_RCV_PDUSES_QOS_02
    ...    M55337C05003    0  NUM_DL_FWDT_RCV_PDUSES_QOS_03
    ...    M55337C05004    0  NUM_DL_FWDT_RCV_PDUSES_QOS_04
    ...    M55337C05005   >1  NUM_DL_FWDT_RCV_PDUSES_QOS_05
    ...    M55337C05006   >1  NUM_DL_FWDT_RCV_PDUSES_QOS_06
    ...    M55337C05007   >1  NUM_DL_FWDT_RCV_PDUSES_QOS_07
    ...    M55337C05008   >1  NUM_DL_FWDT_RCV_PDUSES_QOS_08
    ...    M55337C05009   >1  NUM_DL_FWDT_RCV_PDUSES_QOS_09
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1
    ...    file_path=${pm_counter_file}

Verify Received Data Forwarding Packets For 5QIs Case02
    [Arguments]  ${pm_counter_file}

    Log To Console  Verify Received Data Forwarding Packets For 5QIs ..

    # Received data forwarding packets from airphone during handover:
    Verify Any Counters In File
    ...    M55337C04001 	>1  VOL_DL_FWDT_RCV_PDUSES_QOS_01
    ...    M55337C04002 	>1  VOL_DL_FWDT_RCV_PDUSES_QOS_02
    ...    M55337C04003 	 0  VOL_DL_FWDT_RCV_PDUSES_QOS_03
    ...    M55337C04004 	 0  VOL_DL_FWDT_RCV_PDUSES_QOS_04
    ...    M55337C04005 	>1  VOL_DL_FWDT_RCV_PDUSES_QOS_05
    ...    M55337C04006 	>1  VOL_DL_FWDT_RCV_PDUSES_QOS_06
    ...    M55337C04007 	>1  VOL_DL_FWDT_RCV_PDUSES_QOS_07
    ...    M55337C04008 	>1  VOL_DL_FWDT_RCV_PDUSES_QOS_08
    ...    M55337C04009 	>1  VOL_DL_FWDT_RCV_PDUSES_QOS_09

    ...    M55337C05001   >1  NUM_DL_FWDT_RCV_PDUSES_QOS_01
    ...    M55337C05002   >1  NUM_DL_FWDT_RCV_PDUSES_QOS_02
    ...    M55337C05003    0  NUM_DL_FWDT_RCV_PDUSES_QOS_03
    ...    M55337C05004    0  NUM_DL_FWDT_RCV_PDUSES_QOS_04
    ...    M55337C05005   >1  NUM_DL_FWDT_RCV_PDUSES_QOS_05
    ...    M55337C05006   >1  NUM_DL_FWDT_RCV_PDUSES_QOS_06
    ...    M55337C05007   >1  NUM_DL_FWDT_RCV_PDUSES_QOS_07
    ...    M55337C05008   >1  NUM_DL_FWDT_RCV_PDUSES_QOS_08
    ...    M55337C05009   >1  NUM_DL_FWDT_RCV_PDUSES_QOS_09
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1
    ...    file_path=${pm_counter_file}

Set Default Bearer And Additional QoS Flows
    [Arguments]  ${def_qosflow}  ${add_qosflows}  ${integrity_prot}=${False}

    Log To Console  Set Default Bearer And Additional QoS Flows .. Default bearer qos flow: ${def_qosflow}, additional qos flows: ${add_qosflows}

    Execute Egate Command  cmd=qosflow_modify qos_flow=${def_qosflow} default=on
    Execute Egate Command  cmd=smf_param id=1 reset
    IF  "${add_qosflows}"!="None"  Execute Egate Command  cmd=smf_param id=1 additional_qosflows_to_activate=${add_qosflows}

    # Activates 'CB008116-A U-Plane Integrity Protection Functionality' on Airphone side.. Causes problems if data is active ..
    IF  "${integrity_prot}"=="${True}"
    ...  Execute Egate Command  cmd=smf_param id=1 security_indication=pdu_session_setup:required:preferred max_data_rate=64kbps

Clear And Start Collecting PMI Tickets
    Log To Console  Clear And Start Collecting PMI Tickets ..
    Clear Pmi Tickets
    Start Collecting Pmi Tickets
    Sleep  5s

Check Need Of Fresh PM Counter Interval
    ${status}  ${sMin}  need_to_wait_for_counter_interval
    Log To Console  Check Need Of Fresh PM Counter Interval: ${status}, minutes=${sMin}
    IF  "${status}"=="${True}"
        Log To Console  Need to wait for fresh interval ..
        Get Next Unpacked Full Pm Counters File
    ELSE IF  "${status}"=="${False}"
        Log To Console  No need to wait for fresh interval ..
    END

Delta Commissioning Single Parameter Value
    [Arguments]  ${parameter}=NULL  ${value}=false  ${dist_name}=MRBTS-1/NRBTS-1
    Log To Console  Delta Commissioning Single Parameter Value: ${dist_name}/${parameter}:${value} ..

    Perform Parameter Commissioning    dist_name=${dist_name}    parameter=${parameter}   value=${value}
    Wait Until Keyword Succeeds      3min     5sec      Ensure cell is configured

