*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/frame_structure_and_throughput.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/LTE/basic/scf_operation.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Common/basic/simple_ue.robot
*** Variables ***

*** Keywords ***
Manual_Siso_CM_4G_uDTX
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] The purpose of this test case is to verify actMicroDtx and call functionality.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 15.07.2022 - - Created
    ...    *******************
    ...    Owner_xiaodong.d.chen@nokia-sbell.com
    [Arguments]    ${scf_path}
    Commissioning SCF And Check On Air LTE    scf_path=${scf_path}
    log to console   \n enable Power Saving mode
    Modify RMOD Power Parameter    power_status=true
    sleep    20
    Wait until keyword succeeds    10min    30s    Expect Fault Should Absent    faultId=4308
    Simple UE L3 Call And Throughput
    log to console   \n disable Power Saving mode
    Modify RMOD Power Parameter    power_status=false
    sleep    20
    Wait until keyword succeeds    10min    30s    Expect Fault Should Absent    faultId=4308
    Simple UE L3 Call And Throughput
