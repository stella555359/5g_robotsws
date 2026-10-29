*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/recommissioning_and_make_throughput.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/ru_operation.robot


*** Keywords ***
General_SiSo_RAT_Block_Unblock_with_L3call
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE] The purpose of this test case is to verify that RAT and site behaves correctly during
    ...    procedure of RAT block unblock triggered by user from WEBUI.
    ...    ******************
    ...    Author:kaihui.fan@nokia-sbell.com
    [Arguments]  ${with_call}=${False}  ${with_peak}=${False}  ${duration}=${30}
    ...    ${connection}=GNB_OAM    ${check_ue}=${False}
    log to console    RAT_block_unblock_via_WEBUI
    Selenium Login And Disable Screen Lock
    Close Start Up View    timeout=60
    sleep    5s
    AlarmWatchdog.add_allow_alarms    fault_id=4614
    selenium_coam.block_rat    NR
    Wait For Expect Fault Present    faultId=4614    timeout=180
    sleep    30s
    selenium_coam.unblock_rat    NR
    Wait For Expect Fault To Disappear  faultId=4614    timeout=180
    AlarmWatchdog.remove_allow_alarms    fault_id=4614
    Wait Until Keyword Succeeds    10min    20s    Verify all cells should be onair
    Connect to gnb coam via ssl    connection=${connection}
    ${ru_index_list}  Get All RU Index
    FOR  ${ru_index}  IN  @{ru_index_list}
        ${cell_list}    Get All Cell Id    ${ru_index}
        run keyword if  ${with_call}  Get UE From Init File and Make call  cell_list=${cell_list}
        ...    with_peak=${with_peak}  duration=${duration}    check_ue=${check_ue}
    END
    [Teardown]    Selenium Logout And Close Browser
