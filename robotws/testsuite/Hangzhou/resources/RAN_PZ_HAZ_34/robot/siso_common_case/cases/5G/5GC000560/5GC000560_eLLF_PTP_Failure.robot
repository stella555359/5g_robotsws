*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/gnb_sync.robot
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
    ...    - 30.9.2020 - - Created
    ...    *******************
    ...    Owner_jiangjing.lin@nokia-sbell.com
    ${sync_old}    get sync info of GNB
    set suite variable  ${sync_old}
    set sync info of GNB
    check sync status change of GNB
    Wait For Expect Fault Present    faultId=${16}    timeout=1200
    Wait For Expect Fault Present    faultId=${4298}    timeout=1200
    check sync info of RU    status='abnormal'
    set sync info of GNB    syncinput=${sync_old['syncinput']}    acceptclock=${sync_old['acceptclock']}
    Wait For Expect Fault To Disappear    faultId=${16}    timeout=1200
    Wait For Expect Fault To Disappear    faultId=${4298}    timeout=1200
    Wait For Expect Fault To Disappear    faultId=${1899}    timeout=1200
    Wait until keyword succeeds    20 min    20 sec   verify all cells should be onair
    check sync info of RU    status='normal'
