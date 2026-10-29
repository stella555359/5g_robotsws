*** Settings ***
Documentation    Keywords for the CB006733_B_B23

Library     ta5g_ue_mobility
Library     ute_wtssim


*** Variables ***
${UE_ID_6733_b23}=    1

${Act_Deact_A4_meas_6733_b23}=
...    nr-rrc.rrcReconfiguration_element &&
...    nr-rrc.measObjectToAddModList==1 &&
...    nr-rrc.measId==7 &&
...    nr-rrc.freqBandIndicatorNR==257 &&
...    nr-rrc.measIdToRemoveList==6

${A4_Imm_Deactivation_6733_b23}=
...    nr-rrc.rrcReconfiguration_element &&
...    nr-rrc.measIdToRemoveList==1 && nr-rrc.gapUE==0 && nr-rrc.MeasObjectId == 7 && nr-rrc.MeasId == 7

${Second_A4_Confirmation_6733_b23}=
...    nr-rrc.measIdToAddModList == 6 && nr-rrc.gapUE == 1 && !nr-rrc.reportConfigToAddModList == 2


*** Keywords ***
TC__CB006733-B_B23_CB008696_interaction_-_Deactivation_of_A4_measurements_for_FR1_CA_SCell_Addition_on_UE_Inactivity_timer_expiration
    Attach Ue With Pdu And Wait Till Inactivity Timer Expires Then Start Traffic Before A4retryTimer And A4fr1SuperTimer Expires
    Verify Deactivated A4 Measurements Where Inter-freq A4 for Idle Mode Steering Are Activated In The Same Rrc Conf Message
    ...    ${Act_Deact_A4_meas_6733_b23}
    Verify If A4 measurements for Idle mode steering are deactivated After Starting Data Traffic    ${A4_Imm_Deactivation_6733_b23}
    Verify If A4 measurements for FR1 CA SCell Addition are activated again at the UE   ${Second_A4_Confirmation_6733_b23}

    [Teardown]    Deregister Ue    ue_id=${ue_id_6733_b23}

Attach Ue With Pdu And Wait Till Inactivity Timer Expires Then Start Traffic Before A4retryTimer And A4fr1SuperTimer Expires
    Execute Egate Command    cmd=script file=${CURDIR}/resources/wts_Script_6733_B23.txt

Verify Deactivated A4 Measurements Where Inter-freq A4 for Idle Mode Steering Are Activated In The Same Rrc Conf Message
    [Arguments]    ${Act_Deact_A4_meas}
    Verify Tcpdump Log    packet_filter=${Act_Deact_A4_meas}

Verify If A4 measurements for Idle mode steering are deactivated After Starting Data Traffic
    [Arguments]    ${A4_Imm_Deactivation}
    Verify Tcpdump Log    packet_filter=${A4_Imm_Deactivation}

Verify If A4 measurements for FR1 CA SCell Addition are activated again at the UE
    [Arguments]    ${Second_A4_Confirmation}
    Verify Tcpdump Log    packet_filter=${Second_A4_Confirmation}
