*** Settings ***
Documentation
...   Author: ZHIFU.XU@nokia-sbell.com
...   Contact: ZHIFU.XU@nokia-sbell.com
...   Description: The user scenario related to AirPhone operation.


Suite Setup       Common Suite Setup For RRM
Suite Teardown    Common Suite Teardown For RRM

Test Timeout    600 minutes

Resource          ../../Resources/Classical/RRM_Common_Resource.robot
Resource          CB013289_KW_and_Check_Point.robot
Library     ta5g_tshark
Library      ute_tshark
Library      taf.config.wts      WITH NAME    wts_conf



*** Test Cases ***
CB013289-A#B1_TC02_Successful_IRAT_handover_with_direct_data_forwarding_without_5QI1_and_2_by_NG_interface
    [Tags]    CRT2    CB013289_02    pass
    [Documentation]
    ...    This user scenario describes gNB’s behavior when a ‘B2 Measurement Report’ is received from the UE,
    ...    It is the successful case IRAT HO is triggered with direct data forwarding through NG interface.
    ...    CB013289 feature is enabled by setting “NRBTS.actInterRatHoDirectDlDataFwd” to “IRATDirectDataFwdOnNg”
    ...    A NRADJECELL is configured with parameter “iRatDataForwardingMethod” set to “directDataFwd”
    ...    The parameter “NRDRB_5QI.dataForwarding” is set to “IRATDataFwd” for NRDRB_5QI MOCs corresponding to 5QI-X.
    ...    (not include 5QI-1 or 5QI-2)
    ...    NOte:this case is not set 5QI1&2 for data forwarding
    [Setup]    Run Keywords    Prepare WTS Config With Active direct DataFW    ${CURDIR}/config/basic_setup_13289.cfg
    ...           AND          Case Precondition
    ...           AND          Download wireshark plugin
    Active Feature CB013289 On IRATDirectDataFwdOnNg
    Set NRADJECELL-5000 iRatDataForwardingMethod with directDataFwd
    Start Collect Wireshark For GNB
    Start Collect Counter    ${nrcell_distname}    ${direct_counter}    ${direct_counter_rule}
    Airphone Execute Egate Command    cmd=ue_gnb_param id=4 src_direct_data_forwarding=on
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
    sleep    5s
    Stop Collect Counter and verify PM counters
    ${local_file_path}=    Stop Wireshark log For GNB
    CB013289 Check Direct Path Item    ${local_file_path}
    CB013289 AB1 TC02 Check Ponit 1    ${local_file_path}
    CB013289 Check Data Forwarding By NG interface    ${local_file_path}
    [Teardown]    Run Keywords      Stop Wireshark log For GNB
    ...           AND               Stop Ip Traffic Capture
    ...           AND               Case Postcondition
    ...           AND             Get SCF Internal Id By Scout    no_ute=False

CB013289-A#B1_TC06_Successful_IRAT_handover_with_direct_data_forwarding_with_Multiple_PDU_sessions
    [Tags]    QC_67193        QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    This user scenario describes gNB’s behavior when a ‘B2 Measurement Report’ is received from the UE,
    ...    “NRBTS.actInterRatHoDirectDlDataFwd” to “IRATDirectDataFwdOnXn” or “IRATDirectDataFwdOnNg”
    ...    or “IRATDirectDataFwdOnX2”
    ...    A NRADJECELL is configured with parameter “iRatDataForwardingMethod” set to “directDataFwd”
    ...    The parameter “NRDRB_5QI.dataForwarding” is set to “IRATDataFwd” for NRDRB_5QI MOCs corresponding to 5QI-X.
    ...    (include 5QI-1 or 5QI-2)
    ...    setup 3 PDU session:PDU1 include QFI-5,QFI-1,QFI-2;PDU2 include QFI-5,QFI-6;PDU3 include
    ...    QFI-5,QFI-7,QFI-8,QFI-9;

    [Setup]    Run Keywords    Prepare WTS Config With Active direct DataFW    ${CURDIR}/config/basic_setup_13289.cfg
    ...           AND          Case Precondition
    Set NRADJECELL-5000 iRatDataForwardingMethod with directDataFwd
    Start Collect Wireshark For GNB
    Start Collect Counter    ${nrcell_distname}    ${direct_counter}    ${direct_counter_rule}
    Start Ip Traffic Capture
    UE Register And PDU Session Setup    ue_id=2    ue_gw=2
    Send Egate Command and verify output   ue_meas_cfg_disp id=2
    UE PDU Session Modify   ue_id=2  pdu=1  qos_flow_list=@{pdu1_qos_list}  by=amf
    UE PDU Session Setup   ue_id=2  pdu=2  gw=2  pass_regexp=Pdu Session.*successfully
    UE PDU Session Modify   ue_id=2  pdu=2  qos_flow_list=@{pdu2_qos_list}  by=amf
    UE2 And PDU Session-3 Gateway-2 Setup
    UE PDU Session Modify   ue_id=2  pdu=3  qos_flow_list=@{pdu_qos_list2}  by=amf
    Start data traffic on 2 PDU sessions    ue_id=2
    Start 10Mbps Traffic On PDU Session-3 QFI-1 dl for UE2
    Start 10Mbps Traffic On PDU Session-3 QFI-2 dl for UE2
    Start 10Mbps Traffic On PDU Session-3 QFI-3 dl for UE2
    Start 10Mbps Traffic On PDU Session-3 QFI-4 dl for UE2
    Trigger inter-RAT Handover    ue_id=2  phycell_id=11
    sleep    5s
    ${local_file_path}=    Stop Wireshark log For GNB
    CB013289 AB1 TC06 Check Ponit 1    ${local_file_path}
    Stop Collect Counter and verify PM counters

    [Teardown]    Run Keywords      Stop Wireshark log For GNB
    ...           AND               Stop Ip Traffic Capture
    ...           AND               Case Postcondition
    ...           AND             Get SCF Internal Id By Scout    no_ute=False

CB013289-A#B2_TC10_Successful_IRAT_ handover_with_indirect_data_forwarding
    [Tags]    QC_67174        QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    set the 'data forwarding method' to 'indirect data fwd' in the NRADJECELL MOC.
    ...    The parameter ‘NRDRB_5QI.dataForwarding’ is set to ‘IRATDataFwd' for NRDRB_5QI MOCs corresponding to
    ...    5QI-A, 5QI-B and 5QI-C
    ...    The ‘Inter-RAT handover from NR to LTE’ is executed with indirect data forwarding.
    [Setup]    Run Keywords    Prepare WTS Config With Active Indirect DataFW    ${CURDIR}/config/basic_setup_13289.cfg
    ...           AND          Case Precondition
    Active Feature CB013289 On IRATDirectDataFwdOnX2
    Set NRADJECELL-5000 iRatDataForwardingMethod with indirectDataFwd
    Start Collect Wireshark For GNB
    Start Ip Traffic Capture
    UE Register And PDU Session Setup    ue_id=1    ue_gw=1
    Send Egate Command and verify output   ue_meas_cfg_disp id=1
    UE PDU Session Modify   ue_id=1  pdu=1  qos_flow_list=@{pdu_qos_list}  by=amf
    UE PDU Session Setup   ue_id=1  pdu=2  gw=2  pass_regexp=Pdu Session.*successfully
    UE PDU Session Modify   ue_id=1  pdu=2  qos_flow_list=@{pdu2_qos_list}  by=amf
    Start data traffic on 2 PDU sessions    ue_id=1
    Trigger inter-RAT Handover    ue_id=1  phycell_id=11
    sleep    5s
    ${local_file_path}=    Stop Wireshark log For GNB
    CB013289 AB2 TC10 Check Ponit 1    ${local_file_path}

    [Teardown]    Run Keywords      Stop Wireshark log For GNB
    ...           AND               Stop Ip Traffic Capture
    ...           AND               Case Postcondition
    ...           AND             Get SCF Internal Id By Scout    no_ute=False

CB013289-A_US#B1_AL01_PCMD_Monitoring_QoS_Partial_acceptance_during_IRAT_HO_to_LTE_at_gNB-CU-CP_direct_forwarding
    [Tags]    QC_67158        QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...     this case is based on CB013289-A#B1 ALT2 with PCMD check;
    ...    This user scenario describes Partial Acceptance of data forwarding by peer eNodeB
    ...    “NRBTS.actInterRatHoDirectDlDataFwd” to “IRATDirectDataFwdOnXn” or “IRATDirectDataFwdOnNg”
    ...    or “IRATDirectDataFwdOnX2”
    ...    A NRADJECELL is configured with parameter “iRatDataForwardingMethod” set to “directDataFwd”
    ...    The parameter “NRDRB_5QI.dataForwarding” is set to “IRATDataFwd” for NRDRB_5QI MOCs corresponding to
    ...    5QI-X.(include 5QI-1 or 5QI-2)
    ...    setup 3 PDU session:PDU1 include 5QI-5,5QI-1,5QI-2;PDU2 include 5QI-5,5QI-7,5QI-8;PDU3 include
    ...    5QI-5,5QI-7,5QI-8,QFI-9;
    ...    set 5QI-1,5QI-2,5QI-8 with RLC UM; egate set by: gnb_param id=5 ng_data_forwarding_HO=rlcam,
    ...    so 5QI-1,2,8 will not be accept for data FWD

    [Setup]    Run Keywords    Prepare WTS Config With Active direct DataFW    ${CURDIR}/config/basic_setup_13289.cfg
    ...        AND             Case Precondition
    ...        AND             Start DCAP On VM
    ...        AND             Delta Plan Commission    ${CURDIR}/config/MBA_CB013289.json
    ...        AND             Download wireshark PCMD plugin

    Active Feature CB013289 On IRATDirectDataFwdOnX2
    Set NRADJECELL-5000 iRatDataForwardingMethod with directDataFwd
    Airphone Execute Egate Command    cmd=ue_gnb_param id=2 src_direct_data_forwarding=on
    Airphone Execute Egate Command    cmd=gnb_param id=5 include_e-rab_ids=2,4
    Start Collect Wireshark For GNB
    UE Register And PDU Session Setup    ue_id=2    ue_gw=2
    Send Egate Command and verify output   ue_meas_cfg_disp id=2
    UE PDU Session Modify   ue_id=2  pdu=1  qos_flow_list=@{pdu1_qos_list}  by=amf
    UE PDU Session Setup   ue_id=2  pdu=2  gw=2  pass_regexp=Pdu Session.*successfully
    UE PDU Session Modify   ue_id=2  pdu=2  qos_flow_list=@{pdu2_qos_list}  by=amf
    UE2 And PDU Session-3 Gateway-2 Setup
    UE PDU Session Modify   ue_id=2  pdu=3  qos_flow_list=@{pdu_qos_list2}  by=amf
    Start data traffic on 2 PDU sessions    ue_id=2
    Start 10Mbps Traffic On PDU Session-3 QFI-1 dl for UE2
    Start 10Mbps Traffic On PDU Session-3 QFI-2 dl for UE2
    Start 10Mbps Traffic On PDU Session-3 QFI-3 dl for UE2
    Start 10Mbps Traffic On PDU Session-3 QFI-4 dl for UE2
    Trigger inter-RAT Handover    ue_id=2  phycell_id=11
    sleep    5s
    ${local_file_path}=    Stop Wireshark log For GNB
    CB013289 PCMD CUCP MBA Check Ponit    ${local_file_path}
    [Teardown]    Run Keywords      Stop Wireshark log For GNB
    ...           AND               Case Postcondition
    ...           AND             Get SCF Internal Id By Scout    no_ute=False

CB013289-A#EC1_T15_without_data_forwarding_with_CB013289_enabled_CB005876_enabled_but_eNB_disabled
    [Tags]    QC_67206        QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    This user scenario describes The ‘Inter-RAT handover from NR to LTE’ is executed without data forwarding
    ...    CB013289 feature is enabled by setting “NRBTS.actInterRatHoDirectDlDataFwd” to “IRATDirectDataFwdOnNg”
    ...    A NRADJECELL is configured with parameter “iRatDataForwardingMethod” set to “directDataFwd”
    ...    The parameter ‘NRDRB_5QI.dataForwarding’ is set to ‘IRATDataFwd for NRDRB_5QI MOCs corresponding to 5QI-A,
    ...    5QI-B and 5QI-C
    ...    CB005876  enabled (The setting of parameter ‘NRBTS.actInterRatHoSADlDataForward’ is set to true)
    ...     eNB side set no data forwarding: gnb_param id=5 ng_data_forwarding_HO=off
    [Setup]    Run Keywords    Prepare WTS Config With Active direct DataFW    ${CURDIR}/config/basic_setup_13289.cfg
    ...           AND          Case Precondition
    ...           AND          Download wireshark plugin
    Active Feature CB013289 On IRATDirectDataFwdOnNg
    Set NRADJECELL-5000 iRatDataForwardingMethod with directDataFwd
    Start Collect Counter    ${nrcell_distname}    ${gtp_packet_counter}    ${gtp_packet_counter_rule}
    Start Collect Wireshark For GNB
    Start Ip Traffic Capture
    Airphone Execute Egate Command    cmd=gnb_param id=5 include_e-rab_ids=none
    UE Register And PDU Session Setup    ue_id=1    ue_gw=1
    Send Egate Command and verify output   ue_meas_cfg_disp id=1
    UE PDU Session Modify   ue_id=1  pdu=1  qos_flow_list=@{pdu_qos_list}  by=amf
    Start 10Mbps Traffic On PDU Session-1 QFI-1 dl for UE1
    Start 10Mbps Traffic On PDU Session-1 QFI-2 dl for UE1
    Start 10Mbps Traffic On PDU Session-1 QFI-3 dl for UE1
    Trigger inter-RAT Handover    ue_id=1  phycell_id=11
    sleep    5s
    Stop Collect Counter and verify PM counters
    ${local_file_path}=    Stop Wireshark log For GNB
    CB013289 Check Direct Path Item    ${local_file_path}
    CB013289 EC1 TC15 Check Ponit 1    ${local_file_path}
    [Teardown]    Run Keywords      Stop Wireshark log For GNB
    ...           AND               Stop Ip Traffic Capture
    ...           AND               Case Postcondition
    ...           AND             Get SCF Internal Id By Scout    no_ute=False

CB013289-A#B3_T22_Inter-RAT_handover_with_direct_data_forwarding_when_LTE_neighbour_cell_is_discovered_using_ANR
    [Tags]    QC_67217        QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...   Description: This user scenario describes gNB’s behaviour when a ‘B2 Measurement Report’ is received from the
    ...   UE,but there is no Inter-RAT neighbour (NRADJECELL MOC) configured corresponding to the PCI in the received
    ...   ‘B2 Measurement Report’. gNB uses the ANR procedures to discover the Inter-RAT neighbour. The data forwarding
    ...    method (direct data forwarding, indirect data forwarding or no data forwarding) for the discovered Inter-RAT
    ...    neighbour (NRADJECELL) is determined.using the ANR profile. After the neighbour discovery, the Inter-RAT
    ...    handover from NR to LTE is executed with direct data forwarding.
    ...    Precondition:
    ...    1) CB013289 feature is enabled by setting ‘NRBTS.actInterRatHoDirectDlDataFwd to ‘IRATDirectDataFwdOnNg’
    ...    NRDRB_5QI.dataForwarding’ is set to ‘IRATDataFwd for NRDRB_5QI MOCs corresponding to 5QI-1,2,5-9.
    ...    2) The MOC ‘NRANRPRE’ with id 1  is the default ANR profile, The default ANR profile is configured with
    ...    the following values:
    ...    ‘NRANRPRE.iRatDataForwardingMethod’ is set to ‘indirectDataFwd’,‘NRANRPRE.carrierFreq’ is not configured
    ...    3) The MOC ‘NRANRPRE’ with id 2 is configured with the following values:
    ...    ‘NRANRPRE.iRatDataForwardingMethod’ is set to ‘directDataFwd’,‘NRANRPRE.carrierFreq’ SET target LTE CELL

    [Setup]    Run Keywords    Prepare WTS Config With Active direct DataFW    ${CURDIR}/config/basic_setup_13289.cfg
    ...           AND          Case Precondition For ANR
    ...           AND          Download wireshark plugin
    Active Feature CB013289 On IRATDirectDataFwdOnNg
    Set NRANRPRE-2 iRatDataForwardingMethod with directDataFwd
    Start Collect Counter    ${nrcell_distname}    ${T22_counter}    ${T22_counter_rule}
    Start Collect Wireshark For GNB
    Start Ip Traffic Capture
    UE1 Register
    UE1 And PDU Session-1 Gateway-1 Setup
    UE PDU Session Modify   ue_id=1  pdu=1  qos_flow_list=@{pdu_qos_list}  by=amf
    UE1 And PDU Session-2 Gateway-1 Setup
    UE PDU Session Modify   ue_id=1  pdu=2  qos_flow_list=@{pdu_qos_list2}  by=amf
    Start 10Mbps Traffic On PDU Session-1 QFI-1 dl for UE1
    Start 10Mbps Traffic On PDU Session-1 QFI-2 dl for UE1
    Start 10Mbps Traffic On PDU Session-1 QFI-3 dl for UE1
    Start 10Mbps Traffic On PDU Session-2 QFI-1 dl for UE1
    Start 10Mbps Traffic On PDU Session-2 QFI-2 dl for UE1
    Start 10Mbps Traffic On PDU Session-2 QFI-3 dl for UE1
    Start 10Mbps Traffic On PDU Session-2 QFI-4 dl for UE1
    Send Egate Command and verify output   ue_meas_cfg_disp id=1
    Send A2 Measurement    ue_id=1
    sleep    5s
    Configure ECGI For ANR    ue_id=1
    Send B2 Measurement And Attempt Handover    ue_id=1    phycell_id=11
    sleep    5s
    ${local_file_path}=    Stop Wireshark log For GNB
    CB013289 Check Direct Path Item    ${local_file_path}
    CB013289 AB1 TC02 Check Ponit 1    ${local_file_path}
    CB013289 Check Data Forwarding By NG interface    ${local_file_path}
    Stop Collect Counter and verify PM counters
    [Teardown]    Run Keywords      Stop Wireshark log For GNB
    ...           AND               Stop Ip Traffic Capture
    ...           AND               Case Postcondition
    ...           AND             Get SCF Internal Id By Scout    no_ute=False





