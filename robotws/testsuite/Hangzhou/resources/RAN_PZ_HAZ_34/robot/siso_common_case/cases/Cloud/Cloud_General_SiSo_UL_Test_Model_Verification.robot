*** Settings ***
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_test_model.robot

*** Keywords ***
Cloud_General_SiSo_UL_Test_Model_Verification
    [Documentation]    *****************
    ...    - [TEST PURPOSE] The purpose of this keyword is to execute the uplink testing in Test Model and verify its results.
    ...    - [TEST PARAMETERS] The test parameters are as follows:
    ...        frc_index_list: The list of FRC indexes.
    ...        cell_id: The cell ID, default 'all'.
    ...    - [TEST PROCEDURE] The test procedure is as follows:
    ...        1. Enter to TDS mode.
    ...        2. Go through the frc_index_list and execute the uplink testing in Test Model.
    ...        3. Exit TDS mode.
    ...    - [EXPECTED RESULTS] Enter TDS mode and the uplink versification should be passed,
    ...    cells should be on air for both CU and vDU after exit from TDS mode.
    ...    *******************
    ...    History of changes
    ...    ******************
    ...    - 15.05.2024 - - Created
    ...    *******************
    ...    Owner: shifu.lan@nokia-sbell.com
    [Arguments]    ${frc_index_list}    ${cell_id}=all
    Cloud Enter To TDS Mode
    Cloud Test Uplink Test Model    frc_index_list=${frc_index_list}    cell_id=${cell_id}
    Cloud Exit TDS Mode
