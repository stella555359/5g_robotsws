*** Settings ***
Documentation    Keywords for the CB006733_A_B4

Resource    resources/CB006733_keywords.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T023/resources/airphone/L3_call.robot


*** Variables ***
${ue_id_6733_b4}=     4
${pdu_id_6733_b4}=    3

${UEContextModificationRequestForA4SCellAdd_6733_b4}=
...    f1ap.UEContextModificationRequest_element &&
...    nr-rrc.measObjectToAddModList==6 &&
...    nr-rrc.measObjectId==1 &&
...    nr-rrc.measObjectId==2 &&
...    nr-rrc.measObjectId==3 &&
...    nr-rrc.measObjectId==4 &&
...    nr-rrc.measObjectId==5 &&
...    nr-rrc.measObjectId==6 &&
...    nr-rrc.freqBandIndicatorNR==25 &&
...    nr-rrc.freqBandIndicatorNR==41 &&
...    nr-rrc.freqBandIndicatorNR==66 &&
...    nr-rrc.freqBandIndicatorNR==71 &&
...    nr-rrc.a4_Threshold==0 &&
...    nr-rrc.a4_Threshold==1

${RRCReconfiguratonForA4SCellAdd_6733_b4}=
...    nr-rrc.rrcReconfiguration_element &&
...    nr-rrc.measObjectToAddModList==5 &&
...    nr-rrc.freqBandIndicatorNR==25 &&
...    nr-rrc.freqBandIndicatorNR==41 &&
...    nr-rrc.freqBandIndicatorNR==66 &&
...    nr-rrc.freqBandIndicatorNR==71 &&
...    nr-rrc.freqBandIndicatorNR==77 &&
...    nr-rrc.a4_Threshold==0 &&
...    nr-rrc.a4_Threshold==1 &&
...    nr-rrc.measIdToAddModList==6 &&
...    nr-rrc.gapUE==1 &&
...    nr-rrc.gapOffset==0 &&
...    nr-rrc.mgl==1 &&
...    nr-rrc.mgrp==3 &&
...    nr-rrc.mgta==0

${RRCReconfiguratonPCellAfterA4RetryTimerExpire_6733_b4}=
...    nr-rrc.rrcReconfiguration_element &&
...    nr-rrc.measIdToAddModList==6 &&
...    nr-rrc.gapUE==1 &&
...    nr-rrc.gapOffset==0 &&
...    nr-rrc.mgl==1 &&
...    nr-rrc.mgrp==3 &&
...    nr-rrc.mgta==0

${RRCReconfiguratonPCellAfterA4Fr1SuperVisionTimerExpire_6733_b4}=
...    nr-rrc.rrcReconfiguration_element &&
...    nr-rrc.measIdToRemoveList==6 &&
...    nr-rrc.measGapConfig_element &&
...    nr-rrc.gapUE==0


*** Keywords ***
TC__CB006733-A_B4_Deactivation_of_A4_measurements_for_SCell_addition_after_A4_supervision_timer_expiry_and_reactivation
    Register UE To gNB    ue_id=${ue_id_6733_b4}
    Wait for SuperVisionTimer Expired More Than 6 Times    36s
    Verify Ue Context Modification Request    ${UEContextModificationRequestForA4SCellAdd_6733_b4}
    Verify 4FDD SCells Addition    ${RRCReconfiguratonForA4SCellAdd_6733_b4}
    Verify RRC After A4Fr1SuperVisionTimerExpire    ${RRCReconfiguratonPCellAfterA4Fr1SuperVisionTimerExpire_6733_b4}
    Verify RRC After A4RetryTimerExpire    ${RRCReconfiguratonPCellAfterA4RetryTimerExpire_6733_b4}

    [Teardown]    Release UE    ue_id=${ue_id_6733_b4}    pdu_id=${pdu_id_6733_b4}
