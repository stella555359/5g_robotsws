# *** Settings ***
# Suite Setup          8712_SISO Suite Setup
# Suite Teardown       SISO Suite Teardown_23R1
# Test Setup           SISO Test Setup
# Test Teardown        SISO Test Teardown
# Test Timeout         600 min
# 
# Resource      Resource/CB008974_old_siso_Resource.robot
# 
# 
# Documentation
# ...    Author:Frank Luo
# ...    contact:frank.s.luo@nokia-sbell.com
# ...    squad group:SG_01
# ...    Feature CB005845 in 5G22R2 program
# 
# Force Tags            RAN_5G    RAN_5G_TDD    STATE_SW_UPLOADED  SBTS00
# ...    CLOUD_5G_CLASSICAL_QC_SA_ASILL_ABINB1_2xAEQE    PY36
# 
# *** Variables ***
# 
# *** Test Cases ***
# [1][2.0] General_SiSo_RU_module_reset_from_GUI
#     [Tags]    CRT_23R1   2CC
#     TC.12_General_SiSo_RF_module_reset_from_GUI_crt
# 
# [1][1.1] General_SiSo_RF_alarms_without_recovery
#     [Tags]    CRT_23R1   2CC
#     TC.22_General_SiSo_RF_alarms_without_recovery
# 
# [1][3.0] General_SiSo_Fault_1900_EFaultId_FrConfiguringFailed
#     [Tags]    CRT_23R1    2CC
#     TC.19_General_SiSo_Fault_1900_EFaultId_FrConfiguringFailed_PMAX
# 
# ####NEW####
# #[1][2.0] Manual_SiSo_SM_NR_RAT_reset
# #    [Tags]    CRT_23R1    L3CALL   2CC
# #    [Timeout]  60min
# #    CommonCase.Manual_SiSo_SM_NR_RAT_reset_crt
# 
# [1][2.1] General_SiSo_Cell_block_and_unblock
#     [Tags]    CRT_23R1   L3CALL   1CC
#     [Timeout]  60min
#     TC.62_Manual_SiSo_SM_LTE Cell_block_unblock_crt   scf_file=${CFGFILE_PATH}/${block_unblock_23R1_casescf}