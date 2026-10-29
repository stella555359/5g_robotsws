*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00    CLOUD_5G_I_BOO_AP_LOO

Documentation    :copyright: Nokia
...              :authors: Mateusz Kuropka
...              :contact: mateusz.kuropka@nokia.com


Resource     taf/rfrl/common_resources/robot/libraries_instances.robot
Resource     testsuite/Wroclaw/RRM/WRO_2/resources/testing_env.robot
Resource     ../keywords/messaging.robot
Resource     ../keywords/traffic.robot
Resource     ../keywords/tshark_verifying.robot
Resource     Keywords_CB006733.robot
Resource     ../../VRF_WRO2_T04/resources/ute_report.robot
Library      ta5g_tshark
Library      taf.ul.ettf.setups
Library      ta5g_testline_management
Library      ta5g_iphy
Library      ta5g_egate
Library      ta5g_ue_mobility
Variables    ta5g_global_var
Variables    logging_policy.py


Suite Setup    Run Keywords    With Swconfig Flags        flags=@{SWCONFIG_FLAGS_LIST}
...            AND             Update And Put Iphy Xml    input_filepath=${CURDIR}/config/iphy_xml_6733.xml
...            AND             With Gnb Configuration    commissioning=${SCFC}
...            AND             Wait For Testline Icmp Echo Replies And Ssh Services
...            AND             Start Default Logging
...            AND             With Simulator Configuration    config=${BASIC_SETUP}


*** Variables ***
${BASIC_SETUP}=    ${CURDIR}/config/wts_6733_basic.cfg
${SCFC}=    CB006733_B4.xml
${ue_id}=    4
${pdu_id}=    3
@{SWCONFIG_FLAGS_LIST}=        ${CB007208}
${CB007208}=        0x890073=0    # Disabled CB007208

${UEContextModificationRequestForA4SCellAdd}=
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

${RRCReconfiguratonForA4SCellAdd}=
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

${RRCReconfiguratonPCellAfterA4RetryTimerExpire}=
...    nr-rrc.rrcReconfiguration_element &&
...    nr-rrc.measIdToAddModList==6 &&
...    nr-rrc.gapUE==1 &&
...    nr-rrc.gapOffset==0 &&
...    nr-rrc.mgl==1 &&
...    nr-rrc.mgrp==3 &&
...    nr-rrc.mgta==0

${RRCReconfiguratonPCellAfterA4Fr1SuperVisionTimerExpire}=
...    nr-rrc.rrcReconfiguration_element &&
...    nr-rrc.measIdToRemoveList==6 &&
...    nr-rrc.measGapConfig_element &&
...    nr-rrc.gapUE==0

*** Test Cases ***
CB006733-A_B4_Deactivation_of_A4_measurements_for_SCell_addition_after_A4_supervision_timer_expiry_and_reactivation_upon_A4_retry_timer_expiry
    Register UE To gNB    ue_id=${ue_id}
    Wait for SuperVisionTimer Expired More Than 6 Times    36s
    Verify Ue Context Modification Request    ${UEContextModificationRequestForA4SCellAdd}
    Verify 4FDD SCells Addition    ${RRCReconfiguratonForA4SCellAdd}
    Verify RRC After A4Fr1SuperVisionTimerExpire    ${RRCReconfiguratonPCellAfterA4Fr1SuperVisionTimerExpire}
    Verify RRC After A4RetryTimerExpire    ${RRCReconfiguratonPCellAfterA4RetryTimerExpire}
    Release UE    ue_id=${ue_id}    pdu_id=${pdu_id}
    [Teardown]    Add Scout Data Info To Testcase
