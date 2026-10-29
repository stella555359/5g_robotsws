*** Settings ***
Documentation    Keywords for the CB005934

Library      ute_wtssim
Library      ta_messaging
Resource     testsuite/Wroclaw/RRM/WRO_2/keywords/tshark_verifying.robot
Resource     testsuite/Wroclaw/RRM/WRO_2/keywords/ue_measurements.robot
Resource     testsuite/Wroclaw/RRM/WRO_2/keywords/messaging.robot
Resource     testsuite/Wroclaw/RRM/VRF_WRO2_T023/resources/airphone/measurements.robot
Variables    CB005934_messaging_filters.py


*** Keywords ***
Verify A1 Measurements Are Configured At Multiple UEs
    [Arguments]    ${ue_ids}    ${a1_event_params}    ${a1_frequencies}
    ${ues_number}=    Get Length    ${ue_ids}
    FOR    ${ue_index}    IN RANGE    ${ues_number}
        Verify Measurements Are Configured At UE    ue_id=${ue_ids}[${ue_index}]   event_type=EventA1
        ...    event_params=${a1_event_params}    frequencies=${a1_frequencies}
    END

Trigger A1 Measurement For Multiple UEs
    [Arguments]    ${ue_ids}    ${meas_id}    ${srsrp_nr}
    ${ues_number}=    Get Length    ${ue_ids}
    FOR    ${ue_index}    IN RANGE    ${ues_number}
        Trigger A1 Measurement    ue_id=${ue_ids}[${ue_index}]   meas_id=${meas_id}    srsrp_nr=${srsrp_nr}
    END

Trigger A1 Measurement And Expect SCell Addition Messages Flow For Multiple UEs
    [Arguments]    ${gnb_id}    ${ue_ids}    ${meas_id}    ${srsrp_nr}    ${overall_timeout}=60
    ${ues_number}=    Get Length    ${ue_ids}
    FOR    ${ue_index}    IN RANGE    ${ues_number}
        Expect A1 Measurement Report And SCell Addition Messages Flow    gnb_id=${gnb_id}    ue_id=${ue_ids}[${ue_index}]
        ...    meas_id=${meas_id}    overall_timeout=${overall_timeout}
        Trigger A1 Measurement    ue_id=${ue_ids}[${ue_index}]   meas_id=${meas_id}    srsrp_nr=${srsrp_nr}
    END

Verify SCell Addition Messages Content After A1 Event Trigger For Multiple UEs
    [Arguments]    ${ue_ids}
    ${ues_number}=    Get Length    ${ue_ids}
    FOR    ${ue_index}    IN RANGE    ${ues_number}
        Verify That Message Fulfills Query
        ...  ${A1_measurement_for_SCell_Addition}
        ...  message_alias=A1measurementReport
        ...  flow_alias=SCellAddition_UE${ue_ids}[${ue_index}]
        Verify That Message Fulfills Query
        ...  ${selected_SCells_for_4CC_FFFF_UE_CA_in_UE_CON_MOD_REQ}
        ...  message_alias=UEContModRequest
        ...  flow_alias=SCellAddition_UE${ue_ids}[${ue_index}]
        Verify That Message Fulfills Query
        ...  ${resourceSet1_4CC_FFFF}
        ...  message_alias=UEContModResponse
        ...  flow_alias=SCellAddition_UE${ue_ids}[${ue_index}]
        Verify That Message Fulfills Query
        ...  ${selected_SCells_for_4CC_FFFF_UE_CA_in_UE_CON_MOD_RESP}
        ...  message_alias=UEContModResponse
        ...  flow_alias=SCellAddition_UE${ue_ids}[${ue_index}]
        Verify That Message Fulfills Query
        ...  ${meas_config_for_A1_removal_in_RRC_Reconfiguration}
        ...  message_alias=RRCReconfiguration
        ...  flow_alias=SCellAddition_UE${ue_ids}[${ue_index}]
        Verify That Message Fulfills Query
        ...  ${rrc_reconfiguration_complete_indicator_in_UE_CON_MOD_REQ}
        ...  message_alias=UECMRInd
        ...  flow_alias=SCellAddition_UE${ue_ids}[${ue_index}]
        Verify That Message Fulfills Query
        ...  ${gnb_configuration_query_in_UE_CON_MOD_REQ}
        ...  message_alias=UECMRQuery
        ...  flow_alias=SCellAddition_UE${ue_ids}[${ue_index}]
    END

Start Data Traffic For Multiple UEs
    [Arguments]    ${ue_ids}   ${pdu_ids}
    ${ues_number}=    Get Length    ${ue_ids}
    FOR    ${ue_index}    IN RANGE    ${ues_number}
        Start Data Traffic    ue_id=${ue_ids}[${ue_index}]   pdu_id=${pdu_ids}[${ue_index}]
    END

Start Data Traffic
    [Arguments]    ${ue_id}=1   ${pdu_id}=1    ${Inactive Timer}=2s
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} trf_id=1 dir=dl mbps=100
    BuiltIn.Sleep    ${Inactive Timer}
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} trf_id=2 dir=dl mbps=100
    BuiltIn.Sleep    ${Inactive Timer}
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} trf_id=3 dir=dl mbps=100
    BuiltIn.Sleep    ${Inactive Timer}
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} trf_id=4 dir=dl mbps=100
    BuiltIn.Sleep    ${Inactive Timer}
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} trf_id=5 dir=ul mbps=100
    BuiltIn.Sleep    ${Inactive Timer}
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} trf_id=6 dir=ul mbps=100
    BuiltIn.Sleep    ${Inactive Timer}

Verify Traffic on PCell and All SCells For Multiple UEs
    [Arguments]    ${ue_ids}
    ${ues_number}=    Get Length    ${ue_ids}
    FOR    ${ue_index}    IN RANGE    ${ues_number}
        Verify Traffic Is Scheduled On All Cells 4CC DL And UL On PCell    ue_id=${ue_ids}[${ue_index}]
    END

Verify Traffic Is Scheduled On All Cells 4CC DL And UL On PCell
    [Arguments]    ${ue_id}=1
    Verify DL Traffic Is Scheduled On All Cells 4CC    ue_id=${ue_id}
    BuiltIn.Sleep    10s   #Need to catch traffic
    Verify UL Traffic Is Scheduled On PCell    ue_id=${ue_id}

Verify DL Traffic Is Scheduled On All Cells 4CC
    [Arguments]    ${ue_id}=1
    Verify That Traffic Is Scheduled On All SCells    ue_id=${ue_id}    num_of_scells=3
    Expected Throughput For Ue Should Be Reached    ue_id=${ue_id}    throughput=10    direction=dl    selection_type=average    scells=0-3

Verify UL Traffic Is Scheduled On PCell
    [Arguments]    ${ue_id}=1
    Expected Throughput For Ue Should Be Reached    ue_id=${ue_id}    throughput=10    direction=ul    selection_type=average    scells=0-0
    ...                                             cell_group=MCG

Expect A1 Measurement Report And SCell Addition Messages Flow
    [Arguments]    ${gnb_id}    ${ue_id}    ${meas_id}    ${overall_timeout}
    Expect Message Flow
    ...    UE${ue_id}:NR-RRC_MeasurementReport (measId eq ${meas_id}) as A1measurementReport
    ...    gNB${gnb_id}:F1AP_UEContextModificationRequest (SCell-ToBeSetupMod-List is present) as UEContModRequest
    ...    gNB${gnb_id}:F1AP_UEContextModificationResponse (sCellToAddModList is present) as UEContModResponse
    ...    UE${ue_id}:NR-RRC_RRCReconfiguration (measIdToRemoveList is present) as RRCReconfiguration
    ...    gNB${gnb_id}:F1AP_UEContextModificationRequest (RRCReconfigurationCompleteIndicator is present) as UECMRInd
    ...    gNB${gnb_id}:F1AP_UEContextModificationRequest (GNB-DUConfigurationQuery is present) as UECMRQuery
    ...    alias=SCellAddition_UE${ue_id}
    ...    overall_timeout=${overall_timeout}

Verify SCell Addition Messages Content After A1 TDD Event Trigger For Multiple UEs
    [Arguments]    ${ue_ids}
    ${ues_number}=    Get Length    ${ue_ids}
    FOR    ${ue_index}    IN RANGE    ${ues_number}
        Verify That Message Fulfills Query
        ...  ${A1_measurement_for_TDD_SCell_Addition}
        ...  message_alias=A1measurementReport
        ...  flow_alias=SCellAddition_UE${ue_ids}[${ue_index}]
        Verify That Message Fulfills Query
        ...  ${selected_SCells_for_3CC_FTT_UE_CA_in_UE_CON_MOD_REQ}
        ...  message_alias=UEContModRequest
        ...  flow_alias=SCellAddition_UE${ue_ids}[${ue_index}]
        Verify That Message Fulfills Query
        ...  ${resourceSet1_3CC_FTT}
        ...  message_alias=UEContModResponse
        ...  flow_alias=SCellAddition_UE${ue_ids}[${ue_index}]
        Verify That Message Fulfills Query
        ...  ${selected_SCells_for_3CC_FTT_UE_CA_in_UE_CON_MOD_RESP}
        ...  message_alias=UEContModResponse
        ...  flow_alias=SCellAddition_UE${ue_ids}[${ue_index}]
        Verify That Message Fulfills Query
        ...  ${meas_config_for_A1_removal_in_RRC_Reconfiguration}
        ...  message_alias=RRCReconfiguration
        ...  flow_alias=SCellAddition_UE${ue_ids}[${ue_index}]
        Verify That Message Fulfills Query
        ...  ${rrc_reconfiguration_complete_indicator_in_UE_CON_MOD_REQ}
        ...  message_alias=UECMRInd
        ...  flow_alias=SCellAddition_UE${ue_ids}[${ue_index}]
        Verify That Message Fulfills Query
        ...  ${gnb_configuration_query_in_UE_CON_MOD_REQ}
        ...  message_alias=UECMRQuery
        ...  flow_alias=SCellAddition_UE${ue_ids}[${ue_index}]
    END

Verify SCell Addition Messages Content After A1 FDD Event Trigger For Multiple UEs
    [Arguments]    ${ue_ids}
    ${ues_number}=    Get Length    ${ue_ids}
    FOR    ${ue_index}    IN RANGE    ${ues_number}
        Verify That Message Fulfills Query
        ...  ${A1_measurement_for_FDD_SCell_Addition}
        ...  message_alias=A1measurementReport
        ...  flow_alias=SCellAddition_UE${ue_ids}[${ue_index}]
        Verify That Message Fulfills Query
        ...  ${selected_SCells_for_4CC_FFFF_UE_CA_in_UE_CON_MOD_REQ_2}
        ...  message_alias=UEContModRequest
        ...  flow_alias=SCellAddition_UE${ue_ids}[${ue_index}]
        Verify That Message Fulfills Query
        ...  ${selected_SCells_for_4CC_FFFF_UE_CA_in_UE_CON_MOD_RESP_2}
        ...  message_alias=UEContModResponse
        ...  flow_alias=SCellAddition_UE${ue_ids}[${ue_index}]
        Verify That Message Fulfills Query
        ...  ${meas_config_for_A1_FDD_removal_in_RRC_Reconfiguration}
        ...  message_alias=RRCReconfiguration
        ...  flow_alias=SCellAddition_UE${ue_ids}[${ue_index}]
        Verify That Message Fulfills Query
        ...  ${rrc_reconfiguration_complete_indicator_in_UE_CON_MOD_REQ}
        ...  message_alias=UECMRInd
        ...  flow_alias=SCellAddition_UE${ue_ids}[${ue_index}]
        Verify That Message Fulfills Query
        ...  ${gnb_configuration_query_in_UE_CON_MOD_REQ}
        ...  message_alias=UECMRQuery
        ...  flow_alias=SCellAddition_UE${ue_ids}[${ue_index}]
    END
