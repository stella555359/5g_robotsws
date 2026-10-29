*** Settings ***
Force Tags      RAN_5G    RAN_5G_TDD    SBTS00    SKIPRUN
...             CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    STATE_CONFIGURED

Documentation
...            author:       Mateusz Michalik, mateusz.michalik@nokia.com
...            maintainer:   Mateusz Michalik, mateusz.michalik@nokia.com

#Library    testsuite/Krakow/RRM/RAN_L3_SW2/KRK3/resources/pm_analyze_listener/listener.py
...    testsuite//Bangalore/RRM/5GET_BLR/KRK_PZ/CB008176/resources/pm_counters_template.yaml    30min

Resource     ./resources/common.robot

Suite Setup       Run Keywords    Add UEs with location support to cfg file
...    wts_delta=${DELTA_WTS_LOCATION}  wts_out=${WTS_FINAL}  wts_in=${WTS_HO}
...    AND        Testline Setup    reach_on_air=yes    wts=${WTS_FINAL}    config=${SUITE_CONFIG}
Suite Teardown    Testline Teardown

Test Setup        Test Case Setup 8176
Test Teardown     Test Case Teardown    check_radio_res=yes    oam_logs=yes

*** Variables ***
${COMMON_KRK_RESOURCES_PATH}    ${CURDIR}/../resources/krk3_common
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
${WTS_HO}              /opt/wts/latest/basic_setup.cfg
${WTS_FINAL}           ${OUTPUT DIR}/Logs/wts_ho_with_added_location_ues.cfg
&{DELTA_CONFIG_D1_D2}  delta=${CURDIR}/resources/delta_configs/D/delta_D1_DCAP.json
&{DELTA_CONFIG_D2}     delta=${CURDIR}/resources/delta_configs/D/delta_D2_DCAP.json
&{DELTA_CONFIG_D3}     delta=${CURDIR}/resources/delta_configs/D/delta_D3_DCAP.json
&{DELTA_CONFIG_D4}     delta=${CURDIR}/resources/delta_configs/D/delta_D4_DCAP.json
&{DELTA_CONFIG_D5}     delta=${CURDIR}/resources/delta_configs/D/delta_D5_DCAP.json
&{DELTA_CONFIG_D6}     delta=${CURDIR}/resources/delta_configs/D/delta_D6_DCAP.json
&{DELTA_CONFIG_D9}     delta=${CURDIR}/resources/delta_configs/D/delta_D9_DCAP.json
&{DELTA_CONFIG_D10}    delta=${CURDIR}/resources/delta_configs/D/delta_D10_DCAP.json

*** Test Cases ***
[1]CB008176_5G_D_12_Verify_PM_Counters_during_periodic_MDT_measurement_configuration_during_RRC_re-establishment_with_selection_only_location_UEs
    Recreate Objects via Delta Commissioning    delta_file=${DELTA_CONFIG_D5}
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
    ...    pcap_filepath=${dcap_files}[ipCapture][0]    filter=nsetapx.crnti == ${ue1_crnti}    log_suffix=UE_without_location
    ...    should_MDT_PCMD_be_present=${False}
    ${MDT_traces_ue2}    Get MDT PCMD Records and Cell Traces from PCAP
    ...    pcap_filepath=${dcap_files}[ipCapture][0]    filter=nsetapx.crnti == ${ue2_crnti}    log_suffix=UE_without_location
    ...    should_MDT_PCMD_be_present=${False}
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
    ...    filter=nr-rrc.measurementReport_element && f1ap.GNB_CU_UE_F1AP_ID == 0    count=4   options=${tshark_options}
    Verify Message Count in PCAP    pcap_filepath=${TEST_tcpdump_gnb_path}
    ...    filter=nr-rrc.measurementReport_element && f1ap.GNB_CU_UE_F1AP_ID != 0    count=4   options=${tshark_options}
    ${cellTrace_Seq_UE1}    Prepare Sequence List Of 4 Dictionaries From ${periodic_MDT_cellTrace_with_location}
    ${cellTrace_Seq_UE2}    Prepare Sequence List Of 4 Dictionaries From ${periodic_MDT_cellTrace_no_location}
    Verify Cell Trace Sequence in Collection      ${MDT_traces_ue1}[cellTrace]    ${cellTrace_Seq_UE1}
    Verify Cell Trace Sequence in Collection      ${MDT_traces_ue2}[cellTrace]    ${cellTrace_Seq_UE2}
    Verify Sequence of cellActiveMDTUETraced
    ...    syslog_filepath=${dcap_files}[syslog]    expected_seq=${internal_count_prints_2_UEs_attach_detach}
