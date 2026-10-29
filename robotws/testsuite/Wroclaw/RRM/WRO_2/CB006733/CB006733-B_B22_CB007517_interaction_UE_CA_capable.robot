*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00    CLOUD_5G_I_BOO_AP_LOO

Documentation    :copyright: Nokia
...              :authors: Jakub Magier
...              :contact: jakub.magier@nokia.com

Resource     taf/rfrl/common_resources/robot/libraries_instances.robot
Resource     testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/ute_report.robot
Resource     taf/ul/ettf/main.robot
Resource     ../keywords/messaging.robot
Resource     ../keywords/traffic.robot
Resource     ../keywords/tshark_verifying.robot
Resource     Keywords_CB006733.robot
Library      taf.ul.ettf.setups
Library      ta5g_testline_management
Library      ta5g_iphy
Library      ta5g_ue_mobility
Variables    logging_policy.py

Suite Setup    Run Keywords    Extended SupervisionTimer    20
...            AND             Update And Put Iphy Xml    input_filepath=${iphy_xml}
...            AND             With Gnb Configuration    commissioning=${scfc}
...            AND             Wait For Testline Icmp Echo Replies And Ssh Services
...            AND             Start Default Logging
...            AND             With Simulator Configuration    config=${basic_setup}

*** Variables ***
${iphy_xml}=    ${CURDIR}/config/iphy_xml_6733.xml
${basic_setup}=       ${CURDIR}/config/wts_6733_B_B22.cfg
${scfc}=    CB006733_B_B22.xml

${ue_id}=    4
${a4_retry_timer}=    1

${UeContextModReq}=
...    f1ap.UEContextModificationRequest_element &&
...    nr-rrc.measObjectToAddModList==3 &&
...    nr-rrc.freqBandIndicatorNR==41 &&
...    nr-rrc.freqBandIndicatorNR==71 &&
...    nr-rrc.freqBandIndicatorNR==66 &&
...    nr-rrc.a4_Threshold==0 &&
...    nr-rrc.measIdToAddModList==2

${UeContextModResp}=
...    f1ap.UEContextModificationResponse_element &&
...    nr-rrc.gapUE==1 &&
...    nr-rrc.gapOffset==0 &&
...    nr-rrc.mgta==0

${RRCReconfigurationBeforeRetryTimerExp}=
...    nr-rrc.rrcReconfiguration_element &&
...    nr-rrc.s_MeasureConfig==0 &&
...    nr-rrc.ssb_RSRP==127

${RRCReconfigurationAfterRetryTimerExp}=
...    nr-rrc.rrcReconfiguration_element &&
...    nr-rrc.measObjectToAddModList==2 &&
...    nr-rrc.freqBandIndicatorNR==71 &&
...    nr-rrc.freqBandIndicatorNR==66 &&
...    nr-rrc.eventId==3 &&
...    nr-rrc.measTriggerQuantity.rsrp==80 &&
...    nr-rrc.measIdToAddModList==2 &&
...    nr-rrc.gapUE==1

*** Test Cases ***
CB006733-B_B22_CB007517_interaction_UE_not_CA_capable_or_CA_Capable_but_not_possible_to_configure_with_CA
    Register UE To gNB    ue_id=${ue_id}
    Wait For A4 Retry Timer Expiration    a4_retry_timer=${a4_retry_timer}
    Verify A4 Measurement Configuration    ${UeContextModReq}
    Verify Measurement Gap Configuration    ${UeContextModResp}
    Verify RRC Before A4RetryTimer Expiration   ${RRCReconfigurationBeforeRetryTimerExp}
    Verify RRC A4 Measurement Configuration    ${RRCReconfigurationAfterRetryTimerExp}
    [Teardown]    Run Keywords    Deregister Ue    ue_id=${ue_id}
    ...    AND    Add Scout Data Info To Testcase
