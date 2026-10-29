*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Setup           SISO Coam Test Setup    fail_with_alarms=${True}
Test Teardown        SISO Coam Test Teardown
Test Timeout         12h

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    ${BASIC_PATH_5G}/BTS/General_SiSo_Peak_with_Given_Information.robot
Resource    ${BASIC_PATH_5G}/Cell/E2E_SiSo_Cell_block_and_unblock_gNB.robot
Resource    ${BASIC_PATH_5G}/E2E_SiSo_RU_lock_and_unlock_gNB.robot


Documentation
...    Author:zhihao shi
...    contact:zhihao.shi@nokia-sbell.com
...    squad group:SG_04
...    Feature CB006794 in 5G21B program

Force Tags            5G_RAN    5G_RAN_TDD
...   PY36

*** Variables ***

*** Test Cases ***
[1]CB006794-5G-C_01_10_General_SiSo_E2E_system_setup_with_data_transfer_conducted_80M
    [Tags]    CRT_22R4    CRT_22R3    CRT_TRUNK    RF50
    General_SiSo_Peak_with_Given_Information    band=80    frame_structure=1208_GP1_A1
    ...        beamset=6 beams    basicBeamSet=beamSet_6   suite_name=${SUITE NAME}    test_name=${TEST NAME}

[1]CB006794-5G-C_01_05_General_SiSo_Cell_block_and_unblock
    ${fault_list}    Create List    49
    Allowed Watchdog additional alarms    fault_list=${fault_list}
    E2E_SiSo_Cell_block_and_unblock_gNB

[1]CB006794-5G-C_01_04_General_SiSo_RU_lock_unlock
    [Tags]    CRT_22R4    CRT_TRUNK
    E2E_SiSo_RU_lock_and_unlock_gNB

#[1]CB006794-5G-A_01_08_OAM_KPI_61a_SiSo_Auto_BTS_site_reset
#    [Tags]    3S-1CC-8D-4U
#    [Timeout]    12h
#    Set Log Level    INFO
#    General_Stability_Test_Case    case_name=General_SiSo_Auto_BTS_site_reset    times=${20}    pass=${19}
#    Check 5G inter Loki IQ data routing via Btsom Log
#
#[1]CB006794-5G-A_01_01_General_SiSo_Commissioning_BTS_Template_Commissioning
#    [Tags]    3S-1CC-8D-4U
#    General_SiSo_Commissioning_BTS_Template_Commissioning
#    Check 5G inter Loki IQ data routing via Btsom Log
#
#[1]CB006794-5G-A_01_02_General_SiSo_RF_module_reset_from_GUI
#    [Tags]    3S-1CC-8D-4U
#    General_SiSo_RF_module_reset_from_GUI
#    Check 5G inter Loki IQ data routing via Btsom Log
#
#[1]CB006794-5G-A_01_03_General_SiSo_RF_module_power_reset
#    [Tags]    3S-1CC-8D-4U
#    General_SiSo_RF_module_power_reset
#    Check 5G inter Loki IQ data routing via Btsom Log
#
#[1]CB006794-5G-A_01_06_General_SiSo_Online_Cell_addition_deletion
#    [Tags]    3S-1CC-8D-4U
#    General_SiSo_Online_Cell_addition_deletion
#    Check 5G inter Loki IQ data routing via Btsom Log
#
#[1]CB006794-5G-A_01_07_General_SiSo_E2E_system_setup_with_data_transfer_conducted_100M
#    [Tags]    3S-1CC-8D-4U
#    General_SiSo_Peak_with_Given_Information    band=100    frame_structure=1208_GP1_A1
#    ...        beamset=6 beams    basicBeamSet=beamSet_6
#    Check 5G inter Loki IQ data routing via Btsom Log
#
#[1]CB006794-5G-C_01_01_General_SiSo_Commissioning_BTS_Template_Commissioning
#    [Tags]    3S-1CC-8D-4U
#    General_SiSo_Commissioning_BTS_Template_Commissioning
#    Check 5G inter Loki IQ data routing via Btsom Log
#
#[1]CB006794-5G-C_01_02_General_SiSo_RF_module_reset_from_GUI
#    [Tags]    3S-1CC-8D-4U
#    General_SiSo_RF_module_reset_from_GUI
#    Check 5G inter Loki IQ data routing via Btsom Log
#
#[1]CB006794-5G-C_01_03_General_SiSo_RF_module_power_reset
#    [Tags]    3S-1CC-8D-4U
#    General_SiSo_RF_module_power_reset
#    Check 5G inter Loki IQ data routing via Btsom Log
#
#[1]CB006794-5G-A_01_04_General_SiSo_RU_lock_unlock
#    [Tags]    3S-1CC-8D-4U
#    E2E_SiSo_RU_lock_and_unlock_gNB
#
#[1]CB006794-5G-A_01_05_General_SiSo_Cell_block_and_unblock
#    [Tags]    3S-1CC-8D-4U
#    General_SiSo_Cell_block_and_unblock
#
#[1]CB006794-5G-C_01_08_General_SiSo_E2E_system_setup_with_data_transfer_conducted_40M
#    [Tags]    3S-1CC-8D-4U
#    General_SiSo_Peak_with_Given_Information    band=40    frame_structure=1208_GP1_A1
#    ...        beamset=6 beams    basicBeamSet=beamSet_6
#    Check 5G inter Loki IQ data routing via Btsom Log
#
#[1]CB006794-5G-C_01_09_General_SiSo_E2E_system_setup_with_data_transfer_conducted_60M
#    [Tags]    3S-1CC-8D-4U
#    General_SiSo_Peak_with_Given_Information    band=60    frame_structure=1116_3ms_GP1_B5
#    ...        beamset=6 beams    basicBeamSet=beamSet_6
#    Check 5G inter Loki IQ data routing via Btsom Log
#
#[1]CB006794-5G-C_01_11_General_SiSo_E2E_system_setup_with_data_transfer_conducted_100M
#    [Tags]    3S-1CC-8D-4U
#    General_SiSo_Peak_with_Given_Information    band=100    frame_structure=1208_GP1_A1
#    ...        beamset=6 beams    basicBeamSet=beamSet_6
#    Check 5G inter Loki IQ data routing via Btsom Log
#
#[1]CB006794-5G-C_01_12_OAM_KPI_61a_SiSo_Auto_BTS_site_reset
#    [Tags]    3S-1CC-8D-4U
#    [Timeout]    12h
#    Set Log Level    INFO
#    General_Stability_Test_Case    case_name=General_SiSo_Auto_BTS_site_reset    times=${20}    pass=${19}
#    Check 5G inter Loki IQ data routing via Btsom Log
#
#[1]CB006794-5G-C_01_06_General_SiSo_E2E_system_setup_with_data_transfer_conducted_3UEs_simultaneously
#    [Tags]    3S-1CC-8D-4U
#    General_SiSo_Peak_with_Given_Information    band=20    frame_structure=1116_0ms_GP2_A7
#    ...        beamset=2 beams    basicBeamSet=beamSet_2
#    Check 5G inter Loki IQ data routing via Btsom Log
#
#[1]CB006794-5G-C_call_with_data_transfer_1UE
#    ${cell_list}  create list  ${2}
#    Get UE From Init File and Make call  cell_list=${cell_list}  with_peak=${True}  duration=${300}

*** Keywords ***
