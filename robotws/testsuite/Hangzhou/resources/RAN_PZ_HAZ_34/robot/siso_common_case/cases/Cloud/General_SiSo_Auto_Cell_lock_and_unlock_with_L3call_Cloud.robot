*** Settings ***
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_ru.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_vdu.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_vcu.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_bts.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_throughput.robot

*** Keywords ***
General_SiSo_Auto_Cell_lock_and_unlock_with_L3call
    [Documentation]    *****************
    ...    - [TEST PURPOSE] The purpose of this test case is to verify cell and group cell lock/ unlock functionality.
    ...    - [TEST PROCEDURE] The test procedure is as follows:
    ...        1. Lock Cell
    ...        2. Check Cell locked
    ...        3. Unlock Cell
    ...        4. Check Cell unlocked         
    ...        5. Check cell on air on vCU and vDU
    ...    - [EXPECTED RESULTS] the Cells should lock and unlock successfully.
    ...
    ...    | =Input Parameters= | =Mandatory= | =Description= |
    ...    | vdu_index | No | The vDU index. Default value is 0. |
    ...    | gnb_index | No | The gNB index. Default value is 0. |
    ...    | with_call | No | Flag for l3call. Default value is True. |
    ...    | suite_name | No | The suite name used for customed peak rate. Default value is default. |
    ...    | test_name | No | The test name used for customed peak rate. Default value is default. |

    ...    *******************
    ...    History of changes
    ...    ******************
    ...    - 05.15.2024  - Created
    ...    *******************
    ...    * Owner_jiayi.tang@nokia-sbell.com
    ...    * Group: VRF_HAZ3_T02
    ...    *******************
    [Arguments]    ${gnb_index}=0    ${vdu_index}=0    ${with_call}=${True}   ${suite_name}=default   ${test_name}=default
    log to console    Get Cell id list from Vdu
    ${cell_list}    Cloud Get Cells Id List    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    log to console    lock Cell on vDU
    Lock Cell on vDU    vdu_index=${vdu_index}    gnb_index=${gnb_index}     cell_id=${cell_list}
    Wait Until Keyword Succeeds    3min    5s    vDU Cells Status Should Be As Expected     cells_id_list=${cell_list}
        ...    vdu_index=${vdu_index}    gnb_index=${gnb_index}    administrative_state=Locked    operational_state=disabled
        ...   availability_status=off line    blocking_state=Unblocked
    log to console    Unlock Cell on vDU
    Unlock Cell on vDU    vdu_index=${vdu_index}    gnb_index=${gnb_index}    cell_id=${cell_list}
    log to console    All Cells Should Be Onair For All vDUs
    Wait Until Keyword Succeeds    15min    5s    All Cells Should Be Onair For All vDUs
    log to console    check cell status should be on air for cu...
    wait until keyword succeeds     5min    30s    All Cells Should Be Onair For One Specific vCU
    Run Keyword If    ${with_call}    Cloud UE L3 Call And Throughput    cell_list=${cell_index_list}
    ...    test_name=${test_name}    suite_name=${suite_name}
