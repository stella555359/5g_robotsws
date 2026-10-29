# *** Settings ***
# Suite Setup          SISO Coam Suite Setup
# Suite Teardown       SISO Coam Suite Teardown
# Test Setup           SISO Coam Test Setup
# Test Teardown        SISO Coam Test Teardown
# 
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
# Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
# Resource     Resources/CB009223_common_keyword.robot
# Variables    TestData/variables_9223.py
# 
# Documentation
# ...    Author: jiangjing.lin
# ...    Contact: jiangjing.lin@nokia-sbell.com
# ...    squad group:SG_08
# ...    Feature CB009223
# 
# Force Tags            RAN_5G_TDD    5G_RAN_TDD    SBTS00    RAN_5G    5G_RAN    CRT_UTE	   STATE_SW_UPLOADED
# ...   PY36
# ...    CLOUD_5G_CLASSICAL_SA_ASIKL_ABILB1_AEQN_5GC002374
# 
# *** Variables ***
# 
# *** Test Cases ***
# [1]BTS_setup_Commissioned_with_Cell_Setup_via_WebEM_config6
#    [Tags]    CRT_21A    CRT_TRUNK    CRT_21B    CRT_22R1    CRT_22R2    CRT_22R3    CRT_22R4
#    BTS_setup_Commissioned_with_Cell_Setup_via_WebEM_config6
# 
# [1]L3_call_Single_UE_PEAK_rate_with_L3_call_config_SA
#    [Tags]    CRT_21A    CRT_TRUNK    CRT_21B    CRT_22R1    CRT_22R2    CRT_22R3    CRT_22R4
#    L3_call_Single_UE_PEAK_rate_with_L3_call_config_SA
# 
# [1]Recovery_and_reset_RAT_Reset_from_WebEM_config6
#     [Tags]    CRT_21A    CRT_TRUNK    CRT_21B    CRT_22R1    CRT_22R2    CRT_22R3    CRT_22R4
#     CB009223 Recovery_and_reset_RAT_Reset_from_WebEM_config6
# 
# [1]operation_RF_lock_or_unlock_config6
#      [Tags]    CRT_21A    CRT_TRUNK    CRT_21B    CRT_22R1    CRT_22R2    CRT_22R3    CRT_22R4
#      CB009223 operation_RF_lock_or_unlock_config6
# 
# [1]Operation_cell_lock_or_unlock_config6
#     [Tags]    CRT_21A    CRT_TRUNK    CRT_21B    CRT_22R1    CRT_22R2    CRT_22R3    CRT_22R4
#     CB009223 Operation_cell_lock_or_unlock_config6
