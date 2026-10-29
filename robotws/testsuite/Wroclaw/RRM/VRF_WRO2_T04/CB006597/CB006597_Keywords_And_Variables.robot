*** Settings ***

Documentation    :copyright: Nokia

Resource     ../../resources/airphone/5G_SW_WRO_Keywords.robot
Library      ta5g_enb
Library      ta5g_delta
Library      ta5g_pm_counters
Library      ta5g_ue_measurements

*** Variables ***
${NGAP_UE_RADIO_CAPABILITY_INFO_INDICATION_RELEASE_PREFERENCE_R16}=    ${NGAP_UE_RADIO_CAPABILITY_INFO_INDICATION} &&
...                                                                    nr-rrc.releasePreference_r16 == 0
${RRC_RECONFIGURATION_RELEASE_PREFERENCE_R16_CONNECTED_REPORTING}=    ${RRC_RECONFIGURATION} && nr-rrc.releasePreferenceConfig_r16 == 1 &&
...                                                                   nr-rrc.releasePreferenceProhibitTimer_r16 == 0 &&
...                                                                   nr-rrc.connectedReporting == 0
${UE_ASSISTANT_INFO_PREFERRED_RRC_STATE}=    (nr-rrc.ueAssistanceInformation_element) && (nr-rrc.preferredRRC_State_r16 == 0)

*** Keywords ***
Send Ics Registration On
    [Arguments]    ${id}
    Execute Egate Command    cmd=amf_param id=${id} empty_pdu_session_list=on send_ics_registration=on

Send Ics Registration Off
    [Arguments]    ${id}
    Execute Egate Command    cmd=amf_param id=${id} empty_pdu_session_list=off send_ics_registration=off

Kill Ue
    [Arguments]    ${id}
    Execute Egate Command    cmd=ue_kill id=${id}

Attach Ue Without Ics
    [Arguments]    ${ue_id}
    Execute Egate Command   cmd=amf_param id=1 empty_pdu_session_list=on send_ics_registration=off
    Change Ue Location Without Confirmation    ue_id=1    dst_enb=2    dst_cell=1
    Attach Ue    ue_id=${ue_id}

Trigger Ue To Send UAI With PreferredRRCState Idle
    [Arguments]    ${ue_id}
    Execute Egate Command    cmd=ue_assistance_send_nr ue_id=${ue_id} PreferredRRCState=idle

Trigger Ue To Send UAI With PreferredRRCState Inactive
    [Arguments]    ${ue_id}
    Execute Egate Command    cmd=ue_assistance_send_nr ue_id=${ue_id} PreferredRRCState=inactive

Wait For Triggering Procedure
    Sleep    20s    reason=Waiting For Triggering Procedure

Establish Pdu Session And Perform Handover
    [Arguments]    ${ue_id}
    Execute Egate Command    cmd=ue_pdu_session_setup pdu=1 ue=${ue_id} gw=${ue_id} nwslice=1
    ...                      pass_regexp=UE${ue_id}: UE${ue_id}: Established PDU session ID=1 using PDU Gateway ID=${ue_id}
    Send Custom Ue Measurement Nr     id=${ue_id}     meas_id=3     event=A3     srsrp_nr=18     phycell_id=50     nrsrp_nr=85
    ...                               pass_regexp=UE${ue_id}: Inter-eNB handover from ENB-3.1 to EXT_ENB-2.1 performed
    Sleep    1    reason=Waiting For Handover Procedure End

Add Ue History Information For Handover
    [Arguments]    ${ue_id}
    Execute Egate Command    cmd=ue_history_information_list_add_ngran id=1 gnb_id=3 cell_type=medium nrcgi=311:489|0x01 time_ue_stayed_in_cell=100
    Execute Egate Command    cmd=ue_history_information_list_add_ngran id=1 gnb_id=2 cell_type=medium nrcgi=311:489|0x01 time_ue_stayed_in_cell=100
    Execute Egate Command    cmd=ue_history_information_list id=1 action=commit
    Execute Egate Command    cmd=ue_enb_param id=${ue_id} ue_history_list=1

Verify Ngap Messages For Subcase
    [Arguments]    ${packet_filter}    ${subcase_name}    ${number_of_messages}=1    ${pcap_file_path}=${None}    ${timeout}=16
    ...            ${relation_symbol}= ==    ${alias}=default_s1_x2_subcase    ${continue_on_failure}=${True}
    Verify Tshark
    ...    alias=${alias}
    ...    packet_filter=${packet_filter}
    ...    pass_criteria=${relation_symbol}${number_of_messages}
    ...    pcap_file_path=${pcap_file_path}
    ...    timeout=${timeout}
    ...    continue_on_failure=${continue_on_failure}
    ...    subcase=${subcase_name}

Verify Uu Messages For Subcase
    [Arguments]    ${packet_filter}    ${subcase_name}    ${number_of_messages}=1    ${pcap_file_path}=${None}    ${timeout}=16
    ...            ${relation_symbol}= ==    ${alias}=default_uu_subcase    ${continue_on_failure}=${True}
    Verify Tshark
    ...    alias=${alias}
    ...    packet_filter=${packet_filter}
    ...    pass_criteria=${relation_symbol}${number_of_messages}
    ...    pcap_file_path=${pcap_file_path}
    ...    timeout=${timeout}
    ...    continue_on_failure=${continue_on_failure}
    ...    subcase=${subcase_name}

Verify Handover Messages
    [Arguments]    ${subcase_name}
    Verify Ngap Messages For Subcase    packet_filter=${XNAP_HANDOVER_REQUEST}    subcase_name=${subcase_name}    relation_symbol= >=
    Verify Ngap Messages For Subcase    packet_filter=${XNAP_HANDOVER_REQUEST_ACK}    subcase_name=${subcase_name}    relation_symbol= >=
    Verify Ngap Messages For Subcase    packet_filter=${XNAP_SN_STATUS_TRANSFER}    subcase_name=${subcase_name}    relation_symbol= >=
    Verify Ngap Messages For Subcase    packet_filter=${NGAP_PATH_SWITCH_REQUEST}    subcase_name=${subcase_name}    relation_symbol= >=
    Verify Ngap Messages For Subcase    packet_filter=${NGAP_PATH_SWITCH_REQUEST_ACK}    subcase_name=${subcase_name}    relation_symbol= >=
    Verify Uu Messages For Subcase    packet_filter=${RRC_RECONFIGURATION_COMPLETE}   subcase_name=${subcase_name}    relation_symbol= >=

Verify Ue Assistance Information And Ue Context Release
    [Arguments]    ${subcase_name}    ${number_of_messages}=1    ${relation_symbol}= ==    ${preferredRRC_State_r16}=0
    Verify Uu Messages For Subcase
	...    packet_filter=(nr-rrc.ueAssistanceInformation_element) && (nr-rrc.preferredRRC_State_r16 == ${preferredRRC_State_r16})
    ...    subcase_name=${subcase_name}    number_of_messages=${number_of_messages}    relation_symbol=${relation_symbol}
    Verify Ngap Messages For Subcase    packet_filter=${NGAP_UE_CONTEXT_RELEASE_REQUEST} && ${CAUSE_UNSPECIFIED}
    ...    subcase_name=${subcase_name}    number_of_messages=${number_of_messages}    relation_symbol=${relation_symbol}
    Verify Ngap Messages For Subcase    packet_filter=${NGAP_UE_CONTEXT_RELEASE_COMPLETE}   subcase_name=${subcase_name}
    ...    number_of_messages=${number_of_messages}    relation_symbol=${relation_symbol}
    Verify Ngap Messages For Subcase    packet_filter=${NGAP_UE_CONTEXT_RELEASE_COMMAND}   subcase_name=${subcase_name}
    ...    number_of_messages=${number_of_messages}    relation_symbol=${relation_symbol}