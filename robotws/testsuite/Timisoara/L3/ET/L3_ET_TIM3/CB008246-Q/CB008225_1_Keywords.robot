*** Settings ***
Resource    ../resources/5G_SW_WRO_Keywords.robot
Library    ta5g_iphy
Library    ta5g_enb
Library    ta5g_delta
Library    ta5g_pm_counters
Library    ta5g_throughput

*** Variables ***
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
${SET_AMF_TO_SEND_CNAI_IE_IN_UE_ICS_REQ_EGATE_CMD_MNC_489}=    amf_ue_ics_param id=1 core_network_assistance_info=on
...                                                            ue_identity_index_value=1 ue_specific_drx=64
...                                                            periodic_registration_update_timer=1:10min plmn_id=311:489 tac_id=100
#${SET_AMF_TO_SEND_CNAI_IE_IN_UE_ICS_REQ_EGATE_CMD_MNC_489_UE2}=    amf_ue_ics_param id=1 ue=2 core_network_assistance_info=on
...                                                                ue_identity_index_value=2 ue_specific_drx=64
...                                                                periodic_registration_update_timer=1:10min plmn_id=311:489 tac_id=100
${SET_AMF_TO_SEND_CNAI_IE_IN_UE_ICS_REQ_EGATE_CMD_MNC_489_UE22}=    amf_ue_ics_param id=1 ue=22 core_network_assistance_info=on
...                                                                 ue_identity_index_value=22 ue_specific_drx=64
...                                                                 periodic_registration_update_timer=1:10min plmn_id=311:489 tac_id=100
${SET_AMF_TO_SEND_CNAI_IE_IN_UE_ICS_REQ_EGATE_CMD_MNC_492}=    amf_ue_ics_param id=2 ue=6 core_network_assistance_info=on ue_identity_index_value=6
...                                                            ue_specific_drx=64 periodic_registration_update_timer=1:10min plmn_id=311:492
...                                                            tac_id=200
${SET_AMF_TO_SEND_CNAI_IE_IN_UE_ICS_REQ_EGATE_CMD_MNC_495}=    amf_ue_ics_param id=3 ue=9 core_network_assistance_info=on ue_identity_index_value=9
...                                                            ue_specific_drx=64 periodic_registration_update_timer=1:10min plmn_id=311:495
...                                                            tac_id=258
${SET_AMF_TO_SEND_CNAI_IE_IN_PATH_SW_REQ_EGATE_CMD}=    amf_ue_path_switch_param  id=1 core_network_assistance_info=on ue_identity_index_value=1
...                                                     ue_specific_drx=64 periodic_registration_update_timer=1:10min plmn_id=311:489 tac_id=200
${SET_AMF_TO_SEND_CNAI_IE_IN_HO_REQ_EGATE_CMD}=    amf_ue_ng_handover_request_param id=1 core_network_assistance_info=on ue_identity_index_value=1
...                                                ue_specific_drx=64 periodic_registration_update_timer=1:10min plmn_id=311:489 tac_id=200
${SET_AMF_TO_SEND_CNAI_IE_IN_UE_CTX_MOD_REQ_EGATE_CMD}=    amf_ue_ctx_modify_param id=1 core_network_assistance_info=on ue_identity_index_value=1
...                                                        ue_specific_drx=64 periodic_registration_update_timer=1:10min plmn_id=311:489 tac_id=200

${RRC_RELEASE_WITH_SUSPEND_WITH_T380}=    ${RRC_RELEASE} && nr-rrc.suspendConfig_element && nr-rrc.t380 == 0
${RRC_RELEASE_WITH_SUSPEND}=    ${RRC_RELEASE} && nr-rrc.suspendConfig_element
${RRC_RELEASE_WITHOUT_SUSPEND}=    ${RRC_RELEASE} && !(nr-rrc.suspendConfig_element)
${E1AP_BEARER_CONTEXT_STATUS_CHANGE_SUSPEND}=    ${E1AP_BEARER_CONTEXT_MODIFICATION_REQUEST} && e1ap.BearerContextStatusChange == 0
${E1AP_BEARER_CONTEXT_MODIFICATION_RESPONSE_TO_BEARER_CONTEXT_STATUS_CHANGE}=    ${E1AP_BEARER_CONTEXT_MODIFICATION_RESPONSE}
...                                                                              && !(e1ap.System_BearerContextModificationResponse)
${F1AP_UE_CONTEXT_RELEASE_REQUEST_WITH_RRC_RELEASE_WITH_SUSPEND}=    ${F1AP_UE_CONTEXT_RELEASE_COMMAND}
...                                                                  && f1ap.radioNetwork == 10 && nr-rrc.c1 == 2
#${RRC_RELEASE_PREFERENCE_R16}=    ${UE_CAPABILITY_INFORMATION} && nr-rrc.releasePreference_r16 == 0
${NGAP_INITIAL_CONTEXT_SETUP_REQUEST_WITH_CNAI}=    ${NGAP_INITIAL_CONTEXT_SETUP_REQUEST} && ngap.CoreNetworkAssistanceInformationForInactive_element
${F1AP_UL_RRC_MESSAGE_TRANSFER_WITH_RRC_RESUME_REQUEST_1_RNA_UPDATE}=    ${F1AP_INITIAL_UL_RRC_MESSAGE_TRANSFER}
...                                                                      && nr-rrc.c1 == 0 && nr-rrc.resumeCause == 8
#${RRC_RESUME_REQUEST_1_CAUSE_RNA_UPDATE}=    ${RRC_RESUME_REQUEST_1} && nr-rrc.resumeCause == 8
#${RRC_RESUME_WITH_RADIO_BEARER_CONFIG}=    ${RRC_RESUME} && nr-rrc.c1 == 1 && nr-rrc.radioBearerConfig_element
${NR_RRC_SETUP_COMPLETE}=    ${RRC_SETUP_COMPLETE} && !(nas_5gs.mm.message_type == 0x41)
${F1AP_DL_RRC_MESSAGE_TRANSFER_WITH_RRC_SETUP_CELL2}=    ${F1AP_DL_RRC_MESSAGE_TRANSFER} && nr-rrc.rrcSetup_element && nr-rrc.scramblingID0 == 51
${NGAP_INITIAL_UE_MESSAGE_WITH_NR_CELL_ID}=    ${NGAP_INITIAL_UE_MESSAGE} && ngap.NRCellIdentity == 0x0000004002
${F1AP_INITIAL_UL_RRC_MESSAGE_TRANSFER_WITH_RRC_RESUME_REQUEST}=    ${F1AP_INITIAL_UL_RRC_MESSAGE_TRANSFER} && nr-rrc.rrcResumeRequest_element
${F1AP_INITIAL_UL_RRC_MESSAGE_TRANSFER_WITH_RRC_RESUME_REQUEST_1}=    ${F1AP_INITIAL_UL_RRC_MESSAGE_TRANSFER} && nr-rrc.rrcResumeRequest1_element
${F1AP_DL_RRC_MESSAGE_TRANSFER_WITH_RRC_SETUP}=    ${F1AP_DL_RRC_MESSAGE_TRANSFER} && nr-rrc.rrcSetup_element
${F1AP_UL_RRC_MESSAGE_TRANSFER_WITH_RRC_SETUP_COMPLETE}=    ${F1AP_UL_RRC_MESSAGE_TRANSFER} && nr-rrc.rrcSetupComplete_element
${F1AP_UL_RRC_MESSAGE_TRANSFER_WITH_RRC_RESUME_COMPLETE}=    ${F1AP_UL_RRC_MESSAGE_TRANSFER} && nr-rrc.rrcResumeComplete_element
${F1AP_INITIAL_UL_RRC_MESSAGE_TRANSFER_WITH_RRCRESUMEREQ1_MT_ACCESS}=    ${F1AP_INITIAL_UL_RRC_MESSAGE_TRANSFER} && nr-rrc.rrcResumeRequest1_element
...                                                                      && nr-rrc.resumeCause == 2
${E1AP_BEARER_CONTEXT_MODIFICATION_REQ}=    ${E1AP_BEARER_CONTEXT_MODIFICATION_REQUEST} && e1ap.BearerContextStatusChange == 1
${E1AP_BEARER_CONTEXT_MODIFICATION_RESP}=    ${E1AP_BEARER_CONTEXT_MODIFICATION_RESPONSE} && e1ap.dRB_Modified_List_NG_RAN == 1
${RRC_SETUP_CELL2}=    ${RRC_SETUP} && nr-rrc.scramblingID0 == 51
${E1AP_RESET_WITH_RADIO_NETWORK}=    ${E1AP_RESET} && e1ap.radioNetwork == 20
${SET_AMF_TO_SEND_CNAI_IE_IN_UE_ICS_REQ_EGATE_CMD_MNC_489_UE1_CE2}=    amf_ue_ics_param id=1 ue=1
...                                                                    core_network_assistance_info=on ue_identity_index_value=1
...                                                                    ue_specific_drx=64 periodic_registration_update_timer=5:1min
...                                                                    plmn_id=311:489 tac_id=200
${UE_Register}=    ue_register id=1
${SIM_TTI_Set}=    sim_param_set TTI=2
${UE_PDU_Session_Setup}=    ue_pdu_session_setup pdu=1 ue=1 gw=1
${AMF_UE_PDU_Setup_Param}=    amf_ue_pdu_setup_param id=1 ue=1 pdu=2 action=delay time_to_wait=2m outer_NAS_PDU_type=configuration_update_command
${UE_Param_Ignore_Paging}=    ue_param id=1 ignore_paging=on
${PDU_Session_setup2}=    ue_pdu_session_setup pdu=2 ue=1  gw=2
${SET_AMF_TO_SEND_CNAI_IE_IN_UE_ICS_REQ_EGATE_CMD_MNC_489_UE1}=    amf_ue_ics_param id=1 ue=1 core_network_assistance_info=on
...                                                                ue_identity_index_value=1 ue_specific_drx=64
...                                                                periodic_registration_update_timer=1:10min plmn_id=311:489 tac_id=200
${SET_AMF_TO_SEND_CNAI_IE_IN_UE_ICS_REQ_EGATE_CMD_MNC_489_UE2}=    amf_ue_ics_param id=1 ue=2 core_network_assistance_info=on
...                                                                ue_identity_index_value=1 ue_specific_drx=64
...                                                                periodic_registration_update_timer=1:10min plmn_id=311:489 tac_id=200
${SET_AMF_TO_SEND_CNAI_IE_IN_UE_ICS_REQ_EGATE_CMD_MNC_489_UE3}=    amf_ue_ics_param id=1 ue=3 core_network_assistance_info=on
...                                                                ue_identity_index_value=1 ue_specific_drx=64
...                                                                periodic_registration_update_timer=1:10min plmn_id=311:489 tac_id=200
${INITIALRRC_RRCRESUMEREQ1}=    ${F1AP_INITIAL_UL_RRC_MESSAGE_TRANSFER} && f1ap.RRCContainer && nr-rrc.c1 == 0 && nr-rrc.resumeCause == 2
${INITIALRRC_RRCRESUMEREQ1_MO_SIGNALLING}=    ${F1AP_INITIAL_UL_RRC_MESSAGE_TRANSFER} && f1ap.RRCContainer && nr-rrc.c1 == 0
...                                           && nr-rrc.resumeCause == 3
${E1AP_BEARERCONTEXTMODREQ}=    ${E1AP_BEARER_CONTEXT_MODIFICATION_REQUEST} && e1ap.BearerContextStatusChange == 1
...                             && e1ap.dRB_To_Modify_List_NG_RAN == 1 && e1ap.DRB_To_Modify_Item_NG_RAN_element && e1ap.dRB_ID == 4
${E1AP_BEARERCONTEXTMODREQ_2PDU}=    ${E1AP_BEARER_CONTEXT_MODIFICATION_REQUEST} && e1ap.BearerContextStatusChange == 1
...                                  && e1ap.dRB_To_Modify_List_NG_RAN == 1 && e1ap.DRB_To_Modify_Item_NG_RAN_element && e1ap.dRB_ID == 4
...                                  && e1ap.dRB_ID == 5
${E1AP_BEARERCONTEXTMODRES}=    ${E1AP_BEARER_CONTEXT_MODIFICATION_RESPONSE} && e1ap.dRB_Modified_List_NG_RAN == 1
...                             && e1ap.DRB_Modified_Item_NG_RAN_element && e1ap.dRB_ID == 4
${E1AP_BEARERCONTEXTMODRES_2PDU}=    ${E1AP_BEARER_CONTEXT_MODIFICATION_RESPONSE} && e1ap.dRB_Modified_List_NG_RAN == 1
...                                  && e1ap.DRB_Modified_Item_NG_RAN_element && e1ap.dRB_ID == 4
...                                  && e1ap.dRB_ID == 5
#${RRC_RESUME_DB1}=    ${RRC_RESUME} && nr-rrc.c1 == 1 && nr-rrc.radioBearerConfig_element && nr-rrc.masterCellGroup
...                   && nr-rrc.measConfig_element && nr-rrc.fullConfig == 0 && nr-rrc.drb_Identity == 4 && nr-rrc.drb_Identity == 5
#${RRC_RESUME_WITH_RADIO_BEARER_CONFIG_CB2}=    ${RRC_RESUME} && nr-rrc.c1 == 1 && nr-rrc.radioBearerConfig_element && nr-rrc.masterCellGroup
...                                            && nr-rrc.measConfig_element && nr-rrc.fullConfig == 0
${F1AP_PDU_SESSION_MODIFICATION_COMPLETE}=    ${F1AP_UL_RRC_MESSAGE_TRANSFER} && nas_5gs.sm.message_type == 0xcc
${NGAP_PDU_SESSION_MODIFICATION_COMPLETE}=    ${NGAP_UPLINK_NAS_TRANSPORT} && nas_5gs.sm.message_type == 0xcc

*** Keywords ***
Start Vm Ethernet Interfaces
    Start Vm Ethernet Interface    if_name=eth3:AMF2_NG_ADDR   ip_with_mask=10.0.1.3/24
    Start Vm Ethernet Interface    if_name=eth3:AMF3_NG_ADDR   ip_with_mask=10.0.1.4/24

Stop Vm Ethernet Interfaces
    Stop Vm Ethernet Interface    if_name=eth3:AMF2_NG_ADDR   ip_with_mask=10.0.1.3/24
    Stop Vm Ethernet Interface    if_name=eth3:AMF3_NG_ADDR   ip_with_mask=10.0.1.4/24

Set AMF To Send CNAI IE In UE Initial Context Setup Request
    [Arguments]              ${command}
    Execute Egate Command    cmd=${command}
    Sleep    1

Set AMF To Send CNAI IE In Path Switch Request
    Execute Egate Command    cmd=${SET_AMF_TO_SEND_CNAI_IE_IN_PATH_SW_REQ_EGATE_CMD}

Set AMF To Send CNAI IE In NG Handover Request
    Execute Egate Command    cmd=${SET_AMF_TO_SEND_CNAI_IE_IN_HO_REQ_EGATE_CMD}

Set AMF To Send CNAI IE In UE Context Modification Request
    Execute Egate Command    cmd=${SET_AMF_TO_SEND_CNAI_IE_IN_UE_CTX_MOD_REQ_EGATE_CMD}

Start Data Traffic For All PDUs
    Sleep    3s
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=3 dir=dl mbps=50
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=2 qfi=3 dir=dl mbps=50
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=3 qfi=1 dir=dl mbps=50

Start Data Traffic For 1 PDU
    [Arguments]              ${ue_id}=1
    Sleep    3s
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${ue_id} qfi=3 dir=dl mbps=5

Stop Data Traffic For 1 PDU
    [Arguments]              ${ue_id}=1
    Execute Egate Command    cmd=trf_data_stop ue=${ue_id} pdu=${ue_id} qfi=3

Stop Data Traffic For All PDUs
    Execute Egate Command    cmd=trf_data_stop ue=1 pdu=1 qfi=3
    Execute Egate Command    cmd=trf_data_stop ue=1 pdu=2 qfi=3
    Execute Egate Command    cmd=trf_data_stop ue=1 pdu=3 qfi=1

Verify Traces For Succesful Transition To RRC CONNECTED Mo Signalling
    Verify Tcpdump Log    packet_filter=${INITIALRRC_RRCRESUMEREQ1_MO_SIGNALLING}
    Verify Tcpdump Log    packet_filter=${E1AP_BEARERCONTEXTMODREQ_2PDU}
    Verify Tcpdump Log    packet_filter=${E1AP_BEARERCONTEXTMODRES_2PDU}
#    Verify Uu Messages    packet_filter=${RRC_RESUME_DB1}
    Verify Uu Messages    packet_filter=${RRC_RESUME_COMPLETE}

Verify PDU Bearer Stats
    Check Bearer Stats    ue_id=1    pdu_id=1    qfi_id=3    dir=dl    pass_regexp=50
    Sleep    1s
    Check Bearer Stats    ue_id=1    pdu_id=2    qfi_id=3    dir=dl    pass_regexp=50
    Sleep    1s
    Check Bearer Stats    ue_id=1    pdu_id=3    qfi_id=1    dir=dl    pass_regexp=50

Check Bearer Stats
    [Arguments]              ${ue_id}=1    ${pdu_id}=1    ${qfi_id}=1    ${dir}=dl    ${pass_regexp}=50
    Execute Egate Command    cmd=bearer_stats ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=${dir}    pass_regexp=\(${pass_regexp}\.\\d M\)

Start Data Traffic And Check Bearer Stats
    [Arguments]              ${ue_id}=1    ${pdu_id}=1    ${qfi_id}=1    ${dir}=dl    ${throughput}=30
    Sleep    1s
    Start Data Traffic    ues=${ue_id}    pdu=${pdu_id}    direction=${dir}    throughput=${throughput}mbps
    Sleep    1s
    Check Bearer Stats    ue_id=${ue_id}    pdu_id=${pdu_id}    qfi_id=${qfi_id}    dir=${dir}    pass_regexp=${throughput}
    Sleep    1s

Verify Traces For Succesful Transition to RRC CONNECTED By MT Access
    Verify Tcpdump Log    packet_filter=${F1AP_INITIAL_UL_RRC_MESSAGE_TRANSFER_WITH_RRCRESUMEREQ1_MT_ACCESS}
    Verify Tcpdump Log    packet_filter=${E1AP_BEARER_CONTEXT_MODIFICATION_REQ}
    Verify Tcpdump Log    packet_filter=${E1AP_BEARER_CONTEXT_MODIFICATION_RESP}    number_of_messages=2
    Verify Tcpdump Log    packet_filter=${F1AP_UE_CONTEXT_SETUP_REQUEST}    number_of_messages=2
    Verify Tcpdump Log    packet_filter=${F1AP_UL_RRC_MESSAGE_TRANSFER_WITH_RRC_RESUME_COMPLETE}
#    Verify Uu Messages    packet_filter=${RRC_RESUME_WITH_RADIO_BEARER_CONFIG}
#    Verify Uu Messages    packet_filter=${RRC_RESUME_REQUEST_1}
    Verify Uu Messages    packet_filter=${RRC_RESUME_COMPLETE}

Verify Traces For Successful PDU Modification and Transititon to RRC CONNECTED
    Verify Tcpdump Log    packet_filter=${NGAP_PDU_SESSION_RESOURCE_MODIFY_REQUEST}
    Verify Tcpdump Log    packet_filter=${F1AP_PAGING}
#    Verify Tcpdump Log    packet_filter=${RRC_RESUME_REQUEST_1}
    Verify Tcpdump Log    packet_filter=${INITIALRRC_RRCRESUMEREQ1}
    Verify Tcpdump Log    packet_filter=${E1AP_BEARERCONTEXTMODREQ}
    Verify Tcpdump Log    packet_filter=${E1AP_BEARERCONTEXTMODRES}    number_of_messages=2
#    Verify Uu Messages    packet_filter=${RRC_RESUME_WITH_RADIO_BEARER_CONFIG_CB2}
    Verify Uu Messages    packet_filter=${RRC_RESUME_COMPLETE}
    Verify Tcpdump Log    packet_filter=${F1AP_PDU_SESSION_MODIFICATION_COMPLETE}
    Verify Tcpdump Log    packet_filter=${NGAP_PDU_SESSION_RESOURCE_MODIFY_RESPONSE}
    Verify Tcpdump Log    packet_filter=${NGAP_PDU_SESSION_MODIFICATION_COMPLETE}

Verify Traces For Successful Transition To RRC INACTIVE
    Verify Uu Messages    packet_filter=${RRC_RELEASE_WITH_SUSPEND}
#    Verify Tcpdump Log    packet_filter=${NGAP_INITIAL_CONTEXT_SETUP_REQUEST_WITH_CNAI}
#    Verify Tcpdump Log    packet_filter=${E1AP_BEARER_CONTEXT_STATUS_CHANGE_SUSPEND}
#    Verify Tcpdump Log    packet_filter=${E1AP_BEARER_CONTEXT_MODIFICATION_RESPONSE_TO_BEARER_CONTEXT_STATUS_CHANGE}
#    Verify Tcpdump Log    packet_filter=${F1AP_UE_CONTEXT_RELEASE_REQUEST_WITH_RRC_RELEASE_WITH_SUSPEND}
#    Verify Tcpdump Log    packet_filter=${F1AP_UE_CONTEXT_RELEASE_COMPLETE}

Verify Traces For Successful RNA Update
    Verify Uu Messages    packet_filter=${RRC_RELEASE_WITH_SUSPEND}    number_of_messages=2
    Verify Tcpdump Log    packet_filter=${F1AP_UL_RRC_MESSAGE_TRANSFER_WITH_RRC_RESUME_REQUEST_1_RNA_UPDATE}
    Verify Tcpdump Log    packet_filter=${F1AP_UE_CONTEXT_RELEASE_REQUEST_WITH_RRC_RELEASE_WITH_SUSPEND}    number_of_messages=2
    Verify Tcpdump Log    packet_filter=${F1AP_UE_CONTEXT_RELEASE_COMPLETE}    number_of_messages=2

Verify Traces For RRCRelease After Unsuccessful Transition To RRC INACTIVE
    Verify Tcpdump Log    packet_filter=${RRC_RELEASE_WITHOUT_SUSPEND}
    Verify Tcpdump Log    packet_filter=${NGAP_UE_CONTEXT_RELEASE_REQUEST}
    Verify Tcpdump Log    packet_filter=${NGAP_UE_CONTEXT_RELEASE_COMMAND}

Wait For RRC RELEASE WITH SUSPEND UE
    Verify Uu Messages    packet_filter=${RRC_RELEASE_WITH_SUSPEND}   timeout=65

Wait For Release For No CoreNetworkAssistanceInformation UE
    Verify Uu Messages    packet_filter=${RRC_RELEASE}   timeout=65

Wait For Release
    Verify Uu Messages    packet_filter=${RRC_RELEASE}   timeout=95

Establish PDU Session And Wait For INACTIVE
    [Arguments]    ${ue_id}    ${gw_id}
    Establish PDU Session    ue_id=${ue_id}    gw_id=${gw_id}
    Wait For RRC RELEASE WITH SUSPEND UE

Attach UE And Establish PDU Session And Wait For Release
    [Arguments]    ${ue_id}    ${gw_id}
    Attach UE    ue_id=${ue_id}
    Establish PDU Session    ue_id=${ue_id}    gw_id=${gw_id}
    Wait For Release For No CoreNetworkAssistanceInformation UE

Attach UE And Establish PDU Session And Wait For INACTIVE
    [Arguments]    ${ue_id}    ${gw_id}
    Attach UE    ue_id=${ue_id}
    Establish PDU Session    ue_id=${ue_id}    gw_id=${gw_id}
    Wait For RRC RELEASE WITH SUSPEND UE

Attach UE And Establish PDU Session
    [Arguments]    ${ue_id}    ${gw_id}
    Attach UE    ue_id=${ue_id}
    Establish PDU Session    ue_id=${ue_id}    gw_id=${gw_id}


Attach UE And Establish Multipe PDU Session And Wait For Release
    [Arguments]    ${ue_id}    ${gw_id1}    ${gw_id2}    ${pdu_id1}    ${pdu_id2}
    Attach UE    ue_id=${ue_id}
    Establish PDU Session    ue_id=${ue_id}    gw_id=${gw_id1}    pdu_id=${pdu_id1}
    Establish PDU Session    ue_id=${ue_id}    gw_id=${gw_id2}    pdu_id=${pdu_id2}
    Sleep    1s
    Wait For Release

Attach UE And Establish PDU Session And Send ReleasePreference
    [Arguments]    ${ue_id}    ${gw_id}
    Attach UE    ue_id=${ue_id}
    Establish PDU Session    ue_id=${ue_id}    gw_id=${gw_id}
    Execute Egate Command    cmd=ue_assistance_send_nr ue_id=${ue_id} PreferredRRCState=inactive   pass_regexp=UE.: Is INACTIVE
    Verify Uu Messages    packet_filter=${RRC_RELEASE_WITH_SUSPEND_WITH_t380}   timeout=4
#    Verify Uu Messages    packet_filter=${RRC_RELEASE_PREFERENCE_R16}

Set Parameters For UE RRC Resume Request
    [Arguments]              ${ue_id}    ${gnb_id}    ${cell_nr}    ${msg}    ${cause}
    Execute Egate Command    cmd=ue_nr_rrc_resume_request_param id=${ue_id} gnb=${gnb_id} cell=${cell_nr} msg=${msg} cause=${cause}

Set Parameters For UE RRC Resume Request With Action
    [Arguments]              ${ue_id}    ${gnb_id}    ${cell_nr}    ${msg}    ${cause}    ${action}
    Execute Egate Command    cmd=ue_nr_rrc_resume_request_param id=${ue_id} gnb=${gnb_id} cell=${cell_nr} msg=${msg} cause=${cause} action=${action}

Set PDU Param Internal Traffic
    [Arguments]    ${ue_id}    ${pdu_id}
    Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal

UE RRC Resume Request
    [Arguments]              ${ue_id}
    Execute Egate Command    cmd=ue_nr_rrc_resume id=${ue_id}

Verify Traces For RRC CONNECTED After Resuming UE
    Verify Tcpdump Log    packet_filter=${F1AP_INITIAL_UL_RRC_MESSAGE_TRANSFER_WITH_RRC_RESUME_REQUEST}
    Verify Tcpdump Log    packet_filter=${F1AP_DL_RRC_MESSAGE_TRANSFER_WITH_RRC_SETUP_CELL2}
    Verify Uu Messages    packet_filter=${RRC_SETUP_CELL2}
    Verify Uu Messages    packet_filter=${NR_RRC_SETUP_COMPLETE}
    Verify Ngap Messages    packet_filter=${NGAP_INITIAL_UE_MESSAGE_WITH_NR_CELL_ID}

Verify Traces For RRC Setup After Resuming UE
    Verify Tcpdump Log    packet_filter=${F1AP_INITIAL_UL_RRC_MESSAGE_TRANSFER_WITH_RRC_RESUME_REQUEST_1}
    Verify Tcpdump Log    packet_filter=${F1AP_DL_RRC_MESSAGE_TRANSFER_WITH_RRC_SETUP}   number_of_messages=2
    Verify Tcpdump Log    packet_filter=${F1AP_UL_RRC_MESSAGE_TRANSFER_WITH_RRC_SETUP_COMPLETE}    number_of_messages=2
#    Verify Uu Messages    packet_filter=${RRC_RESUME_REQUEST_1}
    Verify Uu Messages    packet_filter=${RRC_SETUP}    number_of_messages=2
    Verify Uu Messages    packet_filter=${RRC_SETUP_COMPLETE}    number_of_messages=2
    Verify Ngap Messages    packet_filter=${NGAP_INITIAL_UE_MESSAGE}    number_of_messages=2

Set Parameters For NG Link Reset
    [Arguments]              ${id}    ${gnb_id}    ${action}    ${error_type}    ${cause}    &{msg}
    Execute Egate Command    cmd=ng_link_reset_param id=${id} gnb=${gnb_id} action=${action} error_type=${error_type}
    ...                      ntimes=1 nth=1 cause=${cause} msg=&{msg}

Reset NG Link For UE
    [Arguments]              ${amf_id}    ${ue_id}
    Execute Egate Command    cmd=link_ng_reset by=amf:${amf_id} ue=${ue_id} ue_ngap_id_type=both

Verify Traces For NG Reset
    Verify Ngap Messages    packet_filter=${NGAP_RESET}
    Verify Ngap Messages    packet_filter=${NGAP_RESET_ACKNOWLEDGE}
    Verify Tcpdump Log    packet_filter=${E1AP_RESET_WITH_RADIO_NETWORK}
    Verify Tcpdump Log    packet_filter=${E1AP_RESET_ACKNOWLEDGE}

Verify Traces For UEContextReleaseCommand
    Verify Ngap Messages    packet_filter=${NGAP_UE_CONTEXT_RELEASE_COMMAND}
    Verify Ngap Messages    packet_filter=${NGAP_UE_CONTEXT_RELEASE_COMPLETE}
    Verify Tcpdump Log    packet_filter=${E1AP_BEARER_CONTEXT_RELEASE_COMMAND}
    Verify Tcpdump Log    packet_filter=${E1AP_BEARER_CONTEXT_RELEASE_COMPLETE}

#Setup UE And Execute egate commands for CE2 TC
#    [Arguments]              ${ue_id}
#    Execute Egate Command    cmd=${SET_AMF_TO_SEND_CNAI_IE_IN_UE_ICS_REQ_EGATE_CMD_MNC_489_UE1_CE2}
#    Attach UE    ue_id=${ue_id}
#    Execute Egate Command    cmd=${SIM_TTI_Set}

Setup AMF Paging PDU Setup
    Execute Egate Command    cmd=${AMF_UE_PDU_Setup_Param}
    Execute Egate Command    cmd=${UE_Param_Ignore_Paging}
    Execute Egate Command    cmd=${PDU_Session_setup2}

Wait For Timer AMF PDU Setup Timer Delay Expire
    Sleep    150s    reason=Wait For Timer AMF PDU Setup Timer Delay Expire

Verify Pcap traces CE2
    Verify Tcpdump Log    packet_filter=${NGAP_PDU_SESSION_RESOURCE_SETUP_RESPONSE}
    Verify Tcpdump Log    packet_filter=${NGAP_UE_CONTEXT_RELEASE_REQUEST}
    Verify Tcpdump Log    packet_filter=${NGAP_UE_CONTEXT_RELEASE_COMMAND}
    Verify Tcpdump Log    packet_filter=${E1AP_BEARER_CONTEXT_RELEASE_COMMAND}
    Verify Tcpdump Log    packet_filter=${E1AP_BEARER_CONTEXT_RELEASE_COMPLETE}
    Verify Tcpdump Log    packet_filter=${NGAP_UE_CONTEXT_RELEASE_COMPLETE}

Verify Traces For Release Inactive UE in RRCInactive Because Timer Expired
    Verify Tcpdump Log    packet_filter=${NGAP_UE_CONTEXT_RELEASE_REQUEST} && (ngap.radioNetwork == 20)
    Verify Tcpdump Log    packet_filter=${NGAP_UE_CONTEXT_RELEASE_COMMAND}
    Verify Tcpdump Log    packet_filter=${F1AP_UE_CONTEXT_RELEASE_COMMAND}
    Verify Tcpdump Log    packet_filter=${F1AP_UE_CONTEXT_RELEASE_COMPLETE}
    Verify Tcpdump Log    packet_filter=${E1AP_BEARER_CONTEXT_RELEASE_COMMAND}
    Verify Tcpdump Log    packet_filter=${E1AP_BEARER_CONTEXT_RELEASE_COMPLETE}
    Verify Tcpdump Log    packet_filter=${NGAP_UE_CONTEXT_RELEASE_COMPLETE}

Verify Counters For Release Inactive UE in RRCInactive Because Timer Expired PMO09
    ${PM_COUNTER_FILE}=    Get Latest Unpacked Full PM Counters File
    Verify Any Counters In File
    ...    M55133C00002  1  NE1US_CTXT_REL_CMP_SENT
    ...    M55133C00001  1  NE1US_CTXT_REL_CMD_RECD
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCUUP-1
    ...    file_path=${PM_COUNTER_FILE}
    Verify Any Counters In File
    ...    M55135C00001  1  NE1CS_CTXT_REL_CMD_SENT
    ...    M55135C00002  1  NE1CS_CTXT_REL_CMP_RECD
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1
    ...    file_path=${PM_COUNTER_FILE}
    Verify Any Counters In File
    ...    M55163C00006  1  NG_FLOW_SUS_REL_INACTVTY_PMQAP
    ...    M55163C00009  1  NG_FLOW_REL_RRC_INCT_IDL_PMQAP
    ...    M55125C00502  1  NNGCC_UE_CTXT_REL_CMP_SENT
    ...    M55125C09004  1  NG_FLOW_REL_GNB_UE_INACTIVITY
    ...    M55125C08504  1  NG_FLOW_REL_NORMAL
    ...    M55125C00015  1  NG_FLOW_SUSP_REL_INACTIVITY
    ...    M55125C01001  1  NNGCC_UE_CTXT_REL_REQ_SENT
    ...    M55125C00016  1  INACT_UE_CTXT_REL_INACTIVITY
    ...    M55125C08503  1  NG_FLOW_REL
    ...    M55125C00503  1  NNGCC_UE_CTXT_REL_REQ_INACTIVE
    ...    M55125C00020  1  NG_FLOW_REL_RRC_INACTIVE_IDLE
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${PM_COUNTER_FILE}
