*** Settings ***

Documentation    :copyright: Nokia

Resource     ../../../../resources/airphone/5G_SW_WRO_Keywords.robot
Library    ta5g_testline_management
Library    ta5g_ue_measurements
Library    ta5g_iphy
Library    ta5g_enb
Library    ta5g_pm_counters
Library    ta5g_delta

*** Variables ***
${NRREL_OBJECT_CREATION_TIME} =    120
${NRREL_ID} =    256
${CELL_1} =    50
${CELL_2} =    51
${CELL_3} =    150
${NRRRC_MCC} =    nr-rrc.MCC_MNC_Digit == 3 && nr-rrc.MCC_MNC_Digit == 1 && nr-rrc.MCC_MNC_Digit == 1
${NRRRC_MNC} =    nr-rrc.MCC_MNC_Digit == 4 && nr-rrc.MCC_MNC_Digit == 8 && nr-rrc.MCC_MNC_Digit == 9
${NRCGI_REPORT_SUPPORTED_IN_ENDC_MODE} =    nr-rrc.nr_CGI_Reporting_ENDC == 0
${SA_RECONFIGURATION_REPORT_CGI} =    ${RRC_RECONFIGURATION} && nr-rrc.reportType == reportCGI && nr-rrc.cellForWhichToReportCGI ==

${ENDC_CONFIGURATION_TRANSFER}=    (x2ap.ENDCConfigurationTransfer_element) && (s1ap.transfertype == 0)
${ENDC_CONFIGURATION_TRANSFER_RECEIVED}=    s1ap.transfertype == 1
${LOCAL_IP_ADDRESS}=    localIpAddr
${LOCAL_IP_ADDRESS_MOC}=    IPADDRESSV4_A
${FIVE_GS_TAC}=    fiveGsTac
${FIVE_GS_TAC_MOC}=    TRACKINGAREA_A

*** Keywords ***

Start Vm Ethernet Interfaces
    Start Vm Ethernet Interface    if_name=eth3:gNB2_XN    ip_with_mask=10.0.1.101/24
    Start Vm Ethernet Interface    if_name=eth3:gNB2_NG    ip_with_mask=10.0.1.102/24
    Start Vm Ethernet Interface    if_name=eth3:S1U_1296    ip_with_mask=10.0.1.21/24
    Start Vm Ethernet Interface    if_name=eth3:S11_1296    ip_with_mask=10.0.1.22/24
    Start Vm Ethernet Interface    if_name=eth3:gNB2_X2    ip_with_mask=10.0.1.3/24

Stop Vm Ethernet Interfaces
    Stop Vm Ethernet Interface    if_name=eth3:gNB2_XN    ip_with_mask=10.0.1.101/24
    Stop Vm Ethernet Interface    if_name=eth3:gNB2_NG    ip_with_mask=10.0.1.102/24
    Stop Vm Ethernet Interface    if_name=eth3:S1U_1296    ip_with_mask=10.0.1.21/24
    Stop Vm Ethernet Interface    if_name=eth3:S11_1296    ip_with_mask=10.0.1.22/24
    Stop Vm Ethernet Interface    if_name=eth3:gNB2_X2    ip_with_mask=10.0.1.3/24

Attach UE To Enb And Gnb
    [Arguments]    ${ue_id}    ${target_cell}=1
    Attach Ue To Enb    ue_id=${ue_id}    optional_parameters=profile=1
    Start Gnb Addition Procedure    ue=${ue_id}    target_gnb=2    target_cells=${target_cell}    bearer=2    dc_type=split_scg
    ...                             pass_regexp=Proxy \\(eNB 2 cell ${target_cell}\\) reported successful RA
    Sleep    10    reason=Waiting For SN Status Transfer

Verify Traces For Xn Handover
    Verify Tcpdump Log    packet_filter=${XNAP_HANDOVER_REQUEST}
    Verify Tcpdump Log    packet_filter=${XNAP_HANDOVER_REQUEST_ACK}
    Verify Tcpdump Log    packet_filter=${XNAP_SN_STATUS_TRANSFER}
    Verify Tcpdump Log    packet_filter=${XNAP_UE_CONTEXT_RELEASE}
    Verify Tcpdump Log    packet_filter=${F1AP_UE_CONTEXT_RELEASE_COMPLETE}

Verify UE Supports NRCGI Report
    Verify Ngap Messages       packet_filter=${X2AP_SGNB_ADDITION_REQUEST} && ${NRCGI_REPORT_SUPPORTED_IN_ENDC_MODE}

Set AMF To Ignore Requests
    Execute Egate Command    cmd=amf_ng_setup_param id=1 gnb=2 request_ignore=on

Drop NG Link
    Execute Egate Command    cmd=link_drop link=ng by=amf:1 to=gnb:2 msg_type=abort

Drop X2 Link
    Execute Egate Command    cmd=link_drop link=x2 by=enb:1 to=gnb:2 msg_type=abort

Restore X2 Link
    Execute Egate Command    cmd=enb_x2_link_up enb=1 target=2
