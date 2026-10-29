*** Settings ***
Documentation    This is common keywords for LTE siso related cases
...              Please do not modify the file without notification to author

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/LTE/basic/ru_operation.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/LTE/SiSo_Testability_E-UTRA_Test_Model_1.robot
Variables   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/made_variable.py
*** Variables ***



*** Keywords ***
SiSo_Testability_E-UTRA_Test_Model_3
    [Documentation]
        ...    *****************
        ...    - [TEST PURPOSE]Purpose of this test case is to verify LTE test model
        ...		set by operator via WebEM/SCF.
        ...    ******************
        ...    History of changes
        ...    ******************
        ...    - 7.4.2022 - - Created
        ...    *******************
        ...    yue.2.liu@nokia-sbell.com
    Enable Test Dedicated State
    Lte Downlink testmodel    test_model=E-TM3.1
    Stop Lte Downlink testmodel
    Lte Downlink testmodel    test_model=E-TM3.1a
    Stop Lte Downlink testmodel
    Lte Downlink testmodel    test_model=E-TM3.2
    Stop Lte Downlink testmodel
    Lte Downlink testmodel    test_model=E-TM3.3
    Stop Lte Downlink testmodel
    Disable Test Dedicated State
    [Teardown]   Run Keywords    run keyword and ignore error    Disable Test Dedicated State
        ...   AND    Selenium Logout And Close Browser
