*** Settings ***

Documentation    :copyright: Nokia

Resource     ../../resources/airphone/5G_SW_WRO_Keywords.robot

Variables    ta5g_global_var

Library      ta5g_testline_management
Library      ta5g_ue_measurements
Library      ta5g_delta
Library      ta5g_iphy
Library      ta5g_enb

*** Variables ***
@{swconfig_rndFlag}=    0x890057=0 # rdActNrDualConnectivity - Parameter set to 0 implies intraGnb NR-DC enabled in all cells
${FULL_COMMISSIONING}=    ${TRUE}
${RESET_TL}=    ${FALSE}
${RESTORE_DEFAULT_CONFIG}=    ${TRUE}
${LUA_FILEPATH}    ${CURDIR}/config/egate_2c_tdd_NRDC.lua
${LUA_FWAUE_FILEPATH}    ${CURDIR}/config/egate_2c_tdd_FWAUE_NRDC.lua
#FILTERS
${BEARER_CONTEXT_INACTIVITY_NOTIFICATION}=    e1ap.uE_Activity == 1
${UE_CONTEXT_RELEASE_REQUEST}=    ngap.radioNetwork == 20 && (ngap.pDUSessionID == 1 || ngap.pDUSessionID == 2)
${UE_CONTEXT_RELEASE_COMMAND_NGAP}=    ngap.procedureCode == 41 && ngap.radioNetwork == 20
${UE_CONTEXT_RELEASE_COMMAND_NORMAL_RELEASE_PCELL_F1AP}=    f1ap.radioNetwork == 10
${BEARER_CONTEXT_RELEASE_COMMAND}=    e1ap.radioNetwork == 20
${BEARER_CONTEXT_RELEASE_COMPLETE}=    e1ap.dRB_Released_In_Session == 1
${UE_CONTEXT_RELEASE_COMMAND_UNSPECIFIED_PSCELL_F1AP}=    (f1ap.UEContextReleaseCommand_element && (f1ap.radioNetwork == 6 || f1ap.protocol == 6))
...    || ((f1ap.UEContextReleaseCommand_element) && (f1ap.radioNetwork == 0 || f1ap.protocol == 0))
${F1AP_UE_CONTEXT_RELEASE_COMPLETE_PCELL}=    f1ap.UEContextReleaseComplete_element
...    && (f1ap.GNB_DU_UE_F1AP_ID == 1 || f1ap.GNB_DU_UE_F1AP_ID == 49999)
${F1AP_UE_CONTEXT_RELEASE_COMPLETE_PSCELL}=    f1ap.UEContextReleaseComplete_element
...    && (f1ap.GNB_DU_UE_F1AP_ID == 16667 || f1ap.GNB_DU_UE_F1AP_ID == 66665)
${ERROR_INDICATION}=    ngap.procedureCode == 9
${UE_CONTEXT_RELEASE_COMMAND_NGAP_ELEMENT}=    ngap.UEContextReleaseCommand_element
${RRC_RELEASE_WITHOUT_SUSPEND_IE}=    nr-rrc.rrcRelease_element && !nr-rrc.suspendConfig_element
${NGAP_INITIAL_CONTEXT_SETUP_REQUEST_WITH_CNI}=    ngap.InitialContextSetupRequest_element && ngap.CoreNetworkAssistanceInformationForInactive_element
${E1AP_BEARER_CONTEXT_STATUS_CHANGE}=    e1ap.BearerContextModificationRequest_element && e1ap.cell_Group_ID == 1 && e1ap.uL_Configuration == 0
${E1AP_BEARER_CONTEXT_MODIFICATION_RESPONSE}=    e1ap.BearerContextModificationResponse_element && e1ap.cell_Group_ID == 1
${F1AP_UE_CONTEXT_RELEASE_REQUEST_WITH_RRC_RELEASE}=    f1ap.UEContextReleaseCommand_element && f1ap.radioNetwork == 10 && nr-rrc.c1 == 2
${F1AP_UE_CONTEXT_RELEASE_COMPLETE}=    f1ap.UEContextReleaseComplete_element
${NGAP_UE_CONTEXT_RELEASE_COMPLETE}=    ngap.UEContextReleaseComplete_element
${NR_RRC_RESUME}=    nr-rrc.rrcResume_element && f1ap.GNB_DU_UE_F1AP_ID == 16667
${NR_RRC_RESUME_COMPLETED}=    nr-rrc.c1 == 4 && f1ap.GNB_DU_UE_F1AP_ID == 16667
${F1AP_UE_CONTEXT_MODIFICATION_REQUEST_MEAS_CONFIG}=    f1ap.UEContextModificationRequest_element && nr-rrc.reportConfigId == 1
...    && f1ap.GNB_DU_UE_F1AP_ID == 16667 && f1ap.measConfig !=0 && nr-rrc.measId == 1
${F1AP_UE_CONTEXT_MODIFICATION_REQUEST_MEAS_GAP_CONFIG_NOT_INCLUDED}=    f1ap.UEContextModificationRequest_element && f1ap.measGapConfig ==0
${F1AP_UE_CONTEXT_MODIFICATION_REQUEST_MEASUREMENTS_OBJECTS_CANDIDATE}=    f1ap.UEContextModificationRequest_element
...    && nr-rrc.freqBandIndicatorNR == 78 && nr-rrc.freqBandIndicatorNR == 257 && f1ap.GNB_DU_UE_F1AP_ID == 16667 && nr-rrc.measId == 1
${F1AP_UE_CONTEXT_MODIFICATION_REQUEST_REPORT_CONFIG_NR}=    f1ap.UEContextModificationRequest_element && nr-rrc.reportConfig == 0
...    && f1ap.GNB_DU_UE_F1AP_ID == 16667 && nr-rrc.a4_Threshold == 0 && nr-rrc.hysteresis == 0 && nr-rrc.timeToTrigger == 4
...    && nr-rrc.reportAmount == 2 && nr-rrc.reportInterval == 4 && nr-rrc.measId == 1
${F1AP_UE_CONTEXT_MODIFICATION_RESPONSE_MEAS_GAP_CONFIG}=    f1ap.UEContextModificationResponse_element && nr-rrc.gapUE == 1
...    && f1ap.GNB_DU_UE_F1AP_ID == 16667
${RRC_RECONFIGURATIOM_MESSAGE_PCELL}=    nr-rrc.rrcReconfiguration_element && nr-rrc.freqBandIndicatorNR == 78
${RRC_RECONFIGURATIOM_MESSAGE_PSCELL}=    nr-rrc.rrcReconfiguration_element && nr-rrc.freqBandIndicatorNR == 257 && f1ap.GNB_DU_UE_F1AP_ID == 16667
${RRC_RECONFIGURATIOM_MESSAGE_REPORT_CONFIG_NR}=    nr-rrc.rrcReconfiguration_element && nr-rrc.reportConfigToAddModList == 1
...    && nr-rrc.reportConfig == 0 && f1ap.GNB_DU_UE_F1AP_ID == 16667
${RRC_RECONFIGURATIOM_MESSAGE_MEAS_IDS}=    nr-rrc.rrcReconfiguration_element && nr-rrc.measIdToAddModList == 1 && nr-rrc.measId == 1
...    && f1ap.GNB_DU_UE_F1AP_ID == 16667
${RRC_RECONFIGURATIOM_MESSAGE_MEAS_GAP_CONFIG}=    nr-rrc.rrcReconfiguration_element && nr-rrc.gapUE == 1 && f1ap.GNB_DU_UE_F1AP_ID == 16667
...    && nr-rrc.measId == 1
${RRC_RECONFIGURATIOM_MESSAGE_S_MEASURE_CONFIG}=    nr-rrc.rrcReconfiguration_element && f1ap.GNB_DU_UE_F1AP_ID == 16667 && nr-rrc.ssb_RSRP == 127
...    && nr-rrc.measId == 1
${NGAP_INITIAL_CONTEXT_SETUP_REQUEST_INDEX_TO_RFSP}=    ngap.IndexToRFSP == 255
${NGAP_ELIGIBLE_PDU_SESSION_RESOURCE_SETUP_REQUEST}=    ngap.pDUSessionID == 2 && ngap.fiveQI == 170
${RRC_RECONFIGURATION_COMPLETE}=    nr-rrc.criticalExtensions == 0 && f1ap.GNB_DU_UE_F1AP_ID == 16667 && pdcp-nr.direction == 0
...    && pdcp-nr.seq-num == 2

*** Keywords ***
Start Vm Ethernet Interfaces
    Start Vm Ethernet Interface    if_name=eth3:GNBSIM_XN   ip_with_mask=10.0.1.101/24
    Start Vm Ethernet Interface    if_name=eth3:GNBSIM_NG   ip_with_mask=10.0.1.102/2

Stop Vm Ethernet Interfaces
    Stop Vm Ethernet Interface    if_name=eth3:GNBSIM_XN   ip_with_mask=10.0.1.101/24
    Stop Vm Ethernet Interface    if_name=eth3:GNBSIM_NG   ip_with_mask=10.0.1.102/2

Wait For Release For No CoreNetworkAssistanceInformation UE
    Verify Uu Messages    packet_filter=${RRC_RELEASE}   timeout=100

Verify UE Transition To RRC INACTIVE
    Verify Uu Messages    packet_filter=${RRC_RELEASE_WITHOUT_SUSPEND_IE}
    Verify Tcpdump Log    packet_filter=${NGAP_INITIAL_CONTEXT_SETUP_REQUEST_WITH_CNI}
    Verify Tcpdump Log    packet_filter=${E1AP_BEARER_CONTEXT_STATUS_CHANGE}
    Verify Tcpdump Log    packet_filter=${E1AP_BEARER_CONTEXT_MODIFICATION_RESPONSE}
    Verify Tcpdump Log    packet_filter=${F1AP_UE_CONTEXT_RELEASE_REQUEST_WITH_RRC_RELEASE}
    Verify Tcpdump Log    packet_filter=${F1AP_UE_CONTEXT_RELEASE_COMPLETE}    number_of_messages=2

Trigger Error Indication In NGAP UE Context Release Procedure
    Execute Egate Command    cmd=amf_ue_ctx_release_param id=1 action=error_indication

Trigger Core Network Assistance Information For RRC Inactive State In Initial Context Setup Request Procedure
    [Arguments]    ${ue_id}
    ${command} =  catenate  SEPARATOR=
    ...           amf_ue_ics_param id=1 ue=${ue_id} core_network_assistance_info=on
    ...           \ ue_identity_index_value=${ue_id} ue_specific_drx=64
    ...           \ periodic_registration_update_timer=1:10min plmn_id=311:489 tac_id=788
    Execute Egate Command    cmd=${command}
    Sleep    1

Trigger Core Network Assistance Information For FWAUE RRC Inactive State In Initial Context Setup Request Procedure
    [Arguments]    ${ue_id}
    ${command} =  catenate  SEPARATOR=
    ...           amf_ue_ics_param id=1 ue=${ue_id} core_network_assistance_info=on
    ...           \ ue_identity_index_value=${ue_id} ue_specific_drx=64
    ...           \ periodic_registration_update_timer=1:10min plmn_id=311:489 tac_id=788
    ...           \ indexToRFSP=255
    Execute Egate Command    cmd=${command}
    Sleep    1

Trigger Core Network Assistance Information For Non FWAUE RRC Inactive State In Initial Context Setup Request Procedure
    [Arguments]    ${ue_id}
    ${command} =  catenate  SEPARATOR=
    ...           amf_ue_ics_param id=1 ue=${ue_id} core_network_assistance_info=on
    ...           \ ue_identity_index_value=${ue_id} ue_specific_drx=64
    ...           \ periodic_registration_update_timer=1:10min plmn_id=311:489 tac_id=788
    ...           \ indexToRFSP=2
    Execute Egate Command    cmd=${command}
    Sleep    1

Set Traffic Type For UE And PDU Session
    [Arguments]    ${ue_id}    ${pdu_id}
    ${command} =  catenate  SEPARATOR=
    ...           set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute Egate Command    cmd=${command}

Start Data Traffic For UE
    [Arguments]    ${ue_id}    ${pdu_id}
    ${command} =  catenate  SEPARATOR=
    ...           trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=50 seconds=12
    Execute Egate Command    cmd=${command}

Modify Pdu Session To Non Eligible NRDC Pdu Session
    Modify Pdu Session    ue_id=2    pdu_id=2    qos_to_add=2

