*** Settings ***

Documentation    Keywords for CB005934.

*** Keywords ***

Deactivate 4CC CA
    Find Scfc And Send Delta Commissioning Retrying After Errors    scfc_filename=${DELTA_4CC_DEACTIVATION}

Activate 4CC CA
    Find Scfc And Send Delta Commissioning Retrying After Errors    scfc_filename=${DELTA_4CC_ACTIVATION}

Reboot Testline
    Run Keyword If    ${REBOOT} == ${True}    Trigger Site Reset
    Wait For Testline ICMP Echo Replies And SSH Services
    Set Suite Variable    $REBOOT    ${True}

Verify 4CC FFFF Blind SCell Addition Message Contents
    [Arguments]    ${ue_id}
    Verify That Message Fulfills Query
    ...  ${selected_SCells_for_4CC_FFFF_UE_CA_in_UE_CON_MOD_REQ}
    ...  message_alias=UEContextModificationRequest
    ...  flow_alias=SCellAddition_UE${ue_id}
    Verify That Message Fulfills Query
    ...  ${selected_SCells_for_4CC_FFFF_UE_CA_in_UE_CON_MOD_RESP}
    ...  message_alias=UEContextModificationResponse
    ...  flow_alias=SCellAddition_UE${ue_id}
    Verify That Message Fulfills Query
    ...  ${PUCCH_config_for_4CC_FFFF_CA_in_UE_CON_MOD_RESP_B3}
    ...  message_alias=UEContextModificationResponse
    ...  flow_alias=SCellAddition_UE${ue_id}
    Verify That Message Fulfills Query
    ...  ${CSI_meas_config_for_4CC_FFFF_CA_in_UE_CON_MOD_RESP_B3}
    ...  message_alias=UEContextModificationResponse
    ...  flow_alias=SCellAddition_UE${ue_id}

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

Verify Traffic Is Scheduled On All Cells 4CC DL And UL On PCell
    [Arguments]    ${ue_id}=1
    Verify DL Traffic Is Scheduled On All Cells 4CC    ue_id=${ue_id}
    BuiltIn.Sleep    10s   #Need to catch traffic
    Verify UL Traffic Is Scheduled On PCell    ue_id=${ue_id}

Verify DL Traffic Is Scheduled On All Cells 4CC
    [Arguments]    ${ue_id}=1
    Verify That Traffic Is Scheduled On All SCells    ue_id=${ue_id}    num_of_scells=3
    Verify That Throughput Is Reached On All SCells    ue_id=${ue_id}    num_of_scells=3    expected_throughput=10Mbps

Verify UL Traffic Is Scheduled On PCell
    [Arguments]    ${ue_id}=1
    Verify That Throughput Is Reached On Cell Group    ue_id=${ue_id}    expected_throughput=10Mbps    cell_index_min=0
    ...   cell_index_max=0    direction=ul

Attach UE And Verify Establishing PDU Session Without Blind SCell Addition
    [Arguments]    ${ue_id}   ${cell_id}   ${gnb_id}    ${pdu_id}    ${gw_id}
    Expect UE Attach Messages Flow     ue_id=${ue_id}    gNB_id=${gnb_id}
    Expect PDU Messages Flow     ue_id=${ue_id}    gNB_id=${gnb_id}
    Expect SCell UE Without Addition Messages Flow    ue_id=${ue_id}
    Attach UE And Establish PDU Session    ue_id=${ue_id}    cell_id=${cell_id}    enb_id=${gnb_id}    pdu_id=${pdu_id}    gw_id=${gw_id}
    Check If UE Attach Messages Flow Occurred     ue_id=${ue_id}
    Check If PDU Messages Flow Occurred     ue_id=${ue_id}
    Check If SCell Addition Messages Flow Is Not Occured    ue_id=${ue_id}

Check If SCell Addition Messages Flow Is Not Occured
    [Arguments]    ${ue_id}
    Flow Occurred As Expected    alias=SCellAddition1_UE${ue_id}

Expect SCell UE Without Addition Messages Flow
    [Arguments]    ${ue_id}    ${gNB_id}=2
    Expect Message Flow
    ...    gNB${gNB_id}:F1AP_UEContextModificationRequest (SCell-ToBeSetupMod-List is not present) as UEContextModificationRequest
    ...    gNB${gNB_id}:F1AP_UEContextModificationResponse (sCellToAddModList is not present) as UEContextModificationResponse
    ...    gNB${gNB_id}:F1AP_UEContextModificationRequest (GNB-DUConfigurationQuery is present) as UEContextModificationRequest_2nd
    ...    gNB${gNB_id}:F1AP_UEContextModificationResponse (sCellToAddModList is not present) as UEContextModificationResponse_2nd
    ...    alias=SCellAddition1_UE${ue_id}   overall_timeout=60

Release UE
    [Arguments]    ${ue_id}    ${pdu_id}
    Release PDU session    ue_id=${ue_id}    pdu_id=${pdu_id}
    Deregister UE    ue_id=${ue_id}

Trigger A1 Measurement
    [Arguments]    ${ue_id}    ${meas_id}    ${srsrp_nr}=90    ${timeout}=60
    Execute Egate Command And Wait For Data
    ...    cmd=ue_meas_cfg_disp id\=${ue_id}
    Execute Egate Command And Wait For Data
    ...    cmd=ue_measurement_send_nr id\=${ue_id} meas_id\=${meas_id} event\=A1 srsrp_nr\=${srsrp_nr}
    ...    pass_regexp=message c1 : rrcReconfigurationComplete
    ...    timeout=${timeout}

Trigger A2 Measurement
    [Arguments]    ${ue_id}    ${meas_id}    ${scell_id}    ${scell_rsrp}    ${srsrp_nr}=90    ${timeout}=60
    Execute Egate Command And Wait For Data
    ...    cmd=ue_meas_cfg_disp id\=${ue_id}
    Execute Egate Command And Wait For Data
    ...    cmd=ue_measurement_send_nr id\=${ue_id} meas_id\=${meas_id} event\=A2 srsrp_nr\=${srsrp_nr} scell\=${scell_id} scell_rsrp\=${scell_rsrp}
    ...    pass_regexp=message c1 : rrcReconfigurationComplete
    ...    timeout=${timeout}

Verify A1 Measurement Removal And A2 Measurement Activation After A1 Event Trigger
    [Arguments]    ${ue_id}    ${a2_event_params}    ${a2_frequencies}    ${a1_event_params}    ${a1_frequencies}
    Verify A2 Measurements Are Configured At UE   ue_id=${ue_id}    a2_event_params=${a2_event_params}
    ...    a2_frequencies=${a2_frequencies}
    Verify A1 Measurement Is Not Configured At UE    ue_id=${ue_id}    a1_event_params=${a1_event_params}
    ...    a1_frequencies=${a1_frequencies}

Verify A2 Measurements Are Configured At UE
    [Arguments]    ${ue_id}    ${a2_event_params}    ${a2_frequencies}
    Verify Measurements Are Configured At UE    ue_id=${ue_id}   event_type=EventA2
    ...    event_params=${a2_event_params}    frequencies=${a2_frequencies}

Verify A1 Measurement Is Not Configured At UE
    [Arguments]    ${ue_id}    ${a1_event_params}    ${a1_frequencies}
    Verify Measurements Are Not Configured At UE    ue_id=${ue_id}   event_type=EventA1
    ...    event_params=${a1_event_params}    frequencies=${a1_frequencies}

Trigger A2 Measurement And Expect Measurements Configuration And SCell Release Messages Flow
    [Arguments]    ${gnb_id}    ${ue_id}    ${meas_id}    ${scell_id}    ${scell_rsrp}    ${overall_timeout}=60
    Expect A2 Measurement Report And A2 Measurement Removal And SCell Release Messages Flow    gnb_id=${gnb_id}
    ...    ue_id=${ue_id}    a2_meas_id=${meas_id}    overall_timeout=${overall_timeout}
    Trigger A2 Measurement    ue_id=${ue_id}     meas_id=${meas_id}    scell_id=${scell_id}
    ...    scell_rsrp=${scell_rsrp}

Expect A2 Measurement Report And A2 Measurement Removal And SCell Release Messages Flow
    [Arguments]    ${gnb_id}    ${ue_id}    ${a2_meas_id}    ${overall_timeout}
    Expect Message Flow
    ...    UE${ue_id}:NR-RRC_MeasurementReport (measId eq ${a2_meas_id}) as A2measurementReport
    ...    gNB${gnb_id}:F1AP_UEContextModificationRequest (SCell-ToBeRemoved-List is present) as UEContModRequest
    ...    gNB${gnb_id}:F1AP_UEContextModificationResponse (sCellToReleaseList is present) as UEContModResponse
    ...    UE${ue_id}:NR-RRC_RRCReconfiguration (measObjectToRemoveList is present) as RRCReconfiguration
    ...    gNB${gnb_id}:F1AP_UEContextModificationRequest (RRCReconfigurationCompleteIndicator is present) as UECMRInd
    ...    gNB${gnb_id}:F1AP_UEContextModificationRequest (GNB-DUConfigurationQuery is present) as UECMRQuery
    ...    alias=SCellRelease_UE${ue_id}
    ...    overall_timeout=${overall_timeout}

Verify SCell Release Based On A2 Measurement Messages Content After A2 Event Trigger
    [Arguments]    ${ue_id}
    Verify That Message Fulfills Query
    ...  ${A2_measurementReport_in_UL_DCCH_Message_for_SCell}
    ...  message_alias=A2measurementReport
    ...  flow_alias=SCellRelease_UE${ue_id}
    Verify That Message Fulfills Query
    ...  ${SCells_to_remove_in_UE_CON_MOD_REQ}
    ...  message_alias=UEContModRequest
    ...  flow_alias=SCellRelease_UE${ue_id}
    Verify That Message Fulfills Query
    ...  ${PUCCH_config_for_3CC_FFF_CA_in_UE_CON_MOD_RESP}
    ...  message_alias=UEContModResponse
    ...  flow_alias=SCellRelease_UE${ue_id}
    Verify That Message Fulfills Query
    ...  ${SCells_to_remove_in_UE_CON_MOD_RESP}
    ...  message_alias=UEContModResponse
    ...  flow_alias=SCellRelease_UE${ue_id}
    Verify That Message Fulfills Query
    ...  ${meas_config_for_A2_removal_in_RRC_Reconfiguration}
    ...  message_alias=RRCReconfiguration
    ...  flow_alias=SCellRelease_UE${ue_id}
    Verify That Message Fulfills Query
    ...  ${rrc_reconfiguration_complete_indicator_in_UE_CON_MOD_REQ}
    ...  message_alias=UECMRInd
    ...  flow_alias=SCellRelease_UE${ue_id}
    Verify That Message Fulfills Query
    ...  ${gnb_configuration_query_in_UE_CON_MOD_REQ}
    ...  message_alias=UECMRQuery
    ...  flow_alias=SCellRelease_UE${ue_id}

Verify Pm Counters After SCell Release
    [Arguments]    ${local_moid}
    Wait For Next Full Pm Interval
    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    Verify Any Counters In File
        ...    M55118C06501    +1      A2MEAS_REL1DLSCELL_ATT_SA
        ...    M55118C06502    +1      A2MEAS_REL1DLSCELL_SUCC_SA
        ...    M55124C03001    +3      NRRCC_RRC_RECONF_SENT
        ...    M55124C03002    +3      NRRCC_RRC_RECONF_CMP_RECD
        ...    M55118C07001    >0      UE_PCELL_2_CONF_SCELL_DL_SA
        ...    M55118C09501    >\=0    UE_PCELL_3_CONF_SCELL_DL_SA
        ...    local_moid=${local_moid}
        ...    file_path=${pm_counter_file}

Verify A1 Measurement Configuration
    [Arguments]    ${ue_id}
    Verify That Message Fulfills Query
    ...  ${A1_measurements_configuration_in_RRCReconfiguration_B8}
    ...  message_alias=RRCReconfiguration
    ...  flow_alias=Established_PDU_UE${ue_id}

Trigger A1 Based SCell Addition
    [Arguments]    ${ue_id}    ${gnb_id}
    Expect SCell Addition Messages Flow    ${ue_id}    ${gnb_id}
    Execute Egate Command And Wait For Data
    ...    cmd=ue_measurement_send_nr id=${UE_ID} meas_id=1 event=A1 srsrp_nr=90
    Check If SCell Addition Messages Flow Occured    ${ue_id}

Verify 4CC FFFF SCell Addition For SCell Swap Message Contents
    [Arguments]    ${ue_id}
    Verify That Message Fulfills Query
    ...  ${selected_SCells_for_4CC_FFFF_UE_CA_in_UE_CON_MOD_REQ_B8}
    ...  message_alias=UEContextModificationRequest
    ...  flow_alias=SCellAddition_UE${ue_id}
    Verify That Message Fulfills Query
    ...  ${selected_SCells_for_4CC_FFFF_UE_CA_in_UE_CON_MOD_RESP_B8}
    ...  message_alias=UEContextModificationResponse
    ...  flow_alias=SCellAddition_UE${ue_id}
    Verify That Message Fulfills Query
    ...  ${PUCCH_config_for_4CC_FFFF_CA_in_UE_CON_MOD_RESP_B3}
    ...  message_alias=UEContextModificationResponse
    ...  flow_alias=SCellAddition_UE${ue_id}
    Verify That Message Fulfills Query
    ...  ${CSI_meas_config_for_4CC_FFFF_CA_in_UE_CON_MOD_RESP_B3}
    ...  message_alias=UEContextModificationResponse
    ...  flow_alias=SCellAddition_UE${ue_id}
    Verify That Message Fulfills Query
    ...  ${meas_config_in_RRCReconfiguration_B8}
    ...  message_alias=RRCReconfiguration
    ...  flow_alias=SCellAddition_UE${ue_id}

Trigger A6 For SCell Swap
    [Arguments]    ${ue_id}    ${gnb_id}
    Expect SCell Addition Messages Flow    ${ue_id}    ${gnb_id}
    Execute Egate Command And Wait For Data
    ...    cmd=ue_measurement_send_nr id=${UE_ID} meas_id=2 event=A6 srsrp_nr=70 scell=1 scell_rsrp=20 phycell_id=53 nrsrp_nr=95
    Check If SCell Addition Messages Flow Occured    ${ue_id}

Verify Successful SCell Swap Message Contents
    [Arguments]    ${ue_id}
    Verify That Message Fulfills Query
    ...  ${selected_SCells_for_4CC_FFFF_UE_CA_in_UE_CON_MOD_REQ_B8_swap}
    ...  message_alias=UEContextModificationRequest
    ...  flow_alias=SCellAddition_UE${ue_id}
    Verify That Message Fulfills Query
    ...  ${selected_SCells_for_4CC_FFFF_UE_CA_in_UE_CON_MOD_RESP_B8_swap}
    ...  message_alias=UEContextModificationResponse
    ...  flow_alias=SCellAddition_UE${ue_id}
    Verify That Message Fulfills Query
    ...  ${PUCCH_config_for_4CC_FFFF_CA_in_UE_CON_MOD_RESP_B8_swap}
    ...  message_alias=UEContextModificationResponse
    ...  flow_alias=SCellAddition_UE${ue_id}
    Verify That Message Fulfills Query
    ...  ${CSI_meas_config_for_4CC_FFFF_CA_in_UE_CON_MOD_RESP_B8_swap}
    ...  message_alias=UEContextModificationResponse
    ...  flow_alias=SCellAddition_UE${ue_id}
    Verify That Message Fulfills Query
    ...  ${meas_config_in_RRCReconfiguration_B8_swap}
    ...  message_alias=RRCReconfiguration
    ...  flow_alias=SCellAddition_UE${ue_id}

Verify SCell Swap Counters
    [Arguments]    ${pcell}
    ${pm_counter_file}=    Get Next Unpacked Full Pm Counters File
    Verify Any Counters In File
    ...    M55118C10501    1    SCELL_SWAP_1_ATT_SA
    ...    M55118C10502    1    SCELL_SWAP_1_SUCC_SA
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${pcell}
    ...    file_path=${pm_counter_file}

#A-B10
Verify Message After A1 Measurement Triggered
    [Arguments]    ${packet_filter}    ${number_of_messages}=1    ${relation_symbol}= ==
    Verify Tcpdump Log    packet_filter=${packet_filter}    number_of_messages=${number_of_messages}    relation_symbol=${relation_symbol}

Verify Pm Counters After SCell Change
    [Arguments]    ${local_moid}
    Wait For Next Full Pm Interval
    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    Verify Any Counters In File
        ...    M55118C06506    +1      SCELL_CHANGE_ATT_SA
        ...    M55118C06507    +1      SCELL_CHANGE_SUCC_SA
        ...    M55124C03001    +3      NRRCC_RRC_RECONF_SENT
        ...    M55124C03002    +3      NRRCC_RRC_RECONF_CMP_RECD
        ...    M55118C05507    >0      UE_PCELL_1_CONF_SCELL_DL_SA
        ...    M55118C09501    >\=0    UE_PCELL_3_CONF_SCELL_DL_SA
        ...    local_moid=${local_moid}
        ...    file_path=${pm_counter_file}

#A-B5
Register UE To gNB
    [Arguments]    ${ue_id}
    Execute Egate Command    cmd=ue_register id=${ue_id}
    Wait For UE Register    3s
    Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=3 trf_type=internal
    Execute Egate Command    cmd=ue_pdu_session_setup ue=${ue_id} pdu=3 nwslice=1 gw=3
    Wait For UE Register    5s

Wait For UE Register
    [Arguments]    ${inactive_timer}
    BuiltIn.Sleep    ${inactive_timer}

Verify 3FDD SCells Addition After A1 Event Trigger
    [Arguments]    ${UeContextModReqAfterA1}
    Verify Tcpdump Log    ${UeContextModReqAfterA1}

Verify RRC A1 Measurement Removal And SCell Addition
    [Arguments]    ${RRCReconfigurationAfterA1}
    Verify Tcpdump Log    ${RRCReconfigurationAfterA1}

Verify Pm Counters For 5CC Configuration
    [Arguments]    ${local_moid}
    Wait For Next Full Pm Interval
    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    Verify Any Counters In File
        ...    M55138C00048    +1      GNB_SCELL_4_ADMI_REQ_SA
        ...    M55138C00049    +1      GNB_SCELL_4_ADMI_SUCC_SA
        ...    M55139C03001    +1      GNB_DU_SCELL_3_ADMI_REQ_SA
        ...    M55139C03002    +1      GNB_DU_SCELL_3_ADMI_SUCC_SA
        ...    M55118C09503    +1      RRC_RECONF_ADD3DLSCELL_ATT_SA
        ...    M55118C09502    +1      RRC_RECONF_ADD3DLSCELL_SUCC_SA
        ...    M55118C09501    >0      UE_PCELL_3_CONF_SCELL_DL_SA
        ...    local_moid=${local_moid}
        ...    file_path=${pm_counter_file}

#A-B7
Verify 4CC FFFF SCell Addition For PCell Change Message Contents
    [Arguments]    ${ue_id}
    Verify That Message Fulfills Query
    ...  ${selected_SCells_for_4CC_FFFF_UE_CA_in_UE_CON_MOD_REQ}
    ...  message_alias=UEContextModificationRequest
    ...  flow_alias=SCellAddition_UE${ue_id}
    Verify That Message Fulfills Query
    ...  ${PUCCH_config_for_4CC_FFFF_CA_in_UE_CON_MOD_RESP_B3}
    ...  message_alias=UEContextModificationResponse
    ...  flow_alias=SCellAddition_UE${ue_id}
    Verify That Message Fulfills Query
    ...  ${CSI_meas_config_for_4CC_FFFF_CA_in_UE_CON_MOD_RESP_B3}
    ...  message_alias=UEContextModificationResponse
    ...  flow_alias=SCellAddition_UE${ue_id}
    Verify That Message Fulfills Query
    ...  ${selected_SCells_for_4CC_FFFF_UE_CA_in_UE_CON_MOD_RESP}
    ...  message_alias=UEContextModificationResponse
    ...  flow_alias=SCellAddition_UE${ue_id}
    Verify That Message Fulfills Query
    ...  ${meas_config_in_RRCReconfiguration_B7}
    ...  message_alias=RRCReconfiguration
    ...  flow_alias=SCellAddition_UE${ue_id}

Trigger A2 Based PCell Change
    [Arguments]    ${ue_id}    ${gnb_id}    ${A2_cmd}
    Expect PCell Change Messages Flow    ${ue_id}    ${gnb_id}
    Execute Egate Command And Wait For Data
    ...    cmd=ue_meas_cfg_disp id=${ue_id}
    Execute Egate Command And Wait For Data
    ...    cmd=ue_measurement_send_nr ${A2_cmd}
    Check if PCell Change messages flow occured    ${ue_id}

Expect PCell Change messages flow
    [Arguments]    ${ue_id}    ${gNB_id}=2    ${overall_timeout}=60
    Expect message flow
    ...    UE${ue_id}:NR-RRC_MeasurementReport (measId eq ${A2_MEAS_ID}) as A2measurementReport
    ...    gNB${gNB_id}:F1AP_UEContextModificationRequest (SCell-ToBeRemoved-List is present) as UEContextModificationRequest
    ...    gNB${gNB_id}:F1AP_UEContextModificationResponse (sCellToReleaseList is present) as UEContextModificationResponse
    ...    UE${UE_ID}:NR-RRC_RRCReconfiguration (sCellToReleaseList is present) as RRCReconfiguration
    ...    UE${UE_ID}:NR-RRC_RRCReconfigurationComplete as RRCReconfigurationComplete
    ...    gNB${gNB_id}:F1AP_UEContextModificationRequest as UEContextModificationRequest_2nd
    ...    gNB${gNB_id}:F1AP_UEContextModificationResponse as UEContextModificationResponse_2nd
    ...    alias=PCellChange_UE${ue_id}
    ...    overall_timeout=${overall_timeout}

Check if PCell Change messages flow occured
    [Arguments]     ${ue_id}
    Flow occurred as expected  alias=PCellChange_UE${ue_id}

Verify Successful PCell Change And SCells Release
    [Arguments]    ${ue_id}
	Verify That Message Fulfills Query
    ...  ${A2_measurementReport_in_UL_DCCH_Message_for_PCell_Change}
    ...  message_alias=A2measurementReport
    ...  flow_alias=PCellChange_UE${ue_id}
    Verify That Message Fulfills Query
    ...  ${HO_PREP_in_UE_CON_MOD_REQ_B7}
    ...  message_alias=UEContextModificationRequest
    ...  flow_alias=PCellChange_UE${ue_id}
	Verify That Message Fulfills Query
    ...  ${SCell_ToBeRemoved_List_in_UE_CON_MOD_REQ_B7}
    ...  message_alias=UEContextModificationRequest
    ...  flow_alias=PCellChange_UE${ue_id}
    Verify That Message Fulfills Query
    ...  ${spCellConfig_in_UE_CON_MOD_RESP_B7}
    ...  message_alias=UEContextModificationResponse
    ...  flow_alias=PCellChange_UE${ue_id}
    Verify That Message Fulfills Query
    ...  ${meas_config_in_RRC_Reconf_FFFF_B7}
    ...  message_alias=RRCReconfiguration
    ...  flow_alias=PCellChange_UE${ue_id}
    Verify That Message Fulfills Query
    ...  ${nonCriticalExtension_in_RRC_Reconf_FFFF_B7}
    ...  message_alias=RRCReconfiguration
    ...  flow_alias=PCellChange_UE${ue_id}

Trigger A1 Measurement To Verify CA Successful
    [Arguments]    ${ue_id}    ${gnb_id}
    Expect SCell Addition Messages Flow    ${ue_id}    ${gnb_id}
    Execute Egate Command And Wait For Data
    ...    cmd=ue_measurement_send_nr id=${UE_ID} meas_id=3 event=A1 srsrp_nr=90
    Check If SCell Addition Messages Flow Occured    ${ue_id}

Verify Successful CA After A2
    [Arguments]    ${ue_id}
    Verify That Message Fulfills Query
    ...  ${selected_SCells_for_4CC_FFFF_CA_in_UE_CON_MOD_REQ_B7}
    ...  message_alias=UEContextModificationRequest
    ...  flow_alias=SCellAddition_UE${ue_id}
	Verify That Message Fulfills Query
    ...  ${PUCCH_config_for_4CC_FFFF_CA_in_UE_CON_MOD_RESP_B3}
    ...  message_alias=UEContextModificationResponse
    ...  flow_alias=SCellAddition_UE${ue_id}
    Verify That Message Fulfills Query
    ...  ${CSI_meas_config_for_4CC_FFFF_CA_in_UE_CON_MOD_RESP_B3}
    ...  message_alias=UEContextModificationResponse
    ...  flow_alias=SCellAddition_UE${ue_id}
    Verify That Message Fulfills Query
    ...  ${selected_SCells_for_4CC_FFFF_CA_in_UE_CON_MOD_RESP_B7}
    ...  message_alias=UEContextModificationResponse
    ...  flow_alias=SCellAddition_UE${ue_id}
	Verify That Message Fulfills Query
    ...  ${meas_config_in_RRCReconfiguration_After_A2_B7}
    ...  message_alias=RRCReconfiguration
    ...  flow_alias=SCellAddition_UE${ue_id}

Verify PCell Change Counters for PCell_1 and PCell_2
    [Arguments]    ${pcell}    ${pcell_2}
    ${pm_counter_file}=    Get Next Unpacked Full Pm Counters File
    Verify Any Counters In File
    ...    M55138C03001    1    GNB_SCELL_3_ADMI_REQ_SA
    ...    M55138C03002    1    GNB_SCELL_3_ADMI_SUCC_SA
    ...    M55139C03001    1    GNB_DU_SCELL_3_ADMI_REQ_SA
    ...    M55139C03002    1    GNB_DU_SCELL_3_ADMI_SUCC_SA
    ...    M55118C09503    1    RRC_RECONF_ADD3DLSCELL_ATT_SA
    ...    M55118C09502    1    RRC_RECONF_ADD3DLSCELL_SUCC_SA
    ...    M55118C09501    >0    UE_PCELL_3_CONF_SCELL_DL_SA
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${pcell}
    ...    file_path=${pm_counter_file}
    Verify Any Counters In File
    ...    M55138C03001    1    GNB_SCELL_3_ADMI_REQ_SA
    ...    M55138C03002    1    GNB_SCELL_3_ADMI_SUCC_SA
    ...    M55139C03001    1    GNB_DU_SCELL_3_ADMI_REQ_SA
    ...    M55139C03002    1    GNB_DU_SCELL_3_ADMI_SUCC_SA
    ...    M55118C09503    1    RRC_RECONF_ADD3DLSCELL_ATT_SA
    ...    M55118C09502    1    RRC_RECONF_ADD3DLSCELL_SUCC_SA
    ...    M55118C09501    >0    UE_PCELL_3_CONF_SCELL_DL_SA
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${pcell_2}
    ...    file_path=${pm_counter_file}

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

Verify Traffic on PCell and All SCells For Multiple UEs
    [Arguments]    ${ue_ids}
    ${ues_number}=    Get Length    ${ue_ids}
    FOR    ${ue_index}    IN RANGE    ${ues_number}
        Verify Traffic Is Scheduled On All Cells 4CC DL And UL On PCell    ue_id=${ue_ids}[${ue_index}]
    END

Release Multiple UEs
    [Arguments]    ${ue_ids}   ${pdu_ids}
    ${ues_number}=    Get Length    ${ue_ids}
    FOR    ${ue_index}    IN RANGE    ${ues_number}
        Release UE    ue_id=${ue_ids}[${ue_index}]   pdu_id=${pdu_ids}[${ue_index}]
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

Verify Pm Counters For 3CC To 4CC Change
    [Arguments]    ${local_moid}
    Wait For Next Full Pm Interval
    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    Verify Any Counters In File
    ...    M55118C06506    3    SCELL_CHANGE_ATT_SA
    ...    M55118C06507    3    SCELL_CHANGE_SUCC_SA
    ...    M55124C03001    9    NRRCC_RRC_RECONF_SENT
    ...    M55124C03002    9    NRRCC_RRC_RECONF_CMP_RECD
    ...    M55118C09501    >0    UE_PCELL_3_CONF_SCELL_DL_SA
    ...    M55118C07001    >\=0    UE_PCELL_2_CONF_SCELL_DL_SA
    ...    local_moid=${local_moid}
    ...    file_path=${pm_counter_file}

