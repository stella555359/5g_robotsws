# *** Settings ***
# Test Setup           run keywords    SISO Coam Suite Setup    AND    SISO Coam Test Setup
# Test Teardown        run keywords    SISO Coam Test Teardown    AND    SISO Coam Suite Teardown
# Test Timeout         1200 min
# 
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
# Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
# Resource    ${BASIC_PATH_5G}/General_SiSo_Commissioning_BTS_Template_Commissioning.robot
# Resource    ${BASIC_PATH_5G}/Cell/E2E_SiSo_Cell_lock_and_unlock_gNB.robot
# Resource    ${BASIC_PATH_5G}/Cell/E2E_SiSo_Cell_block_and_unblock_gNB.robot
# Resource    ${BASIC_PATH_5G}/E2E_SiSo_RU_lock_and_unlock_gNB.robot
# Resource    ${BASIC_PATH_5G}/Baseband_module_reset_via_WEBUI.robot
# Resource    ${BASIC_PATH_5G}/General_SiSo_RF_module_power_reset.robot
# Resource    ${BASIC_PATH_5G}/RF/General_SiSo_Beamforming_calibration.robot
# Resource    ${BASIC_PATH_5G}/General_SiSo_RF_module_reset_from_GUI.robot
# Resource    ${BASIC_PATH_5G}/General_Stability_Test_Case.robot
# Resource    ${BASIC_PATH_5G}/General_SiSo_RF_module_reset_via_admin.robot
# Resource    ${BASIC_PATH_5G}/BTS/Capture_snapshot_during_tracffic.robot
# Resource    ${BASIC_PATH_5G}/E2E_SiSo_RAT_block_unblock_via_WEBUI.robot
# Resource    ../Resource/e2e_common_cases.robot
# 
# Documentation
# ...    Author: tingting zhong
# ...    Contact: tingting.zhong@nokia-sbell.com
# ...    squad group:SG_04
# ...    Feature E2E CHT
# 
# Force Tags            5G_RAN_TDD    STATE_GNB_COMMISSIONED
# ...   PY36
# 
# *** Variables ***
# ${if_commissioning}             False
# ${rf_reset_total_times}         ${20}
# ${rf_reset_pass_times}          ${20}
# 
# *** Test Cases ***
# [1]E2E_SiSo_Single_UE_L3call_peak_at_first
#     ${gnb_len}    get length    ${tl.gnbs}
#     :FOR    ${gnb_index}    IN RANGE    ${gnb_len}
#         run keyword if    ${gnb_index}!=0    run keywords    SISO Coam Suite Setup    gnb_index=${gnb_index}    AND
#         ...    SISO Coam Test Setup    gnb_index=${gnb_index}
#         ${connection}    set variable if    ${gnb_index}==0    GNB_OAM    GNB_OAM_${gnb_index}
#         run keyword and continue on failure    Make Call with all ue attached RU    connection=${connection}
#         run keyword and continue on failure    CI_commssion.common commissioning    gnb_index=${gnb_index}
#         run keyword if    ${gnb_index}!=0    run keywords    SISO Coam Test Teardown    gnb_index=${gnb_index}
#         ...    is_case_teardown=${False}        AND
#         ...    SISO Coam Suite Teardown    gnb_index=${gnb_index}
#     END
# 
# [1]E2E_01_SiSo_Delta_Commissioning_with_sleeping_cell_check
#     Delta_Commissioning_With_Given_Parameter    with_peak=${True}
# 
# [1]E2E_SiSo_Cell_lock_and_unlock_gNB
#     E2E_SiSo_Cell_lock_and_unlock_gNB    with_call=${True}    with_peak=${True}
# 
# [1]E2E_SiSo_Cell_block_and_unblock_gNB
#     E2E_SiSo_Cell_block_and_unblock_gNB    with_call=${True}    with_peak=${True}
# 
# [1]E2E_SiSo_RU_lock_and_unlock_gNB
#     E2E_SiSo_RU_lock_and_unlock_gNB    with_call=${True}    with_peak=${True}
# 
# [1]E2E_SiSo_BBMOD_module_reset_from_GUI_L3call
#     Baseband_module_reset_via_WEBUI    with_call=${True}    with_peak=${True}
# 
# [1]E2E_SiSo_Beamforming_calibration
#     general_siso_beamforming_calibration
# 
# #[1]E2E_SiSo_RF_module_reset_from_GUI_with_L3call
# #    ${gnb_len}    get length    ${tl.gnbs}
# #    :FOR    ${gnb_index}    IN RANGE    ${gnb_len}
# #        run keyword if    ${gnb_index}!=0    run keywords    SISO Coam Suite Setup    gnb_index=${gnb_index}    AND
# #        ...    SISO Coam Test Setup    gnb_index=${gnb_index}
# #        ${connection}    set variable if    ${gnb_index}==0    GNB_OAM    GNB_OAM_${gnb_index}
# #        run keyword and continue on failure    General_SiSo_RF_module_reset_from_GUI    with_call=${True}    with_peak=${True}
# #        ...    gnb_index=${gnb_index}    connection=${connection}
# #        run keyword if    ${gnb_index}!=0    run keywords    SISO Coam Test Teardown    gnb_index=${gnb_index}
# #        ...    is_case_teardown=${False}        AND
# #        ...    SISO Coam Suite Teardown    gnb_index=${gnb_index}
# #    END
# #
# #[1]E2E_SiSo_RF_module_power_reset_with_L3call
# #    General_SiSo_RF_module_power_reset    with_call=${True}    with_peak=${True}
# 
# [1]E2E_SiSo_Single_UE_L3call_peak_NSA_90Mhz_1070_A3
#     ${ru_index_list}  Get All RU Index
#     FOR  ${ru_index}  IN  @{ru_index_list}
#         ${cell_list}    Get All Cell Id    ${ru_index}
#         Get UE From Init File and Make call    cell_list=${cell_list}    with_peak=${True}    duration=${600}
#     END
# 
# [1]E2E_11_OAM_KPI_651_SiSo_Auto_RF_reset_success_rate_from_webem_with_L3Call
#     log to console    \ntotal times:${rf_reset_total_times}
#     log to console    \nneed pass times:${rf_reset_pass_times}
#     General_Stability_Test_Case    case_name=General_SiSo_RF_module_reset_via_admin
#     ...    times=${rf_reset_total_times}    pass=${rf_reset_pass_times}    with_recovery=${False}    common_setup_each_time=${True}
#     ...    with_call=${True}    with_peak=${True}    test_name=${TEST NAME}
#     ##[Teardown]  Run Keyword If Test Failed    Fatal Error
# 
# [1]E2E_12_SiSo_Radio_memory_verification_by_capturing_snapshot_during_L3call
#     Capture_snapshot_during_tracffic
# 
# [1]E2E_13_Timing_offset_online_activation_and_modification_L3call
#     Timing_offset_online_activation_and_modification_L3call
#     [Teardown]  run keywords    SISO Coam Test Teardown    perform_case_scf=${True}    AND    SISO Coam Suite Teardown
# 
# 
# *** Keywords ***
