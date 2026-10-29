*** Settings ***
Documentation    Validation keywords specific to TranRob_Endurance_Pooling_Fdd TC

Library        taf.ul.hanging_resources                               WITH NAME   resources
Library        ../libraries/TranRob_Endurance_Pooling_Validation.py   WITH NAME   TranRob
Library        ../../../resources/Common/syslog_parser/syslog_parser.py
#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

*** Keywords ***

Verify SYSLOG Trace for TransRob Endurance Pooling
    ${collector_name}=  template.get_collector_name  scenario_name=${scenario_name}

    ${syslog_dir}=  Set Variable  ${ts_log_dir}/btslog_${collector_name}/btslog_gnb0
    ${syslog_files}=  OperatingSystem.List Files In Directory  ${syslog_dir}  *.tgz
    ${num_of_files}=  get length  ${syslog_files}

    ${EXCEPTIONFILE}=  Set Variable    ${CURDIR}/SYSLOG_EXCEPTION_FOR_TranRob_Endurance_Pooling_Fdd.txt
    ${error_file}=  IF  ${num_of_files}==1
    ...    find_errors_and_warnings_in_logfile_and_write_them_into_resultfile
    ...    ${syslog_dir}/${syslog_files}[0]
    ...    ignorefname=${EXCEPTIONFILE}
    ...    ELSE  Log to console    No syslog_files.tgz available

    OperatingSystem.File Should Be Empty  ${error_file}


Generate verdict for ${validate_with_scenario} TC ${test_case_name} PMC Fdd nbrofpmcmi ${nbrofpmcmi} exptp ${exptp}
    # prepare Variables for Validation Test    scenario=${validate_with_scenario}
    Prepare Variables for Validation    scenario=${validate_with_scenario}
    run keyword and continue on failure    TranRob . verify_qc_test_case  ${test_case_name}  ${nbrofpmcmi}  ${exptp}


Generate verdict for ${validate_with_scenario} TC ${test_case_name} PMC Tdd nbrofpmcmi ${nbrofpmcmi} exptp ${exptp}
    # Prepare Variables for Validation Test    scenario=${validate_with_scenario}
    Prepare Variables for Validation    scenario=${validate_with_scenario}
    run keyword and continue on failure    TranRob . verify_qc_test_case  ${test_case_name}  ${nbrofpmcmi}  ${exptp}


Prepare Variables for Validation
    [Arguments]  ${scenario}
    ${collector_name}=  template.get_collector_name  scenario_name=${scenario}
    ${path_to_scf_xml}=        set variable  ${configuration_directory}/scf_${scenario}.xml
    ${pm_counters_dir}=        set variable  ${ts_log_dir}/PMC/gnb_pm_counters/
    # ${pmc_index}=  tools.get_pmc_index
    # ...                                 scenario=${scenario}
    # ...                                 pm_offset_path=${pm_counters_dir}/pm_counter_offsets.json
    ${nrbts_str}=  Get distNames from gNB DU  regex=MRBTS-[0-9]+/NRBTS-[0-9]+
    ${attached_ues}=  Get UE Ids configured for scenario  scenario_name=${scenario}
    set test variable  ${path_to_scf_xml}
    set test variable  ${ts_log_dir}
    set test variable  ${pm_counters_dir}
    # set test variable  ${pmc_index}
    set test variable  ${nrbts_str}
    set test variable  ${attached_ues}


Prepare Variables for Validation Test
    [Arguments]  ${scenario}
    ${configuration_directory}=  set variable  /tmp/Logs/TranRob_Endurance_Pooling_Tdd/SBTS00_ENB_9999_230810_000009/20230816_080339/Configs/
    ${path_to_scf_xml}=        set variable  ${configuration_directory}/scf_${scenario}.xml
    ${ts_log_dir}=  set variable  /tmp/Logs/TranRob_Endurance_Pooling_Tdd/SBTS00_ENB_9999_230810_000009/20230816_080339/Logs/
    ${pm_counters_dir}=        set variable  ${ts_log_dir}/PMC/gnb_pm_counters/
    ${test_description}=  set variable  My TC
    # ${pmc_index}=  tools.get_pmc_index
    # ...                                 scenario=${scenario}
    # ...                                 pm_offset_path=${pm_counters_dir}/pm_counter_offsets.json
    ${nrbts_str}=  Get distNames from gNB DU  regex=MRBTS-[0-9]+/NRBTS-[0-9]+
    set test variable  ${path_to_scf_xml}
    set test variable  ${ts_log_dir}
    set test variable  ${pm_counters_dir}
    # set test variable  ${pmc_index}
    set test variable  ${nrbts_str}

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


get resources taken before_test
    [Documentation]    [PRIVATE]    get resources taken before test, measurement period
    Log To Console    \nget used resources and save in var "resources_usage_before_test"
    ${resources_usage_before_test}    resources.Get Resources Usage   node_id=0   node_type=gnb
    set test variable    ${resources_usage_before_test}


get resources taken after_test
    [Documentation]    [PRIVATE]    get resources taken after test, measurement period
    Log To Console    \nget used resources and save in var "resources_usage_after_test"
    ${resources_usage_after_test}    resources.Get Resources Usage   node_id=0   node_type=gnb
    set test variable    ${resources_usage_after_test}


verify resource usage
    [Documentation]    [PRIVATE]    compare resources before test and after test
    Log To Console    \nverify used resources
    Run Keyword And Continue On Failure      resources.Resources Should Be Equal
    ...    ${resources_usage_before_test}
    ...    ${resources_usage_after_test}

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
