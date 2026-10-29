*** Settings ***
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_vdu.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_vcu.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_bts.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_throughput.robot
Resource    taf/rfrl/cbts/robot/vdu/vdu_operations.robot

*** Keywords ***
General_SiSo_vDU_Lock_Unlock
    [Documentation]    *****************
    ...    - [TEST PURPOSE] The purpose of this test case is to verify vDU lock and unlock operation from vCU WebUI.
    ...    - [TEST PROCEDURE] The test procedure is as follows:
    ...        1. Lock vDU from vCU WebEM
    ...        2. Check cell status, all cells are disable
    ...        3. Unlock vDU from vCU WebEm
    ...        4. Check cell status, all cells back to enable
    ...    - [EXPECTED RESULTS] vDU lock and unlock operation is successful.
    ...
    ...    | =Input Parameters= | =Mandatory= | =Description= |
    ...    | du_id_list | Yes | The list of vDU id. |
    ...    | gnb_index | No | The gNB index. Default value is 0. |
    ...    | with_call | No | Flag for l3call. Default value is True. |
    ...    | suite_name | No | The suite name used for customed peak rate. Default value is default. |
    ...    | test_name | No | The test name used for customed peak rate. Default value is default. |

    ...    *******************
    ...    History of changes
    ...    ******************
    ...    - 06.12.2024  - Created
    ...    *******************
    ...    * Owner_wenjin.zhang@nokia-sbell.com
    ...    * Group: VRF_HAZ4_T01
    ...    *******************
    [Arguments]    ${du_id_list}    ${gnb_index}=0    ${with_call}=${False}   ${suite_name}=default   ${test_name}=default
    log to console    lock vDU from vCU WebEM
    Cloud Lock vDU And Check Result    du_id_list=${du_id_list}    gnb_index=${gnb_index}
    log to console    check cells status change to disable
    Wait Until Keyword Succeeds    10min    30s    Verify All Cells Are Disabled for vCU

    log to console    Unlock vDU from vCU WebEM
    Cloud Unlock vDU And Check Result    du_id_list=${du_id_list}    gnb_index=${gnb_index}
    log to console    check cells status change to enable
    Wait Until Keyword Succeeds    10min    30s    Verify All Cells Are Enabled for vCU

    ${cell_index_list}   vDU Get Cell List From Webem
    Run Keyword If    ${with_call}    Cloud UE L3 Call And Throughput    cell_list=${cell_index_list}
    ...    test_name=${test_name}    suite_name=${suite_name}