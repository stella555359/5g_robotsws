# *** Settings ***
# Suite Setup          SISO Coam Suite Setup
# Suite Teardown       SISO Coam Suite Teardown
# Test Setup           SISO Coam Test Setup
# Test Teardown        SISO Coam Test Teardown
# 
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
# Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
# Resource    ${BASIC_PATH_5G}/OAM_KPI_61a_SiSo_Auto_BTS_site_reset.robot
# Resource    ${BASIC_PATH_5G}/Baseband_module_reset_via_WEBUI.robot
# Resource     ../AZQR_SG08/Resources/CB006487_keyword.robot
# Resource    resources/CB006783_common_keywords.robot
# Resource    ../KDDI/resources/KDDI_common_keywords.robot
# Variables    TestData/variables_6783_E2E.py
# 
# 
# Documentation
# ...    Author: shufei.chen
# ...    Contact: shufei.chen@nokia-sbell.com
# ...    squad group:SG_08
# ...    Feature CB006783 made2
# 
# Force Tags            5G_RAN_TDD
# ...    PY36
# 
# *** Variables ***
# ${MAX_LOOP}    5
# ${L3_MAX_LOOP}    3
# ${MAX_LOOP_RF_reset}    5
# ${MAX_LOOP_cell_lock_unlock}    1
# *** Test Cases ***
# Each_RF_module_reset_on_WebEm
#     [Tags]    CRT_TRUNK    CRT_22R1    CRT_22R1    CDRT_22R2    CRT_22R3
#     FOR    ${TEST_LOOP}    IN RANGE    0    ${MAX_LOOP_RF_reset}
#         ${date}=    Get Current Date        result_format=%Y-%m-%d_%H:%M:%S
#         Log To Console    \n RF_module_reset ${TEST_LOOP} in progress at: ${date}
#         Each_RF_module_reset_on_WebEm
#         Sleep    60s
#     END
#     check RU power
#     E2E_multi_cell_L3call_data_transfer    ue_index_list=${ue_list_1}    tput_expect=${peak_info_1}
# 
# Site_reset_on_WebEm
#     [Tags]    CRT_TRUNK    CRT_22R1    CRT_22R1    CDRT_22R2    CRT_22R3
#     OAM_KPI_61a_SiSo_Auto_BTS_site_reset
#     check RU power
# #    E2E_multi_cell_L3call_data_transfer    ue_index_list=${ue_list_1}    tput_expect=${peak_info_1}
# 
# 
# All_configured_NRCells_lock_unlock_on_WebEm
#     [Tags]    CRT_TRUNK    CRT_22R1    CRT_22R1    CDRT_22R2    CRT_22R3
#     FOR    ${TEST_LOOP}    IN RANGE    0    ${MAX_LOOP_cell_lock_unlock}
#         ${date}=    Get Current Date        result_format=%Y-%m-%d_%H:%M:%S
#         Log To Console    \n NRCells_lock_unlock ${TEST_LOOP} in progress at: ${date}
#         E2E_Cell_lock_and_unlock
#         Sleep    60s
#     END
#     check RU power
# #    E2E_multi_cell_L3call_data_transfer    ue_index_list=${ue_list_1}    tput_expect=${peak_info_1}
# 
# Each_RF_module_lock_unlock_on_WebEm
#     [Tags]    CRT_TRUNK    CRT_22R1    CRT_22R1    CDRT_22R2    CRT_22R3
#     FOR    ${TEST_LOOP}    IN RANGE    0    ${MAX_LOOP}
#         ${date}=    Get Current Date        result_format=%Y-%m-%d_%H:%M:%S
#         Log To Console    \n RF_module_lock_unlock ${TEST_LOOP} in progress at: ${date}
#         E2E_Each_RF_module_lock_unlock
#         Sleep    60s
#     END
#     check RU power
# #    E2E_multi_cell_L3call_data_transfer    ue_index_list=${ue_list_1}    tput_expect=${peak_info_1}
# 
# BBmod_reset_on_WebEm
#     [Tags]    CRT_TRUNK    CRT_22R1    CRT_22R1    CDRT_22R2    CRT_22R3
#     FOR    ${TEST_LOOP}    IN RANGE    0    ${MAX_LOOP}
#         ${date}=    Get Current Date        result_format=%Y-%m-%d_%H:%M:%S
#         Log To Console    \n BBmod_reset ${TEST_LOOP} in progress at: ${date}
#         Baseband_module_reset_via_WEBUI    with_call=${False}
#         Sleep    60s
#     END
#     check RU power
# #    E2E_multi_cell_L3call_data_transfer    ue_index_list=${ue_list_1}    tput_expect=${peak_info_1}
# 
# Snapshot_capture
#     [Tags]    CRT_TRUNK    CRT_22R1    CRT_22R1    CDRT_22R2    CRT_22R3
#     E2E_Snapshot_capture_via_WEBUI
# 
# Parameter_change_validation_Activation
#     [Tags]    CRT_TRUNK    CRT_22R1    CRT_22R1    CDRT_22R2    CRT_22R3
#      FOR    ${TEST_LOOP}    IN RANGE    0    ${MAX_LOOP}
#         ${date}=    Get Current Date        result_format=%Y-%m-%d_%H:%M:%S
#         Log To Console    \n Parameter_change ${TEST_LOOP} in progress at: ${date}
#         Parameter_change_validation_Activation_pmax
#         Sleep    60s
#      END
# #     E2E_multi_cell_L3call_data_transfer    ue_index_list=${ue_list_1}    tput_expect=${peak_info_1}
# 
# #Configuration_backup_on_WebEm
# #    [Tags]    CRT_TRUNK    CRT_22R1    CDRT_22R2
# #    Configuration_backup_via_WEBUI
# 
# Software_Rollback_from_branchB_to_branchA_on_WebEm
#     [Tags]    CRT_TRUNK    CRT_22R1    CRT_22R1    CDRT_22R2    CRT_22R3
#     Perform SW rollback
#     Perform SW rollback
# 
# E2E_multi_cell_L3call_data_transfer_success_rate
#     [Tags]    CRT_TRUNK    CRT_22R1    CRT_22R1    CDRT_22R2    CRT_22R3
#     FOR    ${TEST_LOOP}    IN RANGE    0    ${L3_MAX_LOOP}
#         ${date}=    Get Current Date        result_format=%Y-%m-%d_%H:%M:%S
#         Log To Console    \n L3 call ${TEST_LOOP} in progress at: ${date}
#         E2E_multi_cell_L3call_data_transfer    ue_index_list=${ue_list_1}    tput_expect=${peak_info_1}
#         Sleep    60s
#     END
# 
# Try_call
#     [Tags]    CRT_22R1    CDRT_22R2    CRT_22R3
#     E2E_multi_cell_L3call_data_transfer    ue_index_list=${ue_list_1}    tput_expect=${peak_info_1}
# 
# PTP_failure_with_call
#     [Tags]    CRT_22R1    CDRT_22R2    CRT_22R3
#     eLLF_PTP_Failure_with_call
