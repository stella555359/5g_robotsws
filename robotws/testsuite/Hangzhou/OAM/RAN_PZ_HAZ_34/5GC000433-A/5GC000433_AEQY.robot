*** Settings ***
Suite Setup           Run Keywords     SISO Coam Suite Setup
...                   AND     Case Preparation
Suite Teardown        SISO Coam Suite Teardown
Test Setup            SISO Coam Test Setup    fail_with_alarms=${True}
Test Teardown         SISO Coam Test Teardown

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/5GC000433-A/Resources/5GC000433_common_keywords.robot

Documentation
...    author: Zhihao Shi
...    contact: zhihao.shi@nokia-sbell.com
...    squad group: SG_04
...    feature : 5GC000433-B

Force Tags            5G_RAN_FDD    SBTS00
...    PY36

*** Variables ***

*** Test Cases ***
[1]5GC000433-B_01_01_Energy_Consumption_Counter_Feature_Activate_via_WebUI
    [Tags]    CRT_22R4    CRT_TRUNK    RF50
    Wait for New Interval BTS counters Generate    interval=15min
    Disable Energy Consumption Measurement Collectection    interval=15min
    sleep    300
    Set Power meter    power_meter=true
    Check Real Time Power Value    object_names=RMOD    interval=15min
    Check Real Time Power Value    object_names=SMOD    interval=15min
    sleep    300
    Connect to Common Unit Master
	selenium login and disable screen lock
	${value_2C0}    Get PM Counter via Webem    counter_id=M40002C0    interval=15min
	Should be True    ${value_2C0} > 0
    ${value_3C0}    Get PM Counter via Webem    counter_id=M40003C0    interval=15min
	Should be True    ${value_3C0} > 0
	${value_4C0}    Get PM Counter via Webem    counter_id=M40004C0    interval=15min
	Should be True    ${value_4C0} > 0
	selenium logout and close browser

#[1]5GC000433-B_01_02_Energy_Consumption_Counter_Feature_Deactivate_via_WebUI
#    Wait for New Interval BTS counters Generate    interval=15min
#    Disable Energy Consumption Measurement Collectection    interval=15min
#    Set Power meter    power_meter=true

[1]5GC000433-B_01_05_Counter_Update_M40002C0_ENERGY_CONSUMPTION_IN_SM
    [Tags]    CRT_TRUNK
    Check Real Time Power Value    object_names=RMOD    interval=15min
    Check Real Time Power Value    object_names=SMOD    interval=15min
    Check BTS Counter M40002C    interval=15min

[1]5GC000433-B_01_09_Counter_Update_M40003C1_MAX_INPUT_VOLTAGE_IN_RF
    [Tags]    CRT_TRUNK
    Check BTS Counter M40003C    interval=15min

[1]5GC000433-B_01_14_Counter_Update_M40004C0_SM_ENERGY_CONSUMPTION
    [Tags]    CRT_TRUNK
    Check BTS Counter M40004C    interval=15min
