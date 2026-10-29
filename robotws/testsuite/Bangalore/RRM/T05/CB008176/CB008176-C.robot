*** Settings ***
Force Tags      CRT    RAN_5G    RAN_5G_TDD    SBTS00    STATE_CONFIGURED
...             CLOUD_5G_I_LO_AP_LO      VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE

Documentation
...            author:       Kamil Deregowski kamil.deregowski@nokia.com
...            maintainer:   Kamil Deregowski kamil.deregowski@nokia.com

Resource     ${CURDIR}/resources/common.robot
#Resource     ${CURDIR}/resources/Python/configurators.robot
#Resource         ../../resources/robot/configuration_id.robot
Resource            ../resources/Keywords/configuration_id.robot
Library    ta5g_commissioning

Suite Setup       Run Keywords
...               Add Simulated GNB to WTS Config    wts_delta=${DELTA_WTS_A3_Xn}    wts_out=${WTS_HO}
...    AND        Add UEs with location support to cfg file  wts_delta=${DELTA_WTS_LOCATION}  wts_out=${WTS_FINAL}  wts_in=${WTS_HO}
...    AND        Remove Existing Xn Link If Exists
...    AND        Testline Setup    reach_on_air=yes    wts=${WTS_FINAL}    config=${SUITE_CONFIG}
Suite Teardown    Testline Teardown

Test Setup        Test Case Setup 8176
Test Teardown     Test Case Teardown    check_radio_res=yes    oam_logs=yes

*** Variables ***
@{DCAP_GNB}             condor5gSyslog
@{DCAP_BTS}             ipCapture
&{DCAP_OPTIONS}         gnb_custom_profile=${DCAP_GNB}    bts_custom_profile=${DCAP_BTS}    start=yes
&{LOGS_WITH_DCAP}       dcap=${DCAP_OPTIONS}    tcpdump_gnb=yes
@{DELTAS}               ${DELTA_HO}    ${CONFIG_PCMD}
@{IP_ADDR_SIM_GNB}      eth3:10.0.1.3/24    eth3:10.0.1.4/24
&{SUITE_CONFIG}         delta=${DELTAS}    ip_addr=${IP_ADDR_SIM_GNB}
${DELTA_HO}             ${CURDIR}/resources/delta_configs/common/DELTA_HO_8176.json
${CONFIG_PCMD}          ${CURDIR}/resources/delta_configs/C/delta_for_C_default.json
&{LOGS_WITH_PCMD}               syslog_gnb=yes    tcpdump_gnb=yes    pcmd=yes
${WTS_FINAL}                    ${OUTPUT DIR}/Logs/wts_ho_with_added_location_ues.cfg
${DELTA_WTS_LOCATION}           ${CURDIR}/resources/wts_configs/wts_sim_ues_with_location_supported.cfg
${DELTA_WTS_A3_Xn}              ${COMMON_KRK_RESOURCES_PATH}/configs/wts_sim_gnb_A3_XnHO.cfg
${COMMON_KRK_RESOURCES_PATH}    ${CURDIR}/../../resources/KRK/krk3_common
${WTS_HO}                       ${OUTPUT DIR}/Logs/wts_ext_and_sim_gnb.cfg
&{DELTA_CONFIG_C_1}             delta=${CURDIR}/resources/delta_configs/C/delta_for_C1.json
&{DELTA_CONFIG_C_2}             delta=${CURDIR}/resources/delta_configs/C/delta_for_C2.json
&{DELTA_CONFIG_C_3}             delta=${CURDIR}/resources/delta_configs/C/delta_for_C3.json
&{DELTA_CONFIG_C_4}             delta=${CURDIR}/resources/delta_configs/C/delta_for_C4.json
&{DELTA_CONFIG_C_5}             delta=${CURDIR}/resources/delta_configs/C/delta_for_C5.json
&{DELTA_CONFIG_C_6}             delta=${CURDIR}/resources/delta_configs/C/delta_for_C6.json
&{DEL_NRMTRACECU_CONFIG}        delta=${CURDIR}/resources/delta_configs/common/delta_del_NRMTRACECU.json

*** Test Cases ***
[1]CB008176_5G_C_3_Activation_of_MDT_trace_session_with_event-triggered_measurement_content
    configuration_id.Link SCOUT SCF to Configuration ID for Reporting
    Start SA L3 Call    ue_id=${ue_mapping_SA}[first_ue_without_location]
    Start SA L3 Call    ue_id=${ue_mapping_SA}[second_ue_with_location]
    ${ue1_crnti}    Get CRNTI of UE  ${ue_mapping_SA}[first_ue_without_location]
    ${ue2_crnti}    Get CRNTI of UE  ${ue_mapping_SA}[second_ue_with_location]
    ${first_UE_F1AP_ID}    ${second_UE_F1AP_ID}    Get Message Field Values from PCAP
    ...    pcap_filepath=${TEST_tcpdump_gnb_path}
    ...    field_name=f1ap.GNB_CU_UE_F1AP_ID
    ...    filter=f1ap.UEContextSetupRequest_element
    ${filter_rrmEvent_ue1}    Catenate
    ...    SEPARATOR=&&
    ...    nr-rrc.rrcReconfiguration_element
    ...    nr-rrc.reportConfigToAddModList == 2
    ...    nr-rrc.reportType != periodical
    ...    !nr-rrc.includeCommonLocationInfo_r16
    ...    f1ap.GNB_CU_UE_F1AP_ID == ${first_UE_F1AP_ID}
    ${filter_rrmEvent_ue2}    Catenate
    ...    SEPARATOR=&&
    ...    nr-rrc.rrcReconfiguration_element
    ...    nr-rrc.reportConfigToAddModList == 2
    ...    nr-rrc.reportType != periodical
    ...    !nr-rrc.includeCommonLocationInfo_r16
    ...    f1ap.GNB_CU_UE_F1AP_ID == ${second_UE_F1AP_ID}
    Verify If Message Exists in GNB tcpdump
    ...     filter=${filter_rrmEvent_ue1}
    Verify If Message Exists in GNB tcpdump
    ...     filter=${filter_rrmEvent_ue2}
    Repeat Keyword    4 times   Send NR Measurement    ue_id=${ue_mapping_SA}[first_ue_without_location]
    Repeat Keyword    4 times   Send NR Measurement    ue_id=${ue_mapping_SA}[second_ue_with_location]
    Verify SA UE Traffic Using Bearer Stats    ue_id=${ue_mapping_SA}[first_ue_without_location]    wait=5s
    Verify SA UE Traffic Using Bearer Stats    ue_id=${ue_mapping_SA}[second_ue_with_location]
    Stop SA L3 Call    ue_id=${ue_mapping_SA}[first_ue_without_location]
    Stop SA L3 Call    ue_id=${ue_mapping_SA}[second_ue_with_location]
    ${dcap_files}    Stop and Collect DCAP Trace    log_dir=${TEST_log_dir}/DCAP/
    Sleep  1s  reason=Wait for logs update
    ${MDT_traces_from_ue1}    Get MDT PCMD Records and Cell Traces from PCAP
    ...    pcap_filepath=${dcap_files}[ipCapture][0]    filter=nsetapx.crnti == ${ue1_crnti}    log_suffix=UE1
    ${PCMD_Seq}    Prepare Sequence List Of 4 Dictionaries From ${rrmEvent_MDT_record_for_SA_UE}
    ${cellTrace_Seq}    Prepare Sequence List Of 4 Dictionaries From ${rrmEvent_MDT_cellTrace_no_location}
    Verify Message Count in PCAP 8176    pcap_filepath=${dcap_files}[ipCapture][0]
    ...     filter=nsetapx.ueMeasRecord  count=8    options=${tshark_options}
    Verify Message Count in PCAP 8176    pcap_filepath=${dcap_files}[ipCapture][0]
    ...     filter=nsetapx && nr-rrc.measurementReport_element    count=8    options=${tshark_options}
    Verify Message Count in PCAP 8176    pcap_filepath=${dcap_files}[ipCapture][0]
    ...     filter=nr-rrc.measurementReport_element    count=8    options=${tshark_options}
    Verify PCMD Records Sequence in Collection
    ...     ${MDT_traces_from_ue1}[PCMD]    ${PCMD_Seq}
    Verify Cell Trace Sequence in Collection
    ...     ${MDT_traces_from_ue1}[cellTrace]    ${cellTrace_Seq}
    Verify Sequence of cellActiveMDTUETraced
    ...    syslog_filepath=${dcap_files}[syslog]    expected_seq=${internal_count_prints_1_UE_attach_detach}

#[1]CB008176_5G_C_4_Activation_of_MDT_trace_session_with_event-triggered_measurement_content_alternate_scenario
#    Start NSA L3 Call    ue_id=${ue_mapping_NSA}[first_ue_without_location]
#    ${ue1_crnti}    Get CRNTI of Last Attached NSA UE
#    Start NSA L3 Call    ue_id=${ue_mapping_NSA}[second_ue_with_location]
#    ${ue2_crnti}    Get CRNTI of Last Attached NSA UE
#    ${first_UE_F1AP_ID}    ${second_UE_F1AP_ID}    Get Message Field Values from PCAP
#    ...    pcap_filepath=${TEST_tcpdump_gnb_path}
#    ...    field_name=x2ap.SgNB_UE_X2AP_ID
#    ...    filter=x2ap.SgNBAdditionRequestAcknowledge_element
#    ${filter_rrmEvent_ue1}    Catenate
#    ...    SEPARATOR=&&
#    ...    nr-rrc.rrcReconfiguration_element
#    ...    nr-rrc.reportConfigToAddModList == 2
#    ...    nr-rrc.reportType != periodical
#    ...    !nr-rrc.includeCommonLocationInfo_r16
#    ...    x2ap.SgNB_UE_X2AP_ID == ${first_UE_F1AP_ID}
#    ${filter_rrmEvent_ue2}    Catenate
#    ...    SEPARATOR=&&
#    ...    nr-rrc.rrcReconfiguration_element
#    ...    nr-rrc.reportConfigToAddModList == 2
#    ...    nr-rrc.reportType != periodical
#    ...    !nr-rrc.includeCommonLocationInfo_r16
#    ...    x2ap.SgNB_UE_X2AP_ID == ${second_UE_F1AP_ID}
#    Verify If Message Exists in GNB tcpdump
#    ...     filter=${filter_rrmEvent_ue1}
#    Verify If Message Exists in GNB tcpdump
#    ...     filter=${filter_rrmEvent_ue2}
#    Repeat Keyword    2 times   Send NR Measurement    ue_id=${ue_mapping_NSA}[first_ue_without_location]
#    Repeat Keyword    2 times   Send NR Measurement    ue_id=${ue_mapping_NSA}[second_ue_with_location]
#    Verify NSA UE Traffic Using Bearer Stats   ue_id=${ue_mapping_NSA}[first_ue_without_location]    wait=5s
#    Verify NSA UE Traffic Using Bearer Stats    ue_id=${ue_mapping_NSA}[second_ue_with_location]
#    Stop NSA L3 Call    ue_id=${ue_mapping_NSA}[first_ue_without_location]
#    Stop NSA L3 Call    ue_id=${ue_mapping_NSA}[second_ue_with_location]
#    ${dcap_files}    Stop and Collect DCAP Trace    log_dir=${TEST_log_dir}/DCAP/
#    Sleep  1s  reason=Wait for logs update
#    Verify There Is No Sequence of cellActiveMDTUETraced    syslog_filepath=${dcap_files}[syslog]
#    Verify Message Count in PCAP    pcap_filepath=${dcap_files}[ipCapture][0]
#    ...    filter=nsetapx && !nsetapx.TraceMessage == 1  count=0    options=${tshark_options}
#
#[1]CB008176_5G_C_5_Activation_of_MDT_trace_session_with_event-triggered_measurement_content_alternate_scenario_2
#    Start NSA L3 Call    ue_id=${ue_mapping_NSA}[first_ue_with_location]
#    ${ue1_crnti}    Get CRNTI of Last Attached NSA UE
#    Start NSA L3 Call    ue_id=${ue_mapping_NSA}[second_ue_without_location]
#    ${ue2_crnti}    Get CRNTI of Last Attached NSA UE
#    ${first_UE_F1AP_ID}    ${second_UE_F1AP_ID}    Get Message Field Values from PCAP
#    ...    pcap_filepath=${TEST_tcpdump_gnb_path}
#    ...    field_name=x2ap.SgNB_UE_X2AP_ID
#    ...    filter=x2ap.SgNBAdditionRequestAcknowledge_element
#    ${filter_rrmEvent_ue1}    Catenate
#    ...    SEPARATOR=&&
#    ...    nr-rrc.rrcReconfiguration_element
#    ...    nr-rrc.reportConfigToAddModList == 2
#    ...    nr-rrc.reportType != periodical
#    ...    !nr-rrc.includeCommonLocationInfo_r16
#    ...    x2ap.SgNB_UE_X2AP_ID == ${first_UE_F1AP_ID}
#    ${filter_rrmEvent_ue2}    Catenate
#    ...    SEPARATOR=&&
#    ...    nr-rrc.rrcReconfiguration_element
#    ...    nr-rrc.reportConfigToAddModList == 2
#    ...    nr-rrc.reportType != periodical
#    ...    !nr-rrc.includeCommonLocationInfo_r16
#    ...    x2ap.SgNB_UE_X2AP_ID == ${second_UE_F1AP_ID}
#    Verify If Message Exists in GNB tcpdump
#    ...     filter=${filter_rrmEvent_ue1}
#    Verify If Message Exists in GNB tcpdump
#    ...     filter=${filter_rrmEvent_ue2}
#    Repeat Keyword    2 times   Send NR Measurement    ue_id=${ue_mapping_NSA}[first_ue_with_location]
#    Repeat Keyword    2 times   Send NR Measurement    ue_id=${ue_mapping_NSA}[second_ue_without_location]
#    Verify NSA UE Traffic Using Bearer Stats   ue_id=${ue_mapping_NSA}[first_ue_with_location]    wait=5s
#    Verify NSA UE Traffic Using Bearer Stats    ue_id=${ue_mapping_NSA}[second_ue_without_location]
#    Stop NSA L3 Call    ue_id=${ue_mapping_NSA}[first_ue_with_location]
#    Stop NSA L3 Call    ue_id=${ue_mapping_NSA}[second_ue_without_location]
#    ${dcap_files}    Stop and Collect DCAP Trace    log_dir=${TEST_log_dir}/DCAP/
#    Sleep  1s  reason=Wait for logs update
#    ${MDT_traces_from_ue1}    Get MDT PCMD Records and Cell Traces from PCAP
#    ...    pcap_filepath=${dcap_files}[ipCapture][0]    filter=nsetapx.crnti == ${ue1_crnti}    log_suffix=UE1
#    ${MDT_traces_from_ue2}    Get MDT PCMD Records and Cell Traces from PCAP
#    ...    pcap_filepath=${dcap_files}[ipCapture][0]    filter=nsetapx.crnti == ${ue2_crnti}    log_suffix=UE2
#    ${MDT_record_1}    Create Dictionary    &{rrmEvent_MDT_record_for_SA_UE}
#    ${MDT_record_2}    Create Dictionary    &{rrmEvent_MDT_record_for_SA_UE}
#    ${CT_record_1}    Create Dictionary    &{rrmEvent_MDT_cellTrace_no_location}
#    ${CT_record_2}    Create Dictionary    &{rrmEvent_MDT_cellTrace_no_location}
#    ${PCMD_Seq}    Create List    ${MDT_record_1}    ${MDT_record_2}
#    ${cellTrace_Seq}    Create List    ${CT_record_1}    ${CT_record_2}
#    Verify There Is No Sequence of cellActiveMDTUETraced    syslog_filepath=${dcap_files}[syslog]
#    Verify Message Count in PCAP    pcap_filepath=${dcap_files}[ipCapture][0]
#    ...     filter=nsetapx.ueMeasRecord && nsetapx.crnti == ${ue1_crnti}
#    ...     count=2    options=${tshark_options}
#    Verify Message Count in PCAP    pcap_filepath=${dcap_files}[ipCapture][0]
#    ...     filter=nsetapx && nr-rrc.measurementReport_element && nsetapx.crnti == ${ue1_crnti}
#    ...     count=2    options=${tshark_options}
#    Verify Message Count in PCAP    pcap_filepath=${TEST_tcpdump_gnb_path}
#    ...     filter=nr-rrc.measurementReport_element && x2ap.SgNB_UE_X2AP_ID == ${first_UE_F1AP_ID}
#    ...     count=2    options=${tshark_options}
#    Verify Message Count in PCAP    pcap_filepath=${dcap_files}[ipCapture][0]
#    ...     filter=nsetapx.ueMeasRecord && nsetapx.crnti == ${ue2_crnti}
#    ...     count=2    options=${tshark_options}
#    Verify Message Count in PCAP    pcap_filepath=${dcap_files}[ipCapture][0]
#    ...     filter=nsetapx && nr-rrc.measurementReport_element && nsetapx.crnti == ${ue2_crnti}
#    ...     count=2   options=${tshark_options}
#    Verify Message Count in PCAP    pcap_filepath=${TEST_tcpdump_gnb_path}
#    ...     filter=nr-rrc.measurementReport_element && x2ap.SgNB_UE_X2AP_ID == ${second_UE_F1AP_ID}
#    ...     count=2    options=${tshark_options}
#    Verify PCMD Records Sequence in Collection
#    ...    ${MDT_traces_from_ue1}[PCMD]    ${PCMD_Seq}
#    Verify Cell Trace Sequence in Collection
#    ...    ${MDT_traces_from_ue1}[cellTrace]    ${cellTrace_Seq}
#
#[1]CB008176_5G_C_6_Robustness_MDT_UE_selection_after_last_eligible_UE_SA_call_is_released
#    Start SA L3 Call    ue_id=${ue_mapping_SA}[first_ue_without_location]
#    Start SA L3 Call    ue_id=${ue_mapping_SA}[second_ue_without_location]
#    Start SA L3 Call    ue_id=${ue_mapping_SA}[first_ue_with_location]
#    ${ue1_crnti_first}     Get CRNTI of UE  ${ue_mapping_SA}[first_ue_without_location]
#    ${ue2_crnti_first}     Get CRNTI of UE  ${ue_mapping_SA}[second_ue_without_location]
#    ${ue3_crnti_first}     Get CRNTI of UE  ${ue_mapping_SA}[first_ue_with_location]
#    ${first_UE_F1AP_ID}    ${second_UE_F1AP_ID}    ${third_UE_F1AP_ID}    Get Message Field Values from PCAP
#    ...    pcap_filepath=${TEST_tcpdump_gnb_path}
#    ...    field_name=f1ap.GNB_CU_UE_F1AP_ID
#    ...    filter=f1ap.UEContextSetupRequest_element
#    ${filter_rrmEvent_ue1}    Catenate
#    ...    SEPARATOR=&&
#    ...    nr-rrc.rrcReconfiguration_element
#    ...    nr-rrc.reportConfigToAddModList == 2
#    ...    nr-rrc.reportType != periodical
#    ...    !nr-rrc.includeCommonLocationInfo_r16
#    ...    f1ap.GNB_CU_UE_F1AP_ID == ${first_UE_F1AP_ID}
#    ${filter_rrmEvent_ue2}    Catenate
#    ...    SEPARATOR=&&
#    ...    nr-rrc.rrcReconfiguration_element
#    ...    nr-rrc.reportConfigToAddModList == 2
#    ...    nr-rrc.reportType != periodical
#    ...    !nr-rrc.includeCommonLocationInfo_r16
#    ...    f1ap.GNB_CU_UE_F1AP_ID == ${second_UE_F1AP_ID}
#    ${filter_rrmEvent_ue3}    Catenate
#    ...    SEPARATOR=&&
#    ...    nr-rrc.rrcReconfiguration_element
#    ...    nr-rrc.reportConfigToAddModList == 2
#    ...    nr-rrc.reportType != periodical
#    ...    f1ap.GNB_CU_UE_F1AP_ID == ${third_UE_F1AP_ID}
#    Verify If Message Exists in GNB tcpdump
#    ...     filter=${filter_rrmEvent_ue1}
#    Verify If Message Exists in GNB tcpdump
#    ...     filter=${filter_rrmEvent_ue2}
#    Verify If Message Exists in GNB tcpdump
#    ...     filter=${filter_rrmEvent_ue3}
#    Repeat Keyword    2 times   Send NR Measurement    ue_id=${ue_mapping_SA}[first_ue_without_location]
#    Repeat Keyword    2 times   Send NR Measurement    ue_id=${ue_mapping_SA}[second_ue_without_location]
#    Repeat Keyword    2 times   Send NR Measurement    ue_id=${ue_mapping_SA}[first_ue_with_location]
#    Verify SA UE Traffic Using Bearer Stats    ue_id=${ue_mapping_SA}[first_ue_without_location]    wait=5s
#    Verify SA UE Traffic Using Bearer Stats    ue_id=${ue_mapping_SA}[second_ue_without_location]    wait=5s
#    Verify SA UE Traffic Using Bearer Stats    ue_id=${ue_mapping_SA}[first_ue_with_location]
#    Stop SA L3 Call    ue_id=${ue_mapping_SA}[second_ue_without_location]
#    Start SA L3 Call    ue_id=${ue_mapping_SA}[second_ue_without_location]
#    ${ue2_crnti_second}    Get CRNTI of UE  ${ue_mapping_SA}[second_ue_without_location]
#    @{UE_F1AP_ID}    Get Message Field Values from PCAP
#    ...    pcap_filepath=${TEST_tcpdump_gnb_path}
#    ...    field_name=f1ap.GNB_CU_UE_F1AP_ID
#    ...    filter=f1ap.UEContextSetupRequest_element
#    ${filter_rrmEvent_ue4}    Catenate
#    ...    SEPARATOR=&&
#    ...    nr-rrc.rrcReconfiguration_element
#    ...    nr-rrc.reportConfigToAddModList == 2
#    ...    nr-rrc.reportType != periodical
#    ...    !nr-rrc.includeCommonLocationInfo_r16
#    ...    f1ap.GNB_CU_UE_F1AP_ID == ${UE_F1AP_ID}[-1]
#    Verify If Message Exists in GNB tcpdump
#    ...     filter=${filter_rrmEvent_ue4}
#    Repeat Keyword    2 times   Send NR Measurement    ue_id=${ue_mapping_SA}[second_ue_without_location]
#    Verify SA UE Traffic Using Bearer Stats    ue_id=${ue_mapping_SA}[second_ue_without_location]
#    Stop SA L3 Call    ue_id=${ue_mapping_SA}[first_ue_without_location]
#    Stop SA L3 Call    ue_id=${ue_mapping_SA}[second_ue_without_location]
#    Stop SA L3 Call    ue_id=${ue_mapping_SA}[first_ue_with_location]
#    ${dcap_files}    Stop and Collect DCAP Trace    log_dir=${TEST_log_dir}/DCAP/
#    Sleep  1s  reason=Wait for logs update
#    Verify Sequence of cellActiveMDTUETraced
#    ...    syslog_filepath=${dcap_files}[syslog]    expected_seq=${internal_count_prints_2_UEs_attach_1_UE_detach_attach}
