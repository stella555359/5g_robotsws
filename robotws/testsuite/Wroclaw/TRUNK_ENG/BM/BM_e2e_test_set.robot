*** Settings ***
Documentation  Business Manager End-to-End test set

Library  OperatingSystem
Library  Process

*** Test Cases ***
[1]BM_test_context
    Do some work

[1]BM_test_no_state
    Do some work

[1]BM_test_no_timeout
    Do some work

*** Keywords ***
Do some work
    Sleep  5
    ${env_variables}=  run process  env
    log to console  ${env_variables.stdout}
    ${reservation_context}=    get file    /opt/ute/reservation.context.json
    log to console  ${reservation_context}
    ${execution_context}=      get file    /opt/ute/execution.context.json
    log to console  ${execution_context}

