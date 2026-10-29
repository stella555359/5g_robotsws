*** Settings ***

Documentation    Keywords for CB009854.

*** Keywords ***

Register UE To gNB
    [Arguments]    ${UE_Id}
    Execute Egate Command    cmd=ue_register id=${UE_Id}
    Wait For UE Register    3s
    Execute Egate Command    cmd=set_pdu_param ue=${UE_Id} pdu=3 trf_type=internal
    Execute Egate Command    cmd=ue_pdu_session_setup ue=${UE_Id} pdu=3 nwslice=1 gw=3
    Wait For UE Register    10s

Wait For UE Register
    [Arguments]    ${Inactive Timer}
    BuiltIn.Sleep    ${Inactive Timer}

Trigger CA With A1 Measurement
    [Arguments]    ${UE_Id}    ${Meas_Id}
    Execute Egate Command    cmd=ue_measurement_send_nr id=${UE_Id} meas_id=${Meas_Id} event=A1 srsrp_nr=90
    Wait For Trigger CA    10s

Send A1 Measurement - Secondary Measurement Quantity Not Sufficient
    [Arguments]    ${UE_Id}    ${Meas_Id}
    Execute Egate Command    cmd=ue_measurement_send_nr id=${UE_Id} meas_id=${Meas_Id} event=A1 srsrp_nr=90 srsrq_nr=50
    Wait For Trigger CA    10s

Perform Pcell Switch
    [Arguments]    ${UE_Id}    ${Meas_Id}
    Execute Egate Command    cmd=ue_measurement_send_nr id=${UE_Id} meas_id=${Meas_Id} event=A1 scell=1 scell_rsrp=90
    ...   scell=2 scell_rsrp=34 scell=3 scell_rsrp=34
    Wait For Trigger CA    10s

Wait For Trigger CA
    [Arguments]    ${Inactive Timer}
    BuiltIn.Sleep    ${Inactive Timer}

Trigger A1 Measurement
    [Arguments]    ${ue_id}    ${meas_id}    ${Inactive Timer}=5s
    Execute Egate Command    cmd=ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=90 srsrq_nr=95
    BuiltIn.Sleep    ${Inactive Timer}

Trigger A6 Measurement
    [Arguments]    ${A6_cmd}
    Execute Egate Command    cmd=ue_measurement_send_nr ${A6_cmd}


Verify A6 Measurement
    [Arguments]    ${Verify_A6_Measurement}
    Verify Tcpdump Log    ${Verify_A6_Measurement}

Verify Scell Swap
    [Arguments]    ${Verify_Scell_Swap}
    Verify Tcpdump Log    ${Verify_Scell_Swap}

Verify DL Traffic Is Scheduled On All Cells 5CC
    [Arguments]    ${ue_id}=3
    Verify That Traffic Is Scheduled On All SCells    ue_id=${ue_id}    num_of_scells=4
    Verify That Throughput Is Reached On All SCells    ue_id=${ue_id}    num_of_scells=4    expected_throughput=10Mbps

Verify UL Traffic Is Scheduled On All Cells 2CC
    [Arguments]    ${ue_id}=3
    Verify That Throughput Is Reached On Cell Group    ue_id=${ue_id}    expected_throughput=10Mbps    cell_index_min=0
    ...   cell_index_max=0    direction=ul
    Verify That Throughput Is Reached On Cell Group    ue_id=${ue_id}    expected_throughput=10Mbps    cell_index_min=4
    ...   cell_index_max=4    direction=ul

Start Data Traffic
    [Arguments]    ${ue_id}=3     ${pdu}=3   ${Inactive Timer}=2s
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu} trf_id=1 dir=dl mbps=100
    BuiltIn.Sleep    ${Inactive Timer}
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu} trf_id=2 dir=dl mbps=100
    BuiltIn.Sleep    ${Inactive Timer}
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu} trf_id=3 dir=dl mbps=100
    BuiltIn.Sleep    ${Inactive Timer}
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu} trf_id=4 dir=dl mbps=100
    BuiltIn.Sleep    ${Inactive Timer}
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu} trf_id=5 dir=ul mbps=100
    BuiltIn.Sleep    ${Inactive Timer}
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu} trf_id=6 dir=ul mbps=100
    BuiltIn.Sleep    ${Inactive Timer}


Trigger A2 Measurement
    [Arguments]    ${A2_cmd}
    Execute Egate Command    cmd=ue_measurement_send_nr ${A2_cmd}


Verify A1 Measurement
    [Arguments]    ${Verify_A1_Measurement}
    Verify Tcpdump Log    ${Verify_A1_Measurement}


Verify Message
    [Arguments]    ${expectation}
    Verify Tcpdump Log    ${expectation}


Wait For Trigger SCell Release
    [Arguments]    ${Inactive Timer}
    BuiltIn.Sleep    ${Inactive Timer}



Reboot Testline
    Run Keyword If    ${REBOOT} == ${True}    Trigger Site Reset
    Wait For Testline ICMP Echo Replies And SSH Services
    Set Suite Variable    $REBOOT    ${True}


Verify 5CC DL And 2CC UL FFTTT Blind SCell Addition Message Contents
    [Arguments]    ${ue_id}
    Verify That Message Fulfills Query
    ...  ${selected_SCells_for_5CC_FFTTT_UE_CA_in_UE_CON_MOD_REQ_B3}
    ...  message_alias=UEContextModificationRequest
    ...  flow_alias=SCellAddition_UE${ue_id}
    Verify That Message Fulfills Query
    ...  ${selected_SCells_for_5CC_FFTTT_UE_CA_in_UE_CON_MOD_RESP_B3}
    ...  message_alias=UEContextModificationResponse
    ...  flow_alias=SCellAddition_UE${ue_id}
    Verify 5CC FFTTT PUCCH Config And CSI Config    ue_id=${ue_id}

Verify 5CC FFTTT PUCCH Config And CSI Config
    [Arguments]    ${ue_id}
    Verify That Message Fulfills Query
    ...  ${PUCCH_config_for_5CC_FFTTT_CA_BF_in_UE_CON_MOD_RESP_B3}
    ...  message_alias=UEContextModificationResponse
    ...  flow_alias=SCellAddition_UE${ue_id}
    Verify That Message Fulfills Query
    ...  ${CSI_meas_config_for_5CC_FFTTT_CA_BF_in_UE_CON_MOD_RESP_B3}
    ...  message_alias=UEContextModificationResponse
    ...  flow_alias=SCellAddition_UE${ue_id}


Release UE
    [Arguments]    ${ue_id}=${UE_ID}    ${pdu_id}=${PDU_PCELL_1}
    Release PDU session    ue_id=${UE_ID}    pdu_id=${pdu_id}
    Deregister UE    ue_id=${UE_ID}

Attach UE And Verify Establishing PDU Session And DRX Setup With Blind SCell Addition
    [Arguments]    ${ue_id}    ${cell_id}    ${gnb_id}    ${pdu_id}    ${gw_id}
    Expect DRX Setup Message Flow    ue_id=${UE_ID}    gnb_id=${GNB_ID}    timer_length=${TIMER_LENGTH}
    Attach UE And Verify Establishing PDU Session With Blind SCell Addition    ue_id=${UE_ID}    cell_id=${cell_id}
    ...    gnb_id=${GNB_ID}    pdu_id=${pdu_id}    gw_id=${GW_ID}
    Check DRX Setup Message Flow    ue_id=${UE_ID}
    Verify DRX Setup Message Flow    ue_id=${UE_ID}

Expect DRX Setup Message Flow
    [Arguments]    ${ue_id}    ${gnb_id}    ${timer_length}
    Expect Message Flow
    ...    gNB${gnb_id}:F1AP_UEContextModificationRequest (DRXCycle is present) as ContextModReq
    ...    gNB${gnb_id}:F1AP_UEContextModificationResponse (drx-Config is present) as ContextModResp
    ...    alias=DRXSetup_UE${ue_id}
    ...    overall_timeout=${timer_length}

Check DRX Setup Message Flow
    [Arguments]    ${ue_id}
    Flow Occurred As Expected   alias=DRXSetup_UE${ue_id}

Verify DRX Setup Message Flow
    [Arguments]    ${ue_id}
    Verify That Message Fulfills Query
    ...    ${DRX_Configuration_for_5CC_FFTTT_UE_CA_in_UE_CON_MOD_REQ_B7}
    ...    message_alias=ContextModReq
    ...    flow_alias=DRXSetup_UE${ue_id}
    Verify That Message Fulfills Query
    ...    ${DRX_Configuration_for_5CC_FFTTT_UE_CA_in_UE_CON_MOD_RES_B7}
    ...    message_alias=ContextModResp
    ...    flow_alias=DRXSetup_UE${ue_id}

Verify 5CC FFTTT Blind SCell Addition Message Contents
    [Arguments]    ${ue_id}
    Verify That Message Fulfills Query
    ...  ${selected_SCells_for_5CC_FFTTT_UE_CA_in_UE_CON_MOD_REQ_B3}
    ...  message_alias=UEContextModificationRequest
    ...  flow_alias=SCellAddition_UE${ue_id}
    Verify That Message Fulfills Query
    ...  ${selected_SCells_for_5CC_FFTTT_UE_CA_in_UE_CON_MOD_RESP_B3}
    ...  message_alias=UEContextModificationResponse
    ...  flow_alias=SCellAddition_UE${ue_id}
    Verify That Message Fulfills Query
    ...  ${PUCCH_config_for_5CC_FFTTT_CA_BF_in_UE_CON_MOD_RESP_B3}
    ...  message_alias=UEContextModificationResponse
    ...  flow_alias=SCellAddition_UE${ue_id}
    Verify That Message Fulfills Query
    ...  ${CSI_meas_config_for_5CC_FFTTT_CA_BF_in_UE_CON_MOD_RESP_B3}
    ...  message_alias=UEContextModificationResponse
    ...  flow_alias=SCellAddition_UE${ue_id}

Trigger A2 Measurement For A1 A3 A5 Measurements Configuration
    [Arguments]    ${ue_id}    ${gNB_id}    ${overall_timeout}
    Expect DRX Release Message Flow    ue_id=${UE_ID}    gnb_id=${GNB_ID}    timer_length=${TIMER_LENGTH}
    Expect A1 A3 A5 Measurements Configuration messages flow    ue_id=${ue_id}    overall_timeout=${overall_timeout}
    Send A2 Measurement For A1 A3 A5 Measurements Configuration    ue_id=${ue_id}
    Check if A1 A3 A5 Measurements Configuration messages flow occured    ue_id=${ue_id}
    Check if DRX Release Message flow occured    ue_id=${ue_id}

Expect DRX Release Message Flow
    [Arguments]    ${ue_id}    ${gnb_id}    ${timer_length}
    Expect Message Flow
    ...    gNB${gnb_id}:F1AP_UEContextModificationResponse (drx-Config is present) as ContextModResp
    ...    alias=DRXRelease_UE${ue_id}
    ...    overall_timeout=${timer_length}

Expect A1 A3 A5 Measurements Configuration messages flow
    [Arguments]    ${ue_id}    ${overall_timeout}
    Expect message flow
    ...    UE${UE_ID}:NR-RRC_RRCReconfiguration (measConfig is present) as RRCReconfiguration
    ...    UE${UE_ID}:NR-RRC_RRCReconfigurationComplete as RRCReconfigurationComplete
    ...    alias=MeasConfiguration_UE${ue_id}
    ...    overall_timeout=${overall_timeout}

Send A2 Measurement For A1 A3 A5 Measurements Configuration
    [Arguments]    ${ue_id}
    Execute Egate Command And Wait For Data
    ...    cmd=ue_measurement_send_nr id=${ue_id} meas_id=1 event=A2 srsrp_nr=19 phycell_id=53
    ...    pass_regexp=rrcReconfigurationComplete
    ...    timeout=30

Check if A1 A3 A5 Measurements Configuration messages flow occured
    [Arguments]    ${ue_id}
    Flow occurred as expected  alias=MeasConfiguration_UE${ue_id}

Check if DRX Release Message flow occured
    [Arguments]    ${ue_id}
    Flow occurred as expected  alias=DRXRelease_UE${ue_id}

Verify 5CC FFTTT Measurement Configuration and Meas Gap Setup After A2
    [Arguments]    ${ue_id}
    Verify That Message Fulfills Query
    ...  ${measurements_config_for_FFTTT_5CC_CA_in_RRC_Reconfiguration_A2_removal_B7}
    ...  message_alias=RRCReconfiguration
    ...  flow_alias=MeasConfiguration_UE${ue_id}

Verify DRX Release After A2
    [Arguments]    ${ue_id}
    Verify That Message Fulfills Query
    ...  ${DRX_Release_After_A2_B7}
    ...  message_alias=RRCReconfiguration
    ...  flow_alias=MeasConfiguration_UE${ue_id}
    Verify That Message Fulfills Query
    ...  ${DRX_Release_for_5CC_FFTTT_UE_CA_in_UE_CON_MOD_RES_B7}
    ...  message_alias=ContextModResp
    ...  flow_alias=DRXRelease_UE${ue_id}

Verify Counter In File
    [Arguments]    ${counter_id}    ${counter_name}    ${local_moid}
    ${pm_counter_file}=    Get Next Unpacked Full Pm Counters File
    Verify Any Counters In File
    ...  ${counter_id}    >0    ${counter_name}
    ...  local_moid=${local_moid}
    ...  file_path=${pm_counter_file}

#CB009854-AA-B6c
Attach Ue And Verify Establishing PDU Session With A1 Measurement Verification
    [Arguments]    ${ue_id}    ${cell_id}    ${gnb_id}    ${pdu_id}    ${gw_id}
    Log To Console	UE attach, establishing PDU session and A1 measurement setup verification.
    Create UE Alias    alias=UE${ue_id}    ue_id=${ue_id}    id_type=wts_5g
    Expect UE Attach Messages Flow     ue_id=${ue_id}    gNB_id=${gnb_id}
    Expect PDU Messages Flow    ue_id=${ue_id}    gNB_id=${gnb_id}
    Expect A1 Measurement Configuration And DL UL RRCMessageTransfer Messages Flow    ue_id=${ue_id}    gNB_id=${gnb_id}
    Attach UE And Establish PDU Session    ue_id=${ue_id}    cell_id=${cell_id}    enb_id=${gnb_id}    pdu_id=${pdu_id}    gw_id=${gw_id}
    Check If UE Attach Messages Flow Occurred     ue_id=${ue_id}
    Check If PDU Messages Flow Occurred     ue_id=${ue_id}
    Check If A1 Measurement Configuration And DL UL RRCMessageTransfer Messages Flow Occurred    ue_id=${ue_id}
    Verify A1 Measurement Configuration For PCell    ue_id=${ue_id}

Expect A1 Measurement Configuration And DL UL RRCMessageTransfer Messages Flow
    [Arguments]     ${ue_id}    ${gNB_id}=2
    ${T3410}=    Set Variable    15  # 3GPP TS 24.301
    ${margin}=    Set Variable    2  # if anything the fail should be in Attach UE And Establish PDU Session keyword,
                                     # not in message capturing/veryfing part
    ${timeout}=    Evaluate     ${T3410}*2+${margin}  # There are two T3410 timers in keyword Attach UE And Establish PDU Session
    Expect Message Flow
    ...    gNB${gNB_id}:F1AP_DLRRCMessageTransfer as DLRRCMessageTransfer
    ...    gNB${gNB_id}:F1AP_ULRRCMessageTransfer as ULRRCMessageTransfer
    ...    UE${ue_id}:NR-RRC_RRCReconfiguration (measConfig is present) as RRCReconfiguration
    ...    UE${ue_id}:NR-RRC_RRCReconfigurationComplete as RRCReconfigurationComplete
    ...    gNB${gNB_id}:NGAP_InitialContextSetupResponse as InitialContextSetupResponse
    ...    alias=DL_UL_RRCMessageTransfer_with_A1_UE${ue_id}   overall_timeout=${timeout}

Check If A1 Measurement Configuration And DL UL RRCMessageTransfer Messages Flow Occurred
    [Arguments]     ${ue_id}
    Flow Occurred As Expected    alias=DL_UL_RRCMessageTransfer_with_A1_UE${ue_id}

Verify A1 Measurement Configuration For PCell
    [Arguments]    ${ue_id}
    Verify That Message Fulfills Query
    ...  ${A1_measurement_configuration_for_PCell_FDD_AAB6c}
    ...  message_alias=RRCReconfiguration
    ...  flow_alias=DL_UL_RRCMessageTransfer_with_A1_UE${ue_id}
    Verify That Message Fulfills Query
    ...  ${PDU_Session_ID_check_for_PCell_FDD_AA_B6c}
    ...  message_alias=RRCReconfiguration
    ...  flow_alias=DL_UL_RRCMessageTransfer_with_A1_UE${ue_id}

Trigger A1 Based CA
    [Arguments]    ${ue_id}    ${gnb_id}    ${meas_id}
    Log To Console	Triggering A1 measurement for SCell addition from UE${ue_id}
    Expect A1 Based SCell Addition Messages Flow - Secondary Measurement Quantity Not Sufficient     ue_id=${ue_id}    gNB_id=${gnb_id}
    Send A1 Measurement - Secondary Measurement Quantity Not Sufficient    UE_Id=${ue_id}    Meas_Id=${meas_id}
    Check A1 Based SCell Addition Messages Flow    ue_id=${ue_id}
    Verify A1 Measurement For PCell    ue_id=${ue_id}

Expect A1 Based SCell Addition Messages Flow - Secondary Measurement Quantity Not Sufficient
    [Arguments]     ${ue_id}    ${gNB_id}=2
    Expect Message Flow
    ...    gNB${gNB_id}:F1AP_ULRRCMessageTransfer as ULRRCMessageTransfer_measurement
    ...    UE${UE_ID}:NR-RRC_MeasurementReport as measurementReport_A1
    ...    alias=SCellAdditionCheckForMeasurementReport_UE${ue_id}   overall_timeout=60
    Expect Message Will Not Occur
    ...    gNB${gNB_id}:F1AP_UEContextModificationRequest (SCell-ToBeSetupMod-List is present) as UEContextModificationRequest
    ...    alias=SCellAdditionCheckForModificationRequest_UE${ue_id}   overall_timeout=60

Check A1 Based SCell Addition Messages Flow
    [Arguments]     ${ue_id}
    Flow Occurred As Expected    alias=SCellAdditionCheckForMeasurementReport_UE${ue_id}
    Flow Not Occurred For Message    alias=SCellAdditionCheckForModificationRequest_UE${ue_id}

Verify A1 Measurement For PCell
    [Arguments]    ${ue_id}
    Verify That Message Fulfills Query
    ...  ${A1_measurement_PCell_FDD_AAB6c}
    ...  message_alias=measurementReport_A1
    ...  flow_alias=SCellAdditionCheckForMeasurementReport_UE${ue_id}

Trigger A2 Measurement For Measurements Reconfiguration
    [Arguments]    ${ue_id}    ${overall_timeout}
    Expect A1 A3 A5 Measurements Configuration messages flow    ue_id=${ue_id}    overall_timeout=${overall_timeout}
    Send A2 Measurement For A1 A3 A5 Measurements Configuration    ue_id=${ue_id}
    Check if A1 A3 A5 Measurements Configuration messages flow occured    ue_id=${ue_id}

Trigger A3 Measurement For Intra-gNB Intra-DU Inter Frequency HO
    [Arguments]    ${ue_id}    ${gNB_id}    ${overall_timeout}    ${meas_id}
    Expect Meas Gap Release message flow    ue_id=${ue_id}    overall_timeout=${overall_timeout}
    Expect SCells Release and Handover Preparation messages flow    ue_id=${ue_id}    gNB_id=${gNB_id}    overall_timeout=${overall_timeout}
    Expect Intra-gNB Inter-band Handover Performance messages flow    ue_id=${ue_id}    gNB_id=${gNB_id}    overall_timeout=${overall_timeout}
    Expect SCell Addition After HO messages flow     ue_id=${ue_id}    gNB_id=${gNB_id}    overall_timeout=${overall_timeout}
    Send A3 Measurement For Intra-gNB Intra-DU Inter Frequency HO    ue_id=${ue_id}    meas_id=${meas_id}
    Check if Meas Gap Release message flow occured    ${ue_id}
    Check if SCells Release and Handover Preparation messages flow occured    ue_id=${ue_id}
    Check if Intra-gNB Inter-band Handover Performance messages flow occured    ue_id=${ue_id}
    Check If SCell Addition After HO messages flow occured    ue_id=${ue_id}

Expect Meas Gap Release message flow
    [Arguments]    ${ue_id}    ${overall_timeout}
    Expect message flow
    ...    UE${UE_ID}:NR-RRC_RRCReconfiguration (measConfig is present) as measGapConfig
    ...    alias=MeasGap${ue_id}
    ...    overall_timeout=${overall_timeout}

Expect SCells Release and Handover Preparation messages flow
    [Arguments]    ${ue_id}    ${gNB_id}    ${overall_timeout}
    Expect message flow
    ...    gNB${gNB_id}:F1AP_UEContextModificationRequest (SCell-ToBeRemoved-List is present) as UEConModReq
    ...    UE${UE_ID}:NR-RRC_RRCReconfiguration (measConfig is present) as RRCReconfiguration
    ...    alias=HandoverPrep${ue_id}
    ...    overall_timeout=${overall_timeout}

Expect Intra-gNB Inter-band Handover Performance messages flow
    [Arguments]    ${ue_id}    ${gNB_id}    ${overall_timeout}
    Expect message flow
    ...    gNB${gNB_id}:F1AP_UEContextModificationResponse (DUtoCURRCInformation is present) as UEContextModificationResponse
    ...    UE${UE_ID}:NR-RRC_RRCReconfiguration (sCellToReleaseList is present) as RRCReconfiguration
    ...    UE${ue_id}:NR-RRC_RRCReconfigurationComplete as RRCReconfigurationComplete
    ...    alias=Handover_Performed${ue_id}
    ...    overall_timeout=${overall_timeout}

Expect SCell Addition After HO messages flow
    [Arguments]     ${ue_id}    ${gNB_id}    ${overall_timeout}
    Expect Message Flow
    ...    gNB${gNB_id}:F1AP_UEContextModificationRequest (SCell-ToBeSetupMod-List is present) as UEContextModificationRequest
    ...    gNB${gNB_id}:F1AP_UEContextModificationResponse (sCellToAddModList is present) as UEContextModificationResponse
    ...    alias=SCellAddition_AfterHO_UE${ue_id}
    ...    overall_timeout=${overall_timeout}

Send A3 Measurement For Intra-gNB Intra-DU Inter Frequency HO
    [Arguments]    ${ue_id}    ${meas_id}
    Execute Egate Command And Wait For Data
    ...    cmd=ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A3 phycell_id=51 nrsrp_nr=100
    ...    pass_regexp=rrcReconfigurationComplete
    ...    timeout=30

Check if Meas Gap Release message flow occured
    [Arguments]    ${ue_id}
    Flow occurred as expected  alias=MeasGap${ue_id}

Check if SCells Release and Handover Preparation messages flow occured
    [Arguments]    ${ue_id}
    Flow occurred as expected  alias=HandoverPrep${ue_id}

Check if Intra-gNB Inter-band Handover Performance messages flow occured
    [Arguments]    ${ue_id}
    Flow occurred as expected  alias=Handover_Performed${ue_id}

Check If SCell Addition After HO messages flow occured
    [Arguments]     ${ue_id}
    Flow Occurred As Expected    alias=SCellAddition_AfterHO_UE${ue_id}

Verify Meas Gap Release
    [Arguments]    ${ue_id}
    Verify That Message Fulfills Query
    ...  ${MEAS_GAP_Release_for_5CC_FFTTT_UE_CA_in_RRC_Reconfiguration_B1}
    ...  message_alias=measGapConfig
    ...  flow_alias=MeasGap${ue_id}

Verify SCells Release and Handover Preparation
    [Arguments]    ${ue_id}
    Verify That Message Fulfills Query
    ...  ${Meas_Config_for_5CC_FFTTT_UE_CA_in_RRC_Reconfiguration_B1}
    ...  message_alias=RRCReconfiguration
    ...  flow_alias=HandoverPrep${ue_id}
    Verify That Message Fulfills Query
    ...  ${SCells_To_Remove_for_5CC_FFTTT_UE_CA_in_UE_CONF_MOD_REQ_B1}
    ...  message_alias=UEConModReq
    ...  flow_alias=HandoverPrep${ue_id}
    Verify That Message Fulfills Query
    ...  ${HO_Preparation_From_Cell_3_for_5CC_FFTTT_UE_CA_in_UE_CONF_MOD_REQ_B1}
    ...  message_alias=UEConModReq
    ...  flow_alias=HandoverPrep${ue_id}

Verify Handover Performance
    [Arguments]    ${ue_id}
    Verify That Message Fulfills Query
    ...  ${HO_Performance_To_Cell_1_for_5CC_FFTTT_UE_CA_in_UE_CON_MOD_RES_B1}
    ...  message_alias=UEContextModificationResponse
    ...  flow_alias=Handover_Performed${ue_id}
    Verify That Message Fulfills Query
    ...  ${SCells_To_Release_for_5CC_FFTTT_UE_CA_in_RRC_Reconfiguration_B1}
    ...  message_alias=RRCReconfiguration
    ...  flow_alias=Handover_Performed${ue_id}

Verify 5CC FFTTT Blind SCell Addition Message Contents After HO
    [Arguments]    ${ue_id}
    Verify That Message Fulfills Query
    ...  ${selected_SCells_for_5CC_FFTTT_UE_CA_in_UE_CON_MOD_REQ_B1}
    ...  message_alias=UEContextModificationRequest
    ...  flow_alias=SCellAddition_AfterHO_UE${ue_id}
    Verify That Message Fulfills Query
    ...  ${selected_SCells_for_5CC_FFTTT_UE_CA_in_UE_CON_MOD_RESP_B1}
    ...  message_alias=UEContextModificationResponse
    ...  flow_alias=SCellAddition_AfterHO_UE${ue_id}


#CB009854-AB-B9
Start Vm Ethernet Interfaces
    Start Vm Ethernet Interface    if_name=eth3:EPCsim    ip_with_mask=10.0.1.10/24
    Start Vm Ethernet Interface    if_name=eth3:simeNB    ip_with_mask=10.0.1.11/24
    Start Vm Ethernet Interface    if_name=eth3:CRMsim    ip_with_mask=10.0.1.200/24


Setup Additional Configuration
    Execute Egate Command    cmd=script file=/home/ute/test_repository/testsuite/Wroclaw/RRM/WRO_2/CB009854/config/Set_DSS_param.cfg
    ...   fail_regexp=DSS_SETUP_FAILURE Not matching cell Ids - NR DSS Setup Req not received yet   timeout=120


Set Internal Traffic Type To UEs
    [Arguments]    ${ue_id}    ${pdu_id}=1
    Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal



Attach UE And Start Data Traffic
    [Arguments]    ${ue_id}    ${cell_id}    ${pdu_id}=1    ${gw_id}=3
    Set Internal Traffic Type To UEs    ue_id=${ue_id}
    Attach Ue    ue_id=${ue_id}    cell=${cell_id}
    Establish Pdu Session    ue_id=${ue_id}    pdu_id=${pdu_id}    gw_id=${gw_id}    nwslice=1


Start Data Traffic And Verify Traffic Scheduling On All SCell
    [Arguments]    ${ue_id}=3     ${pdu}=1   ${scell}=0-4    ${Inactive Timer}=10s
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu} trf_id=1 dir=dl mbps=100
    BuiltIn.Sleep    ${Inactive Timer}
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu} trf_id=2 dir=dl mbps=100
    BuiltIn.Sleep    ${Inactive Timer}
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu} trf_id=3 dir=dl mbps=100
    BuiltIn.Sleep    ${Inactive Timer}
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu} trf_id=4 dir=dl mbps=100
    BuiltIn.Sleep    ${Inactive Timer}
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu} trf_id=5 dir=ul mbps=100
    BuiltIn.Sleep    ${Inactive Timer}
    Execute Egate Command    cmd=ue_stats_nr id=${ue_id} scell=${scell}
    BuiltIn.Sleep    ${Inactive Timer}
    BuiltIn.Sleep    60s    Wait for DSS Traffic to stabilize


Activate And Check If Xp Link is active
    BuiltIn.Sleep    5s
    Execute Egate Command    cmd=enb_xp_param id=2 xp_peers=1
    BuiltIn.Sleep    1s
    ute_wtssim.execute egate command and wait for data    cmd=enb_xp_link_up enb=2 target=1
    ...                                                   cmd=enb_disp id=2 enb=1 type=xp_info    timeout=600
    ...                                                   pass_regexp=XpAP Link .* is up   timeout=600
    # sometimes the link falls, and come back again after 4-5 seconds, so we add a BuiltIn.Sleep here
    BuiltIn.Sleep    10s
    Log to console  \n***Activate eNBSim with XpAp interface completed ***


Verify DL DSS Traffic Is Scheduled On All Cells 5CC
    [Arguments]    ${ue_id}=3
    Verify That Traffic Is Scheduled On All SCells    ue_id=${ue_id}    num_of_scells=4
    Verify That Throughput Is Reached On All SCells    ue_id=${ue_id}    num_of_scells=4    expected_throughput=0.5Mbps


Verify UL DSS Traffic Is Scheduled On PCell
    [Arguments]    ${ue_id}=3
    Verify That Throughput Is Reached On Cell Group    ue_id=${ue_id}
    ...   expected_throughput=1Mbps    cell_index_min=0
    ...   cell_index_max=0    direction=ul

Verify Pm Counters For SCell Additions With Large BWP
    [Arguments]    ${local_moid}
    Wait For Next Full Pm Interval
    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    Verify Any Counters In File
    ...    M55139C04002    1    GNB_DU_SCELL_ADM_L_BWP_SUCC
    ...    local_moid=${local_moid}
    ...    file_path=${pm_counter_file}
