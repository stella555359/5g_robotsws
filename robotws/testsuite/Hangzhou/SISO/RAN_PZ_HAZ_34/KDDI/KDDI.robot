# *** Settings ***
# Suite Setup          Run keywords   SISO Coam Suite Setup   AND   Set PA vaule to KDDI
# Suite Teardown       SISO Coam Suite Teardown
# Test Setup           SISO Coam Test Setup
# Test Teardown        SISO Coam Test Teardown
# 
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
# Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
# Resource    ${BASIC_PATH_5G}/General_SiSo_RF_module_reset_from_GUI.robot
# Resource    ${BASIC_PATH_5G}/OAM_KPI_61a_SiSo_Auto_BTS_site_reset.robot
# Resource    ${BASIC_PATH_5G}/Baseband_module_reset_via_WEBUI.robot
# Resource    ${BASIC_PATH_5G}/Baseband_module_lock_unlock_via_WEBUI.robot
# Resource    resources/KDDI_common_keywords.robot
# 
# Documentation
# ...    Author: lanwen.cai
# ...    Contact: lanwen.cai@nokia-sbell.com
# ...    squad group:SG_08
# 
# Force Tags            5G_RAN_TDD    CRT_22R3
# ...    PY36
# 
# *** Variables ***
# ${MAX_LOOP}    5
# 
# *** Test Cases ***
# KDDI_L3call_data_transfer
#     Commissioning SCF And Check On Air      scf_path=${Golden_SCF_Path}
# #    KDDI check multi cell L3call    target_avg_percent=0.95    min_percent=0.85    duration=${600}
# 
# KDDI_power_reset
#     KDDI_power_reset
# #    KDDI check multi cell L3call
# 
# Configuration_backup
#     Configuration_backup_via_WEBUI
# 
# All_configured_NRCells_lock_unlock
#     FOR    ${TEST_LOOP}    IN RANGE    0    ${MAX_LOOP}
#         ${date}=    Get Current Date        result_format=%Y-%m-%d_%H:%M:%S
#         Log To Console    \n NRCells_lock_unlock ${TEST_LOOP} in progress at: ${date}
#         KDDI_Cell_lock_and_unlock
#         Sleep    60s
#     END
# #    KDDI check multi cell L3call
# 
# Each_single_Baseband_module_lock_unlock
#     FOR    ${TEST_LOOP}    IN RANGE    0    ${MAX_LOOP}
#         ${date}=    Get Current Date        result_format=%Y-%m-%d_%H:%M:%S
#         Log To Console    \n Baseband_module_lock_unlock ${TEST_LOOP} in progress at: ${date}
#         Baseband_module_lock_unlock_by_coam
#         Sleep    60s
#     END
# #    KDDI check multi cell L3call
# 
# Each_RF_module_lock_unlock
#     FOR    ${TEST_LOOP}    IN RANGE    0    ${MAX_LOOP}
#         ${date}=    Get Current Date        result_format=%Y-%m-%d_%H:%M:%S
#         Log To Console    \n RF_module_lock_unlock ${TEST_LOOP} in progress at: ${date}
#         Each_RF_module_lock_unlock
#         Sleep    60s
#     END
# #    KDDI check multi cell L3call
# 
# Each_RF_module_reset
#     FOR    ${TEST_LOOP}    IN RANGE    0    ${MAX_LOOP}
#         ${date}=    Get Current Date        result_format=%Y-%m-%d_%H:%M:%S
#         Log To Console    \n RF_module_reset ${TEST_LOOP} in progress at: ${date}
#         General_SiSo_RF_module_reset_from_GUI
#         Sleep    60s
#     END
# #    KDDI check multi cell L3call    pcmd=${True}
# 
# Site_reset_stability
#     OAM_KPI_61a_SiSo_Auto_BTS_site_reset
# #    KDDI check multi cell L3call
# 
# Each_single_Baseband_module_reset
#     FOR    ${TEST_LOOP}    IN RANGE    0    ${MAX_LOOP}
#         ${date}=    Get Current Date        result_format=%Y-%m-%d_%H:%M:%S
#         Log To Console    \n Baseband_module_reset ${TEST_LOOP} in progress at: ${date}
#         Baseband_module_reset_via_WEBUI
#         Sleep    60s
#     END
# #    KDDI check multi cell L3call
# 
# Parameter_change_validation_Activation
#     FOR    ${TEST_LOOP}    IN RANGE    0    ${MAX_LOOP}
#         ${date}=    Get Current Date        result_format=%Y-%m-%d_%H:%M:%S
#         Log To Console    \n Parameter_change_validation_Activation ${TEST_LOOP} in progress at: ${date}
#         update_parameter_dllaIniMcs_via_WEBUI
#         Sleep    60s
#     END
# 
# KDDI_Snapshot_capture
#     KDDI_Snapshot_capture_via_WEBUI
# 
# KDDI_update_ulDMRS_with_L3call
#     KDDI_update_ulDMRS_with_L3call
# 
# KDDI_4G_reset_with_5GL3call
#     4G reset via webUI
#     COAM Wait gnb And Cells ready    timeout=15min    gnb_type='${gNb_CuType}'
# #    KDDI check multi cell L3call
# 
# KDDI_LOCK_x2
#     Update 4G X2 via api
#     COAM Wait gnb And Cells ready    timeout=15min    gnb_type='${gNb_CuType}'
# #    KDDI check multi cell L3call
# 
# KDDI_SW_rollback_with_L3call
#     Perform SW rollback
#     Perform SW rollback
