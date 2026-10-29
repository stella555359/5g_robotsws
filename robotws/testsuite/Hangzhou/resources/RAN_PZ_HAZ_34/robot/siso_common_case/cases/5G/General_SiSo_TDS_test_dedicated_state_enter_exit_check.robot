*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Common/simple_keyword.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/common/coam.robot
*** Variables ***

*** Keywords ***
General_SiSo_TDS_test_dedicated_state_enter_exit_check
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE] The purpose of the case is to check test dedicated state enter exit
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 08.07.2019 - - Created
    ...    *******************
    ...    Owner_zhihao.shi@nokia-sbell.com
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]
    ${boundary}    get the boundary of stream    stream=${stream}
    Selenium Login And Disable Screen Lock    version=${stream}
    log to console    \enable test dedicated state
    selenium_coam.enable_test_dedicated_state
    sleep    180
    log to console    \Close Start Up View
    Run Keyword And Ignore Error    Close Start Up View    timeout=5
    Wait Until Keyword Succeeds    5min    30s    Cell Status Info Should Be Disabled
    ...    bs_blocked=Unblocked    cell_type=nr    boundary=${boundary}
    log to console    \disable test dedicated state
    selenium_coam.disable_test_dedicated_state
    sleep    180
    log to console    \Close Start Up View
    Run Keyword And Ignore Error    Close Start Up View    timeout=5
    Wait Until Keyword Succeeds    5min    30s    Cell Status Info Should Be Enable
    ...    cell_type=nr    boundary=${boundary}
    [Teardown]  selenium logout and close browser
