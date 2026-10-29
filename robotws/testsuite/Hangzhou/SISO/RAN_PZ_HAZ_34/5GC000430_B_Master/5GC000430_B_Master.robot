# *** Settings ***
# Suite Setup          SISO Coam Suite Setup
# Suite Teardown       SISO Coam Suite Teardown
# Test Setup
# Test Teardown
# Test Timeout         200 min
# 
# Resource     Resource/5GC000430_B_Master_KW.robot
# Variables    TestData/variables.py
# 
# Documentation
# ...    Author:shasha.liu
# ...    contact:shasha.liu@nokia-sbell.com
# ...    squad group:SG_05
# ...    Feature 5GC000430-B_uDTX_in_Master (5GC000430 Micro discontinuous transmission (µDTX) for Energy Efficiency) in 5G20B
# 
# Force Tags     RAN_5G   RAN_5G_TDD   CLOUD_5G_CLASSICAL_SA_ASIKL_ABILB1_AEQE   STATE_SW_UPLOADED   SBTS00
# ...    PY36
# 
# *** Variables ***
# 
# *** Test Cases ***
# [1][1.0] 5GC000430-B_01_04_Micro-DTX_deactivate_on_Master_cMAAr6.1_64T64R_Made_RRU
#     [Tags]    master_classicalbts_all   CRT_UTE    CRT_TRUNK    CRT_22R2    CRT_22R3    CRT_22R1    CRT_22R4
#     [Setup]   SISO Coam Test Setup
#     General_Feature_Micro-DTX_deactivate_microDtxEnabled_false
#     [Teardown]   SISO Coam Test Teardown
# 
# [1][1.0] 5GC000430-B_01_03_Micro-DTX_activate_on_Master_cMAAr6.1_64T64R_Made_RRU
#     [Tags]    master_classicalbts_all   CRT_UTE    CRT_TRUNK    CRT_22R2    CRT_22R3   CRT_22R1    CRT_22R4
#     [Setup]   SISO Coam Test Setup
#     General_Feature_Micro-DTX_activate_microDtxEnabled_true
#     [Teardown]   SISO Coam Test Teardown
# 
# #[1]5GC000430-B_01_05_Fault_4308_EFaultId_MdtxConfigurationFailureAl_raise
# #    [Tags]    master_classicalbts_all
# #    [Setup]   SISO Coam Test Setup
# #    General_Fault_4308_EFaultId_MdtxConfigurationFailureAl_raise
# #    [Teardown]   SISO Coam Test Teardown
# #
# #[1]5GC000430-B_01_01_Feature_parameter_actMicroDtx_migration_check
# #    [Tags]    master_classicalbts_all
# #    [Setup]   SISO Coam Test Setup
# #    General_Amber_Feature_parameter_actMicroDtx_migration_check
# #    [Teardown]   SISO Coam Test Teardown
# 
# *** Keywords ***
