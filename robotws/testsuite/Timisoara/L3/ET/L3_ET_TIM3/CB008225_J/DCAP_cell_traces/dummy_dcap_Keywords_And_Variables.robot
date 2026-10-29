*** Settings ***

Documentation    :copyright: Nokia

#Resource     /home/ute/MN/UTE/robotws/testsuite/Wroclaw/RRM/5G_SW_WRO/resources/5G_SW_WRO_Keywords.robot
Resource     ../../resources/5G_SW_WRO_Keywords.robot
#Resource     /home/ute/robotws/testsuite/Wroclaw/CIS/CommonKeywords/Common_keywords.robot
Library      ta5g_testline_management

Library      ta5g_iphy
Library      ta5g_enb
Library      ta5g_ue_measurements
Library      ta5g_delta
Library      ta5g_dcap
Library      ta_pcmd.tshark_plugin_configurator
Library      ta_pcmd

*** Variables ***
${UE_ID_1}             1
${UE_ID_2}             2
${NSETAPX_PROTOCOL}    nsetapx
${NSETAPX_SBA}    nsetapx.traceActivationType == 1
${NSETAPX_MBA}    nsetapx.traceActivationType == 0
${NSETAPX_IS_ALIVE}    nsetapx.TraceMessage == 0
${ICS_WITH_TRACE_ACTIVATION}    ${NGAP_INITIAL_CONTEXT_SETUP_REQUEST} && ngap.TraceActivation_element
${XN_HANDOVER_REQUEST_WITH_TRACE_ACTIVATION}    ${XNAP_HANDOVER_REQUEST} && xnap.TraceActivation_element
${NSETAPX_START_RECORDING_SESSION}    ${NSETAPX_PROTOCOL} && nsetapx.startRecordingSession_element
${NSETAPX_STOP_RECORDING_SESSION}    ${NSETAPX_PROTOCOL} && nsetapx.stopRecordingSession_element
${NSETAPX_REPORT}    nsetapx.report_element
${UE8_NGAP_ID}    ngap.AMF_UE_NGAP_ID == 8
${UE9_NGAP_ID}    ngap.AMF_UE_NGAP_ID == 9
${UE_8_ICS_RESP}    ${NGAP_INITIAL_CONTEXT_SETUP_RESPONSE} && ${NSETAPX_PROTOCOL} && ${NSETAPX_SBA} && ${UE8_NGAP_ID}
${UE_9_ICS_RESP}    ${NGAP_INITIAL_CONTEXT_SETUP_RESPONSE} && ${NSETAPX_PROTOCOL} && ${NSETAPX_SBA} && ${UE9_NGAP_ID}

*** Keywords ***
Add Nestapx Prototcol Plugin To Tshark
     Load Tshark Bin Plugin    technology=5G

Start Server Interface
    [Documentation]    Starts interface between gNB and Trace Control Entity
    Start Vm Ethernet Interface    if_name=eth3:SERVER    ip_with_mask=10.0.1.1/24

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
    [Arguments]    ${ue_id}=1    ${meas_id}=1   ${srsrq_nr}=1    ${srsrp_nr}=1    ${ssinr_nr}=1    ${phycell_id}=52
    ...            ${nrsrq_nr}=122    ${nrsrp_nr}=122    ${nsinr_nr}=122    ${timeout}=30
    ...            ${pass_regexp}=message c1 : rrcReconfigurationComplete

    Send Custom Ue Measurement Nr    pass_regexp=${pass_regexp}
    ...                              id=${ue_id}    event=A5    meas_id=${meas_id}
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

Setup PCMD
    Configure PCMD    technology=5G    asn1per_decoding=${True}
    Start collecting PCMD reports

Teardown PCMD
    Stop collecting PCMD reports
    Deconfigure PCMD

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
