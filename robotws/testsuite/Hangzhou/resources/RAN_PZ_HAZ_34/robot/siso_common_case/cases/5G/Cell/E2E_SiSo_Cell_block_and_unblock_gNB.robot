*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/operate_cell_and_check.robot


*** Keywords ***
E2E_SiSo_Cell_block_and_unblock_gNB
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE] To verify cell and group cell block/ unblock functionality
    ...      during normal operation (OnAir state).
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 26.09.2021 - - Created
    ...    *******************
    ...    Owner_tingting.zhong@nokia-sbell.com
    [Arguments]  ${with_call}=${True}  ${with_peak}=${False}  ${call_duration}=${60}    ${ue_num_each_call}=1
    ...    ${upload_tp}=${True}    ${upload_duration}=${True}  ${suite_name}=default    ${test_name}=default
    ...    ${check_ue}=${False}
    Get X2 link shutdown waiting time
    Selenium Login And Disable Screen Lock
    
    Modify Parameter if Need Modify    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ...    filter_param=Activate radio deep sleep time schedule
    ...    new_value=false
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=${False}    timeout=${300}

    ${cell_id_list}  Get All Cell Id
    ${cell_num}    get length  ${cell_id_list}
    ${check_alarm}  set variable if  ${cell_num}==1  ${True}  ${False}
    FOR  ${block_id}  IN  @{cell_id_list}
        ${operate_list}    create list    ${block_id}
        run keyword if  ${with_call}    Get UE From Init File and Make call    cell_list=${operate_list}  with_peak=${with_peak}
        ...    duration=${call_duration}    upload_tp=${upload_tp}    upload_duration=${upload_duration}
        ...    suite_name=${suite_name}    test_name=${test_name}    check_ue=${check_ue}
        Block cells and check status   block_list=${operate_list}   check_alarm=${check_alarm}    gnb_type='${gNb_CuType}'
        UnBlock Cells and check status   block_list=${operate_list}   check_alarm=${check_alarm}    gnb_type='${gNb_CuType}'
        run keyword if  ${with_call}    Get UE From Init File and Make call    cell_list=${operate_list}  with_peak=${with_peak}
        ...    duration=${call_duration}    upload_tp=${upload_tp}    upload_duration=${upload_duration}
        ...    suite_name=${suite_name}    test_name=${test_name}    check_ue=${check_ue}
    END
    ${check_cell}    run keyword if    ${with_call} and ${cell_num}>1    Get Ues Attached Cell    ue_num_each_call=1
    ${check_list}    create list    ${check_cell}
    ${other_cells}    Get Other Ids    id_list=${cell_id_list}    given_id=${check_cell}
    run keyword if    ${with_call} and ${cell_num}>1    run keywords    Block cells and check status   block_list=${other_cells}
    ...    check_alarm=${check_alarm}    gnb_type='${gNb_CuType}'    AND
    ...    Get UE From Init File and Make call    cell_list=${check_list}  with_peak=${with_peak}
    ...    duration=${call_duration}    upload_tp=${upload_tp}    upload_duration=${upload_duration}
    ...    suite_name=${suite_name}    test_name=${test_name}    AND
    ...    UnBlock Cells and check status   block_list=${other_cells}   check_alarm=${check_alarm}    gnb_type='${gNb_CuType}'
    run keyword if  ${cell_num}>1    Block and UnBlock Cells    block_list=${cell_id_list}
    run keyword if  ${cell_num}>1 and ${with_call}    Get UE From Init File and Make call    cell_list=${cell_id_list}
    ...    with_peak=${with_peak}    duration=${call_duration}    ue_num_each_call=${ue_num_each_call}
    ...    upload_tp=${upload_tp}    upload_duration=${upload_duration}
    ...    suite_name=${suite_name}    test_name=${test_name}
    [Teardown]   Selenium Logout And Close Browser
