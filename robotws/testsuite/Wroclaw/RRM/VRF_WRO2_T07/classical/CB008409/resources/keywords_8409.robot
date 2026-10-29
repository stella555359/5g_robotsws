*** Settings ***
Documentation
...   author:        Marcin Wolczynski
...   contact:       marcin.wolczynski@nokia.com
...   Description:   Feature CB8409

Resource     testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB008409/resources/test_specific_keywords_8409.robot
Library        taf.ue
Library        taf.rfrl.bts.devices.du.pm_counters.GnbPmCounter   WITH NAME      GnbCounter
Library        testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB008409/resources/test_specific_keywords_CB008409.py

Variables    testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB008409/resources/test_specific_keywords_CB008409.py


*** Variables ***
${UE_ALIAS}                 DRB_UE
${UE_CAPA}                  REAL_UE_SA
${VONR_NUMBER}          +555800903300998
${VC_ALIAS}             VC_1
${TTI_type}             sum
${PM_INTERVAL}          5
${attenuation_8409_A2}              90
${file_name_noF_good}      withoutFeaturewithinterferencesGod
${file_name_noF_bad}       withoutFeaturewithinterferencesBad
${file_name_F_good}        withFeaturewithinterferencesGod
${file_name_F_bad}         withFeaturewithinterferencesBad
${file_name_CNI}           CNITTI
${CellFilter}           1
@{counter_ids_8049}     M55308C10003    M55308C10004    M55308C10001    M55308C10002    M55308C26002   M55308C26001
@{counter_ids_8049_B}   M55308C10014
${1st_log}              before_feature_act
${name_log_B_counter}   feature_B_counters
${2nd_log}              after_feature_act
${3rd_log}              CNI_activated
${filter_csv_1}         csiSrReportData
${parameter_filter_1}   cqi
${filter_csv_2}         dlLaAverageCqi
${parameter_filter_2}   rrmInstCqi
${parameters_pcap}      subcarrierLocation-p1       symbolLocation-p1   startingRB
@{value_to_check_pooling_on}       subcarrierLocation-p1: s0 (0)   symbolLocation-p1: 10   startingRB: 0
@{value_to_check_pooling_on_CNI}       subcarrierLocation-p1: s8 (2)   symbolLocation-p1: 4   startingRB: 0
@{value_to_check_pooling_off1}       subcarrierLocation-p1: s0 (0)   symbolLocation-p1: 12   startingRB: 0
@{value_to_check_pooling_off2}       subcarrierLocation-p1: s4 (1)   symbolLocation-p1: 12   startingRB: 0
${filter_pcap_tcp}      DLRRCMessageTransfer
${protocol_pcap}        f1ap
${bip_log_path}         CB008409_L1L2.pcap
${parameterl1l2_1}      csiTransmitPower
${parameterl1l2_2}      startSymbol
${filter_bip1}          dldata_csirssendreq
${filter_bip2}          DlData_CsiRsSendReq_t
${filter_csv_B}         dlFdSchedData
${parameter_filter_B}   numPrbForPowerBoost
${8409_B_feature_on}    feature8409_B_on
${act1rat_on_syslog}    feautre8409_B_on_actrat1


*** Keywords ***
[1]CB008409_A_2_CSI_IM_randomization_in_FDD_cell_with_DRX_configured_ASOE_2DL_2UL
	[Documentation]   This test case is for 8409 feature with interferences
	AdminUtils.unlock_all_cells
	preparing for counters time setting
    Preparing for feature 8409
    test_specific_keywords_8409.Start Syslog collection
    attenuation 8409 A2 for test        ${attenuation_8409_A2}
    Attach Ue            ${UE_ALIAS}
    Data Transfer procedure     ${UE_ALIAS}
    Check data transfer procedure
    Start log collection 8409          ${file_name_noF_good}
    attenuation_8409_A2_loop      ${attenuation_8409_A2}
    Check data transfer procedure
    ${tti_file_path_good}    Stop log collection 8409       ${file_name_noF_good}
    ${data_analysis_cqi_good_1}    tti analysis 8409   ${tti_file_path_good}    ${filter_csv_1}   ${parameter_filter_1}
    ${data_analysis_cqiBTS_good_1}  tti analysis 8409   ${tti_file_path_good}    ${filter_csv_2}   ${parameter_filter_2}
    check CQI values    ${data_analysis_cqi_good_1}    ${data_analysis_cqiBTS_good_1}
    Data transfer in interval
    ${counters_before_ft_at}    Verify counters with interferences   ${CellFilter}   ${counter_ids_8049}     ${1st_log}
    Check data transfer procedure
    Detach Ue                  ${UE_ALIAS}
    AdminUtils.unlock_all_cells
    Activation feature 8409 part A C
    attenuation 8409 A2 for test        ${attenuation_8409_A2}
    BuiltIn.Sleep   5s
    start_logging_pcap  A_C
    BuiltIn.Sleep   5s
    Attach Ue            ${UE_ALIAS}
    BuiltIn.Sleep   5s
    stop_logging_pcap
    Data Transfer procedure     ${UE_ALIAS}
    BuiltIn.Sleep  5s
    Check data transfer procedure
    Start log collection 8409       ${file_name_F_good}
    attenuation_8409_A2_loop      ${attenuation_8409_A2}
    Check data transfer procedure
    ${tti_file_good_F}    Stop log collection 8409       ${file_name_F_good}
    ${data_analysis_cqi_good_1}     tti analysis 8409   ${tti_file_good_F}    ${filter_csv_1}   ${parameter_filter_1}
    ${data_analysis_cqiBTS_good_1}  tti analysis 8409   ${tti_file_good_F}    ${filter_csv_2}   ${parameter_filter_2}
    check CQI values for randomization    ${data_analysis_cqi_good_1}    ${data_analysis_cqiBTS_good_1}
    Data transfer in interval
    ${after_f_activation}      Verify counters with interferences   ${CellFilter}    ${counter_ids_8049}    ${2nd_log}
    compare_counters_8409   ${counters_before_ft_at}   ${after_f_activation}    ${counter_ids_8049}
    Bip and pcap check  ${LOG_PATH}     ${protocol_pcap}    ${filter_pcap_tcp}  ${parameters_pcap}  ${bip_log_path}
    ...                 ${filter_bip1}  ${filter_bip2}  @{value_to_check_pooling_on}


[1]CB133099_Comparison_with_CB008409
	[Documentation]   This test case is for 8409 vs 133099 with interferences
	AdminUtils.unlock_all_cells
	preparing for counters time setting
    Preparing for feature 8409
    test_specific_keywords_8409.Start Syslog collection
    attenuation 8409 A2 for test        ${attenuation_8409_A2}
    Activation feature 8409 part A C
    attenuation 8409 A2 for test        ${attenuation_8409_A2}
    BuiltIn.Sleep   5s
    Attach Ue            ${UE_ALIAS}
    Data Transfer procedure     ${UE_ALIAS}
    BuiltIn.Sleep  5s
    Check data transfer procedure
    Start log collection 8409       ${file_name_F_good}
    attenuation_8409_A2_loop      ${attenuation_8409_A2}
    Check data transfer procedure
    ${tti_file_good_F}    Stop log collection 8409       ${file_name_F_good}
    ${data_analysis_cqi_good_1}     tti analysis 8409   ${tti_file_good_F}    ${filter_csv_1}   ${parameter_filter_1}
    ${data_analysis_cqiBTS_good_1}  tti analysis 8409   ${tti_file_good_F}    ${filter_csv_2}   ${parameter_filter_2}
    check CQI values for randomization    ${data_analysis_cqi_good_1}    ${data_analysis_cqiBTS_good_1}
    Data transfer in interval
    ${after_f_activation}      Verify counters with interferences   ${CellFilter}    ${counter_ids_8049}    ${2nd_log}
    Check data transfer procedure
    Detach Ue                  ${UE_ALIAS}
    activation_cni_CB0133099
    attenuation 8409 A2 for test        ${attenuation_8409_A2}
    BuiltIn.Sleep   5s
    start_logging_pcap  A_C
    BuiltIn.Sleep   5s
    Attach Ue            ${UE_ALIAS}
    BuiltIn.Sleep   5s
    stop_logging_pcap
    Data Transfer procedure     ${UE_ALIAS}
    BuiltIn.Sleep  5s
    Check data transfer procedure
    Start log collection 8409       ${file_name_CNI}
    attenuation_8409_A2_loop      ${attenuation_8409_A2}
    Check data transfer procedure
    ${tti_file_good_CNI}    Stop log collection 8409       ${file_name_CNI}
    ${data_analysis_cqi_good_1_CNI}     tti analysis 8409   ${tti_file_good_CNI}    ${filter_csv_1}   ${parameter_filter_1}
    ${data_analysis_cqiBTS_good_1_CNI}  tti analysis 8409   ${tti_file_good_CNI}    ${filter_csv_2}   ${parameter_filter_2}
    check CQI values for randomization    ${data_analysis_cqi_good_1_CNI}    ${data_analysis_cqiBTS_good_1_CNI}
    Data transfer in interval
    ${after_f_activation_CNI}      Verify counters with interferences   ${CellFilter}    ${counter_ids_8049}    ${3rd_log}
    compare_counters_8409   ${after_f_activation}   ${after_f_activation_CNI}    ${counter_ids_8049}
    Bip and pcap check  ${LOG_PATH}     ${protocol_pcap}    ${filter_pcap_tcp}  ${parameters_pcap}  ${bip_log_path}
    ...                 ${filter_bip1}  ${filter_bip2}  @{value_to_check_pooling_on_CNI}


[1]CB008409_A_2_CSI_IM_randomization_in_FDD_cell_with_DRX_configured_ASOE_2DL_2UL_poolingoff
	[Documentation]   This test case is for 8409 feature with interferences
	AdminUtils.unlock_all_cells
	preparing for counters time setting
    Preparing for feature 8409 pooling off
    test_specific_keywords_8409.Start Syslog collection
    attenuation 8409 A2 for test        ${attenuation_8409_A2}
    Attach Ue            ${UE_ALIAS}
    Data Transfer procedure     ${UE_ALIAS}
    Check data transfer procedure
    Start log collection 8409          ${file_name_noF_good}
    attenuation_8409_A2_loop      ${attenuation_8409_A2}
    Check data transfer procedure
    ${tti_file_path_good}    Stop log collection 8409       ${file_name_noF_good}
    ${data_analysis_cqi_good_1}    tti analysis 8409   ${tti_file_path_good}    ${filter_csv_1}   ${parameter_filter_1}
    ${data_analysis_cqiBTS_good_1}  tti analysis 8409   ${tti_file_path_good}    ${filter_csv_2}   ${parameter_filter_2}
    check CQI values    ${data_analysis_cqi_good_1}    ${data_analysis_cqiBTS_good_1}
    Data transfer in interval
    ${counters_before_ft_at}    Verify counters with interferences   ${CellFilter}   ${counter_ids_8049}     ${1st_log}
    Check data transfer procedure
    Detach Ue                  ${UE_ALIAS}
    AdminUtils.unlock_all_cells
    Activation feature 8409 part A C
    attenuation 8409 A2 for test        ${attenuation_8409_A2}
    BuiltIn.Sleep   5s
    start_logging_pcap  A_C
    BuiltIn.Sleep   5s
    Attach Ue            ${UE_ALIAS}
    BuiltIn.Sleep   5s
    stop_logging_pcap
    Data Transfer procedure     ${UE_ALIAS}
    BuiltIn.Sleep  5s
    Check data transfer procedure
    Start log collection 8409       ${file_name_F_good}
    attenuation_8409_A2_loop      ${attenuation_8409_A2}
    Check data transfer procedure
    ${tti_file_good_F}    Stop log collection 8409       ${file_name_F_good}
    ${data_analysis_cqi_good_1}     tti analysis 8409   ${tti_file_good_F}    ${filter_csv_1}   ${parameter_filter_1}
    ${data_analysis_cqiBTS_good_1}  tti analysis 8409   ${tti_file_good_F}    ${filter_csv_2}   ${parameter_filter_2}
    check CQI values for randomization    ${data_analysis_cqi_good_1}    ${data_analysis_cqiBTS_good_1}
    Data transfer in interval
    ${after_f_activation}      Verify counters with interferences   ${CellFilter}    ${counter_ids_8049}    ${2nd_log}
    compare_counters_8409   ${counters_before_ft_at}   ${after_f_activation}    ${counter_ids_8049}
    Bip and pcap check pooling off  ${LOG_PATH}     ${protocol_pcap}    ${filter_pcap_tcp}  ${parameters_pcap}
    ...                 ${bip_log_path}     ${filter_bip1}  ${filter_bip2}   ${value_to_check_pooling_off1}
    ...                 ${value_to_check_pooling_off2}


CB008409_B_17_FDD_BW15_DL_power_boosting_of_retransmission_for_VoNR_data_with_PRB_Pooling_test
	[Documentation]   This test case
	preparing for counters time setting
    Preparing for feature 8409
    Activation feature 8409 part B
    test_specific_keywords_8409.Start Syslog collection
    attenuation 8409 A2 for test        ${attenuation_8409_A2}
    Wait for next counter interval 8409
    Attach Ue            ${UE_ALIAS}
    Start log collection 8409          ${8409_B_feature_on}
    Voice Call start    ${UE_ALIAS}     ${VC_ALIAS}
    attenuation_8409_B_loop
    Stop voice call     ${VC_ALIAS}
    Detach Ue            ${UE_ALIAS}
    ${8409_B_feature_on_tti}    Stop log collection 8409       ${8409_B_feature_on}
    Wait for next counter interval 8409
    ${counters_part_b_8409}    Verify counters with interferences part B  ${CellFilter}   ${counter_ids_8049_B}     ${name_log_B_counter}
    ${tti_result_for8409_partB}     tti analysis 8409   ${8409_B_feature_on_tti}    ${filter_csv_B}   ${parameter_filter_B}     ${TTI_type}
    compare tti vs counter      ${tti_result_for8409_partB}     ${counters_part_b_8409}
    log to console  CB008409_B counter vs TTI passed
    log to console  Activating Rat1 feature
    feature_actrat1_activation
    attenuation 8409 A2 for test        ${attenuation_8409_A2}
    BuiltIn.Sleep   90s
    Attach Ue            ${UE_ALIAS}
    BuiltIn.Sleep   10s
    Wait for next counter interval 8409
    Start log collection 8409          ${act1rat_on_syslog}
    Voice Call start    ${UE_ALIAS}     ${VC_ALIAS}
    attenuation_8409_B_loop
    Stop voice call     ${VC_ALIAS}
    Detach Ue            ${UE_ALIAS}
    ${act1rat_on_tti}    Stop log collection 8409       ${act1rat_on_syslog}
    Wait for next counter interval 8409
    ${counters_actrat1}    Verify counters with interferences part B  ${CellFilter}   ${counter_ids_8049_B}     ${name_log_B_counter}
    ${tti_result_for8409_partB_actrat1}     tti analysis 8409   ${act1rat_on_tti}    ${filter_csv_B}   ${parameter_filter_B}     ${TTI_type}
    compare tti vs counter      ${tti_result_for8409_partB_actrat1}     ${counters_actrat1}
    log to console  CB008409_B + actrat1 counter vs TTI passed
