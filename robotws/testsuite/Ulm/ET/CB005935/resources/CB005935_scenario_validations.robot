*** Settings ***
Documentation    Scenario Validation keywords for feature CB005935

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
Resource   ../../../resources/Common/ttitrace.robot
Library    ../../../resources/Common/python/tti_analyzer_framework/tti_dlharqmatcher.py
Library    ../../../resources/Common/python/tti_analyzer_framework/tti_ulharqmatcher.py
Library    ./../libraries/CB005935_validation.py                      WITH NAME  CB005935


*** Keywords ***

Generate verdict on ${validate_with_scenario} for ${test_case_name}
    Prepare Variables for Validation    scenario=${validate_with_scenario}
    run keyword and continue on failure    CB005935 . verify_qc_test_case  ${test_case_name}
    #run keyword and continue on failure    CB005935 . verify_sCelladdition   [50,51,52,53,54,55,56,57]


#------------------------------------------------------------------------------------------------------------------------------------[150 characters]


Prepare Variables for Validation
    [Arguments]  ${scenario}
    ${collector_name}=  template.get_collector_name  scenario_name=${scenario}
    ${path_to_ttitrace_json}=  set variable  ${ts_log_dir}/tti_trace_${collector_name}/ttitrace_streaming.json
    ${path_to_ttitrace_pkl}=   set variable  ${ts_log_dir}/tti_trace_${collector_name}/ttitrace_streaming_ulharq.pkl
    ${path_to_syscom_pdml}=    set variable  ${ts_log_dir}/cell_setup_trace_initial/l2_l3_tcpdump.pdml
    ${path_to_scf_xml}=        set variable  ${configuration_directory}/scf_${scenario}.xml
    ${path_to_syslog_tgz}=     set variable  ${ts_log_dir}/btslog_${collector_name}/btslog_gnb0/syslog_files.tgz
    ${pm_counters_dir}=        set variable  ${ts_log_dir}/PMC/gnb_pm_counters/
    ${PMC_INDEX}=  tools.Get_Pmc_Index  scenario=${scenario}  pmc_scenario_dict=${PMC_SCENARIO_DICT}  ts_log_dir=${TS_LOG_DIR}
    ${nrbts_str}=  Get distNames from gNB DU  regex=MRBTS-[0-9]+/NRBTS-[0-9]+
    ${attached_ues}=  Get UE Ids configured for scenario  scenario_name=${scenario}
    set test variable  ${path_to_ttitrace_json}
    set test variable  ${path_to_ttitrace_pkl}
    set test variable  ${path_to_syscom_pdml}
    set test variable  ${path_to_scf_xml}
    set test variable  ${path_to_syslog_tgz}
    set test variable  ${pm_counters_dir}
    set test variable  ${pmc_index}
    set test variable  ${nrbts_str}
    set test variable  ${attached_ues}
    set test variable  ${scenario}


Extract TTI Trace and Convert to JSON
    [Arguments]  @{varargs}
    RETURN


Extract TTI Trace and Convert to Pickle
    [Arguments]  ${path_to_tti_trace_pcap}
    ${target_path}=    Replace String    ${path_to_tti_trace_pcap}    ttitrace_streaming.pcap    ${EMPTY}
    #--- DL -------------------------------------------------------------------------------------------------------------------------[150 characters]
    ${events_required}=  Create List    utcTimestampData
    ...                                 dlFdSchedData
    ...                                 dlHarqRxDataArray
    ${dl_df}=    ttitrace.Convert TTI Trace From PCAP To Data Frame    input_file_path=${path_to_tti_trace_pcap}
    ...                                                       events_list=${events_required}
    ${dlharq_matcher_df}=    tti_dlharqmatcher.dlharq_matcher    dl_df=${dl_df}
    ${dlharq_target_path}=    Replace String    ${path_to_tti_trace_pcap}    ttitrace_streaming.pcap    ttitrace_streaming_dlharq.pkl
    tti_dataframe.write_df_to_pickle    df=${dlharq_matcher_df}    target_path=${dlharq_target_path}
    ttitrace.Convert TTI Trace From Data Frame To Csv    ${dlharq_matcher_df}
    ...                                                  ${target_path}
    ...                                                  tti_trace_filename=ttitrace_streaming_dlharq.csv
    #--- UL -------------------------------------------------------------------------------------------------------------------------[150 characters]
    ${events_required}=  Create List    utcTimestampData
    ...                                 ulFdSchedData
    ...                                 ulHarqRxData
    ...                                 ulLaDeltaSinr
    ...                                 ulFdSchedAdditionalData
    ${ul_df}=    ttitrace.Convert TTI Trace From PCAP To Data Frame    input_file_path=${path_to_tti_trace_pcap}
    ...                                                       events_list=${events_required}
    ${ulharq_matcher_df}=    tti_ulharqmatcher.ulharq_matcher    ul_df=${ul_df}
    ${ulharq_target_path}=    replace string    ${path_to_tti_trace_pcap}    ttitrace_streaming.pcap    ttitrace_streaming_ulharq.pkl
    tti_dataframe.write_df_to_pickle    df=${ulharq_matcher_df}    target_path=${ulharq_target_path}
    ttitrace.Convert TTI trace from data frame to csv    ${ulharq_matcher_df}
    ...                                                  ${target_path}
    ...                                                  tti_trace_filename=ttitrace_streaming_ulharq.csv
