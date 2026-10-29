*** Settings ***
Documentation    Keywords for the CB006733_B_B17

Library     ta5g_ue_mobility
Resource    resources/CB006733_keywords.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T023/resources/airphone/L3_call.robot


*** Variables ***
${ue_id_6733_b17}=    4
${a1_meas_id_6733_b17}=    1
${a4_meas_id_6733_b17}=    2
${srsrp_nr_6733_b17}=    60
${cell2_pci_6733_b17}    52
${nrsrq_nr_6733_b17}=    95
${number_of_messages_6733_b17}=    2

${BufferMonitoringVerification_6733_b17}=
...    nokiaf1ap.BufferMonitoringNotification_element &&
...    nokiaf1ap.BufferMonitoring==0

${BufferCriterionVerification_6733_b17}=
...    nokiaf1ap.BufferCriterionNotification_element &&
...    nokiaf1ap.NokiaBufferCriterion==0

${RRCReconfigurationAfterA4_6733_b17}=
...    nr-rrc.rrcReconfiguration_element &&
...    nr-rrc.measIdToRemoveList==1 &&
...    nr-rrc.MeasId==2 &&
...    nr-rrc.gapUE==0

${UeContextModReqAfterA4_6733_b17}=
...    nokiaf1ap.SCell_ToBeSetupMod_List==2 &&
...    nokiaf1ap.sCellIndex==1 &&
...    nokiaf1ap.nRCellIdentity==00:00:04:00:20 &&
...    nokiaf1ap.sCellIndex==2 &&
...    nokiaf1ap.nRCellIdentity==00:00:04:00:30

${UeContextModRespAfterA4_6733_b17}=
...    nokiaf1ap.UEContextModificationResponse_element &&
...    nr-rrc.sCellToAddModList==2 &&
...    nr-rrc.physCellId==52 &&
...    nr-rrc.physCellId==53

${RRCReconfigurationWithA2_6733_b17}=
...    nr-rrc.rrcReconfiguration_element &&
...    nr-rrc.freqBandIndicatorNR==66 &&
...    nr-rrc.freqBandIndicatorNR==71 &&
...    nr-rrc.reportConfigToAddModList==1 &&
...    nr-rrc.eventId==1 &&
...    nr-rrc.measTriggerQuantity.rsrq==49 &&
...    nr-rrc.measIdToRemoveList==1 &&
...    nr-rrc.MeasId==1 &&
...    nr-rrc.measIdToAddModList==2


*** Keywords ***
TC__CB006733-B_B17_SCell_Change_not_triggered_when_mixed_A1-based_and_A4-based_SCells_are_configured
    Register UE To gNB    ue_id=${ue_id_6733_b17}
    Wait For UE Register    1s
    Trigger A1 RSRP Measurement    ue_id=${ue_id_6733_b17}    meas_id=${a1_meas_id_6733_b17}    srsrp_nr=${srsrp_nr_6733_b17}
    Trigger A4 RSRQ Measurement    ue_id=${ue_id_6733_b17}    pci=${cell2_pci_6733_b17}    meas_id=${a4_meas_id_6733_b17}
    ...    nrsrq_nr=${nrsrq_nr_6733_b17}
    Start DL Data Traffic
    Verify Buffer Monitoring Notification    ${BufferMonitoringVerification_6733_b17}    ${number_of_messages_6733_b17}
    Verify Buffer Criterion Notification    ${BufferCriterionVerification_6733_b17}
    Verify RRC A4 Measurement Removal    ${RRCReconfigurationAfterA4_6733_b17}
    Verify 2 SCells Addition After A4 Event Trigger    ${UeContextModReqAfterA4_6733_b17}
    Verify 3CC Configuration After A4 Event Trigger    ${UeContextModRespAfterA4_6733_b17}
    Verify RRC SCell Addition    ${RRCReconfigurationWithA2_6733_b17}

    [Teardown]    Deregister Ue    ue_id=${ue_id_6733_b17}
