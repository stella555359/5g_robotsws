*** Settings ***
Library           taf.ue.tm500.rtc    WITH NAME    tma
Library           ../PythonKeywords/RTC_handler.py
Library           Collections

*** Variable ***
${USE_COLLECTOR}        True
${ANALYSIS_TEMPLATE}    Case_xyz_analysis
${run_analysis}         False
${TC_NAME}              Test case1
${campaign_result}      FAIL

*** Keywords ***
Close all instances of TMAs and run new TMA
    Log To Console    Close all instances of TMA and start a new TMA instance
    tma.close_all_instances_of_tma
    BuiltIn.Sleep                    5s
    ${response}    tma.open_the_tma_in_given_mode    ${tma_type}    ${tma_path}    ${mci_port}
    ...    ${aci_port}    ${tma_profile}
    # Log To Console                   Wait 40s until TMA is ready
    # BuiltIn.Sleep                    40s

Get scheduled campaign name
    ${campaign_name_from_path}    get_campaign_name_from_path    ${campaign_path}
    Set Global Variable    ${campaign_name_from_path}
    Log To Console    Campaign name parsed from path: ${campaign_name_from_path}

Close TMAs and Schedule campaign
    tma.open_rtc_connection    ${ip}
    Close all instances of TMAs and run new TMA
    Get scheduled campaign name
    Add campaign to campaign scheduler and verifying that the operation was successful

Add campaign to campaign scheduler and verifying that the operation was successful
    ${campaign_name}    tma.schedule_campaign    ${campaign_path}    ${iteration_count}
    ...    ${action_on_event}    ${date}    ${time}
    ${campaign_started}=  Evaluate   "${campaign_name_from_path}" in """${campaign_name}"""
    Run Keyword If    '${campaign_started}' == 'False'
    ...    Fail    msg=TMA not responding. Campaign scheduling failed. Case will stop.
    Set Global Variable    ${campaign_name}
    BuiltIn.Sleep    5s

Start scheduled campaign and verifying that the operation was successful
    ${response}    tma.run_a_scheduled_e500_campaign    ${campaign_name.strip()}
    ...    ${add_to_active_scheduler}
    Log to Console    ${response}
    ${analysis_start}=  Evaluate   "Run started for campaign" in """${response}"""
    Set Test Variable    ${run_analysis}    ${analysis_start}
    Run Keyword If    '${analysis_start}' == 'False'
    ...    Fail    msg=Campaign not started

Start cheking running status and statistics. Get verdict from campaign scheduler
    ${object}=  Get library instance  tma
    ${result}    check_run_status_and_statistics    ${object}    ${test_duration_in_minutes}

    Run Keyword If    '${result['stop']}' == 'True'
    ...    tma.stop_a_running_e500_campaign

    Log To Console    Campaign result: ${result['success']}
    Set Test Variable    ${campaign_result}    ${result['success']}
    should be equal as strings        ${result['success']}    PASS    msg=Campaign execution failed

Start datacollectors
    Run Keyword If    '${USE_COLLECTOR}' == 'True'
    ...           Start DataCollector

Forse stop testcase execution
    Run Keyword If    '${campaign_result}' != 'PASS' and '${run_analysis}' == 'True'
    ...    tma.stop_a_running_e500_campaign
    Run Keyword If    '${USE_COLLECTOR}' == 'True'
    ...    Run Keyword IF    '${run_analysis}' == 'True'
    ...    Stop DataCollectors and Run Analysis    ${ANALYSIS_TEMPLATE}
    Print Test Status To Log

Print Test Status To Log
    Log To Console    Test case ${TC_NAME} result for Jenkins summary view is ${TEST_STATUS}
    Set Suite Metadata    TC_NAME    ${TC_NAME}
    Set Suite Metadata    TC_STATUS    ${TEST_STATUS}