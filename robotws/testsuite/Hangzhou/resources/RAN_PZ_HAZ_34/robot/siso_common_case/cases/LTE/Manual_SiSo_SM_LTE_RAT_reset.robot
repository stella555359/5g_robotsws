*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_LTE.robot
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/frame_structure_and_throughput.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot

*** Variables ***

*** Keywords ***
Manual_SiSo_SM_LTE_RAT_reset
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] The purpose of this test case is to verify LTE rat reset functionality.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 14.06.2022 - - Created
    ...    *******************
    ...    Owner_tong.chen@nokia-sbell.com
    [Arguments]  ${with_call}=${True}  ${with_peak}=${False}  ${call_duration}=${60}
    Selenium Logout And Close Browser
    Selenium Login And Disable Screen Lock    download_dir=${CASE_LOG_PATH}    url=https://${sbts_addr}
    ...    username=${http_username}    password=${http_password}
    Unexpect Alarm Should Not Exist    allowed_faults=${ALLOWED_FAULT}
    selenium_coam.reset_lte    cancel=True
    Verify all cells should be onair    cell_type=lte
    selenium_coam.reset_lte
    Wait Until Keyword Succeeds    2min    3s    Cell Status Info Should Be Disabled    bs_blocked=Unblocked
    Wait Until Keyword Succeeds    30min    30s    Verify all cells should be onair    cell_type=lte
    Unexpect Alarm Should Not Exist    allowed_faults=${ALLOWED_FAULT}
    [Teardown]   Selenium Logout And Close Browser