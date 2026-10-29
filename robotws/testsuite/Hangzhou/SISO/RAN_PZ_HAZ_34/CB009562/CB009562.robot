# *** Settings ***
# Suite Setup          SISO Coam Suite Setup
# Suite Teardown       SISO Coam Suite Teardown
# Test Setup           SISO Coam Test Setup
# Test Teardown        SISO Coam Test Teardown
# Test Timeout         200 min
# 
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
# Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
# Resource    ${BASIC_PATH_5G}/General_SiSo_Auto_BTS_site_reset.robot
# Resource    ${BASIC_PATH_5G}/General_SiSo_Configuration_BPF_and_TargetBD_support_for_RF_module.robot
# Resource    ${BASIC_PATH_5G}/General_SiSo_RF_module_reset_from_GUI.robot
# Resource    ${BASIC_PATH_5G}/Cell/E2E_SiSo_Cell_block_and_unblock_gNB.robot
# Resource    ${BASIC_PATH_5G}/E2E_SiSo_RU_lock_and_unlock_gNB.robot
# Resource    ${BASIC_PATH_5G}/Cell/General_SiSo_Online_Cell_addition_deletion.robot
# Resource    ${BASIC_PATH_5G}/General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot.robot
# Resource    ${BASIC_PATH_5G}/BTS/General_SiSo_RAT_Block_Unblock.robot
# Resource    ${BASIC_PATH_COMMON}/Manual_Siso_PM_5G_uDTX.robot
# Resource    ${BASIC_PATH_5G}/General_SiSo_Power_Meter_counter_update_for_energy_consumption.robot
# Resource    ${BASIC_PATH_5G}/General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot.robot
# Resource    ${BASIC_PATH_5G}/General_SiSo_NR-ARFCN_check.robot
# Resource    ${BASIC_PATH_5G}/General_RU_entering_deep_sleep_mode_for_energy_efficiency_with_CB007511_enabled.robot
# Resource    ${BASIC_PATH_COMMON}/Manual_SiSo_Validating_max_allowed_power_on_RU.robot
# Resource    Resource/CB009562_resource.robot
# Resource    ./../CB009563/Resource/CB009563_common_keyword.robot
# 
# 
# 
# Documentation
# ...    Author:mengting.li@nokia-sbell.com
# ...    Team group:HAZ4_T04
# ...    Feature Leader: Shi Gaofan
# ...    Feature Owner: Xu mingming
# ...    Feature CB009562 AVQA in trunk program
# ...    Known PR:
# 
# Force Tags            5G_RAN    5G_RAN_TDD    RAN_5G_TDD    RAN_5G    STATE_SW_UPLOADED    CLOUD_5G_CLASSICAL_SA_ASIBL_ABIOB1_AVQC
# ...   PY36
# 
# *** Variables ***
# 
# *** Test Cases ***
# [1]CB009562_SR_B_03_AVQA_Manual_SiSo_SM_BTS_Site_Reset
#     [Tags]    1S-1CC-16D-8U
#     General_SiSo_Auto_BTS_site_reset    with_call=${True}
# 
# [1]CB009562_SR_A_01_AVQA_General_SiSo_Configuration_BPF_and_TargetBD_support_for_RF_module
#     [Tags]    1S-1CC-16D-8U
#     General_SiSo_Configuration_BPF_and_TargetBD_support_for_RF_module
# 
# [1]CB009562_SR_A_11_AVQA_General_SiSo_Static_HW_Capabilities_Validation
#     [Tags]    1S-1CC-16D-8U
#     CB009562_General_SiSo_Static_HW_Capabilities_Validation
# 
# [1]CB009562_SR_B_02_AVQA_General_SiSo_RU_module_reset_from_GUI
#     [Tags]    1S-1CC-16D-8U
#     General_SiSo_RF_module_reset_from_GUI    with_call=${True}
# 
# [1]CB009562_SR_B_05_AVQA_General_SiSo_Cell_block_and_unblock
#     [Tags]    1S-1CC-16D-8U
#     [Timeout]  3h
#     E2E_SiSo_Cell_block_and_unblock_gNB    with_call=${True}    with_peak=${True}    call_duration=${300}
#     ...    suite_name=${SUITE NAME}    test_name=${TEST NAME}
# 
# [1]CB009562_SR_B_06_AVQA_Manual_SiSo_SM_RF_Module_lock_unlock
#     [Tags]    1S-1CC-16D-8U
#     E2E_SiSo_RU_lock_and_unlock_gNB  with_call=${True}   with_peak=${True}   call_duration=${300}
#     ...    suite_name=${SUITE NAME}   test_name=${TEST NAME}
# 
# [1]CB009562_SR_B_11_AVQA_General_SiSo_Snapshot_Showing_RU_Logs_For_a_Failure_After_Radio_Reset
#     [Tags]    1S-1CC-16D-8U
#     [Documentation]
#     ...    Known occasional PR: PR766272
#     Snapshot_Full_level_showing_reason_for_a_failure_after_radio_has_been_re-started_AVQC
#     ...    fault_logger_json=${CURDIR}/TestData/fault_logger.json
# 
# [1]CB009562_SR_C_03_AVQA_General_SiSo_Online_Cell_addition_deletion
#     [Tags]    1S-2CC-16D-8U
#     Selenium Login And Disable Screen Lock
#     Prepare for delete NRPGRP
#     Online delete NRPGRP
#     General_SiSo_Online_Cell_addition_deletion
#     [Teardown]  run keywords    SISO Coam Test Teardown    perform_case_scf=${True}    AND
#     ...    Selenium Logout And Close Browser
# 
# [1]CB009562_SR_C_05_AVQA_General_SiSo_RAT_Block_Unblock_with_L3call
#     [Tags]    1S-2CC-16D-8U
#     General_SiSo_RAT_Block_Unblock    with_call=${True}
# 
# [1]CB009562_SR_C_13_AVQA_Manual_Siso_PM_5G_Udtx
#     [Tags]    1S-2CC-16D-8U
#     Manual_Siso_PM_5G_uDTX    cell_type=nr    with_call=${True}
# 
# [1]CB009562_SR_C_15_AVQA_General_SiSo_Power_Meter_counter_update_for_energy_consumption
#     [Tags]    1S-2CC-16D-8U
#     General_SiSo_Power_Meter_counter_update_for_energy_consumption
# 
# [1]CB009562_SR_C_18_AVQA_General_SiSo_stability_with_L3Call
#     [Tags]    1S-2CC-16D-8U
#     ${ru_index_list}  Get All RU Index
#     FOR  ${ru_index}  IN  @{ru_index_list}
#         ${cell_list}    Get All Cell Id    ${ru_index}
#         Get UE From Init File and Make call    cell_list=${cell_list}    with_peak=${False}    duration=${1800}
#     END
# 
# [1]CB009562_SR_C_02_AVQA_General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot
#     [Tags]    1S-2CC-16D-8U
#     [Documentation]
#     ...    Known Permanent PR: PR766272 because of ASIM
#     General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot    is_get_snapshot_via_selenium=${True}
# 
# [1]CB009562_SR_A_07_AVQA_General_SiSo_NR-ARFCN_check
#     [Tags]    1S-1CC-16D-8U
#     [Documentation]
#     ...    Description: trigger FID1900 by update nrarfcn and gscn
#     General_SiSo_NR-ARFCN_check
# 
# [1]CB009562_SR_B_04_AVQA_Manual_SiSo_STARTUP_BTS_Power_Reset
#     [Tags]    1S-1CC-16D-8U
#     CB009562_Manual_SiSo_STARTUP_BTS_Power_Reset    with_call=${True}  with_peak=${True}
# 
# [1]CB009562_SR_C_14_AVQA_General_SiSo_Deep_Sleep_Mode_for_Energy_Efficiency_enhancement
#     [Tags]    1S-2CC-16D-8U
#     [Documentation]
#     ...    Problem: New PR775572, FID10 when RU goto deep sleep mode
#     ${status}   Run Keyword And Return Status   General_RU_entering_deep_sleep_mode_for_energy_efficiency_with_CB007511_enabled
#     Run Keyword If   not ${status}   Fail   General_RU_entering_deep_sleep_mode_for_energy_efficiency_with_CB007511_enabled failed
#     [Teardown]  run keywords    Run Keyword And Ignore Error   SISO Coam Test Teardown   perform_case_scf=${True}    AND
#     ...   Run Keyword And Ignore Error   Selenium Logout And Close Browser
# 
# [1]CB009562_SR_A_10_AVQA_Manual_SiSo_Validating_max_allowed_power_on_RU
#     [Tags]    1S-1CC-16D-8U
#     Manual_SiSo_Validating_max_allowed_power_on_RU
