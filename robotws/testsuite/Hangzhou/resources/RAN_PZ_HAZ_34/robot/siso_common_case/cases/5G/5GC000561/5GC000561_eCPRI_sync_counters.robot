*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/gnb_sync.robot
*** Variables ***


*** Keywords ***
5GC000561_eCPRI_sync_counters
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] The purpose of this test is to verify collecting PM counter data on eCPRI
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 2022.6.22 - - Created
    ...    *******************
    ...    Owner_jiayi.tang@nokia-sbell.com
    Selenium Logout And Close Browser
    Selenium Login And Disable Screen Lock
    ${origin_value}    Change NCPRI PM Interval   interval=5min
    Connect to Common Unit Master    alias=ASIK Master
    Check Sync Counter   change_interval=5
    Change NCPRI PM Interval    interval=15min
    Check Sync Counter   change_interval=15
    [Teardown]    Selenium Logout And Close Browser
