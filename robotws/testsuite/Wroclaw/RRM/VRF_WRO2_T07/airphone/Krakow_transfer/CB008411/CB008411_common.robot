*** Settings ***
Documentation
...            author:     Nelsandro Sampaio, nelsandro.sampaio@nokia.com
...                        Bartosz Szlezak, bartosz.szlezak@nokia.com
...                        Kamil Deregowki, kamil.deregowski@nokia.com
...                        Michal Sagan, michal.sagan@nokia.com

...            maintainer:     Bartosz Szlezak, bartosz.szlezak@nokia.com
...                            Kamil Deregowki, kamil.deregowski@nokia.com
...                            Michal Sagan, michal.sagan@nokia.com

Resource    ../../../../sim_resources/Krk_regression/ran_L3_SW2_resources/KRK3_resources/krk3_common/main_cls.robot
Resource    ./CB007227_common.robot
Resource    variables.robot
Library     ta5g_testline_management

*** Variables ***
${CUUP_CONNECTIVITY_RECORD_SND_TIME}      cuUpBearerCtxSetupReqSndTime.*seconds
${CUUP_CONNECTIVITY_RECORD_RCV_TIME}      cuUpBearerCtxSetupCmplRcvTime.*seconds
${UE_DU_CONN_RECORD_INITIAL_TIME}      DuUeCtxSetupData.*initialUeRrcMessageTransferRcvTime.*seconds
${UE_DU_CONN_RECORD_REQ_SND_TIME}      DuUeCtxSetupData.*ueCtxSetupReqSndTime.*seconds
${UE_DU_CONN_RECORD_REQ_RCV_TIME}      DuUeCtxSetupData.*ueCtxSetupCmplRcvTime.*seconds

*** Keywords ***
Start Subscriber Trace
    [Documentation]   This keyword enables sending NG:TRACE_START for specified UEs
    ...                - ``ue_id``: Specified UE ID
    ...                - ``trace_session_id``: Trace id for trace session
    ...                - ``tce_ip``: Trace collection Entity IP
    ...                - ``trace_depth``: Trace depth (minimum/medium/maximum/min_without_vse/med_without_vse/max_without_vse)
    [Arguments]    ${ue_id}=1    ${trace_session_id}=1    ${tce_ip}=0.0.0.0    ${trace_depth}=medium
    ${command} =  Catenate
    ...           ue_ng_trace_start id=${ue_id} tce_ip=${tce_ip} trace_depth=${trace_depth}
    ...           \ ifaces_to_trace=Uu,NG-C,Xn-C trace_plmn=311:489 trace_rec_session_ref_id=${trace_session_id}
	...           \ trace_ref_id=${trace_session_id}
    Execute Egate Command    cmd=${command}

Set Subscriber Trace Start By Amf
    [Documentation]    This keyword enables triggering another message along with NGAP:Handover Request message
    ...                to override parameters in NGAP:Handover Request mesage for given UEs.
    ...                - ``ue_id``: Specified UE ID
    ...                - ``trace_session_id``: Trace id for trace session
    ...                - ``tce_ip``: Trace collection Entity IP
    ...                - ``trace_depth``: Trace depth (minimum/medium/maximum/min_without_vse/med_without_vse/max_without_vse)
    [Arguments]    ${ue_id}=1    ${trace_session_id}=1    ${tce_ip}=0.0.0.0    ${trace_depth}=medium
    ${command} =  Catenate
    ...           amf_ue_ng_handover_request_param id=1 ue=${ue_id} trace_activation=on
    ...           \ trace_plmn=311:489 trace_ref_id=${trace_session_id}
    ...           \ trace_rec_session_ref_id=${trace_session_id} tce_ip=${tce_ip} trace_depth=${trace_depth}
    ...           \ ifaces_to_trace=Uu,NG-C,Xn-C
    Execute Egate Command    cmd=${command}

Trigger ICS With Trace Start
    [Documentation]    This keywords updates/displays online changeable AMF Initial Context Setup parameters
    ...                for given UEs, so allows to turn on the TraceActivation option in NGAP: Initial Context Setup message.
    ...                - ``ue_id``: Specified UE ID
    ...                - ``trace_session_id``: Trace id for trace session
    ...                - ``tce_ip``: Trace collection Entity IP
    ...                - ``trace_depth``: Trace depth (minimum/medium/maximum/min_without_vse/med_without_vse/max_without_vse)
    [Arguments]    ${ue_id}=1    ${trace_session_id}=1    ${tce_ip}=0.0.0.0    ${trace_depth}=medium
    ...            ${ifaces}=Uu,NG-C,Xn-C
    ${command} =  Catenate
    ...           amf_ue_ics_param id=1 ue=${ue_id} object_id=1 location_reporting_reference_id=1
    ...           \ trace_activation=on
	...           \ trace_plmn=311:489 trace_ref_id=${trace_session_id} trace_rec_session_ref_id=${trace_session_id} trace_depth=${trace_depth}
	...           \ ifaces_to_trace=${ifaces} tce_ip=${tce_ip}
    Execute Egate Command    cmd=${command}

Stop Subscriber Trace
    [Documentation]    This kewywords sends NG:TRACE_STOP for specified UEs.
    ...                - ``ue_id``: Specified UE ID
    ...                - ``trace_session_id``: Trace id for trace session
    [Arguments]    ${ue_id}=1    ${trace_session_id}=1
    ${command} =  Catenate
    ...           ue_ng_trace_stop id=${ue_id} trace_plmn=311:489 trace_rec_session_ref_id=${trace_session_id}
    ...           \ trace_ref_id=${trace_session_id}
    Execute Egate Command    cmd=${command}

Stop Subscriber Trace For ${num_ues} UEs
    FOR    ${ue}    IN RANGE    1    ${num_ues} + 1
        Stop Subscriber Trace    ue_id=${ue}    trace_session_id=${ue}
    END

Attach ${id_range} UEs And Start ${dl_mbps} DL And ${ul_mbps} UL Traffic For Each UE
    FOR   ${ue_id}      IN RANGE    1    ${id_range}+1
        Start SA L3 Call    ue_id=${ue_id}    dl_tput=${dl_mbps}    ul_tput=${ul_mbps}
    END

Stop Traffic And Deregister ${id_range} UEs
    FOR   ${ue_id}      IN RANGE    1    ${id_range}+1
        Stop Internal SA Traffic    ue_id=${ue_id}
        SA UE Deregister    ue_id=${ue_id}
    END

Trigger UE Reestablishment To The Same DU
   [Arguments]     ${ue_id}=1      ${cell_id}=2
   ute_wtssim.execute_egate_command
   ...      cmd=ue_rrc_reestablish id=${ue_id} gnb=2 cell=${cell_id} cause=otherFailure
   ...      pass_regexp=NR RRC Reestablishment sucessfully completed
   Sleep    5s    reason=Wait for reestablishment to be fully completed

Enable Trace Activation IE For 6 UEs In Which 3 Of Them Are Without Vse And Start Traffic
    Trigger ICS With Trace Start    ue_id=1    trace_session_id=1    trace_depth=minimum
    Start SA L3 Call    ue_id=1    dl_tput=80mbps      ul_tput=5mbps
	Trigger ICS With Trace Start    ue_id=2    trace_session_id=2    trace_depth=medium
	Start SA L3 Call    ue_id=2    dl_tput=80mbps      ul_tput=5mbps
	Trigger ICS With Trace Start    ue_id=3    trace_session_id=3    trace_depth=maximum
	Start SA L3 Call    ue_id=3    dl_tput=80mbps      ul_tput=5mbps
	Trigger ICS With Trace Start    ue_id=4    trace_session_id=4    trace_depth=min_without_vse
	Start SA L3 Call    ue_id=4    dl_tput=80mbps      ul_tput=5mbps
	Trigger ICS With Trace Start    ue_id=5    trace_session_id=5    trace_depth=med_without_vse
    Start SA L3 Call    ue_id=5    dl_tput=80mbps      ul_tput=5mbps
	Trigger ICS With Trace Start    ue_id=6    trace_session_id=6    trace_depth=min_without_vse
    Start SA L3 Call    ue_id=6    dl_tput=80mbps      ul_tput=5mbps

Filter PCMD Records For UE
    [Arguments]    ${trace_id}    ${records}    ${ue_id}
    Log to console    "Filter PCMD records for UE-${ue_id}"

    ${SBA_TRACE_ACT_FILE}    Filter PCMD Records in Collection
    ...    collected_records=${records}
    ...    traceRecordingSessionRef=00:0${trace_id}
    ...    save_to_file=${TEST_log_dir}/traceMessage-UE${ue_id}.json

    Log to console    Get PCMD Records from specific trace types - sba for UE-${ue_id}"
    ${sba_pcmd}     Get PCMD Records from specific trace types    json_file=${TEST_log_dir}/traceMessage-UE${ue_id}.json
    ...    save_to_file=${TEST_log_dir}/PCMD/PCMD-records-sba-UE${ue_id}.json
    [Return]    ${sba_pcmd}

Filter PCMD Records Based On Trace Field Name
    [Documentation]    This keyword returns PCMD records filtered by TraceMessage.
    ...                - ``fields``: Record field names with their expected values as regexp patterns
    ...                - ``filter``: Optional tshark packet filter, Default: nsetapx
    ...                - ``options``: List of extra tshark parameters, Default: None
    ...                - ``pcap_filepath``: Path to input PCAP file
    ...                - ``save_to_file``: Json file in which PCMD records shall be saved
    ...                - ``traceActivationType``: Json file in which PCMD records shall be saved
    ...                                           Default: nsetapx.traceActivationType=0
    ...                - ``trace_pattern``: Regexp pattern to match superior items, Default: nsetapx.*TraceMessage_tree
    ...                - ``PCMD_pattern``: Regexp pattern to match inerior items, Default: nsetapx.*Record_tree
    [Arguments]    ${pcap_filepath}    ${options}=@{Empty}
    ...    ${trace_pattern}=nsetapx.*TraceMessage_tree    ${PCMD_pattern}=nsetapx.*Record_tree
    ...    ${filter}=nsetapx   ${save_to_file}=${Empty}    &{fields}

    ${TraceMessage_records}    Get Items Matching Regexp From PCAP    pcap_filepath=${pcap_filepath}
    ...    pattern=${trace_pattern}
    ...    filter=${filter}
    ...    options=${options}
    ...    search_for="nsetapx": {    replace_with="nsetapx_$": {    remove_per=yes
    ${TraceMessage_records_filtered}    Filter PCMD Records in Collection
    ...    collected_records=${TraceMessage_records}
    ...    &{fields}

    ${items}    find_nodes_matching_regexp    ${TraceMessage_records_filtered}    ${PCMD_pattern}
    Run Keyword If    '${save_to_file}' != ''    Save Data as JSON File    data=${items}    filepath=${save_to_file}
    [Return]    ${items}

Get PCMD Records From Specific Trace Types
    [Documentation]   This keyword performs gets pcmd records from SBA or MBA
    ...               json files
    ...                - ``json_file``: The path (not content/object) of json file containing
    ...                                 unparsed PCMD records
    ...                - ``save_to_file``:     Json file in which PCMD records shall be saved
    [Arguments]      ${json_file}     ${save_to_file}=${Empty}
    ${json_string}    OperatingSystem.Get File    ${json_file}
    ${json_string}    replace_string_incrementally    ${json_string}    "nsetapx": {    "nsetapx_$": {
    ${json_obj}    json.loads    ${json_string}
    ${items}    find_nodes_matching_regexp    ${json_obj}    nsetapx.*Record_tree
    remove_nodes_matching_regexp    ${items}    ^per\\..*
    Run Keyword If    '${save_to_file}' != ''    Save Data as JSON File    data=${items}    filepath=${save_to_file}
    [Return]    ${items}

Verify For ${id_range} UEs That ${dl_mbps} DL And ${ul_mbps} UL Traffic Is Running And Stable For ${timeout} Period
    Sleep    ${timeout}    reason=Wait for traffic to reach timeout
    FOR   ${ue_id}      IN RANGE    1    ${id_range}+1
        Verify SA UE Traffic Using Bearer Stats    ue_id=${ue_id}    dl_tput=${dl_mbps}      ul_tput=${ul_mbps}
    END

Verify All CU-CP SBA PCMD Records Triggered By Initial Context Setup Request For UE
    [Documentation]   This keyword verifies C-PLANE PCMD records (SBA) triggered by NGAP:ICS
    [Arguments]     ${ue_id}     ${records}     ${which_message}    ${reestablishment}=False
    Should Be True    type(${ue_id}) is int    msg=Invalid KW parameter: ue_id
    Should Be True    type(${records}) is list    msg=Invalid KW parameter: records
    Should Be True    type(${reestablishment}) is bool    msg=Invalid KW parameter: reestablishment. Bool type
    ${index}       Evaluate     ${ue_id}-1
    @{BearerContextSetupRequest_timestamps}    Get Message Timestamp List From Pcap
    ...    filter=e1ap.BearerContextSetupRequest_element
    @{BearerContextSetupResponse_timestamps}   Get Message Timestamp List From Pcap
    ...    filter=e1ap.BearerContextSetupResponse_element
    ${initialUeRrcMessageTransferRcvTime_timestamps}     Get Message Timestamp From Pcap
    ...    filter=f1ap.InitialULRRCMessageTransfer_element     which_message=${which_message}
    ${ueCtxSetupReqSndTime1}     Get Message Timestamp From Pcap
    ...    filter=f1ap.UEContextSetupRequest_element    which_message=${which_message}
    ${ueCtxSetupCmplRcvTime1}    Get Message Timestamp From Pcap
    ...    filter=f1ap.UEContextSetupResponse_element    which_message=${which_message}
    Set To Dictionary     ${ueDuConnectivityRecord_pdu}         ${UE_DU_CONN_RECORD_REQ_SND_TIME}
    ...                   ${ueCtxSetupReqSndTime1}
    Set To Dictionary     ${ueDuConnectivityRecord_pdu}         ${UE_DU_CONN_RECORD_REQ_RCV_TIME}
    ...                   ${ueCtxSetupCmplRcvTime1}
    Set To Dictionary     ${ueDuConnectivityRecord_attach}      ${UE_DU_CONN_RECORD_INITIAL_TIME}
    ...                   ${initialUeRrcMessageTransferRcvTime_timestamps}
    Set To Dictionary     ${ueCuUpConnectivityRecord}           ${CUUP_CONNECTIVITY_RECORD_SND_TIME}
    ...                   ${BearerContextSetupRequest_timestamps}[${which_message}]
    Set To Dictionary     ${ueCuUpConnectivityRecord}           ${CUUP_CONNECTIVITY_RECORD_RCV_TIME}
    ...                   ${BearerContextSetupResponse_timestamps}[${which_message}]
    Set To Dictionary     ${pduSessionResourceInfoRecord}       pduSessionResourceInfoRecord.*pduSessionId
    ...                   ${ue_id}
    Set To Dictionary     ${bearerRecord}       bearerRecord.*pduSessionId
    ...                   ${ue_id}
    ${PCMD_SEQ}    Create List    ${ueDuConnectivityRecord_attach}    ${rrcSetupRecord}    ${ueInfoRecord}
    ...    ${ueCuUpConnectivityRecord}    ${ueDuConnectivityRecord_pdu}    ${pduSessionResourceInfoRecord}
    Verify PCMD Records Sequence in Collection    ${records}    ${PCMD_SEQ}

Start Vm Ethernet Interfaces
    Start Vm Ethernet Interface    if_name=eth3:GNB3_NG_ADDR    ip_with_mask=10.0.1.3/24
    Start Vm Ethernet Interface    if_name=eth3:GNB3_XN_ADDR    ip_with_mask=10.44.76.28/24

Stop Vm Ethernet Interfaces
    Stop Vm Ethernet Interface    if_name=eth3:GNB3_NG_ADDR    ip_with_mask=10.0.1.3/24
    Stop Vm Ethernet Interface    if_name=eth3:GNB3_XN_ADDR    ip_with_mask=10.44.76.28/24
