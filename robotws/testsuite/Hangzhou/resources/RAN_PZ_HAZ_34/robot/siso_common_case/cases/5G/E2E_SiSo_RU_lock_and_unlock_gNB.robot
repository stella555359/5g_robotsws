*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/ru_operation.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/recommissioning_and_make_throughput.robot

*** Keywords ***
E2E_SiSo_RU_lock_and_unlock_gNB
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] The purpose of this test case is to verify that radio module
    ...    and OAM behaves correctly during procedure of locking and unlocking.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 21.12.2021 - - Created
    ...    - rel7 ticket:https://jiradc.ext.net.nokia.com/browse/LEOPARD-1676
    ...    *******************
    ...    Owner_tingting.zhong@nokia-sbell.com
    [Arguments]  ${with_call}=${True}  ${with_peak}=${False}  ${call_duration}=${60}    ${upload_tp}=${True}
    ...    ${upload_duration}=${True}   ${suite_name}=default    ${test_name}=default    ${ue_num_each_call}=1
    ${ru_index_list}    get all ru index
    ${ru_num}    get length  ${ru_index_list}
    ${cell_list}    get all cell id
    Get X2 link shutdown waiting time
    Selenium Login And Disable Screen Lock
    ${check_alarm}    set variable if    ${ru_num}==1    ${True}    ${False}
    FOR  ${lock_id}  IN  @{ru_index_list}
        ${operate_list}    create list    ${lock_id}
        ${cell_list}    get all cell id    ru_index=${lock_id}
        run keyword if  ${with_call}    Get UE From Init File and Make call    cell_list=${cell_list}
        ...    with_peak=${with_peak}    duration=${call_duration}    upload_tp=${upload_tp}    upload_duration=${upload_duration}
        ...    ue_num_each_call=${ue_num_each_call}
        Lock all RUs and check status    ru_index_list=${operate_list}    check_alarm=${check_alarm}
        ...    gnb_type='${gNb_CuType}'
        #wait RU enter deepsleep state
        sleep    5min
        Unlock all RUs and check status    ru_index_list=${operate_list}    check_alarm=${check_alarm}
        ...    gnb_type='${gNb_CuType}'
        run keyword if  ${with_call}    Get UE From Init File and Make call    cell_list=${cell_list}
        ...    with_peak=${with_peak}    duration=${call_duration}    upload_tp=${upload_tp}    upload_duration=${upload_duration}
        ...    suite_name=${suite_name}    test_name=${test_name}    ue_num_each_call=${ue_num_each_call}
    END
    run keyword if  ${ru_num}>1    Lock and Unlock all RUs  lock_list=${ru_index_list}
    run keyword if  ${with_call} and ${ru_num}>1    Get UE From Init File and Make call    cell_list=${cell_list}
    ...    with_peak=${with_peak}    duration=${call_duration}    upload_tp=${upload_tp}    upload_duration=${upload_duration}
    ...    ue_num_each_call=${ue_num_each_call}
    [Teardown]  Selenium Logout And Close Browser
