*** Settings ***

Documentation    :copyright: Nokia

Resource     resources/5G_CB007321_Keywords.robot
Library      ta5g_testline_management
Library      ta5g_iphy
Library      ta5g_enb
Library      ta5g_ue_measurements
Library      ta5g_delta
Library      ta_pcmd.tshark_plugin_configurator
Library      ta_pcmd
Resource          ../../Resources/Classical/RRM_Common_Resource.robot

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
${SA_Capa_perUE_Full}    E9A09000575F5A13160003C320016093170019C3D09009B20C39F30C7942C0E098040623807DC6C28C0D608C21A0810
...    7482406D6C98AB1A1CF88E3D033EC09F1891C790E7D473E618F28581C0E1E0B801FF800E000BE00098000702A0D883AC1184341020F10480C
...    AD931562439F604F88E3C62471E439F51CF9863CA1607038784FEC000003FB000000260001C0AA3626EB04610D04083A412030B64C55110E7
...    C471E238F40CFB027C639F30C7942C0E070F05C00FFC007003FF0004C0003815C7C46D608C21A08107CA090155B262AC2873E238F18000000
...    00000000000081C3C04FFF800003FFE00000260001C00F78789A001C4100000216020541E14000711800000858158788C001C410000061605
...    61E14000710400000858158789A001C46000002160562E2300071040038820000142C0AC3C28000E268000060B02B17134003882001C28000
...    008160562E26800711800388C0000082C0AC5C28000E20800711800001058158B850001C41000E208000020B02B17134003882001C4600000
...    4160562E14000711800388C0000082C0AC5C4D000E2300070A000002058158788C001C46000006160401C0468051013602087A05D83E14489
...    B1CF870A244D8E7C3851226C73E1C28913639F0E14489B1CF871224489B1CF870A040D8E7C08902040D8E7C08902040D8E7C08902040D8E7C
...    08902040D8E7C08902040D8E7C08902040D8E7C08902040D8E7C0850206C73E000B878C6318C6318C6318C630F413003E00281C1401C0C025
...    00700060240040603E09002000000010000020080000000400000802000008010000060080000400400002802001004010040000300200001
...    C010008000000200002001000012008000030040000500200002C01000812048020000300CE54D654D60A5606560CD60AD652D64CD602D606
...    D6025604560ED0341000009652504000065949410000296524040000E594901000049652404000165949010000696524040001E5949010000
...    89652404000265949010000A96524040002E5949410000C96524040000C594900CD2AABA55554AA2E95455058AA0B1541A2A94C55268AA031
...    540A2A93555078A1202F012A05028140A05028140A05028140A05028140A0502800304040300601002004202004010080600C201002004040
...    30060100C018202018030080600C201002004040300601002004402018030080600C0201803040400802010020086A87C0004080C10181C28
...    2C30344044484C5060646C70747C8494989CA0A4A8B4BD05060B40

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
    ...           \ ifaces_to_trace=Uu,NG-C,Xn-C,F1-C,E1 trace_plmn=311:489 trace_rec_session_ref_id=${trace_session_id}
    ...     trace_ref_id=${trace_session_id}
    Execute Egate Command    cmd=${command}

Set Subscriber Trace Start By Amf
    [Arguments]    ${ue_id}=1
    ${command} =  catenate  SEPARATOR=
    ...           amf_ue_ng_handover_request_param id=${ue_id} trace_activation=on trace_plmn=311:489 trace_ref_id=0
    ...           \ trace_rec_session_ref_id=0 tce_ip=10.0.1.1 trace_depth=medium ifaces_to_trace=Uu,NG-C,Xn-C,F1-C,E1
    Execute Egate Command    cmd=${command}

Start Xn And Ng Interfaces
    Start Vm Ethernet Interface    if_name=eth3:xn    ip_with_mask=10.0.1.101/24
    Start Vm Ethernet Interface    if_name=eth3:ng    ip_with_mask=10.0.1.102/24

Send A5 Event To Trigger Ho
    [Arguments]    ${ue_id}=1   ${srsrq_nr}=1    ${srsrp_nr}=1    ${ssinr_nr}=1    ${phycell_id}=52
    ...            ${nrsrq_nr}=122    ${nrsrp_nr}=122    ${nsinr_nr}=122    ${timeout}=30
    ...            ${pass_regexp}=message c1 : rrcReconfigurationComplete

    Send Ue Measurement Nr Event A5 With Aligned Meas Id    ue_id=${ue_id}  carrier_freq=636576
    ...                              pass_regexp=${pass_regexp}
    ...                              srsrq_nr=${srsrq_nr}    srsrp_nr=${srsrp_nr}    ssinr_nr=${ssinr_nr}
    ...                              phycell_id=${phycell_id}    nrsrq_nr=${nrsrq_nr}    nrsrp_nr=${nrsrp_nr}
    ...                              nsinr_nr=${nsinr_nr}    timeout=${timeout}

Add Item To UE History Information List
    [Arguments]  ${gnb_id}
    Execute Egate Command
    ...  cmd=ue_history_information_list_add_ngran id=1 gnb_id=${gnb_id} cell_type=medium nrcgi=311:489|0x01
    ...     time_ue_stayed_in_cell=100
    Execute Egate Command
    ...  cmd=ue_history_information_list id=1 action=commit
    Execute Egate Command
    ...  cmd=ue_enb_param id=1 ue_history_list=1

Trigger ICS With Trace Start
    [Arguments]    ${ue_id}=1    ${tce_ip}=0.0.0.0
    ${command} =  catenate   SEPARATOR=
    ...    amf_ue_ics_param id=1 ue=${ue_id} object_id=1 location_reporting_reference_id=1 trace_activation=on
    ...    trace_plmn=311:489
    ...    \ trace_ref_id=1 trace_rec_session_ref_id=1 trace_depth=medium ifaces_to_trace=Uu,NG-C,Xn-C,F1-C,E1
    ...    tce_ip=${tce_ip}
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
    ...                          log_dirpath=${RESULT_DIR}${/}${TEST_NAME}${/}${TSHARK_SUBDIR}
    ...                          log_filename_prefix='tcp_nsetapx'
    ...                          capture_filter='tcp'
    [Return]    ${tshark_alias_tcp}

Start Tcp Pcap
    Start tshark
    ...    log_filename=eth3_tcp.pcap
    ...    eth_interface=eth3
    ...    capture_filter='tcp'
    ...    log_dirpath=${RESULT_DIR}/${TEST_NAME}
    ...    alias=tcp_pcap

Stop Tcp Pcap
    [Arguments]    ${alias}=tcp_pcap
    Stop tshark    alias=${alias}

Verify Tcp Messages
    [Arguments]    ${packet_filter}    ${number_of_messages}=1    ${pcap_file_path}=${None}    ${timeout}=16
    ...    ${relation_symbol}= ==
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

Start Tcpdump Log
    Log To Console    start tcpdump
    ${tcpdump_log_name}=    Start tcpdump in SBTS
    Set Suite Variable    ${tcpdump_log_name}

Stop Tcpdump Log
    Log To Console    stop tcpdump
    ${capture_file_path}    ${input_file}=    Stop Tcpdump on SBTS
    set test variable    ${capture_file_path}


Send Throuput
    [Arguments]    ${ue_id}=3    ${pdu_id}=3
    Execute Egate Command And Wait For Data    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=175
    ...                                        trf_id=1 pass_regexp=traffic Receiver on Ue    timeout=60
    Execute Egate Command And Wait For Data    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=175
    ...                                        trf_id=2 pass_regexp=traffic Receiver on Ue    timeout=60
    Execute Egate Command And Wait For Data    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=175
    ...                                        trf_id=3 pass_regexp=traffic Receiver on Ue    timeout=60
    Execute Egate Command And Wait For Data    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=175
    ...                                        trf_id=4 pass_regexp=traffic Receiver on Ue    timeout=60
    Execute Egate Command And Wait For Data    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=175
    ...                                        trf_id=5 pass_regexp=traffic Receiver on Ue    timeout=60
    Execute Egate Command And Wait For Data    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=175
    ...                                        trf_id=6 pass_regexp=traffic Receiver on Ue    timeout=60
    Execute Egate Command And Wait For Data    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=175
    ...                                        trf_id=7 pass_regexp=traffic Receiver on Ue    timeout=60
    Execute Egate Command And Wait For Data    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=175
    ...                                        trf_id=8 pass_regexp=traffic Receiver on Ue    timeout=60

Stop Throuput
    [Arguments]    ${ue_id}=3    ${pdu_id}=3
    Execute Egate Command    cmd=trf_data_stop ue=${ue_id} pdu=${pdu_id} trf_id=1 dir=dl
    ...    pass_regexp=DL Traffic was stopped
    Execute Egate Command    cmd=trf_data_stop ue=${ue_id} pdu=${pdu_id} trf_id=2 dir=dl
    ...    pass_regexp=DL Traffic was stopped
    Execute Egate Command    cmd=trf_data_stop ue=${ue_id} pdu=${pdu_id} trf_id=3 dir=dl
    ...    pass_regexp=DL Traffic was stopped
    Execute Egate Command    cmd=trf_data_stop ue=${ue_id} pdu=${pdu_id} trf_id=4 dir=dl
    ...    pass_regexp=DL Traffic was stopped
    Execute Egate Command    cmd=trf_data_stop ue=${ue_id} pdu=${pdu_id} trf_id=5 dir=dl
    ...    pass_regexp=DL Traffic was stopped
    Execute Egate Command    cmd=trf_data_stop ue=${ue_id} pdu=${pdu_id} trf_id=6 dir=dl
    ...    pass_regexp=DL Traffic was stopped
    Execute Egate Command    cmd=trf_data_stop ue=${ue_id} pdu=${pdu_id} trf_id=7 dir=dl
    ...    pass_regexp=DL Traffic was stopped
    Execute Egate Command    cmd=trf_data_stop ue=${ue_id} pdu=${pdu_id} trf_id=8 dir=dl
    ...    pass_regexp=SCellIndex 1 deactivated successfully


Ue Attch For 7321
    [Arguments]    ${ue_id}=3    ${pdu_id}=3    ${gw_id}=3
    Execute Egate Command    cmd=ue_register id=${ue_id}    pass_regexp=UE now in NG RM Registered
    Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute Egate Command    cmd=ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} gw=${gw_id} nwslice=1
    ...    pass_regexp=QoS Routing Table
