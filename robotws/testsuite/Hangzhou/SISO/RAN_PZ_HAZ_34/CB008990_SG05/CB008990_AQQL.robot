# *** Settings ***
# Suite Setup          SISO Coam Suite Setup
# #Suite Teardown       SISO Coam Suite Teardown
# Test Timeout         60 min
# 
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
# Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/step_keywords.robot
# Resource    ./resource/CB008990_resource.robot
# 
# Documentation
# ...    Author: Liu Yue
# ...    Contact: yue.2.liu@nokia-sbell.com
# ...    squad group:SG_05
# ...    Feature CB008980 in 5G24R2 program
# 
# Force Tags    RAN_5G_TDD
# ...    PY36
# 
# *** Variables ***
# 
# *** Test Cases ***
# [1]CB008990-SR-01_Ecpri_RU_DFE_no_TX_Data_fault_activation
#     [Tags]    CRT_TRUNK
#     [Setup]    SISO Coam Test Setup 
#     Ecpri_RU_DFE_no_TX_Data_fault_activation_Fault1904_AQQL
#     [Teardown]    SISO Coam Test Teardown
# [1]CB008990-SR-01_Ecpri_RU_DFE_Fronthaul_switch_link_fault_activation
#     [Tags]    CRT_TRUNK
#     [Setup]    SISO Coam Test Setup 
#     Ecpri_RU_DFE_Fronthaul_switch_link_fault_activation_Fault1981_AQQL
#     [Teardown]    SISO Coam Test Teardown
# [1]CB008990-SR-01_Ecpri_RU_DFE-DFE_link_fault_activation
#     [Tags]    CRT_TRUNK
#     [Setup]    SISO Coam Test Setup 
#     Ecpri_RU_DFE_Fronthaul_switch_link_fault_activation_Fault1981_AQQL
#     [Teardown]    SISO Coam Test Teardown
# 
# *** Keywords ***
