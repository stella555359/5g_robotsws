*** Settings ***

Documentation    Keywords for CB008696.

*** Keywords ***
Set Internal Traffic Type To UE
    Execute Egate Command    cmd=set_pdu_param ue=1 pdu=1 trf_type=internal

Register UE To gNB
    Attach Ue    ue_id=1
    Wait For UE Register    3s
    Execute Egate Command    cmd=ue_pdu_session_setup ue=1 pdu=1 nwslice=1 gw=1

Verify RRC Reconfiguration
    [Arguments]    ${RRC Reconfiguration}
    Verify Tcpdump Log    ${RRC Reconfiguration}

Verify Measurement Report Sent By Ue With A4
    [Arguments]    ${Measurement Report Sent By Ue}
    Verify Tcpdump Log    ${Measurement Report Sent By Ue}

Wait For UE Register
    [Arguments]    ${Inactive Timer}
    sleep    ${Inactive Timer}

Wait For The UE To Be Inactive
    [Arguments]    ${Inactive Timer}
    sleep    ${Inactive Timer}

Verify EUTRA Reselection Priority
    [Arguments]    ${RRC Release EUTRA}
    Verify Tcpdump Log    ${RRC Release EUTRA}

Verify NR Reselection Priority
    [Arguments]    ${RRC Release NR}
    Verify Tcpdump Log    ${RRC Release NR}

Verify Reselection Priority
    [Arguments]    ${RRC Release Reselection Priority}
    Verify Tcpdump Log    ${RRC Release Reselection Priority}

Verify AMF UE Context Release Request For Inactive UE
    [Arguments]    ${AMF UE Context Release Request}
    Verify Tcpdump Log    ${AMF UE Context Release Request}

Verify AMF UE Context Release Command For Inactive UE
    [Arguments]    ${AMF UE Context Release Command}
    Verify Tcpdump Log    ${AMF UE Context Release Command}

Verify NGAP UE Context Release Complete Appears
    [Arguments]    ${NGAP: UE Context Release Complete appears}
    Verify Tcpdump Log    ${NGAP: UE Context Release Complete appears}

Verify RRC Release Message Occured
    [Arguments]    ${RRC Release}
    Verify Tcpdump Log    ${RRC Release}

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

Start Data Traffic During A4 Supervision Timer Duration
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=10
    Wait for Data Traffic    60s

Stop Data Traffic
    Execute Egate Command    cmd=trf_data_stop ue=1 pdu=1 qfi=1 dir=dl

Wait for Data Traffic
    [Arguments]    ${Inactive Timer}
    sleep    ${Inactive Timer}

UE Is RRC Connected, Verify E1AP Bearer Context Inactivity Notification With Field Active
    [Arguments]    ${E1AP Bearer Context Inactivity Notification With Field Active}
    Verify Tcpdump Log    ${E1AP Bearer Context Inactivity Notification With Field Active}

Verify E1AP Bearer Context Inactivity Notification With Field Inactive
    [Arguments]    ${E1AP Bearer Context Inactivity Notification With Field Inactive}
    Verify Tcpdump Log    packet_filter=${E1AP Bearer Context Inactivity Notification With Field Inactive}    number_of_messages=2

Wait For The UE To Be Inactive And Send UE Measurement Report
    [Arguments]    ${ue_id}    ${meas_id}
    Wait For The UE To Be Inactive   12s
    Execute Egate Command   cmd=ue_meas_cfg_disp id=${ue_id}
    Execute Egate Command   cmd=ue_measurement_send_nr event=A4 phycell_id=52 nrsrp_nr=80 id=1 meas_id=${meas_id}

A4 Measurement Is Deconfigured, Verify RRC Reconfiguration
    ${measId_with_configured_a4}=    Get Attribute Value From Tshark Message
    ...    alias=${DEFAULT_TCPDUMP_ALIAS}
    ...    filter=${RRC Reconfiguration With A4 Before Data Traffic}
    ...    output_pdml_filepath=${OUTPUT_DIR}/measId    pcap_file_path=${OUTPUT_DIR}/tshark/${DEFAULT_TCP_PCAP}
    ...    xpath=.//field[@name="nr-rrc.measId"]   attribute=show
    ${measObjectId_with_configured_a4}=    Get Attribute Value From Tshark Message
    ...    alias=${DEFAULT_TCPDUMP_ALIAS}
    ...    filter=${RRC Reconfiguration With A4 Before Data Traffic}
    ...    output_pdml_filepath=${OUTPUT_DIR}/measObjectId    pcap_file_path=${OUTPUT_DIR}/tshark/${DEFAULT_TCP_PCAP}
    ...    xpath=.//field[@name="nr-rrc.MeasIdToAddMod_element"]/field[@name="nr-rrc.measObjectId"]   attribute=show
    ${reportConfigId_with_configured_a4}=    Get Attribute Value From Tshark Message
    ...    alias=${DEFAULT_TCPDUMP_ALIAS}
    ...    filter=${RRC Reconfiguration With A4 Before Data Traffic}
    ...    output_pdml_filepath=${OUTPUT_DIR}/reportConfigId    pcap_file_path=${OUTPUT_DIR}/tshark/${DEFAULT_TCP_PCAP}
    ...    xpath=.//field[@name="nr-rrc.MeasIdToAddMod_element"]/field[@name="nr-rrc.reportConfigId"]   attribute=show
    ${MeasId_with_deconfigured_a4}=    Get Attribute Value From Tshark Message
    ...    alias=${DEFAULT_TCPDUMP_ALIAS}
    ...    filter=${RRC Reconfiguration With Deconfigured A4 During Data Traffic}
    ...    output_pdml_filepath=${OUTPUT_DIR}/MeasId    pcap_file_path=${OUTPUT_DIR}/tshark/${DEFAULT_TCP_PCAP}
    ...    xpath=.//field[@name="nr-rrc.MeasId"]   attribute=show
    ${MeasObjectId_with_deconfigured_a4}=    Get Attribute Value From Tshark Message
    ...    alias=${DEFAULT_TCPDUMP_ALIAS}
    ...    filter=${RRC Reconfiguration With Deconfigured A4 During Data Traffic}
    ...    output_pdml_filepath=${OUTPUT_DIR}/MeasObjectId    pcap_file_path=${OUTPUT_DIR}/tshark/${DEFAULT_TCP_PCAP}
    ...    xpath=.//field[@name="nr-rrc.MeasObjectId"]   attribute=show
    ${ReportConfigId_with_deconfigured_a4}=    Get Attribute Value From Tshark Message
    ...    alias=${DEFAULT_TCPDUMP_ALIAS}
    ...    filter=${RRC Reconfiguration With Deconfigured A4 During Data Traffic}
    ...    output_pdml_filepath=${OUTPUT_DIR}/ReportConfigId    pcap_file_path=${OUTPUT_DIR}/tshark/${DEFAULT_TCP_PCAP}
    ...    xpath=.//field[@name="nr-rrc.ReportConfigId"]   attribute=show
    Should Be Equal    ${measId_with_configured_a4}    ${MeasId_with_deconfigured_a4}
    Should Be Equal    ${measObjectId_with_configured_a4}    ${MeasObjectId_with_deconfigured_a4}
    Should Be Equal    ${reportConfigId_with_configured_a4}    ${ReportConfigId_with_deconfigured_a4}
