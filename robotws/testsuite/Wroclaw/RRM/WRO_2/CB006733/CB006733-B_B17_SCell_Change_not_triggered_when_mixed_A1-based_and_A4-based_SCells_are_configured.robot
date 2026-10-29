*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00    CLOUD_5G_I_BOO_AP_LOO    QC_44295    QCD_MN_RAN    QCP_RAN_VRF

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
...            AND             With Swconfig Flags        flags=@{SWCONFIG_FLAGS_LIST}
...            AND             Update And Put Iphy Xml    input_filepath=${iphy_xml}
...            AND             With Gnb Configuration    commissioning=${scfc}
...            AND             Wait For Testline Icmp Echo Replies And Ssh Services
...            AND             Start Default Logging
...            AND             With Simulator Configuration    config=${basic_setup}
...            AND             Setup Tshark With Nokia F1AP Plugin

*** Variables ***
${iphy_xml}=    ${CURDIR}/config/iphy_xml_6733.xml
${basic_setup}=       ${CURDIR}/config/wts_6733_BB17.cfg
${scfc}=    CB006733_B_B17.xml
@{SWCONFIG_FLAGS_LIST}=        ${CB007208}
${CB007208}=        0x890073=0    # Disabled CB007208

${ue_id}=    4
${a1_meas_id}=    1
${a4_meas_id}=    2
${srsrp_nr}=    60
${cell2_pci}    52
${nrsrq_nr}=    95
${number_of_messages}    2

${BufferMonitoringVerification}=
...    nokiaf1ap.BufferMonitoringNotification_element &&
...    nokiaf1ap.BufferMonitoring==0

${BufferCriterionVerification}=
...    nokiaf1ap.BufferCriterionNotification_element &&
...    nokiaf1ap.BufferCriterion==0

${RRCReconfigurationAfterA4}=
...    nr-rrc.rrcReconfiguration_element &&
...    nr-rrc.measIdToRemoveList==1 &&
...    nr-rrc.MeasId==2 &&
...    nr-rrc.gapUE==0

${UeContextModReqAfterA4}=
...    nokiaf1ap.SCell_ToBeSetupMod_List==2 &&
...    nokiaf1ap.sCellIndex==1 &&
...    nokiaf1ap.nRCellIdentity==00:00:04:00:20 &&
...    nokiaf1ap.sCellIndex==2 &&
...    nokiaf1ap.nRCellIdentity==00:00:04:00:30

${UeContextModRespAfterA4}=
...    nokiaf1ap.UEContextModificationResponse_element &&
...    nr-rrc.sCellToAddModList==2 &&
...    nr-rrc.physCellId==52 &&
...    nr-rrc.physCellId==53

${RRCReconfigurationWithA2}=
...    nr-rrc.rrcReconfiguration_element &&
...    nr-rrc.measObjectToAddModList==2 &&
...    nr-rrc.freqBandIndicatorNR==66 &&
...    nr-rrc.freqBandIndicatorNR==71 &&
...    nr-rrc.reportConfigToAddModList==1 &&
...    nr-rrc.eventId==1 &&
...    nr-rrc.measTriggerQuantity.rsrq==49 &&
...    nr-rrc.measIdToRemoveList==1 &&
...    nr-rrc.MeasId==1 &&
...    nr-rrc.measIdToAddModList==2

*** Test Cases ***
CB006733-B_B17_SCell_Change_not_triggered_when_mixed_A1-based_and_A4-based_SCells_are_configured
    Register UE To gNB    ue_id=${ue_id}
    Wait For UE Register    1s
    Trigger A1 RSRP Measurement    ue_id=${ue_id}    meas_id=${a1_meas_id}    srsrp_nr=${srsrp_nr}
    Trigger A4 RSRQ Measurement    ue_id=${ue_id}    pci=${cell2_pci}    meas_id=${a4_meas_id}    nrsrq_nr=${nrsrq_nr}
    Start Data Traffic
    Verify Buffer Monitoring Notification    ${BufferMonitoringVerification}    ${number_of_messages}
    Verify Buffer Criterion Notification    ${BufferCriterionVerification}
    Verify RRC A4 Measurement Removal    ${RRCReconfigurationAfterA4}
    Verify 2 SCells Addition After A4 Event Trigger    ${UeContextModReqAfterA4}
    Verify 3CC Configuration After A4 Event Trigger    ${UeContextModRespAfterA4}
    Verify RRC SCell Addition    ${RRCReconfigurationWithA2}
    [Teardown]    Run Keywords    Deregister Ue    ue_id=${ue_id}
    ...    AND    Add Scout Data Info To Testcase
