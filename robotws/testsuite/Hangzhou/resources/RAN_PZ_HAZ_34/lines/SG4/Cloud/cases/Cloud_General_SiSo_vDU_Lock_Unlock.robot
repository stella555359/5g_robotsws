*** Settings ***
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_bts.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_vdu.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_vcu.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_throughput.robot

*** Keywords ***
Cloud_General_SiSo_vDU_Lock_Unlock
    [Documentation]    *****************
    ...    Basic information
    ...    *****************
    ...    Description in reStructuredText format on what is tested
    ...    *****************
    ...    - [TEST PURPOSE] This test case is used to verify vDU lock from vCU WebUI interface. Basic start-up of vDU procedure
    ...    is also verified. In case of stability check vDU lock can be performed multiple times.
    ...    *******************
    ...    History of changes
    ...    ******************
    ...    - 29.03.2024 - - Created
    ...    *******************
    ...    Owner_tingting.zhong@nokia-sbell.com
    [Arguments]  ${with_call}=${True}   ${suite_name}=default    ${test_name}=default
    ${du_id_list}    Create List    1
    Cloud Lock vDU And Check Result    du_id_list=${du_id_list}
    All Rmods Should Be Onair For One Specific vDU
    wait until keyword succeeds     3min    5s    Verify All Cells Are Disabled for vDU
    wait until keyword succeeds     3min    5s    Verify All Cells Are Disabled for vCU
    Cloud Unlock vDU And Check Result    du_id_list=${du_id_list}
    wait until keyword succeeds     10min    5s    All Cells Should Be Onair For One Specific vDU
    wait until keyword succeeds     3min    5s    All Cells Should Be Onair For One Specific vCU
    ${cell_list}   vDU Get Cell List From Webem
    run keyword if    ${with_call}    Cloud UE L3 Call And Throughput    cell_list=${cell_list}
    ...    suite_name=${suite_name}    test_name=${test_name}
