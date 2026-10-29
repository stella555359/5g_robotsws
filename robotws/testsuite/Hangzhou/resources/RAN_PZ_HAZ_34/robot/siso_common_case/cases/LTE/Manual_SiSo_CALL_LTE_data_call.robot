*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/frame_structure_and_throughput.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/LTE/basic/scf_operation.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Common/basic/simple_ue.robot
*** Variables ***

*** Keywords ***
Manual_SiSo_CALL_LTE_data_call
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] The purpose of this test case is to verify LTE call functionality.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 15.07.2022 - - Created
    ...    *******************
    ...    Owner_xiaodong.d.chen@nokia-sbell.com
    [Arguments]    ${scf_path}
    Commissioning SCF And Check On Air LTE    scf_path=${scf_path}
    Simple UE L3 Call And Throughput
