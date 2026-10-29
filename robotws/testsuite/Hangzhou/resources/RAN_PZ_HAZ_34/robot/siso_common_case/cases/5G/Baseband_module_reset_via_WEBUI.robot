*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/recommissioning_and_make_throughput.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/ru_operation.robot
*** Variables ***

*** Keywords ***
Baseband_module_reset_via_WEBUI
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE] The purpose of this test case is to verify that baseband module
    ...    and OAM behaves correctly during procedure of baseband module reset triggered by user from WEBUI.
    ...    ******************
    ...    Author:lanwen.cai@nokia-sbell.com
    [Arguments]  ${with_call}=${False}  ${with_peak}=${False}  ${duration}=${30}
    ${bbmod_index_list}  Get All BBmod Index
    Selenium Login And Disable Screen Lock
    close start up view    timeout=60
    log to console    start reset bbmod via WEBUI
    FOR  ${bbmod_index}  IN  @{bbmod_index_list}
        selenium_coam.reset_baseband    baseband_index=${bbmod_index}    timeout=30
        Wait Until Keyword Succeeds    5min    5s    bbmod Should Be Offline    bbmod_index=${bbmod_index}
    END
    coam wait gnb and cells ready    timeout=15min    gnb_type='${gNb_CuType}'
    ${ru_index_list}  Get All RU Index
    FOR  ${ru_index}  IN  @{ru_index_list}
        ${cell_list}    Get All Cell Id    ${ru_index}
        run keyword if  ${with_call}  Get UE From Init File and Make call  cell_list=${cell_list}
        ...    with_peak=${with_peak}  duration=${duration}
    END
    [Teardown]    Selenium Logout And Close Browser
