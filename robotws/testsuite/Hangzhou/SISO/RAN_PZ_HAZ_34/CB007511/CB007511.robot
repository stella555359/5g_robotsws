*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Setup           SISO Coam Test Setup    fail_with_alarms=${True}
Test Teardown        SISO Coam Test Teardown
Test Timeout         24h

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    ${BASIC_PATH_5G}/General_RU_entering_deep_sleep_mode_during_low_traffic_periods_with_5GC000431_enabled.robot
Resource    ${BASIC_PATH_5G}/General_RU_returning_from_PowerSaving_Mode_to_normal_operation_due_to_change_of_EnergySavingMode.robot
Resource    ${BASIC_PATH_5G}/ALD/ALD_calibration_when_radio_entering_in_deepsleep_and_SW_upgrade_when_radio_is_in_deepsleep.robot
Resource    ${BASIC_PATH_5G}/ALD/ALD-related_faults_cancellation_and_delta_commissioning_when_radio_is_in_deepsleep.robot
Resource    ${BASIC_PATH_5G}/General_Siso_SYNC_loss_impact_on_DSM.robot

Documentation
...    Author:zhihao shi
...    contact:zhihao.shi@nokia-sbell.com
...    squad group:SG_04
...    Feature CB007511 in SBTS23R1 program

Force Tags            5G_RAN    5G_RAN_TDD    RAN_5G_TDD    RAN_5G    STATE_SW_UPLOADED   CLOUD_5G_CLASSICAL_ASIB_ABIO_AQQC_ENB
...   PY310    HAZ4_T04

*** Test Cases ***
#TL582_UTE_Cloud
[1]CB007511-5G-A_1_RU_entering_deep_sleep_mode_during_low_traffic_periods_with_5GC000431_enabled
    [Tags]    1S-1CC-8D-4U_CHT    CRT_UTE    RF50
    General_RU_entering_deep_sleep_mode_during_low_traffic_periods_with_5GC000431_enabled

[1]CB007511-5G-A_5_RU_returning_from_PowerSaving_Mode_to_normal_operation_due_to_change_of_EnergySavingMode
    [Tags]    1S-1CC-8D-4U_CHT    CRT_UTE    RF50
    General_RU_returning_from_PowerSaving_Mode_to_normal_operation_due_to_change_of_EnergySavingMode

[1]CB007511-A_1_ALD_calibration_when_radio_entering_in_deepsleep_and_SW_upgrade_when_radio_is_in_deepsleep
    [Tags]    1S-2CC-8D-4U_ALD
    ALD_calibration_when_radio_entering_in_deepsleep_and_SW_upgrade_when_radio_is_in_deepsleep

[1]CB007511-A_2_ALD-related_faults_cancellation_and_delta_commissioning_when_radio_is_in_deepsleep
    [Tags]    1S-2CC-8D-4U_ALD
    ${fault_list}    Create List    4282
    Allowed Watchdog additional alarms    fault_list=${fault_list}
    ALD-related_faults_cancellation_and_delta_commissioning_when_radio_is_in_deepsleep

#TL580_UTE_Cloud
[1]CB007511-5G-A_01_SYNC_loss_impact_on_DSM
    [Tags]    1S-1CC-8D-4U_CHT    RF50
    ${fault_list}    Create List    4298   16   4452   4405   6918
    Allowed Watchdog additional alarms    fault_list=${fault_list}
    General_Siso_SYNC_loss_impact_on_DSM
