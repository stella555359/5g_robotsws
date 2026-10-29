*** Settings ***
Suite Setup       Suite Setup
Suite Teardown    Suite Teardown
Test Setup        Test Setup
Test Teardown     Test Teardown
Resource          ../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_EMIL}
${AUTO_ANALYSIS_FLAG}    ${False}
${BTS_NUMBER}     1

*** Test Cases ***
Capture Logs
    Log To Console    ${EMPTY}
    Log To Console    \##########################
    Log To Console    You can start your testing now
    Log To Console    Press CTRL-C for only one time if finished...
    Sleep    10h

*** Keywords ***
Suite Setup
    Common Suite Setup
    _get cus info
    _Set VM Ip

Test Setup
    Set Suite Variable    ${IM_FLAG}    ${False}    #IM log can't be captured due to CTRL-C later, but anyway it is already in snapshot
    Common Test Setup And Start To Capture Logs
    execute uex command    sib_status  # in order to start uexgate to start uex logs

Test Teardown
    Common Test Teardown And Stop Capture Logs

Suite Teardown
    Execute Cmd On Pc    ls -ltR ${SUITE_LOG_DIRECTORY}
    Execute Cmd On Pc    rm -rf ${SUITE_LOG_DIRECTORY}/admin_api*.log
    Common Suite Teardown
    Log To Console    all logs are in ${SUITE_LOG_DIRECTORY}
    Log To Console    \##########################
