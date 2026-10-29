# *** Settings ***
# Suite Setup          SISO Coam Suite Setup
# Suite Teardown       SISO Coam Suite Teardown
# Test Setup           SISO Coam Test Setup
# Test Teardown        SISO Coam Test Teardown
# 
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
# Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
# Resource     Resources/CB009542_common_keyword.robot
# Variables    TestData/variables_9542.py
# 
# Documentation
# ...    Author: hongli.xu
# ...    Contact: hongli.xu@nokia-sbell.com
# ...    squad group:SG_08
# ...    Feature CB009542
# 
# Force Tags            RAN_5G_TDD    5G_RAN_TDD    SBTS00    SBTS24R1    RAN_5G    5G_RAN    CRT_UTE	   STATE_SW_UPLOADED
# ...   PY36
# ...    CLOUD_5G_CLASSICAL_SA_ASOF_3xAWHQE
# 
# *** Variables ***
# 
# *** Test Cases ***
# [1][1.0] General_SiSo_E2E_system_setup_with_data_transfer
#    [Tags]     CRT_TRUNK
#    General_SiSo_E2E_system_setup_with_data_transfer
# 
# [1][1.0] Manual_SiSo_SM_BTS_Site_Reset
#    [Tags]     CRT_TRUNK
#    Manual_SiSo_SM_BTS_Site_Reset
# 
# [1][3.0] General_SiSo_Auto_Cell_lock_and_unlock
#     [Tags]     CRT_TRUNK
#     General_SiSo_Auto_Cell_lock_and_unlock
# 
# [1][2.0] General_SiSo_Auto_RF_lock_unlock_with_L3call
#     [Tags]     CRT_TRUNK
#     General_SiSo_Auto_RF_lock_unlock_with_L3call
