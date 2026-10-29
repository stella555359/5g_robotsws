*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00
    ...    CLOUD_5G_I_BOO_AP_LOO    VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD

Documentation    :copyright: Nokia
...              :authors: Malgorzata Muth
...              :contact: malgorzata.muth@nokia.com


Resource     taf/rfrl/common_resources/robot/libraries_instances.robot
Resource     testsuite/Wroclaw/RRM/WRO_2/resources/testing_env.robot
Resource     ../keywords/messaging.robot
Resource     ../keywords/traffic.robot
Resource     ../keywords/L3_Call.robot
Resource    ../keywords/tshark_verifying.robot
Resource     ./verify_ta_messaging/verify_UEContextModification.robot
Resource     ./verify_ta_messaging/verify_PrivateMessage.robot
Resource     ta_messaging/flow.robot
Resource     Keywords_CB006733.robot
Library      ta5g_tshark
Library      ta_messaging
Library      taf.ul.ettf.retry_context
Library      taf.ul.ettf.setups
Library      ta5g_testline_management
Library      ta5g_iphy
Library      ta5g_egate
Library      ta5g_pm_counters
Variables    CB006733_messaging_filters.py
Variables    logging_policy.py
Library      ./verify_ta_messaging/CB006733.py

Suite Setup    Run Keywords    Log to console    Full scfc commissioning with iphy.xml upload
...            AND             Update And Put Iphy Xml    input_filepath=${CURDIR}/config/iphy_xml_6733.xml
...            AND             With Gnb Configuration    commissioning=${scfc}
...            AND             Wait For Testline Icmp Echo Replies And Ssh Services
...            AND             With Simulator Configuration    config=${BASIC_SETUP}
...            AND             Wait For Next Full Pm Interval



*** Variables ***
${LOGS_COMPRESSION}=    ${True}
${LOGGING_POLICY}=    NO_TRAFFIC_LOGS_POLICY
${BASIC_SETUP}=       ${CURDIR}/config/wts_6733_B_B12.cfg
${scfc}=              scfc_B_B12.xml
${GNB_ID}=            2
${PCELL_ID}=          4  #Cell 4
${PHYSCELL_ID}=       54  #Cell 4
${UE_ID}=             4
${PDU_4}=             4
${GW_ID_4}=           4
${LOCAL_MOID}=    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-4
${supervision_timer_fr1} =    9
${a4_retry_timer} =    1
${meas_id_rsrq}=    4
${meas_id_rsrpandrsrq}=    5
${meas_id_A2}=     9
${phycell_id_cell2}=    52
${phycell_id_cell3}=    53
${scell_rsrp_1}=    90
${scell_rsrq_1}=    90
${scell_rsrp_2}=    30
${scell_rsrq_2}=    60
${A2_cmd}=
...    id=${UE_ID} meas_id=9 event=A2 srsrp_nr=5 srsrq_nr=10
...    scell=1 scell_rsrp=90 scell_rsrq=90
...    scell=2 scell_rsrp=30 scell_rsrq=60

*** Test Cases ***
CB006733-B_B12_HO_A1_A2_PCell_Change_to_A4_based_SCell

    Attach UE And Verify Establishing PDU Session With A4 Configuration B_B12   ue_id=${UE_ID}    cell_id=${PCELL_ID}
    ...    gnb_id=${GNB_ID}    pdu_id=${PDU_4}    gw_id=${GW_ID_4}
    Verify that UEContextModificationRequest_3 of 3 contains measConfig with A4 and A2 configuration for 3CC
    Verify in UECtxModResp_3 out of 3 that measGapConfigIE is present for gNB2
    Verify if UE4 RRCReconfiguration 2 of 2 contains A4 configuration B_B12

    Trigger A4 Measurement And Start High Data Traffic B_B12    ue_id=${UE_ID}    gnb_id=${GNB_ID}
    ...    meas_id_rsrq=${meas_id_rsrq}    meas_id_rsrpandrsrq=${meas_id_rsrpandrsrq}    pdu_id=${PDU_4}
    ...    phycell_id_cell2=${phycell_id_cell2}    phycell_id_cell3=${phycell_id_cell3}

    Verify if UE4 Measurement Report 1 of 2 is expected A4 measurement for Cell2 B_B12
    Verify that PrivateMessage_1 of 3 is BufferMonitoringNotification for gNB2
    Verify if UE4 Measurement Report 2 of 2 is expected A4 measurement for Cell3 B_B12
    Verify that PrivateMessage_2 of 3 is BufferMonitoringNotification for gNB2
    Verify that PrivateMessage_3 of 3 is BufferCriterionNotification for gNB2
    Verify if UE4 RRCReconfiguration 1 of 2 contains A4 measurements deconfiguration and measGap release B_B12
    Verify SCell Addition Messages BB12     ue_id=${UE_ID}
    Verify if UE4 RRCReconfiguration 2 of 2 contains A2 measurements configuration before PCell Change


    Trigger A2 Measurement For PCell Change    ue_id=${UE_ID}    gnb_id=${GNB_ID}    A2_cmd=${A2_cmd}    meas_id_A2=${meas_id_A2}
    Verify if UE4 Measurement Report is expected A2 measurement for PCell Change
    Verify Successful PCell Change And SCells Release     ue_id=${UE_ID}
    Verify if UE4 RRCReconfiguration contains A4 and A2 measurements deconfiguration

    Release UE    ue_id=${UE_ID}    pdu_id=${PDU_4}
