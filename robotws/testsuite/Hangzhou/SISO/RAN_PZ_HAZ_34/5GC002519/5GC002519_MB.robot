# *** Settings ***
# Suite Setup          SISO Coam Suite Setup
# Suite Teardown       SISO Coam Suite Teardown
# Test Setup           SISO Coam Test Setup
# Test Teardown        SISO Coam Test Teardown
# Test Timeout         100 min
# 
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
# Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
# Resource    ${BASIC_PATH_5G}/General_SiSo_U-plane_Fast-C-Plane_message_reception_NetActNIDD_PM_measurement_5G_eCPRI_RU_reporting_update.robot
# 
# Documentation
# ...    Author: zhihao shi
# ...    Contact: zhihao.shi@nokia-sbell.com
# ...    squad group:SG_04
# ...    Feature 5GC002367-A in 5G20B program
# 
# Force Tags            5G_RAN_TDD    5G_RAN_TDD    RAN_5G_TDD    RAN_5G    STATE_SW_UPLOADED   CLOUD_5G_CLASSICAL_ASIKL_ABILB1_AEQY
# ...    PY36
# 
# *** Variables ***
# 
# *** Test Cases ***
# [1][1.0] 5GC002519-MB_01_02_eCPRI_U-plane_Fast-C-Plane_message_reception_NetActNIDD_PM_measurement_5G_eCPRI_RU_reporting_update
#     [Tags]    CRT_TRUNK    SBTS00    CRT_UTE
#     General_SiSo_U-plane_Fast-C-Plane_message_reception_NetActNIDD_PM_measurement_5G_eCPRI_RU_reporting_update
# 
# #[1][1.0] 5GC002519-MB_01_01_eCPRI_U-plane_Fast-C-Plane_message_reception_NetActNIDD_PM_measurement_5G_eCPRI_RU_reporting_setup_Robustness
# #    General_SiSo_U-plane_Fast-C-Plane_message_reception_NetActNIDD_PM_measurement_5G_eCPRI_RU_reporting_update    miNrEcpriUpFCp=15min
# #
# #[1][1.0] 5GC002519-MB_01_03_RAURU_eCPRI_U-plane_Fast-C-Plane_message_reception_NIDD_PM_counters_5G_RAU_collection_and_reporting_to_NetAct_step 2
# #    General_SiSo_U-plane_Fast_C-plane_counters
# 
# *** Keywords ***
