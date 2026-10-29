*** Settings ***
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_ru.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_vdu.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_vcu.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_bts.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_throughput.robot

*** Keywords ***
General_SiSo_Online_Cell_Addition_Deletion
    [Documentation]    *****************
    ...    - [TEST PURPOSE] The purpose of this test case is to perform online cell addition and deletion from WebUI under tested configuration.
    ...    - [TEST PROCEDURE] The test procedure is as follows:
    ...        1. Deletion cell 
    ...        2. Check Cell onair and L3call is ok
    ...        3. Addition Cell
    ...        4. Check Cell onair and L3call is ok
    ...    - [EXPECTED RESULTS] the Cells should addition and deletion successfully.
    ...
    ...    | =Input Parameters= | =Mandatory= | =Description= |
    ...    | deletion_scf | Yes | The deletion delta scf. No default value. |
    ...    | addition_scf | Yes | The addition delta scf. No default value. |
    ...    | vdu_index | No | The vDU index. Default value is 0. |
    ...    | gnb_index | No | The gNB index. Default value is 0. |
    ...    | with_call | No | Flag for l3call. Default value is True. |
    ...    | suite_name | No | The suite name used for customed peak rate. Default value is default. |
    ...    | test_name | No | The test name used for customed peak rate. Default value is default. |

    ...    *******************
    ...    History of changes
    ...    ******************
    ...    - 11.06.2024  - Created
    ...    *******************
    ...    * Owner_jiayi.tang@nokia-sbell.com
    ...    * Group: VRF_HAZ3_T02
    ...    *******************
    [Arguments]    ${du_deletion_scf}    ${cu_deletion_scf}    ${du_addition_scf}    ${cu_addition_scf}    ${gnb_index}=0    ${vdu_index}=0
    ...            ${with_call}=${True}    ${suite_name}=default    ${test_name}=default
	log to console    Get Cell id list from vdu
    ${cell_list}    Cloud Get Cells Id List    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    log to console    Deletion Cell on vDU
    Deletion Cell on vDU   du_deletion_scf=${du_deletion_scf}    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    log to console    Deletion Cell on vCU
    Deletion Cell on vCU   cu_deletion_scf=${cu_deletion_scf}    gnb_index=${gnb_index}
    Check Cell Onair and L3call    cell_list=${cell_list}    with_call=${with_call}    suite_name=${suite_name}   test_name=${test_name}
	...    test_name=${test_name}    suite_name=${suite_name}
    log to console    Addition Cell on vDU
    Addition Cell on vDU    du_addition_scf=${du_addition_scf}    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    log to console    Addition Cell on vCU
    Addition Cell on vCU   cu_addition_scf=${cu_addition_scf}    gnb_index=${gnb_index}
    log to console    All Cells Should Be Onair and L3call
    Check Cell Onair and L3call    cell_list=${cell_list}    with_call=${with_call}    suite_name=${suite_name}   test_name=${test_name}
	...    test_name=${test_name}    suite_name=${suite_name}

Check Cell Onair and L3call
    [Arguments]    ${cell_list}    ${with_call}=${True}    ${suite_name}=default    ${test_name}=default
    log to console    check cell status should be on air for du
    Wait Until Keyword Succeeds    15min    5s    All Cells Should Be Onair For All vDUs
    log to console    check cell status should be on air for cu
    Wait Until Keyword Succeeds     5min    30s    All Cells Should Be Onair For One Specific vCU
    Run Keyword If    ${with_call}    Cloud UE L3 Call And Throughput    cell_list=${cell_list}
    ...    suite_name=${suite_name}   test_name=${test_name}