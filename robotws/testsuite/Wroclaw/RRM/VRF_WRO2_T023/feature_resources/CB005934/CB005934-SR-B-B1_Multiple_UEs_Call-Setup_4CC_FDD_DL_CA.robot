*** Settings ***
Documentation    Keywords for the CB005934_B_B1

Resource     resources/CB005934_keywords.robot
Resource     testsuite/Wroclaw/RRM/VRF_WRO2_T023/resources/airphone/L3_call.robot


*** Variables ***
@{UE_IDs_5934_b1}=     1    10    11
@{PDU_IDs_5934_b1}=    1    2     3
@{GW_IDs_5934_b1}=     1    10    11

${PCELL_ID_5934_b1}=    1
${GNB_ID_5934_b1}=      2

&{A1_RSRP_5934_b1}=           Threshold=RSRP 70
@{A1_FREQUENCIES_5934_b1}=    389570
${A1_MEAS_ID_5934_b1}=        1
${SRSRP_NR_5934_b1}=          90


*** Keywords ***
TC__CB005934-SR-B-B1_Multiple_UEs_Call-Setup_4CC_FDD_DL_CA
    Attach Multiple UEs And Establish PDU Sessions    ue_ids=${UE_IDs_5934_b1}    pdu_ids=${PDU_IDs_5934_b1}    gw_ids=${GW_IDs_5934_b1}
    ...    cell_id=${PCELL_ID_5934_b1}    gnb_id=${GNB_ID_5934_b1}

    Verify A1 Measurements Are Configured At Multiple UEs    ue_ids=${UE_IDs_5934_b1}
    ...    a1_event_params=${A1_RSRP_5934_b1}    a1_frequencies=${A1_FREQUENCIES_5934_b1}
    Trigger A1 Measurement And Expect SCell Addition Messages Flow For Multiple UEs    gnb_id=${GNB_ID_5934_b1}
    ...    ue_ids=${UE_IDs_5934_b1}    meas_id=${A1_MEAS_ID_5934_b1}    srsrp_nr=${SRSRP_NR_5934_b1}
    Verify SCell Addition Messages Content After A1 Event Trigger For Multiple UEs    ue_ids=${UE_IDs_5934_b1}

    Start Data Traffic For Multiple UEs    ue_ids=${UE_IDs_5934_b1}    pdu_ids=${PDU_IDs_5934_b1}
    Verify Traffic on PCell and All SCells For Multiple UEs    ue_ids=${UE_IDs_5934_b1}

    [Teardown]    Release Multiple UEs    ue_ids=${UE_IDs_5934_b1}    pdu_ids=${PDU_IDs_5934_b1}
