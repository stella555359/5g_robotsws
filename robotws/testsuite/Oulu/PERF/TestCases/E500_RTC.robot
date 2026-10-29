*** Settings ***
Suite Setup       Run Keyword If    '${USE_COLLECTOR}' == 'True'    Create DataCollector Test Run
Suite Teardown    Run Keyword If    '${USE_COLLECTOR}' == 'True'    Stop DataCollector Test Run
Resource          ../CommonKeywords/RobotKeywords/data_collector.robot
Resource          ../CommonKeywords/RobotKeywords/rtc_control.robot

*** Variables ***
${test_duration_in_minutes}
${ip}                         address to tma lmp computer
${tma_type}                   ${1}
${tma_path}                   None
${mci_port}                   ${5003}
${aci_port}                   ${5030}
${tma_profile}                None

${campaign_path}              Path to campaign
${iteration_count}            ${1}
${action_on_event}            ${2}
${date}                       None
${time}                       None

${campaign_name}              None
${add_to_active_scheduler}    None

${cmd}                        forw mte  GetStats [PHY] [COMBINED] [COMBINED]
${cmd_timeout}                ${2}

${campaign_result}            FAIL

*** Test Cases ***
Run E500 campaign via RTC
    Log To Console    Test Duration: ${test_duration_in_minutes}
    Log to Console    Remote connection address: ${ip}
    Log to Console    Campaign path: ${campaign_path}

    Wait Until Keyword Succeeds    3x    10 sec    Close TMAs and Schedule campaign
    Start scheduled campaign and verifying that the operation was successful
    Start datacollectors
    Start cheking running status and statistics. Get verdict from campaign scheduler
    [Teardown]    Forse stop testcase execution