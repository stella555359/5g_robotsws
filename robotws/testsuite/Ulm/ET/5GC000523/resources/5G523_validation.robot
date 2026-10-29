*** Settings ***
Documentation    Test keyword resource file for 5GC000523

Library  ./libraries/scheduling_request_analyzer.py  WITH NAME  sr_csi_analyzer
Library  ./libraries/tti_trace.py                    WITH NAME  523_tti_extract
Library  ./libraries/csi_report_verdict.py           WITH NAME  csi_report_analyzer
Library  ./libraries/tools_523.py                    WITH NAME  tools_523
Library  ./libraries/ta_counter_analyzer.py          WITH NAME  ta_analyzer
Library  ./libraries/cell_util_counter_analyzer.py   WITH NAME  pm_analyzer
Library  ./libraries/523_F_Pucch_DTX_Counter.py      WITH NAME  dtx_counter

Resource    ../../../resources/Common/gnb.robot
Resource    ../../../resources/Common/pmcounters.robot


*** Keywords ***

Generate Verdict For 5GC000523_E_US1_Handling_of_Scheduling_Request
    [Arguments]  ${validate_with_scenario}=scenario_1
    ${collector_name}=  template.Get Collector Name  scenario_name=${validate_with_scenario}
    Prepare Validation
    ${res} =    sr_csi_analyzer.Sr Check    path_to_json=${ts_log_dir}/tti_trace_${collector_name}/tti_data.json
    ...                                     gnb_build=${sw_build}
    ...                                     frconfig=${nr_freq_config}
    Log  Analyzer ready with result ${res}
    Run Keyword And Continue On Failure  Should Be True  ${res}


Generate Verdict For 5GC000523_E_US6_Configurable_CSI_Reporting_Periodicity
    [Arguments]  ${validate_with_scenarios}
    Prepare Validation
    FOR    ${scenario}    IN    @{validate_with_scenarios}
        Log    ${scenario}
        ${collector_name}=  template.Get Collector Name  scenario_name=${scenario}
        ${Periodicity}=  Set Variable If    '${scenario}'=='scenario_2'  ${160}  ${320}
        ${expected_ri}=  Set Variable If  '${Periodicity}'=='320'  0  1
        ${expected_cqi}=  Set Variable If  '${Periodicity}'=='320'  8  10
        ${res} =    csi_report_analyzer.Generate Verdict
        ...  path_to_tti_json=${ts_log_dir}/tti_trace_${collector_name}/tti_data.json
        ...  FRconfig=${nr_freq_config}
        ...  expectedperiodicity=${Periodicity}
        ...  dtx_threshold_percentage=${0.5}
        ...  path_to_rrc_reconfig_pdml=${ts_log_dir}/s1x2_${collector_name}/backhaul.pdml
        ...  expected_cqi=${expected_cqi}
        ...  expected_ri=${expected_ri}
        Log  Analyzer ready with result ${res}
        Run Keyword And Continue On Failure  Should Be True  ${res}
    END


Generate Verdict For 5GC000523_F_TA_Counters
    [Arguments]  ${validate_with_scenario}=scenario_1
    ${collector_name}=  template.Get Collector Name  scenario_name=${validate_with_scenario}
    Prepare Validation
    &{pi_expected_values}=  ta_analyzer.Ta Counter Analyzer
    ...  path_to_tti_json=${ts_log_dir}/tti_trace_${collector_name}/tti_data.json
    ...  pci=${pCell_dict}
    ${pi_expected_val_rrc_con}=  Get From Dictionary  ${pi_expected_values}  M55307C020
    ${pi_expected_val_rach}=  Get From Dictionary  ${pi_expected_values}  M55307C010
    ${cells}=  Get Dictionary Values  ${pCell_dict}
    FOR  ${cell}  IN  ${1}  ${2}
         Run Keyword And Continue On Failure
         ...  pmcounters.Analyze PM Counters  index=1  abs_tol=0  rel_tol=0  pi_expected=&{pi_expected_val_rrc_con[${cells[${cell}-${1}]}]}
         ...  regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-${cell}  pi_dir=${ts_log_dir}/PMC/gnb_pm_counters/
         Run Keyword And Continue On Failure
         ...  pmcounters.Analyze PM Counters  index=1  abs_tol=0  rel_tol=0  pi_expected=&{pi_expected_val_rach[${cells[${cell}-${1}]}]}
         ...  regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-${cell}  pi_dir=${ts_log_dir}/PMC/gnb_pm_counters/
    END
    Log To Console  PM Counter Analysis completed


Generate Verdict For 5GC000523_F_NR_UL_Signal_Quality_Level_Measurements
    [Arguments]  ${validate_with_scenario}=scenario_1
    ${collector_name}=  template.Get Collector Name  scenario_name=${validate_with_scenario}
    Prepare Validation
    &{results_counted}=  dtx_counter.Pucch Dtx Counter Analyzer
    ...  path_to_tti_json=${ts_log_dir}/tti_trace_${collector_name}/tti_data.json
    ...  pci=${pCell_dict}
    FOR  ${cell}  IN  ${1}  ${2}
         Run Keyword And Continue On Failure
         ...  pmcounters.Analyze PM Counters  index=0  abs_tol=1  rel_tol=0.05  regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-${cell}
         ...  pi_dir=${pm_counters_dir}  pi_expected=&{results_counted[${cell}]}
    END
    Log To Console  SQ counter analysis completed


Generate Verdict For 5GC000523_F_NR_Cell_Utilization_Counters
    Prepare Validation
    Validate Slot Type Counters
    Validate Sample Counters


Prepare Validation
    IF    ${validation_preparation_complete}   RETURN
    Determine Freqency Band
    gnb.Get gNB Physical Cell ID
    ${validation_preparation_complete}=  Set Variable  ${True}
    Set Suite Variable    ${validation_preparation_complete}
    ${sw_build}=  testline.Get GNB SW Version
    Set Suite Variable    ${sw_build}


#---------------------------------------------Supporting Keywords-----------------------------------------------------#
Extract Data From PM Counters
    [Arguments]  ${pi_to_be_extracted}
    ${extracted_pi_dict}=  pm_internal.Get Pi Dict
    ...  pi_dir=${pm_counters_dir}
    ...  pi_list=${pi_to_be_extracted}
    RETURN  ${extracted_pi_dict}


Get Value From SCF
    [Arguments]  ${dist_name}  ${p_name}
    OperatingSystem.Create Directory  ${OUTPUT_DIR}/${SUITE_NAME}
    ${scf_file}=  gnb.Get SCF From GNB  target_dir=${OUTPUT_DIR}/${SUITE_NAME}
    scf.Load Scf  ${scf_file}
    ${ulDlDataSlotRatio}=  scf.Get Value From Scf  dist_name=${dist_name}  p_name=${p_name}
    RETURN   ${ulDlDataSlotRatio}


Validate Sample Counters
    [Documentation]  Validates the following counters: M55308C01000  M55308C01001
    [Arguments]  ${index}=0  ${cell}=1  ${abs_tolerance}=100  ${permitted_relative_tolerance}=0.02
    ${distName_params}=  gnb.Get DistNames From GNB DU  regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-${cell}
    ${num_slots_per_frame}=  Determine Number Of Slots Per Frame  ${nr_freq_config}
    ${rdPmCounter523FSamplingPeriod}=  Set Variable  1.0  #Slots
    ${pi_list_to_analyze}=  Create List  M55308C01000  M55308C01001
    ${counter_extract_list}=  Extract Data from PM Counters  ${pi_list_to_analyze}
    ${counters_to_be_analyzed}=  pm_analyzer.Extractor  pi_dict=${counter_extract_list}
    ...    required_pi_list=${pi_list_to_analyze}  index=${index}  distname=${distName_params[0]}
    ${expected_sample_count}=  pm_analyzer.Sample Count Analyzer  no_slots_per_frame=${num_slots_per_frame}
      ...  sampling_period=${rdPmCounter523FSamplingPeriod}  interval_pm=${pm_reporting_interval}
    ${verdict}=  pm_analyzer.Sample Count Verdict  counters_to_be_analyzed=${counters_to_be_analyzed}
    ...  expected_pi_value=${expected_sample_count}  abs_tolerance=${abs_tolerance}
    ...  permitted_relative_tolerance=${permitted_relative_tolerance}
    IF  '${verdict[0]}' == 'FAIL'    Log To Console  ${verdict[1]}
    Should Contain  PASS  ${verdict[0]}


Validate Slot Type Counters
    [Documentation]  Validates the following counters : M55308C00001  M55308C00002  M55308C00003  M55308C00004
    [Arguments]  ${index}=0  ${cell}=1
    ${pi_list_to_analyze}=  Create List  M55308C00001  M55308C00002  M55308C00003  M55308C00004
    ${distName_params}=  gnb.Get DistNames From GNB DU  regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-${cell}
    ${counter_extract_list}=  Extract Data from PM Counters  ${pi_list_to_analyze}
    ${counters_to_be_analyzed}=  pm_analyzer.Extractor  pi_dict=${counter_extract_list}
    ...    required_pi_list=${pi_list_to_analyze}  index=${index}  distname=${distName_params[0]}
    ${expected_slot_ratio}=  Get Value From SCF   dist_name=${distName_params[0]}  p_name=ulDlDataSlotRatio
    ${verdict}=  pm_analyzer.Slot Type Counter Analyzer  ${counters_to_be_analyzed}  ${expected_slot_ratio}
    Should Contain  PASS  ${verdict}


Extract TTI Trace And Convert To JSON
    [Arguments]  ${path_to_tti_trace_pcap}  ${target_directory}
    ${path}=  523_tti_extract.Extract Data For Analysis From TTI Trace
    ...   file_name_of_tti_trace_pcap=${path_to_tti_trace_pcap}
    ...   gnb_build=${sw_build}  log_dir=${target_directory}


Extract TTI Trace And Convert To Pickle
    [Arguments]  @{varargs}
    RETURN


Determine Number Of Slots Per Frame
    [Arguments]  ${FRconfig}
    ${slotsperframe}  Set Variable If  "${FRconfig}"=="mmW"  ${80}  ${20}
    RETURN  ${slotsperframe}


Determine Freqency Band
    OperatingSystem.Create Directory  ${OUTPUT_DIR}/${SUITE_NAME}
    ${distName_params}=  gnb.Get DistNames From GNB DU  regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-[0-9]+
    ${scf_file}=  gnb.Get SCF From GNB  target_dir=${OUTPUT_DIR}/${SUITE_NAME}
    scf.Load Scf  ${scf_file}
    ${nr_frequency_band}=  scf.Get Value From Scf  dist_name=${distName_params[0]}  p_name=freqBandIndicatorNR
    ${nr_freq_config}=  tools_523.Determine Tl Freq Configuration  nrband=${nr_frequency_band}
    Set Suite Variable  ${nr_freq_config}
