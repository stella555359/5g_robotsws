*** Settings ***
Documentation      author: Lixia Wang
...                 contact: lixia.wang@nokia-sbell.com
...                This robot file is for CB012087 feature

Suite Setup          SuiteSetup
Suite Teardown       SuiteTearDown

Force Tags           SG_01   5G_RAN
Resource           Resource/CB012087_Resource.robot
Resource           ../5GC002479/Resources/5GC002479_CP_Resource.robot
Resource           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot

*** Test Cases ***
[1]CB012087_A_8_5G Cell switch on based on configured time of day successfully
    [Documentation]     This test case test cellSwitchOffType=timewindow in feature CB012087. Cells are switched off to Energcysaving state
    ...               when enter timewindow and exist when time expired

    [Tags]
    [Setup]    CB012087 Test Setup
    [Teardown]  CB012087 Test Teardown
    TC.CB012087_A_8_5G Cell_switch_on_based_on_configured_time_of_day_successfully

[1]CB012087_B_1_Cell unavailability counters are updated based on low voltage
    [Documentation]     This test case test cellSwithofftype=voltage in feature CB012087. coundters should be updated
    ...               when cell is unvailability because of low voltage
    [Tags]
    [Setup]    CB012087 Test Setup
    [Teardown]  CB012087 Test Teardown
    TC.CB012087_B_1_Cell_unavailability_counters_are_updated_based_on_low_voltage


[1]CB012087_A_3_Activation and configuration of 5G Cell Locking based on Time of Day
    [Documentation]     This test case is to active cellSwitchOffType=timewindow in feature CB012087.
    [Tags]
    [Setup]    CB012087 Test Setup
    [Teardown]  CB012087 Test Teardown
    TC.CB012087_A_3_Activation and configuration of 5G Cell Locking based on Time of Day


[1]CB012087_B_3_Activation and configuration of 5G Cell Locking based on Voltage
    [Documentation]     This test case is to active cellSwitchOffType=voltage in feature CB012087.
    [Tags]
    [Setup]    CB012087 Test Setup
    [Teardown]  CB012087 Test Teardown
    TC.CB012087_B_3_Activation and configuration of 5G Cell Locking based on Voltage

[1]CB012087_D_1_Cell unavailability counters are updated based on low voltage
    [Documentation]     This test case test cellSwitchOffType=voltage in feature CB012087.
    [Tags]
    [Setup]    CB012087 Test Setup
    [Teardown]  CB012087 Test Teardown
    TC.CB012087_LTE_Cell_switch_off_and_on_ based_on_configured_low_voltage

[1]CB012087_C_5_4G Cell switch off based on configured time of day successfully
    [Documentation]     This test case test cellSwitchOffType=time in feature CB012087.
    [Tags]
    [Setup]    CB012087 Test Setup
    [Teardown]  CB012087 Test Teardown
    TC.CB012087_C_5_4G Cell switch off based on configured time of day successfully

[1]CB012087_C_9_Online change time of day parameters during cell is switched off by time of day
    [Documentation]     This test case test cellSwitchOffType=time in feature CB012087.
    [Tags]
    [Setup]    CB012087 Test Setup
    [Teardown]  CB012087 Test Teardown
    TC.CB012087_C_9_Online change time of day parameters during cell is switched off by time of day

[1]CB012087_NR_A8_5G Cell switch on based on configured time of day successfully
    [Documentation]     This test case test cellSwitchOffType=timewindow in feature CB012087. Cells are switched off to Energcysaving state
    ...               when enter timewindow and exist when time expired
    [Tags]
    [Setup]    CB012087 Test Setup
    [Teardown]  CB012087 Test Teardown
    TC.CB012087_NR_A8_5G Cell_switch_on_based_on_configured_time_of_day_successfully

[1]CB012087_NR_B1_Cell unavailability counters are updated based on low voltage
    [Documentation]     This test case test cellSwithofftype=voltage in feature CB012087. coundters should be updated
    ...               when cell is unvailability because of low voltage
    [Tags]
    [Setup]    CB012087 Test Setup
    [Teardown]  CB012087 Test Teardown
    TC.CB012087_NR_B1_Cell_unavailability_counters_are_updated_based_on_low_voltage