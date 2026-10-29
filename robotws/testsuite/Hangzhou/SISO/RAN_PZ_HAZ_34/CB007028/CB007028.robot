*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Setup           SISO Coam Test Setup    fail_with_alarms=${True}
Test Teardown        SISO Coam Test Teardown
Test Timeout         48h

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    ${BASIC_PATH_5G}/BTS/General_SiSo_Peak_with_Given_Information.robot
Resource    ${BASIC_PATH_5G}/Cell/E2E_SiSo_Cell_block_and_unblock_gNB.robot

Documentation
...    Author:zhihao shi
...    contact:zhihao.shi@nokia-sbell.com
...    squad group:SG_04
...    Feature CB007028 in SBTS22R2 program

Force Tags            5G_RAN    5G_RAN_TDD
...   PY36

*** Variables ***

*** Test Cases ***
#TL604 2S-4CC/2CC-2D-2U 1*SAMSUNG
[1]CB007028-5G-A4_02_General_SiSo_E2E_system_setup_with_data_transfer_conducted
    [Tags]    CRT_TRUNK    CRT_23R2    CRT_23R1
    General_SiSo_Peak_with_Given_Information    band=20    frame_structure=1116_3ms_GP1_A5
    ...    suite_name=${SUITE NAME}    test_name=${TEST NAME}

[1]CB007028-5G-A4_MIX_05_General_SiSo_Cell_block_and_unblock
    [Tags]    CRT_TRUNK    CRT_23R2    CRT_23R1    RF50
    ${fault_list}    Create List    49
    Allowed Watchdog additional alarms    fault_list=${fault_list}
    E2E_SiSo_Cell_block_and_unblock_gNB

#[1]CB007028-5G-A4_MIX_06_General_SiSo_RU_lock_unlock
#    General_SiSo_RU_lock_unlock
#
#[1]CB007028-5G-A3_14_General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot
#    General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot
#
#[1]CB007028-5G-A3_02_General_SiSo_RF_module_reset_from_GUI
#    General_SiSo_RF_module_reset_from_GUI
#
#[1]CB007028-5G-A3_03_General_SiSo_RF_module_power_reset
#    General_SiSo_RF_module_power_reset
#
#[1]CB007028-5G-A3_04_General_SiSo_RU_lock_unlock
#    General_SiSo_RU_lock_unlock
#
#[1]CB007028-5G-A3_05_General_SiSo_Cell_block_and_unblock
#    General_SiSo_Cell_block_and_unblock
#
#[1]CB007028-5G-A3_06_General_SiSo_Online_Cell_addition_deletion
#    General_SiSo_Online_Cell_addition_deletion
#
#[1]CB007028-5G-A3_10_General_SiSo_CPRI_link_configuration
#    General_SiSo_CPRI_link_configuration
#
#[1]CB007028-5G-A3_01_General_SiSo_Commissioning_BTS_Template_Commissioning
#    General_SiSo_Commissioning_BTS_Template_Commissioning
#
#[1]CB007028-5G-A3_13_General_SiSo_BTS_startup_with_delayed_RF_link_setup
#    General_SiSo_BTS_startup_with_RF_delayed_startup
#
#[1]CB007028-5G-A3_20_OAM_KPI_61a_SiSo_Auto_BTS_site_reset
#    [Timeout]    24h
#    Set Log Level    INFO
#    General_Stability_Test_Case    case_name=General_SiSo_Auto_BTS_site_reset    times=${20}    pass=${19}
#
#[1]CB007028-5G-A3_11_General_SiSo_Auto_Cell_lock_and_unlock
#    [Timeout]    30h
#    Set Log Level    INFO
#    General_Stability_Test_Case    case_name=General_SiSo_Cell_block_and_unblock    times=${20}    pass=${19}
#
#[1]CB007028-5G-A3_19_General_SiSo_stability_with_L3Call
#    [Timeout]    12h
#    Set Log Level    INFO
#    ${cell_list}    Get All Cell Id
#    General_Stability_Test_Case    case_name=Get UE From Init File and Make call  times=${10}    pass=${9}
#    ...    cell_list=${cell_list}  duration=${1800}    ue_num_each_call=${4}
#
#[1]CB007028-5G-A3_18_General_SiSo_E2E_system_setup_with_data_transfer_conducted_with_1116_3ms
#    General_SiSo_Peak_with_Given_Information    band=20    frame_structure=1116_3ms_GP1_A5
#
#[1]CB007028-5G-A3_17_General_SiSo_E2E_system_setup_with_data_transfer_conducted_with_1116_0ms
#    General_SiSo_Peak_with_Given_Information    band=20    frame_structure=1116_0ms_GP2_A7    ue_num_each_call=${4}
#
#[1]CB007028-5G-A3_08_General_SiSo_Automatic_RAT_SW_upgrade
#    General_SiSo_Auto_Automatic_RAT_SW_upgrade
#
#[1]CB007028-5G-A4_01_General_SiSo_Commissioning_BTS_Template_Commissioning
#    General_SiSo_Commissioning_BTS_Template_Commissioning
#
#[1]CB007028-5G-A4_MIX_04_General_SiSo_RF_module_power_reset
#    General_SiSo_RF_module_power_reset
#
#[1]CB007028-5G-A6_OAM_KPI_61a_SiSo_Auto_BTS_site_reset
#    [Timeout]    12h
#    Set Log Level    INFO
#    General_Stability_Test_Case    case_name=General_SiSo_Auto_BTS_site_reset    times=${20}    pass=${19}
#
#[1]CB007028-5G_General_SiSo_stability_with_L3Call
#    ${cell_list}    Get All Cell Id
#    Get UE From Init File and Make call    cell_list=${cell_list}  duration=${120}    ue_num_each_call=${3}
#    ...    check_wait_time=${120}
#
#[1]CB007028-5G-A6_10_OAM_KPI_61a_SiSo_Auto_BTS_site_reset
#    [Timeout]    12h
#    Set Log Level    INFO
#    General_Stability_Test_Case    case_name=General_SiSo_Auto_BTS_site_reset    times=${20}    pass=${19}
#
#[1]CB007028-5G-A6_10_OAM_SiSo_Auto_BTS_site_reset
#    General_SiSo_Auto_BTS_site_reset

*** Keywords ***
