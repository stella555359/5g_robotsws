*** Settings ***
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_ru.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_vdu.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_vcu.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_bts.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_throughput.robot

*** Keywords ***
General_SiSo_RU_module_reset_from_GUI
    [Documentation]    *****************
    ...    - [TEST PURPOSE] The purpose of this test case is to verify that radio module
    ...    and OAM behaves correctly during procedure of radio module reset triggered by user from GUI with use of RP1 messaging.
    ...    - [TEST PROCEDURE] The test procedure is as follows:
    ...        1. Connect to vDU.
    ...        2. Reset RU.
    ...        3. Check cell disabled on vCU and vDU
    ...        4. Check RU should be normal           
    ...        5. Check cell on air on vCU and vDU
    ...    - [EXPECTED RESULTS] the RU should reset successfully.
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
    log to console    rmods_info
    ${rmods}     Get Rmod List    gnb_index=${gnb_index}    vdu_index=${vdu_index}
    Log To Console    reset ru for du
    Reset Rmod By Rest    rmods_list=${rmods}    gnb_index=${gnb_index}    vdu_index=${vdu_index}
    log to console  Check RU Status Normal and Cell on air
    Check RU Status Normal and Cell on air    gnb_index=${gnb_index}    vdu_index=${vdu_index}
    log to console  Check Cell Onair
    Wait Until Keyword Succeeds    15min    5s    All Cells Should Be Onair For All vDUs
    Run Keyword If    ${with_call}    Cloud UE L3 Call And Throughput    cell_list=${cell_list}
    ...    test_name=${test_name}    suite_name=${suite_name}

Check RU Status Normal and Cell on air
    [Arguments]    ${gnb_index}=0    ${vdu_index}=0
    Wait Until Keyword Succeeds   3min    5s    Verify All Cells Are Disabled for vCU   gnb_index=${gnb_index}
    Wait Until Keyword Succeeds   3min    5s    Verify All Cells Are Disabled for vDU   vdu_index=${vdu_index}    gnb_index=${gnb_index}
    Wait Until Keyword Succeeds    15min    5s    Verify All RU Status Should Be Normal on vDU
