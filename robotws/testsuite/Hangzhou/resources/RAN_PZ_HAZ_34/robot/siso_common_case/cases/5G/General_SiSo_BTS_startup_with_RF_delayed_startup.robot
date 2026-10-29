*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/ru_operation.robot
*** Variables ***

*** Keywords ***
General_SiSo_BTS_startup_with_RF_delayed_startup
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE] The purpose of this test case is to check the RU connection,
    ...    detection and configuration to the BTS in a reliable time.
    ...    RU should be powered on with delay after the BTS (RAC and RAU) is online, connected.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 02.19.2020 - - Created
    ...    *******************
    ...    OWNER_tingting.zhong@nokia-sbell.com]
    ${ru_index_list}  Get All RU Index
    Perform RAC and RAU Power Off  ${ru_index_list}
    Perform RAC Power On  ${ru_index_list}
    [Teardown]  Power On RU_and_check RF Delayed Startup  ${ru_index_list}
