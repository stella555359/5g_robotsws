*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/cell_addition_deletion_online.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/recommissioning_and_make_throughput.robot
*** Variables ***

*** Keywords ***
General_SiSo_Online_Cell_addition_deletion
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] The purpose of this test case is to verify that cell addition and cell deletion function works well on WebEM
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 09.15.2020 - - Created
    ...    *******************
    ...    Notice: addition_deletion_cell: cell id for deletion then addition, more than 1 cell on site
    ...    *******************
    ...    Owner_tingting.zhong@nokia-sbell.com
    [Arguments]  ${check_cell}=${None}    ${suite_name}=default    ${test_name}=default    ${dl_tp}=300M    ${ul_tp}=20M    ${check_ue}=${False}
    ${check_cell}    run keyword if    '${check_cell}'=='${None}'    Get Ues Attached Cell    ue_num_each_call=1
    ...    ELSE    convert to integer    ${check_cell}
    ${check_cell_list}    create list    ${check_cell}
    Get UE From Init File and Make call  cell_list=${check_cell_list}    suite_name=${suite_name}    test_name=${test_name}
    ...    dl_tp=${dl_tp}    ul_tp=${ul_tp}    check_ue=${check_ue}
    Online Cell addition deletion   addition_deletion_cell=${check_cell}
    Get UE From Init File and Make call  cell_list=${check_cell_list}    suite_name=${suite_name}    test_name=${test_name}
    ...    dl_tp=${dl_tp}    ul_tp=${ul_tp}    check_ue=${check_ue}
