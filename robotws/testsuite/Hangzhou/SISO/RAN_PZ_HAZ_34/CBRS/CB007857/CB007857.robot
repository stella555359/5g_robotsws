# *** Settings ***
# Suite Setup          CBRS Suite Setup
# Suite Teardown       CBRS Suite Teardown
# Test Setup           CBRS Test Setup
# Test Teardown        CBRS Test Teardown
# 
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
# Resource    ${BASIC_PATH_5G}/Cell/General_SiSo_Cell_block_and_unblock.robot
# Resource    ${BASIC_PATH_5G}/General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot.robot
# Resource    ${BASIC_PATH_5G}/General_SiSo_RF_module_power_reset.robot
# Resource    ${BASIC_PATH_5G}/General_SiSo_Commissioning_BTS_Template_Commissioning.robot
# Resource    ${BASIC_PATH_5G}/General_SiSo_RF_module_reset_from_GUI.robot
# Resource    ${BASIC_PATH_5G}/General_SiSo_Configuration_BPF_and_TargetBD_support_for_RF_module.robot
# Resource    ${BASIC_PATH_5G}/General_SiSo_RF_module_addition_in_BIM_and_WebUI.robot
# Resource    ${BASIC_PATH_5G}/General_SiSo_RU_lock_unlock.robot
# Resource    ${BASIC_PATH_5G}/Cell/General_SiSo_Cell_lock_and_unlock.robot
# Resource    resources/CB007857_common_keywords.robot
# Variables    TestData/7857_variables.py
# 
# Documentation
# ...    Author:cailanwen
# ...    contact:lanwen.cai@nokia-sbell.com
# ...    squad group:SG_08
# ...    Feature CB007857
# 
# Force Tags    SBTS00    CRT_TRUNK    CRT_22R3    CRT_22R4    CRT_23R1
# ...    PY36
# 
# *** Variables ***
# 
# *** Test Cases ***
# [1][2.0] General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot
#     Start SAS server
#     Wait until keyword succeeds    5min    30s    verify all cells should be onair
#     General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot
# 
# [1][2.0] General_SiSo_RF_module_power_reset
#     Start SAS server
#     Wait until keyword succeeds    5min    30s    verify all cells should be onair
#     General_SiSo_RF_module_power_reset
# 
# [1][1.0] General_SiSo_Commissioning_BTS_Template_Commissioning
#     Start SAS server
#     Wait until keyword succeeds    5min    30s    verify all cells should be onair
#     General_SiSo_Commissioning_BTS_Template_Commissioning
# 
# [1][1.0] General_SiSo_RU_module_reset_from_GUI
#     Start SAS server
#     Wait until keyword succeeds    5min    30s    verify all cells should be onair
#     General_SiSo_RF_module_reset_from_GUI
# 
# [1][1.0] General_SiSo_Configuration_BPF_and_TargetBD_support_for_RF_module
#     Start SAS server
#     Wait until keyword succeeds    5min    30s    verify all cells should be onair
#     General_SiSo_Configuration_BPF_and_TargetBD_support_for_RF_module
# 
# [1][1.0] General_SiSo_RF_module_addition_in_BIM_and_WebUI
#     Start SAS server
#     Wait until keyword succeeds    5min    30s    verify all cells should be onair
#     General_SiSo_RF_module_addition_in_BIM_and_WebUI
# 
# [1][1.0] General_SiSo_Cell_block_and_unblock
#     Start SAS server
#     Wait until keyword succeeds    5min    30s    verify all cells should be onair
#     General_SiSo_Cell_block_and_unblock
# 
# [1][1.0] General_SiSo_RU_lock_unlock
#     Start SAS server
#     Wait until keyword succeeds    5min    30s    verify all cells should be onair
#     General_SiSo_RU_lock_unlock
# 
# [1][1.0] General_SiSo_Cell_lock_and_unlock
#     Start SAS server
#     Wait until keyword succeeds    5min    30s    verify all cells should be onair
#     General_SiSo_Cell_lock_and_unlock
# 
# [1]General_SiSo_E2E_system_setup_with_data_transfer
#     Verify_CBRS_L3_call    tput_self_define=${tput_define}
# 
# [1]General_SiSo_E2E_system_setup_with_data_transfer_40MHz
#     ${40M_SCF}    Replace String    ${Golden_SCF_Path}    SCF_    SCF_40M_
#     Commissioning SCF And Check RU On Air    scf_file_path=${40M_SCF}
#     Verify_CBRS_L3_call    tput_self_define=${tput_define}
# 
# [1]General_SiSo_E2E_system_setup_with_data_transfer_90MHz
#     ${90M_SCF}    Replace String    ${Golden_SCF_Path}    SCF_    SCF_90M_
#     Commissioning SCF And Check RU On Air    scf_file_path=${90M_SCF}
#     Verify_CBRS_L3_call    tput_self_define=${tput_define}
# 
# [1]General_SiSo_E2E_system_setup_with_data_transfer_100MHz
#     ${100M_SCF}    Replace String    ${Golden_SCF_Path}    SCF_    SCF_100M_
#     Commissioning SCF And Check RU On Air    scf_file_path=${100M_SCF}
#     Verify_CBRS_L3_call    tput_self_define=${tput_define}
# 	
# [1]CB007857_De-activation of NR CBRS for AEQM
#     Verify_the_CBRS_online_de-activation_is_successful
# 
# [1]CB007857_grant_fail_desiredCHBW_less_than_channel_block_with_maxGrantChBwRed==0
#     CB007857_grant_fail_desiredCHBW_less_than_channel_block_with_maxGrantChBwRed_0
# 
# [1]CB007857_maxERIP_check_8DL_40MHz
#     CB007857_maxERIP_check_8DL_40MHz
# 
# *** Keywords ***
