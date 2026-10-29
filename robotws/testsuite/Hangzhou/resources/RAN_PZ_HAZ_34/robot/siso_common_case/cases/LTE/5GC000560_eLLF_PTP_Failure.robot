*** Settings ***
Documentation    This is common keywords for LTE siso related cases
...              Please do not modify the file without notification to author

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/LTE/basic/sync_startup.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/LTE/basic/ru_operation.robot

*** Variables ***

*** Keywords ***
5GC000560_eLLF_PTP_Failure
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE] The purpose of this test is to verify when set wrong input sync for RAU
    ...    the syncstatus and lockstatus changed right both on webUI and RU soap log
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 2022.4.20 - - Created
    ...    *******************
    ...    Owner_jiayi.tang@nokia-sbell.com
    ${sync_old}    get sync info of LTE
    set suite variable  ${sync_old}
    set sync info of LTE
    check sync status change of LTE
    Wait For Expect Fault Present LTE   faultId=${16}    timeout=1200
    Wait For Expect Fault Present LTE    faultId=${1899}    timeout=1200
    check sync info of RU LTE    status='abnormal'
    set sync info of LTE    syncinput=${sync_old['syncinput']}    acceptclock=${sync_old['acceptclock']}
    Wait For Expect Fault To Disappear LTE    faultId=${16}    timeout=1200
    Wait For Expect Fault To Disappear LTE    faultId=${1899}    timeout=1200
    Run Keyword And Ignore Error    check sync info of RU LTE    status='normal'
    Wait until keyword succeeds    20 min    20 sec   Verify all cells should be onair     cell_type=${cell_type}
