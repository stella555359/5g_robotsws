*** Settings ***
Documentation    Keywords for the CB005934_B_B6a

Library      ta5g_pm_counters
Resource     resources/CB005934_keywords.robot
Resource     testsuite/Wroclaw/RRM/VRF_WRO2_T023/resources/airphone/L3_call.robot


*** Variables ***
@{UE_IDs_5934_b6a}=     1    10    11
@{PDU_IDs_5934_b6a}=    1    2     3
@{GW_IDs_5934_b6a}=     1    10    11

${PCELL_ID_5934_b6a}=    1
${GNB_ID_5934_b6a}=      2

&{A1_RSRP_5934_b6a}=           Threshold=RSRP 70
@{A1_FREQUENCIES_5934_b6a}=    389570
${A1_MEAS_ID_TDD_5934_b6a}=    1
${A1_MEAS_ID_FDD_5934_b6a}=    4
${SRSRP_NR_TDD_5934_b6a}=      75
${SRSRP_NR_FDD_5934_b6a}=      90

${LOCAL_MOID_5934_b6a}=    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1


*** Keywords ***
TC__CB005934-SR-B-B6a_Multi_UE_Call-SCell_Change_based_on_A1-PCell_measurement_for_SA_UE_from_3CC_F-T-T_CA_to_4CC_F-F-F-F_CA
    Attach Multiple UEs And Establish PDU Sessions    ue_ids=${UE_IDs_5934_b6a}    pdu_ids=${PDU_IDs_5934_b6a}
    ...    gw_ids=${GW_IDs_5934_b6a}    cell_id=${PCELL_ID_5934_b6a}    gnb_id=${GNB_ID_5934_b6a}

    Verify A1 Measurements Are Configured At Multiple UEs    ue_ids=${UE_IDs_5934_b6a}
    ...    a1_event_params=${A1_RSRP_5934_b6a}    a1_frequencies=${A1_FREQUENCIES_5934_b6a}

    Trigger A1 Measurement And Expect SCell Addition Messages Flow For Multiple UEs    gnb_id=${GNB_ID_5934_b6a}
    ...    ue_ids=${UE_IDs_5934_b6a}    meas_id=${A1_MEAS_ID_TDD_5934_b6a}    srsrp_nr=${SRSRP_NR_TDD_5934_b6a}
    Verify SCell Addition Messages Content After A1 TDD Event Trigger For Multiple UEs    ue_ids=${UE_IDs_5934_b6a}

    Trigger A1 Measurement And Expect SCell Addition Messages Flow For Multiple UEs    gnb_id=${GNB_ID_5934_b6a}
    ...    ue_ids=${UE_IDs_5934_b6a}    meas_id=${A1_MEAS_ID_FDD_5934_b6a}    srsrp_nr=${SRSRP_NR_FDD_5934_b6a}
    Verify SCell Addition Messages Content After A1 FDD Event Trigger For Multiple UEs    ue_ids=${UE_IDs_5934_b6a}

    Verify Pm Counters For 3CC To 4CC Change    local_moid=${LOCAL_MOID_5934_b6a}

    [Teardown]    Release Multiple UEs    ue_ids=${UE_IDs_5934_b6a}    pdu_ids=${PDU_IDs_5934_b6a}

Verify Pm Counters For 3CC To 4CC Change
    [Arguments]    ${local_moid}
    Wait For Next Full Pm Interval
    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    Verify Any Counters In File
    ...    M55118C06506    3    SCELL_CHANGE_ATT_SA
    ...    M55118C06507    3    SCELL_CHANGE_SUCC_SA
    ...    M55124C03001    12    NRRCC_RRC_RECONF_SENT
    ...    M55124C03002    12    NRRCC_RRC_RECONF_CMP_RECD
    ...    M55118C09501    >0    UE_PCELL_3_CONF_SCELL_DL_SA
    ...    M55118C07001    >\=0    UE_PCELL_2_CONF_SCELL_DL_SA
    ...    local_moid=${local_moid}
    ...    file_path=${pm_counter_file}
