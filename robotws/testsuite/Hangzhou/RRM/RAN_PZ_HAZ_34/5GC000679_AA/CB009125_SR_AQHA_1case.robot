# *** Settings ***
# Suite Setup       9125 Coam Suite Setup
# Suite Teardown    Run Keyword And Ignore Error     SISO Coam Suite Teardown
# Test Setup        CB009125_SR Case Setup
# Test Teardown     CB009125_SR Case Teardown
# Force Tags    RAN_5G   RAN_5G_TDD   STATE_SW_UPLOADED   CLOUD_5G_CLASSICAL_ANDROID_SA_ASIBL_ABIOB1_AQHA_AHPH_2xAHPF   SBTS00   CRT_UTE
# ...    PY36
# Library            OperatingSystem
# Library            Collections
# Library            BuiltIn
# Library            String
# Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/5G/5G_Setup_And_Teardown.robot
# Resource     testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC000679_AA/Resources/CB009125_CXD_common_keywords.robot
# Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
# 
# Documentation
# ...   author: chen xiaodong
# ...   contact: xiaodong.d.chen@nokia-sbell.com
# ...   squad group: SG_02
# 
# *** Test Cases ***
# [1]CB009125_SR_B_B2_SISO_AQHA_02_ General_SiSo_Auto_RF_lock_unlock
#     Multiple UE Attach NR and LTE then Start Traffic
#     Selenium Login And Disable Screen Lock
#     ${ru_index_list}    Get All RU Index
#     ${cell_list}    Get All Cell Id
#     Connect to all rus with allocated IP
#     Lock all RUs    ru_index_list=${ru_index_list}
#     Unock all RUs    ru_index_list=${ru_index_list}
#     Multiple UE Attach NR and LTE
