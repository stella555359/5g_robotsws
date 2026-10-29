# *** Settings ***
# Suite Setup          SISO Coam Suite Setup
# Suite Teardown       SISO Coam Suite Teardown
# Test Setup           SISO Coam Test Setup
# Test Teardown        SISO Coam Test Teardown
# Test Timeout         180 min
# 
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
# Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
# Resource    ${BASIC_PATH_5G}/BTS/General_SiSo_Peak_with_Given_Information.robot
# 
# Documentation
# ...    Author:zhihao shi
# ...    contact:zhihao.shi@nokia-sbell.com
# ...    squad group:SG_04
# ...    Feature CB007464 in 5G21B program
# 
# Force Tags            5G_RAN    5G_RAN_TDD
# ...    PY36
# 
# *** Variables ***
# 
# *** Test Cases ***
# [1][1.0] CB007464-5G-D_03_General_SiSo_E2E_system_setup_with_data_transfer_conducted_40M+50M
#     [Tags]    1S-2CC-4D-4U    CRT_22R3    CRT_22R4    CRT_TRUNK
#     General_SiSo_Peak_with_Given_Information    use_case_variable=${True}    suite_name=${SUITE NAME}    test_name=${TEST NAME}
#     ...    ue_num_each_call=2
# 
# #[1]CB007464-5G-D_01_General_SiSo_Commissioning_BTS_Template_Commissioning_40M+50M
# #    [Tags]    1S-2CC-4D-2U
# #    General_SiSo_Commissioning_BTS_Template_Commissioning
# #
# #[1]CB007464-5G-D_02_General_SiSo_Cell_lock_and_unlock_40M+50M
# #    [Tags]    1S-2CC-4D-2U
# #    General_SiSo_RU_lock_unlock
# 
# *** Keywords ***
