*** Settings ***
Documentation    This is common keywords for LTE siso related cases
...              Please do not modify the file without notification to author

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/LTE/basic/bpf.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/LTE/basic/sync_startup.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/common/selenium.robot

*** Variables ***

*** Keywords ***
General_SiSo_Fault_1900_EFaultId_FrConfiguringFailed_PMAX
    [Documentation]    *****************
    ...    Basic information
    ...    *****************
    ...    Description in reStructuredText format on what is tested
    ...    *****************
    ...    - [TEST PURPOSE] To verify that LTE can report fault 1900: EFaultId_FrConfiguringFailed
    ...      after configuring pmax to out of range value of supported power.
    ...    *******************
    ...    History of changes
    ...    ******************
    ...    - 2022.5.20
    ...    *******************
    ...    Test case flowchart
    ...    *******************
    ...    jiayi.tang@nokia-sbell.com
    [Arguments]  ${cell_id}=1    ${ru_index}=1    ${variable_from_CFAM}=${Variables_CFAM}
    ${origin_params}  Modify pMax to tirgger fault LTE    cell_id=${cell_id}  ru_index=${ru_index}  variable_from_CFAM=${variable_from_CFAM}
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl
    ...    bts_host=${sbts_addr}    username=${http_username}    password=${http_password}
    Wait Until Keyword Succeeds    10min    30s    Alarm in Given Alarm list Present LTE
    [Teardown]  run keywords    Close Start Up View Window    timeout=60    AND
    ...    Modify Parameters On Webem LTE    ${origin_params}              AND
    ...    Wait until keyword succeeds    20 min    20 sec   verify all cells should be onair    cell_type=${cell_type}

