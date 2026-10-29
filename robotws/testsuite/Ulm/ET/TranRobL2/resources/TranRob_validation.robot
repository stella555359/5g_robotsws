*** Settings ***
Documentation    Validation Keywords of TranRob's Test Cases

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

Library    ./../libraries/TranRob_validation.py                    WITH NAME  TranRob


*** Keywords ***

Generate verdict on ${validate_with_scenario} for ${test_case_name}
    Prepare Variables for Validation    scenario=${validate_with_scenario}
    run keyword and continue on failure    TranRob . verify_qc_test_case  ${test_case_name}


#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

Prepare Variables for Validation
    [Arguments]  ${scenario}
    ${collector_name}=  template.get_collector_name  scenario_name=${scenario}
    ${path_to_ttitrace_json}=  set variable  ${ts_log_dir}/tti_trace_${collector_name}/ttitrace_streaming.json
    ${path_to_ttitrace_pkl}=   set variable  ${ts_log_dir}/tti_trace_${collector_name}/ttitrace_streaming.pkl
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

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]


Extract TTI Trace and Convert to JSON
    [Arguments]  @{varargs}
    RETURN


Extract TTI Trace and Convert to Pickle
    [Arguments]  ${path_to_tti_trace_pcap}
    ${events_required}=  create list    utcTimestampData
    ...                                 csiSrReportData
    ...                                 dlFdSchedData
    ...                                 ulFdSchedData
    ...                                 ulHarqRxData
    ...                                 dlHarqRxDataArray
    Convert TTI trace from PCAP to data frame  input_file_path=${path_to_tti_trace_pcap}
    ...                                        events_list=${events_required}
    ...                                        write_to_pickle=${TRUE}

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
