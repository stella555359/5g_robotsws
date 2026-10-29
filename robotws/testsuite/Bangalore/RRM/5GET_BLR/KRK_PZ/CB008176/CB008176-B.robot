*** Settings ***
Force Tags      CRT    RAN_5G    RAN_5G_TDD    SBTS00    STATE_CONFIGURED
...             CLOUD_5G_I_LO_AP_LO      VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE

Documentation
...            author:       Mateusz Zachwieja mateusz.zachwieja@nokia.com
...            maintainer:   Mateusz Zachwieja mateusz.zachwieja@nokia.com

Resource     ./resources/common.robot
Resource         ../../resources/robot/configuration_id.robot

Suite Setup       Run Keywords
...               Add Simulated GNB to WTS Config    wts_delta=${DELTA_WTS_A3_Xn}    wts_out=${WTS_HO}
...    AND        Add UEs with location support to cfg file  wts_delta=${DELTA_WTS_LOCATION}  wts_out=${WTS_FINAL}  wts_in=${WTS_HO}
...    AND        Remove Existing Xn Link If Exists
...    AND        Testline Setup    reach_on_air=yes    wts=${WTS_FINAL}    config=${SUITE_CONFIG}
Suite Teardown    Testline Teardown

Test Setup        Test Case Setup 8176
Test Teardown     Test Case Teardown    check_radio_res=yes    oam_logs=yes

*** Variables ***
#${COMMON_KRK_RESOURCES_PATH}    ${CURDIR}/../resources/krk3_common
${COMMON_KRK_RESOURCES_PATH}    ${CURDIR}/../../resources/KRK/krk3_common
#CONFIG
@{DCAP_GNB}             condor5gSyslog
@{DCAP_BTS}             ipCapture
&{DCAP_OPTIONS}         gnb_custom_profile=${DCAP_GNB}    bts_custom_profile=${DCAP_BTS}    start=yes
&{LOGS_WITH_DCAP}       dcap=${DCAP_OPTIONS}  tcpdump_gnb=yes
&{SUITE_CONFIG}       delta=${DELTAS}    ip_addr=${IP_ADDR_SIM_GNB}
@{DELTAS}             ${DELTA_HO}    ${DELTA_CONFIG_B_DEFAULT}
@{IP_ADDR_SIM_GNB}    eth3:10.0.1.3/24    eth3:10.0.1.4/24
${DELTA_HO}           ${COMMON_KRK_RESOURCES_PATH}/configs/Delta_HO_Xn_NG_A3_A5.json
#WTS DELTAS
${DELTA_WTS_A3_Xn}       ${COMMON_KRK_RESOURCES_PATH}/configs/wts_sim_gnb_A3_XnHO.cfg
${DELTA_WTS_LOCATION}    ${CURDIR}/resources/wts_configs/wts_sim_ues_with_location_supported.cfg
${WTS_HO}                ${OUTPUT DIR}/Logs/wts_ext_and_sim_gnb.cfg
${WTS_FINAL}             ${OUTPUT DIR}/Logs/wts_ho_with_added_location_ues.cfg
#SCF DELTAS
${DELTA_CONFIG_B_DEFAULT}    ${CURDIR}/resources/delta_configs/B/delta_B_default.json
#${DELTA_HO}            ${COMMON_KRK_RESOURCES_PATH}/configs/Delta_HO_Xn_NG_A3_A5.json
&{DELTA_CONFIG_B_1}    delta=${CURDIR}/resources/delta_configs/B/delta_mdtonly_B1.json
&{DELTA_CONFIG_B_2}    delta=${CURDIR}/resources/delta_configs/B/delta_mdtonly_B2.json
&{DELTA_CONFIG_B_3}    delta=${CURDIR}/resources/delta_configs/B/delta_mdtonly_B3.json
&{DELTA_CONFIG_B_4}    delta=${CURDIR}/resources/delta_configs/B/delta_mdtonly_B4.json
&{DELTA_CONFIG_B_5}    delta=${CURDIR}/resources/delta_configs/B/delta_mdtonly_B5.json
&{DEL_NRMTRACECU_CONFIG}    delta=${CURDIR}/resources/delta_configs/common/delta_del_NRMTRACECU.json

*** Test Cases ***
#[1]CB008176_5G_B_1_Periodical_Measurements_reporting_in_ImmediateMDTOnly_Session
#    Start SA L3 Call    ue_id=${ue_mapping_SA}[first_ue_without_location]
#    ${expected_meas_config_in_rrc_reconf}    Catenate
#    ...    SEPARATOR=&&
#    ...    nr-rrc.rrcReconfiguration_element
#    ...    nr-rrc.reportType == periodical
#    ...    nr-rrc.reportInterval == ms5120
#    ...    nr-rrc.reportAmount == r4
#    Verify If Message Exists in GNB tcpdump
#    ...    filter=${expected_meas_config_in_rrc_reconf}
#    Verify SA UE Traffic Using Bearer Stats    ue_id=${ue_mapping_SA}[first_ue_without_location]    wait=30s
#    Stop SA L3 Call    ue_id=${ue_mapping_SA}[first_ue_without_location]
#    ${dcap_files}    Stop and Collect DCAP Trace    log_dir=${TEST_log_dir}/DCAP/
#    ${records}    Get MDT PCMD Records and Cell Traces from PCAP
#    ...    pcap_filepath=${dcap_files}[ipCapture][0]
#    Verify Message Count in PCAP    pcap_filepath=${dcap_files}[ipCapture][0]
#    ...    filter=nsetapx.ueMeasRecord    count=4    options=${tshark_options}
#    Verify Message Count in PCAP    pcap_filepath=${dcap_files}[ipCapture][0]
#    ...    filter=nsetapx && nr-rrc.measurementReport_element    count=4    options=${tshark_options}
#    Verify Message Count in PCAP    pcap_filepath=${TEST_tcpdump_gnb_path}
#    ...    filter=nr-rrc.measurementReport_element    count=4    options=${tshark_options}
#    Verify Sequence of cellActiveMDTUETraced
#    ...    syslog_filepath=${dcap_files}[syslog]    expected_seq=${internal_count_prints_1_UE_attach_detach}
#
#[1]CB008176_5G_B_2_Periodical_Measurements_reporting_in_ImmediateMDTOnly_Session_alternate_scenario
#    Start SA L3 Call    ue_id=${ue_mapping_SA}[first_ue_without_location]
#    ${expected_meas_config_in_rrc_reconf}    Catenate
#    ...    SEPARATOR=&&
#    ...    nr-rrc.rrcReconfiguration_element
#    ...    nr-rrc.reportType == periodical
#    ...    nr-rrc.reportInterval == ms5120
#    ...    nr-rrc.reportAmount == r4
#    Verify If Message Exists in GNB tcpdump
#    ...    filter=${expected_meas_config_in_rrc_reconf}
#    Verify SA UE Traffic Using Bearer Stats    ue_id=${ue_mapping_SA}[first_ue_without_location]    wait=30s
#    Stop SA L3 Call    ue_id=${ue_mapping_SA}[first_ue_without_location]
#    ${dcap_files}    Stop and Collect DCAP Trace    log_dir=${TEST_log_dir}/DCAP/
#    ${records}    Get MDT PCMD Records and Cell Traces from PCAP
#    ...    pcap_filepath=${dcap_files}[ipCapture][0]
#    Verify Message Count in PCAP    pcap_filepath=${dcap_files}[ipCapture][0]
#    ...    filter=nsetapx.ueMeasRecord    count=0    options=${tshark_options}
#    Verify Message Count in PCAP    pcap_filepath=${dcap_files}[ipCapture][0]
#    ...    filter=nsetapx && nr-rrc.measurementReport_element    count=4    options=${tshark_options}
#    Verify Message Count in PCAP    pcap_filepath=${TEST_tcpdump_gnb_path}
#    ...    filter=nr-rrc.measurementReport_element    count=4    options=${tshark_options}
#    Verify Sequence of cellActiveMDTUETraced
#    ...    syslog_filepath=${dcap_files}[syslog]    expected_seq=${internal_count_prints_1_UE_attach_detach}
#
#[1]CB008176_5G_B_3_Activation_of_ImmediateMDTOnly_session_with_periodic_measurements_content
#    ${interval1_start}    DateTime.Get Current Date
#    Start SA L3 Calls for 8176 B3 B4 scenario
#    ${first_UE_F1AP_ID}  ${second_UE_F1AP_ID}    Get Message Field Values from PCAP
#    ...  field_name=f1ap.GNB_CU_UE_F1AP_ID
#    ...  filter=nr-rrc.rrcSetupComplete_element
#    ...  pcap_filepath=${TEST_tcpdump_gnb_path}
#    ${expected_meas_config_in_rrc_reconf_UE1}    Catenate
#    ...    SEPARATOR=&&
#    ...    nr-rrc.rrcReconfiguration_element
#    ...    nr-rrc.reportType == periodical
#    ...    nr-rrc.reportInterval == ms5120
#    ...    nr-rrc.reportAmount == r4
#    ...    !nr-rrc.includeCommonLocationInfo_r16
#    ...    f1ap.GNB_CU_UE_F1AP_ID == ${first_UE_F1AP_ID}
#    ${expected_meas_config_in_rrc_reconf_UE2}    Catenate
#    ...    SEPARATOR=&&
#    ...    nr-rrc.rrcReconfiguration_element
#    ...    nr-rrc.reportType != periodical
#    ...    f1ap.GNB_CU_UE_F1AP_ID == ${second_UE_F1AP_ID}
#    Verify If Message Exists in GNB tcpdump
#    ...  filter=${expected_meas_config_in_rrc_reconf_UE1}
#    Verify If Message Exists in GNB tcpdump
#    ...  filter=${expected_meas_config_in_rrc_reconf_UE2}
#    Verify Message Count in PCAP    pcap_filepath=${TEST_tcpdump_gnb_path}
#    ...    filter=nr-rrc.ueCapabilityInformation_element && nr-rrc.gnss_Location_r16 == supported
#    ...    count=1    options=${tshark_options}
#    Verify SA UE Traffic Using Bearer Stats    ue_id=${ue_mapping_SA}[first_ue_with_location]    wait=20s
#    Verify SA UE Traffic Using Bearer Stats    ue_id=${ue_mapping_SA}[second_ue_without_location]
#    ${interval2_start}    DateTime.Get Current Date
#    Send NR Measurement    ue_id=${ue_mapping_SA}[second_ue_without_location]
#    Stop SA L3 Call    ue_id=${ue_mapping_SA}[second_ue_without_location]
#    Stop SA L3 Call    ue_id=${ue_mapping_SA}[first_ue_with_location]
#    Sleep    5s   reason=Wait for logs update
#    ${dcap_files}    Stop and Collect DCAP Trace    log_dir=${TEST_log_dir}/DCAP/
#    ${filter_for_timerange_1}    Catenate
#    ...    SEPARATOR=&&
#    ...    nsetapx
#    ...    (frame.time >= "${interval1_start}")
#    ...    (frame.time <= "${interval2_start}")
#    ${measurements_timerange1}    Get MDT PCMD Records and Cell Traces from PCAP
#    ...    pcap_filepath=${dcap_files}[ipCapture][0]    filter=${filter_for_timerange_1}    log_suffix=timerange1
#    ${measurements_timerange2}    Get MDT PCMD Records and Cell Traces from PCAP
#    ...    pcap_filepath=${dcap_files}[ipCapture][0]    filter=nsetapx && (frame.time >= "${interval2_start}")
#    ...    should_MDT_PCMD_be_present=${False}    should_MDT_cellTrace_be_present=${False}    log_suffix=timerange2
#    ${all_measurements}    Get MDT PCMD Records and Cell Traces from PCAP
#    ...    pcap_filepath=${dcap_files}[ipCapture][0]    log_suffix=all_measurements
#    Log To Console  MBA Verification ongoing
#    Verify Message Count in PCAP    pcap_filepath=${dcap_files}[ipCapture][0]
#    ...    filter=nsetapx.ueMeasRecord && nsetapx.traceActivationType == mba && nsetapx.triggerType == A3
#    ...    count=2    options=${tshark_options}
#    Verify Message Count in PCAP    pcap_filepath=${dcap_files}[ipCapture][0]
#    ...    filter=nsetapx.ueMeasRecord && nsetapx.traceActivationType == mba && nsetapx.triggerType == periodic
#    ...    count=4    options=${tshark_options}
#    Verify Message Count in PCAP    pcap_filepath=${dcap_files}[ipCapture][0]
#    ...    filter=nsetapx && nr-rrc.measurementReport_element && nsetapx.traceActivationType == mba    count=6
#    ...    options=${tshark_options}
#    Verify Message Count in PCAP    pcap_filepath=${dcap_files}[ipCapture][0]
#    ...    filter=nr-rrc.measurementReport_element && nsetapx && nsetapx.traceActivationType == mba
#    ...    count=6    options=${tshark_options}
#    Verify Message Count in PCAP    pcap_filepath=${dcap_files}[ipCapture][0]
#    ...    filter=nr-rrc.measurementReport_element && nsetapx && nsetapx.traceActivationType == mba && (frame.time >= "${interval2_start}")
#    ...    count=0    options=${tshark_options}
#    ${MDT_Seq_no_location}    Prepare PCMD Sequence
#    ${cell_trace_Seq_no_location}    Prepare Cell Traces Sequence
#    Verify Cell Trace Sequence in Collection    ${all_measurements}[cellTrace]    ${cell_trace_Seq_no_location}
#    Verify PCMD Records Sequence in Collection    ${all_measurements}[PCMD]    ${MDT_Seq_no_location}
#    ...    strict_fields_check=yes

[1]CB008176_5G_B_4_Activation_of_ImmediateMDTOnly_session_with_periodic_measurements_content_alternate_scenario
    Link SCOUT SCF to Configuration ID for Reporting
    ${interval1_start}    DateTime.Get Current Date
    Start SA L3 Calls for 8176 B3 B4 scenario
    ${first_UE_F1AP_ID}  ${second_UE_F1AP_ID}    Get Message Field Values from PCAP
    ...  field_name=f1ap.GNB_CU_UE_F1AP_ID
    ...  filter=nr-rrc.rrcSetupComplete_element
    ...  pcap_filepath=${TEST_tcpdump_gnb_path}
    ${expected_meas_config_in_rrc_reconf_UE1}    Catenate
    ...    SEPARATOR=&&
    ...    nr-rrc.rrcReconfiguration_element
    ...    nr-rrc.reportType == periodical
    ...    nr-rrc.reportInterval == ms5120
    ...    nr-rrc.reportAmount == r4
    ...    !nr-rrc.includeCommonLocationInfo_r16
    ...    f1ap.GNB_CU_UE_F1AP_ID == ${first_UE_F1AP_ID}
    ${expected_meas_config_in_rrc_reconf_UE2}    Catenate
    ...    SEPARATOR=&&
    ...    nr-rrc.rrcReconfiguration_element
    ...    nr-rrc.reportType != periodical
    ...    f1ap.GNB_CU_UE_F1AP_ID == ${second_UE_F1AP_ID}
    Verify If Message Exists in GNB tcpdump
    ...  filter=${expected_meas_config_in_rrc_reconf_UE1}
    Verify If Message Exists in GNB tcpdump
    ...  filter=${expected_meas_config_in_rrc_reconf_UE2}
    Verify Message Count in PCAP    pcap_filepath=${TEST_tcpdump_gnb_path}
    ...    filter=nr-rrc.ueCapabilityInformation_element && nr-rrc.gnss_Location_r16 == supported
    ...    count=1    options=${tshark_options}
    Verify SA UE Traffic Using Bearer Stats    ue_id=${ue_mapping_SA}[first_ue_with_location]    wait=20s
    Verify SA UE Traffic Using Bearer Stats    ue_id=${ue_mapping_SA}[second_ue_without_location]
    ${interval2_start}    DateTime.Get Current Date
    Send NR Measurement    ue_id=${ue_mapping_SA}[second_ue_without_location]
    Stop Subscriber Trace
    Stop SA L3 Call    ue_id=${ue_mapping_SA}[second_ue_without_location]
    Stop SA L3 Call    ue_id=${ue_mapping_SA}[first_ue_with_location]
    Sleep    5s   reason=Wait for logs update
    ${dcap_files}    Stop and Collect DCAP Trace    log_dir=${TEST_log_dir}/DCAP/
    Verify Message Count in PCAP    pcap_filepath=${dcap_files}[ipCapture][0]
    ...    filter=ngap.TraceStart_element && !nsetapx   count=1    options=${tshark_options}
    ${filter_for_mba_timerange}    Catenate
    ...    SEPARATOR=&&
    ...    nsetapx
    ...    (frame.time >= "${interval1_start}")
    ...    (frame.time <= "${interval2_start}")
    ${measurements_timerange_mba}    Get MDT PCMD Records and Cell Traces from PCAP
    ...    pcap_filepath=${dcap_files}[ipCapture][0]    filter=${filter_for_mba_timerange}    log_suffix=measurements_timerange_mba
    ${all_measurements}    Get MDT PCMD Records and Cell Traces from PCAP
    ...    pcap_filepath=${dcap_files}[ipCapture][0]    filter=nsetapx    log_suffix=all_measurements
    Log To Console  MBA Verification ongoing
    Verify Message Count in PCAP    pcap_filepath=${dcap_files}[ipCapture][0]
    ...    filter=nsetapx.ueMeasRecord && nsetapx.traceActivationType == mba && nsetapx.triggerType == A3
    ...    count=2    options=${tshark_options}
    Verify Message Count in PCAP 8176    pcap_filepath=${dcap_files}[ipCapture][0]
    ...    filter=nsetapx.ueMeasRecord && nsetapx.traceActivationType == mba && nsetapx.triggerType == periodic
    ...    count=4    options=${tshark_options}
    Verify Message Count in PCAP    pcap_filepath=${dcap_files}[ipCapture][0]
    ...    filter=nr-rrc.measurementReport_element && nsetapx && nsetapx.traceActivationType == mba && (frame.time >= "${interval2_start}")
    ...    count=0    options=${tshark_options}
    Log To Console  SBA Verification ongoing
    Verify Message Count in PCAP 8176    pcap_filepath=${dcap_files}[ipCapture][0]
    ...    filter=nsetapx && nr-rrc.measurementReport_element && nsetapx.traceActivationType == sba    count=7
    ...    options=${tshark_options}
    Verify Message Count in PCAP    pcap_filepath=${dcap_files}[ipCapture][0]
    ...    filter=nr-rrc.measurementReport_element && nsetapx && nsetapx.traceActivationType == sba && (frame.time >= "${interval2_start}")
    ...    count=1    options=${tshark_options}
    Verify Message Count in PCAP    pcap_filepath=${TEST_tcpdump_gnb_path}
    ...    filter=nr-rrc.measurementReport_element && (frame.time <= "${interval2_start}")
    ...    count=6    options=${tshark_options}
    Verify Message Count in PCAP    pcap_filepath=${TEST_tcpdump_gnb_path}
    ...    filter=nr-rrc.measurementReport_element && (frame.time >= "${interval2_start}")
    ...    count=1    options=${tshark_options}
    ${PCMD_records}    Prepare PCMD And Subscriber PCMD Sequence
    ${cell_trace_Seq_no_location}    Prepare Cell Traces And Subscriber Traces Sequence
    Verify Cell Trace Sequence in Collection    ${measurements_timerange_mba}[cellTrace]    ${cell_trace_Seq_no_location}
#    Verify PCMD Records Sequence in Collection    ${all_measurements}[PCMD]    ${PCMD_records}
#    ...    strict_fields_check=no

#
#[1]CB008176_5G_B_5_Deactivation_of_MDT_trace_session
#    ${interval_with_start}    DateTime.Get Current Date
#    Start SA L3 Call    ue_id=${ue_mapping_SA}[first_ue_without_location]
#    ${expected_meas_config_in_rrc_reconf}    Catenate
#    ...    SEPARATOR=&&
#    ...    nr-rrc.rrcReconfiguration_element
#    ...    nr-rrc.reportType == periodical
#    ...    nr-rrc.reportInterval == ms5120
#    ...    nr-rrc.reportAmount == infinity
#    Verify If Message Exists in GNB tcpdump
#    ...    filter=${expected_meas_config_in_rrc_reconf}
#    Verify SA UE Traffic Using Bearer Stats    ue_id=${ue_mapping_SA}[first_ue_without_location]    wait=20s
#    ${interval_with_stop}    DateTime.Get Current Date
#    Upload Configs    config=${DEL_NRMTRACECU_CONFIG}
#    ${interval_without_start}    DateTime.Get Current Date
#    Sleep  60s   reason=Wait for some time after deactivating session to be sure nothing will be sent
#    ${interval_without_stop}    DateTime.Get Current Date
#    ${dcap_files}    Stop and Collect DCAP Trace    log_dir=${TEST_log_dir}/DCAP/
#    Stop SA L3 Call    ue_id=${ue_mapping_SA}[first_ue_without_location]
#    ${filter_for_timerange_with_records}    Catenate
#    ...    SEPARATOR=&&
#    ...    nsetapx
#    ...    (frame.time >= "${interval_with_start}")
#    ...    (frame.time <= "${interval_without_start}")
#    ${records_with}    Get MDT PCMD Records and Cell Traces from PCAP
#    ...    pcap_filepath=${dcap_files}[ipCapture][0]    filter=${filter_for_timerange_with_records}    log_suffix=records_with
#    ${filter_for_timerange_without_records}    Catenate
#    ...    SEPARATOR=&&
#    ...    nsetapx
#    ...    (frame.time >= "${interval_without_start}")
#    ...    (frame.time <= "${interval_without_stop}")
#    ${records_without}    Get MDT PCMD Records and Cell Traces from PCAP
#    ...    pcap_filepath=${dcap_files}[ipCapture][0]    filter=${filter_for_timerange_without_records}    log_suffix=without_tce
#    ...    should_MDT_PCMD_be_present=${False}    should_MDT_cellTrace_be_present=${False}
#    ${all_records}    Get MDT PCMD Records and Cell Traces from PCAP
#    ...    pcap_filepath=${dcap_files}[ipCapture][0]    log_suffix=all_records
#    ${amount_total}    Get amount of measurements in json file  include_total=True
#    ...    file=${TEST_log_dir}/PCMD/all_records.json
#    ${amount_with}    Get amount of measurements in json file  include_total=True
#    ...    file=${TEST_log_dir}/PCMD/PCMD_records_with_tce.json
#    Should be true  ${amount_with}[total] > ${0}
#    Should be true  ${amount_total}[total] == ${amount_with}[total]
#    Verify Message Count in PCAP    pcap_filepath=${dcap_files}[ipCapture][0]
#    ...    filter=${filter_for_timerange_with_records}   count=>0   options=${tshark_options}
#    ${number_of_messages_with_tce_as_string}  Convert To String  ${amount_with}[total]
#    Verify Message Count in PCAP    pcap_filepath=${dcap_files}[ipCapture][0]
#    ...    filter=nr-rrc.measurementReport_element || nsetapx.ueMeasRecord
#    ...    count=${number_of_messages_with_tce_as_string}  options=${tshark_options}

*** Keywords ***
Prepare PCMD Sequence
    [Arguments]    ${periodic}=${periodic_MDT_record_for_SA_UE}  ${manual}=${rrmEvent_MDT_record_for_SA_UE}
    ${pos1}  Create Dictionary  &{manual}
    ${pos2}  Create Dictionary  &{periodic}
    ${pos3}  Create Dictionary  &{periodic}
    ${pos4}  Create Dictionary  &{manual}
    ${pos5}  Create Dictionary  &{periodic}
    ${pos6}  Create Dictionary  &{periodic}
    ${MDT_Seq_no_location}    Create List  ${pos1}  ${pos2}  ${pos3}  ${pos4}  ${pos5}  ${pos6}
    [Return]    ${MDT_Seq_no_location}

Prepare Cell Traces Sequence
    [Arguments]    ${periodic}=${periodic_MDT_cellTrace_no_location}  ${manual}=${rrmEvent_MDT_cellTrace_no_location}
    ${pos1}  Create Dictionary  &{manual}
    ${pos2}  Create Dictionary  &{periodic}
    ${pos3}  Create Dictionary  &{periodic}
    ${pos4}  Create Dictionary  &{manual}
    ${pos5}  Create Dictionary  &{periodic}
    ${pos6}  Create Dictionary  &{periodic}
    ${CT_Seq_no_location}    Create List  ${pos1}  ${pos2}  ${pos3}  ${pos4}  ${pos5}  ${pos6}
    [Return]    ${CT_Seq_no_location}

Prepare PCMD And Subscriber PCMD Sequence
    [Arguments]    ${periodic}=${periodic_MDT_record_for_SA_UE}  ${manual}=${rrmEvent_MDT_record_for_SA_UE}
    ${pos1_mba}  Create Dictionary  &{manual}
    ${pos1_sba}  Create Dictionary  &{manual}
    ${pos2_mba}  Create Dictionary  &{periodic}
    ${pos2_sba}  Create Dictionary  &{periodic}
    ${pos3_mba}  Create Dictionary  &{periodic}
    ${pos3_sba}  Create Dictionary  &{periodic}
    ${pos4_mba}  Create Dictionary  &{manual}
    ${pos4_sba}  Create Dictionary  &{manual}
    ${pos5_mba}  Create Dictionary  &{periodic}
    ${pos5_sba}  Create Dictionary  &{periodic}
    ${pos6_mba}  Create Dictionary  &{periodic}
    ${pos6_sba}  Create Dictionary  &{periodic}
    ${MDT_Seq_no_location}    Create List  ${pos1_mba}  ${pos1_sba}  ${pos2_mba}  ${pos2_sba}  ${pos3_mba}  ${pos3_sba}
    ...    ${pos4_mba}  ${pos4_sba}  ${pos5_mba}  ${pos5_sba}  ${pos6_mba}  ${pos6_sba}
    [Return]    ${MDT_Seq_no_location}

Prepare Cell Traces And Subscriber Traces Sequence
    [Arguments]    ${periodic}=${periodic_MDT_cellTrace_no_location}  ${manual}=${rrmEvent_MDT_cellTrace_no_location}
    ${pos1_sba}  Create Dictionary  &{manual}
    ${pos1_mba}  Create Dictionary  &{manual}
    ${pos2_sba}  Create Dictionary  &{periodic}
    ${pos2_mba}  Create Dictionary  &{periodic}
    ${pos3_sba}  Create Dictionary  &{periodic}
    ${pos3_mba}  Create Dictionary  &{periodic}
    ${pos4_sba}  Create Dictionary  &{manual}
    ${pos4_mba}  Create Dictionary  &{manual}
    ${pos5_sba}  Create Dictionary  &{periodic}
    ${pos5_mba}  Create Dictionary  &{periodic}
    ${pos6_sba}  Create Dictionary  &{periodic}
    ${pos6_mba}  Create Dictionary  &{periodic}
    ${CT_Seq_no_location}    Create List  ${pos1_sba} ${pos2_sba}   ${pos2_mba}  ${pos4_sba}  ${pos3_sba}  ${pos3_mba}
    ...    ${pos5_sba}  ${pos1_mba}  ${pos5_mba}  ${pos4_mba}  ${pos6_sba}  ${pos6_mba}
    [Return]    ${CT_Seq_no_location}


Start SA L3 Calls for 8176 B3 B4 scenario
    ${cmd}  Set Variable  set_pdu_param ue=2 pdu=2 trf_type=internal;set_pdu_param ue=11 pdu=11 trf_type=internal
    ute_wtssim.execute_egate_command    cmd=${cmd}
    ${scheduled_two_meas}    Catenate
    ...    ue_schedule_measurement_send_nr id=2 periodicity=5200ms action=DELAY_TILL_NR_RRC_RECONF meas_id=1
    ...    event=A3 srsrp_nr=50 srsrq_nr=50 phycell_id=50 nrsrp_nr=51 nrsrq_nr=51
    ...    meas_id=1 event=A3 srsrp_nr=50 srsrq_nr=50 phycell_id=50 nrsrp_nr=51 nrsrq_nr=51
    SA UE Register    ue_id=${ue_mapping_SA}[second_ue_without_location]
    SA UE Register    ue_id=${ue_mapping_SA}[first_ue_with_location]
    ${B4_TEST_NAME}  Set Variable  '[1]CB008176_5G_B_4_Activation_of_ImmediateMDTOnly_session_with_periodic_measurements_content_alternate_scenario'
    Run keyword if  '${TEST_NAME}'==${B4_TEST_NAME}  Start Subscriber Trace  ue_id=${ue_mapping_SA}[second_ue_without_location]
    ute_wtssim.execute_egate_command    cmd=${scheduled_two_meas}
    ${time}    DateTime.Get Current Date
    Set Test Variable  ${time}
    ute_wtssim.execute_egate_command    cmd=ue_pdu_session_setup ue=2 pdu=2 gw=1;ue_pdu_session_setup ue=11 pdu=11 gw=11
    Sleep    5s    reason=Wait for pdu sessions to be established for both ue before starting traffics
    Start Internal SA Downlink Traffic    ue_id=${ue_mapping_SA}[second_ue_without_location]
    Start Internal SA Uplink Traffic      ue_id=${ue_mapping_SA}[second_ue_without_location]
    Start Internal SA Downlink Traffic    ue_id=${ue_mapping_SA}[first_ue_with_location]
    Start Internal SA Uplink Traffic      ue_id=${ue_mapping_SA}[first_ue_with_location]

Get amount of measurements in json file
    [Arguments]  ${file}  ${filter}=False  ${include_total}=False
    ${json_string}    Get File        ${file}
    ${json_object}    evaluate        json.loads('''${json_string}''')    json
    ${count}          Set Variable    ${0}
    &{output}  Create Dictionary
    ${key_count}    Get Length    ${json_object}
    FOR    ${counter}    IN    @{json_object}
    ${status}    Run Keyword And Return Status
    ...    Dictionary Should Contain Key    ${counter}     ${filter}
    ${count}     Set Variable If    ${status}    ${count+1}    ${count}
    END
    Run keyword If  ${include_total}  Set To Dictionary  ${output}  count  ${count}  total  ${key_count}
    ...  ELSE  Run keyword  Set To Dictionary  ${output}  count  ${count}
    [Return]  ${output}
