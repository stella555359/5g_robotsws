*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/cell_addition_deletion_online.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/recommissioning_and_make_throughput.robot
*** Variables ***

*** Keywords ***
General_SiSo_Online_Cell_addition_deletion_Sametimes
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] The purpose of this test case is to verify that cell addition and cell deletion function works well on WebEM
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 26.07.2022 - - Created
    ...    *******************
    ...    Notice: addition_deletion_cell: cell id for deletion then addition, more than 1 cell on site
    ...    case for PR676293
    ...    *******************
    ...    Owner_tingting.zhong@nokia-sbell.com
    [Arguments]  ${wrong_cell}=${True}
    ${check_cell}    Get Ues Attached Cell    ue_num_each_call=1
    ${check_cell_list}    create list    ${check_cell}
    Get UE From Init File and Make call  cell_list=${check_cell_list}
    selenium login and disable screen lock
    ${lcrid}    Get lcrId via webem    cell_id=${check_cell}
    ${gscn}    Get gscn via webem    cell_id=${check_cell}
    run keyword if    ${wrong_cell}    Online Modify Cell to Wrong    cell_id=${check_cell}
    ${new_cell}    Online Add New Cell and Delete Old Cell   cell_id=${check_cell}    lcrid=${lcrid}    gscn=${gscn}
    Get UE From Init File and Make call  cell_list=${check_cell_list}
    [Teardown]  run keywords     selenium logout and close browser    AND
    ...    COAM Commission with scf file    scf_file_path=${Case_SCF_Path}    timeout=600    AND
    ...    sleep  200s  reason=sleep 200s after scf commission!    AND
    ...    coam wait gnb and cells ready    timeout=15min    gnb_type='${gNb_CuType}'
