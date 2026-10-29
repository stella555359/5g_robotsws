*** Settings ***
Force Tags      CRT    RAN_5G    RAN_5G_TDD    SBTS00    STATE_CONFIGURED    RF50
...             CLOUD_5G_I_LO_AP_LO      VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE

Documentation
...            authors:       Marcin Duplaga, marcin.duplaga@nokia.com,
...                           Michal Sagan, michal.sagan@nokia.com
...            maintainer:    I_EXT_MN_RAN_VRF_WRO2_7_T03@internal.nsn.com

Resource    ../../../../sim_resources/Krk_regression/ran_L3_SW2_resources/KRK3_resources/krk3_common/main_cls.robot
Resource    resources/common.robot
Resource    ../../../../resources/airphone/5G_SW_WRO_Keywords.robot
Library     ta5g_ue_mobility
Library     ta5g_enb
Library     ta5g_setups_and_teardowns
Library     ta5g_delta
Library     ../../../../resources/airphone/scripts/dcap_version_checker.py
Library     ../../../../resources/airphone/scripts/SwconfigFlagsChecker.py
Library     ../../../../resources/airphone/scout_reporting/ScoutMonitor.py

Suite Setup       Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
...      AND      Create Suite Scope Variables
...      AND      Start Vm Ethernet Interfaces
...      AND      Get Scfc File    output_filepath=${OUTPUT_DIR}/initial_commissioning.xml
...      AND      Find Scfc and Send Delta Commissioning    scfc_filename=CB008340.json
...      AND      Check Version Of Dcap And Install If Needed
...      AND      SwconfigFlagsChecker.Modify Flags In Swconfig    ${swconfig_flags}
...      AND      Reach Onair    lua_cfg=${WTS_HO}    check_edaemon_port=True
...      AND      Stop Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs

Suite Teardown    Run Keywords    Stop Vm Ethernet Interfaces
...      AND      Roll Delta Back
...               initial_scf_filename=${OUTPUT_DIR}/initial_commissioning.xml
...               delta_scf_filename=${CURDIR}/config/default/CB008340.json
...      AND      Stop Default Processes And Gather Logs And Compress Logs

Test Setup        Test Case Setup    logs=${LOGS_WITH_DCAP}    radio_res=yes
Test Teardown     Run Keywords    Restart Scout Monitoring On Test Line If Needed
...      AND      Add Scout External Execution ID To Reporting Portal
...      AND      Test Case Teardown    check_radio_res=no    oam_logs=yes

*** Variables ***
@{swconfig_flags}=      0xA40000=0    0x1A0020=1
@{IP_ADDR_SIM_GNB}      eth3:10.0.1.3/24    eth3:10.0.1.4/24
${DELTA_PCMD}           ${CURDIR}/resources//Delta_PCMD_DCAP.json
${DELTA_HO_SA}          ${CURDIR}/resources/Delta_HO_Xn_NG_A3_A5.json
${DELTA_HO_NSA}         ${CURDIR}/resources/delta_nsa_intercell_ho_sgnb_rlf.json
@{DELTAS}               ${DELTA_PCMD}    ${DELTA_HO_SA}    ${DELTA_HO_NSA}
&{SUITE_CONFIG}         delta=${DELTAS}    ip_addr=${IP_ADDR_SIM_GNB}
${WTS_HO}               ${CURDIR}/config/wts_ext_and_sim_gnb.cfg
@{DCAP_GNB}             condor5gSyslog
@{DCAP_BTS}             ipCapture
&{DCAP_OPTIONS}         gnb_custom_profile=${DCAP_GNB}    bts_custom_profile=${DCAP_BTS}    start=yes
&{LOGS_WITH_DCAP}       dcap=${DCAP_OPTIONS}    tcpdump_gnb=yes
@{tshark_options}    -o    ntrstr.defragment:TRUE    -o    ntrstr.port:49148

*** Test Cases ***
# Test transferred from Krakow, will be rewritten
[1]CB008340-5G-A_2_B02_XnA_TargetHO_reporting_during_Xn_based_Inter-gNB_SA_handover
    Prepare Ue For Inter gNB HO
    Start SA L3 Call    ue_id=1
    Verify SA UE Traffic Using Bearer Stats    ue_id=1    wait=10s
    Perform Handover To Sim gNB
    Verify SA UE Traffic Using Bearer Stats    ue_id=1    wait=10s
    ${HO_to_real_gNB_timestamp}    DateTime.Get Current Date
    Perform Handover To Ext gNB
    Verify SA UE Traffic Using Bearer Stats    ue_id=1    wait=10s
    Stop SA L3 Call    ue_id=1
    ${dcap_files}      Stop and Collect DCAP Trace    log_dir=${TEST_log_dir}/DCAP/
    Set Test Variable    ${dcap_files}
    ${PCMD_records}    Get PCMD Records from PCAP     pcap_filepath=${dcap_files}[ipCapture][0]
    ...    filter=nsetapx    save_to_file=${TEST_log_dir}/PCMD/PCMD_records.json
    ${duBearerRecord_after_ho}    Get PCMD Records from PCAP     pcap_filepath=${dcap_files}[ipCapture][0]
    ...    filter=nsetapx && frame.time >= "${HO_to_real_gNB_timestamp}"    save_to_file=${TEST_log_dir}/PCMD/PCMD_records.json
    Prepare And Verify timingAdvanceTraceRecord In Collection   ${PCMD_records}
    Prepare And Verify xnHoSrcRecord In Collection              ${PCMD_records}
    Prepare And Verify xnHoTgtRecord In Collection              ${PCMD_records}
    Prepare And Verify duBearerRecord In Collection             ${duBearerRecord_after_ho}
    Prepare And Verify ueCtxSetupRecords In Collection          ${PCMD_records}
    Prepare And Verify ueDuConnectivityRecords In Collection    ${PCMD_records}

# Test transferred from Krakow, will be rewritten
[1]CB008340-5G-A_4_B04_NgAPTargetHO_reporting_on_target_gnb_during_NG-based_Inter-gNB_SA_handover
    [Setup]    Run Keywords
    ...           Switch HO Type To NG In Ext GNB
    ...    AND    Set Sim GNB To NG HO and A5 Event
    ...    AND    Test Case Setup    logs=${LOGS_WITH_DCAP}    radio_res=yes
    Start SA L3 Call    ue_id=1
    Sleep    5s    reason=UE needs some time before establishing another PDU session
    PDU Session Setup    ue_id=1    pdu_id=2    gw_id=2
    Perform Inter-GNB NG Handover To Target PCI    ue_id=1    target_pci=54    event=A5
    Perform Inter-GNB NG Handover To Target PCI    ue_id=1    target_pci=50    event=A5
    Verify SA UE Traffic Using Bearer Stats    ue_id=1    wait=10s
    Stop SA L3 Call    ue_id=1
    ${dcap_files}      Stop and Collect DCAP Trace    log_dir=${TEST_log_dir}/DCAP/
    ${all_PCMD_records}   Get PCMD Records from PCAP     pcap_filepath=${dcap_files}[ipCapture][0]
    ...    filter=nsetapx    save_to_file=${TEST_log_dir}/PCMD/all_PCMD_records.json
    ${PCMD_du_records}    Get PCMD Records from PCAP     pcap_filepath=${dcap_files}[ipCapture][0]
    ...    filter=nsetapx.DuVendorExtensionRecordDataType    save_to_file=${TEST_log_dir}/PCMD/PCMD_du_records.json
    @{PCMD_Seq_duBearerRecords}     Prepare duBearerRecords Verification List
    @{PCMD_Seq_ngHoSrcRecord}       Prepare ngHoSrcRecord Verification List
    @{PCMD_Seq_ngHoTgtRecord}       Prepare ngHoTgtRecord Verification List
    Verify PCMD Records Sequence In Collection    ${all_PCMD_records}    ${PCMD_Seq_ngHoSrcRecord}
    Verify PCMD Records Sequence In Collection    ${all_PCMD_records}    ${PCMD_Seq_ngHoTgtRecord}
    Verify PCMD Records Sequence In Collection    ${PCMD_du_records}     ${PCMD_Seq_duBearerRecords}


*** Keywords ***
Enter Idle Mode
    [Arguments]    ${ue_id}=1
    ute_wtssim.execute_egate_command    cmd=ue_im_entry id=${ue_id} by=ue    pass_regexp=UE${ue_id}: IS IDLE
    Sleep    5s    reason=Wait for UE to be in IDLE mode

Exit Idle Mode To Connected
    [Arguments]    ${ue_id}=1
    Exit Idle Mode     ue_id=${ue_id}    pass_regexp=UE${ue_id}: RrcState: NR CONNECTED

Prepare rrcSetupRecord Verification List
    ${rrcConnReqTriggerRcvTime}        Get Message Timestamp From Pcap     filter=nr-rrc.rrcSetupRequest_element   which_message=0
    ${rrcConnSetupCmplRcvTime}    Get Message Timestamp From Pcap     filter=nr-rrc.rrcSetupComplete_element    which_message=0
    ${durrcSetupRecord}      Create dictionary
    ...    record_name=rrcSetupRecord
    ...    result=0    establishmentCauseType.*establishmentCause=4
    ...    rrcConnReqTriggerRcvTime.*seconds=${rrcConnReqTriggerRcvTime}    rrcConnReqTriggerRcvTime.*useconds=[0-9]+
    ...    rrcConnEstablishmentCmplRcvTime.*seconds=${rrcConnSetupCmplRcvTime}    rrcConnEstablishmentCmplRcvTime.*useconds=[0-9]+
    ${currcSetupRecord}      Create dictionary
    ...    record_name=rrcSetupRecord
    ...    result=0    establishmentCauseType.*establishmentCause=4
    ...    rrcConnReqTriggerRcvTime.*seconds=${rrcConnReqTriggerRcvTime}    rrcConnReqTriggerRcvTime.*useconds=[0-9]+
    ...    rrcConnEstablishmentCmplRcvTime.*seconds=${rrcConnSetupCmplRcvTime}    rrcConnEstablishmentCmplRcvTime.*useconds=[0-9]+
    ${rrcConnReqTriggerRcvTime}        Get Message Timestamp From Pcap     filter=nr-rrc.rrcSetupRequest_element    which_message=1
    ${rrcConnSetupCmplRcvTime}    Get Message Timestamp From Pcap     filter=nr-rrc.rrcSetupComplete_element    which_message=1
    ${durrcSetupRecord_after_exit_idle_mode}      Create dictionary
    ...    record_name=rrcSetupRecord
    ...    result=0    establishmentCauseType.*establishmentCause=4
    ...    rrcConnReqTriggerRcvTime.*seconds=${rrcConnReqTriggerRcvTime}    rrcConnReqTriggerRcvTime.*useconds=[0-9]+
    ...    rrcConnEstablishmentCmplRcvTime.*seconds=${rrcConnSetupCmplRcvTime}    rrcConnEstablishmentCmplRcvTime.*useconds=[0-9]+
    ...    ng_s_tmsiValue.*ng_s_tmsi=00:82:00:00:00:0[1-3]
    ${currcSetupRecord_after_exit_idle_mode}      Create dictionary
    ...    record_name=rrcSetupRecord
    ...    result=0    establishmentCauseType.*establishmentCause=4
    ...    rrcConnReqTriggerRcvTime.*seconds=${rrcConnReqTriggerRcvTime}    rrcConnReqTriggerRcvTime.*useconds=[0-9]+
    ...    rrcConnEstablishmentCmplRcvTime.*seconds=${rrcConnSetupCmplRcvTime}    rrcConnEstablishmentCmplRcvTime.*useconds=[0-9]+
    ...    ng_s_tmsiValue.*ng_s_tmsi=00:82:00:00:00:0[1-3]
    ${PCMD_Seq}    Create List    ${durrcSetupRecord}    ${currcSetupRecord}
    ...    ${durrcSetupRecord_after_exit_idle_mode}    ${currcSetupRecord_after_exit_idle_mode}
    [Return]    ${PCMD_Seq}

Prepare CuUeSetupTraceRecord Verification List
    ${ran_ue_ngap_Id}    Get Message Field Values from PCAP
    ...    pcap_filepath=${TEST_tcpdump_gnb_path}
    ...    field_name=ngap.RAN_UE_NGAP_ID
    ...    filter=ngap.InitialUEMessage_element
    ${amf_ue_ngap_Id}    Get Message Field Values from PCAP
    ...    pcap_filepath=${TEST_tcpdump_gnb_path}
    ...    field_name=ngap.AMF_UE_NGAP_ID
    ...    filter=ngap.DownlinkNASTransport_element
    ${ueSetupRecord_attach}      Create dictionary
    ...    record_name=ueSetupRecord
    ...    result=0    trigger=0    ran_ue_ngap_Id=${ran_ue_ngap_Id}[0]    amf_ue_ngap_Id=${amf_ue_ngap_Id}[0]
    ${ueSetupRecord_pduSession}      Create dictionary
    ...    record_name=ueSetupRecord
    ...    result=0    trigger=0    ran_ue_ngap_Id=${ran_ue_ngap_Id}[0]    amf_ue_ngap_Id=${amf_ue_ngap_Id}[0]
    ...    guami.*plmn_Identity=13:41:98    guami.*amfRegionId=01
    ...    guami.*amfSetId=00:80    guami.*amfPointer=08
    ${ran_ue_ngap_Id}    Get Message Field Values from PCAP
    ...    pcap_filepath=${TEST_tcpdump_gnb_path}
    ...    field_name=ngap.RAN_UE_NGAP_ID
    ...    filter=ngap.InitialContextSetupRequest_element
    ${amf_ue_ngap_Id}    Get Message Field Values from PCAP
    ...    pcap_filepath=${TEST_tcpdump_gnb_path}
    ...    field_name=ngap.AMF_UE_NGAP_ID
    ...    filter=ngap.InitialContextSetupRequest_element
    ${ueSetupRecord_reestab}      Create dictionary
    ...    record_name=ueSetupRecord
    ...    result=0    trigger=1    ran_ue_ngap_Id=${ran_ue_ngap_Id}[0]    amf_ue_ngap_Id=${amf_ue_ngap_Id}[0]
    ...    guami.*plmn_Identity=13:41:98    guami.*amfRegionId=01
    ...    guami.*amfSetId=00:80    guami.*amfPointer=08
    ${PCMD_Seq}    Create List    ${ueSetupRecord_attach}    ${ueSetupRecord_pduSession}    ${ueSetupRecord_reestab}
    [Return]    ${PCMD_Seq}

Prepare And Verify SgNBInitiatedSgNBModificationTraceRecord Verification
    [Arguments]    ${collected_records}
    ${sgnbModificationReqSndTime}        Get Message Timestamp From Pcap     filter=x2ap.SgNBModificationRequired_element
    ${sgnbModificationConfirmRcvTime}    Get Message Timestamp From Pcap     filter=x2ap.SgNBModificationConfirm_element
    ${sgnb_ue_x2ap_Id}    Get Message Field Values from PCAP
    ...    pcap_filepath=${TEST_tcpdump_gnb_path}
    ...    field_name=x2ap.SgNB_UE_X2AP_ID
    ...    filter=x2ap.SgNBAdditionRequestAcknowledge_element
    ${menb_ue_x2ap_Id}    Get Message Field Values from PCAP
    ...    pcap_filepath=${TEST_tcpdump_gnb_path}
    ...    field_name=x2ap.UE_X2AP_ID
    ...    filter=x2ap.SgNBAdditionRequest_element
    Verify PCMD Record In Collection    ${collected_records}    sgnbInitiatedSgNBModRecord    no
    ...    result=0
    ...    sgnbModificationReason=4    sgnb_ue_x2ap_Id=${sgnb_ue_x2ap_Id}[0]    menb_ue_x2ap_Id=${menb_ue_x2ap_Id}[0]
    ...    enb_Id.*plmn_Identity=13:41:98    enb_Id.*macro_eNB_Id=12:34:60
    ...    sgnbModificationReqSndTime.*seconds=${sgnbModificationReqSndTime}    sgnbModificationReqSndTime.*useconds=\\d{2,}
    ...    sgnbModificationConfirmRcvTime.*seconds=${sgnbModificationConfirmRcvTime}    sgnbModificationConfirmRcvTime.*useconds=\\d{2,}

Prepare And Verify CuUeReleaseTraceRecord Verification Data
    [Arguments]    ${collected_records}
    Verify PCMD Record In Collection    ${collected_records}    ueReleaseRecord    no
    ...    classifier.*finalClass=0    classifier.*primaryQualifier=3    classifier.*secondaryQualifier=4

Trigger RLF Detected By SgNB With Recovery
    [Arguments]    ${ue_id}=101
    Log to console    Triggering RLF with recovery
    ${pattern}    Set Variable    Sending SgNB Modification Confirm
    ${cmd_1}    Set Variable    rlf_testmode_nr profile_id=3 num_stop_dlharq_tx=65535 num_stop_csi_report=65535
    ${cmd_2}    Set Variable    ue_testmode_set_nr id=${ue_id} testmode=rlf action=activate profile_id=3
    ${cmd_3}    Catenate
    ...    ue_measurement_send_nr id=${ue_id} meas_id=1 event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=51
    ...    nrsrp_nr=50 nrsrq_nr=50 rs_type=ssb index=0 nrs_result=50:50:50
    ute_wtssim.execute_egate_command    cmd=${cmd_1};${cmd_2}
    Sleep    4s    reason=Wait for RLF
    ute_wtssim.execute_egate_command    cmd=${cmd_3}    pass_regexp=${pattern}
    Log to console    RLF with recovery triggered successfully

Set Sim GNB To ${type} HO and ${event} Event
    &{ho}    Create Dictionary    Xn=xn_based    NG=ng_based
    Update Sim GNB Parameters    id=3    measEvent=${event}    sa_ho=${ho}[${type}]

Prepare ngHoSrcRecord Verification List
    ${hoReqSndTime}     Get Message Timestamp From Pcap    filter=ngap.HandoverRequired_element
    ${hoCmdSndTime}     Get Message Timestamp From Pcap    filter=ngap.HandoverCommand_element
    ${ngHoSrcRecord}      Create dictionary
    ...      record_name=ngHoSrcRecord
    ...      result=0    mobilityReason=1
    ...      tgtRanNodeId.*plmn_Identity=13:41:98    tgtRanNodeId.*gnb_id=00:00:08
    ...      tgtRanCellId.*plmn_Identity=13:41:98    tgtRanCellId.*cellIdentity=00:00:08:00:10
    ...      hoReqSndTime.*seconds=${hoReqSndTime}   hoReqSndTime.*useconds=\\d{2,}
    ...      hoCmdSndTime.*seconds=${hoCmdSndTime}   hoCmdSndTime.*useconds=\\d{2,}
    ${PCMD_Seq}    Create List    ${ngHoSrcRecord}
    [Return]    ${PCMD_Seq}

Prepare ngHoTgtRecord Verification List
    ${hoReqRcvTime}        Get Message Timestamp From Pcap     filter=ngap.HandoverRequest_element
    ${hoCmdCmplRcvTime}    Get Message Timestamp From Pcap     filter=ngap.HandoverNotify_element
    ${ngHoTgtRecord}      Create dictionary
    ...      record_name=ngHoTgtRecord
    ...      result=0
    ...      srcRanCellId.*plmn_Identity=13:41:98    srcRanCellId.*cellIdentity=00:00:08:00:10
    ...      hoReqRcvTime.*seconds=${hoReqRcvTime}   hoReqRcvTime.*useconds=\\d{2,}
    ...      hoCmdCmplRcvTime.*seconds=${hoCmdCmplRcvTime}   hoCmdCmplRcvTime.*useconds=\\d{2,}
    ${PCMD_Seq}    Create List    ${ngHoTgtRecord}
    [Return]    ${PCMD_Seq}

Prepare duBearerRecords Verification List
    ${duBearerRecord1}      Create dictionary
    ...      record_name=bearerRecord
    ...      trigger=1    setupBearers=1    drb_Id=4
    ...      drbLevelQos.*qosCharacteristics=0    drbLevelQos.*fiveQi=6
    ...      drbLevelQos.*priorityLevel=15    drbLevelQos.*preemptionCapability=0
    ...      drbLevelQos.*preemptionVulnerability=1    snssai.*sst=01     snssai.*sd=d1:43:a5
    ...      DuQosFlowMappedToBearerItem.*qfi=1    DuQosFlowMappedToBearerItem.*qosCharacteristics=0
    ...      DuQosFlowMappedToBearerItem.*fiveQi=6    DuQosFlowMappedToBearerItem.*priorityLevel=15
    ...      DuQosFlowMappedToBearerItem.*preemptionCapability=0    DuQosFlowMappedToBearerItem.*preemptionVulnerability=1
    ${duBearerRecord2}      Create dictionary
    ...      record_name=bearerRecord
    ...      trigger=2    setupBearers=1    drb_Id=5
    ...      drbLevelQos.*qosCharacteristics=0    drbLevelQos.*fiveQi=6
    ...      drbLevelQos.*priorityLevel=15    drbLevelQos.*preemptionCapability=0
    ...      drbLevelQos.*preemptionVulnerability=1    snssai.*sst=01     snssai.*sd=d1:43:a5
    ...      DuQosFlowMappedToBearerItem.*qfi=1    DuQosFlowMappedToBearerItem.*qosCharacteristics=0
    ...      DuQosFlowMappedToBearerItem.*fiveQi=6    DuQosFlowMappedToBearerItem.*priorityLevel=15
    ...      DuQosFlowMappedToBearerItem.*preemptionCapability=0    DuQosFlowMappedToBearerItem.*preemptionVulnerability=1
    ${duBearerRecord3}      Create dictionary
    ...      record_name=bearerRecord
    ...      trigger=1   setupBearers=2    setupBearers.*Item 0.*drb_Id=4    setupBearers.*Item 1.*drb_Id=5
    ...      drbLevelQos.*qosCharacteristics=0    drbLevelQos.*fiveQi=6
    ...      drbLevelQos.*priorityLevel=15    drbLevelQos.*preemptionCapability=0
    ...      drbLevelQos.*preemptionVulnerability=1    snssai.*sst=01     snssai.*sd=d1:43:a5
    ...      DuQosFlowMappedToBearerItem.*qfi=1    DuQosFlowMappedToBearerItem.*qosCharacteristics=0
    ...      DuQosFlowMappedToBearerItem.*fiveQi=6    DuQosFlowMappedToBearerItem.*priorityLevel=15
    ...      DuQosFlowMappedToBearerItem.*preemptionCapability=0    DuQosFlowMappedToBearerItem.*preemptionVulnerability=1
    ${PCMD_Seq}    Create List    ${duBearerRecord1}    ${duBearerRecord2}    ${duBearerRecord3}
    [Return]    ${PCMD_Seq}

Switch HO Type To ${type} In Ext GNB
    &{values}    Create Dictionary    Xn=allowed    NG=XnHoNotAllowed
    Change NIDD Parameter Online
    ...    dist=MRBTS-1/NRBTS-1/NRCELL-1/NRREL-1    param=handoverAllowedSA    value=${values}[${type}]

Prepare And Verify timingAdvanceTraceRecord In Collection
    [Arguments]    ${collected_records}
    ${cmd}    Set Variable    grep -o 'initialTa[\:=][0-9]*' '${dcap_files}[syslog][0]' | tail -1 | cut -d ":" -f2 | cut -d "=" -f2
    ${rc}     ${output}    Run And Return Rc And Output    ${cmd}
    ${NTA}    Evaluate     ${output} * 8
    ${NTA_string}    Convert to string     ${NTA}
    Verify PCMD Record In Collection    ${collected_records}    timingAdvanceRecord    no
    ...    initial=${NTA_string}

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
    ...    srcNgranCellId.*nrcgi.*plmn_Identity=13:41:98     srcNgranCellId.*nrcgi.*cellIdentity=00:00:08:00:10
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
    ...      ssbSubcarrierSpacing=1    dlCarrierBandwidthTdd=28    absoluteFrequencySsb=636576
    ...      initialUeRrcMessageTransferSndTime.*seconds=${initialUeRrcMessageTransferSndTime}
    ...      initialUeRrcMessageTransferSndTime.*useconds=[0-9]+
    ${ueCtxSetupReqRcvTime}     Get Message Timestamp From Pcap    filter=f1ap.UEContextSetupRequest_element    which_message=0
    ${ueCtxSetupCmplSndTime}    Get Message Timestamp From Pcap    filter=f1ap.UEContextSetupResponse_element    which_message=0
    ${ueCtxSetupRecord_pdu}      Create dictionary
    ...      record_name=ueCtxSetupRecord
    ...      result=0    gnb_cu_ue_f1ap_Id=${cu_ue_f1ap_id}[0]    gnb_du_ue_f1ap_Id=${du_ue_f1ap_id}[0]
    ...      ssbSubcarrierSpacing=1    dlCarrierBandwidthTdd=28    absoluteFrequencySsb=636576
    ...      ueCtxSetupReqRcvTime.*seconds=${ueCtxSetupReqRcvTime}
    ...      ueCtxSetupReqRcvTime.*useconds=[0-9]+
    ...      ueCtxSetupCmplSndTime.*seconds=${ueCtxSetupCmplSndTime}
    ...      ueCtxSetupCmplSndTime.*useconds=[0-9]+
    ${ueCtxSetupReqRcvTime}     Get Message Timestamp From Pcap    filter=f1ap.UEContextSetupRequest_element    which_message=1
    ${ueCtxSetupCmplSndTime}    Get Message Timestamp From Pcap    filter=f1ap.UEContextSetupResponse_element    which_message=1
    ${ueCtxSetupRecord_ho}      Create dictionary
    ...      record_name=ueCtxSetupRecord
    ...      result=0    gnb_cu_ue_f1ap_Id=${cu_ue_f1ap_id}[1]    gnb_du_ue_f1ap_Id=${du_ue_f1ap_id}[1]
    ...      ssbSubcarrierSpacing=1    dlCarrierBandwidthTdd=28    absoluteFrequencySsb=636576
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
    &{pci}    Create Dictionary    Sim=54    Ext=50
    Perform Inter-GNB Xn Handover To Target PCI    ue_id=1    target_pci=${pci}[${node_type}]    event=A3
    ...    srsrp_nr=19    nrsrp_nr=85

Prepare Ue For Inter gNB HO
    ${cmd1}    Set Variable
    ...    ue_history_information_list_add_ngran id=1 gnb_id=3 cell_type=large nrcgi=311:489|0x01 time_ue_stayed_in_cell=98
    ${cmd2}    Set Variable
    ...    ue_history_information_list_add_ngran id=1 gnb_id=2 cell_type=large nrcgi=311:489|0x01 time_ue_stayed_in_cell=97
    ${cmd3}    Set Variable    ue_history_information_list id=1 action=commit
    ${cmd4}    Set Variable    ue_enb_param id=1 ue_history_list=1
    ute_wtssim.execute_egate_command    cmd=${cmd1};${cmd2};${cmd3};${cmd4}
