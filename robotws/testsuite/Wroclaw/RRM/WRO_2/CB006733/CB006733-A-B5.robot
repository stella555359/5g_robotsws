*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00
    ...    CLOUD_5G_I_BOO_AP_LOO    VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD

Documentation    :copyright: Nokia
...              :authors: Lukasz Klimowicz
...              :contact: lukasz.klimowicz@nokia.com


Resource     taf/rfrl/common_resources/robot/libraries_instances.robot
Resource     testsuite/Wroclaw/RRM/WRO_2/resources/testing_env.robot
Resource     ../keywords/messaging.robot
Resource     ../keywords/traffic.robot
Resource     ../keywords/L3_Call.robot
Resource    ../keywords/tshark_verifying.robot
Resource     ./verify_ta_messaging/verify_UEContextModification.robot
Resource     ta_messaging/flow.robot
Resource     Keywords_CB006733.robot
Library      ta5g_tshark
Library      ta_messaging
Library      taf.ul.ettf.retry_context
Library      taf.ul.ettf.setups
Library      ta5g_testline_management
Library      ta5g_delta
Library      ta5g_iphy
Library      ta5g_pm_counters
Library      DateTime
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
${LOGGING_POLICY}=    FULL_POLICY
${BASIC_SETUP}=       ${CURDIR}/config/wts_6733_basic.cfg
${scfc}=              full_scfc_CB006733_A_B5.xml
${GNB_ID}=            2
${PCELL_ID}=          4  #Cell 4
${PHYSCELL_ID}=       54  #Cell 4
${UE_ID}=             4
${PDU_4}=             4
${GW_ID_4}=           4
${COUNTER_ID}=    M55118C00030
${COUNTER_NAME}=    A4_MEASUR_ACT_SCELL_ADD_SA
${LOCAL_MOID}=    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-4
${supervision_timer_fr1} =    9
${a4_retry_timer} =    60

*** Test Cases ***
CB006733-A_B5_Handling_of_A1_A2_PCell_coverage_measurement_reports_for_mobility
    Attach UE And Verify Establishing PDU Session With following A2 Measurement Trigger    ue_id=${UE_ID}    cell_id=${PCELL_ID}
    ...    gnb_id=${GNB_ID}    pdu_id=${PDU_4}    gw_id=${GW_ID_4}    supervision_timer=${supervision_timer_fr1}

    Verify A2 measurement configuration during ICS    ue_id=${UE_ID}
    Verify that UEContextModificationRequest_3 of 5 contains measConfig with A4 and A2 configuration for gNB2
    Verify that UEContextModificationResponse_3 of 5 contains measGapConfig for gNB2
    Verify if UE4 RRCReconfiguration 2 of 3 contains A4 configuration
    Verify if UE4 RRCReconfiguration 3 of 3 contains A2 deconfiguration and A1 A3 A5 configuration after A2 trigger
    Verify if UE4 Measurement Report is expected A2 measurement

    Wait for supervision timer and a4retry timer expiration    supervision_timer=${supervision_timer_fr1}  a4_retry_timer=${a4_retry_timer}
    ...    ue_id=${UE_ID}

    Trigger A1 Measurement And Wait for A4 Measurement Reactivation    ue_id=${UE_ID}    gnb_id=${GNB_ID}

    Verify if UE4 Measurement Report is expected A1 measurement
    Verify that UEContextModificationRequest_1 of 6 contains measConfig with only A2 configuration for gNB2
    Verify that UEContextModificationResponse_1 of 6 contains measGapConfig release for gNB2
    Verify if UE4 RRCReconfiguration 1 of 3 contains A2 configuration and A1 A3 A5 deconfiguration after A1 trigger
    Verify that UEContextModificationRequest_3 of 6 contains measConfig with A4 and A2 2nd configuration for gNB2
    Verify that UEContextModificationResponse_3 of 6 contains measGapConfig for gNB2
    Verify if UE4 RRCReconfiguration 2 of 3 contains 2nd A4 configuration
    Release UE    ue_id=${UE_ID}    pdu_id=${PDU_4}
    Verify Pm Counters 6733    ue_id=${UE_ID}    counter_id=${COUNTER_ID}    counter_name=${COUNTER_NAME}
    ...    local_moid=${LOCAL_MOID}    condition=2
