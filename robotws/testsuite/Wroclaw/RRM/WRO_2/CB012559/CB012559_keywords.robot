*** Settings ***

Documentation    Keywords for CB012559.

*** Keywords ***

Activate feature 12559
    [Arguments]    ${delta_activation}
    Find Scfc And Send Delta Commissioning Retrying After Errors    scfc_filename=${delta_activation}

Deactivate feature 12559
    [Arguments]    ${delta_deactivation}
    Find Scfc And Send Delta Commissioning Retrying After Errors    scfc_filename=${delta_deactivation}

Create Multiple UEs Aliases
    [Arguments]    ${ue_ids}
    ${ues_number}=    Get Length    ${ue_ids}
    FOR    ${ue_index}    IN RANGE    ${ues_number}
        Create UE Alias    alias=UE${ue_ids}[${ue_index}]   ue_id=${ue_ids}[${ue_index}]    id_type=wts_5g
    END

Release UE
    [Arguments]    ${ue_id}    ${pdu_id}
    Release PDU session    ue_id=${ue_id}    pdu_id=${pdu_id}
    Deregister UE    ue_id=${ue_id}

Release Multiple UEs
    [Arguments]    ${ue_ids}   ${pdu_ids}
    ${ues_number}=    Get Length    ${ue_ids}
    FOR    ${ue_index}    IN RANGE    ${ues_number}
        Release UE    ue_id=${ue_ids}[${ue_index}]   pdu_id=${pdu_ids}[${ue_index}]
    END

Attach UE And Verify Establishing PDU Session With Blind SCell Addition
    [Documentation]    Requires setting the gNB alias separately (keyword Create gNB Alias), but can be used in multi-UE scenarios without any change
    ...                Verifies successful PDU Session Setup and the occurrence of Blind SCell Addition immediately afterwards
    [Arguments]    ${ue_id}    ${cell_id}    ${gnb_id}=2    ${pdu_id}=1    ${gw_id}=1    ${with_SANSA_aliases_setup}=${TRUE}
    Run Keyword If    ${with_SANSA_aliases_setup}    Create UE Alias    alias=UE${ue_id}    ue_id=${ue_id}    id_type=wts_5g
    Expect UE Attach Messages Flow     ue_id=${ue_id}    gNB_id=${gnb_id}
    Expect PDU Messages Flow     ue_id=${ue_id}    gNB_id=${gnb_id}
    Expect SCell Addition Messages Flow    ue_id=${ue_id}
    Attach UE And Establish PDU Session    ue_id=${ue_id}    cell_id=${cell_id}    enb_id=${gnb_id}    pdu_id=${pdu_id}    gw_id=${gw_id}
    Check If UE Attach Messages Flow Occurred     ue_id=${ue_id}
    Check If PDU Messages Flow Occurred     ue_id=${ue_id}
    Check If SCell Addition Messages Flow Occured    ue_id=${ue_id}
    Verify That Message Fulfills Query    pdu-Session eq ${pdu_id}    message_alias=RRCReconfiguration    flow_alias=Established_PDU_UE${ue_id}

Attach Multiple UEs And Verify Establishing PDU Sessions With Blind SCell Addition
    [Arguments]    ${ue_ids}    ${pdu_ids}    ${gw_ids}    ${cell_id}    ${gnb_id}=2    ${with_SANSA_aliases_setup}=${TRUE}
    ${ues_number}=    Get Length    ${ue_ids}
    FOR    ${ue_index}    IN RANGE    ${ues_number}
        Run Keyword If    ${with_SANSA_aliases_setup}    Create UE Alias    alias=UE${ue_ids}[${ue_index}]    ue_id=${ue_ids}[${ue_index}]
        ...    id_type=wts_5g
        Expect UE Attach Messages Flow     ue_id=${ue_ids}[${ue_index}]    gNB_id=${gnb_id}
        Expect PDU Messages Flow     ue_id=${ue_ids}[${ue_index}]    gNB_id=${gnb_id}
        Expect SCell Addition Messages Flow    ue_id=${ue_ids}[${ue_index}]
        Attach UE And Establish PDU Session    ue_id=${ue_ids}[${ue_index}]    cell_id=${cell_id}    enb_id=${gnb_id}
        ...                                    pdu_id=${pdu_ids}[${ue_index}]    gw_id=${gw_ids}[${ue_index}]
        Check If UE Attach Messages Flow Occurred     ue_id=${ue_ids}[${ue_index}]
        Check If PDU Messages Flow Occurred     ue_id=${ue_ids}[${ue_index}]
        Check If SCell Addition Messages Flow Occured    ue_id=${ue_ids}[${ue_index}]
    END

Attach UE Set Message Flow And Verify Establishing PDU Session
    [Arguments]    ${ue_id}    ${cell_id}    ${gnb_id}    ${pdu_id}    ${gw_id}
    Expect PDU Messages Flow     ue_id=${ue_id}    gNB_id=${gnb_id}
    Attach UE And Establish PDU Session    ue_id=${ue_id}    cell_id=${cell_id}    enb_id=${gnb_id}    pdu_id=${pdu_id}    gw_id=${gw_id}
    Check If PDU Messages Flow Occurred     ue_id=${ue_id}


# A#B1
Verify UE1 4CC FFFT Blind SCell Addition Message Contents
    Verify gNB2 message UEContextModificationRequest number 3 of 8 fulfils ${UE_CON_MOD_REQ_4CC_FFFT_CA_in_AB1_UE1_UE2} content
    Verify gNB2 message UEContextModificationResponse number 3 of 8 fulfils ${sCellToAddModList_AB1_4CC} content
    Verify gNB2 message UEContextModificationResponse number 3 of 8 fulfils ${PUCCH_config_for_4CC_FFFT_CA_in_UE_CON_MOD_RESP} content
    Verify gNB2 message UEContextModificationResponse number 3 of 8 fulfils ${CSI_meas_config_for_4CC_BF_FFFT_CA_in_UE_CON_MOD_RESP_AB1} content

Verify UE2 5CC FFFFT Blind SCell Addition Message Contents
    Verify gNB2 message UEContextModificationRequest number 3 of 24 fulfils ${UE_CON_MOD_REQ_5CC_FFFFT_CA_in_AB1_UE1_UE2} content
    Verify gNB2 message UEContextModificationResponse number 3 of 24 fulfils ${sCellToAddModList_AB1_5CC} content
    Verify gNB2 message UEContextModificationResponse number 3 of 24 fulfils ${PUCCH_config_for_5CC_FFFFT_CA_in_UE_CON_MOD_RESP} content
    Verify gNB2 message UEContextModificationResponse number 3 of 24 fulfils ${CSI_meas_config_for_5CC_BF_FFFFT_CA_in_UE_CON_MOD_RESP_AB1} content

Verify UE3 5CC FFFFT Blind SCell Addition Message Contents
    Verify gNB2 message UEContextModificationRequest number 11 of 24 fulfils ${UE_CON_MOD_REQ_5CC_FFFFT_CA_in_AB1_UE3} content
    Verify gNB2 message UEContextModificationResponse number 11 of 24 fulfils ${sCellToAddModList_AB1_5CC} content
    Verify gNB2 message UEContextModificationResponse number 11 of 24 fulfils ${PUCCH_config_for_5CC_FFFFT_CA_in_UE_CON_MOD_RESP} content
    Verify gNB2 message UEContextModificationResponse number 11 of 24 fulfils ${CSI_meas_config_for_5CC_BF_FFFFT_CA_in_UE_CON_MOD_RESP_AB1} content

Verify UE4 5CC FFFFT Blind SCell Addition Message Contents
    Verify gNB2 message UEContextModificationRequest number 19 of 24 fulfils ${UE_CON_MOD_REQ_5CC_FFFFT_CA_in_AB1_UE4} content
    Verify gNB2 message UEContextModificationResponse number 19 of 24 fulfils ${sCellToAddModList_AB1_5CC} content
    Verify gNB2 message UEContextModificationResponse number 19 of 24 fulfils ${PUCCH_config_for_5CC_FFFFT_CA_in_UE_CON_MOD_RESP} content
    Verify gNB2 message UEContextModificationResponse number 19 of 24 fulfils ${CSI_meas_config_for_5CC_BF_FFFFT_CA_in_UE_CON_MOD_RESP_AB1} content

Verify UE1 5CC FFFFT Blind SCell Addition Message Contents
    Verify gNB2 message UEContextModificationRequest number 3 of 8 fulfils ${UE_CON_MOD_REQ_5CC_FFFFT_CA_in_AB1_UE1_UE2} content
    Verify gNB2 message UEContextModificationResponse number 3 of 8 fulfils ${sCellToAddModList_AB1_5CC} content
    Verify gNB2 message UEContextModificationResponse number 3 of 8 fulfils ${PUCCH_config_for_5CC_FFFFT_CA_in_UE_CON_MOD_RESP} content
    Verify gNB2 message UEContextModificationResponse number 3 of 8 fulfils ${CSI_meas_config_for_5CC_BF_FFFFT_CA_in_UE_CON_MOD_RESP_AB1} content

Verify UE2 4CC FFFT Blind SCell Addition Message Contents
    Verify gNB2 message UEContextModificationRequest number 3 of 24 fulfils ${UE_CON_MOD_REQ_4CC_FFFT_CA_in_AB1_UE1_UE2} content
    Verify gNB2 message UEContextModificationResponse number 3 of 24 fulfils ${sCellToAddModList_AB1_4CC} content
    Verify gNB2 message UEContextModificationResponse number 3 of 24 fulfils ${PUCCH_config_for_4CC_FFFT_CA_in_UE_CON_MOD_RESP} content
    Verify gNB2 message UEContextModificationResponse number 3 of 24 fulfils ${CSI_meas_config_for_4CC_BF_FFFT_CA_in_UE_CON_MOD_RESP_AB1} content

Verify UE3 4CC FFFT Blind SCell Addition Message Contents
    Verify gNB2 message UEContextModificationRequest number 11 of 24 fulfils ${UE_CON_MOD_REQ_4CC_FFFT_CA_in_AB1_UE3} content
    Verify gNB2 message UEContextModificationResponse number 11 of 24 fulfils ${sCellToAddModList_AB1_4CC} content
    Verify gNB2 message UEContextModificationResponse number 11 of 24 fulfils ${PUCCH_config_for_4CC_FFFT_CA_in_UE_CON_MOD_RESP} content
    Verify gNB2 message UEContextModificationResponse number 11 of 24 fulfils ${CSI_meas_config_for_4CC_BF_FFFT_CA_in_UE_CON_MOD_RESP_AB1} content

Verify UE4 4CC FFFT Blind SCell Addition Message Contents
    Verify gNB2 message UEContextModificationRequest number 19 of 24 fulfils ${UE_CON_MOD_REQ_4CC_FFFT_CA_in_AB1_UE4} content
    Verify gNB2 message UEContextModificationResponse number 19 of 24 fulfils ${sCellToAddModList_AB1_4CC_UE4} content
    Verify gNB2 message UEContextModificationResponse number 19 of 24 fulfils ${PUCCH_config_for_4CC_FFFT_CA_in_UE_CON_MOD_RESP} content
    Verify gNB2 message UEContextModificationResponse number 19 of 24 fulfils ${CSI_meas_config_for_4CC_BF_FFFT_CA_in_UE_CON_MOD_RESP_AB1} content

# B#B1
Verify UE1 4CC FTTT SCell Addition Message Contents
    [Arguments]    ${ue_id}
    Verify gNB2 message UEContextModificationRequest number 1 of 3 fulfils ${UE_CON_MOD_REQ_4CC_TFFF_CA_in_BB1} content
    Verify gNB2 message UEContextModificationResponse number 1 of 3 fulfils ${sCellToAddModList_BB1_4CC} content
    Verify gNB2 message UEContextModificationResponse number 1 of 3 fulfils ${PUCCH_config_for_4CC_TFFF_CA_in_UE_CON_MOD_RESP_BB1} content
    Verify gNB2 message UEContextModificationResponse number 1 of 3 fulfils ${CSI_meas_config_for_4CC_TFFF_CA_in_UE_CON_MOD_RESP_BB1} content
    Verify RRC Reconfiguration after A1 SCell Addition 4CC    ue_id=${ue_id}

Verify UE2 5CC TFFFF SCell Addition Message Contents
    [Arguments]    ${ue_id}
    Verify gNB2 message UEContextModificationRequest number 1 of 3 fulfils ${UE_CON_MOD_REQ_5CC_TFFFF_CA_in_BB1_UE2} content
    Verify gNB2 message UEContextModificationResponse number 1 of 3 fulfils ${sCellToAddModList_BB1_5CC} content
    Verify gNB2 message UEContextModificationResponse number 1 of 3 fulfils ${PUCCH_config_for_5CC_TFFFF_CA_in_UE_CON_MOD_RESP_BB1_UE2} content
    Verify gNB2 message UEContextModificationResponse number 1 of 3 fulfils ${CSI_meas_config_for_5CC_TFFFF_CA_in_UE_CON_MOD_RESP_BB1} content
    Verify RRC Reconfiguration after A1 SCell Addition 5CC    ue_id=${ue_id}

Verify UE2 4CC TFFF SCell Addition Message Contents
    [Arguments]    ${ue_id}
    Verify gNB2 message UEContextModificationRequest number 1 of 3 fulfils ${UE_CON_MOD_REQ_4CC_TFFF_CA_in_BB1} content
    Verify gNB2 message UEContextModificationResponse number 1 of 3 fulfils ${sCellToAddModList_BB1_4CC} content
    Verify gNB2 message UEContextModificationResponse number 1 of 3 fulfils ${PUCCH_config_for_4CC_TFFF_CA_in_UE_CON_MOD_RESP_BB1} content
    Verify gNB2 message UEContextModificationResponse number 1 of 3 fulfils ${CSI_meas_config_for_4CC_TFFF_CA_in_UE_CON_MOD_RESP_BB1} content
    Verify RRC Reconfiguration after A1 SCell Addition 4CC    ue_id=${ue_id}

Verify UE1 5CC FFFFT SCell Addition Message Contents
    Verify gNB2 message UEContextModificationRequest number 1 of 3 fulfils ${UE_CON_MOD_REQ_5CC_FFFFT_CA_in_AB5} content
    Verify gNB2 message UEContextModificationResponse number 1 of 3 fulfils ${sCellToAddModList_AB4_5CC} content
    Verify gNB2 message UEContextModificationResponse number 1 of 3 fulfils ${PUCCH_config_for_5CC_FFFFT_CA_in_UE_CON_MOD_RESP_AB4} content
    Verify gNB2 message UEContextModificationResponse number 1 of 3 fulfils ${CSI_meas_config_for_5CC_FFFFT_CA_in_UE_CON_MOD_RESP_AB4} content
    Verify UE1 message RRCReconfiguration number 1 of 1 fulfils ${meas_config_in_RRC_Reconf_5CC_FFFFT_AB5} content

Verify UE1 4CC FFFF SCell Release Message Contents
    Verify gNB2 message UEContextModificationRequest number 1 of 3 fulfils ${sCellToBeRemoveList_AB5} content
    Verify gNB2 message UEContextModificationResponse number 1 of 3 fulfils ${CSI_Release_in_UE_CON_MOD_RESP_AB4} content
    Verify UE11 message RRCReconfiguration number 1 of 1 fulfils ${meas_config_in_RRC_Reconf_5CC_FFFFT_AB5_after_A2} content
    Verify gNB2 message UEContextModificationResponse number 3 of 3 fulfils ${PUCCH_config_for_5CC_FFFF_CA_in_UE_CON_MOD_RESP_AB5} content
    Verify gNB2 message UEContextModificationResponse number 3 of 3 fulfils ${CSI_meas_config_after_A2_for_in_UE_CON_MOD_RESP_AB5} content
    Verify gNB2 message UEContextModificationResponse number 3 of 3 fulfils ${sCellToAddModList_AB5_after_A2} content

Verify UE5 5CC TFFFF SCell Addition Message Contents
    Verify gNB2 message UEContextModificationRequest number 1 of 3 fulfils ${UE_CON_MOD_REQ_5CC_TFFFF_CA_in_BB4} content
    Verify gNB2 message UEContextModificationResponse number 1 of 3 fulfils ${sCellToAddModList_BB4_5CC} content
    Verify UE5 message RRCReconfiguration number 1 of 1 fulfils ${meas_config_in_RRC_Reconf_5CC_TFFFF_BB4} content

# B#B5
Verify UE50 5CC TFFFF BB5 SCell Addition Message Contents
    Verify gNB2 message UEContextModificationRequest number 1 of 3 fulfils ${UE_CON_MOD_REQ_5CC_TFFFF_CA_in_BB5_UE5} content
    Verify gNB2 message UEContextModificationResponse number 1 of 3 fulfils ${sCellToAddModList_BB5_5CC} content
    Verify gNB2 message UEContextModificationResponse number 1 of 3 fulfils ${CSI_meas_config_for_5CC_TFFFF_CA_in_UE_CON_MOD_RESP_BB1} content
    Verify UE50 message RRCReconfiguration number 1 of 1 fulfils ${meas_config_in_RRC_Reconf_5CC_TFFFF_BB5_after_A1} content

Verify UE5 5CC TFFFF SCell Change Message Contents
    Verify gNB2 message UEContextModificationRequest number 1 of 2 fulfils ${UE_CON_MOD_REQ_5CC_TFFFF_CA_in_BB4_1} content
    Verify gNB2 message UEContextModificationRequest number 1 of 2 fulfils ${sCellToBeRemoveList_BB4} content
    Verify gNB2 message UEContextModificationResponse number 1 of 2 fulfils ${sCellToAddModList_BB4_5CC_1} content
    Verify gNB2 message UEContextModificationResponse number 1 of 2 fulfils ${SCell_Release_in_UE_CON_MOD_RESP_BB4} content
    Verify UE5 message RRCReconfiguration number 1 of 1 fulfils ${meas_config_in_RRC_Reconf_5CC_TFFFF_BB4_1} content

Set ${all:\d+} expected UE Context Modification messages for gNB${gnb_id:\d+}
    EXPECT FLOW[timeout=20]: gNB${gnb_id} F1AP ${all}*uEContextModification

Verify ${all:\d+} UE Context Modification messages for gNB${gnb_id:\d+} occured
    PASS FLOW[timeout=20]: gNB${gnb_id} F1AP ${all}*uEContextModification

Set ${all:\d+} expected UE Context Modification messages for gNB${gnb_id:\d+} for multiple UEs
    EXPECT FLOW[timeout=30]: gNB${gnb_id} F1AP ${all}*uEContextModification

Verify ${all:\d+} UE Context Modification messages for gNB${gnb_id:\d+} occured for multiple UEs
    PASS FLOW[timeout=30]: gNB${gnb_id} F1AP ${all}*uEContextModification

Set ${rrc_comp:\d+} expected RRC Reconfiguration Request and Complete messages for UE${ue_id:\d+}
    EXPECT FLOW[timeout=90]: UE${ue_id} NR-RRC ${rrc_comp}*RRCReconfiguration
    EXPECT FLOW[timeout=90]: UE${ue_id} NR-RRC ${rrc_comp}*RRCReconfigurationComplete

Set expected RRC Reconfiguration Request and Complete messages for UE${ue_id:\d+}
    EXPECT FLOW[timeout=3]: UE${ue_id} NR-RRC RRCReconfiguration
    EXPECT FLOW[timeout=3]: UE${ue_id} NR-RRC RRCReconfigurationComplete

Verify that ${rrc_comp:\d+} RRC Reconfiguration Request and Complete messages occured for UE${ue_id:\d+}
    PASS FLOW[timeout=90]: UE${ue_id} NR-RRC ${rrc_comp}*RRCReconfiguration
    PASS FLOW[timeout=90]: UE${ue_id} NR-RRC ${rrc_comp}*RRCReconfigurationComplete

Verify that RRC Reconfiguration Request and Complete messages occured for UE${ue_id:\d+}
    PASS FLOW[timeout=3]: UE${ue_id} NR-RRC RRCReconfiguration
    PASS FLOW[timeout=3]: UE${ue_id} NR-RRC RRCReconfigurationComplete

Set expected Measurement Report messages for UE${ue_id:\d+}
    EXPECT FLOW[timeout=15]: UE${ue_id} NR-RRC MeasurementReport

Verify that Measurement Report messages occured for UE${ue_id:\d+}
    PASS FLOW[timeout=15]: UE${ue_id} NR-RRC MeasurementReport

Set ${meas_rep_msg:\d+} expected Measurement Reports messages for UE${ue_id:\d+}
    EXPECT FLOW[timeout=60]: UE${ue_id} NR-RRC ${meas_rep_msg}*MeasurementReport

Verify that all ${meas_rep_msg:\d+} Measurement Reports messages occured for UE${ue_id:\d+}
    PASS FLOW[timeout=60]: UE${ue_id} NR-RRC ${meas_rep_msg}*MeasurementReport

Verify A1 Measurement Configuration for PCell
    [Arguments]    ${ue_id}    ${filters}
    Verify That Message Fulfills Query
    ...  ${filters}
    ...  message_alias=RRCReconfiguration
    ...  flow_alias=Established_PDU_NR_RRC_UE${ue_id}

Verify A2 Measurement Configuration for handover
    [Arguments]    ${ue_id}    ${filters}
    Verify That Message Fulfills Query
    ...  ${filters}
    ...  message_alias=RRCReconfiguration
    ...  flow_alias=Established_PDU_NR_RRC_UE${ue_id}

Trigger A1 Based SCell Addition
    [Arguments]    ${ue_id}    ${gNB_id}    ${meas_id_a1}    ${srsrp_a1}
    Expect SCell Addition Messages Flow    ${ue_id}    ${gNB_id}
    Execute Egate Command And Wait For Data
    ...    cmd=ue_measurement_send_nr id=${UE_ID} meas_id=${meas_id_a1} event=A1 srsrp_nr=${srsrp_a1}

Trigger and Verify A1 Based SCell Addition
    [Arguments]    ${ue_id}    ${gNB_id}    ${meas_id_a1}    ${srsrp_a1}    ${filters}
    Expect SCell Addition Messages Flow    ${ue_id}    ${gNB_id}
    Execute Egate Command And Wait For Data
    ...    cmd=ue_measurement_send_nr id=${UE_ID} meas_id=${meas_id_a1} event=A1 srsrp_nr=${srsrp_a1}
    Verify UE${ue_id} message MeasurementReport number 1 of 1 fulfils ${filters} content

Trigger and Verify A1 Based SCell Addition BB5
    [Arguments]    ${ue_id}    ${gNB_id}    ${meas_id_a1}    ${srsrp_a1}    ${filters}
    Set Message Flow Expectations for A1 Based SCell Addition   ue_id=${ue_id}    gnb_id=${gnb_id}
    Send Ue Measurement Nr    ue_id=${ue_id}    meas_id=${meas_id_a1}    event=A1    srsrp_nr=${srsrp_a1}
    Verify UE50 message MeasurementReport number 1 of 2 fulfils ${filters} content
    Verify UE50 5CC TFFFF BB5 SCell Addition Message Contents

Trigger A1 Based SCell Change
    [Arguments]    ${ue_id}    ${meas_id_a1}    ${srsrp_a1}
    Execute Egate Command And Wait For Data
    ...    cmd=ue_measurement_send_nr id=${UE_ID} meas_id=${meas_id_a1} event=A1 srsrp_nr=${srsrp_a1}

Trigger and Verify A4 Based SCell Addition
    [Arguments]    ${ue_id}    ${meas_id_a4}    ${nrsrp_a4}    ${phycell_id}
    Execute Egate Command And Wait For Data
    ...    cmd=ue_measurement_send_nr id=${ue_id} meas_id=${meas_id_a4} event=A4 phycell_id=${phycell_id} nrsrp_nr=${nrsrp_a4}

Set ${meas_rep_msg:\d+} expected Measurement Report messages for UE${ue_id:\d+}
    EXPECT FLOW[timeout=90]: UE${ue_id} NR-RRC ${meas_rep_msg}*MeasurementReport

Verify that all ${meas_rep_msg:\d+} Measurement Report messages occured for UE${ue_id:\d+}
    PASS FLOW[timeout=9]: UE${ue_id} NR-RRC ${meas_rep_msg}*MeasurementReport

Set ${meas_rep_msg:\d+} expected Measurement Report messages timeout ${timeout:\d+}s for UE${ue_id:\d+}
    EXPECT FLOW[timeout=${timeout}]: UE${ue_id} NR-RRC ${meas_rep_msg}*MeasurementReport

Verify that Measurement Report messages timeout ${timeout:\d+}s occured for UE${ue_id:\d+}
    PASS FLOW[timeout=${timeout}]: UE${ue_id} NR-RRC MeasurementReport

Verify RRC Reconfiguration after A1 SCell Addition 4CC
    [Arguments]    ${ue_id}
    Verify That Message Fulfills Query
    ...  ${meas_config_in_RRC_Reconf_4CC_TFFF}
    ...  message_alias=RRCReconfiguration
    ...  flow_alias=SCellAddition_UE${ue_id}

Verify RRC Reconfiguration after A1 SCell Addition 5CC
    [Arguments]    ${ue_id}
    Verify That Message Fulfills Query
    ...  ${meas_config_in_RRC_Reconf_5CC_TFFFF}
    ...  message_alias=RRCReconfiguration
    ...  flow_alias=SCellAddition_UE${ue_id}

Traffic Start High DL non-GBR Data
    [Arguments]    ${ue_id}   ${pdu_id}
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} trf_id=1 dir=dl mbps=150
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} trf_id=2 dir=dl mbps=150
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} trf_id=3 dir=dl mbps=125
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} trf_id=4 dir=dl mbps=125

Set ${all:\d+} expected PrivateMessages UE gNB${gnb_id:\d+}
    EXPECT FLOW[timeout=20]: gNB${gnb_id} F1AP ${all}*privateMessage

Verify that all ${all:\d+} expected PrivateMessages occured UE gNB${gnb_id:\d+}
    PASS FLOW[timeout=20]: gNB${gnb_id} F1AP ${all}*privateMessage

Verify that PrivateMessage ${msg_num:\d+} of ${all:\d+} is BufferMonitoringNotification for gNB${gnb_id:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=${all}*privateMessage
    ...     device=gNB${gnb_id}
    ...     protocol=F1AP
    ${message_alias}    Set Variable If    ${all} != 1    PrivateMessage_${msg_num}    PrivateMessage

    Verify That Message Fulfills Query
    ...     ${buffer_monitoring_activate_dl}
    ...     message_alias=${message_alias}
    ...     flow_alias=${flow_alias}

Verify that PrivateMessage ${msg_num:\d+} of ${all:\d+} is BufferCriterionNotification for gNB${gnb_id:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=${all}*privateMessage
    ...     device=gNB${gnb_id}
    ...     protocol=F1AP
    ${message_alias}    Set Variable If    ${all} != 1    PrivateMessage_${msg_num}    PrivateMessage

    Verify That Message Fulfills Query
    ...     ${buffer_criterion_downlink}
    ...     message_alias=${message_alias}
    ...     flow_alias=${flow_alias}

Verify that UEContextModificationResponse ${msg_num:\d+} of ${all:\d+} contains measGapConfig for gNB${gnb_id:\d+}
    [Documentation]    message filters in BB9 scenario are similar to BB10
    ${flow_alias}=     Get flow name
    ...     procedure=${all}*uEContextModification
    ...     device=gNB${gnb_id}
    ...     protocol=F1AP

    verify_if_information_element_contains  measGapConfig  ${flow_alias}  UEContextModificationResponse_${msg_num}  0x80C06C007000

Trigger A2 Based SCell Release
    [Arguments]    ${A2_cmd}
    Execute Egate Command And Wait For Data
    ...    cmd=ue_measurement_send_nr ${A2_cmd}

Trigger and Verify A2 PCell Change
    [Arguments]    ${ue_id}   ${gnb_id}    ${meas_id_A2}    ${filters}
    Set Message Flow Expectations for A2 PCell Change   ue_id=${ue_id}    gnb_id=${gnb_id}
    Send Ue Measurement Nr    ue_id=${ue_id}    meas_id=${meas_id_A2}    event=A2    srsrp_nr=5    srsrq_nr=10
    ...     scell=3    scell_rsrp=70    scell_rsrq=90
    Check Message Flow Expectations for A2 PCell Change    ue_id=${ue_id}
    Verify UE50 message MeasurementReport number 2 of 2 fulfils ${filters} content
    Verify UE50 PCell Change Message Contents

Set Message Flow Expectations for A2 PCell Change
    [Arguments]    ${ue_id}    ${gnb_id}
    Set Expected UE Context Modification Request and Response in gNB${gnb_id} for A2 PCell Change
    Set 2 expected RRC Reconfiguration Request and Complete messages for UE${ue_id}

Set Expected UE Context Modification Request and Response in gNB${gnb_id:\d+} for A2 PCell Change
    Expect Message Flow
    ...    gNB${gnb_id}:F1AP_UEContextModificationRequest (SCell-ToBeRemoved-List is present) as UEContModRequest
    ...    gNB${gnb_id}:F1AP_UEContextModificationResponse (sCellToReleaseList is present) as UEContModResponse
    ...    alias=UE_Ctx_Mod_A2_PCell_Change
    ...    overall_timeout=20

Check Expected UE Context Modification Request and Response for A2 PCell Change Occured
    Flow Occurred As Expected    alias=UE_Ctx_Mod_A2_PCell_Change

Set Message Flow Expectations for A1 Based SCell Addition
    [Arguments]    ${ue_id}    ${gnb_id}
    Set 3 expected UE Context Modification messages for gNB${gnb_id}
    Set expected RRC Reconfiguration Request and Complete messages for UE${ue_id}

Check Message Flow Expectations for A2 PCell Change
    [Arguments]    ${ue_id}
    Check Expected UE Context Modification Request and Response for A2 PCell Change Occured
    Verify that 2 RRC Reconfiguration Request and Complete messages occured for UE${ue_id}

Check Message Flow Expectations for A1 Based SCell Addition
    [Arguments]    ${ue_id}    ${gnb_id}
    Verify 3 UE Context Modification messages for gNB${gnb_id} occured
    Verify that RRC Reconfiguration Request and Complete messages occured for UE${ue_id}

Verify UE50 PCell Change Message Contents
    Verify That Message Fulfills Query
    ...  ${HO_Information_in_UE_CON_MOD_REQ}
    ...  message_alias=UEContModRequest
    ...  flow_alias=UE_Ctx_Mod_A2_PCell_Change
    Verify That Message Fulfills Query
    ...  ${sCellToBeRemoveList_BB5}
    ...  message_alias=UEContModRequest
    ...  flow_alias=UE_Ctx_Mod_A2_PCell_Change
    Verify That Message Fulfills Query
    ...  ${SCell_Release_in_UE_CON_MOD_RESP_BB5}
    ...  message_alias=UEContModResponse
    ...  flow_alias=UE_Ctx_Mod_A2_PCell_Change
    Verify UE50 message RRCReconfiguration number 1 of 2 fulfils ${meas_config_in_RRC_Reconf_BB5_after_A2} content

Verify 5CC CA Counters AB5
    [Arguments]    ${scell_1}    ${scell_2}    ${scell_3}    ${scell_4}    ${pcell}
    ${pm_counter_file}=    Get Next Unpacked Full Pm Counters File
    Verify Any Counters In File
    ...    M55316C03004    > 0    PSCELL_UE_4_ACT_SCELL_DL
    ...    M55138C00048    1    GNB_SCELL_4_ADMI_REQ_SA
    ...    M55138C00049    1    GNB_SCELL_4_ADMI_SUCC_SA
    ...    M55139C00023    1    GNB_DU_SCELL_4_ADMI_REQ_SA
    ...    M55139C00024    1    GNB_DU_SCELL_4_ADMI_SUCC_SA
    ...    M55118C02014    1    RRC_RECONF_ADD4DLSCELL_SUCC_SA
    ...    M55118C02015    1    RRC_RECONF_ADD4DLSCELL_ATT_SA
    ...    M55118C02016    > 0    UE_PCELL_4_CONF_SCELL_DL_SA
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${pcell}
    ...    file_path=${pm_counter_file}
    Verify Any Counters In File
    ...    M55118C07510    > 0    UE_SCELL_4_CONF_SCELL_DL_SA
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${scell_1}
    ...    file_path=${pm_counter_file}
    Verify Any Counters In File
    ...    M55118C07510    > 0    UE_SCELL_4_CONF_SCELL_DL_SA
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${scell_2}
    ...    file_path=${pm_counter_file}
    Verify Any Counters In File
    ...    M55118C07510    > 0    UE_SCELL_4_CONF_SCELL_DL_SA
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${scell_3}
    ...    file_path=${pm_counter_file}
    Verify Any Counters In File
    ...    M55118C07510    > 0    UE_SCELL_4_CONF_SCELL_DL_SA
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${scell_4}
    ...    file_path=${pm_counter_file}
