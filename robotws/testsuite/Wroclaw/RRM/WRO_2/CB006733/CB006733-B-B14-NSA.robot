*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00
    ...    CLOUD_5G_I_BOO_AP_LOO

Documentation    :copyright: Nokia
...              :authors: Izabela Prosniak, Malgorzata Muth
...              :contact: izabela.prosniak@nokia.com, malgorzata.muth@nokia.com


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
Library      DateTime
Variables    CB006733_messaging_filters.py
Variables    logging_policy.py
Library      ./verify_ta_messaging/CB006733.py

Suite Setup    Run Keywords    Log to console    Full scfc commissioning with iphy.xml upload
...            AND             Update And Put Iphy Xml    input_filepath=${CURDIR}/config/iphy_xml_6733.xml
...            AND             Set Custom SCTP RTO Min Time
...            AND             With Gnb Configuration    commissioning=${scfc}
...            AND             Wait For Testline Icmp Echo Replies And Ssh Services
...            AND             Create ENB device with alias 'ENB3' identified by ip=10.0.1.137
...            AND             With Simulator Configuration    config=${BASIC_SETUP}

Test Teardown     Detach UE    ue_id=${UE_ID}

*** Variables ***
${LOGS_COMPRESSION}=    ${True}
${LOGGING_POLICY}=    NO_TRAFFIC_LOGS_POLICY
${BASIC_SETUP}=       ${CURDIR}/config/wts_6733_B_B14.cfg
${scfc}=              CB006733_B_B14.xml
${GNB_ID}=            2
${PCELL_ID}=          4  #Cell 4
${PHYS_CELL_ID}=      54  #Cell 4
${UE_ID}=             11
${PDU_4}=             4
${GW_ID_4}=           4
${a4_retry_timer}=    1
${meas_id_rsrp}=      1
@{cells_after_SCell_addition} =    8    9


*** Test Cases ***
CB006733-B_B14_NSA_UE_Context_Activate_A1_PCell_measurement_for_A4-based_SCell__Candidates_with_A1_fallback_enabled
    Attach UE In NSA Mode And Verify Success    ue_id=${UE_ID}    gNB_id=${GNB_ID}    cell_id=${PCELL_ID}
    Verify A1 Measurement Configuration NSA Mode    ue_id=${UE_ID}
    Verify candidateCellInfoListMN during SgNBAdditionRequest    ue_id=${UE_ID}
    Verify that UEContextSetupRequest contains measConfig with A1 configuration for UE11
    Verify that UEContextSetupResponse contains reconfigurationWithSync for UE11
    Verify that SgNBAdditionRequestAcknowledge contains reconfigurationWithSync and A1 measurement for UE11

    Set Message Flow Expectations for A1 Measurement Trigger B_B14   ue_id=${UE_ID}    gNB_id=${GNB_ID}
    Trigger A1 Measurement For RSRP B_B14    ue_id=${UE_ID}    meas_id_rsrp=${meas_id_rsrp}
    Check Message Flow Expectations for A1 Measurement Trigger B_B14    ue_id=${UE_ID}
    Verify that PrivateMessage_1 of 1 is BufferMonitoringNotification for gNB2
    Verify that triggered A1 report contains requested parametrers for gNB2

    Set Message Flow Expectations after data traffic start B_B14    ue_id=${UE_ID}    gNB_id=${GNB_ID}
    Start High DL non-GBR Data Traffic NSA   ue_id=${UE_ID}    trf_level=130
    Wait For Traffic to stabilize    inactive_timer=15
    Verify That Throughput Is Reached On Specific Cells    ue_id=${UE_ID}    cells_list=${cells_after_SCell_addition}    expected_throughput=10Mbps
    Stop Data Traffic NSA    ue_id=${UE_ID}   bearer_id=2
    Check Message Flow Expectations after data traffic start B_B14    ue_id=${UE_ID}    gNB_id=${GNB_ID}
    Verify that PrivateMessage_1 of 1 is BufferCriterionNotification for gNB2
    Verify that UEContextModificationRequest and Response 1 of 3 contain SCell Addition for gNB2
    Verify SgNBModificationRequired if contains A2 measurement for SCell Release
