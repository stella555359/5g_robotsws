# *** Settings ***
# Suite Setup          SISO Coam Suite Setup
# Suite Teardown       SISO Coam Suite Teardown
# Test Setup
# Test Teardown
# Test Timeout         120 min
# 
# Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG5/robot/E2E/resources/e2e_common_cases_pcmd.robot
# Variables    TestData/variables.py
# 
# Documentation
# ...    Author:shasha.liu
# ...    contact:shasha.liu@nokia-sbell.com
# ...    squad group:SG_05
# ...    Feature CB006657 in 5G21B program
# ...    note1: current mixed AWHQV & AWHTA in this TL
# ...    note2: current no UE in this TL
# 
# Force Tags    5G_RAN_TDD
# ...    PY36
# 
# *** Variables ***
# 
# *** Test Cases ***
# #[1]CB006657_001_AWHQV_General_SiSo_Configuration_BPF_and_TargetBD_support_for_RF_module
# #    [Tags]   CLOUD_5G_CLASSICAL_ASIKL_ABILB1_AWHQG_ENB   CRT_21B
# #    [Setup]    SISO Coam Test Setup
# #    [Teardown]    SISO Coam Test Teardown
# #    General_SiSo_Configuration_BPF_and_TargetBD_support_for_RF_module    variable_from_CFAM=${Variables_CFAM_AWHQV_CPRI}
# 
# #[1]CB006657_006_AWHQV_General_SiSo_Cell_lock_and_unlock
# #    [Tags]   CLOUD_5G_CLASSICAL_ASIKL_ABILB1_AWHQG_ENB   CRT_21B
# #    [Setup]    SISO Coam Test Setup
# #    [Teardown]    SISO Coam Test Teardown
# #    General_SiSo_Cell_lock_and_unlock    with_call=${False}
# #    E2E_gNB_SiSo_cell_block_and_unblock_by_RadioType_pcmd   RU_type=AWHQV   with_call=${False}   with_pcmd=${False}
# 
# [1]5GC001833-A_08_AWHTA_General_SiSo_Cell_lock_and_unlock
#     [Tags]    CRT_TRUNK    CRT_22R1   CRT_22R2   CRT_22R3   CRT_22R4   CRT_23R1
#     [Setup]    SISO Coam Test Setup
#     [Teardown]    SISO Coam Test Teardown
# #    General_SiSo_Cell_lock_and_unlock    with_call=${False}
#     E2E_gNB_SiSo_cell_block_and_unblock_by_RadioType_pcmd   RU_type=AWHTA   with_call=${False}   with_pcmd=${False}
# 
# [1]5GC001833-A_09_AWHTA_General_SiSo_RU_lock_unlock
#     [Tags]    CRT_TRUNK    CRT_22R1   CRT_22R2   CRT_22R3   CRT_22R4   CRT_23R1
#     [Setup]    SISO Coam Test Setup
#     [Teardown]    SISO Coam Test Teardown
# #    General_SiSo_RU_lock_unlock    with_call=${False}
#     E2E_gNB_SiSo_RU_lock_and_unlock_by_RadioType_pcmd   RU_type=AWHQV   with_call=${False}   with_pcmd=${False}
# 
# #[1]CB006657_002_AWHQV_General_SiSo_Commissioning_BTS_Template_Commissioning
# #    [Tags]   CLOUD_5G_CLASSICAL_ASIKL_ABILB1_AWHQG_ENB   CRT_21B   CRT_TRUNK
# #    [Setup]    SISO Coam Test Setup
# #    [Teardown]    SISO Coam Test Teardown
# #    General_SiSo_Commissioning_BTS_Template_Commissioning
# #
# #[1]CB006657_004_AWHQV_General_SiSo_RF_module_power_reset
# #    [Tags]   CLOUD_5G_CLASSICAL_ASIKL_ABILB1_AWHQG_ENB   CRT_21B   CRT_TRUNK
# #    [Setup]    SISO Coam Test Setup
# #    [Teardown]    SISO Coam Test Teardown
# #    General_SiSo_RF_module_power_reset
# #
# #[1]CB006657_005_AWHQV_General_SiSo_BTS_startup_with_RF_delayed_startup
# #    [Tags]   CLOUD_5G_CLASSICAL_ASIKL_ABILB1_AWHQG_ENB   CRT_21B   CRT_TRUNK
# #    [Setup]    SISO Coam Test Setup
# #    [Teardown]    SISO Coam Test Teardown
# #    General_SiSo_BTS_startup_with_RF_delayed_startup
# #
# #[1]CB006657_007_AWHQV_General_SiSo_RF_alarms_with_recovery
# #    [Tags]   CLOUD_5G_CLASSICAL_ASIKL_ABILB1_AWHQG_ENB   CRT_21B   CRT_TRUNK
# #    [Setup]    SISO Coam Test Setup
# #    [Teardown]    SISO Coam Test Teardown
# #    General_SiSo_RF_alarms_with_recovery
# #
# #[1]CB006657_008_AWHQV_General_SiSo_RF_alarms_without_recovery
# #    [Tags]   CLOUD_5G_CLASSICAL_ASIKL_ABILB1_AWHQG_ENB   CRT_21B   CRT_TRUNK
# #    [Setup]    SISO Coam Test Setup
# #    [Teardown]    SISO Coam Test Teardown
# #    General_SiSo_RF_alarms_without_recovery
# #
# #[1]CB006657_009_AWHQV_General_SiSo_NR-ARFCN_check
# #    [Tags]   CLOUD_5G_CLASSICAL_ASIKL_ABILB1_AWHQG_ENB   CRT_21B   CRT_TRUNK
# #    [Setup]    SISO Coam Test Setup
# #    [Teardown]    SISO Coam Test Teardown
# #    General_SiSo_NR-ARFCN_check    variable_from_CFAM=${Variables_CFAM_AWHQV_CPRI}
# #
# #[1]CB006657_012_AWHQV_1Sector_1CC_4DL_256QAM_4UL_256QAM_FR1_2SFP_100MHz_with_L3Call_mcs27_fiber_60m_1070_GP1_A3
# #    [Tags]   CLOUD_5G_CLASSICAL_ASIKL_ABILB1_AWHQG_ENB   CRT_21B   CRT_TRUNK    #2S-1CC-4D-4U
# #    [Setup]    SISO Coam Test Setup
# #    [Teardown]    SISO Coam Test Teardown
# #    General_SiSo_E2E_system_setup_with_data_transfer    band=100    cell_id=1
# #
# #[1]CB006657_013_AWHQV_2Sector_1CC_2DL_256QAM_2UL_64QAM_FR1_2SFP_100MHz_with_L3Call_mcs27_fiber_60m_1116_3ms_GP2_A6
# #    [Tags]   CLOUD_5G_CLASSICAL_ASIKL_ABILB1_AWHQG_ENB   CRT_21B   CRT_TRUNK    #2S-1CC-2D-2U
# #    [Setup]    SISO Coam Test Setup
# #    [Teardown]    SISO Coam Test Teardown
# #    General_SiSo_E2E_system_setup_with_data_transfer    band=100    cell_id=1
# 
# *** Keywords ***
