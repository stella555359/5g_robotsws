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
Resource     ../keywords/traffic.robot
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
Library      ta5g_pm_counters
Variables    ta5g_global_var
Variables    CB012559_messaging_filters.py
Variables    logging_policy.py


*** Variables ***
${REBOOT}=    ${False}  # Switch to true to reboot before 1st test iteration, useful when running multiple tests on the same testline
${LOGS_COMPRESSION}=    ${True}
${LOGGING_POLICY}=    NO_TRAFFIC_LOGS_POLICY  # Can be set to FULL_POLICY_WITH_EMIL to capture Emil logs during retests
${BASIC_SETUP}=       ${CURDIR}/config/wts_12559_basic.cfg
${DELTA_12559_ACTIVATION}=    delta_12559_activation.json
${DELTA_12559_DEACTIVATION}=    delta_12559_deactivation.json
${scfc}=              full_scfc_CB012559_A_B1.xml
${scfc_AB4}=          scfc_CB012559_A_B4_alt2.xml
${scfc_AB5}=          scf_CB012559-AB5.xml
${GNB_ID}=            2
${PCELL_ID}=          1  #Cell 1
${PHYSCELL_ID_2}=       52  #Cell 2
${UE_ID_1}=    1
${UE_ID_3}=    11
${UE_ID_4}=    12
${SCELL_1}=    2
${SCELL_2}=    3
${SCELL_3}=    4
${SCELL_4}=    5

@{UE_IDs}=     10    11    12
@{UE_IDs_AB4}=     11    12
@{UE_IDs_release}=     1    10    11    12
${PDU_ID_1}=    1
${PDU_ID_2}=    2
@{PDU_IDs}=    2    3    4
@{PDU_IDs_AB4}=    1    2
@{PDU_IDs_release}=    1    2    3    4
${GW_ID_1}=    1
${GW_ID_2}=    2
@{GW_IDs}=     2    3    4
${MEAS_ID_A1}=    1
${MEAS_ID_A4}=    3
${SRSRP_A1}=    90
${NRSRP_A4}=    95
${A2_cmd}=
...    id=${UE_ID_3} meas_id=5 event=A2 srsrp_nr=90 srsrq_nr=90
...    scell=1 scell_rsrp=60 scell_rsrq=60
...    scell=2 scell_rsrp=60 scell_rsrq=60
...    scell=3 scell_rsrp=60 scell_rsrq=60
...    scell=4 scell_rsrp=10 scell_rsrq=10

*** Test Cases ***
CB012559-A_B1_Blind_Scell_addition_for_4F+1T_FR1_CA
    [Setup]    Run Keywords    Log to console    Full scfc commissioning with iphy.xml upload
      ...         AND          Update And Put Iphy Xml    input_filepath=${CURDIR}/config/iphy_xml_12559.xml
      ...         AND          With Gnb Configuration    commissioning=${scfc}
      ...         AND          Wait For Testline Icmp Echo Replies And Ssh Services
      ...         AND          With Simulator Configuration    config=${BASIC_SETUP}
      ...         AND          Create gNB Alias
    [Teardown]   Release Multiple UEs    ue_ids=@{UE_IDs_release}    pdu_ids=@{PDU_IDs_release}

    Set 8 expected UE Context Modification messages for gNB2
    CB012559_keywords.Attach UE And Verify Establishing PDU Session With Blind SCell Addition
    ...    ue_id=${UE_ID_1}    cell_id=${PCELL_ID}    gnb_id=${GNB_ID}    pdu_id=${PDU_ID_1}    gw_id=${GW_ID_1}
    Verify UE1 4CC FFFT Blind SCell Addition Message Contents
    Verify 8 UE Context Modification messages for gNB2 occured

    Activate feature 12559    delta_activation=${DELTA_12559_ACTIVATION}

    Set 24 expected UE Context Modification messages for gNB2 for multiple UEs
    Attach Multiple UEs And Verify Establishing PDU Sessions With Blind SCell Addition   ue_ids=@{UE_IDs}
    ...    pdu_ids=@{PDU_IDs}    gw_ids=@{GW_IDs}    cell_id=${PCELL_ID}    gnb_id=${GNB_ID}
    Verify UE2 5CC FFFFT Blind SCell Addition Message Contents
    Verify UE3 5CC FFFFT Blind SCell Addition Message Contents
    Verify UE4 5CC FFFFT Blind SCell Addition Message Contents
    Verify 24 UE Context Modification messages for gNB2 occured for multiple UEs

    Release Multiple UEs    ue_ids=@{UE_IDs_release}    pdu_ids=@{PDU_IDs_release}

    Set 8 expected UE Context Modification messages for gNB2
    CB012559_keywords.Attach UE And Verify Establishing PDU Session With Blind SCell Addition
    ...    ue_id=${UE_ID_1}    cell_id=${PCELL_ID}    gnb_id=${GNB_ID}    pdu_id=${PDU_ID_1}    gw_id=${GW_ID_1}
    ...    with_SANSA_aliases_setup=${FALSE}
    Verify UE1 5CC FFFFT Blind SCell Addition Message Contents
    Verify 8 UE Context Modification messages for gNB2 occured

    Deactivate feature 12559    delta_deactivation=${DELTA_12559_DEACTIVATION}

    Set 24 expected UE Context Modification messages for gNB2 for multiple UEs
    Attach Multiple UEs And Verify Establishing PDU Sessions With Blind SCell Addition   ue_ids=@{UE_IDs}
    ...    pdu_ids=@{PDU_IDs}    gw_ids=@{GW_IDs}    cell_id=${PCELL_ID}    gnb_id=${GNB_ID}    with_SANSA_aliases_setup=${FALSE}
    Verify UE2 4CC FFFT Blind SCell Addition Message Contents
    Verify UE3 4CC FFFT Blind SCell Addition Message Contents
    Verify UE4 4CC FFFT Blind SCell Addition Message Contents
    Verify 24 UE Context Modification messages for gNB2 occured for multiple UEs

CB012559-A_B4_Alt2_A1_A4_based_SCell_Addition
# A combination of scenarios CB012559-A-B4_Alt2 and CB012559-A-B5.

    [Setup]    Run Keywords    Log to console    Full scfc commissioning with iphy.xml upload
      ...         AND          Update And Put Iphy Xml    input_filepath=${CURDIR}/config/iphy_xml_12559.xml
      ...         AND          With Gnb Configuration    commissioning=${scfc_AB4}
      ...         AND          Wait For Testline Icmp Echo Replies And Ssh Services
      ...         AND          With Simulator Configuration    config=${BASIC_SETUP}
      ...         AND          Create gNB Alias
    [Teardown]    Release Multiple UEs    ue_ids=@{UE_IDs_AB4}    pdu_ids=@{PDU_IDs_AB4}

    Add Scout Data Info To Testcase

    Create Multiple UEs Aliases    ue_ids=@{UE_IDs_AB4}
    Set 3 expected RRC Reconfiguration Request and Complete messages for UE11
    Set 4 expected UE Context Modification messages for gNB2
    Attach UE Set Message Flow And Verify Establishing PDU Session    ue_id=${UE_ID_3}    cell_id=${PCELL_ID}    gnb_id=${GNB_ID}
    ...    pdu_id=${PDU_ID_1}    gw_id=${GW_ID_1}
    Verify that 3 RRC Reconfiguration Request and Complete messages occured for UE11
    Verify 4 UE Context Modification messages for gNB2 occured
    Verify UE11 message RRCReconfiguration number 1 of 3 fulfils ${A1_measurement_configuration_for_PCell_FDD} content
    Verify gNB2 message UEContextModificationRequest number 3 of 4 fulfils ${ue_context_modification_string_filter_A1_A4} string filter
    Verify that UEContextModificationResponse 3 of 4 contains measGapConfig for gNB2
    Verify UE11 message RRCReconfiguration number 2 of 3 fulfils ${A4_measurement_configuration_for_AB4} content
    Verify UE11 message RRCReconfiguration number 2 of 3 fulfils ${measGapConfig_check_if_present} content

    Set 3 expected RRC Reconfiguration Request and Complete messages for UE12
    Set 4 expected UE Context Modification messages for gNB2
    Attach UE Set Message Flow And Verify Establishing PDU Session    ue_id=${UE_ID_4}    cell_id=${PCELL_ID}    gnb_id=${GNB_ID}
    ...    pdu_id=${PDU_ID_2}    gw_id=${GW_ID_2}
    Verify that 3 RRC Reconfiguration Request and Complete messages occured for UE12
    Verify 4 UE Context Modification messages for gNB2 occured
    Verify UE12 message RRCReconfiguration number 1 of 3 fulfils ${A1_measurement_configuration_for_PCell_FDD} content
    Verify gNB2 message UEContextModificationRequest number 3 of 4 fulfils ${ue_context_modification_string_filter_A1_A4} string filter
    Verify that UEContextModificationResponse 3 of 4 contains measGapConfig for gNB2
    Verify UE12 message RRCReconfiguration number 2 of 3 fulfils ${A4_measurement_configuration_for_AB4} content
    Verify UE12 message RRCReconfiguration number 2 of 3 fulfils ${measGapConfig_check_if_present} content

    Set 2 expected Measurement Report messages timeout 9s for UE11
    Set 1 expected PrivateMessages UE gNB2
    Trigger A1 Based SCell Addition    ue_id=${UE_ID_3}    gNB_id=${GNB_ID}    meas_id_a1=${MEAS_ID_A1}
    ...    srsrp_a1=${SRSRP_A1}
    Verify that all 1 expected PrivateMessages occured UE gNB2
    Verify that PrivateMessage 1 of 1 is BufferMonitoringNotification for gNB2
    Verify UE11 message MeasurementReport number 1 of 2 fulfils ${A1_measurementReport_for_PCell_FDD_AB4} content

    Set expected Measurement Report messages for UE12
    Set 1 expected PrivateMessages UE gNB2
    Trigger A1 Based SCell Addition    ue_id=${UE_ID_4}    gNB_id=${GNB_ID}    meas_id_a1=${MEAS_ID_A1}
    ...    srsrp_a1=${SRSRP_A1}
    Verify that all 1 expected PrivateMessages occured UE gNB2
    Verify that PrivateMessage 1 of 1 is BufferMonitoringNotification for gNB2
    Verify UE12 message MeasurementReport number 1 of 1 fulfils ${A1_measurementReport_for_PCell_FDD_AB4} content
    Verify that Measurement Report messages occured for UE12

    Trigger and Verify A4 Based SCell Addition    ue_id=${UE_ID_3}    meas_id_a4=${MEAS_ID_A4}
    ...    nrsrp_a4=${NRSRP_A4}    phycell_id=${PHYSCELL_ID_2}
    Verify that all 2 Measurement Report messages occured for UE11
    Verify UE11 message MeasurementReport number 2 of 2 fulfils ${A4_measurementReport_for_PCell_FDD_AB4} content

    Set 16 expected UE Context Modification messages for gNB2
    Set 3 expected RRC Reconfiguration Request and Complete messages for UE11
    Set 1 expected PrivateMessages UE gNB2
    Traffic Start High DL non-GBR Data    ue_id=${UE_ID_3}    pdu_id=${PDU_ID_1}
    Wait For Traffic to stabilize    inactive_timer=6
    Verify that all 1 expected PrivateMessages occured UE gNB2
    Verify that PrivateMessage 1 of 1 is BufferCriterionNotification for gNB2
    Verify that 3 RRC Reconfiguration Request and Complete messages occured for UE11
    Verify UE11 message RRCReconfiguration number 1 of 3 fulfils ${meas_Config_with_gap} content
    Verify gNB2 message UEContextModificationRequest number 5 of 16 fulfils ${UE_CON_MOD_REQ_5CC_FFFFT_CA_in_AB4} content
    Verify gNB2 message UEContextModificationResponse number 5 of 16 fulfils ${sCellToAddModList_AB4_5CC} content
    Verify gNB2 message UEContextModificationResponse number 5 of 16 fulfils ${CSI_meas_config_for_5CC_FFFFT_CA_in_UE_CON_MOD_RESP_AB4} content
    Verify UE11 message RRCReconfiguration number 3 of 3 fulfils ${meas_config_in_RRC_Reconf_5CC_FFFFT} content

    Set 1 expected PrivateMessages UE gNB2
    Set 3 expected RRC Reconfiguration Request and Complete messages for UE12
    Traffic Start High DL non-GBR Data    ue_id=${UE_ID_4}    pdu_id=${PDU_ID_2}
    Wait For Traffic to stabilize    inactive_timer=4
    Verify that all 1 expected PrivateMessages occured UE gNB2
    Verify that PrivateMessage 1 of 1 is BufferCriterionNotification for gNB2
    Verify 16 UE Context Modification messages for gNB2 occured
    Verify that 3 RRC Reconfiguration Request and Complete messages occured for UE12
    Verify gNB2 message UEContextModificationRequest number 14 of 16 fulfils ${UE_CON_MOD_REQ_4CC_FFFT_CA_in_AB4} content
    Verify gNB2 message UEContextModificationResponse number 14 of 16 fulfils ${sCellToAddModList_AB4_4CC} content
    Verify gNB2 message UEContextModificationResponse number 14 of 16 fulfils ${CSI_meas_config_for_4CC_FFFT_CA_in_UE_CON_MOD_RESP_AB4} content
    Verify UE12 message RRCReconfiguration number 3 of 3 fulfils ${meas_config_in_RRC_Reconf_4CC_FFFFT} content

    Set expected Measurement Report messages for UE11
    Set 1 expected RRC Reconfiguration Request and Complete messages for UE11
    Set 3 expected UE Context Modification messages for gNB2
    Trigger A2 Based SCell Release    A2_cmd=${A2_cmd}
    Verify UE11 message MeasurementReport number 1 of 1 fulfils ${A2_measurementReport_AB5} content
    Verify that Measurement Report messages occured for UE11
    Verify that 1 RRC Reconfiguration Request and Complete messages occured for UE11
    Verify 3 UE Context Modification messages for gNB2 occured
    Verify UE1 4CC FFFF SCell Release Message Contents
    Verify 5CC CA Counters AB5    scell_1=${SCELL_1}    scell_2=${SCELL_2}    scell_3=${SCELL_3}     scell_4=${SCELL_4}
    ...    pcell=${PCELL_ID}

CB012559-A_B5_SCell_Release_based_on_A2_SCell_measurement
    [Setup]    Run Keywords    Log to console    Full scfc commissioning with iphy.xml upload
      ...         AND          Update And Put Iphy Xml    input_filepath=${CURDIR}/config/iphy_xml_12559.xml
      ...         AND          With Gnb Configuration    commissioning=${scfc_AB5}
      ...         AND          Wait For Testline Icmp Echo Replies And Ssh Services
      ...         AND          With Simulator Configuration    config=${BASIC_SETUP}
      ...         AND          Create gNB Alias
    [Teardown]    Release UE    ue_id=${UE_ID_1}    pdu_id=${PDU_ID_1}

    Add Scout Data Info To Testcase

    Create UE Alias    alias=UE${UE_ID_1}    ue_id=${UE_ID_1}    id_type=wts_5g
    Set 1 expected RRC Reconfiguration Request and Complete messages for UE1
    Attach UE Set Message Flow And Verify Establishing PDU Session    ue_id=${UE_ID_1}    cell_id=${PCELL_ID}    gnb_id=${GNB_ID}
    ...    pdu_id=${PDU_ID_1}    gw_id=${GW_ID_1}
    Verify that 1 RRC Reconfiguration Request and Complete messages occured for UE1
    Verify UE1 message RRCReconfiguration number 1 of 1 fulfils ${A1_measurement_configuration_for_PCell_FDD} content

    Set expected Measurement Report messages for UE1
    Set 1 expected RRC Reconfiguration Request and Complete messages for UE1
    Set 3 expected UE Context Modification messages for gNB2
    Trigger A1 Based SCell Addition    ue_id=${UE_ID_1}    gNB_id=${GNB_ID}    meas_id_a1=${MEAS_ID_A1}
    ...    srsrp_a1=${SRSRP_A1}
    Verify UE1 message MeasurementReport number 1 of 1 fulfils ${A1_measurementReport_for_PCell_FDD_AB4} content
    Verify that Measurement Report messages occured for UE1
    Verify that 1 RRC Reconfiguration Request and Complete messages occured for UE1
    Verify 3 UE Context Modification messages for gNB2 occured
    Verify UE1 5CC FFFFT SCell Addition Message Contents

    Set expected Measurement Report messages for UE1
    Set 1 expected RRC Reconfiguration Request and Complete messages for UE1
    Set 3 expected UE Context Modification messages for gNB2
    Trigger A2 Based SCell Release    A2_cmd=${A2_cmd}
    Verify UE1 message MeasurementReport number 1 of 1 fulfils ${A2_measurementReport_AB5} content
    Verify that Measurement Report messages occured for UE1
    Verify that 1 RRC Reconfiguration Request and Complete messages occured for UE1
    Verify 3 UE Context Modification messages for gNB2 occured
    Verify UE1 4CC FFFF SCell Release Message Contents
    Verify 5CC CA Counters AB5    scell_1=${SCELL_1}    scell_2=${SCELL_2}    scell_3=${SCELL_3}     scell_4=${SCELL_4}
    ...    pcell=${PCELL_ID}
