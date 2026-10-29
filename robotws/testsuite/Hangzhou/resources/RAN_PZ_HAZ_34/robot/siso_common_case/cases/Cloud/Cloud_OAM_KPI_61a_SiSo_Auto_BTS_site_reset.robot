*** Settings ***
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_bts.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_vdu.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_throughput.robot

*** Keywords ***
Cloud_OAM_KPI_61a_SiSo_Auto_BTS_site_reset
    [Arguments]    ${test_loops}=20   ${pass_times}=19   ${max_reset_time}=600   ${vdu_index}=0   ${gnb_index}=0
    ...   ${with_call}=${False}    ${suite_name}=default   ${test_name}=default
    [Documentation]    *****************
    ...    - [TEST PURPOSE] The purpose of this keyword is to verification vDU reset and l3call successful repeated.
    ...    - [TEST PROCEDURE] The test procedure is as follows:
    ...        1. Connect to vDU and perform vDU reset.
    ...        2. Check vDU status and all cells status shall be on air after resetting.
    ...        3. check basic l3call after all cells on air.
    ...        4. Repeat step 1-3 for ${test_loops} times.
    ...    - [EXPECTED RESULTS] vDU and all cells status are normal; l3call success;
    ...    pass ratio and duration are within the expected range.
    ...
    ...    | =Input Parameters= | =Mandatory= | =Description= |
    ...    | test_loops | No | The vDU total reset times. Default value is 20. |
    ...    | pass_times | No | The vDU reset pass times. Default value is 19. |
    ...    | max_reset_time | No | The maximum recovery interval from vDU reset, unit (s). Default value is 600. |
    ...    | vdu_index | No | The vDU index. Default value is 0. |
    ...    | gnb_index | No | The gNB index. Default value is 0. |
    ...    | with_call | No | Flag for l3call. Default value is True. |
    ...    | suite_name | No | The suite name used for customed peak rate. |
    ...    | test_name | No | The test name used for customed peak rate. |

    ...    *******************
    ...    History of changes
    ...    ******************
    ...    - 17.06.2024 - - Created
    ...    *******************
    ...    * Owner: aaron.deng@nokia-sbell.com
    ...    * Group: VRF_HAZ4_T05
    ...    *******************
    ${pass_loops}   Set variable    ${0}
    FOR    ${TEST_LOOP}    IN RANGE    1    ${test_loops}+1
        Log To Console    \n vDU Reset Iteration:${TEST_LOOP}
        ${re_vDUreset}   Run Keyword And Return Status    Cloud vDU Reset With Duration Check   vdu_index=${vdu_index}
        ...    gnb_index=${gnb_index}
        ${re_duration}    Run Keyword And Return Status    Should Be True    ${duration} <= ${max_reset_time}
        ${pass_loops}    Run Keyword If  '${re_vDUreset}'=='True' and '${re_duration}'=='True'    Evaluate    ${pass_loops}+1
        ...    ELSE    Run Keyword And Ignore Error    Cloud Save Snapshot and Log
    END
    Run Keyword And Continue On Failure    Should Be True    ${pass_loops} >= ${pass_times}
    ${pass_ratio}    evaluate    ${pass_loops}/${test_loops}*100
    Log To Console    \n vDU reset pass ${pass_loops} in ${test_loops} times, pass ratio: ${pass_ratio}.

    ${cell_index_list}   vDU Get Cell List From Webem
    Run Keyword If  ${with_call}    Run Keywords    log to console  \ncheck L3call...
    ...    AND    Cloud UE L3 Call And Throughput    cell_list=${cell_index_list}    duration=${300}
    ...    test_name=${test_name}    suite_name=${suite_name}
