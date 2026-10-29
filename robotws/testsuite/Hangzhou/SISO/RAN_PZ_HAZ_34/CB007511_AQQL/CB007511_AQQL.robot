*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Setup           SISO Coam Test Setup
Test Teardown        SISO Coam Test Teardown
Test Timeout         2h

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    ./resource/CB007511_Common_KW.robot

Documentation
...    Author: Zhang Xuewen
...    Contact: xuewen.zhang@nokia-sbell.com
...    squad group:SG_05
...    Feature CB007511 in SBTS23R1 program

Force Tags    RAN_5G_TDD    RAN_5G    SBTS00    STATE_SW_UPLOADED

*** Variables ***

*** Test Cases ***
[1]CB007511-5G-A_01 RU entering deep sleep mode during low traffic periods with 5GC000431 enabled
    [Tags]    1S-2CC-8D-4U    CIT_TRUNK
    RU_entering_deep_sleep_mode_during_low_traffic_periods_with_5GC000431_enabled

[1]CB007511-5G-A_03 RU returning from PowerSaving Mode to normal operation due to at least one carrier enabling on RU triggered by 5GC000431
    [Tags]    1S-2CC-8D-4U   CLOUD_5G_CLASSICAL_ASIB_ABIO_AQQL_ENB
    RU_returning_from_PowerSaving_Mode_to_normal_operation_due_to_disable_5GC000431   LOOPS=${3}

#[1]CB007511-5G-A_02 RU entering deep sleep mode after all cells locked
#    [Tags]    1S-2CC-8D-4U
#    RU_entering_deep_sleep_mode_after_all_cells_locked

#[1]CB007511-5G-A_04 RU returning from PowerSaving Mode to normal operation due to at least one cell unlocked
#    [Tags]    S-2CC-8D-4U
#    RU_returning_from_PowerSaving_Mode_to_normal_operation_due_to_at_least_one_cell_unlocked

*** Keywords ***
