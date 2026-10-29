*** Settings ***
Documentation
...  author: cristinel.sava@nokia.com
...  file for tests with Airphone TLs

Resource    ../resources/5G_SW_WRO_Keywords.robot
Resource    ../resources/dcap.robot
Library     ../resources/python/dcap.py

Library    ta5g_testline_management
Library    ta5g_iphy
Library    ta5g_enb
Library    ta5g_delta
Library    ta5g_pm_counters
Library    ta5g_file_system
Library    ta5g_ue_measurements
Library    ta5g_dcap
Library    ta_pcmd.tshark_plugin_configurator
Library    ta_pcmd
Library    ute_wtssim
#Library    ./B07/Library/pcmd_message.py
Library    ta5g_setups_and_teardowns
Library    taf.transport.ssh    WITH NAME   csn
Library     taf.collectors.btslog       WITH NAME    btslog
Library     taf.collectors.core         WITH NAME    core
Library     taf.analyzer.pcap          WITH NAME    pcap

#Library    ./B07/Library/emil_vars.py

*** Variables ***

${trace_Nsetupx}=    tcp.dstport==49148 && nsetapx.TraceMessage == 2 && nsetapx.nodeType == 0
${trace_start}=   ng_ue_trace_start id=1 trace_plmn=311:489 trace_ref_id=1 trace_rec_session_ref_id=1
...               ifaces_to_trace=NG-C,Uu,Xn-C,F1-C tce_ip=0.0.0.0 trace_depth=minimum
${UTE_SSH_IP}=                     ${tl.test_pc.default_ssh_connection_details.addr}
${RANAC_USEFULLRESUMEID_CELL1}=    (nr-rrc.ranac == 0) && (nr-rrc.ranac == 1) && (nr-rrc.useFullResumeID == 0) &&
...                                (nr-rrc.cellIdentity == 00:00:04:00:10)
${RANAC_USEFULLRESUMEID_CELL2}=    (!(nr-rrc.useFullResumeID == 0) && (nr-rrc.cellIdentity == 00:00:04:00:20)) &&
...                                (nr-rrc.si_Periodicity == 1)
${OFF_RANAC_USEFULLRESUMEID_CELL1}=    (!((nr-rrc.ranac == 0) && (nr-rrc.ranac == 1) && (nr-rrc.useFullResumeID == 0))) &&
...                                    (nr-rrc.cellIdentity == 00:00:04:00:10) && (nr-rrc.si_Periodicity == 2)
${OFF_RANAC_USEFULLRESUMEID_CELL1_NO_RANSHARING}=    (!((nr-rrc.ranac == 1) && (nr-rrc.useFullResumeID == 0))) &&
...                                                  (nr-rrc.cellIdentity == 00:00:04:00:10) && (nr-rrc.si_Periodicity == 1)
${OFF_RANAC_USEFULLRESUMEID_CELL2}=    (!(nr-rrc.useFullResumeID == 0) && (nr-rrc.cellIdentity == 00:00:04:00:20)) &&
...                                    (nr-rrc.si_Periodicity == 2)
${SET_AMF_TO_SEND_CNAI_IE_IN_UE_ICS_REQ_EGATE_CMD}=    amf_ue_ics_param id=1 core_network_assistance_info=on ue_identity_index_value=1
...                                                    ue_specific_drx=64 periodic_registration_update_timer=1:10min plmn_id=311:489 tac_id=200
${SET_AMF_TO_SEND_CNAI_IE_IN_PATH_SW_REQ_EGATE_CMD}=    amf_ue_path_switch_param  id=1 core_network_assistance_info=on ue_identity_index_value=1
...                                                     ue_specific_drx=64 periodic_registration_update_timer=1:10min plmn_id=311:489 tac_id=200
${SET_AMF_TO_SEND_CNAI_IE_IN_HO_REQ_EGATE_CMD}=    amf_ue_ng_handover_request_param id=1 core_network_assistance_info=on ue_identity_index_value=1
...                                                ue_specific_drx=64 periodic_registration_update_timer=1:10min plmn_id=311:489 tac_id=200
${SET_AMF_TO_SEND_CNAI_IE_IN_UE_CTX_MOD_REQ_EGATE_CMD}=    amf_ue_ctx_modify_param id=1 core_network_assistance_info=on ue_identity_index_value=1
...                                                        ue_specific_drx=64 periodic_registration_update_timer=1:10min plmn_id=311:489 tac_id=200
${SET_AMF_TO_SEND_CNAI_IE_IN_UE_ICS_REQ_EGATE_CMD_mo_SMS}=    amf_ue_ics_param id=1 ue=1 core_network_assistance_info=on ue_identity_index_value=1
...                                                        ue_specific_drx=64 periodic_registration_update_timer=5:1min plmn_id=311:489 tac_id=200
${RRC_RELEASE_WITH_SUSPEND}=    ${RRC_RELEASE} && nr-rrc.suspendConfig_element
${RRC_RELEASE_WITHOUT_SUSPEND}=    ${RRC_RELEASE} && !(nr-rrc.suspendConfig_element)
${E1AP_BEARER_CONTEXT_STATUS_CHANGE_SUSPEND}=    ${E1AP_BEARER_CONTEXT_MODIFICATION_REQUEST} && e1ap.BearerContextStatusChange == 0
${E1AP_BEARER_CONTEXT_MODIFICATION_RESPONSE_TO_BEARER_CONTEXT_STATUS_CHANGE}=    ${E1AP_BEARER_CONTEXT_MODIFICATION_RESPONSE}
...                                                                              && !(e1ap.System_BearerContextModificationResponse)
${F1AP_UE_CONTEXT_RELEASE_REQUEST_WITH_RRC_RELEASE_WITH_SUSPEND}=    ${F1AP_UE_CONTEXT_RELEASE_COMMAND}
...                                                                  && f1ap.radioNetwork == 10 && nr-rrc.c1 == 2
${SET_AMF_TO_SEND_CNAI_IE_IN_UE_ICS_REQ_EGATE_CMD_MNC_489_UE2}=    amf_ue_ics_param id=1 ue=2 core_network_assistance_info=on
...                                                                ue_identity_index_value=2 ue_specific_drx=64
...                                                                periodic_registration_update_timer=1:10min plmn_id=311:489 tac_id=100
${SET_AMF_TO_SEND_CNAI_IE_IN_UE_ICS_REQ_EGATE_CMD_MNC_489_UE5}=    amf_ue_ics_param id=1 ue=5 core_network_assistance_info=on
...                                                                ue_identity_index_value=1 ue_specific_drx=256
...                                                                periodic_registration_update_timer=1:10min plmn_id=311:489 tac_id=200

${emil_host}    10.5.60.45
${emil_user}    wcdmata
${emil_password}    Aikon_123456*8
#${txt_file}     unknown
${emil_log_dir}    /cygdrive/c/temp/emil_logs
${emil_path}    /cygdrive/c/Program Files/Emil
${file_list}    unknown
${local_dir}    ${OUTPUT_DIR}
${DU_OAM_IP}    192.168.255.129
${logname}    ZZ_lmp.pcap

#${TXT_FILE}    /home/ute/Downloads/ne_.txt
#${TXT_FILE}    /home/ute/Downloads/ne_.txt
*** Keywords ***

Setup WTS Esim Environment
    ${wts_version}=    Set Variable    Esim.260312.03_sandybridge  # Adapteaza versiunea Esim dorita
    ${wts_package}=    Set Variable    esimmode_WTS_${wts_version}.tar.bz2
    ${wts_dir}=        Set Variable    /opt/iphy/WTS_${wts_version}
    Run    mkdir -p ${wts_dir}
    Run    scp ute@10.5.20.75:/home/ute/Downloads/esimmode_WTS_${wts_version}.tar.bz2 ${wts_dir}
    Run    tar xvf ${wts_dir}/esimmode_WTS_${wts_version}.tar.bz2 -C ${wts_dir}
    Run    ln -sfn ${wts_dir} /opt/iphy/latest

Get Wireshark Value
    [Arguments]  ${cap_file}    ${FILTER_MSG}    ${FILTER_Sepcific}    ${field_name}=_3gpp.sfn
    ${filter}    set variable    (${FILTER_MSG})&&(${FILTER_Sepcific})
    ${cmd}    set variable    /usr/bin/tshark -r {pcap_file} -Y \"${filter}\" -T pdml
    pcap.load_pcap_file    command_template=${cmd}    pcap_file=${cap_file}
    ${field_value}=    pcap.get_field_value_by_name    field_name=${field_name}    attribute_name=show
    [Return]  ${field_value}

Check TraceIds
    [Arguments]    ${trace_list}    ${cap_file}=${OUTPUT_DIR}/${logname}    ${trace_type}=Cu
    [Documentation]    Check specifid trace exists.
    ...    :param  trace_type: The type of trace record data. It could be  Cu / Du / CuUp
    ${trace_ids}=    Get Wireshark Value    cap_file=${cap_file}
    ...    field_name=nsetapx.traceId
    ...    FILTER_MSG=ntrstr    FILTER_Sepcific=nsetapx.${trace_type}VendorExtensionRecordDataType
    FOR    ${trace_id}    IN    @{trace_list}
        should contain    ${trace_ids}    ${trace_id}
    END

Step2: Capture Log & Make L3 Call
    [Arguments]  ${twice_flag}=${false}
    log to console    Step2: Capture Log & Make L3 Call
    Start Wireshark Capture
    sleep    5s
    Make L3 Call    twice_flag=${twice_flag}
    Stop Wireshark Capture

Check msg in Control Plane logs
    [Arguments]    ${msg}
    ...            ${csv_path}=${OUTPUT_DIR}/5gm
	${result}		Parse_Emil_Csv_File_For_Message 	 ${csv_path}		${msg}
	Should Be True		${result}

Check msg in Cell Trace logs
    [Arguments]    ${msg}
    ...            ${csv_path}=${OUTPUT_DIR}/lcbin
	${result}		Parse_Emil_Csv_File_For_Message 	 ${csv_path}		${msg}
	Should Be True		${result}

Get Vm IP and Replace
    [Arguments]       ${delta_scf}       ${suite_path}
    ${source_ipv4}=  Run  ip a | grep eth0 -A 2 | grep -w inet | awk {'print $2'} | awk -F/ {'print $1'}
    Set Suite Variable  ${VM_IP}  ${source_ipv4}
    ${gnb_release}=    Get Enb Active Release Name
    Run  sed -i 's/vm_tceIpAddress/${VM_IP}/' ${suite_path}/config/${gnb_release}/${delta_scf}

Remove Vm IP from delta
    [Arguments]       ${delta_scf}       ${suite_path}
    ${gnb_release}=    Get Enb Active Release Name
    Run  sed -i 's/${VM_IP}/vm_tceIpAddress/' ${suite_path}/config/${gnb_release}/${delta_scf}

Get 5G Tracing Profiles
    [Arguments]    ${timeout}=30
    ${5g_profiles}=    rd.get_5g_profiles    timeout=${timeout}
    Log To Console    ${5g_profiles}
    [Return]   ${5g_profiles}

Start Xn And Ng Interfaces
    Start Vm Ethernet Interface    if_name=eth3:xn    ip_with_mask=10.0.1.101/24
    Start Vm Ethernet Interface    if_name=eth3:ng    ip_with_mask=10.0.1.102/24

Start Vm Ethernet Interfaces
    Start Vm Ethernet Interface    if_name=eth3:AMF2_NG_ADDR   ip_with_mask=10.0.1.3/24
    Start Vm Ethernet Interface    if_name=eth3:AMF3_NG_ADDR   ip_with_mask=10.0.1.4/24
    Start Vm Ethernet Interface    if_name=eth3:int1_XX_ADDR   ip_with_mask=10.0.1.106/24
    Start Vm Ethernet Interface    if_name=eth3:GNB_S1U_ADDR   ip_with_mask=10.0.1.112/24
    Start Vm Ethernet Interface    if_name=eth3:MME1_S1_ADDR   ip_with_mask=10.0.1.131/24
    Start Vm Ethernet Interface    if_name=eth3:SERVER_ADDR   ip_with_mask=10.0.1.132/24
    Start Vm Ethernet Interface    if_name=eth3:SGW_S1U_ADDR   ip_with_mask=10.0.1.133/24
    Start Vm Ethernet Interface    if_name=eth3:SGW_S11_ADDR   ip_with_mask=10.0.1.134/24
    Start Vm Ethernet Interface    if_name=eth3:ENB_X2U_ADDR   ip_with_mask=10.0.1.135/24
    Start Vm Ethernet Interface    if_name=eth3:ENB1_S1_ADDR   ip_with_mask=10.0.1.136/24
    Start Vm Ethernet Interface    if_name=eth3:ENB1_X2_ADDR   ip_with_mask=10.0.1.137/24

Stop Vm Ethernet Interfaces
    Stop Vm Ethernet Interface    if_name=eth3:AMF2_NG_ADDR   ip_with_mask=10.0.1.3/24
    Stop Vm Ethernet Interface    if_name=eth3:AMF3_NG_ADDR   ip_with_mask=10.0.1.4/24
    Stop Vm Ethernet Interface    if_name=eth3:int1_XX_ADDR   ip_with_mask=10.0.1.106/24
    Stop Vm Ethernet Interface    if_name=eth3:GNB_S1U_ADDR   ip_with_mask=10.0.1.112/24
    Stop Vm Ethernet Interface    if_name=eth3:MME1_S1_ADDR   ip_with_mask=10.0.1.131/24
    Stop Vm Ethernet Interface    if_name=eth3:SERVER_ADDR   ip_with_mask=10.0.1.132/24
    Stop Vm Ethernet Interface    if_name=eth3:SGW_S1U_ADDR   ip_with_mask=10.0.1.133/24
    Stop Vm Ethernet Interface    if_name=eth3:SGW_S11_ADDR   ip_with_mask=10.0.1.134/24
    Stop Vm Ethernet Interface    if_name=eth3:ENB_X2U_ADDR   ip_with_mask=10.0.1.135/24
    Stop Vm Ethernet Interface    if_name=eth3:ENB1_S1_ADDR   ip_with_mask=10.0.1.136/24
    Stop Vm Ethernet Interface    if_name=eth3:ENB1_X2_ADDR   ip_with_mask=10.0.1.137/24

Set AMF To Send CNAI IE In UE Initial Context Setup Request
    [Arguments]              ${command}= ${SET_AMF_TO_SEND_CNAI_IE_IN_UE_ICS_REQ_EGATE_CMD}
    Execute Egate Command    cmd=${command}
    sleep    1

Set AMF To Send CNAI IE In Path Switch Request
    Execute Egate Command    cmd=${SET_AMF_TO_SEND_CNAI_IE_IN_PATH_SW_REQ_EGATE_CMD}

Set AMF To Send CNAI IE In NG Handover Request
    Execute Egate Command    cmd=${SET_AMF_TO_SEND_CNAI_IE_IN_HO_REQ_EGATE_CMD}

Set AMF To Send CNAI IE in UE Context Modification Request
    Execute Egate Command    cmd=${SET_AMF_TO_SEND_CNAI_IE_IN_UE_CTX_MOD_REQ_EGATE_CMD}

Verify Traces For Successful Transition to RRC INACTIVE
    Verify Tcpdump Log    packet_filter=${RRC_RELEASE_WITH_SUSPEND}
    Verify Tcpdump Log    packet_filter=${E1AP_BEARER_CONTEXT_STATUS_CHANGE_SUSPEND}
    Verify Tcpdump Log    packet_filter=${E1AP_BEARER_CONTEXT_MODIFICATION_RESPONSE_TO_BEARER_CONTEXT_STATUS_CHANGE}
    Verify Tcpdump Log    packet_filter=${F1AP_UE_CONTEXT_RELEASE_REQUEST_WITH_RRC_RELEASE_WITH_SUSPEND}
    Verify Tcpdump Log    packet_filter=${F1AP_UE_CONTEXT_RELEASE_COMPLETE}

Verify Traces For RRCRelease After Unsuccessful Transition to RRC INACTIVE
    Verify Tcpdump Log    packet_filter=${RRC_RELEASE_WITHOUT_SUSPEND}
    Verify Tcpdump Log    packet_filter=${NGAP_UE_CONTEXT_RELEASE_REQUEST}
    Verify Tcpdump Log    packet_filter=${NGAP_UE_CONTEXT_RELEASE_COMMAND}

Attach Ue And Establish PDU Session And Wait For Release
    [Arguments]    ${ue_id}    ${gw_id}
    Attach Ue    ue_id=${ue_id}
    Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Establish Pdu Session    ue_id=${ue_id}    gw_id=${gw_id}
    Sleep  105s

Attach Ue And Establish PDU Session And Send ReleasePreference
    [Arguments]    ${ue_id}    ${gw_id}
    Attach Ue    ue_id=${ue_id}
    Establish Pdu Session    ue_id=${ue_id}    gw_id=${gw_id}
    Execute Egate Command    cmd=ue_assistance_send_nr ue_id=1 PreferredRRCState=inactive

Attach Ue And Establish PDU Session
    [Arguments]    ${ue_id}    ${gw_id}
    Attach Ue    ue_id=${ue_id}
    Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Establish Pdu Session    ue_id=${ue_id}    gw_id=${gw_id}

Attach Ue And Establish PDU Session And Wait For Inactive
    [Arguments]    ${ue_id}    ${gw_id}
    Attach Ue    ue_id=${ue_id}
    Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Establish Pdu Session    ue_id=${ue_id}    gw_id=${gw_id}
    Sleep  105s

Attach Ue And Start Subscriber Trace And Establish PDU Session And Wait For Inactive
    [Arguments]    ${ue_id}    ${gw_id}
    Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Attach Ue    ue_id=${ue_id}
    Execute Egate Command    cmd=${trace_start}
    Establish Pdu Session    ue_id=${ue_id}    gw_id=${gw_id}
    Sleep  105s

Resume And Establish PDU Session
    [Arguments]    ${ue_id}    ${pdu_id}
#    Attach Ue    ue_id=${ue_id}
#    Establish Pdu Session    ue_id=${ue_id}    gw_id=${gw_id}
    Execute Egate Command    cmd=ue_nr_rrc_resume_request_param id=1  msg=resume_request_1 cause=mo_Signalling  action=invalid_short_mac_i
	Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute Egate Command    cmd=ue_pdu_session_setup pdu=${pdu_id} ue=${ue_id}

#Set Parameters For UE RRC Resume Request
#    [Arguments]              ${ue_id}    ${gnb_id}    ${cell_nr}    ${msg}    ${cause}
#    Execute Egate Command    cmd=ue_nr_rrc_resume_request_param id=${ue_id} gnb=${gnb_id} cell=${cell_nr} msg=${msg} cause=${cause}

#Set Parameters For UE RRC Resume Request plmn
#    [Arguments]              ${ue_id}    ${gnb_id}    ${cell_nr}    ${msg}    ${plmn}    ${cause}
#    Execute Egate Command    cmd=ue_nr_rrc_resume_request_param id=${ue_id} gnb=${gnb_id} cell=${cell_nr} msg=${msg} plmn=${plmn} cause=${cause}

UE RRC Resume Request
    [Arguments]              ${ue_id}
    Execute Egate Command    cmd=ue_nr_rrc_resume id=${ue_id}

UE RRC Resume Request via UL NAS PDU
    [Arguments]              ${ue_id}
    Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=2 trf_type=internal
    Execute Egate Command    cmd=ue_pdu_session_setup pdu=2 ue=${ue_id}
Set AMF To Send CNAI IE In UE Initial Context Setup Request_D_E5
    [Arguments]              ${command}
    Execute Egate Command    cmd=${command}
    sleep    1

Set PDU Param Internal Traffic
    [Arguments]    ${ue_id}    ${pdu_id}=1
    Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal

#Set Parameters For UE RRC Resume Request With Action
#    [Arguments]              ${ue_id}    ${gnb_id}    ${cell_nr}    ${msg}    ${cause}    ${action}
#    Execute Egate Command    cmd=ue_nr_rrc_resume_request_param id=${ue_id} gnb=${gnb_id} cell=${cell_nr} msg=${msg}
#... cause=${cause} action=${action}

Ipcapture should contain Resume_Request List message
    [Arguments]      ${Message_List_string}
    log to console     Verifying ResumeRequest1 List messages in ipcapture
    ${status}=   run    command=sudo cat ${OUTPUT DIR}/ipcaptureExtracted/ipcapture_to_txt.txt | grep "${Message_List_string}"
    Should Contain   ${status}  ${Message_List_string}

Make twice L3CALL And Get ALL PCMD MSG
#    [Arguments]  ${command}=None   ${port}=${EMPTY}
    ${curr_date}   DateTime.Get Current Date   result_format=%Y%m%d_%H%M   exclude_millis=True
#    Start Tcpdump To Get PCMD   pcmd_file=TCPDUMP_${curr_date}.pcap   command=${command}
    # L3CALL Precondition
    # Wait Until Keyword Succeeds   3x   10s   Attach UE and Detach
    Execute Egate Command    cmd=set_pdu_param ue=1 pdu=1 trf_type=internal
#    Execute Egate Command    cmd=set_pdu_param ue=2 pdu=1 trf_type=internal
    Sleep    1s
    Execute Egate Command    cmd=ue_register id=1
#    Execute Egate Command    cmd=ue_register id=2
    Sleep    1s
    Execute Egate Command    cmd=ue_pdu_session_setup ue=1 pdu=1 nwslice=1 gw=1
    Sleep    1s
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=5
    Sleep    1s
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=ul mbps=3
    Sleep    2s
    Execute Egate Command    cmd=trf_data_stop ue=1 pdu=1
    Sleep    1s
    Execute Egate Command    cmd=ue_deregister id=1 by=ue ue_deregister_type=switch_off
#    Execute Egate Command    cmd=ue_deregister id=2 by=ue ue_deregister_type=switch_off
    Sleep    1s
    Execute Egate Command    cmd=set_pdu_param ue=1 pdu=1 trf_type=internal
    Sleep    1s
    Execute Egate Command    cmd=ue_register id=1
#    Execute Egate Command    cmd=ue_register id=2
    Sleep    1s
    Execute Egate Command    cmd=ue_pdu_session_setup ue=1 pdu=1 nwslice=1 gw=1
    Sleep    1s
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=5
    Sleep    1s
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=ul mbps=3
    Sleep    2s
    Execute Egate Command    cmd=trf_data_stop ue=1 pdu=1
    Sleep    1s
    Execute Egate Command    cmd=ue_deregister id=1 by=ue ue_deregister_type=switch_off
#    Execute Egate Command    cmd=ue_deregister id=2 by=ue ue_deregister_type=switch_off
    Sleep    1s
#    Run Keyword and Ignore Error   Run Keyword If   ${1756_L3CALL_status}   Wait Until Keyword Succeeds   2x   20s
#    ...   Call Setup and check tput   duration=60   tput=100   tput_expect=10   4G_check=false   port=${port}

#    Stop Tcpdump To Get PCMD   pcmd_file=TCPDUMP_${curr_date}.pcap
#    Set Suite Variable   ${TCPDUMP_PATH}   ${OUTPUT_DIR}/TCPDUMP_${curr_date}.pcap
EMIL_LAST_FILE
    ${emil_last_file}   DCAP.Get Latest Trace File Name By BTSID
    Set Suite Variable   ${emil_last_file}
#    ${file_list}   Get Newest Trace Files By BTSID   bts_id=1   latest_skip_file=${emil_last_file}   local_dir=${OUTPUT_DIR}
#    ${txt_file}   Covert Emil Logs to TXT   file_list=${file_list}   local_dir=${OUTPUT_DIR}
#    Set Suite Variable   ${TXT_FILE}
#    ${empty_msg_count}   check_empty_pcmd_msg   source_file=${txt_file}
#    Run Keyword If   ${empty_msg_count}>0   Log   PCMD EMPTY MSG COUNT: ${empty_msg_count}. Please Manual Check.   WARN
#    ${all_pcmd_msg}   get_all_pcmd_msgs   source_file=${txt_file}
#    Set Suite Variable   ${ALL_PCMD_MSG}

EMIL_NEWEST_FILE
    ${file_list}   DCAP.Get Newest Trace Files By BTSID
    Log to console    file_list este ${file_list}
    Set Suite Variable   ${file_list}
#    ${txt_file}   Covert Emil Logs to TXT   file_list=${file_list}   local_dir=${OUTPUT_DIR}
#    Set Suite Variable   ${TXT_FILE}
#    ${empty_msg_count}   check_empty_pcmd_msg   source_file=${txt_file}
#    Run Keyword If   ${empty_msg_count}>0   Log   PCMD EMPTY MSG COUNT: ${empty_msg_count}. Please Manual Check.   WARN
#    ${all_pcmd_msg}   get_all_pcmd_msgs   source_file=${txt_file}
#    Set Suite Variable   ${ALL_PCMD_MSG}

Covert Emil Logs to TXT1
    [Arguments]   ${local_dir}=${OUTPUT_DIR}   ${connection}=emil
    ${curr_date}   Get Current Date   result_format=%Y%m%d_%H%M   exclude_millis=True
    ${emil_list}   Create List
    Wait Until Keyword Succeeds   5m   20s   csn.Connect to
    ...   hostname=${emil_host}   username=${emil_user}   password=${emil_password}   alias=${connection}
    csn.Execute   command=rm -rf \"${emil_path}/get_emil.bat\"   connection=${connection}
    csn.Execute   command=mkdir -p ${emil_log_dir}   connection=${connection}
    ${emil_files}   Create List
    FOR    ${emil_file}    IN    @{file_list}
        ${file_name}=    Wait Until Keyword Succeeds    3x    10s
        ...    Convert Emil Log    emil_file=${emil_file}    connection=${connection}
        Append To List    ${emil_list}    ${file_name}
    END
    ${emil_list_str}   Evaluate   ' '.join(${emil_list})
    Run Keyword If   ${emil_list}   csn.Execute   cat ${emil_list_str} > ${emil_log_dir}/Emil_${curr_date}.txt
    ...   connection=${connection}
    ...   ELSE   Create File   ${local_dir}/Emil_${curr_date}.txt
    Run Keyword If   ${emil_list}   csn.Download File   remote_path=${emil_log_dir}/Emil_${curr_date}.txt
    ...   local_path=${local_dir}/Emil_${curr_date}.txt   connection=${connection}
    ${txt_file}=   Set Variable  ${local_dir}/Emil_${curr_date}.txt
    Set Suite Variable   ${txt_file}
    ${all_pcmd_msg}   get_all_pcmd_msgs   source_file=${txt_file}
    Set Suite Variable   ${ALL_PCMD_MSG}
    [Return]   ${txt_file}
    [Teardown]   csn.Disconnect   connection=${connection}


Common suite setup HZ
#    ${1756_L3CALL_status}    Run Keyword And Return Status    Make L3CALL And Get ALL PCMD MSG
    Set Suite Variable    ${1756_L3CALL_status}    False
    ${1756_timestamp_status}    ${all_pcmd_timestamp}   Run Keyword and ignore error    get_all_pcmd_timestamp   source_file=${TXT_FILE}
    Set Suite Variable    ${1756_timestamp_status}
    Set Suite Variable   ${ALL_PCMD_TIMESTAMP}
#    ${Reset_Reason}   Get Last Reset from Blackbox
#    Set Suite Variable   ${RESET_REASON}

check mess in tcpdump
    Verify Tcpdump Log       packet_filter=${trace_Nsetupx}

Syslog Capture Start
    [Arguments]   ${name}=btslog
    ...           ${bts_logs_dir}=/tmp/btslog2
    log to console    syslog_start
    __Make empty BTS logs dir      ${bts_logs_dir}
    btslog.create_btslog_collector
    ...    name=${name}
    ...    log_dir=${bts_logs_dir}
    core.setup_collectors        names=${name}
    core.start_collectors        names=${name}
    btslog.set_suite_alias       ${name}

Syslog Capture Stop and Collect
    [Arguments]  ${bts_logs_dir}=/tmp/btslog2
    log to console    syslog_stop
    run keyword and ignore error    __Stop and collect btslog on local machine
    __Copy btslog to logs dir and clean BTSlog workspace    ${bts_logs_dir}

__Stop and collect btslog on local machine
    [Arguments]   ${name}=btslog
    core.stop_collectors         names=${name}
    core.collect_collectors      names=${name}
    core.teardown_collectors     names=${name}
    Run  rm -rf ${OUTPUTDIR}/5GC*

__Copy btslog to logs dir and clean BTSlog workspace
    [Arguments]     ${bts_logs_dir}=/tmp/btslog2
    Run   mkdir ${LOG_PATH}
    Run   if [ ! -d ${LOG_PATH}/${TESTNAME} ]; then mkdir ${LOG_PATH}/${TESTNAME}; else rm ${LOG_PATH}/${TESTNAME}/*; fi
#    Run   cat ${bts_logs_dir}/*.LOG > ${bts_logs_dir}/SYSLOG.LOG
    Run   cp ${bts_logs_dir}/SYSLOG*.LOG ${LOG_PATH}/${TESTNAME}/
    Run   rm -rf ${OUTPUTDIR}/5GC*

__Make empty BTS logs dir
    [Arguments]     ${bts_logs_dir}=/tmp/btslog2
    Run  if [ ! -d ${bts_logs_dir} ]; then mkdir ${bts_logs_dir}; else rm ${bts_logs_dir}/*; fi


