*** Settings ***
#Resource    ../../resources/5G_SW_WRO_Keywords.robot
#Resource    ../../resources/dcap.robot
#Library     ../../resources/python/dcap.py

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

*** Variables ***
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
#${RRC_RELEASE_WITH_SUSPEND}=    ${RRC_RELEASE} && nr-rrc.suspendConfig_element
#${RRC_RELEASE_WITHOUT_SUSPEND}=    ${RRC_RELEASE} && !(nr-rrc.suspendConfig_element)
#${E1AP_BEARER_CONTEXT_STATUS_CHANGE_SUSPEND}=    ${E1AP_BEARER_CONTEXT_MODIFICATION_REQUEST} && e1ap.BearerContextStatusChange == 0
#${E1AP_BEARER_CONTEXT_MODIFICATION_RESPONSE_TO_BEARER_CONTEXT_STATUS_CHANGE}=    ${E1AP_BEARER_CONTEXT_MODIFICATION_RESPONSE}
#...                                                                              && !(e1ap.System_BearerContextModificationResponse)
#${F1AP_UE_CONTEXT_RELEASE_REQUEST_WITH_RRC_RELEASE_WITH_SUSPEND}=    ${F1AP_UE_CONTEXT_RELEASE_COMMAND}
#...                                                                  && f1ap.radioNetwork == 10 && nr-rrc.c1 == 2
${SET_AMF_TO_SEND_CNAI_IE_IN_UE_ICS_REQ_EGATE_CMD_MNC_489_UE2}=    amf_ue_ics_param id=1 ue=2 core_network_assistance_info=on
...                                                                ue_identity_index_value=2 ue_specific_drx=64
...                                                                periodic_registration_update_timer=1:10min plmn_id=311:489 tac_id=100
${SET_AMF_TO_SEND_CNAI_IE_IN_UE_ICS_REQ_EGATE_CMD_MNC_489_UE5}=    amf_ue_ics_param id=1 ue=5 core_network_assistance_info=on
...                                                                ue_identity_index_value=1 ue_specific_drx=256
...                                                                periodic_registration_update_timer=1:10min plmn_id=311:489 tac_id=200
*** Keywords ***
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

Stop Vm Ethernet Interfaces
    Stop Vm Ethernet Interface    if_name=eth3:AMF2_NG_ADDR   ip_with_mask=10.0.1.3/24
    Stop Vm Ethernet Interface    if_name=eth3:AMF3_NG_ADDR   ip_with_mask=10.0.1.4/24

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

#Verify Traces For Successful Transition to RRC INACTIVE
#    Verify Tcpdump Log    packet_filter=${RRC_RELEASE_WITH_SUSPEND}
#    Verify Tcpdump Log    packet_filter=${E1AP_BEARER_CONTEXT_STATUS_CHANGE_SUSPEND}
#    Verify Tcpdump Log    packet_filter=${E1AP_BEARER_CONTEXT_MODIFICATION_RESPONSE_TO_BEARER_CONTEXT_STATUS_CHANGE}
#    Verify Tcpdump Log    packet_filter=${F1AP_UE_CONTEXT_RELEASE_REQUEST_WITH_RRC_RELEASE_WITH_SUSPEND}
#    Verify Tcpdump Log    packet_filter=${F1AP_UE_CONTEXT_RELEASE_COMPLETE}

#Verify Traces For RRCRelease After Unsuccessful Transition to RRC INACTIVE
#    Verify Tcpdump Log    packet_filter=${RRC_RELEASE_WITHOUT_SUSPEND}
#    Verify Tcpdump Log    packet_filter=${NGAP_UE_CONTEXT_RELEASE_REQUEST}
#    Verify Tcpdump Log    packet_filter=${NGAP_UE_CONTEXT_RELEASE_COMMAND}

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

Set Parameters For UE RRC Resume Request
    [Arguments]              ${ue_id}    ${gnb_id}    ${cell_nr}    ${msg}    ${cause}
    Execute Egate Command    cmd=ue_nr_rrc_resume_request_param id=${ue_id} gnb=${gnb_id} cell=${cell_nr} msg=${msg} cause=${cause}

Set Parameters For UE RRC Resume Request plmn
    [Arguments]              ${ue_id}    ${gnb_id}    ${cell_nr}    ${msg}    ${plmn}    ${cause}
    Execute Egate Command    cmd=ue_nr_rrc_resume_request_param id=${ue_id} gnb=${gnb_id} cell=${cell_nr} msg=${msg} plmn=${plmn} cause=${cause}

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

Set Parameters For UE RRC Resume Request With Action
    [Arguments]              ${ue_id}    ${gnb_id}    ${cell_nr}    ${msg}    ${cause}    ${action}
    Execute Egate Command    cmd=ue_nr_rrc_resume_request_param id=${ue_id} gnb=${gnb_id} cell=${cell_nr} msg=${msg}
... cause=${cause} action=${action}

Ipcapture should contain Resume_Request List message
    [Arguments]      ${Message_List_string}
    log to console     Verifying ResumeRequest1 List messages in ipcapture
    ${status}=   run    command=sudo cat ${OUTPUT DIR}/ipcaptureExtracted/ipcapture_to_txt.txt | grep "${Message_List_string}"
    Should Contain   ${status}  ${Message_List_string}
