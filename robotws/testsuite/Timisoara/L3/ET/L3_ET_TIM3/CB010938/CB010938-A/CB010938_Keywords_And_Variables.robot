*** Settings ***

Documentation    :copyright: Nokia

Resource     ../../resources/5G_SW_WRO_Keywords.robot
Resource     keywords_pcap.robot
Library      ta5g_testline_management
Library      ta5g_iphy
Library      ta5g_enb
Library      ta5g_ue_measurements
Library      ta5g_pm_counters
Library      ta5g_cell_operations
Library      ta5g_delta
Library      ta_pcmd

*** Variables ***
${UE_ID_1}             1
${UE_ID_2}             2
${NSETAPX_PROTOCOL}    nsetapx
${NSETAPX_SBA}    nsetapx.traceActivationType == 1
${NSETAPX_MBA}    nsetapx.traceActivationType == 0
${NSETAPX_IS_ALIVE}    nsetapx.TraceMessage == 0
${NRRRC_SRB_TOADDMODLIST}    nr-rrc.srb_ToAddModList
${ICS_WITH_TRACE_ACTIVATION}    ${NGAP_INITIAL_CONTEXT_SETUP_REQUEST} && ngap.TraceActivation_element
${XN_HANDOVER_REQUEST_WITH_TRACE_ACTIVATION}    ${XNAP_HANDOVER_REQUEST} && xnap.TraceActivation_element
${NSETAPX_START_RECORDING_SESSION}    ${NSETAPX_PROTOCOL} && nsetapx.startRecordingSession_element
${NSETAPX_STOP_RECORDING_SESSION}    ${NSETAPX_PROTOCOL} && nsetapx.stopRecordingSession_element
${NSETAPX_REPORT}    nsetapx.report_element
${UE1_NGAP_ID}    ngap.AMF_UE_NGAP_ID == 1
${UE2_NGAP_ID}    ngap.AMF_UE_NGAP_ID == 2
${UE_1_ICS_RESP}    ${NGAP_INITIAL_CONTEXT_SETUP_RESPONSE} && ${NSETAPX_PROTOCOL} && ${NSETAPX_SBA} && ${UE1_NGAP_ID}
${UE_2_ICS_RESP}    ${NGAP_INITIAL_CONTEXT_SETUP_RESPONSE} && ${NSETAPX_PROTOCOL} && ${NSETAPX_SBA} && ${UE2_NGAP_ID}

*** Keywords ***
Include UE Radio Capabilities in ICSReq
    [Arguments]  ${ue_id}  ${ue_capabilities}

    Execute Egate Command    cmd=amf_ue_ics_param id=1 ue=${ue_id} include_ue_capabilities=on ue_capabilities=${ue_capabilities}

Configure UE To Dont Echo Infra Info
    [Arguments]  ${ue_id}

    Execute Egate Command    cmd=ue_capability_enquiry_param id=${ue_id} if contains=any action=dont_echo

Configure Echoing Infra Info
    [Arguments]  ${ue_id}  ${band_eutra}  ${ca_bandwidth_class_dl_eutra}  ${ca_bandwidth_class_ul_eutra}

    ${command} =  catenate   SEPARATOR=
    ...           ue_nr_capabilities id=${ue_id} band_eutra=${band_eutra} ca_bandwidth_class_dl_eutra=${ca_bandwidth_class_dl_eutra}
    ...           \ ca_bandwidth_class_ul_eutra=${ca_bandwidth_class_ul_eutra}

    Execute Egate Command    cmd=${command}

Configure Chipset Version Support On UE
    [Arguments]  ${ue_id}  ${chipset_version_support}  ${burst_length}  ${max_simultaneous_resource_sets_per_cc}
    ...          ${max_configured_resource_sets_per_cc}  ${max_configured_resource_sets_all_cc}
    ${command} =  catenate   SEPARATOR=
    ...           ue_nr_capabilities id=${ue_id} ue_chipset_version_support=${chipset_version_support} burst_length=${burst_length}
    ...           \ max_simultaneous_resource_sets_per_cc=${max_simultaneous_resource_sets_per_cc}
    ...           \ max_configured_resource_sets_per_cc=${max_configured_resource_sets_per_cc}
    ...           \ max_configured_resource_sets_all_cc=${max_configured_resource_sets_all_cc}

    Execute Egate Command    cmd=${command}

Attach UE And Establish PDU Session
    [Arguments]    ${ue_id}    ${pdu_id}    ${gw_id}
    Attach Ue    ue_id=${ue_id}    pass_regexp=Received REGISTRATION COMPLETE from UE with RAN UE NGAP ID \\d+ and AMF UE NGAP ID \\d+
    Establish PDU Session    ue_id=${ue_id}    pdu_id=${pdu_id}    gw_id=${gw_id}

Attach UE And Establish PDU Session And Release UE Context
    [Arguments]    ${ue_id}    ${pdu_id}    ${gw_id}
    Attach Ue    ue_id=${ue_id}    pass_regexp=Received REGISTRATION COMPLETE from UE with RAN UE NGAP ID \\d+ and AMF UE NGAP ID \\d+
    Establish PDU Session    ue_id=${ue_id}    pdu_id=${pdu_id}    gw_id=${gw_id}
    Release Ue Ctx    ue_id=${ue_id}

Perform Exit Idle Mode
    [Arguments]  ${ue_id}
    Exit Idle Mode   ue_id=${ue_id}  pass_regexp=UE${ue_id}: UE performed IM exit

Attach NSA UE
    [Arguments]  ${ue_id}
    Attach Ue To Enb    			   ue_id=${ue_id}
    Start Gnb Addition Procedure    ue=${ue_id}    target_gnb=2    target_cells=1    bearer=2    dc_type=split_scg
    ...                              pass_regexp=Proxy \\(eNB 2 cell 1\\) reported successful RA
Start Server Interface
    [Documentation]    Starts interface between gNB and Trace Control Entity
    Start Vm Ethernet Interface    if_name=eth3:SERVER    ip_with_mask=10.0.1.1/24

Setup PCMD
    Configure PCMD    technology=5G    asn1per_decoding=${True}
    Start collecting PCMD reports

Teardown PCMD
    Stop collecting PCMD reports
    Deconfigure PCMD

Attach UE With Registration Type
    [Arguments]  ${ue_id}  ${registration_type}

    Execute Egate Command    cmd=ue_register id=${ue_id} registration_type=${registration_type}
    Sleep    3s

Add Nestapx Prototcol Plugin To Tshark
     Load Tshark Bin Plugin    technology=5G

#Start Server Interface
#    [Documentation]    Starts interface between gNB and Trace Control Entity
#    Start Vm Ethernet Interface    if_name=eth3:SERVER    ip_with_mask=10.0.1.1/24

Start Subscriber Trace
    [Arguments]    ${ue_id}=1    ${trace_session_id}=1    ${tce_ip}=10.0.1.1
    ${command} =  catenate  SEPARATOR=
    ...           ue_ng_trace_start id=${ue_id} tce_ip=${tce_ip} trace_depth=minimum
    ...           \ ifaces_to_trace=Uu,NG-C,Xn-C trace_plmn=311:489 trace_rec_session_ref_id=${trace_session_id} trace_ref_id=${trace_session_id}
    Execute Egate Command    cmd=${command}

Set Subscriber Trace Start By Amf
    [Arguments]    ${ue_id}=1
    ${command} =  catenate  SEPARATOR=
    ...           amf_ue_ng_handover_request_param id=${ue_id} trace_activation=on trace_plmn=311:489 trace_ref_id=0
    ...           \ trace_rec_session_ref_id=0 tce_ip=10.0.1.1 trace_depth=medium ifaces_to_trace=Uu,NG-C,Xn-C
    Execute Egate Command    cmd=${command}

Start Xn And Ng Interfaces
    Start Vm Ethernet Interface    if_name=eth3:xn    ip_with_mask=10.0.1.101/24
    Start Vm Ethernet Interface    if_name=eth3:ng    ip_with_mask=10.0.1.102/24

Send A5 Event To Trigger Ho
    [Arguments]    ${ue_id}=1   ${srsrq_nr}=1    ${srsrp_nr}=1    ${ssinr_nr}=1    ${phycell_id}=52
    ...            ${nrsrq_nr}=122    ${nrsrp_nr}=122    ${nsinr_nr}=122    ${timeout}=30
    ...            ${pass_regexp}=message c1 : rrcReconfigurationComplete

    Send Ue Measurement Nr Event A5 With Aligned Meas Id    ue_id=${ue_id}  carrier_freq=636576  pass_regexp=${pass_regexp}
    ...                              srsrq_nr=${srsrq_nr}    srsrp_nr=${srsrp_nr}    ssinr_nr=${ssinr_nr}
    ...                              phycell_id=${phycell_id}    nrsrq_nr=${nrsrq_nr}    nrsrp_nr=${nrsrp_nr}
    ...                              nsinr_nr=${nsinr_nr}    timeout=${timeout}

Add Item To UE History Information List
    [Arguments]  ${gnb_id}
    Execute Egate Command
    ...  cmd=ue_history_information_list_add_ngran id=1 gnb_id=${gnb_id} cell_type=medium nrcgi=311:489|0x01 time_ue_stayed_in_cell=100
    Execute Egate Command
    ...  cmd=ue_history_information_list id=1 action=commit
    Execute Egate Command
    ...  cmd=ue_enb_param id=1 ue_history_list=1

Trigger ICS With Trace Start
    [Arguments]    ${ue_id}=1    ${tce_ip}=0.0.0.0
    ${command} =  catenate   SEPARATOR=
    ...           amf_ue_ics_param id=1 ue=${ue_id} object_id=1 location_reporting_reference_id=1 trace_activation=on trace_plmn=311:489
    ...           \ trace_ref_id=1 trace_rec_session_ref_id=1 trace_depth=medium ifaces_to_trace=Uu,NG-C,Xn-C tce_ip=${tce_ip}
    Execute Egate Command    cmd=${command}

Add Preferences To Wireshark Config
    ${preferences_exist}    Check If Preferences Exist
    ${command}=  catenate  SEPARATOR=
    ...    echo "ntrstr.port: 49151,49392" >> ~/.config/wireshark/preferences  &&
    ...    echo "ntrstr.defragment: TRUE" >> ~/.config/wireshark/preferences
    Run Keyword If    ${preferences_exist}==False
    ...    Run    ${command}
    ...    ELSE    Log    File '~/.config/wireshark/preferences' contains the required flags for 1778

Check If Preferences Exist
    ${preferences_file}    Set Variable    ~/.config/wireshark/preferences
    ${file_exist}=    Run Keyword And Return Status
        ...    File Should Exist    ${preferences_file}
    Run Keyword If   ${file_exist}==False    Create File    ${preferences_file}
    ${file_content}=  OperatingSystem.Get File   ${preferences_file}
    ${preferences_exist}=    Run Keyword And Return Status
    ...    Should Match Regexp    ${file_content}    ntrstr.port: 49151,49392
    [Return]    ${preferences_exist}

Start Tshark For Nsetapx
    ${tshark_alias_tcp}=     Start Tshark For Custom Interface
    ...                          eth_interface='eth3'
    ...                          log_dirpath=${OUTPUT_DIR}${/}${TEST_NAME}${/}${TSHARK_SUBDIR}
    ...                          log_filename_prefix='tcp_nsetapx'
    ...                          capture_filter='tcp'
    [Return]    ${tshark_alias_tcp}

Start Tcp Pcap
    Start tshark
    ...    log_filename=eth3_tcp.pcap
    ...    eth_interface=eth3
    ...    capture_filter='tcp'
    ...    log_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...    alias=tcp_pcap

Stop Tcp Pcap
    [Arguments]    ${alias}=tcp_pcap
    Stop tshark    alias=${alias}

Verify Tcp Messages
    [Arguments]    ${packet_filter}    ${number_of_messages}=1    ${pcap_file_path}=${None}    ${timeout}=16    ${relation_symbol}= ==
    ...            ${alias}=tcp_pcap   ${continue_on_failure}=${True}
    Verify Tshark
    ...    alias=${alias}
    ...    packet_filter=${packet_filter}
    ...    pass_criteria=${relation_symbol}${number_of_messages}
    ...    pcap_file_path=${pcap_file_path}
    ...    timeout=${timeout}
    ...    continue_on_failure=${continue_on_failure}

Stop Subscriber Trace
    [Arguments]    ${ue_id}=1    ${trace_session_id}=1
    ${command} =  catenate  SEPARATOR=
    ...           ue_ng_trace_stop id=${ue_id} trace_plmn=311:489 trace_rec_session_ref_id=${trace_session_id}
    ...           \ trace_ref_id=${trace_session_id}
    Execute Egate Command    cmd=${command}
