*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/operate_cell_and_check.robot
*** Variables ***

*** Keywords ***
E2E_SiSo_Cell_lock_and_unlock_gNB
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE] To verify  cell lock/ unlock functionality
    ...      during normal operation (OnAir state).
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 21.12.2021 - - Created
    ...    *******************
    ...    Owner_tingting.zhong@nokia-sbell.com
    [Arguments]  ${with_call}=${True}  ${with_peak}=${False}  ${call_duration}=${60}
    Get X2 link shutdown waiting time
    ${cell_id_list}  Get All Cell Id
    ${cell_num}    get length  ${cell_id_list}
    ${check_alarm}    set variable if    ${cell_num}==1    ${True}    ${False}
    FOR  ${lock_id}  IN  @{cell_id_list}
        ${operate_list}    create list    ${lock_id}
        run keyword if  ${with_call}    Get UE From Init File and Make call    cell_list=${operate_list}  with_peak=${with_peak}
        ...    duration=${call_duration}
        Lock cells or groups and check status  lock_list=${operate_list}  is_group=${False}  check_alarm=${check_alarm}
        ...    gnb_type='${gNb_CuType}'
        Unlock cells or groups and check status  lock_list=${operate_list}  is_group=${False}  check_alarm=${check_alarm}
        ...    gnb_type='${gNb_CuType}'
        run keyword if  ${with_call}    Get UE From Init File and Make call    cell_list=${operate_list}  with_peak=${with_peak}
        ...    duration=${call_duration}
    END
    run keyword if  ${cell_num}>1    Lock and Unlock all Cells or Groups  lock_list=${cell_id_list}  is_group=${False}
    run keyword if  ${cell_num}>1 and ${with_call}    Get UE From Init File and Make call    cell_list=${cell_id_list}
    ...    with_peak=${with_peak}    duration=${call_duration}
