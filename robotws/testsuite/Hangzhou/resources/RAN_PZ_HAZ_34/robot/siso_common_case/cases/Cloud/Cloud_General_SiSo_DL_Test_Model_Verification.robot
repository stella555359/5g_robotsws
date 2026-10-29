*** Settings ***
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_test_model.robot

*** Keywords ***
Cloud_General_SiSo_DL_Test_Model_Verification
    [Documentation]    *****************
    ...    - [TEST PURPOSE] The purpose of this keyword is to execute the downlink testing in Test Model and verify its results.
    ...    - [TEST PARAMETERS] The test parameters are as follows:
    ...        test_model_list: The list of test models to be executed.
    ...        cell_id: The cell ID, default 'all'.
    ...    - [TEST PROCEDURE] The test procedure is as follows:
    ...        1. Enter to TDS mode.
    ...        2. Go through the frc_index_list and execute the downlink testing in Test Model.
    ...        3. Exit TDS mode.
    ...    - [EXPECTED RESULTS] Enter TDS mode and the downlink versification should be passed,
    ...    cells should be on air for both CU and vDU after exit from TDS mode.
    ...    *******************
    ...    History of changes
    ...    ******************
    ...    - 15.05.2024 - - Created
    ...    *******************
    ...    Owner: shifu.lan@nokia-sbell.com
    ...    *******************
    [Arguments]    ${test_model_list}    ${cell_id}=all
    Cloud Enter To TDS Mode
    Cloud Test Downlink Test Model    test_model_list=${test_model_list}    cell_id=${cell_id}
    Cloud Exit TDS Mode
