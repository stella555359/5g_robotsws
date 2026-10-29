*** Settings ***
Documentation    Keywords for the CB009854_AB_B4a

Library     ta5g_pm_counters
Library     ta5g_ue_mobility
Resource    testsuite/Wroclaw/RRM/WRO_2/keywords/messaging.robot
Resource    resources/CB009854_keywords.robot


*** Variables ***
${GNB_ID_9854_b4a}=               2
${PCELL_ID_9854_b4a}=             3
${UE_ID_9854_b4a}=                3
${PDU_PCELL_1_ID_1_9854_b4a}=     1
${GW_ID_9854_b4a}=                3

${SCell_Addition_check_9854_b4a}=
...    f1ap.SCell_ToBeSetupMod_List == 4 &&
...    f1ap.nRCellIdentity == 00:00:04:00:20 &&
...    f1ap.nRCellIdentity == 00:00:04:00:40 &&
...    f1ap.nRCellIdentity == 00:00:04:00:50 &&
...    f1ap.nRCellIdentity == 00:00:04:00:60
${UEContextModResp_check_9854_b4a}=
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

${local_moid_9854_b4a}=    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3


*** Keywords ***
TC__CB009854-AB-B4a_Large_dedicated_BWP_configuration_for_FDD_SCell_of_UE_configured_with_5CC_DL_CA_due_to_UE_full_bandwidth_support
    Attach UE And Establish PDU Session    ue_id=${UE_ID_9854_b4a}    cell_id=${PCELL_ID_9854_b4a}    pdu_id=${PDU_PCELL_1_ID_1_9854_b4a}
    ...    gw_id=${GW_ID_9854_b4a}
    Verify Message    expectation=${SCell_Addition_check_9854_b4a}
    Verify Message    expectation=${UEContextModResp_check_9854_b4a}
    Verify Pm Counters For SCell Additions With Large BWP    local_moid=${local_moid_9854_b4a}

    [Teardown]    Deregister UE Without Confirmation    ue_id=all

Verify Pm Counters For SCell Additions With Large BWP
    [Arguments]    ${local_moid}
    Wait For Next Full Pm Interval
    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    Verify Any Counters In File
    ...    M55139C04002    1    GNB_DU_SCELL_ADM_L_BWP_SUCC
    ...    local_moid=${local_moid}
    ...    file_path=${pm_counter_file}
