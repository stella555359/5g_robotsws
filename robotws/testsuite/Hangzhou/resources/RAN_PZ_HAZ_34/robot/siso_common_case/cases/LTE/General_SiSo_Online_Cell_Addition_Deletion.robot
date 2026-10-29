*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/common/selenium.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Common/basic/simple_ue.robot
*** Variables ***

*** Keywords ***
General_SiSo_Online_Cell_Addition_Deletion
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] The purpose of this test case is to perform online cell addition and deletion from WebUI
    ...    under tested configuration (which is capable of adding another cell for the same sector).
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 04.20.2021 - - Created
    ...    *******************
    ...    Owner_zhihao.shi@nokia-sbell.com
    [Arguments]   ${operation_cell_id}=${2}    ${new_earfcn}=${41990}
    Online Cell deletion for LTE    delete_cell_id=${operation_cell_id}
    Online Cell addition for LTE    add_cell_id=${operation_cell_id}    new_earfcn=${new_earfcn}
    Wait until keyword succeeds    10min    30s    Verify all cells should be onair    cell_type=${cell_type}
    Simple UE L3 Call And Throughput
    Online Cell deletion for LTE    delete_cell_id=${operation_cell_id}
    Wait until keyword succeeds    10min    30s    Verify all cells should be onair    cell_type=${cell_type}
