*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00
...    CLOUD_5G_I_BOO_AP_LOO    VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD

Documentation    :copyright: Nokia
...              :authors: Izabela Prosniak, Blanka Gozdek
...              :contact: izabela.prosniak@nokia.com, blanka.gozdek@nokia.com

Resource     taf/rfrl/common_resources/robot/libraries_instances.robot
Resource     testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/ute_report.robot
Resource     testsuite/Wroclaw/RRM/WRO_2/resources/testing_env.robot
Resource     testsuite/Wroclaw/RRM/WRO_2/resources/ta_messaging_robot_keywords.robot
Resource     ../keywords/messaging.robot
Resource     ../keywords/L3_Call.robot
Resource     ../keywords/ue_measurements.robot
Resource     ../keywords/tshark_verifying.robot
Resource     CB012559_keywords.robot
Library      ta5g_tshark
Library      ta_messaging
Library      taf.ul.ettf.setups
Library      taf.ul.ettf.retry_context
Library      ta5g_ue_measurements
Library      ta5g_testline_management
Library      ta5g_delta
Library      ta5g_egate
Library      ta5g_iphy
Library      ta5g_ue_mobility
Library      ta5g_enb
Variables    ta5g_global_var
Variables    CB012559_messaging_filters.py
Variables    logging_policy.py

*** Variables ***
${REBOOT}=    ${False}  # Switch to true to reboot before 1st test iteration, useful when running multiple tests on the same testline
${LOGS_COMPRESSION}=    ${True}
${LOGGING_POLICY}=    NO_TRAFFIC_LOGS_POLICY  # Can be set to FULL_POLICY_WITH_EMIL to capture Emil logs during retests
${BASIC_SETUP_BB1}=    ${CURDIR}/config/wts_12559_basic_B.cfg
${BASIC_SETUP_BB4}=    ${CURDIR}/config/wts_12559_basic_BB4.cfg
${BASIC_SETUP_BB5}=    ${CURDIR}/config/wts_12559_BB5.cfg
${DELTA_12559_ACTIVATION}=    delta_12559_activation.json
${DELTA_12559_DEACTIVATION}=    delta_12559_deactivation.json
${scfc_BB1}=          full_scfc_CB012559_B_B1.xml
${scfc_BB4}=          full_scfc_CB012559_B_B4.xml
${scfc_BB5}=          full_scfc_CB012559_B_B5.xml
${GNB_ID}=            2
${PCELL_ID}=          5  #Cell 5
${UE_ID_1}=    51
${UE_ID_2}=    52
${UE_ID_5}=    5
${UE_ID_50}=    50
${SRSRP_A1}=    90
${SRSRP_A1_BB4}=    70
${MEAS_ID_A1}=    1
${MEAS_ID_A1_BB4}=    6
${MEAS_ID_A1_BB5}=    2
${MEAS_ID_A2_BB5}=    7
@{UE_IDs_release}=     51    52
${PDU_ID_1}=    1
${PDU_ID_2}=    2
@{PDU_IDs_release}=    1    2
${GW_ID_1}=    1
${GW_ID_2}=    2

*** Test Cases ***
CB012559-B_B1_A1_Scell_addition_for_1T+4F_CA
    [Setup]    Run Keywords    Log to console    Full scfc commissioning with iphy.xml upload
      ...         AND          Update And Put Iphy Xml    input_filepath=${CURDIR}/config/iphy_xml_12559.xml
      ...         AND          With Gnb Configuration    commissioning=${scfc_BB1}
      ...         AND          Wait For Testline Icmp Echo Replies And Ssh Services
      ...         AND          With Simulator Configuration    config=${BASIC_SETUP_BB1}
      ...         AND          Create gNB Alias
    [Teardown]    Release UE    ue_id=${UE_ID_2}  pdu_id=${PDU_ID_2}

    Add Scout Data Info To Testcase

    Create Multiple UEs Aliases    ue_ids=@{UE_IDs_release}
    Set 2 expected RRC Reconfiguration Request and Complete messages for UE51
    Attach UE Set Message Flow And Verify Establishing PDU Session    ue_id=${UE_ID_1}    cell_id=${PCELL_ID}    gnb_id=${GNB_ID}
    ...    pdu_id=${PDU_ID_1}    gw_id=${GW_ID_1}
    Verify that 2 RRC Reconfiguration Request and Complete messages occured for UE51
    Verify A1 Measurement Configuration for PCell   ue_id=${UE_ID_1}    filters=${A1_measurement_configuration_for_PCell_TDD}

    Set expected Measurement Report messages for UE51
    Set 3 expected UE Context Modification messages for gNB2
    Trigger and Verify A1 Based SCell Addition   ue_id=${UE_ID_1}    gNB_id=${GNB_ID}    meas_id_a1=${MEAS_ID_A1}
    ...    srsrp_a1=${SRSRP_A1}    filters=${A1_measurementReport_for_PCell_TDD}
    Verify UE1 4CC FTTT SCell Addition Message Contents    ue_id=${UE_ID_1}
    Verify that Measurement Report messages occured for UE51
    Verify 3 UE Context Modification messages for gNB2 occured

    Activate feature 12559    delta_activation=${DELTA_12559_ACTIVATION}

    Set 2 expected RRC Reconfiguration Request and Complete messages for UE52
    Attach UE Set Message Flow And Verify Establishing PDU Session    ue_id=${UE_ID_2}    cell_id=${PCELL_ID}    gnb_id=${GNB_ID}
    ...    pdu_id=${PDU_ID_2}    gw_id=${GW_ID_2}
    Verify that 2 RRC Reconfiguration Request and Complete messages occured for UE52
    Verify A1 Measurement Configuration for PCell    ue_id=${UE_ID_2}    filters=${A1_measurement_configuration_for_PCell_TDD}

    Set expected Measurement Report messages for UE52
    Set 3 expected UE Context Modification messages for gNB2
    Trigger and Verify A1 Based SCell Addition   ue_id=${UE_ID_2}    gNB_id=${GNB_ID}    meas_id_a1=${MEAS_ID_A1}
    ...    srsrp_a1=${SRSRP_A1}    filters=${A1_measurementReport_for_PCell_TDD}
    Verify UE2 5CC TFFFF SCell Addition Message Contents    ue_id=${UE_ID_2}
    Verify that Measurement Report messages occured for UE52
    Verify 3 UE Context Modification messages for gNB2 occured

    Deactivate feature 12559    delta_deactivation=${DELTA_12559_DEACTIVATION}

    Release Multiple UEs    ue_ids=@{UE_IDs_release}    pdu_ids=@{PDU_IDs_release}

    Set 2 expected RRC Reconfiguration Request and Complete messages for UE52
    Attach UE Set Message Flow And Verify Establishing PDU Session    ue_id=${UE_ID_2}    cell_id=${PCELL_ID}    gnb_id=${GNB_ID}
    ...    pdu_id=${PDU_ID_2}    gw_id=${GW_ID_2}
    Verify that 2 RRC Reconfiguration Request and Complete messages occured for UE52
    Verify A1 Measurement Configuration for PCell    ue_id=${UE_ID_2}    filters=${A1_measurement_configuration_for_PCell_TDD}

    Set expected Measurement Report messages for UE52
    Set 3 expected UE Context Modification messages for gNB2
    Trigger and Verify A1 Based SCell Addition    ue_id=${UE_ID_2}    gNB_id=${GNB_ID}    meas_id_a1=${MEAS_ID_A1}
    ...    srsrp_a1=${SRSRP_A1}    filters=${A1_measurementReport_for_PCell_TDD}
    Verify UE2 4CC TFFF SCell Addition Message Contents    ue_id=${UE_ID_2}
    Verify that Measurement Report messages occured for UE52
    Verify 3 UE Context Modification messages for gNB2 occured

CB012559-B_B4_5CC_CA_Scell_Change_Functionality_for_SA_Call_with_TDD_PCell
    [Setup]    Run Keywords    Log to console    Full scfc commissioning with iphy.xml upload
      ...         AND          Update And Put Iphy Xml    input_filepath=${CURDIR}/config/iphy_xml_12559-BB4.xml
      ...         AND          With Gnb Configuration    commissioning=${scfc_BB4}
      ...         AND          Wait For Testline Icmp Echo Replies And Ssh Services
      ...         AND          With Simulator Configuration    config=${BASIC_SETUP_BB4}
      ...         AND          Create gNB Alias
    [Teardown]    Release UE    ue_id=${UE_ID_5}    pdu_id=${PDU_ID_1}

    Add Scout Data Info To Testcase

    Create UE Alias    alias=UE${UE_ID_5}    ue_id=${UE_ID_5}    id_type=wts_5g
    Set 1 expected RRC Reconfiguration Request and Complete messages for UE5
    Attach UE Set Message Flow And Verify Establishing PDU Session    ue_id=${UE_ID_5}    cell_id=${PCELL_ID}    gnb_id=${GNB_ID}
    ...    pdu_id=${PDU_ID_1}    gw_id=${GW_ID_1}
    Verify that 1 RRC Reconfiguration Request and Complete messages occured for UE5
    Verify UE5 message RRCReconfiguration number 1 of 1 fulfils ${A1_measurement_configuration_for_PCell_TDD_BB4} content

    Set expected Measurement Report messages for UE5
    Set 1 expected RRC Reconfiguration Request and Complete messages for UE5
    Set 3 expected UE Context Modification messages for gNB2
    Trigger A1 Based SCell Addition    ue_id=${UE_ID_5}    gNB_id=${GNB_ID}    meas_id_a1=${MEAS_ID_A1}
    ...    srsrp_a1=${SRSRP_A1_BB4}
    Verify UE5 message MeasurementReport number 1 of 1 fulfils ${A1_measurementReport_for_PCell_TDD_BB4} content
    Verify that Measurement Report messages occured for UE5
    Verify that 1 RRC Reconfiguration Request and Complete messages occured for UE5
    Verify 3 UE Context Modification messages for gNB2 occured
    Verify UE5 5CC TFFFF SCell Addition Message Contents

    Set expected Measurement Report messages for UE5
    Set 1 expected RRC Reconfiguration Request and Complete messages for UE5
    Set 2 expected UE Context Modification messages for gNB2
    Trigger A1 Based SCell Change    ue_id=${UE_ID_5}    meas_id_a1=${MEAS_ID_A1_BB4}
    ...    srsrp_a1=${SRSRP_A1}
    Verify UE5 message MeasurementReport number 1 of 1 fulfils ${A1_measurementReport_for_SCell_Change} content
    Verify that Measurement Report messages occured for UE5
    Verify that 1 RRC Reconfiguration Request and Complete messages occured for UE5
    Verify 2 UE Context Modification messages for gNB2 occured
    Verify UE5 5CC TFFFF SCell Change Message Contents

CB012559-B_B5_A2_measurement_triggered_Pcell_change_from_TDD_Pcell_to_FDD_SCell
    [Setup]    Run Keywords    Log to console    Full scfc commissioning with iphy.xml upload
      ...            AND             Update And Put Iphy Xml    input_filepath=${CURDIR}/config/iphy_xml_12559.xml
      ...            AND             With Gnb Configuration    commissioning=${scfc_BB5}
      ...            AND             Wait For Testline Icmp Echo Replies And Ssh Services
      ...            AND             With Simulator Configuration    config=${BASIC_SETUP_BB5}
      ...            AND             Create gNB Alias
    [Teardown]    Release UE    ue_id=${UE_ID_50}    pdu_id=${PDU_ID_1}

    Add Scout Data Info To Testcase

    Create UE Alias    alias=UE${UE_ID_50}    ue_id=${UE_ID_50}    id_type=wts_5g
    Set 1 expected RRC Reconfiguration Request and Complete messages for UE50
    Attach UE Set Message Flow And Verify Establishing PDU Session    ue_id=${UE_ID_50}    cell_id=${PCELL_ID}    gnb_id=${GNB_ID}
    ...    pdu_id=${PDU_ID_1}    gw_id=${GW_ID_1}
    Verify that 1 RRC Reconfiguration Request and Complete messages occured for UE50
    Verify A2 Measurement Configuration for handover   ue_id=${UE_ID_50}    filters=${A2_measurement_configuration_for_handover_BB5}
    Verify A1 Measurement Configuration for PCell   ue_id=${UE_ID_50}    filters=${A1_measurement_configuration_for_PCell_TDD_BB5}
    Verify UE50 message RRCReconfiguration number 1 of 1 fulfils ${meas_config_in_RRC_Reconf_5CC_TFFFF_BB5} content

    Set 2 expected Measurement Reports messages for UE50
    Trigger and Verify A1 Based SCell Addition BB5   ue_id=${UE_ID_50}    gNB_id=${GNB_ID}    meas_id_a1=${MEAS_ID_A1_BB5}
    ...    srsrp_a1=${SRSRP_A1}    filters=${A1_measurementReport_for_PCell_TDD_BB5}

    Trigger and Verify A2 PCell Change    ue_id=${UE_ID_50}    gnb_id=${GNB_ID}    meas_id_A2=${MEAS_ID_A2_BB5}
    ...    filters=${A2_measurementReport_for_PCell_Change}
    Verify that all 2 Measurement Reports messages occured for UE50
