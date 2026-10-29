*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/gnb_sync.robot
*** Variables ***

*** Keywords ***
5GC000560_eLLF_sync_generic_startup_at_RU
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE] The purpose of this test is to verify eCPRI sync generic startup
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 29.10.2020 - - Created
    ...    *******************
    ...    Owner_jie-jessy.li@nokia-sbell.com
    ${stream}    get stream from version    ${Active_SW_version}
    ${check_content}    Set Variable If     '${stream}'=='SBTS00'        0        EeCpriStatus_NoError
    Check eCPRI PTP State via Btsom Log    check_content=${check_content}
