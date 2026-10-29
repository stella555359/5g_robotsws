*** Variables ***

${Handover_Request}         ngap.procedureCode == 13 && ngap.NGAP_PDU == 0
${Handover_Failure}         ngap.procedureCode == 13 && ngap.NGAP_PDU == 2
${HO_Target_Not_Allowed}    ngap.radioNetwork == 8

*** Keywords ***
Start Vm Ethernet Interfaces
    Start Vm Ethernet Interface    if_name=eth3:GNB3_NG_ADDR    ip_with_mask=10.0.1.3/24
    Start Vm Ethernet Interface    if_name=eth3:GNB3_XN_ADDR    ip_with_mask=10.0.1.4/24
    Start Vm Ethernet Interface    if_name=eth3:AMF_NG    ip_with_mask=10.0.1.1/24

Stop Vm Ethernet Interfaces
    Stop Vm Ethernet Interface    if_name=eth3:GNB3_NG_ADDR    ip_with_mask=10.0.1.3/24
    Stop Vm Ethernet Interface    if_name=eth3:GNB3_XN_ADDR    ip_with_mask=10.0.1.4/24
    Stop Vm Ethernet Interface    if_name=eth3:AMF_NG    ip_with_mask=10.0.1.1/24

Set Internal Traffic Type To UE
    Execute Egate Command    cmd=gnb_param id=3 sib1_period=40
    Execute Egate Command    cmd=gnb_param id=3 sib2_period=40
    Execute Egate Command    cmd=gnb_param id=3 sib5_period=40
    Execute Egate Command    cmd=set_pdu_param ue=1 pdu=1 trf_type=internal

Change Simulation UE Location
    Execute Egate Command   cmd=ue_change_location id=1 enb=3 cell=1
    Sleep    2s

Register UE To Simulation gNB
    Attach Ue    ue_id=1
    Execute Egate Command    cmd=ue_pdu_session_setup ue=1 pdu=1 nwslice=1 gw=1
    Sleep    2s

Start Data Traffic
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=10
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=ul mbps=5

Perform NGAP Handover
    Execute Egate Command    cmd=ue_measurement_send_nr id=1 meas_id=1 event=A3 srsrp_nr=19 phycell_id=50 nrsrp_nr=100
    Sleep    5s

Verify Handover Target Not Allowed Message
    Verify Ngap Messages    packet_filter=${NGAP_NG_SETUP_REQUEST}    timeout=120
    Verify Ngap Messages    packet_filter=${NGAP_NG_SETUP_RESPONSE}    timeout=120
    Verify Tshark For Single Message    alias=${DEFAULT_NG_XN_TSHARK_ALIAS}
    ...    packet_filter=${Handover_Request}
    Verify Tshark For Single Message    alias=${DEFAULT_NG_XN_TSHARK_ALIAS}
    ...    packet_filter=${Handover_Failure}
    Verify Tshark For Single Message    alias=${DEFAULT_NG_XN_TSHARK_ALIAS}
    ...    packet_filter=${HO_Target_Not_Allowed}

Verify Ngap Messages
    [Arguments]    ${packet_filter}    ${number_of_messages}=1    ${pcap_file_path}=${None}    ${timeout}=16    ${relation_symbol}= ==
    ...    ${alias}=${DEFAULT_NG_XN_TSHARK_ALIAS}    ${continue_on_failure}=${True}
    Verify Tshark
    ...    alias=${alias}
    ...    packet_filter=${packet_filter}
    ...    pass_criteria=${relation_symbol}${number_of_messages}
    ...    pcap_file_path=${pcap_file_path}
    ...    timeout=${timeout}
    ...    continue_on_failure=${continue_on_failure}

Verify Tcpdump Log
    [Arguments]    ${packet_filter}    ${number_of_messages}=1    ${pcap_file_path}=default    ${timeout}=16    ${relation_symbol}= ==
    ...            ${alias}=${DEFAULT_TCPDUMP_ALIAS}    ${continue_on_failure}=${True}
    Verify Tshark
    ...    alias=${alias}
    ...    packet_filter=${packet_filter}
    ...    pass_criteria=${relation_symbol}${number_of_messages}
    ...    pcap_file_path=${pcap_file_path}
    ...    timeout=${timeout}
    ...    continue_on_failure=${continue_on_failure}

Verify E1AP BEARER CONTEXT MODIFICATION REQUEST Message Includes PDCP DL COUNT And F1 DL GTP Tunnel Endpoint Information
    ${dl_gtp_teid}=    Get Attribute Value From Tshark Message
    ...    alias=${DEFAULT_TCPDUMP_ALIAS}
    ...    filter=${F1AP: UE CONTEXT SETUP RESPONSE}
    ...    output_pdml_filepath=${OUTPUT_DIR}/dl_gtp_teid    pcap_file_path=${OUTPUT_DIR}/tshark/${DEFAULT_TCP_PCAP}
    ...    xpath=.//field[@name="f1ap.gTP_TEID"]   attribute=show
    ${pdcp_dl_count}=    Get Attribute Value From Tshark Message
    ...    alias=${DEFAULT_TCPDUMP_ALIAS}
    ...    filter=${NGAP: DOWNLINK RAN STATUS TRANSFER}
    ...    output_pdml_filepath=${OUTPUT_DIR}/pdcp_dl_count    pcap_file_path=${OUTPUT_DIR}/tshark/${DEFAULT_TCP_PCAP}
    ...    xpath=.//field[@name="ngap.dL_COUNTValue_element"]/field[@name="ngap.pDCP_SN18"]   attribute=show
    Verify Tcpdump Log      ${E1AP: BEARER CONTEXT MODIFICATION REQUEST} && e1ap.pDCP_SN == ${pdcp_dl_count} && e1ap.gTP_TEID == ${dl_gtp_teid}

Verify NGAP: HANDOVER REQUEST Message Includes Handover Type Set To Intra5GS And dl-fwd-proposed IE Present
    Verify Ngap Messages    ${NGAP: HANDOVER REQUEST}

Verify NGAP: HANDOVER REQUEST ACKNOWLEDGE Message Includes Mandatory Elements For PDU Session Admitted And Structures For DL Data Forwarding
    Verify Ngap Messages    ${NGAP: HANDOVER REQUEST ACKNOWLEDGE}

Verify That Target gNB Sent NGAP HANDOVER NOTIFY To AMF To Confirm That Handover Was Successful
    Verify Ngap Messages    ${NGAP: HANDOVER NOTIFY}

Verify That Appropriate Counters Incremented Correctly
    [Arguments]      ${counters_list}     ${pm_counter_path}
    Verify If Latest Pm Counters From The List Are Bigger Than The Given Value
    ...    counter_list=${counters_list}
    ...    value=0
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    filepath=${pm_counter_path}
