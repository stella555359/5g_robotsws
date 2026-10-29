*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/test_model.robot
*** Variables ***

*** Keywords ***
General_SiSo_UL_Test_Model_Verification
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE] The purpose of this Test Case is to enter test mode and execute test models
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 18.11.2022 - - Created
    ...    *******************
    ...    Owner_tingting.zhong@nokia-sbell.com
    ...    frc_index_list: G-FR1-A1-2, G-FR1-A1-5, G-FR1-A2-5,
    [Arguments]  ${frc_index_list}    ${cell_id}=all
    selenium login and disable screen lock
    Enable Test Dedicated State
    Test Uplink Test Model    frc_index_list=${frc_index_list}
    Disable Test Dedicated State
    [Teardown]  selenium logout and close browser
