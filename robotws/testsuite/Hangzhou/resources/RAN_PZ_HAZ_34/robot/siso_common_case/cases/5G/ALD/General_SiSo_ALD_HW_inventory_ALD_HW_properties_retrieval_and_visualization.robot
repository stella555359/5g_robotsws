*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/ald_operation.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
*** Variables ***

*** Keywords ***
General_SiSo_ALD_HW_inventory_ALD_HW_properties_retrieval_and_visualization
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE] The purpose of this test case is to check ALD retrieval and visualization via WebUI
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 03.16.2020 https://jiradc.int.net.nokia.com/browse/WESTLAKE- - Created
    ...    *******************
    ...    Owner_zhihao.shi@nokia-sbell.com
    SISO ALD Test Setup
    ALD Details Info Check
    [Teardown]    run keywords    SISO ALD ENV Recover    AND    COAM Teardown gnb connections
