*** Settings ***
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_bts.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_vdu.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_test_model.robot

*** Keywords ***
Cloud_General_SiSo_Test_Model_Stability_Run
    [Arguments]    ${test_loops}=3   ${pass_times}=3   ${is_DL_TM}=${True}   ${is_UL_TM}=${True}
    ...    ${DL_TM_list}=${None}    ${DL_TM_cell_id}=all    ${UL_TM_list}=${None}    ${UL_TM_cell_id}=all
    [Documentation]    *****************
    ...    - [TEST PURPOSE] The purpose of this keyword is to verification uplink/downlink Test Model functions.
    ...    - [TEST PROCEDURE] The test procedure is as follows:
    ...        1. Enter to TDS mode.
    ...        2. Go through the DL_TM_list and execute the downlink testing in Test Model.
    ...        3. Exit TDS mode.
    ...        4. Enter to TDS mode.
    ...        5. Go through the UL_TM_list and execute the uplink testing in Test Model.
    ...        6. Exit TDS mode.
    ...        7. repeat step 1-6 for ${test_loops} times.
    ...    - [EXPECTED RESULTS] Enter/Exit TDS mode and the downlink/ uplink versification should be passed;
    ...    cells should be on air for both CU and vDU after exit from TDS mode.
    ...
    ...    | =Input Parameters= | =Mandatory= | =Description= |
    ...    | test_loops | No | UL/D TM test times. Default value is 3. |
    ...    | pass_times | No | UL/D TM test pass times. Default value is 3. |
    ...    | is_DL_TM | No | if DL TM test. Default value is True. |
    ...    | is_UL_TM | No | if UL TM test. Default value is True.|
    ...    | DL_TM_list | No | The list of DL test models to be executed, like 'NR-FR1-TM1.1'. Default value is None.|
    ...    | DL_TM_cell_id | No | The cell ID to be test in DL TM, default 'all'. |
    ...    | UL_TM_list | No | The list of UL test models to be executed, like 'G-FR1-A1-2'. Default value is None. |
    ...    | UL_TM_cell_id | No | The cell ID to be test in UL TM, default 'all'. |

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
        Log To Console    \n DL Test Model Iteration:${TEST_LOOP}
        ${re_dl_tm}   Run Keyword And Return Status   Run Keyword If  ${is_DL_TM}   Run Keywords
        ...    Cloud Enter To TDS Mode    AND
        ...    Cloud Test Downlink Test Model    test_model_list=${DL_TM_list}    cell_id=${DL_TM_cell_id}    AND
        ...    Cloud Exit TDS Mode
        Run Keyword If  '${re_dl_tm}'!='True'   Run Keywords
        ...    Run Keyword And Ignore Error    Cloud Save Snapshot and Log    AND
        ...    Run Keyword And Ignore Error    Cloud Reset vDU and Check Cell On Air    need_check_on_air=${False}

        Log To Console    \n UL Test Model Iteration:${TEST_LOOP}
        ${re_ul_tm}   Run Keyword And Return Status   Run Keyword If  ${is_UL_TM}   Run Keywords
        ...    Cloud Enter To TDS Mode    AND
        ...    Cloud Test Uplink Test Model    frc_index_list=${UL_TM_list}    cell_id=${UL_TM_cell_id}    AND
        ...    Cloud Exit TDS Mode
        ${pass_loops}   Run Keyword If  '${re_dl_tm}'=='True' and '${re_ul_tm}'=='True'    Evaluate    ${pass_loops}+1
        ...    ELSE    Run Keywords
        ...    Run Keyword And Ignore Error    Cloud Save Snapshot and Log    AND
        ...    Run Keyword And Ignore Error    Cloud Reset vDU and Check Cell On Air    need_check_on_air=${False}
    END
    Run Keyword And Continue On Failure    Should Be True    ${pass_loops} >= ${pass_times}
    ${pass_ratio}    evaluate    ${pass_loops}/${test_loops}*100
    Log To Console    \n Test Model testing pass ${pass_loops} in ${test_loops} times, pass ratio: ${pass_ratio}.
