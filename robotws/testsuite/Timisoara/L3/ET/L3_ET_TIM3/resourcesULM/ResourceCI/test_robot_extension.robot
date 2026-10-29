*** Settings ***
Library    ../python/robot_extension.py


*** Test Cases ***
Test Run Keyword And Warn On Failure Success Case With Positional Arg Only
    [TAGS]              ROBOT
    Run Keyword And Warn On Failure
    ...     Log To Console  \nThis shouldn't raise any warning!

Test Run Keyword And Warn On Failure Success Case With Named And Positional Args
    [TAGS]              ROBOT
    Run Keyword And Warn On Failure
    ...     Log To Console  \nThis shouldn't raise any warning!   no_newline=false  

Test Run Keyword And Warn On Failure With Positional Args Only
    [TAGS]              ROBOT
    Run Keyword And Warn On Failure
    ...     Should Be True  ${1}==${2}  Values should be equal

Test Run Keyword And Warn On Failure With Both Args
    [TAGS]              ROBOT
    Set Test Variable   ${TEST_VAR}     ${0}
    Run Keyword And Warn On Failure
    ...    Change Number   fail_limit=${5} 

*** Keywords ***
Change Number
    [Arguments]     ${fail_limit}=${0}
    Should Be True  ${TEST_VAR}>${fail_limit}
    Set Test Variable   ${TEST_VAR}     ${TEST_VAR-1}
    [Return]
