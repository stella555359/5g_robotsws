*** Settings ***
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_vdu.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_throughput.robot

*** Keywords ***
Cloud_General_SiSo_E2E_system_setup_with_data_transfer_conducted
    [Arguments]    ${vdu_index}=0   ${gnb_index}=0   ${suite_name}=default   ${test_name}=default    ${duration}=${60}
    [Documentation]    *****************
    ...    - [TEST PURPOSE] The purpose of this keyword is to verify l3call if successful.
    ...    - [TEST PROCEDURE] The test procedure is as follows:
    ...        1. Get all cell list.
    ...        2. Make L3call and verify throughput.
    ...    - [EXPECTED RESULTS] Make L3call success.
    ...
    ...    | =Input Parameters= | =Mandatory= | =Description= |
    ...    | vdu_index | No | The vDU index. Default value is 0. |
    ...    | gnb_index | No | The gNB index. Default value is 0. |
    ...    | suite_name | No | The suite name used for customed peak rate. Default value is default. |
    ...    | test_name | No | The test name used for customed peak rate. Default value is default. |

    ...    *******************
    ...    History of changes
    ...    ******************
    ...    - 27.05.2024 - - Created
    ...    *******************
    ...    * Owner: shifu.lan@nokia-sbell.com
    ...    * Group: VRF_HAZ4_T04
    ...    *******************
    log to console  \ncheck L3call...
    ${cell_index_list}   vDU Get Cell List From Webem
    Cloud UE L3 Call And Throughput    cell_list=${cell_index_list}    test_name=${test_name}    suite_name=${suite_name}    duration=${duration}
