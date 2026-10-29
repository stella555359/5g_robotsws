*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00
    ...    CLOUD_5G_I_LPQ_AP_LOO

Documentation    :copyright: Nokia
...              :authors: Aleksandra Sienkiel, Lukasz Klimowicz
...              :contact: aleksandra.sienkiel@nokia.com, lukasz.klimowicz@nokia.com


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
Resource     ../../VRF_WRO2_T04/resources/ute_report.robot
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
Resource     testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/iphy/wireshark_plugin.robot


*** Variables ***
${LOGS_COMPRESSION}=    ${True}
${LOGGING_POLICY}=    NO_TRAFFIC_LOGS_POLICY
${BASIC_SETUP}=       ${CURDIR}/config/wts_6733_B11.cfg
${scfc}=              scfc_6733_LPQ_A_B11.xml
${IPHY_SETUP}=        ${CURDIR}/config/iphy_xml_6733.xml

${PCELL_ID}=          4  #Cell 4
${UE_ID}=             41
${GNB_ID}=            2

#${KEEP_ALIVE}=       True
${PHYSCELL_ID}=       54  #Cell 4
${PDU_4}=             4
${GW_ID_4}=           4
${COUNTER_ID}=    M55118C00030
${COUNTER_NAME}=    A4_MEASUR_ACT_SCELL_ADD_SA
${LOCAL_MOID}=    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-4
${supervision_timer_fr1} =    9
${a4_retry_timer} =    60
${number_of_simulated_ues} =    40
${miNrCaCu_eq_15min} =    increase_counters_interval_A_B11.json


*** Test Cases ***
CB006733-A_B11_A4-based_SCell_Addition_rsrpCombined_or_rsrqCombined
    [Setup]    Run Keywords        Log to console    Full scfc commissioning with iphy.xml upload
    ...            AND             Upload Fixed Iphy Plug
    ...            AND             Update And Put Iphy Xml    input_filepath=${IPHY_SETUP}
    ...            AND             With Gnb Configuration    commissioning=${scfc}
    ...            AND             Wait For Testline Icmp Echo Replies And Ssh Services
    ...            AND             With Simulator Configuration    config=${BASIC_SETUP}
    ...            AND             Wait For Next Full Pm Interval

    Attach Multiple UEs And Verify Establishing PDU Session
    ...    number_of_ues=${number_of_simulated_ues}    cell_id=${PCELL_ID}    gnb_id=${GNB_ID}    pdu_id=${PDU_4}    gw_id=${GW_ID_4}
    ...    supervision_timer=${supervision_timer_fr1}


    Attach Robusstness UE And Verify Establishing PDU Session    ue_id=${UE_ID}    cell_id=${PCELL_ID}
    ...    gnb_id=${GNB_ID}    pdu_id=${PDU_4}    gw_id=${GW_ID_4}    supervision_timer=${supervision_timer_fr1}
    Verify if Robusstness UE${UE_ID} RRCReconfiguration 2 of 3 contains A4 configuration

    Wait Till Second Supervision Timer Launch    ue_id=${UE_ID}    cell_id=${PCELL_ID}
    ...    gnb_id=${GNB_ID}    pdu_id=${PDU_4}    gw_id=${GW_ID_4}    supervision_timer=${supervision_timer_fr1}
    ${timestamp_before_test_ue_second_supervision} =    Get Current Date
    Verify if Robusstness UE${UE_ID} RRCReconfiguration 1 of 1 contains second A4 configuration

    Set Message Flow Expectations for Robusstness UE Buffer Trigger And SCell Addition    ue_id=${ue_id}    gnb_id=${gnb_id}
    Trigger Double A4 Measurements and Start High DL Data Traffic      ue_id=${UE_ID}    pdu_id=${PDU_4}
    ...    first_meas_id=7    second_meas_id=8
    ${timestamp_after_test_ue_A4_trigger} =    Get Current Date

    Check Message Flow Expectations for Robusstness UE Buffer Trigger And SCell Addition    ue_id=${ue_id}
    Verify that PrivateMessage_1 of 3 is BufferMonitoringNotification for gNB2
    Verify that PrivateMessage_2 of 3 is BufferMonitoringNotification for gNB2
    Verify that PrivateMessage_3 of 3 is BufferCriterionNotification for gNB2
    Verify if Robusstness UE${UE_ID} RRCReconfiguration 1 of 2 contains A4 deconfiguration
    Verify if Robusstness UE${UE_ID} RRCReconfiguration 2 of 2 contains sCellToAddModList and A2 configuration

    Verify elepsed time for action    timestamp_A=${timestamp_before_test_ue_second_supervision}
    ...    timestamp_B=${timestamp_after_test_ue_A4_trigger}    message=UE${UE_ID} time between 2nd supervision and A4 trigger
    Verify That Throughput Is Reached On All SCells    ue_id=${UE_ID}    num_of_scells=2    expected_throughput=5Mbps
    Stop High Data Traffic and Launch Medium DL non-GBR Data Traffic    ue_id=${UE_ID}   pdu_id=${PDU_4}

    Wait For SupervisionTimer And RetryTimer period and Verify If all Ues are still in active state    ue_id=${UE_ID}

    Release multiple UEs    num_of_ues=${number_of_simulated_ues}
    Release UE    ue_id=${UE_ID}    pdu_id=${PDU_4}

    ${counetrs_min_value} =    Evaluate    2*${number_of_simulated_ues}
    ${counetrs_min_value_string} =    Convert To String    ${counetrs_min_value}
    Verify Pm Counters 6733    ue_id=${UE_ID}    counter_id=${COUNTER_ID}    counter_name=${COUNTER_NAME}    local_moid=${LOCAL_MOID}
    ...    condition=>${counetrs_min_value_string}

    [Teardown]    Add Scout Data Info To Testcase
