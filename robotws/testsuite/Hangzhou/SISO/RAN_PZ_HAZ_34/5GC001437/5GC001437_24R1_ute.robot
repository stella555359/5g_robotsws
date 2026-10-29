# *** Settings ***
# Documentation     author: Zhang Lusha
# ...               contact: lusha.zhang@nokia-sbell.com
# ...               squad group: MMW_02
# Suite Setup       Common Setup 1437
# Suite Teardown    Run Keyword And Ignore Error     SISO Coam Suite Teardown
# Force Tags        5G_RAN    5G_RAN_TDD    RAN_5G    RAN_5G_TDD    SBTS00    CLOUD_5G_CLASSICAL_SA_ASIKL_ABILB1_AEQP    STATE_SW_UPLOADED
# ...   PY36
# Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/5GC001437/Resources/5GC001437_resource.robot
# 
# 
# *** Variables ***
# 
# 
# *** Test Cases ***
# [1][1.0] General_SiSo_Commissioning_BTS_Template_Commissioning
#     [Documentation]    The purpose of this test case is to check if not commissioned gNB can
#     ...    be correctly configured using BTS Template, verify Managed Object Class in WebUI
#     ...    and update parameters via WebUI. bandwith is 100mhz
#     [Tags]    CIT
#     [Setup]    SISO Coam Test Setup
#     General_SiSo_Commissioning_BTS_Template_Commissioning
#     [Teardown]    SISO Coam Test Teardown
# 
# [2][2.0] General_SiSo_Fault_1900_EFaultId_FrConfiguringFailed
#     [Tags]    CIT
#     [Setup]    SISO Coam Test Setup
#     General_SiSo_Fault_1900_EFaultId_FrConfiguringFailed_PMAX
#     [Teardown]    SISO Coam Test Teardown
# 
# [2][1.0] General_SiSo_RF_module_addition_in_BIM_and_WebUI
#     [Documentation]    General_SiSo_RF_module_addition_in_BIM_and_WebUI
#     [Tags]    CIT
#     [Setup]    SISO Coam Test Setup
#     General_SiSo_RF_module_addition_in_BIM_and_WebUI
#     [Teardown]    SISO Coam Test Teardown
# 
# [1]General_SiSo_RF_alarms_with_recovery
#     [Tags]    CIT
#     [Setup]    SISO Coam Test Setup
#     General_SiSo_RF_alarms_with_recovery
#     [Teardown]    SISO Coam Test Teardown
# 
# [1][2.0] General_SiSo_NR-ARFCN_check
#     [Documentation]    General_SiSo_NR-ARFCN_check
#     [Tags]    CIT
#     [Setup]    SISO Coam Test Setup
#     General_SiSo_NR-ARFCN_check
#     [Teardown]    SISO Coam Test Teardown
# 
# [1][1.0] General_SiSo_RF_module_power_reset
#     [Documentation]    change RU from AEQP to  AEQP_I and recopvery,
#     ...    verify whether AEQP_I can run normally
#     [Tags]    CIT
#     [Setup]    SISO Coam Test Setup
#     log to console    \n run AEQP_I case....
#     csn.reset_cache
#     change_product_code    origin_product_code=${AEQP_product_code}   target_product_code=${AEQP_I_product_code}
#     General_SiSo_RF_module_power_reset
#     [Teardown]    Run Keywords
#     ...    change_product_code    origin_product_code=${AEQP_I_product_code}   target_product_code=${AEQP_product_code}
#     ...    AND    SISO Coam Test Teardown
# 
# 
# *** Keywords ***
# Common Setup 1437
#     Sleep    600s
#     SISO Coam Suite Setup