*** Settings ***
Documentation    This is common keywords for LTE siso related cases
...              Please do not modify the file without notification to author

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/LTE/basic/sync_startup.robot

*** Variables ***

*** Keywords ***
5GC000560_eCPRI_sync_generic_startup_at_RU
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] The purpose of this test is to verify eCPRI sync generic startup
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 2022.4.20 - - Created
    ...    *******************
    ...    Owner_jiayi.tang@nokia-sbell.com
    Check eCPRI PTP State via Btsom Log LTE
