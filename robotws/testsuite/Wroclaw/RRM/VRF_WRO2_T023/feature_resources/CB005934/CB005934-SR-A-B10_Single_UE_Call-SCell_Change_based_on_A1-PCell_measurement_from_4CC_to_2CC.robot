*** Settings ***
Documentation    Keywords for the CB005934_A_B10

Library     ta5g_pm_counters
Resource    testsuite/Wroclaw/RRM/WRO_2/keywords/messaging.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T023/resources/airphone/measurements.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T023/resources/airphone/L3_call.robot
Resource    resources/CB005934_keywords.robot

*** Variables ***
${ue_id_5934_b10}=    1
${pcell_id_5934_b10}=    1
${pdu_id_5934_b10}=    1
${gw_id_5934_b10}=    1
${a1_meas_id_5934_b10}=    1
${a1_rsrp_scell_change_5934_b10}=    90
${scell_change_a1_meas_id_5934_b10}=    5
${local_moid_5934_b10}=    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1

${Verification_A1_measurement_5934_b10}=
...  f1ap && nr-rrc.rrcReconfiguration_element &&
...  nr-rrc.measObjectToAddModList == 3 &&
...  nr-rrc.reportConfigToAddModList == 2 &&
...  nr-rrc.measIdToAddModList == 4 &&
...  nr-rrc.reportConfigToRemoveList == 1 &&
...  nr-rrc.measIdToRemoveList == 1
${rrcReconfigurationComplete_5934_b10}=
...  f1ap &&
...  nr-rrc.rrcReconfigurationComplete_element &&
...  nr-rrc.rrc_TransactionIdentifier == 3
${ULRRCMessageTransfer_5934_b10}=
...  f1ap &&
...  nr-rrc.measurementReport_element &&
...  nr-rrc.measId == 5 &&
...  nr-rrc.physCellId == 51
${UEContextModificationRequest_5934_b10}=
...  f1ap.UEContextModificationRequest_element &&
...  f1ap.SCell_ToBeRemoved_List == 3 &&
...  f1ap.SCell_ToBeSetupMod_List == 1
${UEContextModificationResponse_5934_b10}=
...  f1ap.UEContextModificationResponse_element &&
...  nr-rrc.maxPayloadSize == 4 &&
...  nr-rrc.resourceList == 2 &&
...  nr-rrc.sCellToAddModList == 1 &&
...  nr-rrc.sCellToReleaseList == 3
${DLRRCMessageTransfer_5934_b10}=
...  f1ap &&
...  nr-rrc.rrcReconfiguration_element &&
...  nr-rrc.measIdToRemoveList == 4 &&
...  nr-rrc.MeasId == 5 &&
...  nr-rrc.measObjectToRemoveList == 3 &&
...  nr-rrc.reportConfigToRemoveList == 2
${RRCReconfigCompleteIndicator_5934_b10}=
...  f1ap.UEContextModificationRequest_element &&
...  f1ap.RRCReconfigurationCompleteIndicator == 0
${GNB_DUConfigurationQuery_5934_b10}=
...  f1ap.UEContextModificationRequest_element &&
...  f1ap.GNB_DUConfigurationQuery == 0

*** Keywords ***
TC__CB005934-SR-A-B10_Single_UE_Call-SCell_Change_based_on_A1-PCell_measurement_for_SA_UE_from_4CC_F-F-F-F_CA_to_2CC_F-T_CA
    Attach UE And Establish PDU Session    ue_id=${ue_id_5934_b10}    cell_id=${pcell_id_5934_b10}    pdu_id=${pdu_id_5934_b10}
    ...    gw_id=${gw_id_5934_b10}
    Trigger A1 Measurement    ue_id=${ue_id_5934_b10}     meas_id=${a1_meas_id_5934_b10}    srsrp_nr=75
    Verify Message After A1 Measurement Triggered    packet_filter=${Verification_A1_measurement_5934_b10}
    Trigger A1 Measurement    ue_id=${ue_id_5934_b10}    meas_id=${scell_change_a1_meas_id_5934_b10}    srsrp_nr=${a1_rsrp_scell_change_5934_b10}
    Verify Message After A1 Measurement Triggered    packet_filter=${rrcReconfigurationComplete_5934_b10}
    Verify Message After A1 Measurement Triggered    packet_filter=${ULRRCMessageTransfer_5934_b10}
    Verify Message After A1 Measurement Triggered    packet_filter=${UEContextModificationRequest_5934_b10}
    Verify Message After A1 Measurement Triggered    packet_filter=${UEContextModificationResponse_5934_b10}
    Verify Message After A1 Measurement Triggered    packet_filter=${DLRRCMessageTransfer_5934_b10}
    Verify Message After A1 Measurement Triggered    packet_filter=${RRCReconfigCompleteIndicator_5934_b10}
    ...    number_of_messages=0    relation_symbol= >
    Verify Message After A1 Measurement Triggered    packet_filter=${GNB_DUConfigurationQuery_5934_b10}    number_of_messages=0    relation_symbol= >
    Verify Pm Counters After SCell Change    local_moid=${local_moid_5934_b10}

    [Teardown]    Release UE    ue_id=${ue_id_5934_b10}    pdu_id=${pdu_id_5934_b10}

Verify Message After A1 Measurement Triggered
    [Arguments]    ${packet_filter}    ${number_of_messages}=1    ${relation_symbol}= ==
    Verify Tcpdump Log    packet_filter=${packet_filter}    number_of_messages=${number_of_messages}    relation_symbol=${relation_symbol}

Verify Pm Counters After SCell Change
    [Arguments]    ${local_moid}
    Wait For Next Full Pm Interval
    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    Verify Any Counters In File
        ...    M55118C06506    +1      SCELL_CHANGE_ATT_SA
        ...    M55118C06507    +1      SCELL_CHANGE_SUCC_SA
        ...    M55124C03001    +3      NRRCC_RRC_RECONF_SENT
        ...    M55124C03002    +3      NRRCC_RRC_RECONF_CMP_RECD
        ...    M55118C05507    >0      UE_PCELL_1_CONF_SCELL_DL_SA
        ...    M55118C09501    >\=0    UE_PCELL_3_CONF_SCELL_DL_SA
        ...    local_moid=${local_moid}
        ...    file_path=${pm_counter_file}
