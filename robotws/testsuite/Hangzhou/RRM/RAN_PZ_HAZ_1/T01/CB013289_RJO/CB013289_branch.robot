*** Settings ***
Documentation
...   Author: ZHIFU.XU@nokia-sbell.com
...   Contact: ZHIFU.XU@nokia-sbell.com
...   Description: The user scenario related to AirPhone operation.
...    CLOUD_5G_O_E_AP_LOOO


Suite Setup       Run keywords   Common Suite Setup For RRM   AND   Update bsr package
Suite Teardown    Common Suite Teardown For RRM

Test Timeout    600 minutes

Resource          ../../Resources/Classical/RRM_Common_Resource.robot
Resource          CB013289_KW_and_Check_Point.robot
Library     ta5g_tshark
Library      ute_tshark
Library      taf.config.wts      WITH NAME    wts_conf



*** Test Cases ***
CB013289-A#B1_TC06_Successful_IRAT_handover_with_direct_data_forwarding_with_Multiple_PDU_sessions
    [Tags]    QC_251128        QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    This user scenario describes gNB’s behavior when a ‘B2 Measurement Report’ is received from the UE,
    ...    “NRBTS.actInterRatHoDirectDlDataFwd” to “IRATDirectDataFwdOnXn” or “IRATDirectDataFwdOnNg”
    ...    or “IRATDirectDataFwdOnX2”
    ...    A NRADJECELL is configured with parameter “iRatDataForwardingMethod” set to “directDataFwd”
    ...    The parameter “NRDRB_5QI.dataForwarding” is set to “IRATDataFwd” for NRDRB_5QI MOCs corresponding to 5QI-X.
    ...    (include 5QI-1 or 5QI-2)
    ...    setup 3 PDU session:PDU1 include QFI-5,QFI-1,QFI-2;PDU2 include QFI-5,QFI-6;PDU3 include
    ...    QFI-5,QFI-7,QFI-8,QFI-9;

    [Setup]    Run Keywords    Prepare WTS Config With Active direct DataFW    ${CURDIR}/APCFG/wts_RJO_CB013289.cfg
    ...           AND          Case Precondition
    ...           AND          New Download wireshark plugin
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
    [Tags]    QC_251129        QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    set the 'data forwarding method' to 'indirect data fwd' in the NRADJECELL MOC.
    ...    The parameter ‘NRDRB_5QI.dataForwarding’ is set to ‘IRATDataFwd' for NRDRB_5QI MOCs corresponding to
    ...    5QI-A, 5QI-B and 5QI-C
    ...    The ‘Inter-RAT handover from NR to LTE’ is executed with indirect data forwarding.
    [Setup]    Run Keywords    Prepare WTS Config With Active Indirect DataFW    ${CURDIR}/APCFG/wts_RJO_CB013289.cfg
    ...           AND          Case Precondition
    ...           AND          New Download wireshark plugin
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







