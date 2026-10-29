*** Settings ***
Documentation    Set of keywords using to collect and analyse pm counters

Library    BuiltIn
Library    Collections
Library    DateTime
Library    OperatingSystem
Library    String
Library    taf.collectors.pmcounters
Library    taf.analyzer.pmcounter
Library    pm_analysing.py

*** Keywords ***
Adjust Time To New Pm Interval
    [Arguments]    ${pm_check}=${False}
    Log    --- Count sleep time to await for new pm interval ---    console=True
    ${current_min}    ${current_sec}=    Get Time    min,sec
    ${time_to_sleep}=    Run Keyword If    0<=${current_min[1]}<5    Subtract Time From Time    05:00    0${current_min[1]}:${current_sec}
    ...  ELSE IF      5<=${current_min[1]}<=9    Subtract Time From Time    10:00    0${current_min[1]}:${current_sec}
#    ...  ELSE IF      ${current_min[1]}<=0
    ${time_to_sleep}=    Run Keyword If    ${pm_check}    Add Time To Time    ${time_to_sleep}    00:45    ELSE    Set Variable    ${time_to_sleep}
    Log    --- Sleep: ${time_to_sleep} to await for new pm interval ---    console=True
    Sleep    ${time_to_sleep}
    Log    --- Sleep finished ---    console=True

Collect Counters
    [Arguments]    ${pm_dir_path}    ${time}=300
    ${webservice}=  Create Dictionary
    ...  host=192.168.255.129
    ...  user=Nemuadmin
    ...  password=nemuuser
    ...  port=443
#    ...  release=SBTS25R2
    taf.collectors.pmcounters.create PM collector
    ...  name=PM_counters
    ...  webservice=${webservice}
    ...  for_last=${time}s
    ...  intervals=5
    taf.collectors.pmcounters.setup_collectors
    ...  names=PM_counters
    taf.collectors.pmcounters.collect_collectors
    ...  names=PM_counters
    ...  target_dir=${pm_dir_path}
    taf.collectors.pmcounters.teardown_collectors
    ...  names=PM_counters
    ${pm_file}=    Run    cd ${pm_dir_path}/PM_counters && ls *.ANY.xml
    [Return]    ${pm_dir_path}/PM_counters/${pm_file}

Check Counter Condition
    [Arguments]    ${path}    @{counters}
    Adjust Time To New Pm Interval    ${True}
    Log    ${counters}
    ${pm_file}=    Collect Counters    pm_dir_path=${path}
    Check Counter Conditions    ${pm_file}    @{counters}

Collect Kpis From Scout
    # WIP
    get kpi from scout    start_time=2025-05-04T13:50:52    end_time=2025-05-04T14:10:52    10_16_MRBTS-50560
#    taf.sw.scout.setup_scout    10_16_MRBTS-50560
#    ${kpi}=    taf.sw.scout.get_kpi    	NR_5150a    start_time=2025-05-04T13:50:52    end_time=2025-05-04T14:10:52
#    ...    start_time=2025-05-05T13:50:52.646000    end_time=2025-05-05T14:10:52.646000
#    log    ${kpi}
#    ${kpi}=    taf.sw.scout.get_kpi    SCOUT_NR_219b_5G_Average_PRB_utilization_ratio    start_time=2025-05-05T16:30:52.646000
#    ...    end_time=2025-05-05T16:45:52.646000
#    log    ${kpi}
#    [Teardown]    taf.sw.scout.teardown_scout_api

