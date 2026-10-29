# *** Settings ***
# Suite Setup          SISO Coam Suite Setup
# Suite Teardown       SISO Coam Suite Teardown
# Test Setup           SISO Coam Test Setup
# Test Teardown        SISO Coam Test Teardown
# Test Timeout         100 min
# 
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
# Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
# Resource    ${BASIC_PATH_5G}/General_SiSo_5GC001866_K_Activate_BSR_to_gNB_through_parameter_WebEM_NSA_Classical.robot
# Resource    ${BASIC_PATH_5G}/General_SiSo_5GC001866_K_Deactivate_Custome_BSR_WebEM_NSA_Classical.robot
# 
# Documentation
# ...    Author:zhihao shi
# ...    contact:zhihao.shi@nokia-sbell.com
# ...    squad group:SG_04
# ...    Feature 5GC001866 in trunk program
# 
# Force Tags            5G_RAN    5G_RAN_TDD    RAN_5G_TDD    RAN_5G    STATE_SW_UPLOADED    CLOUD_5G_CLASSICAL_ASIKL_ABILB1_AEQQ_ENB
# ...    PY36
# 
# *** Variables ***
# 
# *** Test Cases ***
# [1]5GC002433_DD_01_AQQY_5GC001866_K_Activate_BSR_to_gNB_through_parameter_WebEM_NSA_Classical_Ecpri
#     [Tags]    CIT_22R4    CIT_TRUNK
#     General_SiSo_5GC001866_K_Activate_BSR_to_gNB_through_parameter_WebEM_NSA_Classical
#     General_SiSo_5GC001866_K_Deactivate_Custome_BSR_WebEM_NSA_Classical
#     [teardown]  run keywords    run keyword if test failed     Commissioning SCF And Check On Air
#     ...    scf_path=${Case_SCF_Path}    AND    SISO Coam Test Teardown
# 
# #[1]5GC002433_DD_02_AQQY_5GC001866_K_Deactivate_Custome_BSR_WebEM_NSA_Classical_Ecpri
# #    General_SiSo_5GC001866_K_Activate_BSR_to_gNB_through_parameter_WebEM_NSA_Classical
# #    General_SiSo_5GC001866_K_Deactivate_Custome_BSR_WebEM_NSA_Classical
# 
# *** Keywords ***
