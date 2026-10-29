*** Settings ***
Documentation  This is a testcase to retrieve tc_execution_id from TL,
...            input parameter is the scout_tl_name
Resource    ../reporting.robot


*** Test Cases ***

test_failcase
    ${foo}=  Run Keyword And Ignore Error  Set Id For Test
    ${bar}=  Set Variable If  '${foo[0]}'=='PASS'  ${foo[1]}  4711
    Log To Console  foo: ${bar}
get scout id directly
    ${id}=  Request Scout SCF ID  ${tl_name}
    Log To Console  ${id}

*** keywords ***
Set Id For Test
    ${test_id}=   Set Variable  test_id
    Should Be True  1=0
    RETURN  ${test_id}
