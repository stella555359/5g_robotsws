*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00
    ...    CLOUD_5G_I_BOO_AP_LOO

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
Resource     ./verify_ta_messaging/verify_PrivateMessage.robot
Resource     ta_messaging/flow.robot
Resource     Keywords_CB006733.robot
Library      ta5g_tshark
Library      ta_messaging
Library      taf.ul.ettf.retry_context
Library      taf.ul.ettf.setups
Library      ta5g_testline_management
Library      ta5g_delta
Library      ta5g_iphy
Library      DateTime
Variables    CB006733_messaging_filters.py
Variables    logging_policy.py
Library      ./verify_ta_messaging/CB006733.py

Suite Setup    Run Keywords    Log to console    Full scfc commissioning with iphy.xml upload
...            AND             Update And Put Iphy Xml    input_filepath=${CURDIR}/config/iphy_xml_6733.xml
...            AND             Configure simulated interfaces
...            AND             Set Custom SCTP RTO Min Time
...            AND             With Gnb Configuration    commissioning=${scfc}
...            AND             Wait For Testline Icmp Echo Replies And Ssh Services
...            AND             With Simulator Configuration    config=${BASIC_SETUP}

Test Teardown     Detach UE    ue_id=${UE_ID}

*** Variables ***
${LOGS_COMPRESSION}=    ${True}
${LOGGING_POLICY}=    FULL_POLICY
${BASIC_SETUP}=       ${CURDIR}/config/wts_6733_BB15.cfg
${scfc}=              full_scfc_CB006733_B_B15.xml
${GNB_ID}=            2
${PCELL_ID_SOURCE}=          1  #Cell 1
${PCELL_ID_TARGET}=          4  #Cell 4
${PHYSCELL_ID_SOURCE}=       51  #Cell 1
${PHYSCELL_ID_TARGET}=       54  #Cell 4
${UE_ID}=             11
@{cells_after_SCell_addition} =    8    9


*** Test Cases ***
CB006733-B_B15_HO_NSA_UE_Context_-_Configuration_of_A1_measurement_for_SCell_addition_on_target_PSCell_during_intra-gNB_PSCell_change

    Attach UE In NSA Mode And Verify Success    ue_id=${UE_ID}    gNB_id=${GNB_ID}    cell_id=${PCELL_ID_SOURCE}
    Verify candidateCellInfoListMN during SgNBAdditionRequest BB15    ue_id=${UE_ID}
    Verify A2 Measurement Configuration For HO NSA Mode BB15    ue_id=${UE_ID}
    Verify that UEContextSetupResponse contains reconfigurationWithSync for UE${UE_ID} BB15

    Set Message Flow Expectations for A2 Measurement Trigger B_B15   gNB_id=${GNB_ID}
    Load Measurement Gap Configuration for Simulated ENB    ue_id=${UE_ID}     gap_pattern=gp5:0    mgta=ms0
    Trigger A2 Measurement    ue_id=${UE_ID}     meas_id=1    srsrp_nr=25    timeout=60    NSA_MODE=${TRUE}
    Check Message Flow Expectations for A2 Measurement Trigger B_B15    gNB_id=${GNB_ID}

    Verify that triggered A2 measurement report for BB15 contains requested parametrers for gNB${GNB_ID}
    Verify that SgBModificationRequired contains measuredFrequenciesSN IE
    Verify that SgBModificationRequest From MeNB contains measGapConfig configuration IEs
    Verify that UEContextModificationRequest to DU contains measGapConfig configuration IEs
    Verify that SgNBModificationReqAck contains A1 ans A3 configuration for HO

    Set Message Flow Expectations for A3 Measurement Trigger B_B15   gNB_id=${GNB_ID}
    Trigger A3 Measurement    ue_id=${UE_ID}     meas_id=3    nrsrp_nr=100    cell_id=${PHYSCELL_ID_TARGET}    timeout=60    NSA_MODE=${TRUE}
    Check Message Flow Expectations for A3 Measurement Trigger B_B15    gNB_id=${GNB_ID}

    Verify that triggered A3 measurement report for BB15 contains requested parametrers for gNB${GNB_ID}
    Verify that UEContextModificationRequest_1 of 4 contains measConfig with A1 for SCell Add in NSA mode for gNB${GNB_ID} B_B15
    Verify that SgBModificationRequired contains reconfigurationWithSync and measConfig for SCell addition NSA
    Verify that SgNBModificationRequest contains measGapConfig release
    Verify that UEContextModificationRequest_3 of 4 contains measGapConfig release for gNB${GNB_ID}

    Set Message Flow Expectations for A1 Measurement Trigger B_B15   gNB_id=${GNB_ID}
    Trigger A1 Measurement    ue_id=${UE_ID}    meas_id=1    srsrp_nr=90    NSA_MODE=${TRUE}
    Check Message Flow Expectations for A1 Measurement Trigger B_B15    gNB_id=${GNB_ID}
    Verify that triggered A1 measurement report for BB15 contains requested parametrers for gNB${GNB_ID}
    Verify that PrivateMessage_1 of 1 is BufferMonitoringNotification for gNB${GNB_ID}

    Set Message Flow Expectations after data traffic start B_B15    ue_id=${UE_ID}    gNB_id=${GNB_ID}
    Start High DL non-GBR Data Traffic NSA   ue_id=${UE_ID}    trf_level=80
    Wait For Traffic to stabilize    inactive_timer=5
    Verify That Throughput Is Reached On Specific Cells    ue_id=${UE_ID}    cells_list=${cells_after_SCell_addition}    expected_throughput=10Mbps
    Stop Data Traffic NSA    ue_id=${UE_ID}   bearer_id=2
    Check Message Flow Expectations after data traffic start B_B14    ue_id=${UE_ID}    gNB_id=${GNB_ID}

    Verify that PrivateMessage_1 of 1 is BufferCriterionNotification for gNB${GNB_ID}
    Verify that UEContextModificationRequest and Response 1 of 3 contain SCell Addition after HO for gNB${GNB_ID}
    Verify SgNBModificationRequired if contains A2 measurement for SCell Release BB15
