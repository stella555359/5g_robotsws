# *** Settings ***
# Suite Setup          SISO Coam Suite Setup
# Suite Teardown       SISO Coam Suite Teardown
# Test Setup           SISO Coam Test Setup
# Test Teardown        SISO Coam Test Teardown
# Test Timeout         300min
# 
# Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
# Resource     ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
# Resource     ${BASIC_PATH_5G}/General_SiSo_RF_module_addition_in_BIM_and_WebUI.robot
# Resource     ${BASIC_PATH_5G}/General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot.robot
# Resource     ${BASIC_PATH_5G}/General_SiSo_SOAP_RP1_verification.robot
# Resource     ${BASIC_PATH_5G}/General_SiSo_RF_module_reset_from_GUI.robot
# Resource     ${BASIC_PATH_5G}/General_SiSo_NR-ARFCN_check.robot
# Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/step_keywords.robot
# Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
# 
# Variables    TestData/variables.py
# 
# 
# Documentation
# ...    Author:shasha.liu
# ...    contact:shasha.liu@nokia-sbell.com
# ...    squad group:SG_05
# ...    Feature 5GC000470-N in 5G20A program
# 
# Force Tags   5G_SISO  RAN_5G   RAN_5G_TDD  master_classicalbts_all  STATE_SW_UPLOADED  CLOUD_5G_CLASSICAL_SA_ASIKL_ABILB1_AWHHD
# ...    PY36
# 
# *** Variables ***
# 
# *** Test Cases ***
# [1]5GC000470-N-I&V-5GC001541_37_AWHHD_General_SiSo_RF_module_addition_in_BIM_and_WebUI
#     [Tags]    CRT_TRUNK      SBTS00   CRT_22R4
#     General_SiSo_RF_module_addition_in_BIM_and_WebUI
# 
# [1]5GC000470-N-I&V-5GC001541_35_AWHHD_General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot
#     [Tags]    CRT_TRUNK      SBTS00   CRT_22R4
#     General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot
# 
# [1]5GC000470-N-I&V-5GC001541_31_AWHHD_General_SiSo_SOAP_RP1_verification
#     [Tags]    CRT_TRUNK      SBTS00   CRT_22R4
#     General_SiSo_SOAP_RP1_verification
# 
# [1]5GC000470-N-I&V-5GC001541_27_AWHHD_General_SiSo_Cell_lock_and_unlock (under creation)
#     [Tags]    CRT_TRUNK      SBTS00   CRT_22R4
#     [Teardown]    Run Keywords   Perform cell unlock via rest api    AND
#     ...                          COAM Teardown gnb connections
#     General_SiSo_Cell_lock_and_unlock_under_creation
# 
# [1]5GC000470-N-I&V-5GC001541_24_AWHHD_General_SiSo_RU_block_unblock
#     [Tags]    CRT_TRUNK       SBTS00   CRT_22R4
#     General_SiSo_RU_block_unblock
# 
# [1]5GC000470-N-I&V-5GC001541_02_AWHHD_General_SiSo_RF_module_reset_from_GUI
#     [Tags]    CRT_TRUNK      SBTS00   CRT_22R4
#     General_SiSo_RF_module_reset_from_GUI
# 
# #[1]5GC000470-N-I&V-5GC001541_01_AWHHD_General_SiSo_Fault_1900_EFaultId_FrConfiguringFailed_PMAX
# #    [Tags]   CRT_20B
# #    General_SiSo_Fault_1900_EFaultId_FrConfiguringFailed_PMAX
# 
# [1]5GC000470-N-I&V-5GC001541_22_AWHHD_General_SiSo_NR-ARFCN_check
#     [Tags]    CRT_TRUNK      SBTS00   CRT_22R4
#     General_SiSo_NR-ARFCN_check   variable_from_CFAM=${Variables_CFAM_470}
# 
# *** Keywords ***
# General_SiSo_Cell_lock_and_unlock_under_creation
#     Connect to gnb coam via ssl
#     Perform cell lock via rest api
#     #Du login page via webUI
#     #Perform Cell Lock
#     #Wait Until Keyword Succeeds    5min    30s    Cell Should Be Locked
#     #Perform Cell Unlock
#     #Wait Until Keyword Succeeds    5min    30s    Cell Should Be Unlocked
#     #Wait Until Keyword Succeeds    10min    10s     Du Check cell on air via WebUI
# 
# General_SiSo_RU_block_unblock
#     Du login page via webUI
#     Perform RU Lock
#     Wait Until Keyword Succeeds    5min    30s    RU Should Be Locked
#     Perform RU Unlock
#     Wait Until Keyword Succeeds    5min    30s    RU Should Be Unlocked
#     Wait Until Keyword Succeeds    10min    10s     Du Check cell on air via WebUI
