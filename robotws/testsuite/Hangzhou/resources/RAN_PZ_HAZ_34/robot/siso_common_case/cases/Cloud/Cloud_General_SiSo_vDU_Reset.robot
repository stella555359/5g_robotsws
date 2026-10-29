*** Settings ***
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_vdu.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_throughput.robot

*** Keywords ***
Cloud_General_SiSo_vDU_Reset
    [Arguments]   ${vdu_index}=0   ${gnb_index}=0   ${with_call}=${True}   ${suite_name}=default   ${test_name}=default
    [Documentation]    *****************
    ...    - [TEST PURPOSE] The purpose of this keyword is to verification vDU reset and l3call success.
    ...    - [TEST PROCEDURE] The test procedure is as follows:
    ...        1. Connect to vDU and reset.
    ...        2. Check vDU status and all cells status shall be on air after resetting.
    ...        3. check basic l3call after all cells on aire.
    ...    - [EXPECTED RESULTS] vDU and all cells status are normal; l3call success.
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
    ...    - 24.05.2024 - - Created
    ...    *******************
    ...    * Owner: aaron.deng@nokia-sbell.com
    ...    * Group: VRF_HAZ4_T05
    ...    *******************
    Cloud Reset vDU and Check Cell On Air   need_check_on_air=${True}
    ...    vdu_index=${vdu_index}    gnb_index=${gnb_index}

    Run Keyword If  ${with_call}    log to console  \ncheck L3call...
    ${cell_index_list}   vDU Get Cell List From Webem
    Run Keyword If  ${with_call}    Cloud UE L3 Call And Throughput    cell_list=${cell_index_list}
    ...    test_name=${test_name}    suite_name=${suite_name}
