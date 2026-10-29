*** Settings ***
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_ru.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_vdu.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_vcu.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_bts.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_throughput.robot

*** Keywords ***
General_SiSo_Cell_block_and_unblock
    [Documentation]    *****************
    ...    - [TEST PURPOSE] To verify cell and group cell block/ unblock functionality
    ...      during normal operation (OnAir state).
    ...    - [TEST PROCEDURE] The test procedure is as follows:
    ...        1. Connect to vDU.
    ...        2. Block each cell.
    ...        3. Check cell disabled on vCU and vDU
    ...        4. Unblock each cell.
    ...        5. Check cell on air on vCU and vDU
    ...    - [EXPECTED RESULTS] Cells block and unlock successfully.
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
    [Arguments]    ${vdu_index}=0    ${gnb_index}=0    ${with_call}=${True}   ${suite_name}=default   ${test_name}=default
    log to console    Get Cell id list from Vdu
    ${cell_list}    Cloud Get Cells Id List    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    FOR    ${index}    IN    @{cell_list}
        Block Cell In vDU     cell_id=${index}    vdu_index=${vdu_index}    gnb_index=${gnb_index}
        Wait Until Keyword Succeeds    3min    5s    Check Cell Should Be Blocked On vDU    cell_id=${index}
        ...    vdu_index=${vdu_index}    gnb_index=${gnb_index}
        Wait Until Keyword Succeeds    5min    5s    Expect Fault Should Present On vDU    fault_id=49    vdu_index=${vdu_index}
        ...     gnb_index=${gnb_index}
        ...     alarming_object=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${index}
    END
    log to console    Verify All Cells Are Disabled for CU    
    Verify All Cells Are Disabled for vCU    gnb_index=${gnb_index}
    log to console    Unblock Cell In vDU
    FOR    ${index}    IN    @{cell_list}
        Unblock Cell In vDU    cell_id=${index}    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    END
    log to console    All Cells Should Be Onair For All vDUs
    Wait Until Keyword Succeeds    15min    5s    All Cells Should Be Onair For All vDUs
    log to console    check cell status should be on air for cu...
    wait until keyword succeeds     5min    30s    All Cells Should Be Onair For One Specific vCU
    Run Keyword If    ${with_call}    Cloud UE L3 Call And Throughput    cell_list=${cell_list}
    ...    test_name=${test_name}    suite_name=${suite_name}
