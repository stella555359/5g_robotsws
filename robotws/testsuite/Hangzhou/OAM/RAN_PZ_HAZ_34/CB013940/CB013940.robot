*** Settings ***
Documentation      author: Bin.3 Wang
...                 contact: bin.3.wang@nokia-sbell.com
...                This robot file is for CB0123940 feature

Suite Setup          SuiteSetup
Suite Teardown       SuiteTearDown

Force Tags           SG_01   5G_RAN
Resource           testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/CB013940/Resource/CB013940_Resource.robot
Resource           ../5GC002479/Resources/5GC002479_CP_Resource.robot
Resource           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot

*** Test Cases ***
[1]CB013940_A_1_RU raises fault 4680 and cancels the fault by timer
    [Documentation]
    [Tags]
    [Setup]    CB013940 Test Setup
    [Teardown]  CB013940 Test Teardown
    TC.CB013940_A_1_RU raises fault 4680 and cancels the fault by timer

[1]CB013940_A_2_Online change parameters while the timer is running
    [Documentation]
    [Tags]
    [Setup]    CB013940 Test Setup
    [Teardown]  CB013940 Test Teardown
    TC.CB013940_A_2_Online change parameters while the timer is running

[1]CB013940_A_3_RU reset while the timer is running and fault is cancelled
    [Documentation]
    [Tags]
    [Setup]    CB013940 Test Setup
    [Teardown]  CB013940 Test Teardown
    TC.CB013940_A_3_RU reset while the timer is running and fault is cancelled

[1]CB013940_A_5_Fault 4680 raises and cancels when RU in DSM
    [Documentation]
    [Tags]
    [Setup]    CB013940 Test Setup
    [Teardown]  CB013940 Test Teardown
    TC.CB013940_A_5_Fault 4680 raises and cancels when RU in DSM

#[2]CB013940_A_2_Online change parameters while the timer is running
#    [Documentation]
#    [Tags]
#    [Setup]    CB013940 Test Setup
#    [Teardown]  CB013940 Test Teardown
#    TC.CB013940_A_2_Online change parameters while the timer is running
#
#[1]CB012087_B_1_Cell unavailability counters are updated based on low voltage
#    [Documentation]     This test case test cellSwithofftype=voltage in feature CB012087. coundters should be updated
#    ...               when cell is unvailability because of low voltage
#    [Tags]
#    [Setup]    CB013940 Test Setup
#    [Teardown]  CB013940 Test Teardown
#    TC.CB012087_B_1_Cell_unavailability_counters_are_updated_based_on_low_voltage
#
#
#[1]CB012087_A_3_Activation and configuration of 5G Cell Locking based on Time of Day
#    [Documentation]     This test case is to active cellSwitchOffType=timewindow in feature CB012087.
#    [Tags]
#    [Setup]    CB013940 Test Setup
#    [Teardown]  CB013940 Test Teardown
#    TC.CB012087_A_3_Activation and configuration of 5G Cell Locking based on Time of Day
#
#
#[1]CB012087_B_3_Activation and configuration of 5G Cell Locking based on Voltage
#    [Documentation]     This test case is to active cellSwitchOffType=voltage in feature CB012087.
#    [Tags]
#    [Setup]    CB013940 Test Setup
#    [Teardown]  CB013940 Test Teardown
#    TC.CB012087_B_3_Activation and configuration of 5G Cell Locking based on Voltage
#
#[1]CB012087_D_1_Cell unavailability counters are updated based on low voltage
#    [Documentation]     This test case test cellSwitchOffType=voltage in feature CB012087.
#    [Tags]
#    [Setup]    CB013940 Test Setup
#    [Teardown]  CB013940 Test Teardown
#    TC.CB012087_LTE_Cell_switch_off_and_on_ based_on_configured_low_voltage
#
#[1]CB012087_C_5_4G Cell switch off based on configured time of day successfully
#    [Documentation]     This test case test cellSwitchOffType=time in feature CB012087.
#    [Tags]
#    [Setup]    CB013940 Test Setup
#    [Teardown]  CB013940 Test Teardown
#    TC.CB012087_C_5_4G Cell switch off based on configured time of day successfully
#
#[1]CB012087_C_9_Online change time of day parameters during cell is switched off by time of day
#    [Documentation]     This test case test cellSwitchOffType=time in feature CB012087.
#    [Tags]
#    [Setup]    CB013940 Test Setup
#    [Teardown]  CB013940 Test Teardown
#    TC.CB012087_C_9_Online change time of day parameters during cell is switched off by time of day
#
#[1]CB012087_NR_A8_5G Cell switch on based on configured time of day successfully
#    [Documentation]     This test case test cellSwitchOffType=timewindow in feature CB012087. Cells are switched off to Energcysaving state
#    ...               when enter timewindow and exist when time expired
#    [Tags]
#    [Setup]    CB013940 Test Setup
#    [Teardown]  CB013940 Test Teardown
#    TC.CB012087_NR_A8_5G Cell_switch_on_based_on_configured_time_of_day_successfully
#
#[1]CB012087_NR_B1_Cell unavailability counters are updated based on low voltage
#    [Documentation]     This test case test cellSwithofftype=voltage in feature CB012087. coundters should be updated
#    ...               when cell is unvailability because of low voltage
#    [Tags]
#    [Setup]    CB013940 Test Setup
#    [Teardown]  CB013940 Test Teardown
#    TC.CB012087_NR_B1_Cell_unavailability_counters_are_updated_based_on_low_voltage