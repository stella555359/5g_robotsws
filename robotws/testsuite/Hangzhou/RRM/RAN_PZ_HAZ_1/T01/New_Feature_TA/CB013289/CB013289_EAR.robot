*** Settings ***
Documentation
...   Author: ZHIFU.XU@nokia-sbell.com
...   Contact: ZHIFU.XU@nokia-sbell.com
...   Description: The user scenario related to AirPhone operation.


Suite Setup       Common Suite Setup For RRM
Suite Teardown    Common Suite Teardown For RRM

Test Timeout    600 minutes

Resource          ../../../Resources/Classical/RRM_Common_Resource.robot
Resource          CB013289_KeyWord.robot
Resource          CB013289_PM_Counter_KeyWord.robot
Resource          CB013289_Check_Point_KeyWord.robot
Library     ta5g_tshark
Library      ute_tshark
Library      Process
Library    taf.collectors.l1l2bip    WITH NAME    l1l2bip
Library    taf.collectors.tcpdump    WITH NAME    tcpdump
Library    taf.collectors.core    WITH NAME    core
Library    taf.transport.ssh    WITH NAME    ssh
Library    String
Library    Collections
Library    OperatingSystem
*** Variables ***
@{UE_ID_LIST}    ${1}    ${2}    ${3}    ${4}
${shell_script}     /opt/wts/latest/sosReport_ASIL/airphone_mirror.sh             # This can be where you have kept the file
${python_script}    /opt/wts/latest/sosReport_ASIL/gnbMirroring.py                # This can be where you have kept the file
&{teardown_cmd}      setup=./airphone_mirror.sh    teardown=./airphone_mirror.sh --stop
&{AP}     Ip=192.168.200.1    Username=toor4nsn    Password=oZPS0POrRieRtu    Connection=Ap

*** Test Cases ***
CB013289-A#B1_Exploratory_TC41_ignore_tunnel_information_if_fill_indirect_data_forwarding_tunnel_information
    [Tags]    CRT1    CB013289_42    Pass
    [Documentation]
    ...   This user scenario describes gNB’s will ignore all “DL Forwarding UP Tunnel information” provided for this
    ...    PDU Session In NGAP: Handover command if gNB propose direct data forwarding in NGAP:HandoverRequired
    ...    CB013289 feature is enabled by setting “NRBTS.actInterRatHoDirectDlDataFwd” to “IRATDirectDataFwdOnNg”
    ...    A NRADJECELL is configured with parameter “iRatDataForwardingMethod” set to “directDataFwd”
    ...    The parameter “NRDRB_5QI.dataForwarding” is set to “IRATDataFwd” for NRDRB_5QI MOCs corresponding to 5QI-X.

    [Setup]    Run Keywords    Prepare WTS Config With Active direct DataFW    ${CURDIR}/config/basic_setup_13289.cfg
    ...           AND          Case Precondition
    ...           AND          Download wireshark plugin
#    Kill agate and start egate
    Active Feature CB013289 On IRATDirectDataFwdOnNg
    Set NRADJECELL-5000 iRatDataForwardingMethod with directDataFwd
    ${command} =  catenate   SEPARATOR=
    ...    amf_ue_ng_handover_command_param id=1 ue=all action=include_indirect_tnl_info_direct_data_fwding
    ...    \ fteid_indirect_tnl_info=AA22:BB11:1122:CDEF:1234:AA99:7654:7410,9999 include_qosflow_to_be_forwarded_item=on
    Airphone Execute Egate Command    cmd=${command}
    # fill indirect data forwarding tunnel information in NGAP:HandoverCommand by egate
    Start Collect Counter    ${nrcell_distname}    ${gtp_packet_counter}    ${gtp_packet_counter_rule}
    Start Collect Wireshark For GNB
    Start Ip Traffic Capture
    UE Register And PDU Session Setup    ue_id=3    ue_gw=3
    Send Egate Command and verify output   ue_meas_cfg_disp id=3
    UE PDU Session Modify   ue_id=3  pdu=1  qos_flow_list=@{pdu_qos_list}  by=amf
    UE PDU Session Setup   ue_id=3  pdu=2  gw=2  pass_regexp=Pdu Session.*successfully
    UE PDU Session Modify   ue_id=3  pdu=2  qos_flow_list=@{pdu_qos_list2}  by=amf
    Start 10Mbps Traffic On PDU Session-1 QFI-1 dl for UE3
    Start 10Mbps Traffic On PDU Session-1 QFI-2 dl for UE3
    Start 10Mbps Traffic On PDU Session-1 QFI-3 dl for UE3
    Start 10Mbps Traffic On PDU Session-2 QFI-1 dl for UE3
    Start 10Mbps Traffic On PDU Session-2 QFI-2 dl for UE3
    Start 10Mbps Traffic On PDU Session-2 QFI-3 dl for UE3
    Start 10Mbps Traffic On PDU Session-2 QFI-4 dl for UE3
    Trigger inter-RAT Handover    ue_id=3  phycell_id=11
    sleep    5s
    ${local_file_path}=    Stop Wireshark log For GNB
    CB013289 EAR TC41 Check Ponit 1    ${local_file_path}
    Stop Collect Counter and verify PM counters

    [Teardown]    Run Keywords      Stop Wireshark log For GNB
    ...           AND               Stop Ip Traffic Capture
    ...           AND               Case Postcondition

CB013289-A#B1_TC42_PDCP_SN_and_QFI_shall_not_be_added_in_GTP-U_extension_header_when_use_direct_data_forwarding
    [Tags]    CRT2    CB013289_43    PASS
    [Documentation]
    ...    This user scenario is order to validate gNB behavior with respect to end markers, if UPF will send end markers
    ...    with QFI information in the GTP header, then gNB shall not add PDCP SN and QFI in GTP-U extension header
    ...    CB013289 feature is enabled by setting “NRBTS.actInterRatHoDirectDlDataFwd” to “IRATDirectDataFwdOnNg”
    ...    A NRADJECELL is configured with parameter “iRatDataForwardingMethod” set to “directDataFwd”
    ...    The parameter “NRDRB_5QI.dataForwarding” is set to “IRATDataFwd” for NRDRB_5QI MOCs corresponding to 5QI-X.
    ...    (not include 5QI-1 or 5QI-2)

    [Setup]    Case Precondition
#    Kill agate and start egate
    Active Feature CB013289 On IRATDirectDataFwdOnNg
    Set NRADJECELL-5000 iRatDataForwardingMethod with directDataFwd
    #set UPF send end markers with  QFI information in the GTP header by egate
    Start Collect Counter    ${nrcell_distname}    ${direct_counter}    ${direct_counter_rule}
    Start Collect Wireshark For GNB
    Start Ip Traffic Capture
    UE4 Register
    UE4 And PDU Session-1 Gateway-4 Setup
    Send Egate Command and verify output   ue_meas_cfg_disp id=4
    UE PDU Session Modify   ue_id=4  pdu=1  qos_flow_list=@{pdu_qos_list}  by=amf
    UE4 And PDU Session-2 Gateway-4 Setup
    UE PDU Session Modify   ue_id=4  pdu=2  qos_flow_list=@{pdu_qos_list2}  by=amf
    Start 10Mbps Traffic On PDU Session-1 QFI-1 dl for UE4
    Start 10Mbps Traffic On PDU Session-1 QFI-2 dl for UE4
    Start 10Mbps Traffic On PDU Session-1 QFI-3 dl for UE4
    Start 10Mbps Traffic On PDU Session-2 QFI-1 dl for UE4
    Start 10Mbps Traffic On PDU Session-2 QFI-2 dl for UE4
    Start 10Mbps Traffic On PDU Session-2 QFI-3 dl for UE4
    Start 10Mbps Traffic On PDU Session-2 QFI-4 dl for UE4
    Trigger inter-RAT Handover    ue_id=4  phycell_id=11
    Stop Collect Counter and verify PM counters

    [Teardown]    Run Keywords      Stop Wireshark log For GNB
    ...           AND               Run Keyword And Ignore Error    Stop Ip Traffic Capture
    ...           AND               Case Postcondition


CB013289-A#B1_Exploratory_TC43_Multi-UE_Successful_IRAT_ handover_with_direct_data_forwarding
    [Tags]    CRT3    CB013289_44    PASS
    [Documentation]
    ...    It is the successful case IRAT HO is triggered with direct data forwarding with Multi-UE
    ...    This user scenario describes gNB’s behavior when a ‘B2 Measurement Report’ is received from the UE,
    ...    It is the successful case IRAT HO is triggered with direct data forwarding through NG interface.
    ...    CB013289 feature is enabled by setting “NRBTS.actInterRatHoDirectDlDataFwd” to “IRATDirectDataFwdOnX2”
    ...    A NRADJECELL is configured with parameter “iRatDataForwardingMethod” set to “directDataFwd”
    ...    The parameter “NRDRB_5QI.dataForwarding” is set to “IRATDataFwd” for NRDRB_5QI MOCs corresponding to 5QI-X.
    ...    (not include 5QI-1 or 5QI-2)
    ...    NOte:this case is not set 5QI1&2 for data forwarding
    [Setup]    Run Keywords     Case Precondition For Multi UE
    ...           AND          start tcpdump on vm
#    Kill agate and start egate
    Active Feature CB013289 On IRATDirectDataFwdOnNg    #feature enable
    Set NRADJECELL-5000 iRatDataForwardingMethod with directDataFwd
    Start Collect Wireshark For GNB
    FOR    ${UE_ID}    IN    @{UE_ID_LIST}
        UE Register And PDU Session Setup    ue_id=${UE_ID}    ue_gw=${UE_ID}
        Send Egate Command and verify output   ue_meas_cfg_disp id=${UE_ID}
        UE PDU Session Modify   ue_id=${UE_ID}  pdu=1  qos_flow_list=@{pdu_qos_list}  by=amf
    END
    FOR    ${TIMES}    IN RANGE    1    6
        IRAT HO with Muti UE and HO back to 5G
        sleep    3s
    END
    #collect snapshot
    [Teardown]    Run Keywords      Stop Wireshark log For GNB
    ...           AND               stop tcpdump on vm
    ...           AND               Case Postcondition


CB013289-A#B1_Exploratory_TC44_End_markers_are_not_received_for_the_PDU_sessions_before_End_marker_timer_expiry
    [Tags]    CRT4    CB013289_45   PASS
    [Documentation]
    ...   This user scenario is describe that Upon reception of End marker, or upon the expiry of End marker timer
    ...    “NRBTS.pduSessionEndMarkerTimerUpf”, the data forwarding is ended and the GTP tunnels are released
    ...    CB013289 feature is enabled by setting “NRBTS.actInterRatHoDirectDlDataFwd” to “IRATDirectDataFwdOnNg”
    ...    A NRADJECELL is configured with parameter “iRatDataForwardingMethod” set to “directDataFwd”
    ...    The parameter “NRDRB_5QI.dataForwarding” is set to “IRATDataFwd” for NRDRB_5QI MOCs corresponding to 5QI-X.

    [Setup]    Run Keywords    Prepare WTS Config With Active direct DataFW    ${CURDIR}/config/basic_setup_13289.cfg
    ...           AND          Case Precondition
#    Kill agate and start egate
    Active Feature CB013289 On IRATDirectDataFwdOnNg
    Set NRADJECELL-5000 iRatDataForwardingMethod with directDataFwd
    Set pduSessionEndMarkerTimer with 100ms
    Airphone Execute Egate Command    cmd=upf_param id=1 end_markers=0
    Start Collect Counter    ${nrcell_distname}    ${direct_counter}    ${direct_counter_rule}
    Start Collect Wireshark For GNB
    Start Ip Traffic Capture
    UE Register And PDU Session Setup    ue_id=3    ue_gw=3
    Send Egate Command and verify output   ue_meas_cfg_disp id=3
    UE PDU Session Modify   ue_id=3  pdu=1  qos_flow_list=@{pdu_qos_list}  by=amf
    Start 100Mbps Traffic On PDU Session-1 QFI-1 dl for UE3
    Start 100Mbps Traffic On PDU Session-1 QFI-2 dl for UE3
    Start 100Mbps Traffic On PDU Session-1 QFI-3 dl for UE3
    Trigger inter-RAT Handover    ue_id=3  phycell_id=11
    Stop Collect Counter and verify PM counters

    [Teardown]    Run Keywords      Stop Wireshark log For GNB
    ...           AND               Run Keyword And Ignore Error    Stop Ip Traffic Capture
    ...           AND               Case Postcondition

CB013289-A#B1_TC50_Robustness_compare_handover_successful_ratio_with_feature_enable_and_disable
    [Tags]    CRT5    CB013289_50    PASS
    [Documentation]
    ...    It is the successful case IRAT HO is triggered with direct data forwarding with Multi-UE
    ...    This user scenario describes gNB’s behavior when a ‘B2 Measurement Report’ is received from the UE,
    ...    It is the successful case IRAT HO is triggered with direct data forwarding through NG interface.
    ...    CB013289 feature is enabled by setting “NRBTS.actInterRatHoDirectDlDataFwd” to “IRATDirectDataFwdOnX2”
    ...    A NRADJECELL is configured with parameter “iRatDataForwardingMethod” set to “directDataFwd”
    ...    The parameter “NRDRB_5QI.dataForwarding” is set to “IRATDataFwd” for NRDRB_5QI MOCs corresponding to 5QI-X.
    ...    (not include 5QI-1 or 5QI-2)
    ...    NOte:this case is not set 5QI1&2 for data forwarding
    [Setup]    Run Keywords    Prepare WTS Config With Active Indirect DataFW For MUE    ${CURDIR}/config/basic_setup_13289_MUE.cfg
    ...           AND          Case Precondition For Multi UE

#    Kill agate and start egate
    Active Feature CB013289 On noIRATDirectDataFwd    #feature disable
    FOR    ${UE_ID}    IN    @{UE_ID_LIST}
        #UE Register And Setup One PDU Session    ue_id=${UE_ID}    ue_gw=${UE_ID}
        UE Register And PDU Session Setup    ue_id=${UE_ID}   ue_gw=${UE_ID}
        UE PDU Session Modify   ue_id=${UE_ID}  pdu=1  qos_flow_list=@{pdu_qos_list}  by=amf
        Start 10Mbps Traffic On PDU Session-1 QFI-1 dl for UE${UE_ID}
        Start 10Mbps Traffic On PDU Session-1 QFI-2 dl for UE${UE_ID}
        Start 10Mbps Traffic On PDU Session-1 QFI-3 dl for UE${UE_ID}
    END
    FOR    ${TIMES}    IN RANGE    1    101
        IRAT HO with Muti UE and HO back to 5G
        sleep    5s
    END
    #collect snapshot
    [Teardown]    Run Keywords    stop tcpdump on vm
#        ...           AND         Get L1l2bipLogs stop
    ...           AND             Case Postcondition


CB013289-A#EC1_Exploratory_T51_indirect_data_forwarding_if_QFI_not_included_in_HandoverCommand_will_be_removed_from_data_forwarding_list
    [Tags]    CRT7    CB013289_51    Pass
    [Documentation]
    ...   This user scenario describes for indirect data forwarding, if QoS flows which are not included in the
    ...    ‘NGAP: HandoverCommand.PDUSessionResourceHandoverList.handoverCommandTransfer.qosFlowToBeForwardedList.qosFlowIdentifier”
    ...    should be removed from data forwarding list.for example:
    ...    In NGAP:HandoverRequired message , ‘dL-Forwarding-proposed’ for PDU session id 1 is QFI1,QFI2,QFI3, PDU session id 2 is QFI4;
    ...    In the NGAP:handoverCommand we receive the  peer GTP tunnel endpoints for the PDU session id 1 is QFI1,QFI2,QFI3;
    ...    so only QFI1,QFI2,QFI3 will do indirect data forwarding, QFI4 will not to do indirect data forwarding
    ...    CB013289 feature is disenabled by setting “NRBTS.actInterRatHoDirectDlDataFwd”
    ...    A NRADJECELL is configured with parameter “iRatDataForwardingMethod” set to “indirectDataFwd”
    ...    The parameter “NRDRB_5QI.dataForwarding” is set to “IRATDataFwd” for NRDRB_5QI MOCs corresponding to 5QI-X.

    [Setup]    Run Keywords    Prepare WTS Config With Active Indirect DataFW    ${CURDIR}/config/basic_setup_13289.cfg
    ...           AND          Case Precondition
    ...           AND          Download wireshark plugin
#    Kill agate and start egate
    Active Feature CB013289 On IRATDirectDataFwdOnNg
    Set NRADJECELL-5000 iRatDataForwardingMethod with indirectDataFwd
    ${command} =  catenate   SEPARATOR=
    ...    amf_ue_ng_handover_command_param id=1 ue=all action=exclude_TEIDs_indirect_data_forwarding list_pdu_sessions_exclude_TEIDs=2
    Airphone Execute Egate Command    cmd=${command}
    Start Collect Wireshark For GNB
    Start Ip Traffic Capture
    UE Register And PDU Session Setup    ue_id=3    ue_gw=3
    Send Egate Command and verify output   ue_meas_cfg_disp id=3
    UE PDU Session Modify   ue_id=3  pdu=1  qos_flow_list=@{pdu_qos_list}  by=amf
    UE3 And PDU Session-2 Gateway-3 Setup
    Start 10Mbps Traffic On PDU Session-1 QFI-1 dl for UE3
    Start 10Mbps Traffic On PDU Session-1 QFI-2 dl for UE3
    Start 10Mbps Traffic On PDU Session-1 QFI-3 dl for UE3
    Start 10Mbps Traffic On PDU Session-2 QFI-1 dl for UE3
    Trigger inter-RAT Handover    ue_id=3  phycell_id=11
    sleep    5s
    ${local_file_path}=    Stop Wireshark log For GNB
    CB013289 EAR TC51 Check Ponit 1    ${local_file_path}
    [Teardown]    Run Keywords      Stop Wireshark log For GNB
    ...           AND               Stop Ip Traffic Capture
    ...           AND               Case Postcondition


CB013289-A#EC1_T52_ignore_data_forwarding_if_GTP-U_Error_Indication_is_received_at_Source_Gnb_CU-UP_On_NG
    [Tags]    CRT8    CB013289_52
    [Documentation]
    ...   This user scenario describes gNB’s behavior when 'GTP-U Error Indication' is received at Source gNB CU-UP from
    ...    Xn-U/NG-U/X2U during data forwarding in IRAT HO.
    ...    CB013289 feature is disenabled by setting “NRBTS.actInterRatHoDirectDlDataFwd” to “IRATDirectDataFwdOnNg”
    ...    A NRADJECELL is configured with parameter “iRatDataForwardingMethod” set to “directDataFwd”
    ...    The parameter “NRDRB_5QI.dataForwarding” is set to “IRATDataFwd” for NRDRB_5QI MOCs corresponding to 5QI-X.

    [Setup]    Run Keywords    Prepare WTS Config With Active direct DataFW    ${CURDIR}/config/basic_setup_13289.cfg
    ...           AND          Case Precondition
    ...           AND          Download wireshark plugin
#    Kill agate and start egate
    Active Feature CB013289 On IRATDirectDataFwdOnNg
    Set NRADJECELL-5000 iRatDataForwardingMethod with directDataFwd
#    start tcpdump on vm
#    Start Collect Counter For T52
    Start Collect Wireshark For GNB
#    Start Ip Traffic Capture
#    UE Register And PDU Session Setup    ue_id=2    ue_gw=2
#    Send Egate Command and verify output   ue_meas_cfg_disp id=2
#    UE PDU Session Modify   ue_id=2  pdu=1  qos_flow_list=@{pdu_qos_list}  by=amf
#    Start 100Mbps Traffic On PDU Session-1 QFI-1 dl for UE2
#    Start 100Mbps Traffic On PDU Session-1 QFI-2 dl for UE2
#    Start 100Mbps Traffic On PDU Session-1 QFI-3 dl for UE2
#    Trigger inter-RAT Handover    ue_id=2  phycell_id=11
#    sleep    6s
#    ${value1}    Stop Collect Counter and verify PM counters For T52
#    Stop Ip Traffic Capture

    Airphone Execute Egate Command    cmd=gnb_param id=5 gtpu_error_direct_data_fwding_erab_list=all
    sleep    2s
#    Start Collect Counter For T52
    Start Ip Traffic Capture
    UE Register And PDU Session Setup    ue_id=3    ue_gw=3
    Send Egate Command and verify output   ue_meas_cfg_disp id=3
    UE PDU Session Modify   ue_id=3  pdu=1  qos_flow_list=@{pdu_qos_list}  by=amf
    Start 100Mbps Traffic On PDU Session-1 QFI-1 dl for UE3
    Start 100Mbps Traffic On PDU Session-1 QFI-2 dl for UE3
    Start 100Mbps Traffic On PDU Session-1 QFI-3 dl for UE3
    Trigger inter-RAT Handover    ue_id=3  phycell_id=11
    sleep    6s
#    ${value2}    Stop Collect Counter and verify PM counters For T52
    #add check point：gNB will ignore data forwarding
    [Teardown]    Run Keywords      Stop Wireshark log For GNB
    ...           AND               Stop Ip Traffic Capture
#    ...           AND               stop tcpdump on vm
    ...           AND               Case Postcondition

CB013289_Exploratory_T62_indirect_data_forwarding_E1AP_not_included_QFIs_if_QFI_not_included_in_HandoverCommand
    [Tags]    CRT9    CB013289_62    pass
    [Setup]    Run Keywords    Prepare WTS Config With Active Indirect DataFW    ${CURDIR}/config/basic_setup_13289.cfg
    ...           AND          Case Precondition
    ...           AND          Delta Plan Commission    ${CURDIR}/config/5QI8_RLC_UM.json
#    Kill agate and start egate
    Active Feature CB013289 On noIRATDirectDataFwd
    Set NRADJECELL-5000 iRatDataForwardingMethod with indirectDataFwd
    Airphone Execute Egate Command    cmd=gnb_param id=5 ng_data_forwarding_HO=rlcum rlc_config=8:um:size_12
    Start Collect Wireshark For GNB
    Start Ip Traffic Capture
    UE Register And PDU Session Setup    ue_id=1    ue_gw=1
    Send Egate Command and verify output   ue_meas_cfg_disp id=1
    UE PDU Session Modify   ue_id=1  pdu=1  qos_flow_list=@{pdu_qos_list}  by=amf
    UE PDU Session Setup   ue_id=1  pdu=2  gw=2  pass_regexp=Pdu Session.*successfully
    UE PDU Session Modify   ue_id=1  pdu=2  qos_flow_list=@{pdu1_qos_list}  by=amf
    Start 20Mbps Traffic On PDU Session-1 QFI-1 dl for UE1
    Start 20Mbps Traffic On PDU Session-1 QFI-2 dl for UE1
    Start 20Mbps Traffic On PDU Session-1 QFI-3 dl for UE1
    Start 20Mbps Traffic On PDU Session-2 QFI-1 dl for UE1
    Start 20Mbps Traffic On PDU Session-2 QFI-2 dl for UE1
    Start 20Mbps Traffic On PDU Session-2 QFI-3 dl for UE1
    Trigger inter-RAT Handover    ue_id=1  phycell_id=11
    sleep    5s
    ${local_file_path}=    Stop Wireshark log For GNB

    [Teardown]    Run Keywords      Stop Wireshark log For GNB
    ...           AND               Stop Ip Traffic Capture
    ...           AND               Case Postcondition
*** Keywords ***

Kill agate and start egate
    OperatingSystem.Run    sudo pkill edaemon
    OperatingSystem.Run    sudo pkill egate
    Airphone Edaemon Egate Setup
    Airphone Cfg Configuration    wts_cfg_name=${CURDIR}/config/basic_setup_13289.cfg
    Sleep    5s

Case Precondition For Multi UE
    log to console    Case Precondition
    Common Test Setup For RRM
    Airphone Common Setup    local_wts_dir=${CURDIR}/config/basic_setup_13289_MUE.cfg
    ...                      iphy_path=${CURDIR}/config/iphy.xml
    ...                      scf_file_path=${CURDIR}/config/scf_13289.xml
    Airphone Execute Egate Command    cmd=set_log flush
    Airphone Execute Egate Command    cmd=state_sim_disp
    Start Btslog Collect    names=btslog1

UE Register And Setup One PDU Session
    [Arguments]    ${ue_id}=1    ${pass_regexp}=QoS Routing Table    ${ue_gw}=1
    Airphone Execute Egate Command    cmd=ue_register id=${ue_id}
    sleep    5s
    Airphone Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    sleep    5s
    Airphone Execute Egate Command    cmd=ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=${ue_gw}    pass_regexp=${pass_regexp}
    sleep    5s




