*** Settings ***
Documentation    This is common keywords for LTE siso related cases
...              Please do not modify the file without notification to author

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/LTE/basic/bpf.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/LTE/basic/sync_startup.robot

*** Variables ***

*** Keywords ***
5GC000561_eCPRI_sync_counters
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] The purpose of this test is to verify collecting PM counter data on eCPRI
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 2022.5.22 - - Created
    ...    *******************
    ...    Owner_jiayi.tang@nokia-sbell.com
    [Arguments]    ${TNL_ETHLK}=TNL-2/ETHLK/ETHLK-3
    ${origin_value}    Change NCPRI PM Interval LTE   interval=5min
    csn.connect to    hostname=${sbts_addr}    username=${ssh_username}    password=${ssh_password}  alias=ASIK Master
    Check Sync Counter LTE   change_interval=5    TNL_ETHLK=${TNL_ETHLK}
    Change NCPRI PM Interval LTE    interval=15min
    Check Sync Counter LTE   change_interval=15    TNL_ETHLK=${TNL_ETHLK}
    [Teardown]  csn.Disconnect    connection=ASIK Master

