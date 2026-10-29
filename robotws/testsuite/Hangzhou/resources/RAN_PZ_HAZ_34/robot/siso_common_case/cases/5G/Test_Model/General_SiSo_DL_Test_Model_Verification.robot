*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/test_model.robot
*** Variables ***

*** Keywords ***
General_SiSo_DL_Test_Model_Verification
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE] The purpose of this Test Case is to enter test mode and execute test models
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 18.11.2022 - - Created
    ...    *******************
    ...    Owner_tingting.zhong@nokia-sbell.com
    ...    test_model_list: NR-FR1-TM1.1, NR-FR1-TM1.2, NR-FR1-TM2, NR-FR1-TM2a,
    ...    NR-FR1-TM3.1, NR-FR1-TM3.1a, NR-FR1-TM3.2, NR-FR1-TM3.3
    [Arguments]  ${test_model_list}   ${cell_id}=all
    Selenium Login And Disable Screen Lock
    Enable Test Dedicated State
    Test Downlink Test Model    test_model_list=${test_model_list}
    Disable Test Dedicated State
    [Teardown]  selenium logout and close browser
