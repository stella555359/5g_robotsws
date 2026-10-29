*** Settings ***
Documentation    :copyright: Nokia
...              :authors: I_L3_WRO_PSI_ET_GMS
...              :contact: I_L3_WRO_PSI_ET@nokia.com

*** Keywords ***
Activate Feature CB011081
    [Arguments]    ${scfc_filename}=delta_CB011081_enabled.json
    Find Scfc And Send Delta Commissioning Retrying After Errors    scfc_filename=${scfc_filename}

Deactivate Feature CB011081
    [Arguments]    ${scfc_filename}=delta_CB011081_disabled.json
    Find Scfc And Send Delta Commissioning Retrying After Errors    scfc_filename=${scfc_filename}

Expect SCell ToBeSetupMod And ToAddModList
    [Arguments]    ${ue_id}    ${gnb_id}
    Expect Message Flow
    ...    gNB${gnb_id}:F1AP_UEContextModificationRequest (SCell-ToBeSetupMod-List is present) as UEContModRequest
    ...    gNB${gnb_id}:F1AP_UEContextModificationResponse (sCellToAddModList is present) as UEContModResponse
    ...    alias=SCellAddition_UE${ue_id}   overall_timeout=60

Attach UE And Expect Establishing PDU Session
    [Arguments]    ${ue_id}    ${cell_id}    ${gnb_id}    ${pdu_id}    ${gw_id}

    Expect PDU Messages Flow     ue_id=${ue_id}    gNB_id=${gnb_id}

    Attach UE And Establish PDU Session    ue_id=${ue_id}    cell_id=${cell_id}    enb_id=${gnb_id}    pdu_id=${pdu_id}    gw_id=${gw_id}
    Check If PDU Messages Flow Occurred     ue_id=${ue_id}

Start Specific Data DL Traffic
    [Arguments]    ${ue_id}    ${pdu_id}    ${qfi}=1    ${mbps_per_trf_id}=100    ${first_trf_id}=1    ${last_trf_id}=8
    FOR    ${INDEX}  IN RANGE    ${first_trf_id}   ${last_trf_id}+1
        Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi} trf_id=${INDEX} dir=dl mbps=${mbps_per_trf_id}
    END

Start Specific Data DL Traffic In Kbps
    [Arguments]    ${ue_id}    ${pdu_id}    ${qfi}=1    ${kbps_per_trf_id}=100    ${first_trf_id}=1    ${last_trf_id}=3
    FOR    ${INDEX}  IN RANGE    ${first_trf_id}   ${last_trf_id}+1
        Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi} trf_id=${INDEX} dir=dl kbps=${kbps_per_trf_id}
    END

Verify DL Traffic Is Scheduled On All Cells
    [Arguments]    ${ue_id}    ${num_of_scells}=5    ${expected_throughput}=10Mbps
    Verify That Traffic Is Scheduled On All SCells    ue_id=${ue_id}    num_of_scells=${num_of_scells}
    Verify That Throughput Is Reached On All SCells    ue_id=${ue_id}    num_of_scells=${num_of_scells}    expected_throughput=${expected_throughput}

Verify Pm Counters
    [Arguments]    ${counter_id_list}    ${counter_name_list}    ${local_moid}    ${pm_counter_file}    ${condition}=1
    ${counters_amount}=    Get length    ${counter_id_list}
    FOR    ${index}    IN RANGE    0    ${counters_amount}
        Verify Any Counters In File
        ...  ${counter_id_list}[${index}]    ${condition}    ${counter_name_list}[${index}]
        ...  local_moid=${local_moid}
        ...  file_path=${pm_counter_file}
    END

Verify Pm Counters With Varius Value
    [Arguments]    ${counter_id_list}    ${counter_name_list}    ${local_moid}    ${pm_counter_file}    ${condition}=1
    ${counters_amount}=    Get length    ${counter_id_list}
    FOR    ${index}    IN RANGE    0    ${counters_amount}
        Verify Any Counters In File
        ...  ${counter_id_list}[${index}]    ${condition}[${index}]    ${counter_name_list}[${index}]
        ...  local_moid=${local_moid}
        ...  file_path=${pm_counter_file}
    END

Verify Pm Counter On SCells
    [Arguments]    ${counter_id}    ${counter_name}    ${local_moids}    ${pm_counter_file}    ${condition}=>1
    ${local_moids_amount}=    Get length    ${local_moids}
    FOR    ${index}    IN RANGE    0    ${local_moids_amount}
        Verify Any Counters In File
        ...  ${counter_id}    ${condition}[${index}]    ${counter_name}
        ...  local_moid=${local_moids}[${index}]
        ...  file_path=${pm_counter_file}
    END

Verify Pm Counters AB1 AB3
    ${pm_counter_file}=    Get Next Unpacked Full Pm Counters File
    Verify Pm Counters    counter_id_list=${COUNTER_IDs_PCELL_P1}    counter_name_list=${COUNTER_NAMEs_PCELL_P1}
    ...    local_moid=${LOCAL_MOID_PCELL}    pm_counter_file=${pm_counter_file}
    Verify Pm Counters    counter_id_list=${COUNTER_IDs_PCELL_P2}    counter_name_list=${COUNTER_NAMEs_PCELL_P2}
    ...    local_moid=${LOCAL_MOID_PCELL}    pm_counter_file=${pm_counter_file}    condition=>1
    Verify Pm Counters    counter_id_list=${COUNTER_ID_SCELL_6}    counter_name_list=${COUNTER_NAME_SCELL_6}
    ...    local_moid=${LOCAL_MOID_SCELL_6}    pm_counter_file=${pm_counter_file}    condition=>1

    FOR    ${CURRENT_MOID}    IN    @{ALL_SCELL_MOID}
        Verify Pm Counters    counter_id_list=${COUNTER_ID_SCELLs}    counter_name_list=${COUNTER_NAME_SCELLs}
    ...    local_moid=${CURRENT_MOID}    pm_counter_file=${pm_counter_file}    condition=>1
    END


Verify SCell Addition Messages For CC
    [Arguments]    ${ue_id}    ${cc_nr_cell_identitiy}    ${cc_scell_physcell_id}    ${num_of_reportConfigId}
    FOR    ${nr_cell_identity}    IN    @{cc_nr_cell_identitiy}
        Verify That Message Has Fields
    ...  SCell-ToBeSetupMod-List..nRCellIdentity eq ${nr_cell_identity}
    ...  message_alias=UEContModRequest
    ...  flow_alias=SCellAddition_UE${ue_id}
    END

    Verify That Message Has Fields
    ...  length(csi-ReportConfigToAddModList) eq ${num_of_reportConfigId}
    ...  message_alias=UEContModResponse
    ...  flow_alias=SCellAddition_UE${ue_id}

    FOR    ${scell_physcell_id}    IN    @{cc_scell_physcell_id}
        Verify That Message Has Fields
    ...  sCellToAddModList..physCellId eq ${scell_physcell_id}
    ...  message_alias=UEContModResponse
    ...  flow_alias=SCellAddition_UE${ue_id}
    END

Verify SCell Addition Messages For 5CC
    [Arguments]    ${ue_id}    ${5cc_nr_cell_identitiy}    ${5cc_scell_physcell_id}
    FOR    ${NR_CELL_IDENTITY}    IN    @{5cc_nr_cell_identitiy}
        Verify That Message Has Fields
    ...                              SCell-ToBeSetupMod-List..nRCellIdentity eq ${NR_CELL_IDENTITY}
    ...  message_alias=UEContModRequest
    ...  flow_alias=SCellAddition_UE${ue_id}
    END

    Verify That Message Has Fields
    ...                              length(csi-ReportConfigToAddModList) eq 7
    ...  message_alias=UEContModResponse
    ...  flow_alias=SCellAddition_UE${ue_id}

    FOR    ${SCELL_PHYSCELL_ID}    IN    @{5cc_scell_physcell_id}
        Verify That Message Has Fields
    ...                              sCellToAddModList..physCellId eq ${SCELL_PHYSCELL_ID}
    ...  message_alias=UEContModResponse
    ...  flow_alias=SCellAddition_UE${ue_id}
    END

Verify SCell Addition Messages For 6CC
    [Arguments]    ${ue_id}    ${6cc_nr_cell_identitiy}    ${6cc_scell_physcell_id}
    FOR    ${NR_CELL_IDENTITY}    IN    @{6cc_nr_cell_identitiy}
        Verify That Message Has Fields
    ...                              SCell-ToBeSetupMod-List..nRCellIdentity eq ${NR_CELL_IDENTITY}
    ...  message_alias=UEContModRequest
    ...  flow_alias=SCellAddition_UE${ue_id}
    END

    Verify That Message Has Fields
    ...                              length(csi-ReportConfigToAddModList) eq 8
    ...  message_alias=UEContModResponse
    ...  flow_alias=SCellAddition_UE${ue_id}

    FOR    ${SCELL_PHYSCELL_ID}    IN    @{6cc_scell_physcell_id}
        Verify That Message Has Fields
    ...                              sCellToAddModList..physCellId eq ${SCELL_PHYSCELL_ID}
    ...  message_alias=UEContModResponse
    ...  flow_alias=SCellAddition_UE${ue_id}
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

#AB4
Verify A1 Measurement Configuration At UE
    [Arguments]    ${ue_id}    ${filters}
    Verify That Message Fulfills Query
    ...  ${filters}
    ...  message_alias=RRCReconfiguration
    ...  flow_alias=Established_PDU_NR_RRC_UE${ue_id}

Expect A1 Measurement Report And SCell Addition Messages Flow
    [Arguments]    ${gnb_id}    ${ue_id}    ${meas_id}    ${overall_timeout}=60
    Expect Message Flow
    ...    UE${ue_id}:NR-RRC_MeasurementReport (measId eq ${meas_id}) as A1measurementReport
    ...    gNB${gnb_id}:F1AP_UEContextModificationRequest (SCell-ToBeSetupMod-List is present) as UEContModRequest
    ...    gNB${gnb_id}:F1AP_UEContextModificationResponse (sCellToAddModList is present) as UEContModResponse
    ...    UE${ue_id}:NR-RRC_RRCReconfiguration (measIdToRemoveList is present) as RRCReconfiguration
    ...    gNB${gnb_id}:F1AP_UEContextModificationRequest (RRCReconfigurationCompleteIndicator is present) as UECMRInd
    ...    gNB${gnb_id}:F1AP_UEContextModificationRequest (GNB-DUConfigurationQuery is present) as UECMRQuery
    ...    alias=SCellAddition_UE${ue_id}
    ...    overall_timeout=${overall_timeout}

Check If A1 Measurement Report And SCell Addition Messages Flow Occured
    [Arguments]     ${ue_id}
    Flow Occurred As Expected    alias=SCellAddition_UE${ue_id}

Trigger A1 Measurement
    [Arguments]    ${ue_id}    ${meas_id}    ${srsrp_nr}    ${srsrq_nr}    ${timeout}=60
    Execute Egate Command And Wait For Data
    ...    cmd=ue_meas_cfg_disp id\=${ue_id}
    Execute Egate Command And Wait For Data
    ...    cmd=ue_measurement_send_nr id\=${ue_id} meas_id\=${meas_id} event\=A1 srsrp_nr\=${srsrp_nr} srsrq_nr\=${srsrq_nr}
    ...    pass_regexp=message c1 : rrcReconfigurationComplete
    ...    timeout=${timeout}

Trigger A1 Measurement And Expect SCell Addition Messages Flow For UE
    [Arguments]    ${ue_id}    ${gnb_id}    ${meas_id}    ${srsrp_nr}    ${srsrq_nr}
    Expect A1 Measurement Report And SCell Addition Messages Flow    ue_id=${ue_id}    gnb_id=${gnb_id}    meas_id=${meas_id}
    Trigger A1 Measurement    ue_id=${ue_id}   meas_id=${meas_id}    srsrp_nr=${srsrp_nr}    srsrq_nr=${srsrq_nr}
    Check If A1 Measurement Report And SCell Addition Messages Flow Occured    ue_id=${ue_id}

Verify SCell Addition Messages Content After A1 Event Trigger For UE
    [Arguments]    ${ue_id}
    Verify That Message Fulfills Query
    ...  ${A1_measurement_for_SCell_Addition}
    ...  message_alias=A1measurementReport
    ...  flow_alias=SCellAddition_UE${ue_id}
    Verify That Message Fulfills Query
    ...  ${selected_SCells_for_6CC_4F2T_UE_CA_in_UE_CON_MOD_REQ}
    ...  message_alias=UEContModRequest
    ...  flow_alias=SCellAddition_UE${ue_id}
    Verify That Message Fulfills Query
    ...  ${selected_SCells_for_6CC_4F2T_UE_CA_in_UE_CON_MOD_RESP}
    ...  message_alias=UEContModResponse
    ...  flow_alias=SCellAddition_UE${ue_id}
    Verify That Message Fulfills Query
    ...  ${PUCCH_config_for_6CC_4F2T_CA_in_UE_CON_MOD_RESP}
    ...  message_alias=UEContModResponse
    ...  flow_alias=SCellAddition_UE${ue_id}
    Verify That Message Fulfills Query
    ...  ${csi_MeasConfig_for_6CC_4F2T_CA_in_UE_CON_MOD_RESP}
    ...  message_alias=UEContModResponse
    ...  flow_alias=SCellAddition_UE${ue_id}

Verify Traffic Is Scheduled On All Cells 6CC DL And 2CC UL
    [Arguments]    ${ue_id}    ${inactive_timer}=10    ${expected_throughput_ul}=10Mbps    ${expected_throughput_dl}=10Mbps
    ...    ${cell_index_max}=5
    Wait for Traffic to Stabilize    ${inactive_timer}
    Verify DL Traffic Is Scheduled On All Cells    ue_id=${ue_id}    expected_throughput=${expected_throughput_dl}
    Verify UL Traffic Is Scheduled On PCell and SCell    ue_id=${ue_id}    expected_throughput=${expected_throughput_ul}
    ...    cell_index_max=${cell_index_max}

Verify UL Traffic Is Scheduled On PCell and SCell
    [Arguments]    ${ue_id}=1    ${expected_throughput}=10Mbps    ${cell_index_max}=5
    Verify That Throughput Is Reached On Cell Group    ue_id=${ue_id}    expected_throughput=${expected_throughput}    cell_index_min=0
    ...   cell_index_max=0    direction=ul
    Verify That Throughput Is Reached On Cell Group    ue_id=${ue_id}    expected_throughput=${expected_throughput}
    ...   cell_index_max=${cell_index_max}    direction=ul    cell_index_min=${cell_index_max}

Start Specific Data UL Traffic
    [Arguments]    ${ue_id}    ${pdu_id}    ${mbps_per_trf_id}=100    ${first_trf_id}=1    ${last_trf_id}=8
    FOR    ${INDEX}  IN RANGE    ${first_trf_id}   ${last_trf_id}
        Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} trf_id=${INDEX} dir=ul mbps=${mbps_per_trf_id}
    END

#C_IWK7
Register UE To gNB without PDU session setup
    [Arguments]    ${ue_id}
    Execute Egate Command    cmd=amf_param id=1 empty_pdu_session_list=on send_ics_registration=on
    Expect Message Flow
    ...     UE${ue_id}:NR-RRC_RRCSetupComplete as RRCSetupComplete
    ...  alias=RRCSetupComplete_UE${ue_id}   overall_timeout=5
    Execute Egate Command    cmd=ue_register id=${ue_id}
    Flow Occurred As Expected    alias=RRCSetupComplete_UE${ue_id}

Configure additional DRB
    [Arguments]    ${drb}
    Execute Egate Command     cmd=smf_param id=1 additional_qosflows_to_activate=${drb}

Setup PDU session
    [Arguments]    ${ue_id}    ${pdu}    ${gw}=3
    Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=${pdu} trf_type=internal
    Execute Egate Command    cmd=ue_pdu_session_setup ue=${ue_id} pdu=${pdu} nwslice=1 gw=${gw}

Expect Messages PDUSessionResourceSetup
    [Arguments]    ${ue_id}    ${amf_id}=1
    Expect Message Flow
    ...     AMF${amf_id}:NGAP_PDUSessionResourceSetupRequest as PDUSessionResourceSetupRequest
    ...     AMF${amf_id}:NGAP_PDUSessionResourceSetupResponse as PDUSessionResourceSetupResponse
    ...  alias=PDUSessionResourceSetup_UE${ue_id}   overall_timeout=60

Verify Messages PDUSessionResourceSetupRequest
    [Arguments]    ${ue_id}    ${pdu_id}    ${QosFlowSetupRequestList}    ${fiveQIs}
    Verify That Message Has Fields
    ...     pDUSessionID eq ${pdu_id}
    ...     length(QosFlowSetupRequestList) eq ${QosFlowSetupRequestList}
    ...  message_alias=PDUSessionResourceSetupRequest
    ...  flow_alias=PDUSessionResourceSetup_UE${ue_id}

    FOR    ${FIVE_QI}    IN    @{fiveQIs}
        Verify That Message Has Fields
    ...     nonDynamic5QI..fiveQI eq ${FIVE_QI}
    ...  message_alias=PDUSessionResourceSetupRequest
    ...  flow_alias=PDUSessionResourceSetup_UE${ue_id}
    END

Verify Messages PDUSessionResourceSetupResponse
    [Arguments]    ${ue_id}    ${pdu_id}    ${qosFlowIdentifiers}
    Verify That Message Has Fields
    ...    pDUSessionID eq ${pdu_id}
    ...    length(associatedQosFlowList) eq ${qosFlowIdentifiers}
    ...  message_alias=PDUSessionResourceSetupResponse
    ...  flow_alias=PDUSessionResourceSetup_UE${ue_id}

    FOR    ${qosFlowIdentifier}    IN RANGE    1    ${qosFlowIdentifiers}
        Verify That Message Has Fields
    ...    associatedQosFlowList..qosFlowIdentifier eq ${qosFlowIdentifier}
    ...  message_alias=PDUSessionResourceSetupResponse
    ...  flow_alias=PDUSessionResourceSetup_UE${ue_id}
    END

Register UE With Additional DBR
    [Arguments]    ${ue_id}    ${pdu_id}    ${drb}    ${QosFlowSetupRequestList}    ${fiveQIs}
    Expect Messages PDUSessionResourceSetup  ue_id=${ue_id}
    Register UE To gNB without PDU session setup   ue_id=${ue_id}
    Configure additional DRB    drb=${drb}
    Setup PDU session   ue_id=${ue_id}    pdu=${pdu_id}
    Verify Messages PDUSessionResourceSetupRequest    ue_id=${ue_id}    pdu_id=${pdu_id}
    ...    QosFlowSetupRequestList=${QosFlowSetupRequestList}    fiveQIs=@{fiveQIs}
    Verify Messages PDUSessionResourceSetupResponse    ue_id=${ue_id}    pdu_id=${pdu_id}    qosFlowIdentifiers=${QosFlowSetupRequestList}

Register UE Without Additional DBR
    [Arguments]    ${ue_id}    ${pdu_id}    ${QosFlowSetupRequestList}    ${fiveQIs}
    Expect Messages PDUSessionResourceSetup  ue_id=${ue_id}
    Register UE To gNB without PDU session setup   ue_id=${ue_id}
    Setup PDU session   ue_id=${ue_id}    pdu=${pdu_id}
    Verify Messages PDUSessionResourceSetupRequest    ue_id=${ue_id}    pdu_id=${pdu_id}
    ...    QosFlowSetupRequestList=${QosFlowSetupRequestList}    fiveQIs=@{fiveQIs}
    Verify Messages PDUSessionResourceSetupResponse    ue_id=${ue_id}    pdu_id=${pdu_id}    qosFlowIdentifiers=${QosFlowSetupRequestList}

Expect Messages PDUSessionResourceModify
    [Arguments]    ${ue_id}    ${amf_id}=1
    Expect Message Flow
    ...     AMF${amf_id}:NGAP_PDUSessionResourceModifyRequest as PDUSessionResourceModifyRequest
    ...     AMF${amf_id}:NGAP_PDUSessionResourceModifyResponse as PDUSessionResourceModifyResponse
    ...  alias=PDUSessionResourceModify_UE${ue_id}   overall_timeout=60

Modify PDU Session By Adding QoS Flow
    [Arguments]    ${ue_id}    ${pdu_id}    ${qosflows_to_add}
    Execute Egate Command And Wait For Data    cmd=ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id} qosflows_to_add=${qosflows_to_add} by=amf

Verify Messages PDUSessionResourceModifyRequest ADD
    [Arguments]    ${ue_id}    ${fiveQI}    ${PDUSessionResourceModifyListModReq}=1

    Verify That Message Has Fields
    ...     length(PDUSessionResourceModifyListModReq) eq ${PDUSessionResourceModifyListModReq}
    ...     fiveQI eq ${fiveQI}
    ...  message_alias=PDUSessionResourceModifyRequest
    ...  flow_alias=PDUSessionResourceModify_UE${ue_id}

Verify Messages PDUSessionResourceModifyResponse ADD
    [Arguments]    ${ue_id}    ${pdu_id}   ${qosFlowIdentifier}     ${PDUSessionResourceModifyListModRes}=1

    Verify That Message Has Fields
    ...     length(PDUSessionResourceModifyListModRes) eq ${PDUSessionResourceModifyListModRes}
    ...     pDUSessionID eq ${pdu_id}
    ...     qosFlowAddOrModifyResponseList..qosFlowIdentifier eq ${qosFlowIdentifier}
    ...  message_alias=PDUSessionResourceModifyResponse
    ...  flow_alias=PDUSessionResourceModify_UE${ue_id}

Modify PDU Session By Deleting QoS Flow
    [Arguments]    ${ue_id}    ${pdu_id}    ${qosflows_to_del}
    Execute Egate Command And Wait For Data    cmd=ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id} qosflows_to_del=${qosflows_to_del} by=amf

Verify Messages PDUSessionResourceModifyRequest DEL
    [Arguments]    ${ue_id}    ${pdu_id}    ${qosFlowIdentifier}    ${PDUSessionResourceModifyListModReq}=1

    Verify That Message Has Fields
    ...     length(PDUSessionResourceModifyListModReq) eq ${PDUSessionResourceModifyListModReq}
    ...     pDUSessionID eq ${pdu_id}
    ...     QosFlowListWithCause..qosFlowIdentifier eq ${qosFlowIdentifier}
    ...  message_alias=PDUSessionResourceModifyRequest
    ...  flow_alias=PDUSessionResourceModify_UE${ue_id}

Verify Messages PDUSessionResourceModifyResponse DEL
    [Arguments]    ${ue_id}    ${pdu_id}     ${PDUSessionResourceModifyListModRes}=1

    Verify That Message Has Fields
    ...     length(PDUSessionResourceModifyListModRes) eq ${PDUSessionResourceModifyListModRes}
    ...     pDUSessionID eq ${pdu_id}
    ...  message_alias=PDUSessionResourceModifyResponse
    ...  flow_alias=PDUSessionResourceModify_UE${ue_id}

Setup Dedicated Wireshark For UU Interface
    [Arguments]    ${capture_filter}=less 1400
    ${UU_ALIAS}=    Start Tshark For Uu Interface    capture_filter=${capture_filter}
    Set Suite Variable    ${UU_ALIAS}

Create Alias For UEs
    [Arguments]    ${ue_id_start}    ${ue_id_stop}
    FOR    ${ue_id}    IN RANGE    ${ue_id_start}    ${ue_id_stop}+1
        Create UE Alias    alias=UE${ue_id}    ue_id=${ue_id}    id_type=wts_5g
    END

Verify Established 5QI-5 bearer for IMS Signalling
    [Arguments]    ${PDUModifyRequest}
    Verify Ngap Messages     packet_filter=${PDUModifyRequest}


Verify Established 5QI-1 bearer for voice data
    [Arguments]    ${PDUModifyRequest}
    Verify Ngap Messages    packet_filter=${PDUModifyRequest}


Send Pdu Session Modify And Start VoNR
    [Arguments]    ${ue_id}      ${pdu_id}
    Execute Egate Command    cmd=ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id} qosflows_to_add=2 by=amf
    Wait For PDU Session Modify Complete   2s
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=2 dir=dl mbps=1 trf_id=1 protocol=tcp
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=2 dir=ul mbps=1 trf_id=2 protocol=tcp
    Wait for Traffic to Stabilize    inactive_timer=2
    Execute Egate Command    cmd=ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id} qosflows_to_add=3 by=amf
    Wait For PDU Session Modify Complete    2s
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=3 dir=dl rtp_codec=amr_12_2 trf_id=3
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=3 dir=ul rtp_codec=amr_12_2 trf_id=4
    Wait for Traffic to Stabilize    inactive_timer=5

Veryfify DRX Profile
    [Arguments]    ${drx_profile}    ${number_of_messages}
    Verify Tcpdump Log     packet_filter=${drx_profile}    number_of_messages=${number_of_messages}

Wait For PDU Session Modify Complete
    [Arguments]    ${inactive_timer}
    sleep   ${inactive_timer}

Trigger A1 Measurement A6
    [Arguments]    ${ue_id}    ${meas_id}    ${Inactive Timer}=5s
    Execute Egate Command    cmd=ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=90 srsrq_nr=95
    sleep    ${Inactive Timer}

Trigger A6 Measurement
    [Arguments]    ${A6_cmd}
    Execute Egate Command    cmd=ue_measurement_send_nr ${A6_cmd}

Verify A6 Measurement
    [Arguments]    ${Verify_A6_Measurement}
    Verify Tcpdump Log    ${Verify_A6_Measurement}

Verify Scell Swap
    [Arguments]    ${Verify_Scell_Swap}
    Verify Tcpdump Log    ${Verify_Scell_Swap}

Verify Pm Counters AB13
    ${pm_counter_file}=    Get Next Unpacked Full Pm Counters File
    Verify Pm Counters    counter_id_list=${COUNTER_IDs_PCELL_P1}    counter_name_list=${COUNTER_NAMEs_PCELL_P1}
    ...    local_moid=${LOCAL_MOID_PCELL}    pm_counter_file=${pm_counter_file}

Trigger A2 Measurement
    [Arguments]    ${ue_id}    ${meas_id}    ${SCELL_INDEX}
    Execute Egate Command
    ...  cmd=ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 srsrp_nr=90 srsrq_nr=95 scell=${SCELL_INDEX} scell_rsrp=5

Set RRC Resume Parameters
    [Arguments]    ${ue_id}    ${cell_id}    ${gnb_id}    ${cmd}
    Execute Egate Command    cmd=${cmd}
    Wait RRC Resume Param    3s
    Execute Egate Command
    ...    cmd=ue_nr_rrc_resume_request_param id=${ue_id} gnb=${gnb_id} cell=${cell_id} msg=resume_request_1 cause=mo_Signalling
    Wait RRC Resume Param    3s

Wait For UE Inactive State
    [Arguments]    ${inactive_timer}
    sleep    ${inactive_timer}

Wait RRC Resume Param
    [Arguments]    ${inactive_timer}
    sleep    ${inactive_timer}

Verify Inactive UE State
    [Arguments]
    ...    ${rrc_resume_element}    ${rrc_resume_complete_element}
    Verify Tcpdump Log    packet_filter=${rrc_resume_element}
    Verify Tcpdump Log    packet_filter=${rrc_resume_complete_element}

Verify Scell Release
    [Arguments]    ${A2_meas_element}    ${cell_release_after_A2}
    Verify Tcpdump Log    packet_filter=${A2_meas_element}
    Verify Tcpdump Log    packet_filter= ${cell_release_after_A2}    number_of_messages=2

Perform CB011081_AB18 UE Resume
    [Arguments]    ${UE_ID_6CC}    ${SOURCE_CELL_ID}    ${GNB_ID}    ${cmd_ue_resume_configuration}
    ...    ${PDU_ID}    ${GW_ID}    ${A1_MEAS_ID}
    Set RRC Resume Parameters    ue_id=${UE_ID_6CC}  cell_id=${SOURCE_CELL_ID}   gnb_id=${GNB_ID}    cmd=${cmd_ue_resume_configuration}
    Attach UE And Establish PDU Session    ue_id=${UE_ID_6CC}  cell_id=${SOURCE_CELL_ID}   enb_id=${GNB_ID}
    ...    pdu_id=${PDU_ID}    gw_id=${GW_ID}
    Wait For UE Inactive State    inactive_timer=128s
    Start Specific Data DL Traffic    ue_id=${UE_ID_6CC}   pdu_id=${PDU_ID}    first_trf_id=1    last_trf_id=2
    Start Specific Data UL Traffic    ue_id=${UE_ID_6CC}   pdu_id=${PDU_ID}    first_trf_id=3    last_trf_id=4
    Wait for Traffic to Stabilize    15
    Trigger A1 Measurement A6    ue_id=${UE_ID_6CC}    meas_id=${A1_MEAS_ID}

Verify BWPs for UE
    [Arguments]    ${ue_id}    ${UE_carrierBandwidth_values}    ${UE_locationAndBandwidth_values}

    FOR    ${physcellid}     ${carrierBandwidth}    ${locationAndBandwidth}    IN ZIP    ${UE_carrierBandwidth_values.keys()}
    ...    ${UE_carrierBandwidth_values.values()}    ${UE_locationAndBandwidth_values.values()}
        Verify That Message Has Fields
    ...  sCellToAddModList..physCellId eq ${physcellid}
    ...  sCellToAddModList..carrierBandwidth eq ${carrierBandwidth}
    ...  sCellConfigDedicated..locationAndBandwidth eq ${locationAndBandwidth}
    ...  message_alias=UEContModResponse
    ...  flow_alias=SCellAddition_UE${ue_id}
    END

Verify 6CC FFFTTT Measurement Configuration and Meas Gap Setup After A2
    [Arguments]    ${ue_id}
    Verify That Message Fulfills Query
    ...  ${measurements_config_for_FFFTTT_6CC_CA_in_RRC_Reconfiguration_A2_removal_AB16}
    ...  message_alias=RRCReconfiguration
    ...  flow_alias=MeasConfiguration_UE${ue_id}

Verify 6CC SCells Release and Handover Preparation
    [Arguments]    ${ue_id}
    Verify That Message Fulfills Query
    ...  ${Meas_Config_for_6CC_FFFTTT_UE_CA_in_RRC_Reconfiguration_AB16}
    ...  message_alias=RRCReconfiguration
    ...  flow_alias=HandoverPrep${ue_id}
    Verify That Message Fulfills Query
    ...  ${SCells_To_Remove_for_6CC_FFFTTT_UE_CA_in_UE_CONF_MOD_REQ_AB16}
    ...  message_alias=UEConModReq
    ...  flow_alias=HandoverPrep${ue_id}
    Verify That Message Fulfills Query
    ...  ${HO_Preparation_From_Cell_3_for_6CC_FFFTTT_UE_CA_in_UE_CONF_MOD_REQ_AB16}
    ...  message_alias=UEConModReq
    ...  flow_alias=HandoverPrep${ue_id}

Verify Handover Performance From Cell3 to Cell1
    [Arguments]    ${ue_id}
    Verify That Message Fulfills Query
    ...  ${HO_Performance_To_Cell_1_for_6CC_FFFTTT_UE_CA_in_UE_CON_MOD_RES_AB16}
    ...  message_alias=UEContextModificationResponse
    ...  flow_alias=Handover_Performed${ue_id}
    Verify That Message Fulfills Query
    ...  ${SCells_To_Release_for_6CC_FFFTTT_UE_CA_in_RRC_Reconfiguration_AB16}
    ...  message_alias=RRCReconfiguration
    ...  flow_alias=Handover_Performed${ue_id}

Verify SCell Addition Messages For CC After HO
    [Arguments]    ${ue_id}    ${nr_cell_identity}    ${scell_physcell_id}
    FOR    ${NR_CELL_ID}    IN    @{nr_cell_identity}
        Verify That Message Has Fields
    ...    SCell-ToBeSetupMod-List..nRCellIdentity eq ${NR_CELL_ID}
    ...    message_alias=UEContextModificationRequest
    ...    flow_alias=SCellAddition_AfterHO_UE${ue_id}
    END

    Verify That Message Has Fields
    ...    length(csi-ReportConfigToAddModList) eq 7
    ...    message_alias=UEContextModificationResponse
    ...    flow_alias=SCellAddition_AfterHO_UE${ue_id}

    FOR    ${SCELL_ID}    IN    @{scell_physcell_id}
        Verify That Message Has Fields
    ...    sCellToAddModList..physCellId eq ${SCELL_ID}
    ...    message_alias=UEContextModificationResponse
    ...    flow_alias=SCellAddition_AfterHO_UE${ue_id}
    END

Set ${rrc_comp:\d+} expected RRC Reconfiguration Request and Complete messages for UE${ue_id:\d+}
    EXPECT FLOW[timeout=90]: UE${ue_id} NR-RRC ${rrc_comp}*RRCReconfiguration
    EXPECT FLOW[timeout=90]: UE${ue_id} NR-RRC ${rrc_comp}*RRCReconfigurationComplete

Verify that ${rrc_comp:\d+} RRC Reconfiguration Request and Complete messages occured for UE${ue_id:\d+}
    PASS FLOW[timeout=90]: UE${ue_id} NR-RRC ${rrc_comp}*RRCReconfiguration
    PASS FLOW[timeout=90]: UE${ue_id} NR-RRC ${rrc_comp}*RRCReconfigurationComplete

Verify A1 Measurement Configuration for PCell
    [Arguments]    ${ue_id}    ${filters}
    Verify That Message Fulfills Query
    ...  ${filters}
    ...  message_alias=RRCReconfiguration
    ...  flow_alias=Established_PDU_NR_RRC_UE${ue_id}

Set expected Measurement Report messages for UE${ue_id:\d+}
    EXPECT FLOW[timeout=15]: UE${ue_id} NR-RRC MeasurementReport

Verify that Measurement Report messages occured for UE${ue_id:\d+}
    PASS FLOW[timeout=15]: UE${ue_id} NR-RRC MeasurementReport

Trigger and Verify A1 Based SCell Addition
    [Arguments]    ${ue_id}    ${gNB_id}    ${meas_id_a1}    ${srsrp_a1}    ${srsrq_a1}    ${filters}
    Set expected Measurement Report messages for UE3
    Set Message Flow Expectations for A1 Based SCell Addition   gnb_id=${gnb_id}
    Send Ue Measurement Nr    ue_id=${ue_id}    meas_id=${meas_id_a1}    event=A1    srsrp_nr=${srsrp_a1}    srsrq_nr=${srsrq_a1}
    Verify UE${ue_id} message MeasurementReport number 1 of 1 fulfils ${filters} content
    Verify UE3 6CC 3F3T SCell Addition Message Contents

    Verify if UE3 RRCReconfiguration contains A1 measurements configuration before PCell Change

Set Message Flow Expectations for A1 Based SCell Addition
    [Arguments]    ${gnb_id}
    Set 3 expected UE Context Modification messages for gNB${gnb_id}

Set ${all:\d+} expected UE Context Modification messages for gNB${gnb_id:\d+}
    EXPECT FLOW[timeout=20]: gNB${gnb_id} F1AP ${all}*uEContextModification

Verify ${all:\d+} UE Context Modification messages for gNB${gnb_id:\d+} occured
    PASS FLOW[timeout=20]: gNB${gnb_id} F1AP ${all}*uEContextModification

Verify UE3 6CC 3F3T SCell Addition Message Contents
    Verify gNB2 message UEContextModificationRequest number 1 of 3 fulfils ${selected_SCells_for_6CC_3F3T_UE3_AB15_CA_in_UE_CON_MOD_REQ} content
    Verify gNB2 message UEContextModificationResponse number 1 of 3 fulfils ${selected_SCells_for_6CC_3F3T_UE3_AB15_CA_in_UE_CON_MOD_RESP} content
    Verify gNB2 message UEContextModificationResponse number 1 of 3 fulfils ${PUCCH_config_for_6CC_3F3T_CA_in_UE_CON_MOD_RESP} content
    Verify gNB2 message UEContextModificationResponse number 1 of 3 fulfils ${csi_MeasConfig_for_6CC_3F3T_CA_in_UE_CON_MOD_RESP} content

Verify if UE3 RRCReconfiguration contains A1 measurements configuration before PCell Change
    Verify Tcpdump Log    packet_filter=${RRCRECONFIGURATION_BEFORE_PCELL_CHANGE}    continue_on_failure=False

Trigger A1 Based PCell Change
    [Arguments]    ${ue_id}    ${gnb_id}    ${A1_cmd}
    Expect PCell Change Messages Flow    ${ue_id}    ${gnb_id}
    Execute Egate Command And Wait For Data
    ...    cmd=ue_meas_cfg_disp id=${ue_id}
    Execute Egate Command And Wait For Data
    ...    cmd=ue_measurement_send_nr ${A1_cmd}
    Check if PCell Change messages flow occured    ${ue_id}
    Verify Successful PCell Change And SCells Release    ue_id=${UE_ID}
    Verify that Measurement Report messages occured for UE3

Expect PCell Change messages flow
    [Arguments]    ${ue_id}    ${gNB_id}=2    ${overall_timeout}=60
    Expect message flow
    ...    UE${ue_id}:NR-RRC_MeasurementReport (measId eq 3) as A1measurementReport
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
    ...  ${A1_measurementReport_in_UL_DCCH_Message_for_PCell_Change}
    ...  message_alias=A1measurementReport
    ...  flow_alias=PCellChange_UE${ue_id}
    Verify That Message Fulfills Query
    ...  ${spCellConfig_in_UE_CON_MOD_RESP_AB15}
    ...  message_alias=UEContextModificationResponse
    ...  flow_alias=PCellChange_UE${ue_id}
    Verify That Message Fulfills Query
    ...  ${meas_config_in_RRC_Reconf_3F3T_AB15}
    ...  message_alias=RRCReconfiguration
    ...  flow_alias=PCellChange_UE${ue_id}
    Verify That Message Fulfills Query
    ...  ${nonCriticalExtension_in_RRC_Reconf_3F3T_AB15}
    ...  message_alias=RRCReconfiguration
    ...  flow_alias=PCellChange_UE${ue_id}

Verify UE Successful Blind SCell Addition after A1 PCell Change
    Verify Tcpdump Log      packet_filter=${F1AP_SCELL_TO_BE_SETUP_MOD_LIST_AFTER_PCELL_CHANGE}        number_of_messages=2
    ...                                                                                                continue_on_failure=False
    Verify Tcpdump Log      packet_filter=${F1AP_SCELL_TO_ADD_MOD_LIST_AFTER_PCELL_CHANGE}             continue_on_failure=False
