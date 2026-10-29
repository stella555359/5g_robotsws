# *** Settings ***
# Suite Setup          Run Keywords    CBRS Suite Setup
# ...                  AND     Case Preparation
# Suite Teardown       CBRS Suite Teardown
# Test Setup           CB009154-C CBRS Test Setup
# Test Teardown        CB009154-C CBRS Test Teardown
# 
# Resource    Resources/CB009154-C_common_keywords.robot
# 
# Documentation
# ...    Author:wangqingqing
# ...    contact:qingqing.wang@nokia-sbell.com
# ...    squad group:SG_08
# ...    Feature CB009154-C
# 
# Force Tags            RAN_5G_TDD    5G_RAN_TDD    RAN_5G    5G_RAN    CRT_UTE    STATE_SW_UPLOADED    SBTS00
# ...    PY36
# ...    CLOUD_5G_CLASSICAL_SA_ASILL_ABIOL_AZQC
# 
# *** Variables ***
# 
# *** Test Cases ***
# [1]CB009154-C_9_CBSD_behavior_check_when_BBMOD_reset
#     [Tags]    CRT_TRUNK
#     CB009154-C_9_CBSD_behavior_check_when_BBMOD_reset
# 
# [1]CB009154-C_8_CBSD_behavior_check_when_SBTS_reset
#     [Tags]    CRT_TRUNK
#     CB009154-C_8_CBSD_behavior_check_when_SBTS_reset
# 
# [1]CB009154-C_19_verify_the_behavior_when_NR_grant_terminated
#     [Tags]    CRT_TRUNK
#     CB009154-C_19_verify_the_behavior_when_NR_grant_terminated
# 
# [1]CB009154-C_24_online_modify_supportedSpectrumV2_Volatile_MO_released
#     [Tags]    CRT_TRUNK
#     CB009154-C_24_online_modify_supportedSpectrumV2_Volatile_MO_released
# 
# [1]CB009154-C_13_online_add_NR_cell_under_RFS
#     [Tags]    CRT_TRUNK
#     CB009154-C_13_online_add_NR_cell_under_RFS
# 
# [1]CB009154-C_26_CBSD_behavior_check_when_modify cbrsFreqPriority
#     [Tags]    CRT_TRUNK
#     CB009154-C_26_CBSD_behavior_check_when_modify cbrsFreqPriority
# 
# [1]CB009154-C_17_verify_NR_preempt_LTE_grant
#     [Tags]    CRT_TRUNK
#     CB009154-C_17_verify_NR_preempt_LTE_grant
# 
# *** Keywords ***
