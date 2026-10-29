*** Settings ***
Documentation    Keywords for feature CB007517

Library     ta_messaging
Library     ../resources/NSA_messaging_filters.py


*** Keywords ***

Start Vm Ethernet Interfaces
    Start Vm Ethernet Interface    if_name=eth3:MME_S1    ip_with_mask=10.0.1.131/24
    Start Vm Ethernet Interface    if_name=eth3:enb1_X2AP    ip_with_mask=10.0.1.137/24
    Start Vm Ethernet Interface    if_name=eth3:enb1_X2u   ip_with_mask=10.0.1.135/24
    Start Vm Ethernet Interface    if_name=eth3:enb1_S1u   ip_with_mask=10.0.1.136/24
    Start Vm Ethernet Interface    if_name=eth3:S11   ip_with_mask=10.0.1.135/24
    Start Vm Ethernet Interface    if_name=eth3:S1U   ip_with_mask=10.0.1.133/24
    Start Vm Ethernet Interface    if_name=eth3:SERVER_ADDR   ip_with_mask=10.0.1.132/24
    Start Vm Ethernet Interface    if_name=eth3:AMF_NG_ADDR   ip_with_mask=10.0.1.1/24


Stop Vm Ethernet Interfaces
    Stop Vm Ethernet Interface    if_name=eth3:MME_S1    ip_with_mask=10.0.1.131/24
    Stop Vm Ethernet Interface    if_name=eth3:enb1_X2AP    ip_with_mask=10.0.1.137/24
    Stop Vm Ethernet Interface    if_name=eth3:enb1_X2u   ip_with_mask=10.0.1.135/24
    Stop Vm Ethernet Interface    if_name=eth3:enb1_S1u   ip_with_mask=10.0.1.136/24
    Stop Vm Ethernet Interface    if_name=eth3:S11   ip_with_mask=10.0.1.135/24
    Stop Vm Ethernet Interface    if_name=eth3:S1U   ip_with_mask=10.0.1.133/24
    Stop Vm Ethernet Interface    if_name=eth3:SERVER_ADDR   ip_with_mask=10.0.1.132/24
    Stop Vm Ethernet Interface    if_name=eth3:AMF_NG_ADDR   ip_with_mask=10.0.1.1/24


Verify Measurements Setup Or Removal
    [Arguments]    ${ue_id}    ${gNB_id}    ${timer_length}    ${alias_name}    ${filter}
    Expect Measurement Setup Or Removal Flow    ue_id=${ue_id}    gNB_id=${gNB_id}    timer_length=${timer_length}
    ...    alias_name=${alias_name}
    Check Measurement Setup Or Removal Flow   ue_id=${ue_id}    alias_name=${alias_name}
    Verify That Message Fulfills Query
    ...    ${filter}    message_alias=SgnbModReq    flow_alias=${alias_name}_UE${ue_id}

Expect Measurement Setup Or Removal Flow
   [Arguments]    ${ue_id}    ${gNB_id}    ${timer_length}    ${alias_name}
   ${margin}=    Set Variable    5    # Safety margin for parsing messages etc., equal to tDCoverall
   ${timeout}=    Evaluate    ${timer_length}+${margin}
   Expect Message Flow
   ...    gNB${gNB_id}:X2AP_SgNBModificationRequired (measConfig is present) as SgnbModReq
   ...    gNB${gNB_id}:X2AP_SgNBModificationConfirm (rrcReconfigurationComplete is present) as SgnbModConf
   ...    alias=${alias_name}_UE${ue_id}
   ...    overall_timeout=${timeout}

Check Measurement Setup Or Removal Flow
    [Arguments]    ${ue_id}    ${alias_name}
    Flow Occurred As Expected   alias=${alias_name}_UE${ue_id}

Verify Measurement Configuration During SgNB Addition
    [Arguments]    ${ue_id}    ${filter}
    Verify That Message Fulfills Query
    ...    ${filter}    message_alias=SgnbAddReqAck    flow_alias=EN-DC_X2AP_UE${ue_id}

SgNB Addition
    Execute Egate Command   cmd=enb_ue_dc_start target_gnb=2 target_cells=1 ue=1 bearer=2 type=split_scg
    Sleep    12s

Send A2 Measurement Report
    Execute Egate Command   cmd=ue_measurement_send_nr id=1 meas_id=1 event=A2 srsrp_nr=7 ssinr_nr=59 srsrq_nr=91
    Sleep    20s

Attach UE To Simulated eNB
    Execute Egate Command   cmd=ue_attach id=1 profile=1
    Sleep    3s

Verify SgNBAdditionRequest
    [Arguments]    ${SgNBAdditionRequest}
    Verify Tcpdump Log    ${SgNBAdditionRequest}

Verify SgNBReconfigurationComplete
    [Arguments]    ${SgNBReconfigurationComplete}
    Verify Tcpdump Log    ${SgNBReconfigurationComplete}

Verify A2 Measurement Report
    [Arguments]    ${A2 Measurement Report}
    Verify Tcpdump Log    ${A2 Measurement Report}

Verify SgNBModificationRequired
    [Arguments]    ${SgNBModificationRequired}
    Verify Tcpdump Log    ${SgNBModificationRequired}

Verify SgNBModificationConfirm
    [Arguments]    ${SgNBModificationConfirm}
    Verify Tcpdump Log    ${SgNBModificationConfirm}

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
