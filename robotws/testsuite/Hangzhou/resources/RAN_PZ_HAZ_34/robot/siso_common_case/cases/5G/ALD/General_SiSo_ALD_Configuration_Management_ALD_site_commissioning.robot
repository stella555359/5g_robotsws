*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/ald_operation.robot
*** Variables ***

*** Keywords ***
General_SiSo_ALD_Configuration_Management_ALD_site_commissioning
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE] The purpose of this test case is to check functionality of ALD commissioning
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 10.16.2020 https://jiradc.int.net.nokia.com/browse/WESTLAKE- - Created
    ...    *******************
    ...    Owner_zhihao.shi@nokia-sbell.com
    SISO ALD Test Setup
    [Teardown]    run keywords    SISO ALD ENV Recover    AND    COAM Teardown gnb connections
