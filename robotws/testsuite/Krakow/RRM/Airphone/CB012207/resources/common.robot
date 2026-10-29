*** Settings ***
Documentation
...            author:       Marcin Duplaga, marcin.duplaga@nokia.com
...                          Paulina Karpf Matoga, paulina.karpf_matoga@nokia.com
...                          Krystian Krakowski, krystian.krakowski@nokia.com
...            maintainer:   Marcin Duplaga, marcin.duplaga@nokia.com
...                          Paulina Karpf Matoga, paulina.karpf_matoga@nokia.com

Resource    testsuite/Krakow/resources/former_l3_sw2/main_cls.robot
Resource    variables.robot

*** Variables ***
&{DEL_NRMTRACECU_CONFIG}    delta=${CURDIR}/delta_configs/${ENB_BRANCH}/delta_del_NRMTRACECU.json
&{DELTA_PCMD_ENABLED}       delta=${CURDIR}/delta_configs/${ENB_BRANCH}/delta_pcmd_enabled.json

*** Keywords ***
Modify UE Capabilities And Remove NSA Cells From WTS Config
    [Arguments]    ${wts_out}    ${wts_in}=/opt/wts/latest/basic_setup.cfg
    File Should Exist    ${wts_in}
    wtscfg.Load Wts Cfg    ${wts_in}
    wtscfg.Insert    set SA_UE_CAPABILITIES_CB012207=${CB012207_UE_CAPABILITY}
    ...    before   set_ue simulated id=1
    wtscfg.Insert    set SA_UE_CAPABILITIES_CB012207_WITH_LOCATION=${CB012207_UE_CAPABILITY_WITH_LOCATION}
    ...    before   set_ue simulated id=1
    wtscfg.Insert    set SA_UE_CAPABILITIES_CB012207_UNSUPPORTED_BAND=${CB012207_UE_CAPABILITY_UNSUPPORTED_BAND}
    ...    before   set_ue simulated id=1
    wtscfg.Modify    ue_param id=1    ue_nr_capabilities=$SA_UE_CAPABILITIES_CB012207
    wtscfg.Modify    ue_param id=2    ue_nr_capabilities=$SA_UE_CAPABILITIES_CB012207_WITH_LOCATION
    wtscfg.Modify    ue_param id=3    ue_nr_capabilities=$SA_UE_CAPABILITIES_CB012207
    wtscfg.Modify    ue_param id=4    ue_nr_capabilities=$SA_UE_CAPABILITIES_CB012207_UNSUPPORTED_BAND
    wtscfg.Delete    set_cell id=3
    wtscfg.Delete    set_cell id=4
    Create File    ${wts_out}    ${Empty}
    wtscfg.save_wts_cfg    ${wts_out}

Remove Existing NradjGnb And Xn Link If Exists
    ${local_skip}    Get Variable Value    ${skip}
    ${skip_config}    Set Variable If    'config' in '${local_skip}'    ${True}    ${False}
    Run Keyword If    ${skip_config}    Return From Keyword
    Log to Console    Removing existing Xn Link if exists
    ${connection}    coam_admin.setup_admin
    ${status_nradjgnb}    ${msg_nradjgnb}    Run Keyword And Ignore Error    coam_admin.perform_object_recommissioning
    ...    dist_name=MRBTS-1/NRBTS-1/NRADJGNB-1    parameter=@{Empty}    operation=delete    connection=${connection}
    ${status_xnlink}    ${msg_xnlink}    Run Keyword And Ignore Error    coam_admin.perform_object_recommissioning
    ...    dist_name=MRBTS-1/NRBTS-1/XNLINK-1    parameter=@{Empty}    operation=delete    connection=${connection}
    coam_admin.teardown_admin    connection=${connection}
    ${not_exist_nradjgnb}    Run Keyword And Return Status    Should Contain    ${msg_nradjgnb}    object not exist
    ${not_exist_xnlink}    Run Keyword And Return Status    Should Contain    ${msg_xnlink}    object not exist
    Run Keyword If    not ${not_exist_nradjgnb} and '${status_nradjgnb}' != 'PASS'    Fail    ${msg_nradjgnb}
    Run Keyword If    not ${not_exist_xnlink} and '${status_xnlink}' != 'PASS'    Fail    ${msg_xnlink}

Recreate Objects via Delta Commissioning
    [Arguments]    ${delta_file}
    Upload Configs    config=${DEL_NRMTRACECU_CONFIG}
    Upload Configs    config=${delta_file}

Get MDT PCMD Records and Cell Traces from PCAP
    [Arguments]    ${pcap_filepath}=${dcap_files}[ipCapture][0]    ${filter}=nsetapx    ${log_suffix}=${EMPTY}
    ...    ${should_MDT_PCMD_be_present}=${True}    ${should_MDT_cellTrace_be_present}=${True}
    ${PCMD_records}    Run Keyword If    ${should_MDT_PCMD_be_present} == ${True}
    ...            Get PCMD Records from PCAP
    ...            pcap_filepath=${pcap_filepath}
    ...            filter=${filter}
    ...            pattern=nsetapx.ueMeasRecord_tree
    ...            save_to_file=${TEST_log_dir}/MDT/PCMD_records_${log_suffix}.json
    ...    ELSE    Run Keyword And Expect Error     REGEXP: No PCMD records present in ${pcap_filepath}
    ...            Get PCMD Records from PCAP
    ...            pcap_filepath=${pcap_filepath}
    ...            filter=${filter}
    ...            pattern=nsetapx.ueMeasRecord_tree
    ...            save_to_file=${TEST_log_dir}/MDT/PCMD_records_${log_suffix}.json
    ${cell_traces}     Run Keyword If    ${should_MDT_cellTrace_be_present} == ${True}
    ...            Get Cell Traces from PCAP
    ...            pcap_filepath=${pcap_filepath}
    ...            filter=${filter}
    ...            pattern=nr-rrc.measurementReport_element
    ...            save_to_file=${TEST_log_dir}/MDT/Cell_traces_${log_suffix}.json
    ...    ELSE    Run Keyword And Expect Error     REGEXP: No Cell Traces present in ${pcap_filepath}
    ...            Get Cell Traces from PCAP
    ...            pcap_filepath=${pcap_filepath}
    ...            filter=${filter}
    ...            pattern=nr-rrc.measurementReport_element
    ...            save_to_file=${TEST_log_dir}/MDT/Cell_traces_${log_suffix}.json
    &{MDT_traces}    Create Dictionary
    Set To Dictionary    ${MDT_traces}    PCMD=${PCMD_records}
    Set To Dictionary    ${MDT_traces}    cellTrace=${cell_traces}
    [Return]    ${MDT_traces}

Verify Sequence of cellActiveMDTUETraced
    [Arguments]    ${syslog_filepath}=${dcap_files}[syslog]    ${expected_seq}=None
    ${pattern}   Set Variable    (de)?allocated .* current list size .*
    ${output}    Should Match Regexp in Files    ${pattern}    @{syslog_filepath}
    ${received_seq}    Get Regexp Matches    ${output}    ${pattern}
    Run Keyword And Ignore Error    Lists Should Be Equal    ${expected_seq}    ${received_seq}
    List Should Contain Sub List    ${received_seq}    ${expected_seq}

Start Subscriber Trace
    [Arguments]    ${ue_id}=1    ${trace_session_id}=1    ${tce_ip}=10.0.1.1
    ${cmd}    Catenate  ue_ng_trace_start id=${ue_id} tce_ip=${tce_ip} trace_depth=minimum
    ...    ifaces_to_trace=Uu,NG-C,Xn-C trace_plmn=311:489 trace_rec_session_ref_id=${trace_session_id} trace_ref_id=${trace_session_id}
    Execute Egate Command    cmd=${cmd}
    Log To Console  Subsriber Trace Started

Get CRNTI of UE
    [Arguments]  ${ue_id}
    ${egate_output}    Execute Egate Command And Wait For Data
    ...    cmd=ue_disp id=${ue_id}
    ...    pass_regexp=C-RNTI
    ${CRNTI_line}    Get Regexp Matches    ${egate_output}    C-RNTI .* [0-9]+
    ${Actual_CRNTI}    Get Regexp Matches  @{CRNTI_line}   [0-9]+
    [Return]    ${Actual_CRNTI}[0]

Prepare Sequence List Of 4 Dictionaries From ${dict}
    ${dict1}    Create Dictionary    &{dict}
    ${dict2}    Create Dictionary    &{dict}
    ${dict3}    Create Dictionary    &{dict}
    ${dict4}    Create Dictionary    &{dict}
    ${Dict_Seq}    Create List    ${dict1}    ${dict2}    ${dict3}    ${dict4}
    [Return]    ${Dict_Seq}

Get Message Timestamp From Pcap
    [Arguments]    ${filter}=f1ap.UEContextSetupRequest_element    ${pcap_filepath}=${TEST_tcpdump_gnb_path}
    ...    ${which_message}=-1
    @{messages_timestamp}    Get Message Field Values from PCAP
    ...    pcap_filepath=${pcap_filepath}
    ...    field_name=frame.time_epoch
    ...    filter=${filter}
    ...    options=${tshark_options}
    ${date}    Convert To String    ${messages_timestamp}[${which_message}]
    ${splitted_date}    Split String    ${date}    separator=.
    Log to console    ${splitted_date}
    [Return]    ${splitted_date}[0]

Trigger Txnreloctimerexpiry by dropping RRCreconfig message
    [Arguments]    ${ue_id}=1
    Execute Egate Command    cmd=ue_nr_rrc_reconf_param id\=${ue_id} if_contains\=any action\=drop

Prepare Ue For Inter gNB HO
    [Arguments]    ${ue_id}=1
    ${cmd1}    Set Variable
    ...    ue_history_information_list_add_ngran id=${ue_id} gnb_id=2 cell_type=large nrcgi=311:489|0x01 time_ue_stayed_in_cell=97
    ${cmd2}    Set Variable
    ...    ue_history_information_list_add_ngran id=${ue_id} gnb_id=3 cell_type=large nrcgi=311:489|0x01 time_ue_stayed_in_cell=98
    ${cmd3}    Set Variable    ue_history_information_list id=${ue_id} action=commit
    ${cmd4}    Set Variable    ue_enb_param id=${ue_id} ue_history_list=${ue_id}
    ute_wtssim.execute_egate_command    cmd=${cmd1};${cmd2};${cmd3};${cmd4}

Modify DRB QoS To Exclude Mapping
    [Arguments]    ${sim_gNB}=3    ${pdu_id}=1
    ${cmd}    Catenate
    ...    gnb_xn_handover_preparation_param id=${sim_gNB}
    ...    action=modify_drb_qos_mapping drb_qos_map_modification=exclude_mapping pdu_sessions=${pdu_id}
    ute_wtssim.execute_egate_command    cmd=${cmd}

Modify DRB QoS To Exclude Mapping In NG-Based HO
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${sim_gNB}=3
    ${cmd}    Set Variable    ue_gnb_ho_param id=${ue_id} gnb=${sim_gNB} dRB_To_QosFlowsMappingList_Missing_For_Pdu=${pdu_id}
    ute_wtssim.execute_egate_command    cmd=${cmd}

Activate TA Testmode
    [Arguments]    ${ue_id}=1
    Log to Console      Activating TA Testmode
    ute_wtssim.execute_egate_command    cmd=ue_ta_nr profile_id=${ue_id} ue_p_delay_initial=8
    ute_wtssim.execute_egate_command    cmd=ue_testmode_set_nr id=${ue_id} testmode=ta profile_id=${ue_id} action=activate

Prepare And Verify xnHoSrcRecord In Collection
    [Arguments]    ${collected_records}
    ${hoReqSndTime}     Get Message Timestamp From Pcap    filter=xnap.HandoverRequest_element    which_message=0
    ${hoCmdSndTime}     Get Message Timestamp From Pcap    filter=xnap.HandoverRequestAcknowledge_element     which_message=0
    ${src_ng_rannode_ue_xnap_Id}    Get Message Field Values from PCAP
    ...    pcap_filepath=${TEST_tcpdump_gnb_path}
    ...    field_name=xnap.NG_RANnodeUEXnAPID
    ...    filter=xnap.HandoverRequest_element
    @{NG_RANnodeUEXnAPID_options}    Set Variable    -E    occurrence=l
    ${tgt_ng_rannode_ue_xnap_Id}    Get Message Field Values from PCAP
    ...    pcap_filepath=${TEST_tcpdump_gnb_path}
    ...    field_name=xnap.NG_RANnodeUEXnAPID
    ...    filter=xnap.HandoverRequestAcknowledge_element && ip.dst == 10.0.1.2
    ...    options=${NG_RANnodeUEXnAPID_options}
    Verify PCMD Record In Collection    ${collected_records}    xnHoSrcRecord    no
    ...    result=0    mobilityReason=1
    ...    tgtNgranNodeId.*gnb_Id.*plmn_Identity=13:41:98    tgtNgranNodeId.*gnb_id=00:00:08
    ...    tgtNgranCellId.*nrcgi.*plmn_Identity=13:41:98     tgtNgranCellId.*nrcgi.*cellIdentity=00:00:08:00:10
    ...    src_ng_rannode_ue_xnap_Id=${src_ng_rannode_ue_xnap_Id}[0]    tgt_ng_rannode_ue_xnap_Id=${tgt_ng_rannode_ue_xnap_Id}[0]
    ...    hoReqSndTime.*seconds=${hoReqSndTime}    hoReqSndTime.*useconds=[0-9]+
    ...    hoCmdSndTime.*seconds=${hoCmdSndTime}    hoCmdSndTime.*useconds=[0-9]+

Prepare And Verify xnHoTgtRecord In Collection
    [Arguments]    ${collected_records}
    ${hoReqRcvTime}     Get Message Timestamp From Pcap    filter=xnap.HandoverRequest_element    which_message=1
    ${hoCmdCmplRcvTime}    Get Message Timestamp From Pcap    filter=xnap.HandoverRequestAcknowledge_element     which_message=1
    ${src_ng_rannode_ue_xnap_Id}    Get Message Field Values from PCAP
    ...    pcap_filepath=${TEST_tcpdump_gnb_path}
    ...    field_name=xnap.NG_RANnodeUEXnAPID
    ...    filter=xnap.HandoverRequest_element && ip.dst == 10.0.1.2
    @{NG_RANnodeUEXnAPID_options}    Set Variable    -E    occurrence=l
    ${tgt_ng_rannode_ue_xnap_Id}    Get Message Field Values from PCAP
    ...    pcap_filepath=${TEST_tcpdump_gnb_path}
    ...    field_name=xnap.NG_RANnodeUEXnAPID
    ...    filter=xnap.HandoverRequestAcknowledge_element && ip.dst == 10.0.1.4
    ...    options=${NG_RANnodeUEXnAPID_options}
    ${ngcUeReference}    Get Message Field Values from PCAP
    ...    pcap_filepath=${TEST_tcpdump_gnb_path}
    ...    field_name=xnap.ng_c_UE_reference
    ...    filter=xnap.HandoverRequest_element && ip.dst == 10.0.1.2
    Verify PCMD Record In Collection    ${collected_records}    xnHoTgtRecord    no
    ...    result=0
    ...    srcNgranNodeId.*gnb_Id.*plmn_Identity=13:41:98    srcNgranNodeId.*gnb_id=00:00:08
    ...    srcNgranCellId.*nrcgi.*plmn_Identity=13:41:98     srcNgranCellId.*nrcgi.*cellIdentity=00:00:04:00:10
    ...    src_ng_rannode_ue_xnap_Id=${src_ng_rannode_ue_xnap_Id}[0]    tgt_ng_rannode_ue_xnap_Id=${tgt_ng_rannode_ue_xnap_Id}[0]
    ...    ngcUeReference=${ngcUeReference}[0]
    ...    hoReqRcvTime.*seconds=${hoReqRcvTime}            hoReqRcvTime.*useconds=[0-9]+
    ...    hoCmdCmplRcvTime.*seconds=${hoCmdCmplRcvTime}    hoCmdCmplRcvTime.*useconds=[0-9]+

Prepare And Verify ueCtxSetupRecords In Collection
    [Arguments]    ${collected_records}
    ${initialUeRrcMessageTransferSndTime}    Get Message Timestamp From Pcap    filter=f1ap.InitialULRRCMessageTransfer_element
    ${cu_ue_f1ap_id}    Get Message Field Values from PCAP
    ...    pcap_filepath=${TEST_tcpdump_gnb_path}
    ...    field_name=f1ap.GNB_CU_UE_F1AP_ID
    ...    filter=f1ap.UEContextSetupResponse_element
    ${du_ue_f1ap_id}    Get Message Field Values from PCAP
    ...    pcap_filepath=${TEST_tcpdump_gnb_path}
    ...    field_name=f1ap.GNB_DU_UE_F1AP_ID
    ...    filter=f1ap.UEContextSetupResponse_element
    ${ueCtxSetupRecord_attach}      Create dictionary
    ...      record_name=ueCtxSetupRecord
    ...      result=0    gnb_cu_ue_f1ap_Id=${cu_ue_f1ap_id}[0]    gnb_du_ue_f1ap_Id=${du_ue_f1ap_id}[0]
    ...      ssbSubcarrierSpacing=4    dlCarrierBandwidthTdd=10    absoluteFrequencySsb=2077723
    ...      initialUeRrcMessageTransferSndTime.*seconds=${initialUeRrcMessageTransferSndTime}
    ...      initialUeRrcMessageTransferSndTime.*useconds=[0-9]+
    ${ueCtxSetupReqRcvTime}     Get Message Timestamp From Pcap    filter=f1ap.UEContextSetupRequest_element    which_message=0
    ${ueCtxSetupCmplSndTime}    Get Message Timestamp From Pcap    filter=f1ap.UEContextSetupResponse_element    which_message=0
    ${ueCtxSetupRecord_pdu}      Create dictionary
    ...      record_name=ueCtxSetupRecord
    ...      result=0    gnb_cu_ue_f1ap_Id=${cu_ue_f1ap_id}[0]    gnb_du_ue_f1ap_Id=${du_ue_f1ap_id}[0]
    ...      ssbSubcarrierSpacing=4    dlCarrierBandwidthTdd=10    absoluteFrequencySsb=2077723
    ...      ueCtxSetupReqRcvTime.*seconds=${ueCtxSetupReqRcvTime}
    ...      ueCtxSetupReqRcvTime.*useconds=[0-9]+
    ...      ueCtxSetupCmplSndTime.*seconds=${ueCtxSetupCmplSndTime}
    ...      ueCtxSetupCmplSndTime.*useconds=[0-9]+
    ${ueCtxSetupReqRcvTime}     Get Message Timestamp From Pcap    filter=f1ap.UEContextSetupRequest_element    which_message=1
    ${ueCtxSetupCmplSndTime}    Get Message Timestamp From Pcap    filter=f1ap.UEContextSetupResponse_element    which_message=1
    ${ueCtxSetupRecord_ho}      Create dictionary
    ...      record_name=ueCtxSetupRecord
    ...      result=0    gnb_cu_ue_f1ap_Id=${cu_ue_f1ap_id}[1]    gnb_du_ue_f1ap_Id=${du_ue_f1ap_id}[1]
    ...      ssbSubcarrierSpacing=4    dlCarrierBandwidthTdd=10    absoluteFrequencySsb=2077723
    ...      ueCtxSetupReqRcvTime.*seconds=${ueCtxSetupReqRcvTime}
    ...      ueCtxSetupReqRcvTime.*useconds=[0-9]+
    ...      ueCtxSetupCmplSndTime.*seconds=${ueCtxSetupCmplSndTime}
    ...      ueCtxSetupCmplSndTime.*useconds=[0-9]+
    ${ueCtxSetupRecords_seq}    Create List    ${ueCtxSetupRecord_attach}    ${ueCtxSetupRecord_pdu}    ${ueCtxSetupRecord_ho}
    Verify PCMD Records Sequence In Collection    ${collected_records}    ${ueCtxSetupRecords_seq}

Prepare And Verify ueDuConnectivityRecords In Collection
    [Arguments]    ${collected_records}
    ${initialUeRrcMessageTransferRcvTime}    Get Message Timestamp From Pcap    filter=f1ap.InitialULRRCMessageTransfer_element
    ${cu_ue_f1ap_id}    Get Message Field Values from PCAP
    ...    pcap_filepath=${TEST_tcpdump_gnb_path}
    ...    field_name=f1ap.GNB_CU_UE_F1AP_ID
    ...    filter=f1ap.UEContextSetupResponse_element
    ${du_ue_f1ap_id}    Get Message Field Values from PCAP
    ...    pcap_filepath=${TEST_tcpdump_gnb_path}
    ...    field_name=f1ap.GNB_DU_UE_F1AP_ID
    ...    filter=f1ap.UEContextSetupResponse_element
    ${ueDuConnectivityRecord_attach}      Create dictionary
    ...      record_name=ueDuConnectivityRecord
    ...      result=0    gnb_du_Id=0    gnb_Id.*plmn_Identity=13:41:98    gnb_id=00:00:04
    ...      gnb_cu_ue_f1ap_Id=${cu_ue_f1ap_id}[0]    gnb_du_ue_f1ap_Id=${du_ue_f1ap_id}[0]
    ...      initialUeRrcMessageTransferRcvTime.*seconds=${initialUeRrcMessageTransferRcvTime}
    ...      initialUeRrcMessageTransferRcvTime.*useconds=[0-9]+
    ${ueCtxSetupReqSndTime}     Get Message Timestamp From Pcap    filter=f1ap.UEContextSetupRequest_element    which_message=0
    ${ueCtxSetupCmplRcvTime}    Get Message Timestamp From Pcap    filter=f1ap.UEContextSetupResponse_element    which_message=0
    ${ueDuConnectivityRecord_pdu}      Create dictionary
    ...      record_name=ueDuConnectivityRecord
    ...      result=0    gnb_du_Id=0    gnb_Id.*plmn_Identity=13:41:98    gnb_id=00:00:04
    ...      gnb_cu_ue_f1ap_Id=${cu_ue_f1ap_id}[0]    gnb_du_ue_f1ap_Id=${du_ue_f1ap_id}[0]
    ...      ueCtxSetupReqSndTime.*seconds=${ueCtxSetupReqSndTime}
    ...      ueCtxSetupReqSndTime.*useconds=[0-9]+
    ...      ueCtxSetupCmplRcvTime.*seconds=${ueCtxSetupCmplRcvTime}
    ...      ueCtxSetupCmplRcvTime.*useconds=[0-9]+
    ${ueCtxSetupReqSndTime}     Get Message Timestamp From Pcap    filter=f1ap.UEContextSetupRequest_element    which_message=1
    ${ueCtxSetupCmplRcvTime}    Get Message Timestamp From Pcap    filter=f1ap.UEContextSetupResponse_element    which_message=1
    ${ueDuConnectivityRecord_ho}      Create dictionary
    ...      record_name=ueDuConnectivityRecord
    ...      result=0    gnb_du_Id=0    gnb_Id.*plmn_Identity=13:41:98    gnb_id=00:00:04
    ...      gnb_cu_ue_f1ap_Id=${cu_ue_f1ap_id}[1]    gnb_du_ue_f1ap_Id=${du_ue_f1ap_id}[1]
    ...      ueCtxSetupReqSndTime.*seconds=${ueCtxSetupReqSndTime}
    ...      ueCtxSetupReqSndTime.*useconds=[0-9]+
    ...      ueCtxSetupCmplRcvTime.*seconds=${ueCtxSetupCmplRcvTime}
    ...      ueCtxSetupCmplRcvTime.*useconds=[0-9]+
    ${ueDuConnectivityRecords_seq}    Create List    ${ueDuConnectivityRecord_attach}    ${ueDuConnectivityRecord_pdu}
    ...    ${ueDuConnectivityRecord_ho}
    Verify PCMD Records Sequence In Collection    ${collected_records}    ${ueDuConnectivityRecords_seq}

Prepare And Verify duBearerRecord In Collection
    [Arguments]    ${collected_records}
    Verify PCMD Record In Collection    ${collected_records}    bearerRecord    no
    ...    trigger=1    setupBearers=1    drb_Id=4
    ...    drbLevelQos.*qosCharacteristics=0      drbLevelQos.*nonDynamicFiveQiDescriptor.*fiveQi=6
    ...    drbLevelQos.*arp.*priorityLevel=15     drbLevelQos.*arp.*preemptionCapability=0
    ...    drbLevelQos.*arp.*preemptionVulnerability=1    snssai.*sst=01    snssai.*sd=d1:43:a5
    ...    DuQosFlowMappedToBearer.*qfi=1    DuQosFlowMappedToBearer.*qosCharacteristics=0    DuQosFlowMappedToBearer.*fiveQi=6
    ...    qosFlowsMappedToBearer.*arp.*priorityLevel=15    qosFlowsMappedToBearer.*arp.*preemptionCapability=0
    ...    qosFlowsMappedToBearer.*arp.*preemptionVulnerability=1

Perform Handover To ${node_type} gNB
    &{pci}    Create Dictionary    Sim=52    Ext=50
    Perform Inter-GNB Xn Handover To Target PCI    ue_id=1    target_pci=${pci}[${node_type}]    event=A3
    ...    srsrp_nr=19    nrsrp_nr=85

Switch HO Type To ${type} In Ext GNB
    &{values}    Create Dictionary    Xn=allowed    NG=XnHoNotAllowed
    Change NIDD Parameter Online
    ...    dist=MRBTS-1/NRBTS-1/NRCELL-1/NRREL-1    param=handoverAllowedSA    value=${values}[${type}]

Set Sim GNB To ${type} HO and ${event} Event
    &{ho}    Create Dictionary    Xn=xn_based    NG=ng_based
    Update Sim GNB Parameters    id=3    measEvent=${event}    sa_ho=${ho}[${type}]

Trigger E-CID
    [Arguments]    ${ue_id}=1    ${pass_regexp}=rrcReconfiguration
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=0 report_type=periodical action=send_after_rrc_reconf_complete
    ...    delay=3000 srsrp_nr=40 srsrq_nr=50 srs_result=0:40:50:40
    Execute Egate Command    cmd=${cmd}    pass_regexp=send this meas report
    ${cmd1}    Catenate    lmf_send_ecid_meas_req id=1 ue=${ue_id} nrppa_transaction_id=1 lmf_ue_measurement_id=1 report_characteristics=OnDemand
    ...    meas_qty=SS-RSRP,SS-RSRQ
    Execute Egate Command    cmd=${cmd1}    pass_regexp=${pass_regexp}

Check RRC messages count and params
    [Arguments]    ${event}    ${offset_ssb_A3}    ${hysteresis_A3}    ${time_to_trigger_ssb_A3}
    ...    ${threshold1_A5}    ${threshold2_A5}    ${hysteresis_A5}    ${time_to_trigger_ssb_A5}    ${count}
    Sleep   5s   reason=Wait for ue rrc resume message
    ${expected_meas_config}    Catenate
    ...    SEPARATOR=&&
    ...    nr-rrc.rrc${event}_element
    ...    nr-rrc.eventId == eventA3
    ...    nr-rrc.measTriggerQuantityOffset.rsrp == ${offset_ssb_A3}
    ...    nr-rrc.hysteresis == ${hysteresis_A3}
    ...    nr-rrc.timeToTrigger == ${time_to_trigger_ssb_A3}
    ...    nr-rrc.eventId == eventA5
    ...    nr-rrc.a5_Threshold1 == 0
    ...    nr-rrc.a5_Threshold2 == 0
    ...    nr-rrc.measTriggerQuantity.rsrp == ${threshold1_A5}
    ...    nr-rrc.measTriggerQuantity.rsrp == ${threshold2_A5}
    ...    nr-rrc.hysteresis == ${hysteresis_A5}
    ...    nr-rrc.timeToTrigger == ${time_to_trigger_ssb_A5}
    Verify Message Count in PCAP
    ...  filter=${expected_meas_config}
    ...  pcap_filepath=${TEST_tcpdump_gnb_path}
    ...  count=${count}    options=${tshark_options}

Prepare E-CID Meas Record Verification List
    ${ecidMeasRecord_mba1}  Create Dictionary  &{ecidMeasRecord}
    ${ecidMeasRecord_sba1}  Create Dictionary  &{ecidMeasRecord}
    ${ecidMeasRecord_mba2}  Create Dictionary  &{ecidMeasRecord}
    ${PCMD_Seq}    Create List    ${ecidMeasRecord_mba1}    ${ecidMeasRecord_sba1}    ${ecidMeasRecord_mba2}
    [Return]    ${PCMD_Seq}

Prepare E-CID Cell Traces And Subscriber Traces Sequence
    ${ecidMeasCellTrace_mba1}  Create Dictionary  &{ecidMeasurementInitiationRequest}
    ${ecidMeasCellTrace_sba1}  Create Dictionary  &{ecidMeasurementInitiationRequest}
    ${ecidMeasCellTrace_mba2}  Create Dictionary  &{ecidMeasurementInitiationResponse}
    ${ecidMeasCellTrace_sba2}  Create Dictionary  &{ecidMeasurementInitiationResponse}
    ${ecidMeasCellTrace_mba3}  Create Dictionary  &{ecidMeasurementInitiationRequest}
    ${ecidMeasCellTrace_mba4}  Create Dictionary  &{ecidMeasurementInitiationFailure}
    ${ecidMeasCellTrace_sba3}  Create Dictionary  &{ecidMeasurementInitiationRequest}
    ${ecidMeasCellTrace_sba4}  Create Dictionary  &{ecidMeasurementInitiationFailure}
    ${ecidMeasCellTrace_mba5}  Create Dictionary  &{ecidMeasurementInitiationRequest}
    ${ecidMeasCellTrace_mba6}  Create Dictionary  &{ecidMeasurementInitiationResponse}
    ${CellTrace_Seq}    Create List     ${ecidMeasCellTrace_mba1}    ${ecidMeasCellTrace_sba1}    ${ecidMeasCellTrace_mba2}
    ...    ${ecidMeasCellTrace_sba2}    ${ecidMeasCellTrace_mba3}    ${ecidMeasCellTrace_mba4}    ${ecidMeasCellTrace_sba3}
    ...    ${ecidMeasCellTrace_sba4}    ${ecidMeasCellTrace_mba5}    ${ecidMeasCellTrace_mba6}
    [Return]    ${CellTrace_Seq}

Prepare Meas Cell Traces And Subscriber Traces Sequence
    ${ecidMeasCellTrace_mba1}  Create Dictionary  &{ecidMeasCellTrace}
    ${ecidMeasCellTrace_sba1}  Create Dictionary  &{ecidMeasCellTrace}
    ${ecidMeasCellTrace_mba2}  Create Dictionary  &{ecidMeasCellTrace}
    ${CellTrace_Seq}    Create List     ${ecidMeasCellTrace_mba1}    ${ecidMeasCellTrace_sba1}    ${ecidMeasCellTrace_mba2}
    [Return]    ${CellTrace_Seq}
