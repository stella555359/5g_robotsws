*** Settings ***
Force Tags      CRT    RAN_5G    RAN_5G_TDD    SBTS00    STATE_CONFIGURED
...             CLOUD_5G_I_LO_AP_LO      VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE

Documentation
...            author:       Marcin Duplaga, marcin.duplaga@nokia.com,
...                          Mateusz Zachwieja, mateusz.zachwieja@nokia.com
...                          Mateusz Michalik, mateusz.michalik@nokia.com
...            maintainer:   Marcin Duplaga, marcin.duplaga@nokia.com

Resource     ./resources/common.robot

Suite Setup       Run Keywords      Add UEs with location support to cfg file
...    wts_delta=${DELTA_WTS_LOCATION}  wts_out=${WTS_FINAL}  wts_in=${WTS_HO}
...    AND        Remove Existing Xn Link If Exists
...    AND        Testline Setup    reach_on_air=yes    wts=${WTS_FINAL}    config=${SUITE_CONFIG}
Suite Teardown    Testline Teardown

Test Setup        Test Case Setup 8176
Test Teardown     Test Case Teardown    check_radio_res=yes    oam_logs=yes

*** Variables ***
${COMMON_KRK_RESOURCES_PATH}    ${CURDIR}/../../resources/KRK/krk3_common
@{DCAP_GNB}             condor5gSyslog
@{DCAP_BTS}             ipCapture
&{DCAP_OPTIONS}         gnb_custom_profile=${DCAP_GNB}    bts_custom_profile=${DCAP_BTS}    start=yes
&{LOGS_WITH_DCAP}       dcap=${DCAP_OPTIONS}    tcpdump_gnb=yes
@{DELTAS}               ${DELTA_HO}    ${DELTA_CONFIG_D_DEFAULT}
@{IP_ADDR_SIM_GNB}      eth3:10.0.1.3/24    eth3:10.0.1.4/24
&{SUITE_CONFIG}         delta=${DELTAS}    ip_addr=${IP_ADDR_SIM_GNB}
${DELTA_CONFIG_D_DEFAULT}   ${CURDIR}/resources/delta_configs/D/delta_D_default.json
${DELTA_HO}                 ${CURDIR}/resources/delta_configs/common/DELTA_HO_8176.json
${DELTA_WTS_A3_Xn}          ${COMMON_KRK_RESOURCES_PATH}/configs/wts_sim_gnb_A3_XnHO.cfg
${DELTA_WTS_LOCATION}       ${CURDIR}/resources/wts_configs/wts_sim_ues_with_location_supported.cfg
${WTS_HO}               /opt/wts/latest/basic_setup.cfg
${WTS_FINAL}            ${OUTPUT DIR}/Logs/wts_ho_with_added_location_ues.cfg
&{DELTA_CONFIG_D_1}     delta=${CURDIR}/resources/delta_configs/D/delta_D1_DCAP.json
&{DELTA_CONFIG_D_2}     delta=${CURDIR}/resources/delta_configs/D/delta_D2_DCAP.json
&{DELTA_CONFIG_D_3}     delta=${CURDIR}/resources/delta_configs/D/delta_D3_DCAP.json
&{DELTA_CONFIG_D_4}     delta=${CURDIR}/resources/delta_configs/D/delta_D4_DCAP.json
&{DELTA_CONFIG_D_5}     delta=${CURDIR}/resources/delta_configs/D/delta_D5_DCAP.json
&{DELTA_CONFIG_D_6}     delta=${CURDIR}/resources/delta_configs/D/delta_D6_DCAP.json
&{DELTA_CONFIG_D_7}     delta=${CURDIR}/resources/delta_configs/D/delta_D7_and_D8_DCAP.json
&{DELTA_CONFIG_D_8}     delta=${CURDIR}/resources/delta_configs/D/delta_D7_and_D8_DCAP.json
&{DELTA_CONFIG_D_9}     delta=${CURDIR}/resources/delta_configs/D/delta_D9_DCAP.json
&{DELTA_CONFIG_D_10}    delta=${CURDIR}/resources/delta_configs/D/delta_D10_DCAP.json

*** Test Cases ***
[1]CB008176_5G_D_1_Measurement_Configuration_for_NR_UE_[not_GNSS_Capable]_when_Location_info_is_requested
    Start SA L3 Call    ue_id=${ue_mapping_SA}[first_ue_without_location]
    ${tcpdump_filter}    Catenate
    ...    SEPARATOR=&&
    ...    nr-rrc.rrcReconfiguration_element
    ...    nr-rrc.reportType == eventTriggered
    ...    nr-rrc.reportType != periodical
    ...    !nr-rrc.includeCommonLocationInfo_r16
    Verify If Message Exists in GNB tcpdump
    ...    filter=${tcpdump_filter}
    Repeat Keyword    4 times   Send NR Measurement    ue_id=${ue_mapping_SA}[first_ue_without_location]
    Verify SA UE Traffic Using Bearer Stats    ue_id=${ue_mapping_SA}[first_ue_without_location]    wait=15s
    Stop SA L3 Call    ue_id=${ue_mapping_SA}[first_ue_without_location]
    ${dcap_files}    Stop and Collect DCAP Trace    log_dir=${TEST_log_dir}/DCAP/
    ${MDT_traces}    Get MDT PCMD Records and Cell Traces from PCAP    pcap_filepath=${dcap_files}[ipCapture][0]
    ${PCMD_Seq}    Prepare Sequence List Of 4 Dictionaries From ${rrmEvent_MDT_record_for_SA_UE_no_location}
    ${cellTrace_Seq}    Prepare Sequence List Of 4 Dictionaries From ${rrmEvent_MDT_cellTrace_no_location}
    Verify Message Count in PCAP    pcap_filepath=${dcap_files}[ipCapture][0]
    ...    filter=nsetapx.ueMeasRecord    count=4    options=${tshark_options}
    Verify Message Count in PCAP    pcap_filepath=${dcap_files}[ipCapture][0]
    ...    filter=nsetapx && nr-rrc.measurementReport_element    count=4    options=${tshark_options}
    Verify Message Count in PCAP    pcap_filepath=${TEST_tcpdump_gnb_path}
    ...    filter=nr-rrc.measurementReport_element && nr-rrc.measId == 1    count=4    options=${tshark_options}
    Verify PCMD Records Sequence in Collection    ${MDT_traces}[PCMD]    ${PCMD_Seq}    strict_fields_check=yes
    Verify Cell Trace Sequence in Collection      ${MDT_traces}[cellTrace]    ${cellTrace_Seq}
    Verify Sequence of cellActiveMDTUETraced
    ...    syslog_filepath=${dcap_files}[syslog]    expected_seq=${internal_count_prints_1_UE_attach_detach}

[1]CB008176_5G_D_2_Measurement_Configuration_for_NSA_UE_[not_GNSS_Capable]_when_Location_info_is_requested_alternate_scenario
    Start NSA L3 Call    ue_id=${ue_mapping_NSA}[first_ue_without_location]
    ${tcpdump_filter}    Catenate
    ...    SEPARATOR=&&
    ...    nr-rrc.rrcReconfiguration_element
    ...    nr-rrc.reportType == periodical
    ...    nr-rrc.reportInterval == ms5120
    ...    nr-rrc.reportAmount == r4
    ...    !nr-rrc.includeCommonLocationInfo_r16
    Verify If Message Exists in GNB tcpdump
    ...  filter=${tcpdump_filter}
    Verify NSA UE Traffic Using Bearer Stats    ue_id=${ue_mapping_NSA}[first_ue_without_location]     wait=16s
    Stop NSA L3 Call    ue_id=${ue_mapping_NSA}[first_ue_without_location]
    ${dcap_files}    Stop and Collect DCAP Trace    log_dir=${TEST_log_dir}/DCAP/
    ${MDT_traces}    Get MDT PCMD Records and Cell Traces from PCAP    pcap_filepath=${dcap_files}[ipCapture][0]
    ${PCMD_Seq}    Prepare Sequence List Of 4 Dictionaries From ${periodic_MDT_record_for_NSA_UE}
    ${cellTrace_Seq}    Prepare Sequence List Of 4 Dictionaries From ${periodic_MDT_cellTrace_no_location}
    Verify Message Count in PCAP    pcap_filepath=${dcap_files}[ipCapture][0]
    ...    filter=nsetapx.ueMeasRecord    count=4    options=${tshark_options}
    Verify Message Count in PCAP    pcap_filepath=${dcap_files}[ipCapture][0]
    ...    filter=nsetapx && nr-rrc.measurementReport_element    count=4    options=${tshark_options}
    Verify Message Count in PCAP    pcap_filepath=${TEST_tcpdump_gnb_path}
    ...    filter=nr-rrc.measurementReport_element    count=4    options=${tshark_options}
    Verify PCMD Records Sequence in Collection    ${MDT_traces}[PCMD]    ${PCMD_Seq}    strict_fields_check=yes
    Verify Cell Trace Sequence in Collection      ${MDT_traces}[cellTrace]    ${cellTrace_Seq}
    Verify Sequence of cellActiveMDTUETraced
    ...    syslog_filepath=${dcap_files}[syslog]    expected_seq=${internal_count_prints_1_NSA_UE_attach_detach}

[1]CB008176_5G_D_3_Configure_and_receive_Measurement_Reports_with_LocationInformation_from_NR_UE_[R16_GNSS_Capable]
    Start SA L3 Call    ue_id=${ue_mapping_SA}[first_ue_with_location]
    ${tcpdump_filter}    Catenate
    ...    SEPARATOR=&&
    ...    nr-rrc.rrcReconfiguration_element
    ...    nr-rrc.reportType == eventTriggered
    ...    nr-rrc.reportType != periodical
    ...    nr-rrc.includeCommonLocationInfo_r16 == 0
    Verify If Message Exists in GNB tcpdump
    ...  filter=${tcpdump_filter}
    Repeat Keyword    4 times   Send NR Measurement With LocationInfo    ue_id=${ue_mapping_SA}[first_ue_with_location]
    Verify SA UE Traffic Using Bearer Stats    ue_id=${ue_mapping_SA}[first_ue_with_location]    wait=15s
    Stop SA L3 Call    ue_id=${ue_mapping_SA}[first_ue_with_location]
    ${dcap_files}    Stop and Collect DCAP Trace    log_dir=${TEST_log_dir}/DCAP/
    ${MDT_traces}    Get MDT PCMD Records and Cell Traces from PCAP    pcap_filepath=${dcap_files}[ipCapture][0]
    ${PCMD_Seq}    Prepare Sequence List Of 4 Dictionaries From ${rrmEvent_MDT_record_for_SA_UE}
    ${cellTrace_Seq}    Prepare Sequence List Of 4 Dictionaries From ${rrmEvent_MDT_cellTrace_with_location}
    Verify Message Count in PCAP    pcap_filepath=${dcap_files}[ipCapture][0]
    ...    filter=nsetapx.ueMeasRecord    count=4    options=${tshark_options}
    Verify Message Count in PCAP    pcap_filepath=${dcap_files}[ipCapture][0]
    ...    filter=nsetapx && nr-rrc.measurementReport_element    count=4    options=${tshark_options}
    Verify Message Count in PCAP    pcap_filepath=${TEST_tcpdump_gnb_path}
    ...    filter=nr-rrc.measurementReport_element    count=4    options=${tshark_options}
    Verify PCMD Records Sequence in Collection    ${MDT_traces}[PCMD]    ${PCMD_Seq}    strict_fields_check=yes
    Verify Cell Trace Sequence in Collection      ${MDT_traces}[cellTrace]    ${cellTrace_Seq}
    Verify Sequence of cellActiveMDTUETraced
    ...    syslog_filepath=${dcap_files}[syslog]    expected_seq=${internal_count_prints_1_UE_attach_detach}

[1]CB008176_5G_D_4_Configure_and_receive_Measurement_Reports_with_LocationInformation_from_NR_UE_[R16_GNSS_Capable]_alternate_scenario
    Start SA L3 Call    ue_id=${ue_mapping_SA}[first_ue_with_location]
    ${tcpdump_filter}    Catenate
    ...    SEPARATOR=&&
    ...    nr-rrc.rrcReconfiguration_element
    ...    nr-rrc.reportType == periodical
    ...    nr-rrc.reportInterval == ms5120
    ...    nr-rrc.reportAmount == r4
    ...    nr-rrc.includeCommonLocationInfo_r16 == 0
    Verify If Message Exists in GNB tcpdump
    ...  filter=${tcpdump_filter}
    Verify SA UE Traffic Using Bearer Stats    ue_id=${ue_mapping_SA}[first_ue_with_location]    wait=15s
    Stop SA L3 Call    ue_id=${ue_mapping_SA}[first_ue_with_location]
    ${dcap_files}    Stop and Collect DCAP Trace    log_dir=${TEST_log_dir}/DCAP/
    ${MDT_traces}    Get MDT PCMD Records and Cell Traces from PCAP    pcap_filepath=${dcap_files}[ipCapture][0]
    ${PCMD_Seq}    Prepare Sequence List Of 4 Dictionaries From ${periodic_MDT_record_for_SA_UE}
    ${cellTrace_Seq}    Prepare Sequence List Of 4 Dictionaries From ${periodic_MDT_cellTrace_with_location}
    Verify Message Count in PCAP    pcap_filepath=${dcap_files}[ipCapture][0]
    ...    filter=nsetapx.ueMeasRecord    count=4    options=${tshark_options}
    Verify Message Count in PCAP    pcap_filepath=${dcap_files}[ipCapture][0]
    ...    filter=nsetapx && nr-rrc.measurementReport_element    count=4    options=${tshark_options}
    Verify Message Count in PCAP    pcap_filepath=${TEST_tcpdump_gnb_path}
    ...    filter=nr-rrc.measurementReport_element    count=4    options=${tshark_options}
    Verify PCMD Records Sequence in Collection    ${MDT_traces}[PCMD]    ${PCMD_Seq}    strict_fields_check=yes
    Verify Cell Trace Sequence in Collection      ${MDT_traces}[cellTrace]    ${cellTrace_Seq}
    Verify Sequence of cellActiveMDTUETraced
    ...    syslog_filepath=${dcap_files}[syslog]    expected_seq=${internal_count_prints_1_UE_attach_detach}

[1]CB008176_5G_D_5_Activation_of_MDT_session_with_location_information_required
    Start SA L3 Call    ue_id=${ue_mapping_SA}[first_ue_with_location]
    Start SA L3 Call    ue_id=${ue_mapping_SA}[second_ue_without_location]
    ${ue1_crnti}    Get CRNTI of UE  ${ue_mapping_SA}[first_ue_with_location]
    ${ue2_crnti}    Get CRNTI of UE  ${ue_mapping_SA}[second_ue_without_location]
    ${first_UE_F1AP_ID}    ${second_UE_F1AP_ID}    Get Message Field Values from PCAP
    ...    pcap_filepath=${TEST_tcpdump_gnb_path}
    ...    field_name=f1ap.GNB_CU_UE_F1AP_ID
    ...    filter=f1ap.UEContextSetupRequest_element
    ${filter_periodical_first_ue}    Catenate
    ...    SEPARATOR=&&
    ...    nr-rrc.rrcReconfiguration_element
    ...    nr-rrc.reportType == periodical
    ...    nr-rrc.reportInterval == ms5120
    ...    nr-rrc.reportAmount == r4
    ...    nr-rrc.includeCommonLocationInfo_r16 == 0
    ...    f1ap.GNB_CU_UE_F1AP_ID == ${first_UE_F1AP_ID}
    ${filter_periodical_second_ue}   Catenate
    ...    SEPARATOR=&&
    ...    nr-rrc.rrcReconfiguration_element
    ...    nr-rrc.reportType == periodical
    ...    nr-rrc.reportInterval == ms5120
    ...    nr-rrc.reportAmount == r4
    ...    !nr-rrc.includeCommonLocationInfo_r16
    ...    f1ap.GNB_CU_UE_F1AP_ID == ${second_UE_F1AP_ID}
    Verify If Message Exists in GNB tcpdump
    ...    filter=${filter_periodical_first_ue}
    Verify If Message Exists in GNB tcpdump
    ...    filter=${filter_periodical_second_ue}
    Verify SA UE Traffic Using Bearer Stats    ue_id=${ue_mapping_SA}[first_ue_with_location]    wait=16s
    Verify SA UE Traffic Using Bearer Stats    ue_id=${ue_mapping_SA}[second_ue_without_location]
    Stop SA L3 Call    ue_id=${ue_mapping_SA}[first_ue_with_location]
    Stop SA L3 Call    ue_id=${ue_mapping_SA}[second_ue_without_location]
    ${dcap_files}    Stop and Collect DCAP Trace    log_dir=${TEST_log_dir}/DCAP/
    ${MDT_traces_ue1}    Get MDT PCMD Records and Cell Traces from PCAP
    ...    pcap_filepath=${dcap_files}[ipCapture][0]    filter=nsetapx.crnti == ${ue1_crnti}
    ...    should_MDT_PCMD_be_present=${False}    log_suffix=UE1
    ${MDT_traces_ue2}    Get MDT PCMD Records and Cell Traces from PCAP
    ...    pcap_filepath=${dcap_files}[ipCapture][0]    filter=nsetapx.crnti == ${ue2_crnti}
    ...    should_MDT_PCMD_be_present=${False}    log_suffix=UE2
    Verify Message Count in PCAP    pcap_filepath=${dcap_files}[ipCapture][0]
    ...    filter=!nr-rrc && !ngap && !x2ap && !xnap && nsetapx.TraceMessage == Report    count=0
    ...    options=${tshark_options}
    Verify Message Count in PCAP    pcap_filepath=${dcap_files}[ipCapture][0]
    ...    filter=nsetapx && nr-rrc.measurementReport_element && nsetapx.crnti == ${ue1_crnti}    count=4
    ...    options=${tshark_options}
    Verify Message Count in PCAP    pcap_filepath=${dcap_files}[ipCapture][0]
    ...    filter=nsetapx && nr-rrc.measurementReport_element && nsetapx.crnti == ${ue2_crnti}    count=4
    ...    options=${tshark_options}
    Verify Message Count in PCAP    pcap_filepath=${TEST_tcpdump_gnb_path}
    ...    filter=nr-rrc.measurementReport_element && f1ap.GNB_CU_UE_F1AP_ID == ${first_UE_F1AP_ID}    count=4
    ...    options=${tshark_options}
    Verify Message Count in PCAP    pcap_filepath=${TEST_tcpdump_gnb_path}
    ...    filter=nr-rrc.measurementReport_element && f1ap.GNB_CU_UE_F1AP_ID != ${first_UE_F1AP_ID}    count=4
    ...    options=${tshark_options}
    ${cellTrace_Seq_UE1}    Prepare Sequence List Of 4 Dictionaries From ${periodic_MDT_cellTrace_with_location}
    ${cellTrace_Seq_UE2}    Prepare Sequence List Of 4 Dictionaries From ${periodic_MDT_cellTrace_no_location}
    Verify Cell Trace Sequence in Collection      ${MDT_traces_ue1}[cellTrace]    ${cellTrace_Seq_UE1}
    Verify Cell Trace Sequence in Collection      ${MDT_traces_ue2}[cellTrace]    ${cellTrace_Seq_UE2}
    Verify Sequence of cellActiveMDTUETraced
    ...    syslog_filepath=${dcap_files}[syslog]    expected_seq=${internal_count_prints_2_UEs_attach_detach}

CB008176_5G_D_6_Activation_of_MDT_session_with_location_information_required_alternate_scenario
    Start NSA L3 Call    ue_id=${ue_mapping_NSA}[first_ue_without_location]
    Start NSA L3 Call    ue_id=${ue_mapping_NSA}[second_ue_without_location]
    Verify If Message Exists in GNB tcpdump
    ...  filter=nr-rrc.rrcReconfiguration_element && nr-rrc.reportType == eventTriggered && x2ap.SgNB_UE_X2AP_ID == 0
    Verify If Message Exists in GNB tcpdump
    ...  filter=nr-rrc.rrcReconfiguration_element && nr-rrc.reportType == eventTriggered && x2ap.SgNB_UE_X2AP_ID != 0
    Repeat Keyword    2 times   Send NR Measurement    ue_id=${ue_mapping_NSA}[first_ue_without_location]
    Repeat Keyword    2 times   Send NR Measurement    ue_id=${ue_mapping_NSA}[second_ue_without_location]
    Verify NSA UE Traffic Using Bearer Stats   ue_id=${ue_mapping_NSA}[first_ue_without_location]    wait=5s
    Verify NSA UE Traffic Using Bearer Stats    ue_id=${ue_mapping_NSA}[second_ue_without_location]
    Stop NSA L3 Call    ue_id=${ue_mapping_NSA}[first_ue_without_location]
    Stop NSA L3 Call    ue_id=${ue_mapping_NSA}[second_ue_without_location]
    ${dcap_files}    Stop and Collect DCAP Trace    log_dir=${TEST_log_dir}/DCAP/
    Verify Message Count in PCAP    pcap_filepath=${dcap_files}[ipCapture][0]
    ...    filter=nsetapx.ueMeasRecord    count=0    options=${tshark_options}
    Verify Message Count in PCAP    pcap_filepath=${dcap_files}[ipCapture][0]
    ...    filter=nsetapx && nr-rrc.measurementReport_element    count=4    options=${tshark_options}
    Verify Message Count in PCAP    pcap_filepath=${TEST_tcpdump_gnb_path}
    ...    filter=nr-rrc.measurementReport_element    count=4    options=${tshark_options}
    Verify There Is No Sequence of cellActiveMDTUETraced    syslog_filepath=${dcap_files}[syslog]

[1]CB008176_5G_D_7_Activation_of_MDT_session_with_selection_only_location_capable_UEs
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

[1]CB008176_5G_D_8_Activation_of_MDT_session_with_selection_only_location_capable_UEs_alternate_scenario
    Start NSA L3 Call    ue_id=${ue_mapping_NSA}[first_ue_without_location]
    ${ue11_crnti}    Get CRNTI of Last Attached NSA UE
    Start NSA L3 Call    ue_id=${ue_mapping_NSA}[second_ue_without_location]
    ${ue12_crnti}    Get CRNTI of Last Attached NSA UE
    ${UE11_X2_ID}    ${UE12_X2_ID}    Get Message Field Values from PCAP    pcap_filepath=${TEST_tcpdump_gnb_path}
    ...    field_name=x2ap.SgNB_UE_X2AP_ID
    ...    filter=x2ap.SgNBAdditionRequestAcknowledge_element
    ${filter_not_periodical_UE11}    Catenate
    ...    SEPARATOR=&&
    ...    nr-rrc.rrcReconfiguration_element
    ...    nr-rrc.reportType != periodical
    ...    !nr-rrc.includeCommonLocationInfo_r16
    ...    x2ap.SgNB_UE_X2AP_ID == ${UE11_X2_ID}
    ${filter_not_periodical_UE12}    Catenate
    ...    SEPARATOR=&&
    ...    nr-rrc.rrcReconfiguration_element
    ...    nr-rrc.reportType != periodical
    ...    !nr-rrc.includeCommonLocationInfo_r16
    ...    x2ap.SgNB_UE_X2AP_ID == ${UE12_X2_ID}
    Verify If Message Exists in GNB tcpdump
    ...    filter=${filter_not_periodical_UE11}
    Verify If Message Exists in GNB tcpdump
    ...    filter=${filter_not_periodical_UE12}
    Verify NSA UE Traffic Using Bearer Stats    ue_id=${ue_mapping_NSA}[first_ue_without_location]     wait=16s
    Verify NSA UE Traffic Using Bearer Stats    ue_id=${ue_mapping_NSA}[second_ue_without_location]
    Stop NSA L3 Call    ue_id=${ue_mapping_NSA}[first_ue_without_location]
    Stop NSA L3 Call    ue_id=${ue_mapping_NSA}[second_ue_without_location]
    ${dcap_files}    Stop and Collect DCAP Trace    log_dir=${TEST_log_dir}/DCAP/
    ${MDT_traces_ue11}    Get MDT PCMD Records and Cell Traces from PCAP
    ...    pcap_filepath=${dcap_files}[ipCapture][0]    filter=nsetapx.crnti == ${ue11_crnti}    log_suffix=UE11
    ...    should_MDT_PCMD_be_present=${False}    should_MDT_cellTrace_be_present=${False}
    ${MDT_traces_ue12}    Get MDT PCMD Records and Cell Traces from PCAP
    ...    pcap_filepath=${dcap_files}[ipCapture][0]    filter=nsetapx.crnti == ${ue12_crnti}    log_suffix=UE12
    ...    should_MDT_PCMD_be_present=${False}    should_MDT_cellTrace_be_present=${False}
    Verify Message Count in PCAP    pcap_filepath=${dcap_files}[ipCapture][0]
    ...    filter=!nr-rrc && !ngap && !x2ap && !xnap && nsetapx.TraceMessage == Report    count=0    options=${tshark_options}
    Verify Message Count in PCAP    pcap_filepath=${dcap_files}[ipCapture][0]
    ...    filter=!nsetapx.CuVendorExtensionRecordDataType && nsetapx && (xnap || nr-rrc || ngap || x2ap)
    ...    count=>0    options=${tshark_options}
    Verify Message Count in PCAP    pcap_filepath=${dcap_files}[ipCapture][0]
    ...    filter=nsetapx && nr-rrc.measurementReport_element    count=0    options=${tshark_options}
    Verify Message Count in PCAP    pcap_filepath=${TEST_tcpdump_gnb_path}
    ...    filter=nr-rrc.measurementReport_element    count=0    options=${tshark_options}
    Verify There Is No Sequence of cellActiveMDTUETraced    syslog_filepath=${dcap_files}[syslog]

[1]CB008176_5G_D_9_Robustness_periodic_MDT_measurement_configuration_during_RRC_re-establishment_with_selection_only_location_capable_Ues
    Start SA L3 Call    ue_id=${ue_mapping_SA}[first_ue_with_location]
    Start SA L3 Call    ue_id=${ue_mapping_SA}[first_ue_without_location]
    ${ue_with_location_crnti}       Get CRNTI of UE  ${ue_mapping_SA}[first_ue_with_location]
    ${ue_without_location_crnti}    Get CRNTI of UE  ${ue_mapping_SA}[first_ue_without_location]
    ${first_UE_F1AP_ID}    ${second_UE_F1AP_ID}    Get Message Field Values from PCAP
    ...    pcap_filepath=${TEST_tcpdump_gnb_path}
    ...    field_name=f1ap.GNB_CU_UE_F1AP_ID
    ...    filter=f1ap.UEContextSetupRequest_element
    ${filter_periodical_first_ue}    Catenate
    ...    SEPARATOR=&&
    ...    nr-rrc.rrcReconfiguration_element
    ...    nr-rrc.reportType == periodical
    ...    nr-rrc.reportInterval == ms5120
    ...    nr-rrc.reportAmount == r4
    ...    nr-rrc.includeCommonLocationInfo_r16 == 0
    ...    f1ap.GNB_CU_UE_F1AP_ID == ${first_UE_F1AP_ID}
    ${filter_note_periodical_second_ue}    Catenate
    ...    SEPARATOR=&&
    ...    nr-rrc.rrcReconfiguration_element
    ...    nr-rrc.reportType != periodical
    ...    f1ap.GNB_CU_UE_F1AP_ID == ${second_UE_F1AP_ID}
    Verify If Message Exists in GNB tcpdump
    ...  filter=${filter_periodical_first_ue}
    Verify If Message Exists in GNB tcpdump
    ...  filter=${filter_note_periodical_second_ue}
    Verify SA UE Traffic Using Bearer Stats    ue_id=${ue_mapping_SA}[first_ue_with_location]    wait=15s
    Verify SA UE Traffic Using Bearer Stats    ue_id=${ue_mapping_SA}[first_ue_without_location]
    ${reestab_timestamp}    DateTime.Get Current Date
    Perform UE RRC Reestablishment    ue_id=${ue_mapping_SA}[first_ue_with_location]       cause=otherFailure
    Perform UE RRC Reestablishment    ue_id=${ue_mapping_SA}[first_ue_without_location]    cause=otherFailure
    ${ue_with_location_crnti_reestablished}       Get CRNTI of UE  ${ue_mapping_SA}[first_ue_with_location]
    ${ue_without_location_crnti_reestab}    Get CRNTI of UE  ${ue_mapping_SA}[first_ue_without_location]
    Verify If Message Exists in GNB tcpdump
    ...  filter=${filter_periodical_first_ue}
    Verify If Message Exists in GNB tcpdump
    ...  filter=${filter_note_periodical_second_ue}
    Verify SA UE Traffic Using Bearer Stats    ue_id=${ue_mapping_SA}[first_ue_with_location]    wait=15s
    Verify SA UE Traffic Using Bearer Stats    ue_id=${ue_mapping_SA}[first_ue_without_location]
    Stop SA L3 Call    ue_id=${ue_mapping_SA}[first_ue_with_location]
    Stop SA L3 Call    ue_id=${ue_mapping_SA}[first_ue_without_location]
    ${dcap_files}    Stop and Collect DCAP Trace    log_dir=${TEST_log_dir}/DCAP/
    ${MDT_traces_before_reestab_for_ue_with_location}    Get MDT PCMD Records and Cell Traces from PCAP
    ...    pcap_filepath=${dcap_files}[ipCapture][0]
    ...    filter=nsetapx.crnti == ${ue_with_location_crnti} && (frame.time <= "${reestab_timestamp}")
    ...    log_suffix=UE_with_location_before_reestab
    ${MDT_traces_after_reestab_for_ue_with_location}    Get MDT PCMD Records and Cell Traces from PCAP
    ...    pcap_filepath=${dcap_files}[ipCapture][0]
    ...    filter=nsetapx.crnti == ${ue_with_location_crnti_reestablished} && (frame.time >= "${reestab_timestamp}")
    ...    log_suffix=UE_with_location_after_reestab
    ${MDT_traces_ue_without_location}    Get MDT PCMD Records and Cell Traces from PCAP
    ...    pcap_filepath=${dcap_files}[ipCapture][0]
    ...    filter=nsetapx.crnti == ${ue_without_location_crnti} || nsetapx.crnti == ${ue_without_location_crnti_reestab}
    ...    log_suffix=UE_without_location
    ...    should_MDT_PCMD_be_present=${False}    should_MDT_cellTrace_be_present=${False}
    Verify Message Count in PCAP    pcap_filepath=${dcap_files}[ipCapture][0]
    ...    filter=nsetapx.ueMeasRecord    count=8    options=${tshark_options}
    Verify Message Count in PCAP    pcap_filepath=${dcap_files}[ipCapture][0]
    ...    filter=nsetapx && nr-rrc.measurementReport_element    count=8    options=${tshark_options}
    Verify Message Count in PCAP    pcap_filepath=${TEST_tcpdump_gnb_path}
    ...    filter=nr-rrc.measurementReport_element    count=8    options=${tshark_options}
    ${ipcapture_filter_without_location_rrc_meas_report}    Catenate
    ...    SEPARATOR=&&
    ...    nsetapx
    ...    nr-rrc.measurementReport_element
    ...    (nsetapx.crnti == ${ue_without_location_crnti} || nsetapx.crnti == ${ue_without_location_crnti_reestab})
    Verify Message Count in PCAP    pcap_filepath=${dcap_files}[ipCapture][0]
    ...    filter=${ipcapture_filter_without_location_rrc_meas_report}
    ...    count=0    options=${tshark_options}
    Verify Message Count in PCAP    pcap_filepath=${TEST_tcpdump_gnb_path}
    ...    filter=nr-rrc.measurementReport_element && f1ap.GNB_CU_UE_F1AP_ID != 0    count=0   options=${tshark_options}
    ${PCMD_Seq_before_reestab}    Prepare Sequence List Of 4 Dictionaries From ${periodic_MDT_record_for_SA_UE}
    ${cellTrace_Seq_before_reestab}    Prepare Sequence List Of 4 Dictionaries From ${periodic_MDT_cellTrace_with_location}
    ${PCMD_Seq_after_reestab}    Prepare Sequence List Of 4 Dictionaries From ${periodic_MDT_record_for_SA_UE}
    ${cellTrace_Seq_after_reestab}    Prepare Sequence List Of 4 Dictionaries From ${periodic_MDT_cellTrace_with_location}
    Verify PCMD Records Sequence in Collection
    ...    ${MDT_traces_before_reestab_for_ue_with_location}[PCMD]    ${PCMD_Seq_before_reestab}    strict_fields_check=yes
    Verify Cell Trace Sequence in Collection
    ...    ${MDT_traces_before_reestab_for_ue_with_location}[cellTrace]    ${cellTrace_Seq_before_reestab}
    Verify PCMD Records Sequence in Collection
    ...    ${MDT_traces_after_reestab_for_ue_with_location}[PCMD]     ${PCMD_Seq_after_reestab}    strict_fields_check=yes
    Verify Cell Trace Sequence in Collection
    ...    ${MDT_traces_after_reestab_for_ue_with_location}[cellTrace]     ${cellTrace_Seq_after_reestab}
    Verify Sequence of cellActiveMDTUETraced
    ...    syslog_filepath=${dcap_files}[syslog]    expected_seq=${internal_count_prints_1_UE_attach_detach_twice}

[1]CB008176_5G_D_10_Robustness_event_triggered_MDT_measurement_configuration_during_RRC_re-establishment_with_selection_only_location_capable_UE
    Start SA L3 Call    ue_id=${ue_mapping_SA}[first_ue_with_location]
    Start SA L3 Call    ue_id=${ue_mapping_SA}[first_ue_without_location]
    ${ue_with_location_crnti}       Get CRNTI of UE  ${ue_mapping_SA}[first_ue_with_location]
    ${ue_without_location_crnti}    Get CRNTI of UE  ${ue_mapping_SA}[first_ue_without_location]
    ${first_UE_F1AP_ID}    ${second_UE_F1AP_ID}    Get Message Field Values from PCAP
    ...    pcap_filepath=${TEST_tcpdump_gnb_path}
    ...    field_name=f1ap.GNB_CU_UE_F1AP_ID
    ...    filter=f1ap.UEContextSetupRequest_element
    ${filter_event_triggered_with_location}    Catenate
    ...    SEPARATOR=&&
    ...    nr-rrc.rrcReconfiguration_element
    ...    nr-rrc.reportType == eventTriggered
    ...    nr-rrc.includeCommonLocationInfo_r16 == 0
    ...    f1ap.GNB_CU_UE_F1AP_ID == ${first_UE_F1AP_ID}
    ${filter_event_triggered_without_location}    Catenate
    ...    SEPARATOR=&&
    ...    nr-rrc.rrcReconfiguration_element
    ...    nr-rrc.reportType == eventTriggered
    ...    !nr-rrc.includeCommonLocationInfo_r16
    ...    f1ap.GNB_CU_UE_F1AP_ID == ${second_UE_F1AP_ID}
    Verify If Message Exists in GNB tcpdump
    ...  filter=${filter_event_triggered_with_location}
    Verify If Message Exists in GNB tcpdump
    ...  filter=${filter_event_triggered_without_location}
    Repeat Keyword    4 times   Send NR Measurement With LocationInfo    ue_id=${ue_mapping_SA}[first_ue_with_location]
    Repeat Keyword    2 times   Send NR Measurement    ue_id=${ue_mapping_SA}[first_ue_without_location]
    Verify SA UE Traffic Using Bearer Stats    ue_id=${ue_mapping_SA}[first_ue_with_location]    wait=5s
    Verify SA UE Traffic Using Bearer Stats    ue_id=${ue_mapping_SA}[first_ue_without_location]
    ${reestab_timestamp}    DateTime.Get Current Date
    Perform UE RRC Reestablishment    ue_id=${ue_mapping_SA}[first_ue_with_location]       cause=otherFailure
    Perform UE RRC Reestablishment    ue_id=${ue_mapping_SA}[first_ue_without_location]    cause=otherFailure
    ${ue_with_location_crnti_reestablished}       Get CRNTI of UE  ${ue_mapping_SA}[first_ue_with_location]
    ${ue_without_location_crnti_reestab}    Get CRNTI of UE  ${ue_mapping_SA}[first_ue_without_location]
    Verify If Message Exists in GNB tcpdump
    ...  filter=${filter_event_triggered_with_location}
    Verify If Message Exists in GNB tcpdump
    ...  filter=${filter_event_triggered_without_location}
    Repeat Keyword    4 times   Send NR Measurement With LocationInfo    ue_id=${ue_mapping_SA}[first_ue_with_location]
    Repeat Keyword    2 times   Send NR Measurement    ue_id=${ue_mapping_SA}[first_ue_without_location]
    Verify SA UE Traffic Using Bearer Stats    ue_id=${ue_mapping_SA}[first_ue_with_location]    wait=5s
    Verify SA UE Traffic Using Bearer Stats    ue_id=${ue_mapping_SA}[first_ue_without_location]
    Stop SA L3 Call    ue_id=${ue_mapping_SA}[first_ue_with_location]
    Stop SA L3 Call    ue_id=${ue_mapping_SA}[first_ue_without_location]
    ${dcap_files}    Stop and Collect DCAP Trace    log_dir=${TEST_log_dir}/DCAP/
    ${MDT_traces_before_reestab_for_ue_with_location}    Get MDT PCMD Records and Cell Traces from PCAP
    ...    pcap_filepath=${dcap_files}[ipCapture][0]
    ...    filter=nsetapx.crnti == ${ue_with_location_crnti} && (frame.time <= "${reestab_timestamp}")
    ...    log_suffix=UE_with_location_before_reestab
    ${MDT_traces_after_reestab_for_ue_with_location}    Get MDT PCMD Records and Cell Traces from PCAP
    ...    pcap_filepath=${dcap_files}[ipCapture][0]
    ...    filter=nsetapx.crnti == ${ue_with_location_crnti_reestablished} && (frame.time >= "${reestab_timestamp}")
    ...    log_suffix=UE_with_location_after_reestab
    ${MDT_traces_ue_without_location}    Get MDT PCMD Records and Cell Traces from PCAP
    ...    pcap_filepath=${dcap_files}[ipCapture][0]
    ...    filter=nsetapx.crnti == ${ue_without_location_crnti} || nsetapx.crnti == ${ue_without_location_crnti_reestab}
    ...    log_suffix=UE_without_location
    Verify Message Count in PCAP    pcap_filepath=${dcap_files}[ipCapture][0]
    ...    filter=nsetapx.ueMeasRecord    count=12    options=${tshark_options}
    Verify Message Count in PCAP    pcap_filepath=${dcap_files}[ipCapture][0]
    ...    filter=nsetapx && nr-rrc.measurementReport_element    count=12    options=${tshark_options}
    Verify Message Count in PCAP    pcap_filepath=${TEST_tcpdump_gnb_path}
    ...    filter=nr-rrc.measurementReport_element    count=12    options=${tshark_options}
    ${PCMD_Seq_before_reestab}    Prepare Sequence List Of 4 Dictionaries From ${rrmEvent_MDT_record_for_SA_UE}
    ${cellTrace_Seq_before_reestab}    Prepare Sequence List Of 4 Dictionaries From ${rrmEvent_MDT_cellTrace_with_location}
    ${PCMD_Seq_after_reestab}    Prepare Sequence List Of 4 Dictionaries From ${rrmEvent_MDT_record_for_SA_UE}
    ${cellTrace_Seq_after_reestab}    Prepare Sequence List Of 4 Dictionaries From ${rrmEvent_MDT_cellTrace_with_location}
    ${PCMD_Seq_ue_without_location}    Prepare Sequence List Of 4 Dictionaries From ${rrmEvent_MDT_record_for_SA_UE}
    ${cellTrace_Seq_ue_without_location}    Prepare Sequence List Of 4 Dictionaries From ${rrmEvent_MDT_cellTrace_no_location}
    Verify PCMD Records Sequence in Collection
    ...    ${MDT_traces_before_reestab_for_ue_with_location}[PCMD]    ${PCMD_Seq_before_reestab}    strict_fields_check=yes
    Verify Cell Trace Sequence in Collection
    ...    ${MDT_traces_before_reestab_for_ue_with_location}[cellTrace]    ${cellTrace_Seq_before_reestab}
    Verify PCMD Records Sequence in Collection
    ...    ${MDT_traces_after_reestab_for_ue_with_location}[PCMD]     ${PCMD_Seq_after_reestab}    strict_fields_check=yes
    Verify Cell Trace Sequence in Collection
    ...    ${MDT_traces_after_reestab_for_ue_with_location}[cellTrace]     ${cellTrace_Seq_after_reestab}
    Verify PCMD Records Sequence in Collection
    ...    ${MDT_traces_ue_without_location}[PCMD]     ${PCMD_Seq_ue_without_location}    strict_fields_check=yes
    Verify Cell Trace Sequence in Collection
    ...    ${MDT_traces_ue_without_location}[cellTrace]     ${cellTrace_Seq_ue_without_location}
    Verify Sequence of cellActiveMDTUETraced
    ...    syslog_filepath=${dcap_files}[syslog]    expected_seq=${internal_count_prints_1_UE_attach_detach_twice}
