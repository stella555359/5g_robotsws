*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00    CLOUD_5G_I_BOO_AP_LOO

Documentation    :copyright: Nokia
...              :authors: Krystian Kozlowski, Vira Solomashenko
...              :contact: krystian.kozlowski@nokia.com, vira.solomashenko@nokia.com

Resource     taf/rfrl/common_resources/robot/libraries_instances.robot
Resource     testsuite/Wroclaw/RRM/WRO_2/resources/testing_env.robot
Resource     ../keywords/messaging.robot
Resource     ../keywords/ue_measurements.robot
Resource     ../keywords/traffic.robot
Resource     ../keywords/tshark_verifying.robot
Resource     CB009854_keywords.robot
Library      ta5g_cell_operations
Library      ta5g_tshark
Library      ta5g_iphy
Library      ta5g_egate
Library      ta5g_pm_counters
Library      ta5g_testline_management
Library      taf.ul.ettf.setups

Suite Setup    Run Keywords    With Retry Context    3
...                            Update And Put Iphy Xml    input_filepath=${iphy_xml}
...            AND             With Gnb Configuration    commissioning=${scfc}
...            AND             Wait For Testline Icmp Echo Replies And Ssh Services
...            AND             Start Default Logging
...            AND             Start Vm Ethernet Interfaces
...            AND             Reach Onair Without Confirmation    lua_cfg=${wts_config}
...            AND             Wait For All Cells To Be Enabled    timeout=600
...            AND             Activate And Check If Xp Link is active
...            AND             Sleep    60s    Wait for Xp Link to stabilize
...            AND             Setup Additional Configuration


*** Variables ***
${iphy_xml}=    ${CURDIR}/config/iphy_AB_B9.xml
${wts_config}=    ${CURDIR}/config/wts_DSS_9854.cfg
${scfc}=    CB009854_AB_B9_DSS.xml
${UE_ID}=     3
${PDU_ID}=    1
${PCELL_ID}=    3
${PDU_PCELL_1}=    1
${GW_ID}=    3
${GNB_ID}=    2
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
CB009854-AB-B9a_UE_configured_with_5CC_DL_CA_with_2_FDD_and_3_TDD_serving_cell_is_not_configured_with_2CC_UL_CA_due_to_interaction_with_DSS
    Attach UE And Start Data Traffic    ue_id=3    cell_id=3
    Verify Message    expectation=${ULRRCMessageTransfer}
    Verify Message    expectation=${DLRRCMessageTransfer}
    Verify Message    expectation=${ULRRCAfterPDUSessionSetup}
    Verify Message    expectation=${UEContextModificationRequest}
    Verify Message    expectation=${UEContextModificationResponse}
    Start Data Traffic And Verify Traffic Scheduling On All SCell
    Verify DL DSS Traffic Is Scheduled On All Cells 5CC
    Verify UL DSS Traffic Is Scheduled On PCell
