*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00
    ...    CLOUD_5G_I_LPQ_AP_LOO    VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD

Documentation    :copyright: Nokia
...              :authors: Blanka Gozdek, Izabela Prosniak
...              :contact: blanka.gozdek@nokia.com, izabela.prosniak@nokia.com


Resource     taf/rfrl/common_resources/robot/libraries_instances.robot
Resource     testsuite/Wroclaw/RRM/WRO_2/resources/testing_env.robot
Resource     ../keywords/messaging.robot
Resource     ../keywords/traffic.robot
Resource     ../keywords/L3_Call.robot
Resource    ../keywords/tshark_verifying.robot
Resource     ./verify_ta_messaging/verify_PrivateMessage.robot
Resource     ./verify_ta_messaging/verify_UEContextModification.robot
Resource     ta_messaging/flow.robot
Resource     Keywords_CB006733.robot
Library      ta5g_tshark
Library      ta_messaging
Library      taf.ul.ettf.retry_context
Library      taf.ul.ettf.setups
Library      ta5g_testline_management
Library      ta5g_iphy
Library      ta5g_pm_counters
Variables    CB006733_messaging_filters.py
Variables    logging_policy.py
Library      ./verify_ta_messaging/CB006733.py

Suite Setup    Run Keywords    Log to console    Full scfc commissioning with iphy.xml upload
...            AND             Update And Put Iphy Xml    input_filepath=${CURDIR}/config/iphy_xml_6733.xml
...            AND             With Gnb Configuration    commissioning=${scfc}
...            AND             Wait For Testline Icmp Echo Replies And Ssh Services
...            AND             With Simulator Configuration    config=${SETUP_A_B12}
...            AND             Wait For Next Full Pm Interval


*** Variables ***
${LOGS_COMPRESSION}=    ${True}
${LOGGING_POLICY}=    NO_TRAFFIC_LOGS_POLICY  # Can be set to FULL_POLICY_WITH_EMIL to capture Emil logs during retests
${SETUP_A_B12}=       ${CURDIR}/config/wts_6733_AB12.cfg
${scfc}=              full_scfc_CB006733_A_B12.xml
${GNB_ID}=            2
${PCELL_ID}=          4  #Cell 4
${UE_ID}=             4
${PDU_4}=             4
${GW_ID_4}=           4
${COUNTER_ID}=    M55118C00030
${COUNTER_NAME}=    A4_MEASUR_ACT_SCELL_ADD_SA
${LOCAL_MOID}=    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-4
${meas_id_rsrq}=    1
${meas_id_rsrp}=    2
${phycell_id_cell2}=    52
${phycell_id_cell3}=    53
${inactive_timer}=    13s
${meas_id_A2_cell2}=    4
${meas_id_A2_cell3}=    5
${scell2_rsrq}=    40
${scell3_rsrq}=    35
${srsrp_nr}=       90
${srsrq_nr}=       0
${param1}=
    ...    id=${ue_id} meas_id=${meas_id_A2_cell2} event=A2 srsrp_nr=${srsrp_nr}
    ...    srsrq_nr=${srsrq_nr} scell=1 scell_rsrq=${scell2_rsrq}
${param2}=
    ...    id=${ue_id} meas_id=${meas_id_A2_cell3} event=A2 srsrp_nr=${srsrp_nr}
    ...    srsrq_nr=${srsrq_nr} scell=2 scell_rsrq=${scell3_rsrq}


*** Test Cases ***
CB006733-A_B12_A4_measurements_reactivation_after_last_SCell_Release
    Attach UE And Verify Establishing PDU Session With A4 Configuration    ue_id=${UE_ID}    cell_id=${PCELL_ID}
    ...    gnb_id=${GNB_ID}    pdu_id=${PDU_4}    gw_id=${GW_ID_4}
    Verify that UEContextModificationRequest_3 of 3 contains measConfig with A4 configuration for 3CC
    Verify in UECtxModResp_3 out of 3 that measGapConfigIE is present for gNB2
    Verify 6733 A4 Activation Message Contents AB12    ue_id=${UE_ID}

    Trigger A4 Measurement And Start High Data Traffic    ue_id=${UE_ID}    gnb_id=${GNB_ID}    meas_id_rsrq=${meas_id_rsrq}
    ...    meas_id_rsrp=${meas_id_rsrp}    pdu_id=${PDU_4}    phycell_id_cell2=${phycell_id_cell2}    phycell_id_cell3=${phycell_id_cell3}
    Verify if UE4 Measurement Report 1 of 2 is expected A4 measurement for Cell2
    Verify if UE4 Measurement Report 2 of 2 is expected A4 measurement for Cell3
    Verify if UE4 RRCReconfiguration 1 of 2 contains A4 measurements deconfiguration and measConfig release
    Verify SCell Addition Messages AB12    ue_id=${UE_ID}
    Verify if UE4 RRCReconfiguration 2 of 2 contains A2 measurements configuration
    Verify if UE4 RRCReconfiguration 2 of 2 contains SCellToBeSetupModList
    Wait For Supervision Timer Expiration    inactive_timer=${inactive_timer}


    Trigger A2 Measurements And Wait for A4 Measurement Reactivation    ue_id=${UE_ID}    gnb_id=${GNB_ID}    param1=${param1}    param2=${param2}

    Verify that PrivateMessage_1 of 3 is BufferMonitoringNotification for gNB2
    Verify that PrivateMessage_2 of 3 is BufferMonitoringNotification for gNB2
    Verify that PrivateMessage_3 of 3 is BufferCriterionNotification for gNB2

    Verify if UE4 Measurement Report 1 of 2 is expected A2 measurement for Cell2
    Verify if UE4 Measurement Report 2 of 2 is expected A2 measurement for Cell3
    Verify Successful Cell2 Release    ue_id=${UE_ID}
    Verify if UE4 RRCReconfiguration 1 of 7 contains Cell2 release
    Verify Successful Cell3 Release    ue_id=${UE_ID}
    Verify if UE4 RRCReconfiguration 2 of 7 contains Cell3 release
    Verify that UEContextModificationRequest_7 of 19 contains measConfig with A4 reactivation
    Verify in UECtxModResp_7 out of 19 that measGapConfigIE is present for gNB2

    Release UE    ue_id=${UE_ID}    pdu_id=${PDU_4}
    Verify Pm Counters 6733    ue_id=${UE_ID}    counter_id=${COUNTER_ID}    counter_name=${COUNTER_NAME}    local_moid=${LOCAL_MOID}
