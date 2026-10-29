*** Settings ***

Documentation    :copyright: Nokia

Resource    ../../../resources/airphone/5G_SW_WRO_Keywords.robot
Library    ta5g_testline_management
Library    ta5g_iphy
Library    ta5g_enb
Library    ta5g_delta
Library    ta5g_pm_counters
Library    ta5g_throughput
Library    ta5g_ue_mobility

*** Variables ***
${RRC_RELEASE_WITHOUT_SUSPEND} =    ${RRC_RELEASE} && !(nr-rrc.suspendConfig_element)
${F1AP_PAGING_REPETITION}=    ${F1AP_PAGING} && f1ap.PagingPriority == 1
${RRC_SETUP_COMPLETE_WITH_eDRX_SUPPORT}=    ${RRC_SETUP_COMPLETE} && gsm_a.gm.gmm.edrx_value == 0x5
${NGAP_INITIAL_CONTEXT_SETUP_REQUEST_WITH_CNAI_CONTAINING_PAGING_eDRX_INFO} =    ${NGAP_INITIAL_CONTEXT_SETUP_REQUEST}
...                                                  && ngap.CoreNetworkAssistanceInformationForInactive_element
...                                                  && ngap.HashedUEIdentityIndexValue == 42:c0
...                                                  && ngap.ExtendedUEIdentityIndexValue == 11:fd
...                                                  && ngap.nR_paging_Time_Window == 15
...                                                  && ngap.nR_paging_eDRX_Cycle == 2

${NGAP_INITIAL_MESSAGE_WITH_REDCAP} =    ${NGAP_INITIAL_UE_MESSAGE} && ngap.RedCapIndication == 0
${UE_CAPABILITY_WITH_REDCAP} =    ${UE_CAPABILITY_INFORMATION} && nr-rrc.supportOfRedCap_r17 == 0
${RRC_RELEASE_WITH_SUSPEND_WITH_T380} =    ${RRC_RELEASE} && nr-rrc.suspendConfig_element && nr-rrc.t380 == 0
${NGAP_INITIAL_CONTEXT_SETUP_REQUEST_WITH_CNAI} =    ${NGAP_INITIAL_CONTEXT_SETUP_REQUEST}
...                                                  && ngap.CoreNetworkAssistanceInformationForInactive_element
${E1AP_BEARER_CONTEXT_STATUS_CHANGE_SUSPEND} =    ${E1AP_BEARER_CONTEXT_MODIFICATION_REQUEST} && e1ap.BearerContextStatusChange == 0
${E1AP_BEARER_CONTEXT_MODIFICATION_RESPONSE_TO_BEARER_CONTEXT_STATUS_CHANGE} =    ${E1AP_BEARER_CONTEXT_MODIFICATION_RESPONSE}
...                                                                              && !(e1ap.System_BearerContextModificationResponse)
${F1AP_UE_CONTEXT_RELEASE_REQUEST_WITH_RRC_RELEASE_WITH_SUSPEND} =    ${F1AP_UE_CONTEXT_RELEASE_COMMAND}
...                                                                  && f1ap.radioNetwork == 10 && nr-rrc.c1 == 2
${F1AP_INITIAL_UL_RRC_MESSAGE_TRANSFER_WITH_RRCRESUMEREQ1_MT_ACCESS} =    ${F1AP_INITIAL_UL_RRC_MESSAGE_TRANSFER} && nr-rrc.rrcResumeRequest1_element
...                                                                      && nr-rrc.c1 == 0 && nr-rrc.resumeCause == 2
${E1AP_BEARER_CONTEXT_STATUS_CHANGE_RESUME} =    ${E1AP_BEARER_CONTEXT_MODIFICATION_REQUEST} && e1ap.BearerContextStatusChange == 1
${E1AP_BEARER_CONTEXT_MODIFICATION_RESPONSE_ONE_DRB} =    ${E1AP_BEARER_CONTEXT_MODIFICATION_RESPONSE} && e1ap.dRB_Modified_List_NG_RAN == 1
...                                                      && e1ap.DRB_Modified_Item_NG_RAN_element && e1ap.dRB_ID == 4
${F1AP_UL_RRC_MESSAGE_TRANSFER_WITH_RRC_RESUME_COMPLETE} =    ${F1AP_UL_RRC_MESSAGE_TRANSFER} && nr-rrc.rrcResumeComplete_element
${RRC_RESUME_WITH_RADIO_BEARER_CONFIG} =    ${RRC_RESUME} && nr-rrc.c1 == 1 && nr-rrc.radioBearerConfig_element
${RRC_RESUME_REQUEST_1_CAUSE_MT_ACCESS} =    ${RRC_RESUME_REQUEST_1} && nr-rrc.resumeCause == 2

*** Keywords ***
Set Core Network Assistance Information For RRC Inactive State In Initial Context Setup Request With eDRX
    [Arguments]    ${ue_id}    ${amf_id}=1    ${plmn_id}=311:489    ${tac_id}=788    ${extende_ue_id}=4605
    ...            ${hashed_ue_id}=2136    ${paging_edrx_cycle}=hf1    ${paging_time_window}=s16
    ${command} =  catenate  SEPARATOR=
    ...           amf_ue_ics_param id=${amf_id} ue=${ue_id} core_network_assistance_info=on
    ...           \ ue_identity_index_value=${ue_id} periodic_registration_update_timer=1:10min plmn_id=${plmn_id}
    ...           \ tac_id=${tac_id} extended_ue_identity_index_value=${extende_ue_id} hashed_ue_identity_index_value=${hashed_ue_id}
    ...           \ nr_paging_edrx_cycle=${paging_edrx_cycle} nr_paging_time_window=${paging_time_window}
    Execute Egate Command    cmd=${command}
    Sleep    1

Removal Restriction Modification Of MIB Cell Barred Status
    Execute Egate Command    cmd=uec_l2_testmode_params periodic_ssb_reading=true
    Sleep    1s    reason=waiting for cell started to be not barred

Set Delay Paging For Ue
    [Arguments]    ${ue_id}    ${pagingdelay}
    Ue Nr Rrc Setup Param    ue_id=${ue_id}    pagingdelay=${pagingdelay}

Verify Paging Repetition
    Verify Tcpdump Log    packet_filter=${F1AP_PAGING_REPETITION}    number_of_messages=6    timeout=120

Verify CNAI With Paging eDRX Information Extended And Hashed UE Index Values
    Verify Ngap Messages    packet_filter=${NGAP_INITIAL_CONTEXT_SETUP_REQUEST_WITH_CNAI_CONTAINING_PAGING_eDRX_INFO}

Verify RRC Setup Complete With eDRX Support
    Verify Tcpdump Log    packet_filter=${RRC_SETUP_COMPLETE_WITH_eDRX_SUPPORT}

Verify RedCap Messages
    Verify Ngap Messages    packet_filter=${NGAP_INITIAL_MESSAGE_WITH_REDCAP}
    Verify Tcpdump Log    packet_filter=${UE_CAPABILITY_WITH_REDCAP}

Verify Exact Value Of Latest Pm Counter
    Wait For Next Full PM Interval
    ${PM_COUNTER_FILE}=    Get Latest Unpacked Full PM Counters File
    Verify If Latest Pm Counter Has Exact Value    counter_id=M55197C00001    value=1    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1
    ...                                            filepath=${PM_COUNTER_FILE}    pmqap=PLMN-PLMN/NRPAGING_STRAT_RRCINACT-2
    Verify If Latest Pm Counter Has Exact Value    counter_id=M55197C00004    value=1    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1
    ...                                            filepath=${PM_COUNTER_FILE}    pmqap=PLMN-PLMN/NRPAGING_STRAT_RRCINACT-2
    Verify If Latest Pm Counter Has Exact Value    counter_id=M55197C00005    value=1    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1
    ...                                            filepath=${PM_COUNTER_FILE}    pmqap=PLMN-PLMN/NRPAGING_STRAT_RRCINACT-2
    Verify If Latest Pm Counter Has Exact Value    counter_id=M55197C00006    value=1    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1
    ...                                            filepath=${PM_COUNTER_FILE}    pmqap=PLMN-PLMN/NRPAGING_STRAT_RRCINACT-2
    Verify If Latest Pm Counter Has Exact Value    counter_id=M55197C00007    value=1    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1
    ...                                            filepath=${PM_COUNTER_FILE}    pmqap=PLMN-PLMN/NRPAGING_STRAT_RRCINACT-2
    Verify If Latest Pm Counter Has Exact Value    counter_id=M55197C00008    value=1    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1
    ...                                            filepath=${PM_COUNTER_FILE}    pmqap=PLMN-PLMN/NRPAGING_STRAT_RRCINACT-2
    Verify If Latest Pm Counter Has Exact Value    counter_id=M55197C00002    value=1    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1
    ...                                            filepath=${PM_COUNTER_FILE}    pmqap=PLMN-PLMN/NRPAGING_STRAT_RRCINACT-2

Start Vm Ethernet Interfaces
    Start Vm Ethernet Interface    if_name=eth3:AMF2_NG_ADDR    ip_with_mask=10.0.1.3/24
    Start Vm Ethernet Interface    if_name=eth3:AMF3_NG_ADDR    ip_with_mask=10.0.1.4/24

Stop Vm Ethernet Interfaces
    Stop Vm Ethernet Interface    if_name=eth3:AMF2_NG_ADDR    ip_with_mask=10.0.1.3/24
    Stop Vm Ethernet Interface    if_name=eth3:AMF3_NG_ADDR    ip_with_mask=10.0.1.4/24

Wait For Release RRC Inactive Conditions Met
    Verify Tcpdump Log    packet_filter=${RRC_RELEASE}    timeout=20

Verify Traces For Successful Transition To RRC INACTIVE
    Verify Tcpdump Log    packet_filter=${RRC_RELEASE_WITH_SUSPEND_WITH_T380}
    Verify Tcpdump Log    packet_filter=${NGAP_INITIAL_CONTEXT_SETUP_REQUEST_WITH_CNAI}
    Verify Tcpdump Log    packet_filter=${E1AP_BEARER_CONTEXT_STATUS_CHANGE_SUSPEND}
    Verify Tcpdump Log    packet_filter=${E1AP_BEARER_CONTEXT_MODIFICATION_RESPONSE_TO_BEARER_CONTEXT_STATUS_CHANGE}
    Verify Tcpdump Log    packet_filter=${F1AP_UE_CONTEXT_RELEASE_REQUEST_WITH_RRC_RELEASE_WITH_SUSPEND}
    Verify Tcpdump Log    packet_filter=${F1AP_UE_CONTEXT_RELEASE_COMPLETE}

Verify Traces For Successful Transition to RRC CONNECTED By MT Access
    Verify Tcpdump Log    packet_filter=${F1AP_INITIAL_UL_RRC_MESSAGE_TRANSFER_WITH_RRCRESUMEREQ1_MT_ACCESS}
    Verify Tcpdump Log    packet_filter=${E1AP_BEARER_CONTEXT_STATUS_CHANGE_RESUME}
    Verify Tcpdump Log    packet_filter=${E1AP_BEARER_CONTEXT_MODIFICATION_RESPONSE_ONE_DRB}    number_of_messages=2
    Verify Tcpdump Log    packet_filter=${F1AP_UE_CONTEXT_SETUP_REQUEST}    number_of_messages=2
    Verify Tcpdump Log    packet_filter=${F1AP_UL_RRC_MESSAGE_TRANSFER_WITH_RRC_RESUME_COMPLETE}
    Verify Tcpdump Log    packet_filter=${RRC_RESUME_WITH_RADIO_BEARER_CONFIG}
    Verify Tcpdump Log    packet_filter=${RRC_RESUME_REQUEST_1_CAUSE_MT_ACCESS}
    Verify Tcpdump Log    packet_filter=${RRC_RESUME_COMPLETE}

Set Core Network Assistance Information For RRC Inactive State In Initial Context Setup Request
    [Arguments]    ${ue_id}    ${amf_id}=1    ${plmn_id}=311:489    ${tac_id}=200
    ${command} =  catenate  SEPARATOR=
    ...           amf_ue_ics_param id=${amf_id} ue=${ue_id} core_network_assistance_info=on
    ...           \ ue_identity_index_value=${ue_id} ue_specific_drx=64
    ...           \ periodic_registration_update_timer=1:10min plmn_id=${plmn_id} tac_id=${tac_id}
    Execute Egate Command    cmd=${command}
    Sleep    1
