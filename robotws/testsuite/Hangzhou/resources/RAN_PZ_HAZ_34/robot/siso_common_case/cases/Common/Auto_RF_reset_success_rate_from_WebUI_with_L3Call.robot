*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_coam.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/common/selenium.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Common/basic/simple_ue.robot
*** Variables ***

*** Keywords ***
Auto_RF_reset_success_rate_from_WebUI_with_L3Call
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] The purpose of this test case is to verify success rate of Radio Unit reset activated from WebUI interface.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 04.01.2021 - - Created
    ...    *******************
    ...    Owner_zhihao.shi@nokia-sbell.com
    [Arguments]  ${ru_index}=1
    selenium_coam.reset_ru  ru_index=${ru_index}
    Wait Until Keyword Succeeds    5min    5s    RU Should Be Offline    ru_index=${ru_index}
    Wait until keyword succeeds    10min    30s    RU Should Be Online    ru_index=${ru_index}
    Wait until keyword succeeds    10min    30s    Verify all cells should be onair    cell_type=${cell_type}
    Simple UE L3 Call And Throughput

