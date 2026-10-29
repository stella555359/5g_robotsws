# *** Settings ***
# Suite Setup          SISO Coam Suite Setup
# Suite Teardown       SISO Coam Suite Teardown
# Test Teardown        SISO Coam Test Teardown
# Test Timeout         1200 min
# 
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
# Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
# Resource    ${BASIC_PATH_5G}/Cell/E2E_SiSo_Cell_lock_and_unlock_gNB.robot
# Resource    ${BASIC_PATH_5G}/Cell/E2E_SiSo_Cell_block_and_unblock_gNB.robot
# Resource    ${BASIC_PATH_5G}/Baseband_module_reset_via_WEBUI.robot
# Resource    ${BASIC_PATH_5G}/General_Stability_Test_Case.robot
# Resource    ${BASIC_PATH_5G}/General_SiSo_RF_module_reset_via_admin.robot
# Resource    ../Resource/e2e_common_cases.robot
# 
# Documentation
# ...    Author: tingting zhong
# ...    Contact: tingting.zhong@nokia-sbell.com
# ...    squad group:SG_04
# ...    Feature E2E Sleepingcell
# 
# Force Tags            5G_RAN_TDD    STATE_GNB_COMMISSIONED
# ...   PY36
# 
# *** Variables ***
# ${if_commissioning}                     True
# ${rf_reset_total_times}                 ${3}
# ${bbmod_reset_total_times}              ${3}
# ${cell_lock_unlock_times}               ${3}
# ${cell_block_unblock_times}             ${3}
# ${delta_commissioning_total_times}      ${3}
# 
# *** Test Cases ***
# [1]E2E_11_OAM_KPI_651_SiSo_Auto_RF_reset_success_rate_from_webem_with_L3Call
#     log to console    \ntotal times:${rf_reset_total_times}
#     log to console    \nneed pass times:${rf_reset_total_times}
#     General_Stability_Test_Case    case_name=General_SiSo_RF_module_reset_via_admin
#     ...    times=${rf_reset_total_times}    pass=${rf_reset_total_times}    with_recovery=${False}
#     ...    common_setup_each_time=${True}    with_call=${True}    with_peak=${False}
# 
# [1]E2E_05_SiSo_BBMOD_module_reset_from_GUI_with_Single_UE_perCell_L3call_peak_NSA
#     log to console    \ntotal times:${bbmod_reset_total_times}
#     log to console    \nneed pass times:${bbmod_reset_total_times}
#     General_Stability_Test_Case    case_name=Baseband_module_reset_via_WEBUI
#     ...    times=${bbmod_reset_total_times}    pass=${bbmod_reset_total_times}    with_recovery=${False}
#     ...    common_setup_each_time=${True}    with_call=${True}    with_peak=${False}
# 
# [1]E2E_02_SiSo_Cell_lock_and_unlock_gNB_with_Single_UE_perCell_L3call_peak_NSA
#     log to console    \ntotal times:${cell_lock_unlock_times}
#     log to console    \nneed pass times:${cell_lock_unlock_times}
#     General_Stability_Test_Case    case_name=E2E_SiSo_Cell_lock_and_unlock_gNB
#     ...    times=${cell_lock_unlock_times}    pass=${cell_lock_unlock_times}    with_recovery=${False}
#     ...    common_setup_each_time=${True}    with_call=${True}    with_peak=${False}
# 
# [1]E2E_03_SiSo_Cell_block_and_unblock_gNB_with_Single_UE_perCell_L3call_peak_NSA
#     log to console    \ntotal times:${cell_block_unblock_times}
#     log to console    \nneed pass times:${cell_block_unblock_times}
#     General_Stability_Test_Case    case_name=E2E_SiSo_Cell_block_and_unblock_gNB
#     ...    times=${cell_block_unblock_times}    pass=${cell_block_unblock_times}    with_recovery=${False}
#     ...    common_setup_each_time=${True}    with_call=${True}    with_peak=${False}
# 
# [1]E2E_01_SiSo_Delta_Commissioning_with_sleeping_cell_check
#     log to console    \ntotal times:${delta_commissioning_total_times}
#     log to console    \nneed pass times:${delta_commissioning_total_times}
#     General_Stability_Test_Case    case_name=Delta_Commissioning_With_Given_Parameter
#     ...    times=${delta_commissioning_total_times}    pass=${delta_commissioning_total_times}    with_recovery=${False}
#     ...    common_setup_each_time=${True}    with_peak=${False}
# 
# *** Keywords ***
