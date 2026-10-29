*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00    CLOUD_5G_I_BOO_AP_LOO    QC_358522    QCD_MN_RAN    QCP_RAN_ET

Documentation    :copyright: Nokia
...              :authors: Krystian Kozlowski, Vira Solomashenko
...              :contact: krystian.kozlowski@nokia.com, vira.solomashenko@nokia.com

Resource     testsuite/Wroclaw/RRM/WRO_2/resources/testing_env.robot
Resource     testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/ute_report.robot
Resource     ../keywords/messaging.robot
Resource     ../keywords/ue_measurements.robot
Resource     ../keywords/traffic.robot
Resource     ../keywords/tshark_verifying.robot
Resource     CB009854_keywords.robot
Library      ta5g_tshark
Library      ta5g_iphy
Library      ta5g_egate
Library      ta5g_pm_counters
Library      ta5g_testline_management
Library      taf.ul.ettf.setups

Suite Setup    Run Keywords    With Retry Context    3
...                            Update And Put Iphy Xml    input_filepath=${IPHY_XML}
...            AND             Find Scfc And Fix And Send Full Commissioning    CB009854-AB-B4a.xml
...            AND             Wait For Testline Icmp Echo Replies And Ssh Services
...            AND             Start Default Logging
...            AND             Reach Onair Without Confirmation    lua_cfg=${BASIC_SETUP}


*** Variables ***
${IPHY_XML}=    ${CURDIR}/config/iphy_xml_AB_B4A.xml
${BASIC_SETUP}=    ${CURDIR}/config/wts_AB_B4A.cfg
${UE_ID}=     3
${PCELL_ID}=    3
${PDU_PCELL_1}=    1
${GW_ID}=    3
${GNB_ID}=    2
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


*** Test Cases ***
CB009854-AB-B4a_Large_dedicated_BWP_configuration_for_FDD_SCell_of_UE_configured_with_5CC_DL_CA_due_to_UE_full_bandwidth_support
    Attach UE And Verify Establishing PDU Session   ue_id=${UE_ID}    cell_id=${PCELL_ID}
    ...    gnb_id=${GNB_ID}    pdu_id=${PDU_PCELL_1}    gw_id=${GW_ID}
    Verify Message    expectation=${SCell_Addition_check}
    Verify Message    expectation=${UEContextModResp_check}
    Verify Pm Counters For SCell Additions With Large BWP    local_moid=${local_moid}
[Teardown]    Add Scout Data Info To Testcase
