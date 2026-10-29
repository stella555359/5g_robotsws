*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Setup           SISO Coam Test Setup    fail_with_alarms=${True}
Test Teardown        SISO Coam Test Teardown
Test Timeout         12h

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_Configuration_BPF_and_TargetBD_support_for_RF_module.robot
Resource    ${BASIC_PATH_5G}/Cell/E2E_SiSo_Cell_block_and_unblock_gNB.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_BTS_startup_with_RF_delayed_startup.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_RF_module_power_reset.robot
Resource    ${BASIC_PATH_5G}/Cell/General_SiSo_Online_Cell_addition_deletion.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_LED_states_management_basic.robot
Resource    ${BASIC_PATH_5G}/BTS/General_SiSo_Peak_with_Given_Information.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_RF_alarms_with_recovery.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_RF_alarms_without_recovery.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_NR-ARFCN_check.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_RU_lock_unlock.robot

Documentation
...    Author:zhihao shi
...    contact:zhihao.shi@nokia-sbell.com
...    squad group:SG_04
...    Feature CB006892 in 22R1 program

Force Tags            5G_RAN    5G_RAN_TDD    RAN_5G_TDD    RAN_5G    STATE_SW_UPLOADED   CLOUD_5G_CLASSICAL_ASIB_ABIO_AQQC_ENB
...   PY36

*** Variables ***

*** Test Cases ***
#Tl582 1S-2CC-8D-4U
[1]CB006892_B_01_AQQC_General_SiSo_Configuration_BPF_and_TargetBD_support_for_RF_module
    [Tags]    SBTS00    master_classicalbts_all   CIT
    General_SiSo_Configuration_BPF_and_TargetBD_support_for_RF_module

[1]CB006892_C_04_AQQC_General_SiSo_Cell_block_and_unblock
    [Tags]    SBTS00    master_classicalbts_all   CIT
    ${fault_list}    Create List    49
    Allowed Watchdog additional alarms    fault_list=${fault_list}
    E2E_SiSo_Cell_block_and_unblock_gNB

[1]CB006892_C_02_AQQC_General_SiSo_BTS_startup_with_RF_delayed_startup
    [Tags]    CIT_22R4    CRT_22R3    CDRT_22R3    SBTS00    master_classicalbts_all   CIT
    ${fault_list}    Create List    10    4589    4590
    Allowed Watchdog additional alarms    fault_list=${fault_list}
    General_SiSo_BTS_startup_with_RF_delayed_startup

[1]CB006892_C_01_AQQC_General_SiSo_RF_module_power_reset
    [Tags]    SBTS00    master_classicalbts_all   CIT
    General_SiSo_RF_module_power_reset

[1]5GC002433_BA_03_AQQY_General_SiSo_Online_Cell_addition_deletion
    [Tags]    SBTS00    master_classicalbts_all   CIT
    General_SiSo_Online_Cell_addition_deletion

[1]5GC002433_AD_09_AQQY_General_SiSo_LED_states_management_basic
    [Tags]    CRT_22R4    CRT_TRUNK    SBTS00    master_classicalbts_all   CRT_UTE
    ${fault_list}    Create List    10    4589
    Allowed Watchdog additional alarms    fault_list=${fault_list}
    General_SiSo_LED_states_management_basic

[1]CB006892_B_11_AQQC_General_SiSo_E2E_system_setup_with_data_transfer_conducted
    [Tags]    CRT_TRUNK    SBTS00    master_classicalbts_all   CRT_UTE
    General_SiSo_Peak_with_Given_Information    use_case_variable=${True}    suite_name=${SUITE NAME}    test_name=${TEST NAME}
    ...    band=100    frame_structure=1208_GP1_A1    prach_index=93    ue_num_each_call=1

[1]CB006892_E_02_AQQC_General_SiSo_RF_alarms_with_recovery
    [Tags]    SBTS00    master_classicalbts_all   CIT
    ${fault_list}    Create List    1901
    Allowed Watchdog additional alarms    fault_list=${fault_list}
    General_SiSo_RF_alarms_with_recovery

[1]CB006892_E_03_AQQC_General_SiSo_RF_alarms_without_recovery
    [Tags]    SBTS00    master_classicalbts_all   CIT
    ${fault_list}    Create List    1937
    Allowed Watchdog additional alarms    fault_list=${fault_list}
    General_SiSo_RF_alarms_without_recovery

[1]CB006892_B_10_AQQC_General_SiSo_NR-ARFCN_check
    [Tags]    SBTS00    master_classicalbts_all   CIT
    ${fault_list}    Create List    1900
    Allowed Watchdog additional alarms    fault_list=${fault_list}
    General_SiSo_NR-ARFCN_check

[1]CB006892_F_06_AQQC_General_SiSo_E2E_system_setup_with_data_transfer_conducted_50M+80M
    [Tags]    CRT_TRUNK    SBTS00    master_classicalbts_all   CRT_UTE
    General_SiSo_Peak_with_Given_Information    use_case_variable=${True}    suite_name=${SUITE NAME}    test_name=${TEST NAME}
    ...    ue_num_each_call=1

[1]CB006892_E_05_AQQC_General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot
    [Tags]    CIT_22R4    CRT_22R3    CDRT_22R3    SBTS00    master_classicalbts_all   CIT
    General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot    is_get_snapshot_via_selenium=${True}

[1]CB006892_C_05_AQQC_General_SiSo_RU_lock_unlock
    [Tags]    SBTS00    master_classicalbts_all   CIT
    General_SiSo_RU_lock_unlock

#[1]CB006892_B_06_AQQC_eCPRI_sync_generic_startup_at_RU
#    [Tags]    1S-2CC-2D-2U
#    5GC000560_eLLF_sync_generic_startup_at_RU
#
#[1]CB006892_B_02_AQQC_General_SiSo_Commissioning_BTS_Template_Commissioning
#    [Tags]    1S-2CC-2D-2U
#    General_SiSo_Commissioning_BTS_Template_Commissioning
#
#[1]CB006892_E_04_AQQC_eCPRI_PTP_Failure
#    [Tags]    1S-2CC-2D-2U
#    5GC000560_eLLF_PTP_Failure
#
#[1]CB006892_B_08_AQQC_General_SiSo_Automatic_RAT_SW_upgrade
#    [Tags]    1S-2CC-2D-2U
#    [Timeout]    3h
#    General_SiSo_Auto_Automatic_RAT_SW_upgrade
#

*** Keywords ***
