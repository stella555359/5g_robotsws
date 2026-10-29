*** Settings ***
Documentation
...  Author:  marcin.plawny@nokia.com
...  Mantainer:  marcin.plawny@nokia.com

Resource    taf/rfrl/common_resources/robot/libraries_instances.robot
Resource    ../../../../resources/airphone/5G_SW_WRO_Keywords.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T08/features/airphone/CB008225/CB008225_G/CB008225_G_Keywords_And_Variables.robot
Library    testsuite/Wroclaw/RRM/resources/scout_report.py
Library    ta5g_testline_management
Library    ta5g_iphy
Library    ta5g_enb
Library    ta5g_delta
Library    ta5g_throughput
Library    testsuite/Wroclaw/RRM/resources/syslog_checker.py

*** Variables ***
${CELL_ID_1} =    (f1ap.nRCellIdentity == 00:00:04:00:10)
${CELL_ID_2} =    (f1ap.nRCellIdentity == 00:00:04:00:20)
${RRC_RELEASE_WITH_SUSPEND_CONFIG} =    ${RRC_RELEASE} && nr-rrc.suspendConfig_element
${RRC_RELEASE_WITHOUT_SUSPEND} =    ${RRC_RELEASE} && !(nr-rrc.suspendConfig_element)
${RRC_RESUME_REQUEST_1_CAUSE_MT_ACCESS_CELL_1} =    ${RRC_RESUME_REQUEST_1} && nr-rrc.resumeCause == 2 && ${CELL_ID_1}
${RRC_RESUME_REQUEST_1_CAUSE_MT_ACCESS_CELL_2} =    ${RRC_RESUME_REQUEST_1} && nr-rrc.resumeCause == 2 && ${CELL_ID_2}
${RRC_RESUME_REQUEST_1_CAUSE_RNA_UPDATE_CELL_1} =    ${RRC_RESUME_REQUEST_1} && nr-rrc.resumeCause == 8 && ${CELL_ID_1}
${RRC_RESUME_REQUEST_1_CAUSE_RNA_UPDATE_CELL_2} =    ${RRC_RESUME_REQUEST_1} && nr-rrc.resumeCause == 8 && ${CELL_ID_2}
${RRC_RESUME_REQUEST_CAUSE_RNA_UPDATE_CELL_2} =    ${RRC_RESUME_REQUEST} && nr-rrc.resumeCause == 8 && ${CELL_ID_2}
${RRC_RESUME_REQUEST_1_CAUSE_MO_SIGNALING_CELL_1} =    ${RRC_RESUME_REQUEST_1} && nr-rrc.resumeCause == 3 && ${CELL_ID_1}
${RRC_SETUP_CELL1} =    ${RRC_SETUP} && nr-rrc.scramblingID0 == 50
${RRC_SETUP_CELL2} =    ${RRC_SETUP} && nr-rrc.scramblingID0 == 51
${NGAP_LOCATION_REPORT_WITH_TIMESTAMP} =    ${NGAP_LOCATION_REPORT_ULI} && ngap.timeStamp

*** Keywords ***
Set Core Network Assistance Information For RRC Inactive State In Initial Context Setup Request
    [Arguments]    ${ue_id}    ${amf_id}=1    ${plmn_id}=311:489    ${tac_id}=200
    ${command} =  catenate  SEPARATOR=
    ...           amf_ue_ics_param id=${amf_id} ue=${ue_id} core_network_assistance_info=on
    ...           \ ue_identity_index_value=${ue_id} ue_specific_drx=64
    ...           \ periodic_registration_update_timer=1:10min plmn_id=${plmn_id} tac_id=${tac_id}
    Execute Egate Command    cmd=${command}
    Sleep    1    reason=waiting for procedure being finished

Verify Traces For RRCRelease After Unsuccessful Transition To RRC INACTIVE
    Verify Tcpdump Log    packet_filter=${RRC_RELEASE_WITHOUT_SUSPEND}
    Verify Tcpdump Log    packet_filter=${NGAP_UE_CONTEXT_RELEASE_REQUEST}
    Verify Tcpdump Log    packet_filter=${NGAP_UE_CONTEXT_RELEASE_COMMAND}

Set Parameters For UE RRC Resume Request
    [Arguments]    ${ue_id}    ${gnb_id}    ${cell_nr}    ${msg}    ${cause}
    Execute Egate Command    cmd=ue_nr_rrc_resume_request_param id=${ue_id} gnb=${gnb_id} cell=${cell_nr} msg=${msg} cause=${cause}

Set SIM TTI
    Execute Egate Command    cmd=sim_param_set TTI=2

Set PDU Param Internal Traffic
    [Arguments]              ${ue_id}    ${pdu_id}=1
    Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal

Wait For RRC Release Message Without Suspend Config
    [Arguments]    ${number_of_messages}=1
    Verify Tcpdump Log    packet_filter=${RRC_RELEASE_WITHOUT_SUSPEND}    number_of_messages=${number_of_messages}    timeout=19

Wait For Timer T380 To Expire
    Verify Tcpdump Log    packet_filter=${RRC_RESUME_REQUEST_1} && nr-rrc.resumeCause == 8    timeout=305

Start DL Traffic
    [Arguments]    ${ue_id}    ${pdu_id}
    Start Data Traffic    ues=${ue_id}    direction=dl    pdu=${pdu_id}    throughput=1mbps
    Sleep    5s    reason=Wait for data traffic transfer to start
    Check DL Bearer Stats    ue_id=${ue_id}    pdu_id=${pdu_id}
    Stop Data Traffic    ues=${ue_id}    direction=dl    pdu=${pdu_id}

Area Of Interest Configuration Reset
    Execute Egate Command    cmd=area_of_interest_configuration reset
