*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00
...    CLOUD_5G_I_BOO_AP_LOO    VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD

Documentation    :copyright: Nokia

Resource     taf/rfrl/common_resources/robot/libraries_instances.robot
Resource     testsuite/Wroclaw/RRM/WRO_2/resources/testing_env.robot
Resource     testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/ute_report.robot
Resource     ../keywords/messaging.robot
Resource     ../keywords/L3_Call.robot
Resource     ../keywords/ue_measurements.robot
Resource     ../keywords/tshark_verifying.robot
Resource     ../keywords/traffic.robot
Resource     CB009854_keywords.robot
Library      ta_messaging
Library      taf.ul.ettf.setups
Library      taf.ul.ettf.retry_context
Library      ta5g_testline_management
Library      ta5g_egate
Library      ta5g_iphy
Library      ta5g_cell_operations
Library      ta5g_pm_counters
Library      ta5g_ue_mobility
Library      ta5g_tshark
Library      ta5g_ue_measurements
Variables    CB009854_messaging_filters.py
Variables    logging_policy.py
Variables    ta5g_global_var

*** Variables ***
${REBOOT}=    ${True}  # Switch to true to reboot before 1st test iteration, useful when running multiple tests on the same testline
${LOGS_COMPRESSION}=    ${True}
${LOGGING_POLICY}=    FULL_POLICY  # Can be set to FULL_POLICY_WITH_EMIL to capture Emil logs during retests
${B3a_SETUP}=         ${CURDIR}/config/wts_9854_basic.cfg
${B6c_SETUP}=         ${CURDIR}/config/AAB6c_wts_7cells_3FDD_n25_30MHzn66n71_20MHz_4TDD_n41_40_60MHz_n77_80_40MHz.cfg
${AB_B4_SETUP}=       ${CURDIR}/config/wts_AB_B4A.cfg
${AB_B9a_SETUP}=      ${CURDIR}/config/wts_DSS_9854.cfg
${GNB_ID}=            2
${PCELL_ID}=          3
${PHYSCELL_ID}=       53
${UE_ID}=             3
${PDU_PCELL_1_ID_3}=  3
${PDU_PCELL_1_ID_1}=  1
${PDU_ID}=            1
${GW_ID}=             3
${SCELL_1}=           1
${SCELL_2}=           4
${SCELL_3}=           5
${SCELL_4}=           6
${Trigger_CA_Meas_ID}=    1
${FDD_PCELL_ID}=     3
${UE_FDD_PCELL_3}=     3
${PDU_FDD_PCELL_3}=     3
${SCell_Addition_check}=
...    f1ap.SCell_ToBeSetupMod_List == 4 &&
...    f1ap.nRCellIdentity == 00:00:04:00:20 &&
...    f1ap.nRCellIdentity == 00:00:04:00:40 &&
...    f1ap.nRCellIdentity == 00:00:04:00:50 &&
...    f1ap.nRCellIdentity == 00:00:04:00:60
${UEContextModResp_check}=
...    f1ap.procedureCode == 7 &&
...    nr-rrc.resourceSetToAddModList == 2 &&
...    nr-rrc.maxPayloadSize == 12 &&
...    nr-rrc.sCellToAddModList == 4 &&
...    nr-rrc.physCellId == 52 &&
...    nr-rrc.carrierBandwidth == 160 &&
...    nr-rrc.locationAndBandwidth == 28875 &&
...    nr-rrc.physCellId == 54 &&
...    nr-rrc.physCellId == 55 &&
...    nr-rrc.physCellId == 56 &&
...    nr-rrc.csi_ReportConfigToAddModList == 7
${local_moid}=    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3
${ULRRCMessageTransfer}=    f1ap.procedureCode == 13 && nas_5gs.mm.message_type == 0x43
${DLRRCMessageTransfer}=    nr-rrc.pdu_Session == 1
${ULRRCAfterPDUSessionSetup}=    nr-rrc.criticalExtensions == 0 && nr-rrc.rrc_TransactionIdentifier == 2 &&
...    f1ap.procedureCode == 13
${UEContextModificationRequest}=    f1ap.SCell_ToBeSetupMod_List == 4 && f1ap.nRCellIdentity == 00:00:04:00:10 &&
...    f1ap.nRCellIdentity == 00:00:04:00:40 && f1ap.nRCellIdentity == 00:00:04:00:50 &&
...    f1ap.nRCellIdentity == 00:00:04:00:60
${UEContextModificationResponse}=    f1ap.procedureCode == 7 && nr-rrc.resourceSetToAddModList == 2 &&
...    nr-rrc.maxPayloadSize == 12 && nr-rrc.resourceList == 2 && nr-rrc.csi_ReportConfigToAddModList == 7 &&
...    nr-rrc.reportConfigId == 13 && nr-rrc.reportQuantity == 1 && nr-rrc.reportConfigId == 14 &&
...    nr-rrc.reportQuantity == 7 && nr-rrc.reportConfigId == 22 && nr-rrc.reportQuantity == 6 &&
...    nr-rrc.reportConfigId == 15 && nr-rrc.reportQuantity == 7 && nr-rrc.reportConfigId == 23 &&
...    nr-rrc.reportQuantity == 6 && nr-rrc.reportConfigId == 16 && nr-rrc.reportQuantity == 7 &&
...    nr-rrc.reportConfigId == 24 && nr-rrc.reportQuantity == 6

*** Test Cases ***

CB009854-AA-B3a_3T2F_Blind_5CC_SCell_Addition_with_weight-based_SCell_selection_with_uniformly_weighted_SCells
    [Documentation]    :copyright: Nokia
    ...                :authors: Izabela Prosniak
    ...                :contact: izabela.prosniak@nokia.com

    [Setup]    Run Keywords    Update And Put Iphy Xml    input_filepath=${CURDIR}/config/iphy_xml_9854.xml
    ...            AND             With Gnb Configuration    commissioning=CB009854-AA-B3a.xml
    ...            AND             Wait For Testline Icmp Echo Replies And Ssh Services
    ...            AND             Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...            AND             With Simulator Configuration    config=${B3a_SETUP}
    ...            AND             Create gNB Alias

    Add Scout Data Info To Testcase

    Attach UE And Verify Establishing PDU Session With Blind SCell Addition    ue_id=${UE_ID}    cell_id=${PCELL_ID}
    ...    gnb_id=${GNB_ID}    pdu_id=${PDU_PCELL_1_ID_3}   gw_id=${GW_ID}
    Verify 5CC DL And 2CC UL FFTTT Blind SCell Addition Message Contents    ue_id=${UE_ID}
    Start Data Traffic
    Verify Traffic Is Scheduled On All Cells 5CC DL And 2CC UL
    Verify 5CC CA Counters    scell_1=${SCELL_1}    scell_2=${SCELL_2}    scell_3=${SCELL_3}     scell_4=${SCELL_4}
    ...    pcell=${PCELL_ID}
    Release UE    ue_id=${UE_ID}    pdu_id=${PDU_PCELL_1_ID_3}

    [Teardown]    Run Keywords    Deregister UE Without Confirmation    ue_id=all
    ...    AND    Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}


CB009854-AA-B6c_A1_PCell_Measurement_report_not_meeting_secondary_report_quantity_threshold_does_not_trigger_SCell_Addition
    [Documentation]    :copyright: Nokia
    ...                :authors: Blanka Gozdek, Lukasz Klimowicz
    ...                :contact: blanka.gozdek@nokia.com, lukasz.klimowicz@nokia.com

    [Setup]    Run Keywords    Update And Put Iphy Xml    input_filepath=${CURDIR}/config/iphy_xml_9854.xml
    ...            AND             With Gnb Configuration    commissioning=CB009854-AA-B6c.xml
    ...            AND             Wait For Testline Icmp Echo Replies And Ssh Services
    ...            AND             Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...            AND             With Simulator Configuration    config=${B6c_SETUP}
    ...            AND             Create gNB Alias

    Add Scout Data Info To Testcase

    Attach Ue And Verify Establishing PDU Session With A1 Measurement Verification    ue_id=${UE_FDD_PCELL_3}
    ...    cell_id=${FDD_PCELL_ID}    gnb_id=${GNB_ID}    pdu_id=${PDU_FDD_PCELL_3}    gw_id=${UE_FDD_PCELL_3}
    Trigger A1 Based CA    ue_id=${UE_FDD_PCELL_3}    gnb_id=${GNB_ID}    meas_id=${Trigger_CA_Meas_ID}
    Release UE    ue_id=${UE_FDD_PCELL_3}    pdu_id=${PDU_FDD_PCELL_3}

    [Teardown]    Run Keywords    Deregister UE Without Confirmation    ue_id=all
    ...    AND    Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}


CB009854-AB-B4a_Large_dedicated_BWP_configuration_for_FDD_SCell_of_UE_configured_with_5CC_DL_CA_due_to_UE_full_bandwidth_support
    [Documentation]    :copyright: Nokia
    ...                :authors: Krystian Kozlowski, Vira Solomashenko
    ...                :contact: krystian.kozlowski@nokia.com, vira.solomashenko@nokia.com

    [Setup]    Run Keywords    With Retry Context    3
    ...                            Update And Put Iphy Xml    input_filepath=${CURDIR}/config/iphy_xml_AB_B4A.xml
    ...            AND             Find Scfc And Fix And Send Full Commissioning    CB009854-AB-B4a.xml
    ...            AND             Wait For Testline Icmp Echo Replies And Ssh Services
    ...            AND             Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...            AND             With Simulator Configuration    config=${AB_B4_SETUP}

    Add Scout Data Info To Testcase

    Attach UE And Verify Establishing PDU Session   ue_id=${UE_ID}    cell_id=${PCELL_ID}
    ...    gnb_id=${GNB_ID}    pdu_id=${PDU_PCELL_1_ID_1}   gw_id=${GW_ID}
    Verify Message    expectation=${SCell_Addition_check}
    Verify Message    expectation=${UEContextModResp_check}
    Verify Pm Counters For SCell Additions With Large BWP    local_moid=${local_moid}

    [Teardown]       Run Keywords    Deregister UE Without Confirmation    ue_id=all
    ...    AND    Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

CB009854-AB-B9a_UE_configured_with_5CC_DL_CA_with_2_FDD_and_3_TDD_serving_cell_is_not_configured_with_2CC_UL_CA_due_to_interaction_with_DSS
    [Documentation]    :copyright: Nokia
    ...                :authors: Krystian Kozlowski, Vira Solomashenko
    ...                :contact: krystian.kozlowski@nokia.com, vira.solomashenko@nokia.com

    [Setup]    Run Keywords    With Retry Context    3
    ...                            Update And Put Iphy Xml    input_filepath=${CURDIR}/config/iphy_AB_B9.xml
    ...            AND             With Gnb Configuration    commissioning=CB009854_AB_B9_DSS.xml
    ...            AND             Wait For Testline Icmp Echo Replies And Ssh Services
    ...            AND             Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...            AND             Start Vm Ethernet Interfaces
    ...            AND             Reach Onair Without Confirmation    lua_cfg=${AB_B9a_SETUP}
    ...            AND             Wait For All Cells To Be Enabled    timeout=600
    ...            AND             Activate And Check If Xp Link is active
    ...            AND             BuiltIn.Sleep    60s    Wait for Xp Link to stabilize
    ...            AND             Setup Additional Configuration

    Attach UE And Start Data Traffic    ue_id=3    cell_id=3
    Verify Message    expectation=${ULRRCMessageTransfer}
    Verify Message    expectation=${DLRRCMessageTransfer}
    Verify Message    expectation=${ULRRCAfterPDUSessionSetup}
    Verify Message    expectation=${UEContextModificationRequest}
    Verify Message    expectation=${UEContextModificationResponse}
    Start Data Traffic And Verify Traffic Scheduling On All SCell
    Verify DL DSS Traffic Is Scheduled On All Cells 5CC
    Verify UL DSS Traffic Is Scheduled On PCell

    [Teardown]    Run Keywords    Deregister UE Without Confirmation    ue_id=all
    ...    AND    Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...    AND    Add Scout Data Info To Testcase


*** Keywords ***

Verify Traffic Is Scheduled On All Cells 5CC DL And 2CC UL
    Verify DL Traffic Is Scheduled On All Cells 5CC
    BuiltIn.Sleep    10s
    Verify UL Traffic Is Scheduled On All Cells 2CC

Verify 5CC CA Counters
    [Arguments]    ${scell_1}    ${scell_2}    ${scell_3}    ${scell_4}    ${pcell}
    ${pm_counter_file}=    Get Next Unpacked Full Pm Counters File
    Verify Any Counters In File
    ...    M55118C10005    >0    UE_PCELL_1_CONF_SCELL_UL_SA
    ...    M55316C03004    >0    PSCELL_UE_4_ACT_SCELL_DL
    ...    M55118C10001    1    RRC_RECONF_ADD1ULSCELL_ATT_SA
    ...    M55118C10002    1    RRC_RECONF_ADD1ULSCELL_SUCC_SA
    ...    M55138C00048    1    GNB_SCELL_4_ADMI_REQ_SA
    ...    M55138C00049    1    GNB_SCELL_4_ADMI_SUCC_SA
    ...    M55139C00023    1    GNB_DU_SCELL_4_ADMI_REQ_SA
    ...    M55139C00024    1    GNB_DU_SCELL_4_ADMI_SUCC_SA
    ...    M55118C02014    1    RRC_RECONF_ADD4DLSCELL_SUCC_SA
    ...    M55118C02015    1    RRC_RECONF_ADD4DLSCELL_ATT_SA
    ...    M55118C02016    >0    UE_PCELL_4_CONF_SCELL_DL_SA
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${pcell}
    ...    file_path=${pm_counter_file}
    Verify Any Counters In File
    ...    M55118C07510    >0    UE_SCELL_4_CONF_SCELL_DL_SA
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${scell_1}
    ...    file_path=${pm_counter_file}
    Verify Any Counters In File
    ...    M55118C07510    >0    UE_SCELL_4_CONF_SCELL_DL_SA
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${scell_2}
    ...    file_path=${pm_counter_file}
    Verify Any Counters In File
    ...    M55118C07510    >0    UE_SCELL_4_CONF_SCELL_DL_SA
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${scell_3}
    ...    file_path=${pm_counter_file}
    Verify Any Counters In File
    ...    M55118C10006    >0    UE_SCELL_1_CONF_SCELL_UL_SA
    ...    M55118C07510    >0    UE_SCELL_4_CONF_SCELL_DL_SA
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${scell_4}
    ...    file_path=${pm_counter_file}


