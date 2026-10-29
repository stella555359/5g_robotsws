*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/frame_structure_and_throughput.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/LTE/basic/scf_operation.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Common/basic/simple_ue.robot

*** Variables ***

*** Keywords ***
Multi Carrier_Commission and Throughput with DL interference
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] The purpose of this test case is to verify LTE muti_carrier call functionality.
    ...    UE0---Cell1; UE1---Cell2
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 25.07.2022 - - Created
    ...    *******************
    ...    Owner_xiaodong.d.chen@nokia-sbell.com
    [Arguments]    ${scf_path}
    ${cell_1_list}    create list    ${1}
    ${cell_2_list}    create list    ${2}
    Commissioning SCF And Check On Air LTE    scf_path=${scf_path}
    Simple UE L3 Call And Throughput    cell_list=${cell_1_list}
    Simple UE L3 Call And Throughput    cell_list=${cell_2_list}
