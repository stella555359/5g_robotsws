*** Settings ***
Documentation    :copyright: Nokia
Resource         ../../../resources/airphone/5G_SW_WRO_Keywords.robot
Library          ../../../resources/scout_report.py
Library          ../../../resources/airphone/multignb_testlines_variables.py
Library          CB008490_LD/resources/CB008490_Keywords.py    WITH NAME    sskpy
Library          ta5g_testline_management
Library          ta5g_ue_measurements
Library          ta5g_pm_counters
Library          ta5g_throughput
Library          ta5g_ue_mobility
Library          ta5g_iphy
Library          ta5g_enb

*** Variables ***
@{REMOTE_HOSTS} =                   ${EMPTY}
${XNAP_SNODE_RELEASE_REQUIRED} =    xnap.SNodeReleaseRequired_element && xnap.radioNetwork == 22
${SERV_CELL_INDEX_1} =              nr-rrc.servCellIndex == 1
${SCELL_INDEX_2} =                  nr-rrc.sCellIndex == 2
${SCELL_INDEX_3} =                  nr-rrc.sCellIndex == 3
${SCELL_INDEX_4} =                  nr-rrc.sCellIndex == 4
${SCELL_INDEX_5} =                  nr-rrc.sCellIndex == 5
${SCELL_INDEX_6} =                  nr-rrc.sCellIndex == 6
${SCELL_INDEX_7} =                  nr-rrc.sCellIndex == 7
${SCELL_INDEX_8} =                  nr-rrc.sCellIndex == 8
${SCELL_INDEX_LIST} =               ${SCELL_INDEX_2} && ${SCELL_INDEX_3} && ${SCELL_INDEX_4} && ${SCELL_INDEX_5} &&
...                                 ${SCELL_INDEX_6} && ${SCELL_INDEX_7} && ${SCELL_INDEX_8}
${PHYS_CELL_ID_52} =                nr-rrc.physCellId == 52
${PHYS_CELL_ID_53} =                nr-rrc.physCellId == 53
${PHYS_CELL_ID_54} =                nr-rrc.physCellId == 54
${PHYS_CELL_ID_55} =                nr-rrc.physCellId == 55
${PHYS_CELL_ID_56} =                nr-rrc.physCellId == 56
${PHYS_CELL_ID_57} =                nr-rrc.physCellId == 57
${PHYS_CELL_ID_58} =                nr-rrc.physCellId == 58
${PHYS_CELL_ID_59} =                nr-rrc.physCellId == 59
${PHYS_CELL_ID_LIST} =              ${PHYS_CELL_ID_52} && ${PHYS_CELL_ID_53} && ${PHYS_CELL_ID_54} && ${PHYS_CELL_ID_55} &&
...                                 ${PHYS_CELL_ID_56} && ${PHYS_CELL_ID_57} && ${PHYS_CELL_ID_58} && ${PHYS_CELL_ID_59}
${SCELL_TO_ADD_MOD_LIST} =          nr-rrc.sCellToAddModList
${UPLINK_CONFIG} =                  nr-rrc.uplinkConfig_element


*** Keywords ***
Wait ${x:\d+}s For ${reason}
    Sleep    ${x}s    ${reason}

Send Command To Not Send SNodeModificationConfirm Message
    [Arguments]     ${gnb_id}=3
    Execute Egate Command   cmd=gnb_nrdc_modify_param id=${gnb_id} action=do_not_send_confirm
    Sleep  2s    Wait Measurement To Configure

Verify DL thoughput For UE1 On SCells
    expected_throughput_for_ue_should_be_reached    ue_id=1    throughput=150    direction=dl    selection_type=average

Verify Secondary Node Addition Flow
    Verify Tcpdump Log    packet_filter=${E1AP_BEARER_CONTEXT_SETUP_REQUEST}
    Verify Tcpdump Log    packet_filter=${E1AP_BEARER_CONTEXT_SETUP_RESPONSE}
    Verify Tcpdump Log    packet_filter=${E1AP_BEARER_CONTEXT_MODIFICATION_REQUEST}    number_of_messages=5    relation_symbol= >=
    Verify Tcpdump Log    packet_filter=${E1AP_BEARER_CONTEXT_MODIFICATION_RESPONSE}    number_of_messages=5     relation_symbol= >=
    Verify Tcpdump Log    packet_filter=${F1AP_UE_CONTEXT_SETUP_REQUEST}
    Verify Tcpdump Log    packet_filter=${F1AP_UE_CONTEXT_SETUP_RESPONSE}
    Verify Tcpdump Log    packet_filter=${XNAP_SNODE_ADDITION_REQUEST}
    Verify Tcpdump Log    packet_filter=${XNAP_SNODE_ADDITION_REQUEST_ACKNOWLEDGE}
    Verify Tcpdump Log    packet_filter=${XNAP_XNU_ADDRESS_INDICATION}

Attach UE${ue_id:\d+} And Establish PDU Session On GNB${gnb_id:\d+} With 2 Qos Flow/s
    Attach_ue    ue_id=${ue_id}    enb=${gnb_id}    cell=1
    Set Internal Traffic Type For UE    ue=${ue_id}    pdu=${pdu_id}
    Establish Pdu Session        ue_id=${ue_id}    timeout=30
    Trigger PDU Session Modify Procedure For UE${ue_id} and QoS Flow ID eq 2

Trigger PDU Session Modify Procedure For UE${ue_id:\d+} and QoS Flow ID eq ${qosflows:\d+}
    Execute Egate Command And Wait For Data
    ...     cmd=ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id} qosflows_to_add=${qosflows}
    ...     pass_regexp=message c1 : rrcReconfigurationComplete

UE${ue_id:\d+} sends A4 measurement ID eq ${meas_id:\d+} for inter-gNB NR-DC PSCell ID eq ${phycell_id:\d+} addition
    Execute Egate Command And Wait For Data
    ...    cmd=ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} phycell_id=${phycell_id} nrsrp_nr=60 report_type=event_triggered event=A4
    ...    pass_regexp=SCellIndex 3 activated successfully at airphone

Verify SNodeAdditionRequestAcknowledge Message Content
    Verify Tcpdump Log    packet_filter=${XNAP_SNODE_ADDITION_REQUEST_ACKNOWLEDGE} && ${SERV_CELL_INDEX_1}
    Verify Tcpdump Log    packet_filter=${XNAP_SNODE_ADDITION_REQUEST_ACKNOWLEDGE} && ${SCELL_TO_ADD_MOD_LIST} && ${SCELL_INDEX_LIST}
    Verify Tcpdump Log    packet_filter=${XNAP_SNODE_ADDITION_REQUEST_ACKNOWLEDGE} && ${PHYSCELLID_52}
    Verify Tcpdump Log    packet_filter=${XNAP_SNODE_ADDITION_REQUEST_ACKNOWLEDGE} && ${PHYS_CELL_ID_LIST}
    Verify Tcpdump Log    packet_filter=${XNAP_SNODE_ADDITION_REQUEST_ACKNOWLEDGE} && ${UPLINK_CONFIG}
