*** Settings ***
Force Tags      CRT    OPTION_RELATED_ARTIFACTS_5G    SBTS00    SBTS25R1    STATE_CONFIGURED
...             CLOUD_5G_I_LO_AP_LO    VARIANT_SA+NSA_FS_ECPRI_MMWV_TDD_GMC    UPGRADE_UTF

Documentation
...            author:       Marcin Duplaga, marcin.duplaga@nokia.com
...                          Paulina Karpf Matoga, paulina.karpf_matoga@nokia.com
...                          Krystian Krakowski, krystian.krakowski@nokia.com
...            maintainer:   Marcin Duplaga, marcin.duplaga@nokia.com
...                          Paulina Karpf Matoga, paulina.karpf_matoga@nokia.com

Resource     ./resources/common.robot
Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot

Suite Setup       Run Keywords
...               Add Simulated GNB to WTS Config    wts_delta=${DELTA_WTS_A3_Xn}    wts_out=${WTS_HO}
...      AND      Modify UE Capabilities And Remove NSA Cells From WTS Config    wts_in=${WTS_HO}     wts_out=${WTS_FINAL}
...      AND      Remove Existing NradjGnb And Xn Link If Exists
...      AND      Testline Setup    reach_on_air=without_x2_link    wts=${WTS_FINAL}    config=${SUITE_CONFIG}
Suite Teardown    Testline Teardown

Test Setup        Test Case Setup    logs=${LOGS_WITH_DCAP}
Test Teardown     Run Keywords
...               Test Case Teardown
...      AND      Run Keyword And Ignore Error    setups_and_teardowns_keywords.Add Main BTS Metadata to Report

*** Variables ***
${COMMON_KRK_RESOURCES_PATH}    ${CURDIR}/../resources/krk3_common
@{DCAP_GNB}              condor5gSyslog
@{DCAP_BTS}              ipCapture
&{DCAP_OPTIONS}          gnb_custom_profile=${DCAP_GNB}    bts_custom_profile=${DCAP_BTS}    start=yes
&{LOGS_WITH_DCAP}        dcap=${DCAP_OPTIONS}    tcpdump_gnb=yes
&{SUITE_CONFIG}          delta=${DELTA_FILES}    ip_addr=${IP_ADDR_SIM_GNB}
@{IP_ADDR_SIM_GNB}       eth3:10.0.1.3/24    eth3:10.0.1.4/24
${DELTA_CONFIG_C}        ${CURDIR}/resources/delta_configs/${ENB_BRANCH}/delta_CB012207-C.json
${DELTA_WTS_A3_Xn}       ${CURDIR}/resources/wts_sim_gnb_A3_XnHO_FR2_LMF.cfg
${WTS_HO}                ${OUTPUT DIR}/Logs/wts_ext_and_sim_gnb.cfg
${WTS_FINAL}             ${OUTPUT DIR}/Logs/wts_ho_with_added_location_ue.cfg
@{DELTA_FILES}           ${DELTA_HO}    ${DELTA_CONFIG_C}
${DELTA_HO}              ${CURDIR}/resources/delta_configs/${ENB_BRANCH}/Delta_HO_Xn_NG_A3_A5_FR2.json
&{DELTA_PCMD_ENABLED}    delta=${CURDIR}/resources/delta_configs/${ENB_BRANCH}/delta_pcmd_enabled.json
&{DELTA_PCMD_DISABLED}   delta=${CURDIR}/resources/delta_configs/${ENB_BRANCH}/delta_pcmd_disabled.json
&{DEL_NRMTRACECU}        delta=${CURDIR}/resources/delta_configs/${ENB_BRANCH}/delta_del_NRMTRACECU.json

*** Test Cases ***
CB012207-C_2_CB008176_5G_D_7_Activation_of_MDT_session_with_selection_only_location_capable_Ues
    [Setup]    Run Keywords
    ...           Test Case Setup    logs=${LOGS_WITH_DCAP}    radio_res=yes
    ...    AND    Recreate Objects via Delta Commissioning    delta_file=${DELTA_PCMD_DISABLED}
    Configure Tracing Profile    pcmd=false    cellTrace=true    mdt=true    subscriberTrace=false
    Start SA L3 Call    ue_id=${ue_mapping_SA}[first_ue_with_location]
    Start SA L3 Call    ue_id=${ue_mapping_SA}[second_ue_without_location]
    ${first_UE_F1AP_ID}    ${second_UE_F1AP_ID}    Get Message Field Values from PCAP
    ...    pcap_filepath=${TEST_tcpdump_gnb_path}
    ...    field_name=f1ap.GNB_CU_UE_F1AP_ID
    ...    filter=f1ap.UEContextSetupRequest_element
    ${filter_periodical}    Catenate
    ...    SEPARATOR=&&
    ...    nr-rrc.rrcReconfiguration_element
    ...    nr-rrc.reportType == periodical
    ...    nr-rrc.reportInterval == ms5120
    ...    nr-rrc.reportAmount == r4
    ...    nr-rrc.includeCommonLocationInfo_r16 == 0
    ...    f1ap.GNB_CU_UE_F1AP_ID == ${first_UE_F1AP_ID}
    ${filter_not_periodical}    Catenate
    ...    SEPARATOR=&&
    ...    nr-rrc.rrcReconfiguration_element
    ...    nr-rrc.reportType != periodical
    ...    !nr-rrc.includeCommonLocationInfo_r16
    ...    f1ap.GNB_CU_UE_F1AP_ID == ${second_UE_F1AP_ID}
    Verify If Message Exists in GNB tcpdump
    ...    filter=${filter_periodical}
    Verify If Message Exists in GNB tcpdump
    ...    filter=${filter_not_periodical}
    Verify SA UE Traffic Using Bearer Stats    ue_id=${ue_mapping_SA}[first_ue_with_location]    wait=16s
    Verify SA UE Traffic Using Bearer Stats    ue_id=${ue_mapping_SA}[second_ue_without_location]
    ${dcap_files}    Stop and Collect DCAP Trace    log_dir=${TEST_log_dir}/DCAP/
    ${ue1_crnti}    Get CRNTI of UE  ${ue_mapping_SA}[first_ue_with_location]
    ${ue2_crnti}    Get CRNTI of UE  ${ue_mapping_SA}[second_ue_without_location]
    Stop SA L3 Call    ue_id=${ue_mapping_SA}[first_ue_with_location]
    Stop SA L3 Call    ue_id=${ue_mapping_SA}[second_ue_without_location]
    ${MDT_traces_ue1}    Get MDT PCMD Records and Cell Traces from PCAP
    ...    pcap_filepath=${dcap_files}[ipCapture][0]    filter=nsetapx.crnti == ${ue1_crnti}
    ...    should_MDT_PCMD_be_present=${False}    log_suffix=UE1
    ${MDT_traces_ue2}    Get MDT PCMD Records and Cell Traces from PCAP
    ...    pcap_filepath=${dcap_files}[ipCapture][0]    filter=nsetapx.crnti == ${ue2_crnti}    log_suffix=UE2
    ...    should_MDT_PCMD_be_present=${False}    should_MDT_cellTrace_be_present=${False}
    Verify Message Count in PCAP    pcap_filepath=${dcap_files}[ipCapture][0]
    ...    filter=!nr-rrc && !ngap && !x2ap && !xnap && nsetapx.TraceMessage == Report    count=0
    ...    options=${tshark_options}
    Verify Message Count in PCAP    pcap_filepath=${dcap_files}[ipCapture][0]
    ...    filter=!nsetapx.CuVendorExtensionRecordDataType && nsetapx && (xnap || nr-rrc || ngap || x2ap)
    ...    count=>0    options=${tshark_options}
    Log To Console  Veryfing UE with CRNTI:${ue1_crnti}
    Verify Message Count in PCAP    pcap_filepath=${dcap_files}[ipCapture][0]
    ...    filter=nsetapx && nr-rrc.measurementReport_element && nsetapx.crnti == ${ue1_crnti}    count=4
    ...    options=${tshark_options}
    Verify Message Count in PCAP    pcap_filepath=${TEST_tcpdump_gnb_path}
    ...    filter=nr-rrc.measurementReport_element && f1ap.GNB_CU_UE_F1AP_ID == ${first_UE_F1AP_ID}    count=4
    ...    options=${tshark_options}
    ${cellTrace_Seq}    Prepare Sequence List Of 4 Dictionaries From ${periodic_MDT_cellTrace_with_location}
    Verify Cell Trace Sequence in Collection      ${MDT_traces_ue1}[cellTrace]    ${cellTrace_Seq}
    Log To Console  Veryfing UE with CRNTI:${ue2_crnti}
    Verify Message Count in PCAP    pcap_filepath=${dcap_files}[ipCapture][0]
    ...    filter=nsetapx && nr-rrc.measurementReport_element && nsetapx.crnti == ${ue2_crnti}    count=0
    ...    options=${tshark_options}
    Verify Message Count in PCAP    pcap_filepath=${TEST_tcpdump_gnb_path}
    ...    filter=nr-rrc.measurementReport_element && f1ap.GNB_CU_UE_F1AP_ID == ${second_UE_F1AP_ID}    count=0
    ...    options=${tshark_options}
    Verify Sequence of cellActiveMDTUETraced
    ...    syslog_filepath=${dcap_files}[syslog]    expected_seq=${internal_count_prints_1_UE_attach_detach}
    [Teardown]    Run Keywords
    ...           Test Case Teardown
    ...    AND    Recreate Objects via Delta Commissioning    delta_file=${DELTA_PCMD_ENABLED}
    ...    AND    Run Keyword And Ignore Error    Run Keyword And Ignore Error    setups_and_teardowns_keywords.Add Main BTS Metadata to Report

CB012207-C_3_CB008340-5G-A_2_B02_XnA_TargetHO_reporting_during_Xn_based_Inter-gNB_SA_handover
    Configure Tracing Profile    pcmd=true    cellTrace=true    mdt=false    subscriberTrace=false
    Prepare Ue For Inter gNB HO
    Activate TA Testmode
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
    Verify PCMD Record In Collection    ${PCMD_records}    timingAdvanceRecord    no    initial=16
    Prepare And Verify xnHoSrcRecord In Collection              ${PCMD_records}
    Prepare And Verify xnHoTgtRecord In Collection              ${PCMD_records}
    Prepare And Verify duBearerRecord In Collection             ${duBearerRecord_after_ho}
    Prepare And Verify ueCtxSetupRecords In Collection          ${PCMD_records}
    Prepare And Verify ueDuConnectivityRecords In Collection    ${PCMD_records}

CB012207-C_6_CB008033_Inter-gNB_Xn_based_handover_TXnRELOCexec_timer_expiry
    Prepare Ue For Inter gNB HO
    Change UE Location    ue_id=1    node_id=3    cell_id=1
    Wait for Next PM Counters Interval
    Start SA L3 Call    ue_id=1
    Verify SA UE Traffic Using Bearer Stats    ue_id=1    wait=10s
    Trigger Txnreloctimerexpiry by dropping RRCreconfig message
    Run Keyword And Expect Error    NoRegexpMatch: *    Perform Handover To Ext gNB
    ute_wtssim.execute_egate_command    cmd=ue_kill id=1
    ${pm_counter_file}    Get Next XML PM Counters File
    Verify Last Counters In File
    ...    M55125C13009    1    NG_FLOW_REL_XN_HO_F1_TRG
    ...    M55163C03003    1    NG_FLOW_REL_XN_HO_F1_TRG_PMQAP
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counter_file}

CB012207-C_16_5GC000704_Unsuccessful_RRC_Admission_Control_checks_in_case_of_intra-gNB_handover
    [Setup]    Run Keywords
    ...           Test Case Setup    logs=${LOGS_WITH_DCAP}    radio_res=yes
    ...    AND    Change NIDD Parameter Online    dist=MRBTS-1/NRBTS-1/NRCELL-1    param=maxNumOfSCellAlloc    value=1
    ...    AND    Change NIDD Parameter Online    dist=MRBTS-1/NRBTS-1/NRCELL-1    param=maxNumOfRrcSA    value=1
    Prepare Ue For Inter gNB HO    ue_id=1
    Prepare Ue For Inter gNB HO    ue_id=2
    Prepare Ue For Inter gNB HO    ue_id=3
    Prepare Ue For Inter gNB HO    ue_id=4
    Change UE Location    ue_id=1    node_id=2    cell_id=1
    Change UE Location    ue_id=2    node_id=2    cell_id=2
    Change UE Location    ue_id=3    node_id=3    cell_id=1
    Change UE Location    ue_id=4    node_id=3    cell_id=1
    Start SA L3 Call    ue_id=1
    Start SA L3 Call    ue_id=2
    Start SA L3 Call    ue_id=3
    Start SA L3 Call    ue_id=4
    Wait for Next PM Counters Interval
    Perform Intra-GNB Inter-Cell Handover To Target PCI
    ...    ue_id=1    target_pci=51    event=A3    should_contain=@{EMPTY}    pass_regexp=${NONE}    timeout=1s
    ute_wtssim.execute_egate_command    cmd=gnb_xn_handover_preparation_param id=3 action=drop
    Perform Inter-GNB Xn Handover To Target PCI
    ...    ue_id=1    target_pci=52    event=A3    should_contain=@{EMPTY}    pass_regexp=XnHANDOVER_REQUEST rejected
    ute_wtssim.execute_egate_command    cmd=gnb_xn_handover_preparation_param id=3 reset
    Stop SA L3 Call    ue_id=1
    Stop SA L3 Call    ue_id=2
    Perform Intra-GNB Inter-Cell Handover To Target PCI
    ...    ue_id=4    target_pci=50    event=A3    should_contain=Unsuccessful outcome for XnAP::HandoverPreparation is received
    ...    pass_regexp=Handover canceled
    Stop SA L3 Call    ue_id=4
    Change NIDD Parameter Online    dist=MRBTS-1/NRBTS-1/NRCELL-1    param=administrativeState    value=Locked
    Perform Intra-GNB Inter-Cell Handover To Target PCI
    ...    ue_id=3    target_pci=50    event=A3    should_contain=Unsuccessful outcome for XnAP::HandoverPreparation is received
    ...    pass_regexp=Handover canceled
    Change NIDD Parameter Online    dist=MRBTS-1/NRBTS-1/NRCELL-1    param=administrativeState    value=Unlocked
    Switch HO Type To NG In Ext GNB
    Set Sim GNB To NG HO and A5 Event
    Start SA L3 Call    ue_id=1
    ute_wtssim.execute_egate_command    cmd=mobility_restriction_amf_list_param id=1 fa_plmn=311:489 forbidden_tacs=200
    ute_wtssim.execute_egate_command    cmd=amf_ue_ng_handover_request_param id=1 action=override_ie pdu=1 nwslice=none mobility_restriction_list_id=1
    Perform Intra-GNB Inter-Cell Handover To Target PCI
    ...    ue_id=3    target_pci=50    event=A3    should_contain=@{EMPTY}    pass_regexp=Handover Preparation Failure
    ute_wtssim.execute_egate_command    cmd=amf_ue_ng_handover_request_param id=1 reset
    Perform Inter-GNB NG Handover To Target PCI
    ...    ue_id=3    target_pci=50    event=A3    should_contain=@{EMPTY}    pass_regexp=Handover Preparation Failure
    ute_wtssim.execute_egate_command
    ...    cmd=amf_ue_ng_handover_param id=1 action=ho_preparation_failure cause=RN_no_radio_resources_available_in_target_cell
    Perform Inter-GNB NG Handover To Target PCI
    ...    ue_id=3    target_pci=50    event=A3    should_contain=@{EMPTY}    pass_regexp=Handover Preparation Failure
    Perform Inter-GNB NG Handover To Target PCI
    ...    ue_id=1    target_pci=52    event=A5    should_contain=@{EMPTY}    pass_regexp=Handover Preparation Failure
    Stop SA L3 Call    ue_id=3
    ute_wtssim.execute_egate_command    cmd=amf_ue_ng_handover_param id=1 reset
    ute_wtssim.execute_egate_command    cmd=amf_ue_ng_handover_param id=1 action=ho_preparation_failure cause=RN_invalid_qos_combination
    Perform Inter-GNB NG Handover To Target PCI
    ...    ue_id=1    target_pci=52    event=A5    should_contain=@{EMPTY}    pass_regexp=Handover Preparation Failure
    ute_wtssim.execute_egate_command    cmd=amf_ue_ng_handover_param id=1 action=ho_preparation_failure cause=RN_cell_not_available
    Perform Inter-GNB NG Handover To Target PCI
    ...    ue_id=1    target_pci=52    event=A5    should_contain=@{EMPTY}    pass_regexp=Handover Preparation Failure
    ute_wtssim.execute_egate_command    cmd=amf_ue_ng_handover_param id=1 reset
    ute_wtssim.execute_egate_command    cmd=amf_ue_ng_handover_request_ack_param id=1 action=ignore
    Perform Inter-GNB NG Handover To Target PCI
    ...    ue_id=1    target_pci=52    event=A5    should_contain=@{EMPTY}    pass_regexp=Sending Handover Cancel Acknowledge to GNB-2
    ute_wtssim.execute_egate_command    cmd=amf_ue_ng_handover_request_ack_param id=1 reset
    ute_wtssim.execute_egate_command    cmd=amf_ue_ctx_release_param id=1 action=override_cause cause=RN_handover_cancelled
    Perform Inter-GNB NG Handover To Target PCI
    ...    ue_id=1    target_pci=52    event=A5    should_contain=@{EMPTY}    pass_regexp=Received UE Context Release
    ute_wtssim.execute_egate_command    cmd=amf_ue_ctx_release_param id=1 reset
    Stop SA L3 Call    ue_id=1
    Change UE Location    ue_id=1    node_id=3    cell_id=1
    Change UE Location    ue_id=2    node_id=2    cell_id=1
    Start SA L3 Call    ue_id=1
    Start SA L3 Call    ue_id=2
    ute_wtssim.execute_egate_command    cmd=ue_nr_rrc_reconf_param id=1 if_contains=any action=drop
    ute_wtssim.execute_egate_command    cmd=ue_nr_rrc_reconf_param id=2 if_contains=any action=drop
    Perform Inter-GNB NG Handover To Target PCI
    ...    ue_id=2    target_pci=52    event=A5    should_contain=@{EMPTY}    pass_regexp=UE2: IS IDLE
    Stop SA L3 Call    ue_id=2
    Perform Inter-GNB NG Handover To Target PCI
    ...    ue_id=1    target_pci=50    event=A5    should_contain=@{EMPTY}    pass_regexp=T_NG_RELOC_Overall Timeout
    ute_wtssim.execute_egate_command    cmd=ue_nr_rrc_reconf_param id=1 reset;ue_nr_rrc_reconf_param id=2 reset
    Stop SA L3 Call    ue_id=1
    ${pm_counter_file}    Get Next XML PM Counters File
    Verify Last Counters In File
    ...    M55138C00006    1    SGNB_SA_RAC_REJ_DUE_TO_RRC
    ...    M55153C00003    1    FAIL_HO_NRREL_PREP
    ...    M55125C07505    1    NG_HO_RES_ALC_F_AC_TRG
    ...    M55125C07507    1    NG_HO_PREP_FAIL_RRL_SRC
    ...    M55125C07508    1    NG_HO_PREP_FAIL_BNS_SRC
    ...    M55125C07509    1    NG_HO_PREP_FAIL_CNA_SRC
    ...    M55125C07511    1    NG_HO_PREP_TIME_EXP_SRC
    ...    M55125C07515    1    NG_HO_FAIL_TIME_EXP_TRG
    ...    M55125C07516    1    NG_HO_PREP_CNC_SRC
    ...    M55125C07517    1    NG_HO_PREP_CNC_ACK_SRC
    ...    M55125C07524    1    NG_HO_EXEC_FAIL_TOT_SRC
    ...    M55125C13005    1    NG_FLOW_REL_IANR_FAIL_HO
    ...    M55163C03001    1    NG_FLOW_REL_IANR_FAIL_HO_PMQAP
    ...    M55125C07521    1    NG_HO_EXEC_TIME_EXP_SRC
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counter_file}
    Change UE Location    ue_id=3    node_id=3    cell_id=1
    Start SA L3 Call    ue_id=3
    Change NIDD Parameter Online    dist=MRBTS-1/NRBTS-1/NRCELL-1    param=maxNumOfNonGBRBearersSA    value=0
    Perform Intra-GNB Inter-Cell Handover To Target PCI
    ...    ue_id=3    target_pci=50    event=A5    should_contain=Handover Preparation Failure    pass_regexp=HANDOVER FAILURE
    Stop SA L3 Call    ue_id=3
    [Teardown]    Run Keywords
    ...           Test Case Teardown
    ...    AND    Change NIDD Parameter Online    dist=MRBTS-1/NRBTS-1/NRCELL-1    param=maxNumOfRrcSA    value=106
    ...    AND    Change NIDD Parameter Online    dist=MRBTS-1/NRBTS-1/NRCELL-1    param=maxNumOfSCellAlloc    value=106
    ...    AND    Change NIDD Parameter Online    dist=MRBTS-1/NRBTS-1/NRCELL-1    param=maxNumOfNonGBRBearersSA    value=550
    ...    AND    Switch HO Type To Xn In Ext GNB
    ...    AND    Set Sim GNB To Xn HO and A3 Event
    ...    AND    Run Keyword And Ignore Error    setups_and_teardowns_keywords.Add Main BTS Metadata to Report

CB012207-C_17_CB008699-A_inter-gNB_handover_when_QOS_to_DRB_mapping_sent_by_source_not_supported_at_target_gNB
    Change NIDD Parameter Online    dist=MRBTS-1/NRBTS-1    param=actMeasurementProfile    value=SA
    Change NIDD Parameter Online    dist=MRBTS-1/NRBTS-1    param=rrcReestabTypeSA    value=sameGNB
    Change UE Location    ue_id=1    node_id=2    cell_id=1
    Start SA L3 Call    ue_id=1
    Perform UE RRC Reestablishment    ue_id=1
    Check RRC messages count and params    event=Reconfiguration    offset_ssb_A3=2    hysteresis_A3=0    time_to_trigger_ssb_A3=ms0
    ...    threshold1_A5=7    threshold2_A5=7    hysteresis_A5=0    time_to_trigger_ssb_A5=ms40    count=1
    SA UE Deregister    ue_id=1
    Prepare Ue For Inter gNB HO
    Change UE Location    ue_id=1    node_id=3    cell_id=1
    Wait for Next PM Counters Interval
    Start SA L3 Call    ue_id=1
    Verify SA UE Traffic Using Bearer Stats    ue_id=1    wait=10s
    Modify DRB QoS To Exclude Mapping
    Perform Inter-GNB Xn Handover To Target PCI    ue_id=1    target_pci=50    event=A3
    ...    should_contain=Inter-gNB Handover is triggered    pass_regexp=Unsuccessful outcome for XnAP::HandoverPreparation is received
    Modify DRB QoS To Exclude Mapping In NG-Based HO
    Switch HO Type To NG In Ext GNB
    Set Sim GNB To NG HO and A3 Event
    Perform Inter-GNB NG Handover To Target PCI    ue_id=1    target_pci=50    event=A3
    ...    should_contain=Inter-gNB Handover is triggered    pass_regexp=Received Handover Preparation Failure from AMF
    ${pm_counter_file}    Get Next XML PM Counters File
    Verify Last Counters In File
    ...    M55125C07506    1    NG_HO_RES_ALC_F_OTH_TRG
    ...    M55143C00009    1    HO_PREP_FAIL_SENT_OTH
    ...    local_moid=MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counter_file}

CB012207-C_22_CB008281-A_B_Verification_of_cell_trace_and_PCMD_content_in_MBA_and_SBA_session_related_to_UL_NR-ECID_position_measurement_method
    Configure Tracing Profile    pcmd=true    cellTrace=true    mdt=false    subscriberTrace=true
    Change UE Location    ue_id=1    node_id=2    cell_id=1
    ${part_I}    DateTime.Get Current Date
    Start SA L3 Call    ue_id=1
    Start Subscriber Trace  ue_id=1
    Change NIDD Parameter Online    dist=MRBTS-1/NRBTS-1    param=nrEcidMeasSupervisionTimer    value=6000
    Change NIDD Parameter Online    dist=MRBTS-1/NRBTS-1/NRCELL-1    param=actUlNrEcIdPosMethod    value=true
    Trigger E-CID
    Verify SA UE Traffic Using Bearer Stats    ue_id=1    wait=10s
    Verify If Message Exists in GNB tcpdump
    ...    filter=nrppa.E_CIDMeasurementInitiationRequest_element && nrppa.ReportCharacteristics == onDemand
    Verify If Message Exists in GNB tcpdump
    ...    filter=nrppa.E_CIDMeasurementInitiationResponse_element
    Verify If Message Exists in GNB tcpdump
    ...    filter=nr-rrc.rrcReconfiguration_element && nr-rrc.reportType == periodical && nr-rrc.reportAmount == r1
    Verify If Message Exists in GNB tcpdump
    ...    filter=nr-rrc.measurementReport_element
    ${part_II}    DateTime.Get Current Date
    Change NIDD Parameter Online    dist=MRBTS-1/NRBTS-1/NRCELL-1    param=actUlNrEcIdPosMethod    value=false
    Trigger E-CID    pass_regexp=Received ECID Measurement Failure
    Verify SA UE Traffic Using Bearer Stats    ue_id=1    wait=10s
    Verify If Message Exists in GNB tcpdump
    ...    filter=nrppa.E_CIDMeasurementInitiationRequest_element && nrppa.ReportCharacteristics == onDemand && frame.time >= "${part_II}"
    Verify If Message Exists in GNB tcpdump
    ...    filter=nrppa.E_CIDMeasurementInitiationFailure_element && nrppa.radioNetwork == requested-item-not-supported
    Verify Message Count in PCAP    pcap_filepath=${TEST_tcpdump_gnb_path}    count=0
    ...    filter=nr-rrc.rrcReconfiguration_element && nr-rrc.reportType == periodical && nr-rrc.reportAmount == r1 && frame.time >= "${part_II}"
    Verify Message Count in PCAP    pcap_filepath=${TEST_tcpdump_gnb_path}    count=0
    ...    filter=nr-rrc.measurementReport_element && frame.time >= "${part_II}"
    ${part_III}    DateTime.Get Current Date
    Change NIDD Parameter Online    dist=MRBTS-1/NRBTS-1/NRCELL-1    param=actUlNrEcIdPosMethod    value=true
    Change NIDD Parameter Online    dist=MRBTS-1/NRBTS-1    param=actSubscriberTraceReport    value=false
    Trigger E-CID
    Verify SA UE Traffic Using Bearer Stats    ue_id=1    wait=10s
    Verify If Message Exists in GNB tcpdump
    ...    filter=nrppa.E_CIDMeasurementInitiationRequest_element && nrppa.ReportCharacteristics == onDemand && frame.time >= "${part_III}"
    Verify If Message Exists in GNB tcpdump
    ...    filter=nrppa.E_CIDMeasurementInitiationResponse_element && frame.time >= "${part_III}"
    Verify If Message Exists in GNB tcpdump
    ...    filter=nr-rrc.measurementReport_element && frame.time >= "${part_III}"
    ${dcap_files}    Stop and Collect DCAP Trace    log_dir=${TEST_log_dir}/DCAP/
    ${collected_PCMD_records}    Get PCMD Records from PCAP     pcap_filepath=${dcap_files}[ipCapture][0]
    ...    save_to_file=${TEST_log_dir}/PCMD/PCMD_records.json
    ${collected_ecid_traces}    Get Cell Traces from PCAP    pcap_filepath=${dcap_files}[ipCapture][0]
    ...    pattern=nrppa.E_CIDMeasurementInitiation.*    save_to_file=${TEST_log_dir}/cell_traces/ecid_traces.json
    ${collected_meas_traces}    Get Cell Traces from PCAP    pcap_filepath=${dcap_files}[ipCapture][0]
    ...    pattern=nr-rrc.measurementReport.*    save_to_file=${TEST_log_dir}/cell_traces/measurementReport_traces.json
    ${ecid_MeasRecords}    Prepare E-CID Meas Record Verification List
    ${ecid_traces}    Prepare E-CID Cell Traces And Subscriber Traces Sequence
    ${meas_traces}    Prepare Meas Cell Traces And Subscriber Traces Sequence
    Verify Message Count in PCAP    pcap_filepath=${dcap_files}[ipCapture][0]
    ...    filter=ngap.TraceStart_element && !nsetapx   count=1    options=${tshark_options}
    Verify Message Count in PCAP    pcap_filepath=${dcap_files}[ipCapture][0]
    ...    filter=nsetapx.stopRecordingSession_element && nsetapx.traceActivationType == sba && frame.time >= "${part_III}"
    ...    count=1    options=${tshark_options}
    Verify Cell Trace Sequence in Collection    ${collected_ecid_traces}    ${ecid_traces}
    Verify Cell Trace Sequence in Collection    ${collected_meas_traces}    ${meas_traces}
    Verify PCMD Records Sequence in Collection    ${collected_PCMD_records}    ${ecid_MeasRecords}    strict_fields_check=no
    Stop SA L3 Call    ue_id=1

*** Keywords ***
Temporary Workaround To Install Newest UTF Lab DCAP
    [Documentation]    Will be removed in the future, once newer DCAP is released in UTE Cloud TL
    [Arguments]    ${version}=FB2416.1
    ${installer_file}    Set Variable    utf_lab_installer.${version}.sh
    ${installer_path}    Set Variable    /home/ute/${installer_file}
    ${installer_link}    Catenate    SEPARATOR=
    ...    https://artifactory-espoo2.int.net.nokia.com/artifactory/tts-binaries-releases-local/utf_lab/releases/
    ...    ${version}/${installer_file}
    Download File with WGET    link=${installer_link}    local_path=${installer_path}
    ${ip}    Get VM External IP
    Log To Console    Installing DCAP ${version}...    no_newline=${True}
    ${result}    Run Process And Expect Success    sudo    UTE_CLOUD\=1    bash    ${installer_path}    ${ip}
    ...    msg=Error installing DCAP
    Should Match    ${result.stdout}    *SUCCESS: DCAP Basic*installed*    msg=Unsuccessful DCAP installation.
    Log to Console    Done

Configure Tracing Profile
    [Arguments]    ${pcmd}=true    ${cellTrace}=true    ${mdt}=true    ${subscriberTrace}=true
    Change NIDD Parameter Online    dist=MRBTS-1/NRBTS-1    param=actPCMDReport    value=${pcmd}
    Change NIDD Parameter Online    dist=MRBTS-1/NRBTS-1    param=actCellTraceReport    value=${cellTrace}
    Change NIDD Parameter Online    dist=MRBTS-1/NRBTS-1    param=actMDTTraceReport    value=${mdt}
    Change NIDD Parameter Online    dist=MRBTS-1/NRBTS-1    param=actSubscriberTraceReport    value=${subscriberTrace}
