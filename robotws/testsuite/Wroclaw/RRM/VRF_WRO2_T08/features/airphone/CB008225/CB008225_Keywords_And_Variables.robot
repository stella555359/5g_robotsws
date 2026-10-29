*** Settings ***
Documentation
...  Author:  przemyslaw.sas@nokia.com, bartosz.grzegorczyk@nokia.com, marcin.szulc@nokia.com, adam.wojtyna@nokia.com
...           rafal.magnowski@nokia.com, tomasz.niedzwiedzki@nokia.com, sebastian.maslak@nokia.com
...  Mantainer:  marcin.plawny@nokia.com

Resource    taf/rfrl/common_resources/robot/libraries_instances.robot
Resource    ../../../../resources/airphone/5G_SW_WRO_Keywords.robot
Library    testsuite/Wroclaw/RRM/resources/scout_report.py
Library    ta5g_testline_management
Library    ta5g_iphy
Library    ta5g_ue_measurements
Library    ta5g_enb
Library    ta5g_delta
Library    ta5g_pm_counters
Library    ta5g_throughput
Library    ta5g_iperf_traffic
Library    taf.sw.reporting_portal
Library    testsuite/Wroclaw/RRM/resources/syslog_checker.py

*** Variables ***
${RANAC_USEFULLRESUMEID_CELL1} =    (nr-rrc.ranac == 4) && (nr-rrc.ranac == 49) && (nr-rrc.useFullResumeID == 0) &&
...                                (nr-rrc.cellIdentity == 00:00:04:00:10)
${OFF_RANAC_USEFULLRESUMEID_CELL1} =    (!((nr-rrc.ranac == 4) && (nr-rrc.ranac == 49) && (nr-rrc.useFullResumeID == 0))) &&
...                                    (nr-rrc.cellIdentity == 00:00:04:00:10)

${RRC_RELEASE_WITH_SUSPEND_WITH_T380} =    ${RRC_RELEASE} && nr-rrc.suspendConfig_element && nr-rrc.t380 == 0
${RRC_RELEASE_WITHOUT_SUSPEND} =    ${RRC_RELEASE} && !(nr-rrc.suspendConfig_element)
${RRC_RESUME_REQUEST_1_CAUSE_MT_ACCESS} =    ${RRC_RESUME_REQUEST_1} && nr-rrc.resumeCause == 2
${RRC_RESUME_REQUEST_1_CAUSE_MO_SIGNALING} =    ${RRC_RESUME_REQUEST_1} && nr-rrc.resumeCause == 3
${RRC_RESUME_REQUEST_CAUSE_RNA_UPDATE} =    ${RRC_RESUME_REQUEST} && nr-rrc.resumeCause == 8
${RRC_RESUME_WITH_RADIO_BEARER_CONFIG} =    ${RRC_RESUME} && nr-rrc.c1 == 1 && nr-rrc.radioBearerConfig_element
${RRC_SETUP_CELL2} =    ${RRC_SETUP} && nr-rrc.scramblingID0 == 51
${RRC_SETUP_COMPLETE_CELL2} =    ${RRC_SETUP_COMPLETE} && !(nas_5gs.mm.message_type == 0x41)

${E1AP_RESET_WITH_RADIO_NETWORK} =    ${E1AP_RESET} && e1ap.radioNetwork == 20
${E1AP_RESET_WITH_TRANSPORT} =    ${E1AP_RESET} && e1ap.transport == 0
${E1AP_BEARER_CONTEXT_STATUS_CHANGE_SUSPEND} =    ${E1AP_BEARER_CONTEXT_MODIFICATION_REQUEST} && e1ap.BearerContextStatusChange == 0
${E1AP_BEARER_CONTEXT_MODIFICATION_REQUEST_WITH_PDU_MOD} =    ${E1AP_BEARER_CONTEXT_MODIFICATION_REQUEST} && e1ap.BearerContextStatusChange == 1
...                                                          && e1ap.dRB_To_Modify_List_NG_RAN == 1 && e1ap.DRB_To_Modify_Item_NG_RAN_element
...                                                          && e1ap.dRB_ID == 4 && e1ap.dRB_ID == 5
${E1AP_BEARER_CONTEXT_STATUS_CHANGE_RESUME} =    ${E1AP_BEARER_CONTEXT_MODIFICATION_REQUEST} && e1ap.BearerContextStatusChange == 1
${E1AP_BEARER_CONTEXT_MODIFICATION_RESPONSE_TO_BEARER_CONTEXT_STATUS_CHANGE} =    ${E1AP_BEARER_CONTEXT_MODIFICATION_RESPONSE}
...                                                                              && !(e1ap.System_BearerContextModificationResponse)
${E1AP_BEARER_CONTEXT_MODIFICATION_RESPONSE_ONE_DRB} =    ${E1AP_BEARER_CONTEXT_MODIFICATION_RESPONSE} && e1ap.dRB_Modified_List_NG_RAN == 1
...                                                      && e1ap.DRB_Modified_Item_NG_RAN_element && e1ap.dRB_ID == 4
${E1AP_BEARER_CONTEXT_MODIFICATION_RESPONSE_TWO_DRB} =    ${E1AP_BEARER_CONTEXT_MODIFICATION_RESPONSE} && e1ap.dRB_Modified_List_NG_RAN == 1
...                                                      && e1ap.DRB_Modified_Item_NG_RAN_element && e1ap.dRB_ID == 4 && e1ap.dRB_ID == 5

${GNB_DU_CONFIGURATION_UPDATE_FOR_CELL2} =    ${F1AP_GNB_CONFIGURATION_UPDATE} && nr-rrc.cellIdentity == 00:00:04:00:20
${F1AP_UE_CONTEXT_RELEASE_REQUEST_WITH_RRC_RELEASE_WITH_SUSPEND} =    ${F1AP_UE_CONTEXT_RELEASE_COMMAND}
...                                                                  && f1ap.radioNetwork == 10 && nr-rrc.c1 == 2
${F1AP_DL_RRC_MESSAGE_TRANSFER_WITH_RRC_SETUP} =    ${F1AP_DL_RRC_MESSAGE_TRANSFER} && nr-rrc.rrcSetup_element
${F1AP_DL_RRC_MESSAGE_TRANSFER_WITH_RRC_SETUP_CELL2} =    ${F1AP_DL_RRC_MESSAGE_TRANSFER} && nr-rrc.rrcSetup_element && nr-rrc.scramblingID0 == 51
${F1AP_UL_RRC_MESSAGE_TRANSFER_WITH_RRC_SETUP_COMPLETE} =    ${F1AP_UL_RRC_MESSAGE_TRANSFER} && nr-rrc.rrcSetupComplete_element
${F1AP_UL_RRC_MESSAGE_TRANSFER_WITH_RRC_RESUME_COMPLETE} =    ${F1AP_UL_RRC_MESSAGE_TRANSFER} && nr-rrc.rrcResumeComplete_element
${F1AP_INITIAL_UL_RRC_MESSAGE_TRANSFER_WITH_RRCRESUMEREQ1_MT_ACCESS} =    ${F1AP_INITIAL_UL_RRC_MESSAGE_TRANSFER} && nr-rrc.rrcResumeRequest1_element
...                                                                      && nr-rrc.c1 == 0 && nr-rrc.resumeCause == 2
${F1AP_INITIAL_UL_RRC_MESSAGE_TRANSFER_WITH_RRCRESUMEREQ1_MO_SIGNALING} =    ${F1AP_INITIAL_UL_RRC_MESSAGE_TRANSFER}
...                                                                         && f1ap.RRCContainer && nr-rrc.c1 == 0 && nr-rrc.resumeCause == 3
${F1AP_INITIAL_UL_RRC_MESSAGE_TRANSFER_WITH_RRCRESUMEREQ1_RNA_UPDATE} =    ${F1AP_INITIAL_UL_RRC_MESSAGE_TRANSFER}
...                                                                        && nr-rrc.rrcResumeRequest1_element && nr-rrc.c1 == 0
...                                                                        && nr-rrc.resumeCause == 8
${F1AP_INITIAL_UL_RRC_MESSAGE_TRANSFER_WITH_RRC_RESUME_REQUEST} =    ${F1AP_INITIAL_UL_RRC_MESSAGE_TRANSFER} && nr-rrc.rrcResumeRequest_element
${F1AP_INITIAL_UL_RRC_MESSAGE_TRANSFER_WITH_RRC_RESUME_REQUEST_1} =    ${F1AP_INITIAL_UL_RRC_MESSAGE_TRANSFER} && nr-rrc.rrcResumeRequest1_element

${NGAP_INITIAL_CONTEXT_SETUP_REQUEST_WITH_CNAI} =    ${NGAP_INITIAL_CONTEXT_SETUP_REQUEST}
...                                                  && ngap.CoreNetworkAssistanceInformationForInactive_element
${NGAP_INITIAL_UE_MESSAGE_WITH_NR_CELL_ID} =    ${NGAP_INITIAL_UE_MESSAGE} && ngap.NRCellIdentity == 0x0000004002
${NGAP_PDU_SESSION_RESOURCE_SETUP_RESPONSE_UNSUCCESSFUL_TRANSFER_CAUSE_UE_INACTIVE}=    ${NGAP_PDU_SESSION_RESOURCE_SETUP_RESPONSE}
...                                                                                     && ngap.pDUSessionResourceSetupUnsuccessfulTransfer
...                                                                                     && ngap.radioNetwork == 40
${NGAP_UE_CONTEXT_RELEASE_REQUEST_DUE_TO_USER_INACTIVITY} =    ${NGAP_UE_CONTEXT_RELEASE_REQUEST} && (ngap.radioNetwork == 20)
${VM_IP}=    127.0.0.1

*** Keywords ***
Start Vm Ethernet Interfaces
    Start Vm Ethernet Interface    if_name=eth3:AMF2_NG_ADDR    ip_with_mask=10.0.1.3/24
    Start Vm Ethernet Interface    if_name=eth3:AMF3_NG_ADDR    ip_with_mask=10.0.1.4/24

Stop Vm Ethernet Interfaces
    Stop Vm Ethernet Interface    if_name=eth3:AMF2_NG_ADDR    ip_with_mask=10.0.1.3/24
    Stop Vm Ethernet Interface    if_name=eth3:AMF3_NG_ADDR    ip_with_mask=10.0.1.4/24

Set VM IP
    ${source_ipv4}=    Run    ip a | grep eth0 -A 2 | grep -w inet | awk {'print $2'} | awk -F/ {'print $1'}
    Set Suite Variable    ${VM_IP}    ${source_ipv4}

Get Vm IP and Replace
    [Arguments]    ${delta_scf}    ${suite_path}
    Run    sed -i 's/vm_tceIpAddress/${VM_IP}/' ${suite_path}/config/default/${delta_scf}

Remove Vm IP from delta
    [Arguments]    ${delta_scf}    ${suite_path}
    Run    sed -i 's/${VM_IP}/vm_tceIpAddress/' ${suite_path}/config/default/${delta_scf}

Set Core Network Assistance Information For RRC Inactive State In Initial Context Setup Request
    [Arguments]    ${ue_id}    ${amf_id}=1    ${plmn_id}=311:489    ${tac_id}=200
    ${command} =  catenate  SEPARATOR=
    ...           amf_ue_ics_param id=${amf_id} ue=${ue_id} core_network_assistance_info=on
    ...           \ ue_identity_index_value=${ue_id} ue_specific_drx=64
    ...           \ periodic_registration_update_timer=1:10min plmn_id=${plmn_id} tac_id=${tac_id}
    Execute Egate Command    cmd=${command}
    Sleep    1

Set Parameters For UE RRC Resume Request
    [Arguments]    ${ue_id}    ${gnb_id}    ${cell_nr}    ${msg}    ${cause}
    Execute Egate Command    cmd=ue_nr_rrc_resume_request_param id=${ue_id} gnb=${gnb_id} cell=${cell_nr} msg=${msg} cause=${cause}

Set Parameters For UE RRC Resume Request With Action
    [Arguments]              ${ue_id}    ${gnb_id}    ${cell_nr}    ${msg}    ${cause}    ${action}
    Execute Egate Command    cmd=ue_nr_rrc_resume_request_param id=${ue_id} gnb=${gnb_id} cell=${cell_nr} msg=${msg} cause=${cause} action=${action}

Set PDU Param Internal Traffic
    [Arguments]              ${ue_id}    ${pdu_id}=1
    Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal

Send UE RRC Resume Request
    [Arguments]    ${ue_id}
    Execute Egate Command    cmd=ue_nr_rrc_resume id=${ue_id}

Wait For Release RRC Inactive Conditions Met
    Verify Tcpdump Log    packet_filter=${RRC_RELEASE}    timeout=20

Wait For Release RRC Inactive Conditions Not Met
    Verify Tcpdump Log    packet_filter=${RRC_RELEASE}    timeout=35

Wait For Timer T380 To Expire
    Verify Tcpdump Log    packet_filter=${RRC_RESUME_REQUEST_1} && nr-rrc.resumeCause == 8    timeout=305

Set UE To Ignore Paging
    [Arguments]    ${ue_id}=3
    Execute Egate Command    cmd=ue_param id=${ue_id} ignore_paging=on

AMF NG Context Release
    [Arguments]    ${ue_id}=6    ${cause}=RN_radio_connection_with_ue_lost
    Execute Egate Command    cmd=ue_ng_ctx_release id=${ue_id} by=amf cause=${cause}

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

Verify Traces For Successful Transition To RRC CONNECTED By MO Signaling
    Verify Tcpdump Log    packet_filter=${F1AP_PAGING}
    Verify Tcpdump Log    packet_filter=${F1AP_INITIAL_UL_RRC_MESSAGE_TRANSFER_WITH_RRCRESUMEREQ1_MO_SIGNALING}
    Verify Tcpdump Log    packet_filter=${E1AP_BEARER_CONTEXT_MODIFICATION_REQUEST_WITH_PDU_MOD}
    Verify Tcpdump Log    packet_filter=${E1AP_BEARER_CONTEXT_MODIFICATION_RESPONSE_TWO_DRB}
    Verify Tcpdump Log    packet_filter=${RRC_RESUME_WITH_RADIO_BEARER_CONFIG}
    Verify Tcpdump Log    packet_filter=${RRC_RESUME_REQUEST_1_CAUSE_MO_SIGNALING}
    Verify Tcpdump Log    packet_filter=${RRC_RESUME_COMPLETE}
    Verify Tcpdump Log    packet_filter=${NGAP_PDU_SESSION_RESOURCE_MODIFY_REQUEST}    number_of_messages=2
    Verify Tcpdump Log    packet_filter=${NGAP_PDU_SESSION_RESOURCE_MODIFY_RESPONSE}    number_of_messages=2

Verify Traces For Successful Reselection Of UE In RRC INACTIVE
    Verify Tcpdump Log    packet_filter=${F1AP_INITIAL_UL_RRC_MESSAGE_TRANSFER_WITH_RRC_RESUME_REQUEST}
    Verify Tcpdump Log    packet_filter=${F1AP_DL_RRC_MESSAGE_TRANSFER_WITH_RRC_SETUP_CELL2}
    Verify Tcpdump Log    packet_filter=${F1AP_UL_RRC_MESSAGE_TRANSFER_WITH_RRC_SETUP_COMPLETE}    number_of_messages=2
    Verify Tcpdump Log    packet_filter=${RRC_RESUME_REQUEST_CAUSE_RNA_UPDATE}
    Verify Tcpdump Log    packet_filter=${RRC_SETUP_CELL2}
    Verify Tcpdump Log    packet_filter=${RRC_SETUP_COMPLETE_CELL2}
    Verify Ngap Messages    packet_filter=${NGAP_INITIAL_UE_MESSAGE_WITH_NR_CELL_ID}

Verify Traces For RRC Setup After Resuming UE
    Verify Tcpdump Log    packet_filter=${F1AP_INITIAL_UL_RRC_MESSAGE_TRANSFER_WITH_RRC_RESUME_REQUEST_1}
    Verify Tcpdump Log    packet_filter=${F1AP_DL_RRC_MESSAGE_TRANSFER_WITH_RRC_SETUP}    number_of_messages=2
    Verify Tcpdump Log    packet_filter=${F1AP_UL_RRC_MESSAGE_TRANSFER_WITH_RRC_SETUP_COMPLETE}    number_of_messages=2
    Verify Tcpdump Log    packet_filter=${RRC_RESUME_REQUEST_1}
    Verify Tcpdump Log    packet_filter=${RRC_SETUP}    number_of_messages=2
    Verify Tcpdump Log    packet_filter=${RRC_SETUP_COMPLETE}    number_of_messages=2
    Verify Ngap Messages    packet_filter=${NGAP_INITIAL_UE_MESSAGE}    number_of_messages=2

Verify Traces For RRCRelease After Unsuccessful Transition To RRC INACTIVE
    Verify Tcpdump Log    packet_filter=${RRC_RELEASE_WITHOUT_SUSPEND}
    Verify Tcpdump Log    packet_filter=${NGAP_UE_CONTEXT_RELEASE_REQUEST}
    Verify Tcpdump Log    packet_filter=${NGAP_UE_CONTEXT_RELEASE_COMMAND}

Verify Traces For Inactive UE Release After MaxUeRrcInactTime Timer Expired
    Verify Tcpdump Log    packet_filter=${NGAP_UE_CONTEXT_RELEASE_COMMAND}
    Verify Tcpdump Log    packet_filter=${F1AP_UE_CONTEXT_RELEASE_COMMAND}
    Verify Tcpdump Log    packet_filter=${F1AP_UE_CONTEXT_RELEASE_COMPLETE}
    Verify Tcpdump Log    packet_filter=${E1AP_BEARER_CONTEXT_RELEASE_COMMAND}
    Verify Tcpdump Log    packet_filter=${E1AP_BEARER_CONTEXT_RELEASE_COMPLETE}
    Verify Tcpdump Log    packet_filter=${NGAP_UE_CONTEXT_RELEASE_COMPLETE}

Verify Traces For UE Release
    Verify Ngap Messages    packet_filter=${NGAP_UE_CONTEXT_RELEASE_COMMAND}
    Verify Ngap Messages    packet_filter=${NGAP_UE_CONTEXT_RELEASE_COMPLETE}
    Verify Tcpdump Log    packet_filter=${E1AP_BEARER_CONTEXT_RELEASE_COMMAND}
    Verify Tcpdump Log    packet_filter=${E1AP_BEARER_CONTEXT_RELEASE_COMPLETE}
    Verify Tcpdump Log    packet_filter=${NGAP_UE_CONTEXT_RELEASE_COMPLETE}

Verify Traces For Successful RNA Update
    Verify Tcpdump Log    packet_filter=${RRC_RELEASE_WITH_SUSPEND_WITH_T380}    number_of_messages=2
    Verify Tcpdump Log    packet_filter=${F1AP_INITIAL_UL_RRC_MESSAGE_TRANSFER_WITH_RRCRESUMEREQ1_RNA_UPDATE}
    Verify Tcpdump Log    packet_filter=${F1AP_UE_CONTEXT_RELEASE_REQUEST_WITH_RRC_RELEASE_WITH_SUSPEND}    number_of_messages=2
    Verify Tcpdump Log    packet_filter=${F1AP_UE_CONTEXT_RELEASE_COMPLETE}    number_of_messages=2

Verify Traces For NG Resets
    Verify Ngap Messages    packet_filter=${NGAP_RESET}    number_of_messages=2
    Verify Ngap Messages    packet_filter=${NGAP_RESET_ACKNOWLEDGE}    number_of_messages=2
    Verify Tcpdump Log    packet_filter=${E1AP_RESET_WITH_RADIO_NETWORK}
    Verify Tcpdump Log    packet_filter=${E1AP_RESET_WITH_TRANSPORT}
    Verify Tcpdump Log    packet_filter=${E1AP_RESET_ACKNOWLEDGE}    number_of_messages=2
