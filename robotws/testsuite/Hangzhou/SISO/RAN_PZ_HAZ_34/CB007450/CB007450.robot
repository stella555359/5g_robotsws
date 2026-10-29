# *** Settings ***
# Suite Setup          SBTS Suite Setup
# Suite Teardown       SBTS Suite Teardown
# Test Setup           SBTS Test Setup
# Test Teardown        SBTS Test Teardown
# Test Timeout         12h
# 
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
# Resource    ${BASIC_PATH_COMMON}/SBTS_Setup_And_Teardown.robot
# Resource    ${BASIC_PATH_LTE}/Manual_SiSo_SM_RF_Module_lock_unlock.robot
# 
# Documentation
# ...    Author:zhihao shi
# ...    contact:zhihao.shi@nokia-sbell.com
# ...    squad group:SG_04
# ...    Feature Owner: Li Jie 2
# ...    Feature CB007450 in SBTS00 program
# 
# Force Tags            5G_RAN    5G_RAN_TDD    RAN_5G_TDD    RAN_5G    STATE_SW_UPLOADED   CLOUD_5G_CLASSICAL_SA_ASILL_ABIOB1_AZNA
# ...   PY36
# 
# *** Variables ***
# ${cell_type}   lte
# 
# *** Test Cases ***
# # TL604(LTE) 7450
# [1]CB007450-A_Manual_SiSo_SM_RF_Module_lock_unlock_ASOE_C3
#     [Tags]    2S-2CC-2D-2U    CRT_TRUNK    CRT_23R2    CRT_23R1
#     Manual_SiSo_SM_RF_Module_lock_unlock
# 
# #[1]CB007450-A_General_SiSo_BTS_startup_with_delayed_RF_link_setup_ASOE_C3
# #    General_SiSo_BTS_startup_with_RF_delayed_startup
# #
# #[1]CB007450-A_General_SiSo_Cell_block_and_unblock_ASOE_C3
# #    General_SiSo_Cell_block_and_unblock
# #
# #[1]CB007450-A_General_SiSo_Commissioning_BTS_Template_Commissioning_ASOE_C3
# #    General_SiSo_Commissioning_BTS_Template_Commissioning
# #
# #[1]CB007450-A_General_SiSo_Online_Sector_Addition_Deletion_ASOE_C3
# #    General_SiSo_Online_Cell_Addition_Deletion
# #
# #[1]CB007450-A_Manual_SiSo_CALL_LTE_data_call_ASOE_C3
# #
# #[1]CB007450-A_Manual_SiSo_REC_Radio_Module_power_reset_ASOE_C3
# #    General_SiSo_RF_module_power_reset
# #
# #[1]CB007450-A_Manual_SiSo_SM_BTS_Site_Reset_ASOE_C3
# #    General_SiSo_Auto_BTS_site_reset
# #
# #[1]CB007450-A_Manual_SiSo_SM_LTE_RAT_reset_ASOE_C3
# #    General_SiSo_RF_module_reset_from_GUI
# #
# 
# # TL602 3S-1CC
# #[1]CB007450-A_General_SiSo_Cell_block_and_unblock_ABIO_C4
# #    General_SiSo_Cell_block_and_unblock
# #
# #[1]CB007450-A_General_SiSo_Commissioning_BTS_Template_Commissioning_ABIO_C4
# #    General_SiSo_Commissioning_BTS_Template_Commissioning
# #
# #[1]CB007450-A_General_SiSo_Online_Cell_Addition_Deletion_ABIO_C4
# #    General_SiSo_Online_Cell_Addition_Deletion
# #
# #[1]CB007450-A_Manual_SiSo_CALL_LTE_data_call_ABIO_C4
# #
# #[1]CB007450-A_Manual_SiSo_REC_Radio_Module_power_reset_ABIO_C4
# #    General_SiSo_RF_module_power_reset
# #
# #[1]CB007450-A_Manual_SiSo_SM_BTS_Site_Reset_ABIO_C4
# #    General_SiSo_Auto_BTS_site_reset
# #
# #[1]CB007450-A_Manual_SiSo_SM_LTE_RAT_reset_ABIO_C4
# #    General_SiSo_RF_module_reset_from_GUI
# #
# #[1]CB007450-A_Manual_SiSo_SM_RF_Module_lock_unlock_ABIO_C4
# #    General_SiSo_RU_lock_unlock
# #
# #[1]CB007450-A_General_SiSo_Cell_block_and_unblock_ABIN_C4
# #    General_SiSo_Cell_block_and_unblock
# #
# #[1]CB007450-A_General_SiSo_Commissioning_BTS_Template_Commissioning_ABIN_C4
# #    General_SiSo_Commissioning_BTS_Template_Commissioning
# #
# #[1]CB007450-A_General_SiSo_Online_Cell_Addition_Deletion_ABIN_C4
# #    General_SiSo_Online_Cell_Addition_Deletion
# #
# #[1]CB007450-A_Manual_SiSo_CALL_LTE_data_call_ABIN_C4
# #
# #[1]CB007450-A_Manual_SiSo_REC_Radio_Module_power_reset_ABIN_C4
# #    General_SiSo_RF_module_power_reset
# #
# #[1]CB007450-A_Manual_SiSo_SM_BTS_Site_Reset_ABIN_C4
# #    General_SiSo_Auto_BTS_site_reset
# #
# #[1]CB007450-A_Manual_SiSo_SM_LTE_RAT_reset_ABIN_C4
# #    General_SiSo_RF_module_reset_from_GUI
# #
# #[1]CB007450-A_Manual_SiSo_SM_RF_Module_lock_unlock_ABIN_C4
# #    General_SiSo_RU_lock_unlock
# 
# *** Keywords ***
