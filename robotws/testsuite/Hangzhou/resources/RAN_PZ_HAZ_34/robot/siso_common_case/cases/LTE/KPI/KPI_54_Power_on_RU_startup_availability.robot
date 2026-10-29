*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource       testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/LTE/basic/ru_operation.robot
Resource       testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/LTE/btslog_check.robot

*** Variables ***

*** Keywords ***
KPI_54_Power_on_RU_startup_availability
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] The purpose of this test case is to verify ru power on startup duration.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 28.10.2022 - - Created
    ...    *******************
    ...    Owner_tingting.zhong@nokia-sbell.com
    [Arguments]  ${ru_index}=1    ${ru_power_on_startup_duration}=360
    Perform RU Power reset LTE    ru_index=${ru_index}
    Wait until keyword succeeds    10min    30s    Verify all cells should be onair    cell_type=${cell_type}
    run keyword and ignore error    Stop Btslog With Path Check
    Btslog Check RU Power On Startup Duration     ru_index=${ru_index}
    ...                                           ru_power_on_startup_duration=${ru_power_on_startup_duration}
