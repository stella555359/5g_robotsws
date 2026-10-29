*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00    CLOUD_5G_I_BOO_AP_LOO

Documentation    :copyright: Nokia
...              :authors: Krystian Kozlowski, Vira Solomashenko
...              :contact: krystian.kozlowski@nokia.com, vira.solomashenko@nokia.com


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
...            AND             Update And Put Iphy Xml    input_filepath=${CURDIR}/config/iphy_xml_6733.xml
...            AND             With Gnb Configuration    commissioning=${SCFC}
...            AND             Setup Tshark With Nokia F1AP Plugin
...            AND             Wait For Testline Icmp Echo Replies And Ssh Services
...            AND             Start Default Logging
...            AND             With Simulator Configuration    config=${BASIC_SETUP}
...            AND             Wait For Next Full Pm Interval

*** Variables ***
${BASIC_SETUP}=    ${CURDIR}/config/wts_6733_AB10.cfg
${SCFC}=    CB006733_A_B10.xml

${ue_id}=    4
${pdu_id}=    3
${nrsrq_nr}=    95
${nrsrp_nr}=    90
${phycell_id}=    53
${a4_meas_id_rsrp}=    3
${a4_meas_id_rsrq}=    4

${UeContextModReqBeforeA4}=
...  nr-rrc.measObjectToAddModList == 5 &&
...  nr-rrc.reportConfigToAddModList == 2 &&
...  nr-rrc.measIdToAddModList == 6 &&
...  nr-rrc.gapUE == 1

${BufferMonitoringMessageRSRP}=
...  nokiaf1ap.BufferMonitoring == 0 &&
...  sctp.data_ssn == 13

${BufferMonitoringMessageRSRQ}=
...  nokiaf1ap.BufferMonitoring == 0 &&
...  sctp.data_ssn == 14

${BufferCriterionNotification}=
...  nokiaf1ap.BufferCriterion == 0

${RRCReconfigurationAfterA4}=
...  nr-rrc.measIdToRemoveList == 6 &&
...  nr-rrc.gapUE == 0 &&
...   sctp.data_payload_proto_id == 62

${UeContextModReqAfterA4}=
...  nokiaf1ap.SCell_ToBeSetupMod_List == 1 &&
...  nokiaf1ap.nRCellIdentity == 00:00:04:00:30 &&
...  nokiaf1ap.sCellIndex == 1

${UeContextModRespAfterA4}=
...  nr-rrc.sCellToAddModList == 1 &&
...  nr-rrc.physCellId == 53 &&
...  nokiaf1ap.procedureCode == 7 &&
...  nr-rrc.rlc_BearerToAddModList == 1

${RRCReconfigurationWithA2}=
...   nr-rrc.eventId == 1 &&
...   nr-rrc.a2_Threshold == 1 &&
...   nr-rrc.measTriggerQuantity.rsrq == 49 &&
...   nr-rrc.measIdToAddModList == 1 &&
...   nr-rrc.measId == 7 &&
...   nokiaf1ap.F1AP_PDU == 0

${COUNTER_ID}=             M55118C00031
${COUNTER_NAME}=           A4_SCELL_ADDED_SA
${LOCAL_MOID}=             PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-4


*** Test Cases ***
CB006733-A_B10_A4-based_SCell_Addition_rsrpAndRsrq
    Attach UE To gNB    ue_id=${ue_id}
    Verify A4 Measurement Configuration    ${UeContextModReqBeforeA4}
    Trigger A4 RSRP Measurement for SCell    ue_id=${ue_id}    pci=${phycell_id}    meas_id=${a4_meas_id_rsrp}    nrsrp_nr=${nrsrp_nr}
    Trigger A4 RSRQ Measurement for SCell    ue_id=${ue_id}    pci=${phycell_id}    meas_id=${a4_meas_id_rsrq}    nrsrq_nr=${nrsrq_nr}
    Verify RSRP Buffer Monitoring Notification Message    ${Buffer_Monitoring_Message_RSRP}
    Verify RSRQ Buffer Monitoring Notification Message    ${Buffer_Monitoring_Message_RSRQ}
    Start Data Traffic
    Verify Buffer Criterion Notification    ${BufferCriterionNotification}
    Verify RRC A4 Measurement Removal    ${RRCReconfigurationAfterA4}
    Verify SCell Addition After A4 Event Trigger    ${UeContextModReqAfterA4}
    Verify 2CC CA Configuration After A4 Event Trigger    ${UeContextModRespAfterA4}
    Verify RRC SCell Addition    ${RRCReconfigurationWithA2}
    Verify Pm Counter For Scell Added SA    counter_id=${COUNTER_ID}    counter_name=${COUNTER_NAME}    local_moid=${LOCAL_MOID}
    [Teardown]    Release UE    ue_id=${ue_id}    pdu_id=${pdu_id}
