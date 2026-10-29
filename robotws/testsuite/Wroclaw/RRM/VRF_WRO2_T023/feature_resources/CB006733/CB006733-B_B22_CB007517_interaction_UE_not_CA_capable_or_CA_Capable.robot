*** Settings ***
Documentation    Keywords for the CB006733_B_B22

Library     ta5g_ue_mobility
Resource    resources/CB006733_keywords.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T023/resources/airphone/L3_call.robot


*** Variables ***
${ue_id_6733_b22}=    4
${a4_retry_timer_6733_b22}=    1

${UeContextModReq_6733_b22}=
...    f1ap.UEContextModificationRequest_element &&
...    nr-rrc.measObjectToAddModList==3 &&
...    nr-rrc.freqBandIndicatorNR==41 &&
...    nr-rrc.freqBandIndicatorNR==71 &&
...    nr-rrc.freqBandIndicatorNR==66 &&
...    nr-rrc.a4_Threshold==0 &&
...    nr-rrc.measIdToAddModList==2

${UeContextModResp_6733_b22}=
...    f1ap.UEContextModificationResponse_element &&
...    nr-rrc.gapUE==1 &&
...    nr-rrc.gapOffset==0 &&
...    nr-rrc.mgta==0

${RRCReconfigurationBeforeRetryTimerExp_6733_b22}=
...    nr-rrc.rrcReconfiguration_element &&
...    nr-rrc.s_MeasureConfig==0 &&
...    nr-rrc.ssb_RSRP==127

${RRCReconfigurationAfterRetryTimerExp_6733_b22}=
...    nr-rrc.rrcReconfiguration_element &&
...    nr-rrc.measObjectToAddModList==2 &&
...    nr-rrc.freqBandIndicatorNR==71 &&
...    nr-rrc.freqBandIndicatorNR==66 &&
...    nr-rrc.eventId==3 &&
...    nr-rrc.measTriggerQuantity.rsrp==80 &&
...    nr-rrc.measIdToAddModList==2 &&
...    nr-rrc.gapUE==1


*** Keywords ***
TC__CB006733-B_B22_CB007517_interaction_UE_not_CA_capable_or_CA_Capable_but_not_possible_to_configure_with_CA
    Register UE To gNB    ue_id=${ue_id_6733_b22}
    Wait For A4 Retry Timer Expiration    a4_retry_timer=${a4_retry_timer_6733_b22}
    Verify A4 Measurement Configuration    ${UeContextModReq_6733_b22}
    Verify Measurement Gap Configuration    ${UeContextModResp_6733_b22}
    Verify RRC Before A4RetryTimer Expiration   ${RRCReconfigurationBeforeRetryTimerExp_6733_b22}
    Verify RRC A4 Measurement Configuration    ${RRCReconfigurationAfterRetryTimerExp_6733_b22}

    [Teardown]    Deregister Ue    ue_id=${ue_id_6733_b22}
