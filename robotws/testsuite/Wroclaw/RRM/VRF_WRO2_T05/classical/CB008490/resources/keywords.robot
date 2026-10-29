*** Settings ***
Documentation
...                 author: Pawel Sniady
...                 contact: pawel.sniady@nokia.com

Library             Collections
Library             OperatingSystem
Library             Process
Library             String
Library             Telnet
Library             taf.sw.dcap.rd    WITH NAME    rd
Library             taf.collectors.dcap    WITH NAME    utflab
Library             taf.hw.rf_attenuator    WITH NAME    attenuator
Library             taf.analyzer.pcap    WITH NAME    pcap
Library             taf.rfrl.bts.devices.du.logs_collecting.basic_logs.GnbLog    WITH NAME    gnb_log

*** Keywords ***
Check Host Reachability
    [Documentation]    This keyword is used to check a user-defined host's reachability.
    ...    It succeeds when host is available. Otherwise, it returns a fail.
    ...    Arguments:
    ...    param str ip_addr: IPv4 address of network host
    [Arguments]    ${ip_addr}

    ${result}=    Run Process    ping ${ip_addr} -c 5    shell=True
    Should Contain    ${result.stdout}    64 bytes from ${ip_addr}

Reboot RF Attenuator
    [Documentation]    This keyword is used to restart a programmable RF attenuator.
    ...    Only JFW device is supported.
    ...    Arguments:
    ...    param str vendor: The vendor name of programmable RF attenuator
    ...    param str attenuator_id: RF attenuator instance ID defined in testline_configuration file
    [Arguments]    ${vendor}=JFW    ${attenuator_id}=0

    Should Be True    '${vendor}' in ('JFW')    msg=Unsupported attenuator type
    Run Keyword If    '${vendor}' == 'JFW'      Run Keywords
    ...    Telnet.Open Connection
           ...    ${tl.attenuators[${attenuator_id}].ip_addr}
           ...    port=${tl.attenuators[${attenuator_id}].port}
    ...    AND    Telnet.Write              REBOOT
    ...    AND    Sleep    3
    ...    AND    Wait Until Keyword Succeeds   5   5
           ...    Check Host Reachability   ${tl.attenuators[${attenuator_id}].ip_addr}

Initialize RF Attenuator
    [Documentation]    This keyword is used to initialize the connection towards the programmable RF attenuator.
    ...    Arguments:
    ...    param str attenuator_id: RF attenuator instance ID defined in testline_configuration file
    [Arguments]    ${attenuator_id}=0

    Reboot RF Attenuator
    attenuator.Setup Attenuator    vendor=JFW
    ...    ip_addr=${tl.attenuators[${attenuator_id}].ip_addr}
    ...    port=${tl.attenuators[${attenuator_id}].port}
    ...    attenuation_port_numbers=${tl.attenuators[${attenuator_id}].attenuation_port_numbers}
    ...    alias=PA_${attenuator_id}

Set RF Attenuation
    [Documentation]    This keyword set a specific attenuation value for a given radio module.
    ...    Arguments:
    ...    param str attenuator_id: RF attenuator instance ID defined in testline_configuration file.
    ...    param str gnb_id: gNodeB instance ID defined in testline_configuration file.
    ...    param str du_id: gNodeB-DU instance ID defined in testline_configuration file.
    ...    param str radio_module_id: Radio module instance ID defined in testline_configuration file.
    ...    param str value: RF attenuation value to be introduced on the RF path.
    [Arguments]    ${attenuator_id}=0    ${gnb_id}=0    ${du_id}=0    ${radio_module_id}=0    ${value}=0

    FOR    ${index}    IN    @{tl.gnbs[${gnb_id}].dus[${du_id}].rus[${radio_module_id}].attenuation_ports}
        attenuator.Set Attenuation    port=${index.port_no}
        ...    value=${${value}}
        ...    confirm=True
        ...    attenuator_device=PA_${attenuator_id}
    END

Terminate RF Attenuator
    [Documentation]    This keyword is used to set maximum attenuation on all ports and disconnect all active socket
    ...    connections from a programmable RF attenuator. Only JFW and TopYoung devices are supported.
    ...    Arguments:
    ...    param str vendor = JFW|TopYoung: The vendor name of programmable RF attenuator
    ...    param str attenuator_id: RF attenuator instance ID defined in testline_configuration file
    [Arguments]    ${vendor}=JFW    ${attenuator_id}=0

    Should Be True    '${vendor}' in ('JFW', 'TopYoung')    msg=Unsupported attenuator type
    FOR    ${index}    IN    @{tl.attenuators[${attenuator_id}].attenuation_port_numbers}
        attenuator.Set Attenuation    port=${index}
        ...    value=${90}
        ...    confirm=True
        ...    attenuator_device=PA_${attenuator_id}
    END
    Telnet.Open Connection    ${tl.attenuators[${attenuator_id}].ip_addr}
    ...    port=${tl.attenuators[${attenuator_id}].port}
    Telnet.Write    DIS

Start UTF Lab Tracing
    [Documentation]    This keyword is collecting a user-defined set of logs from the selected cells using UTF Lab.
    ...    Arguments:
    ...    param str utflab_ipaddr: IPv4 address of UTF Lab application
    ...    param str gnb_id: gNB instance ID defined in testline_configuration file
    ...    param list bts_custom_profile: BTS level trace profile, e.g.: immediateSnapshot, scf, pmFiles
    ...    param list gnb_custom_profile: gNB level trace profile, e.g.: condor5gsyslog, cp_5g
    ...    param list cells: Runtime NRCELL object where tracing will be started, e.g.: NRCELL_R-101
    [Arguments]    ${utflab_ipaddr}=${tl.gnbs[0].dcap.connection_details.addr}
    ...    ${gnb_id}=0
    ...    ${bts_custom_profile}=${None}
    ...    ${gnb_custom_profile}=${None}
    ...    ${cells}=${None}
    ...    ${alias}=utflab

    @{bts_default_profile}=    Create List    immediateSnapshot    scf    pmFiles    ipCapture
    ${bts_custom_profile}=    Set Variable If    ${bts_custom_profile} is None    ${bts_default_profile}
    ...    ${bts_custom_profile}

    @{gnb_default_profile}=    Create List    condor5gSyslog    cp_5g
    ${gnb_custom_profile}=    Set Variable If    ${gnb_custom_profile} is None    ${gnb_default_profile}
    ...    ${gnb_custom_profile}

    &{bts}=    Create Dictionary
    ...    host=${tl.gnbs[${gnb_id}].cu.backhaul_site_oam_ip.v4}
    ...    port=443
    ...    username=${tl.gnbs[0].cu.oam_http_connection_details.username}
    ...    password=${tl.gnbs[0].cu.oam_http_connection_details.password}
    ...    nrCells=@{cells}

    &{utflab}=    Create Dictionary
    ...    host=${utflab_ipaddr}
    ...    port=443
    ...    username=${tl.gnbs[0].dcap.connection_details.username}
    ...    password=${tl.gnbs[0].dcap.connection_details.password}

    &{trace}=    Create Dictionary
    ...    bts=${bts}
    ...    bts_custom_profile=${bts_custom_profile}
    ...    gnb_custom_profile=${gnb_custom_profile}
    ...    timeout=${600.0}

    utflab.Create DCAP Trace Collector
    ...    name=${alias}
    ...    dcap=${utflab}
    ...    trace=${trace}
    ...    invalidate_bts_info_cache=True

    utflab.Setup Collectors    names=${alias}
    utflab.Set Suite Alias    ${alias}
    utflab.Start Collectors    names=${alias}

Stop UTF Lab Tracing
    [Documentation]    This keyword stop the active UTF Lab trace and collects the logs.
    ...    Arguments:
    ...    param str alias: The instance alias
    [Arguments]    ${alias}=utflab

    utflab.Stop Collectors    names=${alias}
    utflab.Collect Collectors    names=${alias}

Teardown UTF Lab Collector
    [Documentation]    This keyword will teardown a UTF Lab Collector.
    ...    Arguments:
    ...    param str alias: The instance alias
    [Arguments]    ${alias}=utflab

    utflab.Teardown Collectors    names=${alias}

Wait Until Next PM Interval
    [Documentation]    This keyword wait until the next PM reporting interval.
    ...    Arguments:
    ...    param int pm_interval: The time interval in which the BTS creates a PM file.
    ...    param int delay: An additional time delay needed to create PM counters file.
    [Arguments]    ${pm_interval}=${5}    ${delay}=${45}

    ${current_minutes}=    Get Time    minutes
    ${remaining_minutes}=    Evaluate    ${${current_minutes}} % ${pm_interval}
    ${seconds_to_sleep}=    Evaluate    (${pm_interval} - ${remaining_minutes}) * 60 + ${delay}
    Sleep    ${seconds_to_sleep}

Convert Control Plane Trace To Json
    [Documentation]    This keyword uploads Control Plane traces into Web Emil in UTF Lab for postprocessing.
    ...    The logs are filtered out to match only Sctp and Zmq messages and converted into json format.
    ...    Arguments:
    ...    param list file_list: The filepath(s) of Control Plane trace(s)
    ...    param str target_dir: The target directory for the output files.
    [Arguments]    ${file_list}    ${target_dir}

    rd.Connect to    host=${tl.gnbs[0].dcap.connection_details.addr}
    ...    port=443
    ...    username=utfuser
    ...    password=utfadmin!
    ...    rd_version=dcapv3
    ...    secure=True

    ${f1ap_protocol}=     Catenate    SEPARATOR=;  "Message name"="ITF_CP_CPUE_CPRT_CPRT_SENDTOCPUE_ID"
    ...    "Message name"="ITF_CP_CPUE_CPRT_CPRT_RECEIVEFROMCPUE_ID"
    ${e1ap_protocol}=    Catenate    SEPARATOR=;  "Message name"="ITF_CP_CPUE_CPNRT_CPNRT_SENDTOCPUE_ID"
    ...    "Message name"="ITF_CP_CPUE_CPNRT_CPNRT_RECEIVEFROMCPUE_ID"
    ${other_protocols}=    Catenate    SEPARATOR=;  "Message name"="SctpMessage"    "Message name"="ZmqMessage"
    ...    "Message name"="TmMessage"    "Message name"="ITF_CP_CP_SB_INTERFACE_SRBSENDREQ_ID"
    ...    "Message name"="ITF_CP_CP_SB_UE_INTERFACE_ULSDURECEIVEIND_ID"
    ...    "Message name"="ITF_CP_CP_SB_UE_INTERFACE_SRBSENDREQ_ID"
    ${filtered_protocols}=  Catenate  SEPARATOR=;  ${f1ap_protocol}  ${e1ap_protocol}  ${other_protocols}
    ${testresults}=    Set Variable    /home/ute/test_results
    ${dir}=    Catenate    SEPARATOR=/    ${testresults}    ${SUITE_NAME}    ${TEST_NAME}    ${target_dir}    CP_FILES

    FOR    ${file}    IN    @{file_list}
        ${trace}=    rd.Upload Encoded File    file_name=${file}
        ${result}=    rd.Get Decoded File Contents In Json
        ...    session_id=${trace['session_id']}
        ...    data_source_id=${trace['source_ids'][0]}
        ...    what=source
        ...    filter=${filtered_protocols}
        ...    timeout=180
        ...    tree=n
        ${json}=    Evaluate    json.dumps(${result})    json
        Create File    ${dir}/${trace['file_names'][0][:-4]}.json    ${json}
    END

Prepare Logs For Analysis
    [Documentation]    This keyword prepares the logs collected from UTF Lab for analysis. Depending on the log type,
    ...    various operations are executed, e.g., extraction, merge, or file type conversion.
    ...    Arguments:
    ...    param list requested_logs: The log types to be prepared. Only cp_5g, ipCapture, and/or pmFiles are supported.
    ...    param str source_dir: The source directory of the logs collected via UTF Lab.
    ...    param str target_dir: The target directory for the output files.
    ...    Return:
    ...    log_files: A dictionary containing the file paths to logs.
    [Arguments]    ${requested_logs}    ${source_dir}    ${target_dir}

    ${controlPlane5g_json}=    Set Variable    None
    ${ipCapture_pcap}=    Set Variable    None

    FOR    ${log_type}    IN    @{requested_logs}
        ${temp_json}=   Run Keyword If    '${log_type}' == 'cp_5g'
        ...    Handle CP 5G Logs    ${source_dir}    ${target_dir}
        Run Keyword If    '${log_type}' == 'pmFiles'
        ...    Extract Zip With Nested Gz    nested_zip_pattern=.*pm-files.*    source_dir=${source_dir}
        ${temp_pcap}=    Run Keyword If    '${log_type}' == 'ipCapture'
        ...    Handle IP Capture Logs    ${source_dir}    IPCAPTURE_FILES
        ${controlPlane5g_json}=    Set Variable If    '${temp_json}' != 'None'    ${temp_json}    ${controlPlane5g_json}
        ${ipCapture_pcap}=    Set Variable If    '${temp_pcap}' != 'None'    ${temp_pcap}    ${ipCapture_pcap}
    END

    ${log_files}=    Create Dictionary    cp_5g=${controlPlane5g_json}    ipCapture=${ipCapture_pcap}
    [Return]    ${log_files}

Handle CP 5G Logs
    [Documentation]    This keyword handles the extraction and processing of Control Plane 5G logs. It extracts
    ...    the relevant files from a zip archive, converts the Control Plane trace to JSON format,
    ...    and merges the JSON files into a single file.
    ...    Arguments:
    ...    param str source_dir: The source directory where the zip files containing the Control Plane 5G logs are located.
    ...    param str target_dir: The target directory where the processed JSON files will be stored.
    ...    Return:
    ...    cp_5g_json: The path to the merged JSON file containing the Control Plane 5G logs.

    [Arguments]    ${source_dir}    ${target_dir}
    @{cp_5g}=    Extract Files From Zip    file_pattern=.*5gm    source_dir=${source_dir}    target_dir=CP_FILES
    Convert Control Plane Trace To Json    ${cp_5g}    ${target_dir}
    ${cp_5g_json}=    Merge Json Files    ${target_dir}
    [Return]    ${cp_5g_json}

Handle IP Capture Logs
    [Documentation]    This keyword handles the extraction and processing of IP Capture logs. It extracts the relevant
    ...    files from a zip archive and merges the pcap files into a single file if any pcap files are found.
    ...    Arguments:
    ...    param str source_dir: The source directory where the zip files containing the IP Capture logs are located.
    ...    param str target_dir: The target directory where the processed pcap files will be stored.
    ...    Return:
    ...    ipCapture_pcap: The path to the merged pcap file containing the IP Capture logs.
    [Arguments]    ${source_dir}    ${target_dir}

    @{ipCapture}=    Extract Files From Zip
    ...    file_pattern=.*pcap
    ...    source_dir=${source_dir}
    ...    target_dir=${target_dir}
    ${ipCapture_pcap}=    Run Keyword If    ${ipCapture} != @{EMPTY}    Merge Pcap Files    ${ipCapture}
    [Return]    ${ipCapture_pcap}

Assert BTS On Air Status
    [Documentation]    This keyword asserts that the BTS is in the 'On Air' status.
    ...    It retrieves the current status and compares it with the expected 'On Air' status.
    ...    If the BTS is not 'On Air', an error message will be displayed indicating the current procedural state.
    ...    Arguments:
    ...    param str connection: AdminConnection string name alias
    [Arguments]    ${connection}

    ${state}=    oam.Get BTS Statuses    connection=${connection}
    ${procedural_state}=    Set Variable    ${state['proceduralState']}
    Should Be Equal As Strings    ${procedural_state}    OnAir    BTS is not OnAir (proceduralState=${proceduralState}

Calculate NR-DC Call Setup Time
    [Documentation]    This keyword calculates NR-DC Call setup latency time based on a PCAP file. As the intention is
    ...    to verify internal gNB processing time, some external factors (i.e. AMF and UE processing time) that may have
    ...    impact on the results are assumed to be within the defined targets.
    ...    Arguments:
    ...    param float target: maximum allowed NR-DC Call Setup latency
    ...    param str file_name: a path to PCAP file containing the NR-DC Call Setup procedure
    [Arguments]    ${target}    ${file_name}

    ${timerXnDataFwdGuard}=    Set Variable    ${250.0}

    ${snode_add_req}=    Find Message In PCAP    pcap_file=${file_name}
    ...    display_filter=nokiaxnap.SNodeAdditionRequest_element and ip.dst == ${tl.gnbs[1].cu.xnc.v4}
    ${snode_add_req_timestamp}=    Get Frame Arrival Time    ${snode_add_req}

    ${rrc_recfg}=    Find Message In PCAP    pcap_file=${file_name}
    ...    display_filter=f1ap.DLRRCMessageTransfer_element
    ...    arrival_time=${snode_add_req_timestamp}
    ${rrc_recfg_timestamp}=    Get Frame Arrival Time    ${rrc_recfg}

    ${rrc_recfg_cmplt}=    Find Message In PCAP    pcap_file=${file_name}
    ...    display_filter=f1ap.ULRRCMessageTransfer_element
    ...    arrival_time=${snode_add_req_timestamp}
    ${rrc_recfg_cmplt_timestamp}=    Get Frame Arrival Time    ${rrc_recfg_cmplt}

    ${pdu_mod_ind}=    Find Message In PCAP    pcap_file=${file_name}
    ...    display_filter=ngap.PDUSessionResourceModifyIndication_element and ip.src == ${tl.gnbs[0].cu.ngc.v4}
    ...    arrival_time=${snode_add_req_timestamp}
    ${pdu_mod_ind_timestamp}=    Get Frame Arrival Time     ${pdu_mod_ind}

    ${pdu_mod_confm}=    Find Message In PCAP    pcap_file=${file_name}
    ...    display_filter=ngap.PDUSessionResourceModifyConfirm_element and ip.dst == ${tl.gnbs[0].cu.ngc.v4}
    ...    arrival_time=${snode_add_req_timestamp}
    ${pdu_mod_confm_timestamp}=    Get Frame Arrival Time     ${pdu_mod_confm}

    ${bearer_cntxt_mod_resp_filter}=    Catenate    e1ap.BearerContextModificationResponse_element
    ...    and    e1ap.PDU_Session_Resource_Modified_List    and    !(e1ap.pDCP_SN_Status_Information_element)
    ${bearer_cntxt_mod_resp}=    Find Message In PCAP   pcap_file=${file_name}
    ...    display_filter=${bearer_cntxt_mod_resp_filter}
    ...    arrival_time=${snode_add_req_timestamp}
    ${bearer_cntxt_mod_resp_timestamp}=    Get Frame Arrival Time    ${bearer_cntxt_mod_resp}

    ${raw_result}=    Get Time Diff    ${snode_add_req_timestamp}    ${bearer_cntxt_mod_resp_timestamp}
    ${amf_proc}=    Evaluate Message Processing Time    ${pdu_mod_ind_timestamp}    ${pdu_mod_confm_timestamp}    ${6.0}
    ${ue_proc}=    Evaluate Message Processing Time    ${rrc_recfg_timestamp}    ${rrc_recfg_cmplt_timestamp}    ${26.5}

    ${total_latency}=    Evaluate    ${raw_result} - ${ue_proc} - ${amf_proc} - ${timerXnDataFwdGuard}
    Log    Total Latency: ${total_latency}
    Should Be True    ${total_latency} <= ${target}

Calculate MN Inititated NR-DC Bearer Takeback Time
    [Documentation]    This keyword calculates MN initiated NR-DC bearer takeback latency based on a PCAP file.
    ...    As the intention is to verify internal gNB processing time, some external factors (i.e. AMF and UE
    ...    processing time) that may have impact on the results are assumed to be within the defined targets.
    ...    Arguments:
    ...    param float target: maximum allowed MN initiated NR-DC bearer takeback latency
    ...    param str file_name: a path to PCAP file containing the NR-DC Call Setup procedure
    [Arguments]    ${target}    ${mn_file_name}    ${sn_file_name}

    ${snode_rel_req}=    Find Message In PCAP    pcap_file=${mn_file_name}
    ...    display_filter=nokiaxnap.SNodeReleaseRequest_element and ip.dst == ${tl.gnbs[1].cu.xnc.v4}
    ${snode_rel_req_timestamp}=    Get Frame Arrival Time    ${snode_rel_req}

    ${rrc_recfg}=    Find Message In PCAP    pcap_file=${mn_file_name}
    ...    display_filter=f1ap.DLRRCMessageTransfer_element
    ...    arrival_time=${snode_rel_req_timestamp}
    ${rrc_recfg_timestamp}=    Get Frame Arrival Time    ${rrc_recfg}

    ${rrc_recfg_cmplt}=    Find Message In PCAP    pcap_file=${mn_file_name}
    ...    display_filter=f1ap.ULRRCMessageTransfer_element
    ...    arrival_time=${snode_rel_req_timestamp}
    ${rrc_recfg_cmplt_timestamp}=    Get Frame Arrival Time    ${rrc_recfg_cmplt}

    ${pdu_mod_ind}=    Find Message In PCAP    pcap_file=${mn_file_name}
    ...    display_filter=ngap.PDUSessionResourceModifyIndication_element and ip.src == ${tl.gnbs[0].cu.ngc.v4}
    ...    arrival_time=${snode_rel_req_timestamp}
    ${pdu_mod_ind_timestamp}=    Get Frame Arrival Time     ${pdu_mod_ind}

    ${pdu_mod_confm}=    Find Message In PCAP    pcap_file=${mn_file_name}
    ...    display_filter=ngap.PDUSessionResourceModifyConfirm_element and ip.dst == ${tl.gnbs[0].cu.ngc.v4}
    ...    arrival_time=${snode_rel_req_timestamp}
    ${pdu_mod_confm_timestamp}=    Get Frame Arrival Time     ${pdu_mod_confm}

    ${ue_cntxt_rel_cmplt}=    Find Message In PCAP   pcap_file=${sn_file_name}
    ...    display_filter=f1ap.UEContextReleaseComplete_element
    ...    arrival_time=${snode_rel_req_timestamp}
    ${ue_cntxt_rel_cmplt_timestamp}=    Get Frame Arrival Time    ${ue_cntxt_rel_cmplt}

    ${raw_result}=    Get Time Diff    ${snode_rel_req_timestamp}    ${ue_cntxt_rel_cmplt_timestamp}
    ${amf_proc}=    Evaluate Message Processing Time    ${pdu_mod_ind_timestamp}    ${pdu_mod_confm_timestamp}    ${6.0}
    ${ue_proc}=    Evaluate Message Processing Time    ${rrc_recfg_timestamp}    ${rrc_recfg_cmplt_timestamp}    ${26.5}

    ${total_latency}=    Evaluate    ${raw_result} - ${ue_proc} - ${amf_proc}
    Log    Total Latency: ${total_latency}
    Should Be True    ${total_latency} <= ${target}

Start PCAP collection on nodes
    [Documentation]    This keyword activates network interface tracing using tcpdump utility on MN-gNB and SN-gNB.
    ...    Return:
    ...    str mn_file_name: A string representing a PCAP file name collected on MN-gNB
    ...    str sn_file_name: A string representing a PCAP file name collected on SN-gNB

    ${TIMESTAMP}=    Get Current Date    result_format=%Y%m%d.%H%M%S    time_zone=UTC
    ${mn_file_name}=  Set Variable    MN_CPlane_${TIMESTAMP}.pcap
    ${sn_file_name}=  Set Variable    SN_CPlane_${TIMESTAMP}.pcap
    ${capture_filter}=    Set Variable   'sctp and (port 38412 or port 38472 or port 38462 or port 38422 or port 29211)'

    gnb_log.Start Tcpdump On SMOD   bts_id=0
    ...                             interface=any
    ...                             capture_file=${mn_file_name}
    ...                             background=${True}
    ...                             additional_options=${capture_filter}
    gnb_log.Start Tcpdump On SMOD   bts_id=1
    ...                             interface=any
    ...                             capture_file=${sn_file_name}
    ...                             background=${True}
    ...                             additional_options=${capture_filter}

    [Return]    ${mn_file_name}    ${sn_file_name}

Generate And Download PCAP files from nodes
    [Documentation]    This keyword deactivates a network interfaces tracing using tcpdump utility and downloads the
    ...    collected traces.
    ...    Arguments:
    ...    str mn_file_name: A string representing a PCAP file name collected on MN-gNB
    ...    str sn_file_name: A string representing a PCAP file name collected on SN-gNB
    ...    Return:
    ...    list log_path: A list containing file paths to collected traces
    [Arguments]    ${mn_file_name}    ${sn_file_name}

    ${test_logs}=    Set Variable    /home/ute/test_results
    ${dir}=    Catenate    SEPARATOR=/    ${test_logs}    ${SUITE_NAME}    ${TEST_NAME}    _extracted    IPCAPTURE_FILES
    ${mn_file_path}=    Catenate    SEPARATOR=/    ${dir}    ${mn_file_name}
    ${sn_file_path}=    Catenate    SEPARATOR=/    ${dir}    ${sn_file_name}
    @{log_path}=    Create List    ${mn_file_path}    ${sn_file_path}

    gnb_log.Stop Tcpdump On SMOD    bts_id=0
    gnb_log.Stop Tcpdump On SMOD    bts_id=1
    gnb_log.Download Tcpdump From BTS    bts_id=0
    ...                                  interface=FCT
    ...                                  log_file_name=${mn_file_name}
    ...                                  log_dir=${dir}
    gnb_log.Download Tcpdump From BTS    bts_id=1
    ...                                  interface=FCT
    ...                                  log_file_name=${sn_file_name}
    ...                                  log_dir=${dir}

    [Return]    ${log_path}

Calculate NR-DC Data Interruption Time
    [Documentation]    This keyword calculates the data interruption time during NR-DC call setup/takeback using a TTI
    ...    trace file. The data interruption time refers to the interval between the last data PDU received over the DRB
    ...    which will be split before the NR-DC call setup, and the first data PDU received over the split DRB
    ...    after the NR-DC call setup
    ...    Arguments:
    ...    param float target: maximum allowed NR-DC Call Setup/Takeback data interruption time
    ...    param str file_name: a path to TTI trace file containing the NR-DC Call Setup/Takeback procedure in JSON
    [Arguments]    ${target}    ${lcId_before}    ${lcId_after}    ${minBytes}    ${file_path}

    ${output_file_path_1}=    CATENATE    SEPARATOR=    ${file_path}[:-5]    _filtered_    ${lcId_before}    .json
    ${output_file_path_2}=    CATENATE    SEPARATOR=    ${file_path}[:-5]    _filtered_    ${lcId_after}    .json

    Filter scheduledBytesPerBearer in JSON
    ...    input_file_path=${file_path}
    ...    output_file_path=${output_file_path_1}
    ...    lc_id=${lcId_before}
    Filter scheduledBytesPerBearer in JSON
    ...    input_file_path=${file_path}
    ...    output_file_path=${output_file_path_2}
    ...    lc_id=${lcId_after}
    Remove File    ${file_path}
    ${last_pdu}=    Find Last Data PDU Before NRDC Setup    ${output_file_path_1}    ${lcId_before}    ${minBytes}
    ${first_pdu}=    Find First Data PDU After NRDC Setup    ${output_file_path_2}    ${lcId_after}    ${minBytes}
    ${sfn1}=    Get From Dictionary    ${last_pdu}[0]    sfn
    ${slot1}=    Get From Dictionary    ${last_pdu}[1]    slot
    ${sfn2}=    Get From Dictionary    ${first_pdu}[0]    sfn
    ${slot2}=    Get From Dictionary    ${first_pdu}[1]    slot
    ${total_dit}=    Get Time Diff Between SFNs    ${sfn1}    ${slot1}    ${sfn2}    ${slot2}
    Should Be True    ${total_dit} <= ${target}
