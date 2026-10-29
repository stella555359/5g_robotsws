*** Settings ***
Documentation         keywords for counter benchmarking. It helps user to collect, analyse and
...                   Save the counter values for benchmarking.
Library    ../../../../../resources/python/counter_benchmark.py
Library    taf.collectors.pmcounters    WITH NAME    gnb_pmcounters
Library    taf.analyzer.pmcounter
Library    DateTime
Library    OperatingSystem

*** Variables ***
${start_date}    None
${end_date}    None
${log_entries}    None

*** Keywords ***
Start_Fetching_Counter_Values
    ${start_counter_date}=    Get Current Date
	Set Test Variable    ${start_counter_date}
    Log    The test case name is: ${TEST NAME}
    [Return]    ${start_counter_date}

Stop_Fetching_Counter_Values
    ${end_counter_date}=    Get Current Date
	Set Test Variable    ${end_counter_date}
    [Return]    ${end_counter_date}

Collect_Counter_Logs
    [Arguments]    ${host}    ${user}    ${password}    ${Log_Path}    ${counter_json_file}    ${git_commit_path}
    ${webservice}=  Create Dictionary
    ...  host=${host}
    ...  user=${user}
    ...  password=${password}
    ${interval}    ${sw_version}=     get_admin_pminterval    ${webservice}
    Set Test Variable    ${sw_version}
    ${for_last}=     wait_for_the_log    ${start_counter_date}    ${end_counter_date}    ${interval}
    log    {gnb_pm_counters}
    gnb_pmcounters.create PM collector
    ...  name=gnb_pm_counters
    ...  webservice=${webservice}
    ...  for_last=${for_last}
    gnb_pmcounters.setup_collectors
    ...  names=gnb_pm_counters
    log    ${Log_Path}
    log    ${Log_Path}gnb_pm_counters/
    gnb_pmcounters.collect_collectors
    ...  names=gnb_pm_counters     target_dir=${Log_Path}
    gnb_pmcounters.teardown_collectors
    ...  names=gnb_pm_counters
    ${path}=    Join Path    ${Log_Path}     gnb_pm_counters
    ${path1}=    Convert To String    ${path}
    ${log_entries}=    Evaluate
    ...    list(taf.analyzer.pmcounter.PMCounterLogReader.from_dir(dir_path="${path1}", file_pattern="PM*"))
    ...    taf,taf.analyzer,taf.analyzer.pmcounter
    Set Test Variable    ${log_entries}
#    ${sw_version}=     Set Variable     avccsccsc
    ${sw_version}=      Get gNB SW version
    log    ${sw_version}
    Set Test Variable    ${sw_version}
    log    ${log_entries}
	Write_Counter_Values_To_Excel    ${counter_json_file}     ${git_commit_path}

Write_Counter_Values_To_Excel
    [Arguments]    ${counter_json_file}     ${git_commit_path}
    log    ${sw_version}
    log    ${log_entries}
    ${output}=    write_counter     ${sw_version}    ${TEST NAME}   ${log_entries}    ${counter_json_file}
	...    ${start_counter_date}    ${end_counter_date}     ${git_commit_path}
    log    ${output}
