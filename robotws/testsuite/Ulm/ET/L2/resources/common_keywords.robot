*** Settings ***
Documentation    Common keywords for Sqd68 Entity Testing
#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
Library    OperatingSystem
Library    taf.config.scf                                  WITH NAME   scf
Library    ../libraries/template_functions.py              WITH NAME   template
Library    ../libraries/tools.py
Library    ../libraries/ulm_common_library.py              WITH NAME   ucl
Resource   ../../../resources/Common/dcap.robot
Resource   ../../../resources/Common/testline.robot
Resource   ../../../resources/Common/gnb.robot
Resource   ../../../resources/Common/commissioning.robot
Resource   ../../../resources/Common/snapshot.robot
Resource   robot/tracing.robot
Resource   robot/5G_L3_call.robot
Resource   robot/test_setup.robot
Resource   robot/throughput_calculation.robot
Resource   robot/kpi.robot
Resource   ../../../resources/Common/scout_kpi.robot
#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

*** Variables ***
${Send_Data_ReP_Flag}    True

*** Keywords ***


Run Test Scenario
    ${tc_log_dir}=  testline.Get testcase log directory
    Set Suite Variable  ${tc_log_dir}
    IF  '${are_test_scenarios_run}'=='True'   RETURN
    Run Keyword And Continue On Failure    Run planned scenarios required for test
    Run Keyword And Continue On Failure    Collect PM Counters and process throughput using PM counters
    Run Keyword And Continue On Failure    kpi.Calculate KPI For all scenarios
    Log    ${PMC_SCENARIO_DICT}    console=yes
    Run Keyword And Continue On Failure    tracing.Process TTI Traces for all scenarios
    ${are_test_scenarios_run}=  Set Variable  True
    Set Suite Variable   ${are_test_scenarios_run}


Restore WTS Config
    copy file   ${configuration_directory}/basic_setup.cfg.orig  ${tl.core.dir_path}/${tl.core.cfg_filename}


Restore original gnb SCF
    ucl.kwrun  Execute full commissioning  gnb_id=${0}  scf_path=${original_gnb_scf}


Capture Snapshot and restore config
    Run Keyword And Warn On Failure  tracing.Collect WTS Logs
    Run Keyword And Warn On Failure  Restore WTS Config
    IF  '${logs_and_traces_flags["IMS_Snapshot"]}'=='True'
        ucl.kwrun  snapshot.Collect IM Snapshot From gNB  target_dir=${TS_LOG_DIR}
    END
    IF  '${logs_and_traces_flags['BTS_Snapshot']}'=='True'
        ucl.kwrun  snapshot.Collect Snapshot From gNB  target_dir=${TS_LOG_DIR}
    END
    IF  '${logs_and_traces_flags['AP_SOSLogs']}'=='True'
        Run Keyword And Warn On Failure  ucl.kwrun  wts_ue.Collect SOS Report Logs  target_dir=${TS_LOG_DIR}
    END
    IF  "${logs_and_traces_flags["Syslog_Teardown"]}"=="True"  tracing.Stop BTSLog Collection  btslog_teardown
    IF  '${extra_options_flags['restore_scf']}'=='False'    RETURN
    Restore Original gNB SCF


Save Resource Usage to File
    [Arguments]  ${collection_point}
    taf.ccs.aashell.Create Aashell Cli    name=aashell
    taf.ccs.aashell.Setup    aashell
    ${resources_usage}=    taf.ccs.aashell.Get Resources Usage    aashell
    OperatingSystem.Create Directory    ${ts_log_dir}/resource_stats
    tools.write_dictionary_to_json  dir_path=${ts_log_dir}/resource_stats
    ...  dictionary=${resources_usage}   filename=${scenario_name}_${collection_point}.json
    [Teardown]  taf.ccs.aashell.Teardown  aashell


Run planned scenarios required for test
    &{collector_dict}=  template.create_collector_dict  ${TEST TAGS}
    @{collector_names}=    create list
    ${pm_offsets}=  create dictionary
    ${scenario_pm_index}=  Set Variable  ${0}
    @{scenario_names}=  Get Dictionary Keys    ${collector_dict}
    ucl.kwrun  Get nrarfcn Info  #Required to make 7113 bearer stats evaluation quicker
    ${tti_init_required}=  tracing.Check if TTI Trace needs to be Reinitialized  re_init=${reinitialize_required}
    IF  '${logs_and_traces_flags['DCAP']['collection']}'=='True'    dcap.Start DCAP container
    IF  ${tti_init_required}    tracing.Create TTI-Trace Collectors for all Scenarios  scenario_names=${scenario_names}
    FOR    ${scenario_name}    IN   @{scenario_names}
        Set Suite Variable    ${scenario_name}
        ${is_with_pm_counters}=  template.is_with_pm_counters   ${scenario_name}
        ${special_keywords}=  template. get_special_keywords_for_scenario  ${scenario_name}
        Log    ${special_keywords}    console=yes
        IF  ${is_with_pm_counters}
            ucl.kwrun  pmcounters.Wait Until The Next Measurement Period Starts    additional_time=0
        END
        ${scenario_prep_start_time}=  tools.get_current_time
        ${collector}=  template.get_collector_name     ${scenario_name}
        set to dictionary  ${collector_dict["${scenario_name}"]}  collector_name=${collector}
        Execute Scenario specific configuration change    scenario_name=${scenario_name}
        Run Scenario specific Keywords before Scenario Execution  ${special_keywords}
        ${scenario_prep_end_time}=  tools.get_current_time
        ${scenario_prep_time}=  tools.get_elapsed_time  start_time=${scenario_prep_start_time}  end_time=${scenario_prep_end_time}
        ${pm_offset}=  tools.identify_pm_counter_index_offset
        ...    defined_pm_interval=${pm_reporting_interval}
        ...    elapsed_time_in_interval=${scenario_prep_time}
        set to dictionary  ${pm_offsets}  ${collector}=${pm_offset}
        set to dictionary  ${collector_dict["${scenario_name}"]}  pm_offset=${pm_offset}
        set to dictionary  ${collector_dict["${scenario_name}"]}  pm_index=${scenario_pm_index}
        ${scenario_pm_index}=  Evaluate  ${scenario_pm_index} + ${1}
        ${tti_init_required}=  tracing.Check if TTI Trace needs to be Reinitialized
        IF  ${tti_init_required}  tracing.Create TTI-Trace Collectors for all Scenarios  scenario_names=${scenario_names}
        Save Resource Usage to File  collection_point=before_scenario
        ${pm_counter_start_before_L3}=  template.pm_counter_start_before_L3  ${scenario_name}
        IF  ${pm_counter_start_before_L3}
                ...    ucl.kwrun  pmcounters.Wait Until The Next Measurement Period Starts    additional_time=0
        ${is_with_pm_counters}  Set Variable If    ${is_with_pm_counters} or ${pm_counter_start_before_L3}  ${True}  ${False}
        ${kw_status}=  Run Keyword And Return Status  5G_L3_call.5G L3 Call with traffic   &{collector_dict["${scenario_name}"]}
        IF    not ${kw_status}    Log    L3 CALL on ${scenario_name} FAILED!    level=ERROR
        IF    not ${kw_status}    tracing.Stop and collect running traces  collector_name=${collector}  scenario_name=${scenario_name}
        Save Resource Usage to File  collection_point=after_scenario
        IF    '${logs_and_traces_flags['DCAP']['collection']}'=='True'
        ...  dcap.Collect DCAP Traces  target_dir=${ts_log_dir}/dcap_${scenario_name}
        Collections.Append To List    ${collector_names}    ${collector}
    END
    IF  "${logs_and_traces_flags["Syslog_Teardown"]}"=="True"  tracing.Prepare And Start Syslogs
    tracing.Collect TTI-Traces For all Scenarios  ${scenario_names}  ${collector_dict}
    IF  ${is_with_pm_counters}
        ucl.kwrun  pmcounters.Wait Until The Next Measurement Period Starts
        OperatingSystem.Create Directory  ${ts_log_dir}/PMC/gnb_pm_counters
        tools.post_process_pmc_indices
        ...    collector_dict=${collector_dict}
        ...    dir_path=${ts_log_dir}/PMC/gnb_pm_counters
        ...    max_scenario_pm_index=${scenario_pm_index}
    END
    Set Suite Variable  ${collector_names}


Execute Scenario specific configuration change
    [Arguments]  ${scenario_name}
    ${config_change_needed}  ${change_params}=  template.is_scenario_modifications_configured  ${scenario_name}
    IF    not ${config_change_needed}
        Log To Console  Scenario specific SCF changes not configured for: ${scenario_name}
    ELSE
        Log To Console  Following SCF Paramaters will be changed for ${scenario_name}: ${change_params}
        Change Scenario configuration  scenario_name=${scenario_name}
    END
    ${full_file_path}  Get SCF From GNB  target_dir=${configuration_directory}
    Move File    ${full_file_path}    ${configuration_directory}/scf_${scenario_name}.xml


Change Scenario configuration
    [Arguments]  ${scenario_name}
    ${current_scf}=  gnb.Get SCF From GNB  gnb_id=${0}  target_dir=${configuration_directory}  scf_name=scf_before_${scenario_name}_changes.xml
    ${scf_content}=  OperatingSystem.Get File  ${current_scf}
    ${list_of_scf_modifications}  template.get_commissioned_object_list  ${scenario_name}  ${scf_content}
    ucl.kwrun  Commission Managed Object List  ${list_of_scf_modifications}
    ${status}=  Run Keyword And Ignore Error  Wait until Node to be onair state  timeout=300 sec
    IF  '${status[${0}]}'=='FAIL'  test_setup.Bring cell on air
    ...  cell_setup_trace_dir=${ts_log_dir}/cell_setup_trace_${scenario_name}


Report Test Result to Reporting Portal
    ${is_single_run}=  template.Is Single Run
    Log To Console    message=This Test was a single run: ${is_single_run}
    IF  ${is_single_run}
        Remove Tags    SKIP_REPORT
        RETURN
    ELSE
        Log To Console  This is not a single run test case, using online reporting
    END
    ${ALWAYS_REPORT_FLAG}=    Run Keyword And Return Status  Collections.List Should Contain Value  ${TEST TAGS}  ALWAYS_REPORT
    ${PM_COUNTERS_TO_REPORT}=    Run Keyword And Return Status  Variable Should Exist  ${tc_pm_counters_validated}
    ${rep_pm_counters}=  Set Variable If  ${PM_COUNTERS_TO_REPORT}  ${tc_pm_counters_validated}  ${EMPTY}
    ${KPIs_TO_REPORT}=    Run Keyword And Return Status  Variable Should Exist  ${tc_kpis_validated}
    ${rep_kpis}=  Set Variable If  ${KPIs_TO_REPORT}  ${tc_kpis_validated}  ${EMPTY}
    ${SW_POST_FIX_PRESENT}=    Run Keyword And Return Status  Variable Should Exist  ${SW_POSTFIX}
    ${swPostFix}=    Set Variable If  ${SW_POST_FIX_PRESENT}  ${SW_POSTFIX}  ${EMPTY}
    Report Test case status to reporting portal  pmcounters_to_be_reported=${rep_pm_counters}
    ...                                          swPostFix=${swPostFix}
    ...                                          kpis_to_be_reported=${rep_kpis}


Stop Logs and Collect Traces
    [Timeout]  30 minutes
    ${status}=  Run Keyword And Return Status  Set SCOUT TC ID for Reporting
    IF  ${status}
        Log To Console  Scout ID was set successfully
    ELSE
        Log To Console  Scout ID was not set successfully
        RETURN
    END
    IF    '${LOGS_AND_TRACES_FLAGS["KPI"]["calculation"]}'=='True'
        scout_kpi.Disable KPI Collection
    END
    IF    '${Send_Data_ReP_Flag}' == 'True'   Run Keyword And Warn On Failure
    ...    Report Test Result To Reporting Portal


Report Test case status to reporting portal
    [Arguments]  ${pmcounters_to_be_reported}  ${swPostFix}  ${kpis_to_be_reported}
    ucl.kwrun  reporting.Online Reporting to ReP  tcName=${TEST_NAME}
    ...                                           tsResult=${TEST STATUS}
    ...                                           pmCounters=${pmcounters_to_be_reported}
    ...                                           swPostFix=${swPostFix}
    ...                                           kpi_results=${kpis_to_be_reported}


Report Passed Test case status to reporting portal
    [Arguments]  ${pmcounters_to_be_reported}  ${swPostFix}  ${kpis_to_be_reported}
    IF    '${TEST STATUS}'=='PASS'
        ucl.kwrun  reporting.Online Reporting to ReP  tcName=${TEST_NAME}
        ...                                           tsResult=Passed
        ...                                           pmCounters=${pmcounters_to_be_reported}
        ...                                           swPostFix=${swPostFix}
        ...                                           kpi_results=${kpis_to_be_reported}
    END
