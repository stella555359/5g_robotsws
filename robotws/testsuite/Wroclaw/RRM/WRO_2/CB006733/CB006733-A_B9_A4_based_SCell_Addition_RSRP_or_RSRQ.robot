*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00    CLOUD_5G_I_BOO_AP_LOO

Documentation    :copyright: Nokia
...              :authors: Jakub Magier
...              :contact: jakub.magier@nokia.com

Resource     taf/rfrl/common_resources/robot/libraries_instances.robot
Resource     testsuite/Wroclaw/RRM/WRO_2/resources/testing_env.robot
Resource     ../keywords/messaging.robot
Resource     ../keywords/traffic.robot
Resource     ../keywords/tshark_verifying.robot
Resource     Keywords_CB006733.robot
Library      taf.ul.ettf.setups
Library      ta5g_testline_management
Library      ta5g_iphy
Library      ta5g_pm_counters
Library      ta5g_ue_mobility
Variables    logging_policy.py

Suite Setup    Run Keywords    Extended SupervisionTimer    20
...            AND             Update And Put Iphy Xml    input_filepath=${iphy_xml}
...            AND             With Gnb Configuration    commissioning=${scfc}
...            AND             Wait For Testline Icmp Echo Replies And Ssh Services
...            AND             Start Default Logging
...            AND             With Simulator Configuration    config=${basic_setup}
...            AND             Setup Tshark With Nokia F1AP Plugin
...            AND             Wait For Next Full Pm Interval

*** Variables ***
${iphy_xml}=    ${CURDIR}/config/iphy_xml_6733.xml
${basic_setup}=       ${CURDIR}/config/wts_6733_AB9.cfg
${scfc}=    CB006733_A_B9_A4_SCell_Addition.xml

${ue_id}=    4
${cell2_a4_meas_id}=    1
${cell3_a4_meas_id}=    2
${nrsrq_nr}=    95
${nrsrp_nr}=    90
${cell2_pci}    52
${cell3_pci}    53
${number_of_messages}    2

${UeContextModReqBeforeA4}=
...    nokiaf1ap.UEContextModificationRequest_element &&
...    nr-rrc.measObjectToAddModList==3 &&
...    nr-rrc.freqBandIndicatorNR==66 &&
...    nr-rrc.freqBandIndicatorNR==71 &&
...    nr-rrc.eventId==3 &&
...    nr-rrc.a4_Threshold==0 &&
...    nr-rrc.a4_Threshold==1 &&
...    nr-rrc.measIdToAddModList==3

${RRCReconfigurationAfterA4}=
...    nr-rrc.rrcReconfiguration_element &&
...    nr-rrc.measIdToRemoveList==3 && nr-rrc.gapUE==0

${BufferMonitoringVerification}=
...    nokiaf1ap.BufferMonitoringNotification_element &&
...    nokiaf1ap.BufferMonitoring==0

${BufferCriterionVerification}=
...    nokiaf1ap.BufferCriterionNotification_element &&
...    nokiaf1ap.BufferCriterion==0

${UeContextModReqAfterA4}=
...    nokiaf1ap.SCell_ToBeSetupMod_List==2 &&
...    nokiaf1ap.nRCellIdentity==00:00:04:00:20 &&
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
...    nr-rrc.eventId==1 &&
...    nr-rrc.a2_Threshold==1 &&
...    nr-rrc.measIdToAddModList==2

${LOCAL_MOID}=    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-4

*** Test Cases ***
CB006733-A_B9_A4-based_SCell_Addition_RSRP_or_RSRQ
    Register UE To gNB    ue_id=${ue_id}
    Trigger A4 RSRQ Measurement    ue_id=${ue_id}    pci=${cell2_pci}    meas_id=${cell2_a4_meas_id}    nrsrq_nr=${nrsrq_nr}
    Trigger A4 RSRP Measurement    ue_id=${ue_id}    pci=${cell3_pci}    meas_id=${cell3_a4_meas_id}    nrsrp_nr=${nrsrp_nr}
    Start Data Traffic
    Verify A4 Measurement Configuration    ${UeContextModReqBeforeA4}
    Verify Buffer Monitoring Notification    ${BufferMonitoringVerification}    ${number_of_messages}
    Verify Buffer Criterion Notification    ${BufferCriterionVerification}
    Verify RRC A4 Measurement Removal    ${RRCReconfigurationAfterA4}
    Verify 2 SCells Addition After A4 Event Trigger    ${UeContextModReqAfterA4}
    Verify 3CC Configuration After A4 Event Trigger    ${UeContextModRespAfterA4}
    Verify RRC SCell Addition    ${RRCReconfigurationWithA2}
    Verify Pm Counter For 3CC Configuration   local_moid=${LOCAL_MOID}
    [Teardown]    Deregister Ue    ue_id=${ue_id}
