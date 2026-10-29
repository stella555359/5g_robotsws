# *** Settings ***
# Suite Setup          SISO Coam Suite Setup
# Suite Teardown       SISO Coam Suite Teardown
# Test Setup           SISO Coam Test Setup
# Test Teardown        SISO Coam Test Teardown
# Test Timeout         1h
# 
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
# Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
# Resource    ${BASIC_PATH_5G}/Cell/E2E_SiSo_Cell_block_and_unblock_gNB.robot
# Resource    ${BASIC_PATH_5G}/E2E_SiSo_RU_lock_and_unlock_gNB.robot
# 
# Documentation
# ...    Author: liu yue
# ...    contact: yue.2.liu@nokis-sbell.com
# ...    squad group:SG_05
# ...    Feature 'CNI-84112 AWHQV dual carrier 60Mhz + 20MHz support' in 22R4 program
# 
# Force Tags    RAN_5G_TDD    RAN_5G    STATE_SW_UPLOADED   CLOUD_5G_CLASSICAL_SA_ASOE_AWHQV
# ...   PY36
# 
# *** Variables ***
# 
# *** Test Cases ***
# [1]AWHQV_1Sector_2CC_DualCarrier_4DL_256QAM_4UL_64QAM_FR1_20MHz_60MHz_A7_General_SiSo_Cell_block_and_unblock
#     [Tags]    1S-2CC-4D4U_A7_20-60M_F0-9_3CPRI    CRT_TRUNK    CRT_22R4
#     E2E_SiSo_Cell_block_and_unblock_gNB    with_call=${False}
# 
# [1]AWHQV_1Sector_2CC_DualCarrier_4DL_256QAM_4UL_64QAM_FR1_20MHz_60MHz_A8_iqc_General_SiSo_RU_lock_unlock
#     [Tags]    1S-2CC-4D4U_A8_20-60M_F0-9_2CPRI_iqc    CRT_TRUNK   CRT_22R4
#     E2E_SiSo_RU_lock_and_unlock_gNB    with_call=${False}
# 
# *** Keywords ***
