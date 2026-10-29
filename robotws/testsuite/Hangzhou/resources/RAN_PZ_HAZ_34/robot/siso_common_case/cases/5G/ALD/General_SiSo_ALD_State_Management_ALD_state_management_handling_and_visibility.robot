*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/ald_operation.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
*** Variables ***

*** Keywords ***
General_SiSo_ALD_State_Management_ALD_state_management_handling_and_visibility
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE] The purpose of this test case is to check ALD handling and visibility via WebUI
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 03.16.2020 https://jiradc.int.net.nokia.com/browse/WESTLAKE- - Created
    ...    *******************
    ...    Owner_zhihao.shi@nokia-sbell.com
    [Arguments]  ${ald_type}=RAEU
    SISO ALD Test Setup
    Repeat 2 Times Enable And Disable DC Voltgae For RET Port ${ald_type}
    [Teardown]    run keywords    SISO ALD ENV Recover    AND    COAM Teardown gnb connections
